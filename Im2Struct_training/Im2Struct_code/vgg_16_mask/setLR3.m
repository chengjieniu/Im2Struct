function setLR3( net )

%imNet
for ii = 1:26
    net.params(ii).learningRate = 0.0001 ;
    net.params(ii).weightDecay = 0.00005 ;
end

%full layers
for ii = 27:30
    net.params(ii).learningRate = 0.00001 ;
    net.params(ii).weightDecay = 0.00005 ;
end


for ii = 31:36
    net.params(ii).learningRate = 0.0001;
    net.params(ii).weightDecay = 0.00005 ;
end

end

