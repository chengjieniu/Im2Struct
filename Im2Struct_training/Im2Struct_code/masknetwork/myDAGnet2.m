function net = myDAGnet2

net = createNetfromvgg();
net = vl_simplenn_tidy(net) ;
net = dagnn.DagNN.fromSimpleNN(net, 'canonicalNames', true) ;

reshapeBlock = myReshape();
net.addLayer('myreshape', reshapeBlock, 'x35', 'x36');

% add first conv layer to connect with pool_4
net.addLayer('skip_4', ...
     dagnn.Conv('size', [1 1 512 64], 'pad', [0 0 0 0]), ...
     'x24', 'x37', {'skip_4_f','skip_4_b'});

f = net.getParamIndex('skip_4_f') ;
net.params(f).value = 0.01*randn(1, 1, 512, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('skip_4_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

skip4_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_skip_4', skip4_reluBlock, 'x37', 'x38', {}) ;

skip4_concatBlock = dagnn.Concat();
net.addLayer('concat_skip_4', skip4_concatBlock, {'x38', 'x36'}, 'x39', {}) ;

net.addLayer('joinConv_4_1', ...
     dagnn.Conv('size', [3 3 128 64], 'pad', [1 1 1 1]), ...
     'x39', 'x40', {'joinConv_4_1_f','joinConv_4_1_b'});

f = net.getParamIndex('joinConv_4_1_f') ;
net.params(f).value = 0.01*randn(3, 3, 128, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('joinConv_4_1_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

joinConv_4_1_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_joinConv_4_1', joinConv_4_1_reluBlock, 'x40', 'x41', {}) ;

net.addLayer('joinConv_4_2', ...
     dagnn.Conv('size', [3 3 64 64], 'pad', [1 1 1 1]), ...
     'x41', 'x42', {'joinConv_4_2_f','joinConv_4_2_b'});

f = net.getParamIndex('joinConv_4_2_f') ;
net.params(f).value = 0.01*randn(3, 3, 64, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('joinConv_4_2_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

joinConv_4_2_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_joinConv_4_2', joinConv_4_2_reluBlock, 'x42', 'x43', {}) ;

net.addLayer('joinConv_4_3', ...
     dagnn.Conv('size', [3 3 64 64], 'pad', [1 1 1 1]), ...
     'x43', 'x44', {'joinConv_4_3_f','joinConv_4_3_b'});

f = net.getParamIndex('joinConv_4_3_f') ;
net.params(f).value = 0.01*randn(3, 3, 64, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('joinConv_4_3_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

joinConv_4_3_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_joinConv_4_3', joinConv_4_3_reluBlock, 'x44', 'x45', {}) ;

filters = single(bilinear_u(4, 1, 64)) ;
net.addLayer('deconv4', ...
  dagnn.ConvTranspose(...
  'size', size(filters), ...
  'upsample', 2, ...
  'crop', [1 1 1 0], ...
  'hasBias', false), ...
  'x45', 'x46', 'deconv4f') ;

f = net.getParamIndex('deconv4f') ;
net.params(f).value = filters ;
net.params(f).learningRate = 0 ;
net.params(f).weightDecay = 1 ;

% add first conv layer to connect with pool_3
net.addLayer('skip_3', ...
     dagnn.Conv('size', [1 1 256 64], 'pad', [0 0 0 0]), ...
     'x17', 'x47', {'skip_3_f','skip_3_b'});

f = net.getParamIndex('skip_3_f') ;
net.params(f).value = 0.01*randn(1, 1, 256, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('skip_3_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

skip3_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_skip_3', skip3_reluBlock, 'x47', 'x48', {}) ;

skip3_concatBlock = dagnn.Concat();
net.addLayer('concat_skip_3', skip3_concatBlock, {'x48', 'x46'}, 'x49', {}) ;

net.addLayer('joinConv_3_1', ...
     dagnn.Conv('size', [3 3 128 64], 'pad', [1 1 1 1]), ...
     'x49', 'x50', {'joinConv_3_1_f','joinConv_3_1_b'});

f = net.getParamIndex('joinConv_3_1_f') ;
net.params(f).value = 0.01*randn(3, 3, 128, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('joinConv_3_1_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

joinConv_3_1_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_joinConv_3_1', joinConv_3_1_reluBlock, 'x50', 'x51', {}) ;

net.addLayer('joinConv_3_2', ...
     dagnn.Conv('size', [3 3 64 64], 'pad', [1 1 1 1]), ...
     'x51', 'x52', {'joinConv_3_2_f','joinConv_3_2_b'});

f = net.getParamIndex('joinConv_3_2_f') ;
net.params(f).value = 0.01*randn(3, 3, 64, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('joinConv_3_2_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

joinConv_3_2_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_joinConv_3_2', joinConv_3_2_reluBlock, 'x52', 'x53', {}) ;

net.addLayer('joinConv_3_3', ...
     dagnn.Conv('size', [3 3 64 64], 'pad', [1 1 1 1]), ...
     'x53', 'x54', {'joinConv_3_3_f','joinConv_3_3_b'});

f = net.getParamIndex('joinConv_3_3_f') ;
net.params(f).value = 0.01*randn(3, 3, 64, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('joinConv_3_3_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

joinConv_3_3_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_joinConv_3_3', joinConv_3_3_reluBlock, 'x54', 'x55', {}) ;

net.addLayer('joinConv_3_4', ...
     dagnn.Conv('size', [3 3 64 64], 'pad', [1 1 1 1]), ...
     'x55', 'x56', {'joinConv_3_4_f','joinConv_3_4_b'});

f = net.getParamIndex('joinConv_3_4_f') ;
net.params(f).value = 0.01*randn(3, 3, 64, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('joinConv_3_4_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

joinConv_3_4_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_joinConv_3_4', joinConv_3_4_reluBlock, 'x56', 'x57', {}) ;

net.addLayer('joinConv_3_5', ...
     dagnn.Conv('size', [3 3 64 64], 'pad', [1 1 1 1]), ...
     'x57', 'x58', {'joinConv_3_5_f','joinConv_3_5_b'});

f = net.getParamIndex('joinConv_3_5_f') ;
net.params(f).value = 0.01*randn(3, 3, 64, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('joinConv_3_5_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

joinConv_3_5_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_joinConv_3_5', joinConv_3_5_reluBlock, 'x58', 'x59', {}) ;

filters = single(bilinear_u(4, 1, 64)) ;
net.addLayer('deconv3', ...
  dagnn.ConvTranspose(...
  'size', size(filters), ...
  'upsample', 2, ...
  'crop', [1 0 1 1], ...
  'hasBias', false), ...
  'x59', 'x60', 'deconv3f') ;

f = net.getParamIndex('deconv3f') ;
net.params(f).value = filters ;
net.params(f).learningRate = 0 ;
net.params(f).weightDecay = 1 ;


% add first conv layer to connect with pool_2
net.addLayer('skip_2', ...
     dagnn.Conv('size', [1 1 128 64], 'pad', [0 0 0 0]), ...
     'x10', 'x61', {'skip_2_f','skip_2_b'});

f = net.getParamIndex('skip_2_f') ;
net.params(f).value = 0.01*randn(1, 1, 128, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('skip_2_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

skip2_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_skip_2', skip2_reluBlock, 'x61', 'x62', {}) ;

skip2_concatBlock = dagnn.Concat();
net.addLayer('concat_skip_2', skip2_concatBlock, {'x62', 'x60'}, 'x63', {}) ;

net.addLayer('joinConv_2_1', ...
     dagnn.Conv('size', [3 3 128 64], 'pad', [1 1 1 1]), ...
     'x63', 'x64', {'joinConv_2_1_f','joinConv_2_1_b'});

f = net.getParamIndex('joinConv_2_1_f') ;
net.params(f).value = 0.01*randn(3, 3, 128, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('joinConv_2_1_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

joinConv_2_1_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_joinConv_2_1', joinConv_2_1_reluBlock, 'x64', 'x65', {}) ;

net.addLayer('joinConv_2_2', ...
     dagnn.Conv('size', [3 3 64 64], 'pad', [1 1 1 1]), ...
     'x65', 'x66', {'joinConv_2_2_f','joinConv_2_2_b'});

f = net.getParamIndex('joinConv_2_2_f') ;
net.params(f).value = 0.01*randn(3, 3, 64, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('joinConv_2_2_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

joinConv_2_2_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_joinConv_2_2', joinConv_2_2_reluBlock, 'x66', 'x67', {}) ;

net.addLayer('joinConv_2_3', ...
     dagnn.Conv('size', [3 3 64 64], 'pad', [1 1 1 1]), ...
     'x67', 'x68', {'joinConv_2_3_f','joinConv_2_3_b'});

f = net.getParamIndex('joinConv_2_3_f') ;
net.params(f).value = 0.01*randn(3, 3, 64, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('joinConv_2_3_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

joinConv_2_3_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_joinConv_2_3', joinConv_2_3_reluBlock, 'x68', 'x69', {}) ;


net.addLayer('joinConv_2_4', ...
     dagnn.Conv('size', [3 3 64 64], 'pad', [1 1 1 1]), ...
     'x69', 'x70', {'joinConv_2_4_f','joinConv_2_4_b'});

f = net.getParamIndex('joinConv_2_4_f') ;
net.params(f).value = 0.01*randn(3, 3, 64, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('joinConv_2_4_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

joinConv_2_4_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_joinConv_2_4', joinConv_2_4_reluBlock, 'x70', 'x71', {}) ;

net.addLayer('joinConv_2_5', ...
     dagnn.Conv('size', [3 3 64 64], 'pad', [1 1 1 1]), ...
     'x71', 'x72', {'joinConv_2_5_f','joinConv_2_5_b'});

f = net.getParamIndex('joinConv_2_5_f') ;
net.params(f).value = 0.01*randn(3, 3, 64, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('joinConv_2_5_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

joinConv_2_5_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_joinConv_2_5', joinConv_2_5_reluBlock, 'x72', 'x73', {}) ;

net.addLayer('joinConv_2_6', ...
     dagnn.Conv('size', [3 3 64 64], 'pad', [1 1 1 1]), ...
     'x73', 'x74', {'joinConv_2_6_f','joinConv_2_6_b'});

f = net.getParamIndex('joinConv_2_6_f') ;
net.params(f).value = 0.01*randn(3, 3, 64, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('joinConv_2_6_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

joinConv_2_6_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_joinConv_2_6', joinConv_2_6_reluBlock, 'x74', 'x75', {}) ;

net.addLayer('joinConv_2_7', ...
     dagnn.Conv('size', [3 3 64 64], 'pad', [1 1 1 1]), ...
     'x75', 'x76', {'joinConv_2_7_f','joinConv_2_7_b'});

f = net.getParamIndex('joinConv_2_7_f') ;
net.params(f).value = 0.01*randn(3, 3, 64, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('joinConv_2_7_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

joinConv_2_7_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_joinConv_2_7', joinConv_2_7_reluBlock, 'x76', 'x77', {}) ;

net.addLayer('joinConv_2_8', ...
     dagnn.Conv('size', [3 3 64 64], 'pad', [1 1 1 1]), ...
     'x77', 'x78', {'joinConv_2_8_f','joinConv_2_8_b'});

f = net.getParamIndex('joinConv_2_8_f') ;
net.params(f).value = 0.01*randn(3, 3, 64, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('joinConv_2_8_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

joinConv_2_8_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_joinConv_2_8', joinConv_2_8_reluBlock, 'x78', 'x79', {}) ;

net.addLayer('joinConv_2_9', ...
     dagnn.Conv('size', [3 3 64 64], 'pad', [1 1 1 1]), ...
     'x79', 'x80', {'joinConv_2_9_f','joinConv_2_9_b'});

f = net.getParamIndex('joinConv_2_9_f') ;
net.params(f).value = 0.01*randn(3, 3, 64, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('joinConv_2_9_b') ;
net.params(f).value = zeros(1, 1, 64, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

joinConv_2_9_reluBlock = dagnn.ReLU() ;
net.addLayer('relu_joinConv_2_9', joinConv_2_9_reluBlock, 'x80', 'x81', {}) ;

net.addLayer('joinConv_2_10', ...
     dagnn.Conv('size', [3 3 64 1], 'pad', [1 1 1 1]), ...
     'x81', 'prediction', {'joinConv_2_10_f','joinConv_2_10_b'});

f = net.getParamIndex('joinConv_2_10_f') ;
net.params(f).value = 0.01*randn(3, 3, 64, 1, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('joinConv_2_10_b') ;
net.params(f).value = zeros(1, 1, 1, 'single') ;
net.params(f).learningRate = 1 ;
net.params(f).weightDecay = 1 ;



% joinConv_2_10_reluBlock = dagnn.ReLU() ;
% net.addLayer('relu_joinConv_2_10', joinConv_2_10_reluBlock, 'x83', 'prediction', {}) ;

% filters = single(bilinear_u(8, 1, 1)) ;
% net.addLayer('deconv2', ...
%   dagnn.ConvTranspose(...
%   'size', size(filters), ...
%   'upsample', 4, ...
%   'crop', [1 1 2 1], ...
%   'hasBias', false), ...
%   'x83', 'prediction', 'deconv2f') ;
% 
% f = net.getParamIndex('deconv2f') ;
% net.params(f).value = filters ;
% net.params(f).learningRate = 0 ;
% net.params(f).weightDecay = 1 ;

net.vars(net.getVarIndex('prediction')).precious = 1 ;
% Add loss layer
net.addLayer('objective', ...
  myLoss(), ...
  {'prediction', 'label'}, 'objective') ;

% Add accuracy layer
net.addLayer('accuracy', ...
  myAccuracy(), ...
  {'prediction', 'label'}, 'accuracy') ;

end

