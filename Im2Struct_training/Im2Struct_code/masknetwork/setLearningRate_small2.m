function setLearningRate_small( net )

%imNet
for ii = 1:26
    net.params(ii).learningRate = 0.00001 ;
    net.params(ii).weightDecay = 0.00001 ;
end

%full layers
for ii = 27:30
    net.params(ii).learningRate = 0.00001 ;
    net.params(ii).weightDecay = 0.00001 ;
end

%skip_4_f skip_4_b
net.params(31).learningRate = 0.00001  ;
net.params(31).weightDecay = 0.00001 ;
net.params(32).learningRate = 0.00001  ;
net.params(32).weightDecay = 0.00001 ;

%skip_3_f skip_3_b
net.params(34).learningRate = 0.00001  ;
net.params(34).weightDecay = 0.00001 ;
net.params(35).learningRate =0.00001  ;
net.params(35).weightDecay = 0.00001 ;

%scale Conv1
net.params(37).learningRate =0.00001  ;
net.params(37).weightDecay = 0.00001 ;
net.params(38).learningRate = 0.00001  ;
net.params(38).weightDecay = 0.00001 ;

%scale Conv2
net.params(39).learningRate = 0.00001  ;
net.params(39).weightDecay = 0.00001 ;
net.params(40).learningRate = 0.00001 ;
net.params(40).weightDecay = 0.00001 ;

%scale Conv3
net.params(41).learningRate = 0.00001 ;
net.params(41).weightDecay = 0.00001 ;
net.params(42).learningRate = 0.00001  ;
net.params(42).weightDecay = 0.00001 ;

%scale Conv4
net.params(43).learningRate = 0.00001  ;
net.params(43).weightDecay = 0.00001 ;
net.params(44).learningRate = 0.00001  ;
net.params(44).weightDecay = 0.00001 ;

%scale Conv5
net.params(45).learningRate = 0.00001  ;
net.params(45).weightDecay = 0.00001 ;
net.params(46).learningRate = 0.00001  ;
net.params(46).weightDecay = 0.00001 ;

%scale Conv6
net.params(47).learningRate = 0.00001  ;
net.params(47).weightDecay = 0.00001 ;
net.params(48).learningRate = 0.00001  ;
net.params(48).weightDecay = 0.00001 ;

%scale Conv7
net.params(49).learningRate = 0.00001  ;
net.params(49).weightDecay = 0.00001 ;
net.params(50).learningRate = 0.00001 ;
net.params(50).weightDecay = 0.00001 ;

%scale Conv8
net.params(51).learningRate = 0.00001  ;
net.params(51).weightDecay = 0.00001 ;
net.params(52).learningRate = 0.00001  ;
net.params(52).weightDecay = 0.00001 ;

%scale Conv9
net.params(53).learningRate = 0.00001  ;
net.params(53).weightDecay = 0.00001 ;
net.params(54).learningRate = 0.00001  ;
net.params(54).weightDecay = 0.00001 ;

%scale Conv10
net.params(55).learningRate = 0.00001  ;
net.params(55).weightDecay = 0.00001 ;
net.params(56).learningRate = 0.00001  ;
net.params(56).weightDecay = 0.00001 ;

end

