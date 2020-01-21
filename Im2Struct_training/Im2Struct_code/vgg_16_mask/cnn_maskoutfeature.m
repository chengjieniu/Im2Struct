function  maskfeature = cnn_maskoutfeature()
load('H:\vgg_16_mask\matconvnet-1.0-beta24\vgg_16_mask\data\masknet_100.mat');
load('H:\backgroundadd\frontdata\imdb.mat');

net=dagnn.DagNN.loadobj(net);
net.removeLayer('error');
net.removeLayer('loss');
net.removeLayer('scale2Conv10');
net.mode = 'test' ;

%im=zeros(224,224,3,2400);
im = imdb.images.data(:,:,:,1:2400);
im_ = single(im) ; % note: 0-255 range
im_ = imresize(im_, [224 224]) ;
%因为imdb本身已经剪过均值了
%im_ = bsxfun(@minus, im_, net.meta.normalization.averageImage) ;
im_ = gpuArray(im_);
for i=1:2400
    net.eval({'input', im_(:,:,:,i), 'input2',  im_(:,:,:,i)}) ;
    maskfeature(:,:,:,i) = single(gather(net.vars(net.getVarIndex('x63')).value)) ;
end

save H:\vgg_16_mask\matconvnet-1.0-beta24\vgg_16_mask\data\maskfeature.mat maskfeature;

end