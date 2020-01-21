function setLR1( net )

%imNet
for ii = 1:26
    net.params(ii).learningRate = 0.001 ;
    net.params(ii).weightDecay = 0.0005 ;
end

%full layers
for ii = 27:30
    net.params(ii).learningRate = 0.0001 ;
    net.params(ii).weightDecay = 0.0005 ;
end


for ii = 31:36
    net.params(ii).learningRate = 0.001;
    net.params(ii).weightDecay = 0.0005 ;
end

end

