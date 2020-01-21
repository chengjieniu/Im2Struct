function diagonal_distance
%groud truth 与 recovery boxes之间的对角线形成的差距
type=1;
load ('D:\eval_vgg_data\gtShapes_boxes.mat');
%load ('G:\Image2boxJointtrain\image2box\genShape_boxes.mat');
load('D:\eval_vgg_data\vgg_16_mask\vgg16_mask_genShape_boxes.mat');
switch type
    case 1
        %trainging data
        for i=1:1800
            gtboxes{i}=Gtshapes{i}.rec_cornerpoints;
            reboxes{i}=genShapes{i}.rec_cornerpoints;
        end
    case 2
        %testing data
        for i=1801:2400
            gtboxes{i-1800}=Gtshapes{i}.rec_cornerpoints;
            reboxes{i-1800}=genShapes{i}.rec_cornerpoints;
        end
    case 3
        %mix data
        for i=1:2400
            gtboxes{i}=Gtshapes{i}.rec_cornerpoints;
            reboxes{i}=genShapes{i}.rec_cornerpoints;
        end
end
xmax=0;
ymax=0;
zmax=0;
for ii=1:length(gtboxes)
    currgtboxes=gtboxes{ii};
    currreboxes=reboxes{ii};
    %求H(gtboxes, currgtboxes) hausdorff距离
    %currgtboxes中所有box与另一个recovery boxes中所有box的最小hausdoff距离
    for jj=1:length(currgtboxes)
        currgtbox=currgtboxes{jj};  
        for n=1:3
            if n==3
                currgtbox=sortrows(currgtbox,[n,1]);
            else
                currgtbox=sortrows(currgtbox,[n n+1]);
            end;
            temp=currgtbox(3,:);
            currgtbox(3,:)=currgtbox(4,:);
            currgtbox(4,:)=temp;
            h=patch(currgtbox(1:4,1),currgtbox(1:4,2),currgtbox(1:4,3),'r');
            xlabel('x');
        ylabel('y');
        zlabel('z');

           set(h,'FaceAlpha',1);
            temp=currgtbox(7,:);
            currgtbox(7,:)=currgtbox(8,:);
            currgtbox(8,:)=temp;
            %h=patch(x(5:8,1),x(5:8,2),x(5:8,3),c, 'EdgeColor','none');
            h=patch(currgtbox(5:8,1),currgtbox(5:8,2),currgtbox(5:8,3),'r');
            set(h,'FaceAlpha',1);
        end;
        if xmax<max(abs(currgtbox(:,1)))
             xmax=max(abs(currgtbox(:,1)));
        end
        if ymax<max(abs(currgtbox(:,2)))
             ymax=max(abs(currgtbox(:,2)));
        end
        if zmax<max(abs(currgtbox(:,3)))
             zmax=max(abs(currgtbox(:,3)));
        end
    end
    l=sqrt((2*xmax)^2+(2*ymax)^2+(2*zmax)^2);
end
%training data
gt2redist=sum(hausdorffdist)/length(hausdorffdist);
%testing data
%gt2redist=sum(hausdorffdist)/(length(gtboxes)*1/4);
%gt2redist=sum(hausdorffdist)/length(gtboxes);
%save image2box\gt2redist gt2redist
%save F:\test\gt2redist gt2redist

end

function minpoint2boxdis = point2dist(point1,box2)
%计算一个点到一个box所有点之间的最小距离
    for i=1:length(box2)
        dist(i)=sqrt(sum(power(point1-box2(i,:),2)));
    end
    minpoint2boxdis=min(dist); 
    
end