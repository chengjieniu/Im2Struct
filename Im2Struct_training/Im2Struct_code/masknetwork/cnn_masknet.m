function net = cnn_masknet

net = createNetfromvgg();
net = vl_simplenn_tidy(net);
net = vl_simplenn_move(net,'gpu');
net = dagnn.DagNN.fromSimpleNN(net, 'canonicalNames', true) ;

% net.layers(1).block.pad = [0 0 0 0];
% net.layers(3).block.pad = [0 0 0 0];
% net.layers(5).block.poolSize = [3 3];

reshapeBlock = myReshape();
net.addLayer('myreshape', reshapeBlock, 'x35', 'x36');

% add first conv layer to connect with pool_4
net.addLayer('skip_4', ...
     dagnn.Conv('size', [5 5 512 64], 'pad', [2 2 2 2]), ...
     'x24', 'x37', {'skip_4_f','skip_4_b'});

f = net.getParamIndex('skip_4_f') ;
net.params(f).value = 0.01*randn(5, 5, 512, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('skip_4_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 2 ;
net.params(f).weightDecay = 1 ;

skip4_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_skip_4', skip4_reluBlock, 'x37', 'x38', {}) ;

filters = single(bilinear_u(8, 1, 64)) ;
net.addLayer('deconv4', ...
  dagnn.ConvTranspose(...
  'size', size(filters), ...
  'upsample', 4, ...
  'crop', [1 3 1 3], ...
  'hasBias', false), ...
  'x38', 'x39', 'deconv4f') ;

f = net.getParamIndex('deconv4f') ;
net.params(f).value = filters ;
net.params(f).learningRate = 0 ;
net.params(f).weightDecay = 1 ;

% add first conv layer to connect with pool_3
net.addLayer('skip_3', ...
     dagnn.Conv('size', [5 5 256 64], 'pad', [2 2 2 2]), ...
     'x17', 'x40', {'skip_3_f','skip_3_b'});

f = net.getParamIndex('skip_3_f') ;
net.params(f).value = 0.01*randn(5, 5, 256, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('skip_3_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

skip3_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_skip_3', skip3_reluBlock, 'x40', 'x41', {}) ;

filters = single(bilinear_u(5, 1, 64)) ;
net.addLayer('deconv3', ...
  dagnn.ConvTranspose(...
  'size', size(filters), ...
  'upsample', 2, ...
  'crop', [1 2 1 2], ...
  'hasBias', false), ...
  'x41', 'x42', 'deconv3f') ;

f = net.getParamIndex('deconv3f') ;
net.params(f).value = filters ;
net.params(f).learningRate = 0 ;
net.params(f).weightDecay = 1 ;


% scale 2 net work
net.addLayer('scale2Conv1', ...
     dagnn.Conv('size', [2 2 3 96], 'pad', [0 0 0 0], 'stride', [2 2]), ...
     'input2', 'x43', {'scale2Conv1_f','scale2Conv1_b'});

f = net.getParamIndex('scale2Conv1_f') ;
net.params(f).value = 0.01*randn(2, 2, 3, 96, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('scale2Conv1_b') ;
net.params(f).value = zeros(1, 1, 96, 'single') ;
net.params(f).learningRate = 2 ;
net.params(f).weightDecay = 1 ;

scale2Conv1_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_scale2Conv1', scale2Conv1_reluBlock, 'x43', 'x44', {}) ;

net.addLayer('pool1_scale2', dagnn.Pooling('poolSize', [2 2], 'stride', [2 2]), 'x44', 'xfix', {}) ;

scale2Conv1_concatBlock = dagnn.Concat();
net.addLayer('concat_scale2Conv1', scale2Conv1_concatBlock, {'xfix', 'x42'}, 'x45', {}) ;

net.addLayer('scale2Conv2', ...
     dagnn.Conv('size', [5 5 160 64], 'pad', [2 2 2 2]), ...
     'x45', 'x46', {'scale2Conv2_f','scale2Conv2_b'});

f = net.getParamIndex('scale2Conv2_f') ;
net.params(f).value = 0.01*randn(5, 5, 160, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('scale2Conv2_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 2 ;
net.params(f).weightDecay = 1 ;

scale2Conv2_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_scale2Conv2', scale2Conv2_reluBlock, 'x46', 'x47', {}) ;

net.addLayer('scale2Conv3', ...
     dagnn.Conv('size', [5 5 64 64], 'pad', [2 2 2 2]), ...
     'x47', 'x48', {'scale2Conv3_f','scale2Conv3_b'});

f = net.getParamIndex('scale2Conv3_f') ;
net.params(f).value = 0.01*randn(5, 5, 64, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('scale2Conv3_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 2 ;
net.params(f).weightDecay = 1 ;

scale2Conv3_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_scale2Conv3', scale2Conv3_reluBlock, 'x48', 'x49', {}) ;

scale2Conv3_concatBlock = dagnn.Concat();
net.addLayer('concat_scale2Conv3', scale2Conv3_concatBlock, {'x49', 'x39'}, 'x50', {}) ;

net.addLayer('scale2Conv4', ...
     dagnn.Conv('size', [5 5 128 64], 'pad', [2 2 2 2]), ...
     'x50', 'x51', {'scale2Conv4_f','scale2Conv4_b'});

f = net.getParamIndex('scale2Conv4_f') ;
net.params(f).value = 0.01*randn(5, 5, 128, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('scale2Conv4_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 2 ;
net.params(f).weightDecay = 1 ;

scale2Conv4_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_scale2Conv4', scale2Conv4_reluBlock, 'x51', 'x52', {}) ;

net.addLayer('scale2Conv5', ...
     dagnn.Conv('size', [5 5 64 64], 'pad', [2 2 2 2]), ...
     'x52', 'x53', {'scale2Conv5_f','scale2Conv5_b'});

f = net.getParamIndex('scale2Conv5_f') ;
net.params(f).value = 0.01*randn(5, 5, 64, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('scale2Conv5_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 2 ;
net.params(f).weightDecay = 1 ;

scale2Conv5_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_scale2Conv5', scale2Conv5_reluBlock, 'x53', 'x54', {}) ;

scale2Conv5_concatBlock = dagnn.Concat();
net.addLayer('concat_scale2Conv5', scale2Conv5_concatBlock, {'x54', 'x36'}, 'x55', {}) ;

net.addLayer('scale2Conv6', ...
     dagnn.Conv('size', [5 5 67 64], 'pad', [2 2 2 2]), ...
     'x55', 'x56', {'scale2Conv6_f','scale2Conv6_b'});

f = net.getParamIndex('scale2Conv6_f') ;
net.params(f).value = 0.01*randn(5, 5, 67, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('scale2Conv6_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 2 ;
net.params(f).weightDecay = 1 ;

scale2Conv6_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_scale2Conv6', scale2Conv6_reluBlock, 'x56', 'x57', {}) ;

net.addLayer('scale2Conv7', ...
     dagnn.Conv('size', [5 5 64 64], 'pad', [2 2 2 2]), ...
     'x57', 'x58', {'scale2Conv7_f','scale2Conv7_b'});

f = net.getParamIndex('scale2Conv7_f') ;
net.params(f).value = 0.01*randn(5, 5, 64, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('scale2Conv7_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 2 ;
net.params(f).weightDecay = 1 ;

scale2Conv7_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_scale2Conv7', scale2Conv7_reluBlock, 'x58', 'x59', {}) ;

net.addLayer('scale2Conv8', ...
     dagnn.Conv('size', [5 5 64 64], 'pad', [2 2 2 2]), ...
     'x59', 'x60', {'scale2Conv8_f','scale2Conv8_b'});

f = net.getParamIndex('scale2Conv8_f') ;
net.params(f).value = 0.01*randn(5, 5, 64, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('scale2Conv8_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 2 ;
net.params(f).weightDecay = 1 ;

scale2Conv8_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_scale2Conv8', scale2Conv8_reluBlock, 'x60', 'x61', {}) ;

net.addLayer('scale2Conv9', ...
     dagnn.Conv('size', [5 5 64 64], 'pad', [2 2 2 2]), ...
     'x61', 'x62', {'scale2Conv9_f','scale2Conv9_b'});

f = net.getParamIndex('scale2Conv9_f') ;
net.params(f).value = 0.01*randn(5, 5, 64, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('scale2Conv9_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 2 ;
net.params(f).weightDecay = 1 ;

scale2Conv9_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_scale2Conv9', scale2Conv9_reluBlock, 'x62', 'x63', {}) ;

net.addLayer('scale2Conv10', ...
     dagnn.Conv('size', [5 5 64 2], 'pad', [2 2 2 2]), ...
     'x63', 'prediction', {'scale2Conv10_f','scale2Conv10_b'});

f = net.getParamIndex('scale2Conv10_f') ;
net.params(f).value = 0.01*randn(5, 5, 64, 2, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('scale2Conv10_b') ;
net.params(f).value = zeros(1, 1, 2, 'single') ;
net.params(f).learningRate = 2 ;
net.params(f).weightDecay = 1 ;

net.vars(net.getVarIndex('prediction')).precious = 1 ;
% Add loss layer
% net.addLayer('objective', ...
%   Loss(), ...
%   {'prediction', 'label'}, 'objective') ;

% % Add accuracy layer
% net.addLayer('accuracy', ...
%   myAccuracy(), ...
%   {'prediction', 'label'}, 'accuracy') ;
%  net.addLayer('error', dagnn.Loss('loss', 'classerror'), {'pred','label'}, 'error');

  % softmax loss:
  net.addLayer('loss', dagnn.Loss('loss', 'softmaxlog'), {'prediction','label'}, 'objective');
  net.addLayer('error', dagnn.Loss('loss', 'classerror'), {'prediction','label'}, 'error');

  %setLearningRate(net);
  
save H:\matconvnet-1.0-beta24_20171016\matconvnet-1.0-beta24\masknetwork\data\net net
end

