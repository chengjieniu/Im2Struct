function distence_gt_rec
%groud truth 与 recovery boxes之间的hausdoff distance形成的差距
%共用一个数据
load ('D:\eval_vgg_data\gtShapes_boxes.mat');
%load ('G:\Image2boxJointtrain\image2box\genShape_boxes.mat');
load('D:\eval_vgg_data\vgg_16_mask\vgg16_mask_genShape_boxes.mat');
%training data
% for i=1:1800
%     gtboxes{i}=Gtshapes{i}.rec_cornerpoints;
%     reboxes{i}=genShapes{i}.rec_cornerpoints;
% end
%testing data
for i=(1800+1):length(genShapes)
    gtboxes{i-1800}=Gtshapes{i}.rec_cornerpoints;
    reboxes{i-1800}=genShapes{i}.rec_cornerpoints;
end

% for i=1801:length(genShapes)
%     gtboxes{i-1800}=Gtshapes{i}.rec_cornerpoints;
%     reboxes{i-1800}=genShapes{i}.rec_cornerpoints;
% end

for ii=1:length(gtboxes)
    currgtboxes=gtboxes{ii};
    currreboxes=reboxes{ii};
    %求H(gtboxes, currgtboxes) hausdorff距离
    %currgtboxes中所有box与另一个recovery boxes中所有box的最小hausdoff距离
    for jj=1:length(currgtboxes)
        currgtbox=currgtboxes{jj};  
        %gtbox中的一个box与另个recovery boxes中所有box的最大距离,
        for xx=1:length(currreboxes)
            currrebox=currreboxes{xx};
            %gtbox中每个点（即一个box）对另一个box的最小距离
            for zz=1:length(currgtbox)
                point1=currgtbox(zz,:);
                minpoint2boxdis(zz)=point2dist(point1,currrebox);
            end
            %最大距离即H（currgtbox, currreboxes）
            maxbox2boxdis(xx)=max(minpoint2boxdis);
            clear minpoint2boxdis;
        end
        %找到与currgtbox距离最小的box，即对应的rebox.
        minbox2boxdis(jj)=min(maxbox2boxdis);
        clear maxbox2boxdis;
    end  
    hausdorffdist(ii)= sum(minbox2boxdis)/length(currgtboxes);      
    clear minbox2boxdis;
end
%training data
gt2redist=sum(hausdorffdist)/length(hausdorffdist);
%testing data
%gt2redist=sum(hausdorffdist)/(length(gtboxes)*1/4);
%gt2redist=sum(hausdorffdist)/length(gtboxes);
%save image2box\gt2redist gt2redist
%save H:\maskgrass_1030\matconvnet-1.0-beta24\im2str\data\gt2redist gt2redist

end

function minpoint2boxdis = point2dist(point1,box2)
%计算一个点到一个box所有点之间的最小距离
    for i=1:length(box2)
        dist(i)=sqrt(sum(power(point1-box2(i,:),2)));
    end
    minpoint2boxdis=min(dist); 
    
end