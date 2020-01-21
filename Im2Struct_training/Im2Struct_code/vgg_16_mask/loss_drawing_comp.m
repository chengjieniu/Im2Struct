% function loss_drawing_comp
%  net1=load('D:\exp_vgg16_mask\net-epoch-200.mat') ;
%  net2=load('D:\exp_vgg16_only\net-epoch-200.mat');
% % net1=load('D:\exp_vgg19_mask\net-epoch-300.mat') ;
% % net2=load('D:\exp_vgg19_only\net-epoch-300.mat');
% stats_new1=net1.stats;
% stats_new2=net2.stats;
% loss=zeros(4,200);
% for ii=1:200
% loss(3,ii)=stats_new1.train(ii).reconLoss;
% loss(1,ii)=stats_new2.train(ii).reconLoss;
% loss(4,ii)=stats_new1.val(ii).reconLoss;
% loss(2,ii)=stats_new2.val(ii).reconLoss;
% end
% for i=1:4
% loss(i,:)=sort(loss(i,:),'descend');
% end
for j=1:4
y(j,:)=interp1(1:1:200,sort(loss(j,:),'descend'),1:0.2:200,'spline');
end

plot( 1:0.2:200, y,'-') ;
axis([0 200 0 0.6]); 
xlabel('epoch') ;
set(0,'defaultfigurecolor','w');
legend({'Train reconstruction loss (w/o mask)','Test reconstruction loss (w/o mask)', 'Train reconstruction loss (w mask)','Test reconstruction loss (w mask)'}) ;
box off;
%end

