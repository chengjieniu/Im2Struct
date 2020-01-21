function [net,info]=cnn_masknet_train(varargin)
%clear;
clc;
%run matlab/vl_setupnn ;
gpuDevice(1);
opts.imdbpath='H:\maskgrass_1030\matconvnet-1.0-beta24\masknetwork\data_modify\imdb.mat';
%opts.expDir='F:\exp1015';
%前100次结果 学习率为0.0001
%opts.expDir='G:\exp_masknet';
%100次之后的结果 
opts.expDir='D:\exp_masknet_vmodify';
%opts.train = struct() ;
opts.train = 'gpus';
opts.gpus = [] ;
opts.useGpu = true;
[opts, varargin] = vl_argparse(opts, varargin) ;
%if ~isfield(opts.train, 'gpus'), opts.train.gpus = []; end;

imdb=load(opts.imdbpath);
imdb=imdb.imdb;
%set imdb on GPU
imdb.images.data=gpuArray(imdb.images.data);
imdb.images.labels=gpuArray(imdb.images.labels);

load('masknetwork\data\net.mat');
setLearningRate(net);

net.meta.normalization.averageImage=imdb.images.data_mean;
net.meta.trainOpts.numEpochs = 300 ;
net.meta.trainOpts.batchSize = 5 ;
fbatch = @(i,b) getBatch(opts.train,i,b);



  [net,info]=cnn_train_dag_masknet(net,imdb,fbatch,...
    'expDir',opts.expDir,....
     net.meta.trainOpts, ...
    'val',find(imdb.images.set==3));
end

% function fn=getBatch(opts)
%     fn=@(x,y)getSimpleNNBatch(x,y);
% end

% function [images,labels]=getSimpleNNBatch(imdb,batch)
%     images=imdb.images.data(:,:,:,batch);
%     labels=imdb.images.labels(batch);
% end    

% --------------------------------------------------------------------
function inputs = getBatch(opts, imdb, batch)
% --------------------------------------------------------------------
% 
if ~isa(imdb.images.data, 'gpuArray') && numel(opts.gpus) > 0
  imdb.images.data = gpuArray(imdb.images.data);
  imdb.images.labels = gpuArray(imdb.images.labels);
end
images = imdb.images.data(:,:,:,batch) ;
labels = imdb.images.labels(:,:,:,batch) ;
inputs = {'input', images, 'input2', images, 'label', labels} ;
end
