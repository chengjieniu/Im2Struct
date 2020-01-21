function net = Netfromvgg_scale1()

%vggnet = load('../../data/imagenet-vgg-verydeep-16.mat') ;
vggnet=load('data/imagenet-vgg-verydeep-16.mat');
net.layers = vggnet.layers(1:31);
end

