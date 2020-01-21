function net = myDAGnet3

net = createNetfromvgg();
net = vl_simplenn_tidy(net) ;
net = dagnn.DagNN.fromSimpleNN(net, 'canonicalNames', true) ;

reshapeBlock = myReshape();
net.addLayer('myreshape', reshapeBlock, 'x35', 'prediction');

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

