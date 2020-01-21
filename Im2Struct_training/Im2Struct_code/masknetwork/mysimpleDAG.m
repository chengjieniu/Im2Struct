function net = mysimpleDAG()

% net = initializeDepthCNN();

load('../data/old_net.mat');
% vggnet=load('data/imagenet-vgg-verydeep-16.mat');
% net.layers = vggnet.layers(1:33);

net = vl_simplenn_tidy(net) ;
net = dagnn.DagNN.fromSimpleNN(net, 'canonicalNames', true) ;

reshapeBlock = myReshape();
net.addLayer('myreshape', reshapeBlock, 'x35', 'prediction');

net.vars(net.getVarIndex('prediction')).precious = 1 ;

net.addLayer('objective', ...
  myLoss(), ...
  {'prediction', 'label'}, 'objective') ;

% Add accuracy layer
net.addLayer('accuracy', ...
  myAccuracy(), ...
  {'prediction', 'label'}, 'accuracy') ;

end

