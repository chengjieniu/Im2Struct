function [net,stats] = my_cnn_train_dag(getBatch, varargin)
%CNN_TRAIN_DAG Demonstrates training a CNN using the DagNN wrapper
%    CNN_TRAIN_DAG() is similar to CNN_TRAIN(), but works with
%    the DagNN wrapper instead of the SimpleNN wrapper.

% Copyright (C) 2014-15 Andrea Vedaldi.
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

% Todo: save momentum with checkpointing (a waste?)
opts.id = 1;
opts.useGpu = true;
opts.dataDir = '';
opts.outputDir = '';
opts.saveDir = '';
opts.continue = false ;
opts.batchSize = 256 ;
opts.numSubBatches = 1 ;
opts.train = [] ;
opts.val = [] ;
opts.gpus = [] ;
opts.prefetch = false ;
opts.numEpochs = 100 ;
opts.learningRate = 1 ;
opts.weightDecay = 1 ;
opts.momentum = 0.9 ;
opts.clip_d = 1;
opts.epochpre = 0;
opts.derOutputs = {'objective', 1} ;
opts.extractStatsFn = @extractStats ;
opts.plotStatistics = false;
opts.outputN = 1;
opts = vl_argparse(opts, varargin) ;

if ~exist(opts.saveDir, 'dir'), mkdir(opts.saveDir) ; end
if ~exist(opts.outputDir, 'dir'), mkdir(opts.outputDir) ; end

% -------------------------------------------------------------------------
%                                                            Initialization
% -------------------------------------------------------------------------

% opts.train = 1:2*numel(opts.train);

state.getBatch = getBatch ;
stats = [] ;

% setup GPUs
numGpus = numel(opts.gpus) ;
if numGpus > 1
  if isempty(gcp('nocreate')),
    parpool('local',numGpus) ;
    spmd, gpuDevice(opts.gpus(labindex)), end
  end
  if exist(opts.memoryMapFile)
    delete(opts.memoryMapFile) ;
  end
elseif numGpus == 1
%   gpuDevice(opts.gpus)
end

% -------------------------------------------------------------------------
%                                                        Train and validate
% -------------------------------------------------------------------------

modelPath = @(ep) fullfile(opts.saveDir, sprintf('FT-net-%d.mat', opts.id));
modelFigPath = fullfile(opts.saveDir, 'net-train.pdf') ;

trainInfoPath = fullfile(opts.outputDir, sprintf('FT-info-%d.txt', opts.id));
fid = fopen(trainInfoPath, 'w');
fprintf(fid,'Start training... \n\n\n');
fclose(fid);


epoch_start = 0 ;
if exist(fullfile(opts.saveDir, sprintf('FT-net-%d.mat', opts.id)), 'file')
        [net, stats, epoch_start] = loadState(fullfile(opts.saveDir, sprintf('FT-net-%d.mat', opts.id))) ;
        fprintf('load cnn net from last time \n');
else
   if exist(fullfile(opts.dataDir, 'start_vgg16_iccv_set_image_scale_12_D.mat'), 'file')
        net = loadState(fullfile(opts.dataDir, 'start_vgg16_iccv_set_image_scale_12_D.mat')) ;
        fprintf('load start net model \n');
   else
       net = myDAGnet(opts.outputN);
       net.meta.imgRbgMean.r = 124.89;
       net.meta.imgRbgMean.g = 107.37;
       net.meta.imgRbgMean.b = 103.04;
       saveState(fullfile(opts.dataDir, 'start_vgg16_iccv_set_image_scale_12_D.mat'), net, [], 0);
   end
end

setLearningRate(net);
rng('shuffle');
opts.imgRbgMean = net.meta.imgRbgMean;

for epoch=epoch_start+1:opts.numEpochs
  trainingsetid = mod(epoch,11);
  if trainingsetid == 0;
      trainingsetid = 11;
  end
  trainingfile = sprintf('nyufinaldb-%d.mat', trainingsetid);
  imdb = load([opts.dataDir '/' trainingfile]) ;
  opts.train = find(imdb.nyudata.set==1) ;
  opts.val = find(imdb.nyudata.set==2) ;
  if isnan(opts.train), opts.train = [] ; end
  evaluateMode = isempty(opts.train) ;
  if ~evaluateMode
    if isempty(opts.derOutputs)
      error('DEROUTPUTS must be specified when training.\n') ;
    end
  end
  % train one epoch
  state.epoch = epoch ;
  state.learningRate = opts.learningRate(min(epoch, numel(opts.learningRate))) ;
  state.train = opts.train(randperm(numel(opts.train))) ; % shuffle
  state.val = opts.val ;
  state.imdb = imdb ;
  
  net.layers(53).block.setClip(opts.clip_d(epoch));

  if numGpus <= 1
    stats.train(epoch) = process_epoch(net, state, opts, 'train') ;
    stats.val(epoch) = process_epoch(net, state, opts, 'val') ;
  else
    savedNet = net.saveobj() ;
    spmd
      net_ = dagnn.DagNN.loadobj(savedNet) ;
      stats_.train = process_epoch(net_, state, opts, 'train') ;
      stats_.val = process_epoch(net_, state, opts, 'val') ;
      if labindex == 1, savedNet_ = net_.saveobj() ; end
    end
    net = dagnn.DagNN.loadobj(savedNet_{1}) ;
    stats__ = accumulateStats(stats_) ;
    stats.train(epoch) = stats__.train ;
    stats.val(epoch) = stats__.val ;
    clear net_ stats_ stats__ savedNet_ ;
  end

  if ~evaluateMode
    saveState(modelPath(epoch), net, stats, epoch) ;
  end

  fid = fopen(trainInfoPath, 'a+');
  fprintf(fid,'%s %d %s \n', '[epoch = ', epoch, ']');
  fprintf(fid,'%s %.4f \n', '   train-objective = ', stats.train(epoch).objective);
  train_accuracy = stats.train(epoch).accuracy;
  fprintf(fid,'%s %.4f \n', '   train-rel_error = ', train_accuracy(1));
  fprintf(fid,'%s %.4f \n', '   train-log_error = ', train_accuracy(2));
  fprintf(fid,'%s %.4f \n', '   train-rm_error = ', train_accuracy(3));
  val_accuracy = stats.val(epoch).accuracy;
  fprintf(fid,'%s %.4f \n', '   val-objective = ', stats.val(epoch).objective);
  fprintf(fid,'%s %.4f \n', '   val-rel_error = ', val_accuracy(1));
  fprintf(fid,'%s %.4f \n', '   val-log_error = ', val_accuracy(2));
  fprintf(fid,'%s %.4f \n\n\n', '   val-rm_error = ', val_accuracy(3));
  fclose(fid);

  if opts.plotStatistics
    figure(1) ; clf ;
    plots = setdiff(...
      cat(2,...
      fieldnames(stats.train)', ...
      fieldnames(stats.val)'), {'num', 'time'}) ;
    for p = plots
      p = char(p) ;
      values = zeros(0, epoch) ;
      leg = {} ;
      for f = {'train', 'val'}
        f = char(f) ;
        if isfield(stats.(f), p)
          tmp = [stats.(f).(p)] ;
          values(end+1,:) = tmp(1,:)' ;
          leg{end+1} = f ;
        end
      end
      subplot(1,numel(plots),find(strcmp(p,plots))) ;
      plot(1:epoch, values','o-') ;
      xlabel('epoch') ;
      title(p) ;
      legend(leg{:}) ;
      grid on ;
    end
    drawnow ;
    print(1, modelFigPath, '-dpdf') ;
  end
end

% -------------------------------------------------------------------------
function stats = process_epoch(net, state, opts, mode)
% -------------------------------------------------------------------------

if strcmp(mode,'train')
  state.momentum = num2cell(zeros(1, numel(net.params))) ;
end

numGpus = numel(opts.gpus) ;
if numGpus >= 1
  net.move('gpu') ;
  if strcmp(mode,'train')
    state.momentum = cellfun(@gpuArray,state.momentum,'UniformOutput',false) ;
  end
end
if numGpus > 1
  mmap = map_gradients(opts.memoryMapFile, net, numGpus) ;
else
  mmap = [] ;
end

stats.time = 0 ;
stats.num = 0 ;
subset = state.(mode) ;
start = tic ;
num = 0 ;

for t=1:opts.batchSize:numel(subset)
  batchSize = min(opts.batchSize, numel(subset) - t + 1) ;

  for s=1:opts.numSubBatches
    % get this image batch and prefetch the next
    batchStart = t + (labindex-1) + (s-1) * numlabs ;
    batchEnd = min(t+opts.batchSize-1, numel(subset)) ;
    batch = subset(batchStart : opts.numSubBatches * numlabs : batchEnd) ;
    num = num + numel(batch) ;
    if numel(batch) == 0, continue ; end
    
    bopts.imgRbgMean = opts.imgRbgMean;
    bopts.useGpu = opts.useGpu;
    inputs = state.getBatch(state.imdb, batch, mode, bopts) ;

    if opts.prefetch
      if s == opts.numSubBatches
        batchStart = t + (labindex-1) + opts.batchSize ;
        batchEnd = min(t+2*opts.batchSize-1, numel(subset)) ;
      else
        batchStart = batchStart + numlabs ;
      end
      nextBatch = subset(batchStart : opts.numSubBatches * numlabs : batchEnd) ;
      bopts.imgRbgMean = opts.imgRbgMean;
      bopts.useGpu = opts.useGpu;
      state.getBatch(state.imdb, nextBatch, mode, bopts) ;
    end

    if strcmp(mode, 'train')
      net.mode = 'normal' ;
      net.accumulateParamDers = (s ~= 1) ;
      net.myeval(inputs, opts.derOutputs, state.epoch, opts.epochpre) ;
    else
      net.mode = 'test' ;
      net.myeval(inputs, [], state.epoch, opts.epochpre) ;
    end
  end

  % extract learning stats
  stats = opts.extractStatsFn(net) ;

  % accumulate gradient
  if strcmp(mode, 'train')
    if ~isempty(mmap)
      write_gradients(mmap, net) ;
      labBarrier() ;
    end
    state = accumulate_gradients(state, net, opts, batchSize, mmap, opts.epochpre) ;
  end

  % print learning statistics
  time = toc(start) ;
  stats.num = num ;
  stats.time = toc(start) ;

  fprintf('%s: epoch %02d: %3d/%3d: %.1f Hz', ...
    mode, ...
    state.epoch, ...
    fix(t/opts.batchSize)+1, ceil(numel(subset)/opts.batchSize), ...
    stats.num/stats.time * max(numGpus, 1)) ;
  fprintf('\n') ;
end

net.layers(54).block.recalerror();
stats = opts.extractStatsFn(net) ;

for f = setdiff(fieldnames(stats)', {'num', 'time'})
    f = char(f) ;
    fprintf(' %s:', f) ;
    fprintf(' %.3f', stats.(f)) ;
end
fprintf('\n') ;

net.reset() ;
net.move('cpu') ;

% -------------------------------------------------------------------------
function state = accumulate_gradients(state, net, opts, batchSize, mmap, epochpre)
% -------------------------------------------------------------------------

startlayer = 1;
if state.epoch < epochpre
    startlayer = 27;
end

for p=startlayer:numel(net.params)

  % bring in gradients from other GPUs if any
  if ~isempty(mmap)
    numGpus = numel(mmap.Data) ;
    tmp = zeros(size(mmap.Data(labindex).(net.params(p).name)), 'single') ;
    for g = setdiff(1:numGpus, labindex)
      tmp = tmp + mmap.Data(g).(net.params(p).name) ;
    end
    net.params(p).der = net.params(p).der + tmp ;
  else
    numGpus = 1 ;
  end

  switch net.params(p).trainMethod

    case 'average' % mainly for batch normalization
      thisLR = net.params(p).learningRate ;
      net.params(p).value = ...
          (1 - thisLR) * net.params(p).value + ...
          (thisLR/batchSize/net.params(p).fanout) * net.params(p).der ;

    case 'gradient'
      thisDecay = opts.weightDecay * net.params(p).weightDecay ;
      thisLR = state.learningRate * net.params(p).learningRate ;
      state.momentum{p} = opts.momentum * state.momentum{p} ...
        - thisDecay * net.params(p).value ...
        - (1 / batchSize) * net.params(p).der ;
      net.params(p).value = net.params(p).value + thisLR * state.momentum{p} ;

    case 'otherwise'
      error('Unknown training method ''%s'' for parameter ''%s''.', ...
        net.params(p).trainMethod, ...
        net.params(p).name) ;
  end
end

% -------------------------------------------------------------------------
function mmap = map_gradients(fname, net, numGpus)
% -------------------------------------------------------------------------
format = {} ;
for i=1:numel(net.params)
  format(end+1,1:3) = {'single', size(net.params(i).value), net.params(i).name} ;
end
format(end+1,1:3) = {'double', [3 1], 'errors'} ;
if ~exist(fname) && (labindex == 1)
  f = fopen(fname,'wb') ;
  for g=1:numGpus
    for i=1:size(format,1)
      fwrite(f,zeros(format{i,2},format{i,1}),format{i,1}) ;
    end
  end
  fclose(f) ;
end
labBarrier() ;
mmap = memmapfile(fname, 'Format', format, 'Repeat', numGpus, 'Writable', true) ;

% -------------------------------------------------------------------------
function write_gradients(mmap, net)
% -------------------------------------------------------------------------
for i=1:numel(net.params)
  mmap.Data(labindex).(net.params(i).name) = gather(net.params(i).der) ;
end

% -------------------------------------------------------------------------
function stats = accumulateStats(stats_)
% -------------------------------------------------------------------------

stats = struct() ;

for s = {'train', 'val'}
  s = char(s) ;
  total = 0 ;

  for g = 1:numel(stats_)
    stats__ = stats_{g} ;
    num__ = stats__.(s).num ;
    total = total + num__ ;

    for f = setdiff(fieldnames(stats__.(s))', 'num')
      f = char(f) ;

      if g == 1
        stats.(s).(f) = 0 ;
      end
      stats.(s).(f) = stats.(s).(f) + stats__.(s).(f) * num__ ;

      if g == numel(stats_)
        stats.(s).(f) = stats.(s).(f) / total ;
      end
    end
  end
  stats.(s).num = total ;
end

% -------------------------------------------------------------------------
function stats = extractStats(net)
% -------------------------------------------------------------------------
sel = find(cellfun(@(x) isa(x,'dagnn.Loss'), {net.layers.block})) ;
stats = struct() ;
for i = 1:numel(sel)
  stats.(net.layers(sel(i)).outputs{1}) = net.layers(sel(i)).block.average ;
end

% -------------------------------------------------------------------------
function saveState(fileName, net, stats, epoch_start)
% -------------------------------------------------------------------------
net_ = net ;
net = net_.saveobj() ;
save(fileName, 'net', 'stats', 'epoch_start') ;

% -------------------------------------------------------------------------
function [net, stats, epoch_start] = loadState(fileName)
% -------------------------------------------------------------------------
load(fileName, 'net', 'stats', 'epoch_start') ;
net = dagnn.DagNN.loadobj(net) ;

