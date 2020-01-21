function distence_rec_gt
%recovery boxes��ground truth֮���hausdoff distance�γɵĲ��

load ('D:\eval_vgg_data\gtShapes_boxes.mat');
%load ('G:\Image2boxJointtrain\image2box\genShape_boxes.mat');
load('D:\eval_vgg_data\vgg_16_mask\vgg16_mask_genShape_boxes.mat');


%trainging data
% for i=1:1800
%     gtboxes{i}=Gtshapes{i}.rec_cornerpoints;
%     reboxes{i}=genShapes{i}.rec_cornerpoints;
% end

%testing data
for i=1801:2400
    gtboxes{i-1800}=Gtshapes{i}.rec_cornerpoints;
    reboxes{i-1800}=genShapes{i}.rec_cornerpoints;
end

% for i=1:2400
%     gtboxes{i}=Gtshapes{i}.rec_cornerpoints;
%     reboxes{i}=genShapes{i}.rec_cornerpoints;
% end


for ii=1:length(reboxes)
    currreboxes=reboxes{ii};
    currgtboxes=gtboxes{ii};
    %��H(gtboxes, currgtboxes) hausdorff����
    %currgtboxes������box����һ��recovery boxes������box����Сhausdoff����
    for jj=1:length(currreboxes)
        currrebox=currreboxes{jj};  
        %gtbox�е�һ��box�����recovery boxes������box��������,
        for xx=1:length(currgtboxes)
            currgtbox=currgtboxes{xx};
            %gtbox��ÿ���㣨��һ��box������һ��box����С����
            for zz=1:length(currrebox)
                point1=currrebox(zz,:);
                minpoint2boxdis(zz)=point2dist(point1,currgtbox);
            end
            %�����뼴H��currgtbox, currreboxes��
            maxbox2boxdis(xx)=max(minpoint2boxdis);
            clear minpoint2boxdis;
        end
        %�ҵ���currgtbox������С��box������Ӧ��rebox.
        minbox2boxdis(jj)=min(maxbox2boxdis);
        clear maxbox2boxdis;
    end  
    hausdorffdist(ii)= sum(minbox2boxdis)/length(currreboxes);
    clear minbox2boxdis;
end

%training data
%re2gtdist=sum(hausdorffdist)/(length(reboxes)*3/4);
%testing data
%re2gtdist=sum(hausdorffdist)/(length(reboxes)*1/4);
%save hausdorffdist hausdorffdist
re2gtdist=sum(hausdorffdist)/length(hausdorffdist);
%save image2box\re2gtdist re2gtdist

end
function minpoint2boxdis = point2dist(point1,box2)
%����һ���㵽һ��box���е�֮�����С����
    for i=1:length(box2)
        dist(i)=sqrt(sum(power(point1-box2(i,:),2)));
    end
    minpoint2boxdis=min(dist); 
    
end