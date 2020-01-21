function loss_drawing
load('D:\exp_vgg16_mask\net-epoch-200.mat') 
stats_new=stats;
loss=zeros(6,200);
for ii=1:200
loss(1,ii)=stats.train(ii).reconLoss;
loss(3,ii)=stats.train(ii).symLoss;
loss(5,ii)=stats.train(ii).catLoss;
loss(2,ii)=stats.val(ii).reconLoss;
loss(4,ii)=stats.val(ii).symLoss;
loss(6,ii)=stats.val(ii).catLoss;
end
for j=1:6
y(j,:)=interp1(1:1:200,sort(loss(j,:),'descend'),1:0.2:200,'spline');
end

plot( 1:0.2:200, y,'-') ;
axis([0 200 0 0.6]); 
xlabel('epoch') ;
set(0,'defaultfigurecolor','w');
legend({'Train reconstruciton loss','Test reconstruciton loss', 'Train symmetry loss','Test symmetry loss',  'Train classification loss','Test classification loss'}) ;
box off;
end

