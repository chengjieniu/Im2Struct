%未完成：0930
%已完成：1008
%计算hausdoff disdance比diagnol box的百分比，其中box使用的是每一个小box
function hausdorff_diagonal_smallbox
%run matlab/vl_setupnn ;

load('D:\eval_vgg_data\vgg_16_mask\vgg16_mask_genShape_boxes.mat')
load('D:\eval_vgg_data\gtShapes_boxes.mat')
    %设置绘制类型
    diagdist_gt_train=distence_diagdist(Gtshapes,1);
    diagdist_gt_test=distence_diagdist(Gtshapes,2);
 
%     diagdist_rec_train=distence_diagdist(genshapes,1);
%     diagdist_rec_test=distence_diagdist(genshapes,2);

    hausddist_gt_rec_train=distence_gt_rec(Gtshapes,genShapes,1);
    hausddist_gt_rec_test=distence_gt_rec(Gtshapes,genShapes,2);
    
    
    [hausddist_rec_gt_train,diagdist_gt_single_train]=distence_rec_gt(Gtshapes,genShapes,1);
    [hausddist_rec_gt_test,diagdist_gt_single_test]=distence_rec_gt(Gtshapes,genShapes,2);
    
    
    ld_rec_gt_train=(hausddist_rec_gt_train)./(diagdist_gt_single_train);
    ld_rec_gt_test=(hausddist_rec_gt_test)./(diagdist_gt_single_test);
    save D:\eval_vgg_data\vgg_16_mask\ld_rec_gt_train  ld_rec_gt_train;
    save D:\eval_vgg_data\vgg_16_mask\ld_rec_gt_test ld_rec_gt_test;
        
    ld_gt_rec_train=(hausddist_gt_rec_train)./(diagdist_gt_train);
    ld_gt_rec_test=(hausddist_gt_rec_test)./(diagdist_gt_test);
    save D:\eval_vgg_data\vgg_16_mask\ld_gt_rec_train  ld_gt_rec_train;
    save D:\eval_vgg_data\vgg_16_mask\ld_gt_rec_test ld_gt_rec_test;

    
end

function [diagdist]=distence_diagdist(Shapes,type)
switch type
    case 1
        %trainging data
        for i=1:1800           
            boxes{i}=Shapes{i}.rec_cornerpoints;
        end
    case 2
        %testing data
        for i=1801:2400
            boxes{i-1800}=Shapes{i}.rec_cornerpoints;
        end
    case 3
        %mix data
        for i=1:2400
           boxes{i}=Shapes{i}.rec_cornerpoints;
        end
end

xmax=0;
ymax=0;
zmax=0;
diagdist=zeros(1,0);
for ii=1:length(boxes)
    currboxes=boxes{ii};
    for jj=1:length(currboxes)
        currbox=currboxes{jj};
        xmax=max(abs(currbox(:,1)));           
        ymax=max(abs(currbox(:,2)));         
        zmax=max(abs(currbox(:,3)));
        diagdist(end+1)=sqrt((2*xmax)^2+(2*ymax)^2+(2*zmax)^2); 
      
    end
%    diagdist(ii)=sqrt((2*xmax)^2+(2*ymax)^2+(2*zmax)^2); 
end
end

function [boxdiag]=distence_diagdist_single(box)

            currbox=box;
            xmax=max(abs(currbox(:,1)));           
            ymax=max(abs(currbox(:,2)));         
            zmax=max(abs(currbox(:,3)));
            boxdiag=sqrt((2*xmax)^2+(2*ymax)^2+(2*zmax)^2); 

end

function [ minbox2boxdis, gt_single_diag]=distence_rec_gt(Gtshapes,genShapes,type)

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
minbox2boxdis=zeros(1,0);
gt_single_diag=zeros(1,0);
for ii=1:length(reboxes)
    currreboxes=reboxes{ii};
    currgtboxes=gtboxes{ii};
    %求H(gtboxes, currgtboxes) hausdorff距离
    %currgtboxes中所有box与另一个recovery boxes中所有box的最小hausdoff距离
    for jj=1:length(currreboxes)
        currrebox=currreboxes{jj};  
        %gtbox中的一个box与另个recovery boxes中所有box的最大距离,
        for xx=1:length(currgtboxes)
            currgtbox=currgtboxes{xx};
            %gtbox中每个点（即一个box）对另一个box的最小距离
            for zz=1:length(currrebox)
                point1=currrebox(zz,:);
                minpoint2boxdis(zz)=point2dist(point1,currgtbox);
            end
            %最大距离即H（currgtbox, currreboxes）
            maxbox2boxdis(xx)=max(minpoint2boxdis);
            clear minpoint2boxdis;
        end
        %找到与currgtbox距离最小的box，即对应的rebox.index为最小gtbox的索引
        [minbox2boxdis(end+1),index]=min(maxbox2boxdis);
        gt_single_diag(end+1)=distence_diagdist_single(currgtboxes{index});
        clear maxbox2boxdis;              
    end  
 %   hausdorffdist(ii)= sum(minbox2boxdis)/length(currreboxes);
 %   clear minbox2boxdis;
end
%re2gtdist=sum(hausdorffdist)/length(hausdorffdist);
end

function [minbox2boxdis]=distence_gt_rec(Gtshapes,genShapes,type)
switch type
    case 1
        %training data
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
        for i=1:length(genShapes)
        gtboxes{i}=Gtshapes{i}.rec_cornerpoints;
        reboxes{i}=genShapes{i}.rec_cornerpoints;
        end 
end    
 minbox2boxdis=zeros(1,0);       
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
        minbox2boxdis(end+1)=min(maxbox2boxdis);
        clear maxbox2boxdis;
    end  
%    hausdorffdist(ii)= sum(minbox2boxdis)/length(currgtboxes);      
 %   clear minbox2boxdis;
end
%gt2redist=sum(hausdorffdist)/length(hausdorffdist);
end

function minpoint2boxdis = point2dist(point1,box2)
%计算一个点到一个box所有点之间的最小距离
    for i=1:length(box2)
        dist(i)=sqrt(sum(power(point1-box2(i,:),2)));
    end
    minpoint2boxdis=min(dist); 
    
end

function genShapes=generate_genShapes(imdb, net, vae_theta)

    imagename=imdb.images.data;
    %folderlist = dir(imagename);
    imagenum=length(imagename);
    feature=cell(1,imagenum);
    res=cell(1,imagenum);
    for i=1:imagenum
        imagenamei=imagename(:,:,:,i);
    %    figure(i);
    %    imshow(im);

    %     im_ = single(im) ; % note: 255 range
    %     im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
    %     im_ = im_ - net.meta.normalization.averageImage ;
    %    imshow(uint8(im_));
        %imshow(filtered_img(net.meta.normalization.averageImage));
        % Run the CNN.
        [res{i},~,~,~,~] = vl_simplenn(net, imagenamei ,[],[], vae_theta,[]) ;
        feature{i}=squeeze(res{i}(21).x);
    end

    %
    %decoder the shapecode
    %

    WdecoS1Left = vae_theta.WdecoS1Left; WdecoS1Right = vae_theta.WdecoS1Right; WdecoS2 = vae_theta.WdecoS2;
    WsymdecoS1 = vae_theta.WsymdecoS1; WsymdecoS2 = vae_theta.WsymdecoS2;
    WdecoBox = vae_theta.WdecoBox;
    bdecoS1Left = vae_theta.bdecoS1Left; bdecoS1Right = vae_theta.bdecoS1Right; bdecoS2 = vae_theta.bdecoS2;
    bsymdecoS1 = vae_theta.bsymdecoS1; bsymdecoS2 = vae_theta.bsymdecoS2;
    bdecoBox = vae_theta.bdecoBox;
    Wcat1 = vae_theta.Wcat1; bcat1 = vae_theta.bcat1;
    Wcat2 = vae_theta.Wcat2; bcat2 = vae_theta.bcat2;


    f = @norm1tanh;
    f_prime = @norm1tanh_prime;


    %num = 1;
    genShapes = cell(1,1);
    for ii = 1:imagenum
        %generate the shapes
        count = 1;
        features = feature{ii};

        symlist = 10*ones(8,1);
        while (size(features,2))
            p = double(features(:,1));
            sfm = f(Wcat1*p+bcat1);
            sm = softmax(Wcat2*sfm + bcat2);
            [~,l_index] = max(sm);
            if(l_index == 1)
                re_box = f(WdecoBox*p+bdecoBox);
                genShapes{ii}.boxes(:,count) = re_box;
                count = count+1;
                symfeature = symlist(:,1);
                if (abs(symfeature(1)+1) < 0.15 )
                    folds = uint8(1/symfeature(8));
                    newbox = re_box;
                    symfeature(2:4) = symfeature(2:4)/norm(symfeature(2:4));
                    for kk = 1:folds-1
                        rotvector = [symfeature(2:4); symfeature(8)*2*pi*single(kk)];
                        rotm = vrrotvec2mat(rotvector);
                        center = re_box(1:3);
                        dir_1 = re_box(7:9);
                        dir_2 = re_box(10:12);
                        newcenter = rotm*(center-symfeature(5:7))+symfeature(5:7);
                        newbox(1:3) = newcenter;
                        newbox(7:9) = rotm*dir_1;
                        newbox(10:12) = rotm*dir_2;
                        genShapes{ii}.boxes(:,count) = newbox;
                        count = count+1;
                    end
                end
                if (abs(symfeature(1)) < 0.15 )
                    trans = symfeature(2:4);
                    trans_end = symfeature(5:7);
                    center = re_box(1:3);
                    trans_length = sqrt(sum(trans.^2));
                    trans_total = sqrt(sum(trans_end-center).^2);
                    folds = trans_total/trans_length;
                    for kk = 1:folds 
                        newbox = re_box;                   
                        newcenter = center+trans*single(kk);
                        newbox(1:3) = newcenter;
                        genShapes{ii}.boxes(:,count) = newbox;
                        count = count+1;
                    end
                end
                if (abs(symfeature(1)-1) < 0.15 )
                    ref_normal = symfeature(2:4);
                    ref_normal = ref_normal/norm(ref_normal);
                    ref_point = symfeature(5:7); 
                    newbox = re_box;
                    center = re_box(1:3);
                    if (dot(ref_normal, ref_point-center) < 0)
                        ref_normal = -ref_normal;
                    end

                    newcenter = abs(sum((ref_point-center).*ref_normal))*ref_normal*2+center;
                    newbox(1:3) = newcenter;
                    dir_1 = re_box(7:9);
                    if (dot(ref_normal, dir_1) > 0)
                        ref_normal = -ref_normal;
                    end
                    newbox(7:9) = dir_1 - 2*dot(dir_1, ref_normal)*ref_normal;
                    dir_2 = re_box(10:12);
                    if (dot(ref_normal, dir_2) > 0)
                        ref_normal = -ref_normal;
                    end                
                    newbox(10:12) = dir_2 - 2*dot(dir_2, ref_normal)*ref_normal;

                    genShapes{ii}.boxes(:,count) = newbox;
                    count = count+1;

                end
                symlist(:,1) = [];
                features(:,1) = [];
            else
                if (l_index == 3)
                    ym = f(WsymdecoS2*p + bsymdecoS2);
                    yp = f(WsymdecoS1*ym + bsymdecoS1);               
                    y1 = yp(1:end-8);
                    features(:,1) = [];
                    features = [features y1];
                    symfeature = yp(end-7:end);
                    symlist(:,1) = [];
                    symlist = [symlist symfeature];               
                else
                    if(l_index == 2)
                        ym = f(WdecoS2*p + bdecoS2);
                        y1 = f(WdecoS1Left*ym + bdecoS1Left);
                        y2 = f(WdecoS1Right*ym + bdecoS1Right);
                        features(:,1) = [];
                        features = [features y1 y2];
                        symlist = [symlist symlist(:,1) symlist(:,1)];
                        symlist(:,1) = [];
                    end
                end

            end
        end

    end
    clear net;
    clear vae_theta;
end

function Gtshapes = recoverGtshapes(imdb)
    for ii =1:length(imdb.images.labels)        
        recover_boxes = imdb.images.labels(ii).boxes;    
   %     figure(ii+100); 
        for jj = 1:size(recover_boxes,2)
            p = recover_boxes(:,jj);
            Gtshapes{ii}.rec_cornerpoints{jj}=recover3dOBB_v2(p);
        end           
    end    
end

function genShapes=recoverGenshapes(genShapes)
    for ii =1:length(genShapes)
        
        recover_boxes = genShapes{ii}.boxes;    
   %     figure(ii+100);
 
        for jj = 1:size(recover_boxes,2)
            p = recover_boxes(:,jj);
            genShapes{ii}.rec_cornerpoints{jj}=recover3dOBB_v2(p);
        end           
    end    
end

%将hierarchy 恢复为 boundingboxes
function cornerpoints = recover3dOBB_v2(p)

    center = p(1:3);
    lengths = p(4:6);
    dir_1 = p(7:9);
    dir_2 = p(10:12);

    dir_1 = dir_1/norm(dir_1);
    dir_2 = dir_2/norm(dir_2);
    dir_3 = cross(dir_1,dir_2);
    dir_3 = dir_3/norm(dir_3); 
    cornerpoints = zeros(8,3);

    d1 = 0.5*lengths(1)*dir_1;
    d2 = 0.5*lengths(2)*dir_2;
    d3 = 0.5*lengths(3)*dir_3;
    cornerpoints(1,:) = center-d1-d2-d3;
    cornerpoints(2,:) = center-d1+d2-d3;
    cornerpoints(3,:) = center+d1-d2-d3;
    cornerpoints(4,:) = center+d1+d2-d3;
    cornerpoints(5,:) = center-d1-d2+d3;
    cornerpoints(6,:) = center-d1+d2+d3;
    cornerpoints(7,:) = center+d1-d2+d3;
    cornerpoints(8,:) = center+d1+d2+d3;
    
%     col='r';
%     plot3([cornerpoints(1,1),cornerpoints(2,1)],[cornerpoints(1,2),cornerpoints(2,2)],[cornerpoints(1,3),cornerpoints(2,3)],col);hold on;
% plot3([cornerpoints(1,1),cornerpoints(3,1)],[cornerpoints(1,2),cornerpoints(3,2)],[cornerpoints(1,3),cornerpoints(3,3)],col);hold on;
% plot3([cornerpoints(2,1),cornerpoints(4,1)],[cornerpoints(2,2),cornerpoints(4,2)],[cornerpoints(2,3),cornerpoints(4,3)],col);hold on;
% plot3([cornerpoints(3,1),cornerpoints(4,1)],[cornerpoints(3,2),cornerpoints(4,2)],[cornerpoints(3,3),cornerpoints(4,3)],col);hold on;
% plot3([cornerpoints(5,1),cornerpoints(6,1)],[cornerpoints(5,2),cornerpoints(6,2)],[cornerpoints(5,3),cornerpoints(6,3)],col);hold on;
% plot3([cornerpoints(5,1),cornerpoints(7,1)],[cornerpoints(5,2),cornerpoints(7,2)],[cornerpoints(5,3),cornerpoints(7,3)],col);hold on;
% plot3([cornerpoints(6,1),cornerpoints(8,1)],[cornerpoints(6,2),cornerpoints(8,2)],[cornerpoints(6,3),cornerpoints(8,3)],col);hold on;
% plot3([cornerpoints(7,1),cornerpoints(8,1)],[cornerpoints(7,2),cornerpoints(8,2)],[cornerpoints(7,3),cornerpoints(8,3)],col);hold on;
% plot3([cornerpoints(1,1),cornerpoints(5,1)],[cornerpoints(1,2),cornerpoints(5,2)],[cornerpoints(1,3),cornerpoints(5,3)],col);hold on;
% plot3([cornerpoints(2,1),cornerpoints(6,1)],[cornerpoints(2,2),cornerpoints(6,2)],[cornerpoints(2,3),cornerpoints(6,3)],col);hold on;
% plot3([cornerpoints(3,1),cornerpoints(7,1)],[cornerpoints(3,2),cornerpoints(7,2)],[cornerpoints(3,3),cornerpoints(7,3)],col);hold on;
% plot3([cornerpoints(4,1),cornerpoints(8,1)],[cornerpoints(4,2),cornerpoints(8,2)],[cornerpoints(4,3),cornerpoints(8,3)],col);hold on;

end
