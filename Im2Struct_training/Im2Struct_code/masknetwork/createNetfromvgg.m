function net = createNetfromvgg()

%vggnet = load('../../data/imagenet-vgg-verydeep-16.mat') ;
vggnet=load('data/imagenet-vgg-verydeep-16.mat');
net.layers = vggnet.layers(1:33);

net.layers{end-1}.filters = 1.0/100*randn(7,7,512,4096, 'single');
net.layers{end-1}.biases = zeros(1,4096,'single');

net.layers{end+1} = struct('type', 'dropout', ...
                             'name', sprintf('dropout%s', '6'), ...
                             'rate', 0.5) ;
net.layers{end+1} = vggnet.layers{34};

% net.layers{end+1} = struct('type', 'conv', ...
%                              'name', sprintf('fc%s', '7'), ...
%                              'size', [1,1,4096,9408], 'pad', [0 0 0 0], ...
%                              'stride', [1,1]);
% net.addLayer('fc7', ...
%      dagnn.Conv('size', [1,1,4096,9408], 'pad', [0 0 0 0]), ...
%      'x34', 'x35', {'fc7f','fc7b'});

net.layers{end}.biases = zeros(1,9408,'single');
net.layers{end}.filters = 0.01*randn(1,1,4096,9408,'single');
net.layers{end}.weights{1}=0.01*randn(1,1,4096,9408,'single');
net.layers{end}.weights{2}=randn(9408,1,'single');
end

