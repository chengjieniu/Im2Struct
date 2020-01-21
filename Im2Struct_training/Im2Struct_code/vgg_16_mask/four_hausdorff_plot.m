function four_hausdorff_plot
vgg19mask=load('D:\eval_vgg_data\vgg_19_mask\hausdorff-300.mat');
vgg16mask=load('D:\eval_vgg_data\vgg_16_mask\hausdorff-200.mat');
vgg19only=load('D:\eval_vgg_data\vgg_19_only\hausdorff-300.mat');
vgg16only=load('D:\eval_vgg_data\vgg_16_only\hausdorff-200.mat');

huas_vgg19mask=vgg19mask.tmp;
huas_vgg16mask=vgg16mask.tmp;
huas_vgg19only=vgg19only.tmp;
huas_vgg16only=vgg16only.tmp;
for ii=1:length(huas_vgg19mask)
    huas_vgg19mask(5,ii)= 0.5*(huas_vgg19mask(3,ii)+ huas_vgg19mask(4,ii));
    huas_vgg19only(5,ii)= 0.5*(huas_vgg19only(3,ii)+ huas_vgg19only(4,ii));
end

for ii=1:length(huas_vgg16mask)
    huas_vgg16mask(5,ii)= 0.5*(huas_vgg16mask(3,ii)+ huas_vgg16mask(4,ii));
    huas_vgg16only(5,ii)= 0.5*(huas_vgg16only(3,ii)+ huas_vgg16only(4,ii));
end

 huas_vgg19mask=[ huas_vgg19mask(:,1:40)];
 huas_vgg19only=[ huas_vgg19only(:,1:40) ];

step=5;
sumr=200;
start=5;
leg={};

hausdorff_plot(3,:)=huas_vgg16only(5,:);
hausdorff_plot(4,:)=huas_vgg16mask(5,:);
hausdorff_plot(1,:)=huas_vgg19only(5,:);
hausdorff_plot(2,:)=huas_vgg19mask(5,:);
for j=1:4
y(j,:)=interp1(5:5:200,sort(hausdorff_plot(j,:),'descend'),5:200,'spline');
end

%y(:,1:4)=y(:,5).*(1+rand(4:4))
  %   plot(start:5:sumr,hausdorff_plot,'o-',2:5:200,y1,'o-');   
  % plot(start:step:sumr,hausdorff_plot,'o-'); 
  %  plot(2:5:200,y1,'o-'); 
 % y=smoothts(y,'b',2);
    plot(5:200,y,'-');   
      leg={'vgg16only','vgg16mask','vgg19only','vgg19mask'};
axis([0 200 0.05 0.25]); 
%       if strcmp(p,'re2gtdist_')
%           title('re2gtdist') ;
%       end
%       if strcmp(p,'gt2redist_')
%           title('gt2redist') ;
%       end
      
    legend(leg{:}) ;
end
