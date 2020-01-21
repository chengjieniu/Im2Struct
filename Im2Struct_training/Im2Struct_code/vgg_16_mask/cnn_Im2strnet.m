function net = cnn_Im2strnet()

%获取vgg的pool5层之前的
net = Netfromvgg_scale1();
net = vl_simplenn_tidy(net);
net = vl_simplenn_move(net,'gpu');
net = dagnn.DagNN.fromSimpleNN(net, 'canonicalNames', true) ;

% % scale 5 net work
net.addLayer('scale5Conv1', ...
     dagnn.Conv('size', [2 2 64 64], 'pad', [0 0 0 0], 'stride', [2 2]), ...
     'input2', 'x32', {'scale5Conv1_f','scale5Conv1_b'});

f = net.getParamIndex('scale5Conv1_f') ;
net.params(f).value = 0.01*randn(2, 2, 64, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('scale5Conv1_b') ;
net.params(f).value = zeros(1, 1,64, 'single') ;
net.params(f).learningRate = 2 ;
net.params(f).weightDecay = 1 ;

scale5Conv1_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_scale5Conv1', scale5Conv1_reluBlock, 'x32', 'x33', {}) ;

net.addLayer('pool1_scale5', dagnn.Pooling('poolSize', [2 2], 'stride', [2 2]), 'x33', 'x34', {}) ;

net.addLayer('scale5Conv2', ...
     dagnn.Conv('size', [3 3 64 64], 'pad', [1 1 1 1]), ...
     'x34', 'x35', {'scale5Conv2_f','scale5Conv2_b'});

f = net.getParamIndex('scale5Conv2_f') ;
net.params(f).value = 0.01*randn(3, 3, 64, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('scale5Conv2_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

scale5Conv2_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_scale5Conv2', scale5Conv2_reluBlock, 'x35', 'x36', {}) ;

net.addLayer('pool2_scale5', dagnn.Pooling('poolSize', [2 2], 'stride', [2 2]), 'x36', 'x37', {}) ;

scale5Conv1_concatBlock = dagnn.Concat();
net.addLayer('concat_scale5Conv1', scale5Conv1_concatBlock, {'x31', 'x37'}, 'x38', {}) ;


net.addLayer('scale5fc3', ...
     dagnn.Conv('size', [7 7 576 4096], 'pad', [0 0 0 0]), ...
     'x38', 'x39', {'scale5fc3_f','scale5fc3_b'});

f = net.getParamIndex('scale5fc3_f') ;
net.params(f).value = 0.01*randn(7, 7, 576, 4096, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('scale5fc3_b') ;
net.params(f).value = zeros(1, 1, 4096, 'single') ;
net.params(f).learningRate = 2 ;
net.params(f).weightDecay = 1 ;

scale5Conv3_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_scale5fc3', scale5Conv3_reluBlock, 'x39', 'x40', {}) ;

net.addLayer('scale5fc4', ...
     dagnn.Conv('size', [1  1 4096 4096], 'pad', [0 0 0 0]), ...
     'x40', 'x41', {'scale5fc4_f','scale5fc4_b'});

f = net.getParamIndex('scale5fc4_f') ;
net.params(f).value = 0.01*randn(1, 1, 4096, 4096, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('scale5fc4_b') ;
net.params(f).value = zeros(1, 1, 4096, 'single') ;
net.params(f).learningRate = 2 ;
net.params(f).weightDecay = 1 ;

scale5Conv3_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_scale5fc4', scale5Conv3_reluBlock, 'x41', 'x42', {}) ;

net.addLayer('scale5fc5', ...
     dagnn.Conv('size', [1  1 4096 80], 'pad', [0 0 0 0]), ...
     'x42', 'prediction', {'scale5fc5_f','scale5fc5_b'});

f = net.getParamIndex('scale5fc5_f') ;
net.params(f).value = 0.01*randn(1, 1, 4096, 80, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('scale5fc5_b') ;
net.params(f).value = zeros(1, 1, 80, 'single') ;
net.params(f).learningRate = 2 ;
net.params(f).weightDecay = 1 ;


net.vars(net.getVarIndex('prediction')).precious = 1 ;

net.addLayer('loss', dagnn.Loss('loss', 'vaedecoder'), {'prediction','label'}, 'objective');
  % softmax loss:
%   net.addLayer('loss', dagnn.Loss('loss', 'softmaxlog'), {'prediction','label'}, 'objective');
% net.addLayer('error', dagnn.Loss('loss', 'classerror'), {'prediction','label'}, 'error');

  %setLearningRate(net);
  
%save H:\maskgrass_1030\matconvnet-1.0-beta24\im2str\data\im2strnet net;
save vgg_16_mask\data\im2strnet net;
end

