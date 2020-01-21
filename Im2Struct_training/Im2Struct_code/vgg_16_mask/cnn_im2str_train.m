function [net,info]=cnn_im2str_train(varargin)

% clc;
%run matlab/vl_setupnn ;
gpuDevice();
%opts.imdbpath='H:\vgg_16_mask\matconvnet-1.0-beta24\vgg_16_mask\data\im2strimdb.mat';
%opts.imdbpath='H:\0retry_cv\data\vgg_16_mask\im2strimdb.mat';
opts.imdbpath='H:\vgg_16_mask\matconvnet-1.0-beta24\vgg_16_mask\data\airplane\im2strimdb.mat';
%opts.expDir='D:\exp_vgg16_mask';
%opts.expDir='H:\vgg_16_mask\matconvnet-1.0-beta24\vgg_16_mask\exp_vgg16_mask';
%opts.expDir='H:\0retry_cv\data\vgg_16_mask\epoch_1.5';
opts.expDir='vgg_16_mask';
opts.train = 'gpus';
opts.gpus = [] ;
opts.useGpu = true;
[opts, varargin] = vl_argparse(opts, varargin) ;
%if ~isfield(opts.train, 'gpus'), opts.train.gpus = []; end;

imdb=load(opts.imdbpath);
imdb=imdb.imdb;
%set imdb on GPU
% imdb.images.data=gpuArray(imdb.images.data);
% imdb.images.maskfeature=gpuArray(imdb.images.maskfeature);
%imdb.images.labels=gpuArray(imdb.images.labels);

%load('H:\vgg_16_mask\matconvnet-1.0-beta24\vgg_16_mask\data\im2strnet.mat');
%load('H:\0retry_cv\data\vgg_16_mask\im2strnet.mat');
load('H:\vgg_16_mask\matconvnet-1.0-beta24\vgg_16_mask\data\airplane\im2strnet.mat')
setLR1(net);

size_params.hiddenSize = 200;
size_params.latentSize = 80;
size_params.boxSize = 12;
size_params.catSize = 3;
size_params.symSize = 8;
vae_theta = im2str_initializeVaeParameters(size_params);
net.meta.vae_theta=vae_theta;

%已经减去均值了 所以此处不需要均值
%net.meta.normalization.averageImage=imdb.images.data_mean;
net.meta.trainOpts.numEpochs = 500 ;
net.meta.trainOpts.batchSize = 20;

fbatch = @(i,b) getBatch(opts.train,i,b);



  [net,info]=cnn_train_dag_im2strnet(net,imdb,fbatch,...
    'expDir',opts.expDir,....
     net.meta.trainOpts, ...
    'val',find(imdb.images.set==3));

end

% --------------------------------------------------------------------
function inputs = getBatch(opts, imdb, batch)
% --------------------------------------------------------------------
% 
% if ~isa(imdb.images.data, 'gpuArray') && numel(opts.gpus) > 0
%   imdb.images.data = imdb.images.data;
%   imdb.images.labels = imdb.images.labels;
% end
images =gpuArray( imdb.images.data(:,:,:,batch)) ;
maskfeature = gpuArray( imdb.images.maskfeature(:,:,:,batch) );
labels = imdb.images.labels(batch) ;
inputs = {'input', images, 'input2', maskfeature, 'label', labels} ;
%inputs={'input', images, 'label', labels} ;
end