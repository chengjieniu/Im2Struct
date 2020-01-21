datapath = 'H:\0retry_cv\training_data_models';
%datapath='G:\03001627_chair\03001627\03001627';
width=512;
%width=1024;
height=width;
folderlist = dir(datapath);

% shapenetdata = struct( 'images', zeros(256,256,3,4500,'uint8'), ...
%                    'depths', zeros(256,256,1,4500,'uint16'),...
%                    'set', zeros(1,4500,'uint8'));

%imagesavepath = 'G:\ncj_chair_selected0709\render_old';
%imagesavepath = 'G:\plane_table_obj_obb_test0928\render';
%imagesavepath='G:\backgroundadd\frontpicture';
imagesavepath='H:\0retry_cv\renderImage_model';
mkdir(imagesavepath);

%testdata = struct( 'images', zeros(256,256,3,6000,'uint8'), ...
%                   'depths', zeros(256,256,1,6000,'single'));
save H:\0retry_cv\folderlist folderlist;
count = 1;
for ii =1:402
    disp(ii);
    if strcmp('.',folderlist(ii,1).name) || strcmp('..',folderlist(ii,1).name)
        continue;
    end
    
  %  objectname = fullfile(datapath, folderlist(ii,1).name, 'model_seg.obj')
  %  objectname = fullfile(datapath,'a4da5746b99209f85da16758ae613576','model.obj')
    objectname = fullfile(datapath,folderlist(ii,1).name,'model.obj');
    rendereddata{ii-2}.modelname=folderlist(ii,1).name;
%     for jj = 1:6
%         imagename = num2str(count, '%04d');
%         [depth, rendered, unproject, A, R, T]=renderer(width,height, objectname,0,0,-0.3,15,-30*(jj-1),1,'zxy');
%         rendered = imresize(rendered, [256 256]);
%         depth = imresize(depth, [256 256], 'nearest');
%         testdata.images(:,:,:,count) = rendered;
%         testdata.depths(:,:,:,count) = depth;
%         count = count+1;
%     end
%     
%     for jj = 1:6
%         imagename = num2str(count, '%04d');
%         [depth, rendered, unproject, A, R, T]=renderer(width,height, objectname,0,0,-0.3,30,-30*(jj-1),1,'zxy');
%         rendered = imresize(rendered, [256 256]);
%         depth = imresize(depth, [256 256], 'nearest');
%         testdata.images(:,:,:,count) = rendered;
%         testdata.depths(:,:,:,count) = depth;
%         count = count+1;
%     end
%     
%     for jj = 1:6
%         imagename = num2str(count, '%04d');
%         [depth, rendered, unproject, A, R, T]=renderer(width,height, objectname,0,0,-0.3,45,-30*(jj-1),1,'zxy');
%         rendered = imresize(rendered, [256 256]);
%         depth = imresize(depth, [256 256], 'nearest');
%         testdata.images(:,:,:,count) = rendered;
%         testdata.depths(:,:,:,count) = depth;
%         count = count+1;
%     end
    
    for kk = 1:2
        for jj = 1:3
            imagename = num2str(count, '%04d');
%             w1 = rand*60;
%             w2 = -rand*90-(kk-1)*90;
             w1=20;
             w2 = -rand*90-(kk-1)*90;
            %renderer(宽，高，名称，1，光照为1，比例，角度，角度，1，‘zxy’);
            [depth, rendered, unproject, A, R, T]=renderer(width,height, objectname,1,0,-0.3,w1,w2,0,'zxy');
            rendered = imresize(rendered, [256 256]);
            depth = imresize(depth, [256 256], 'nearest');
%             rendered = imresize(rendered, [1024 1024]);
%             depth = imresize(depth, [1024 1024], 'nearest');
%             testdata.images(:,:,:,count) = rendered;
%             testdata.depths(:,:,:,count) = depth;
 %           imwrite(rendered, [imagesavepath '\' imagename '_' num2str((kk-1)*6+jj) '.jpg']);
            imwrite(rendered,[imagesavepath '\' folderlist(ii,1).name '_' num2str((kk-1)*3+jj) '.jpg']);
            rendereddata{ii-2}.images{(kk-1)*3+jj}=rendered;

            count = count+1;
            

        end
    end

%    count = count+1;
    
%     [depth, rendered, unproject, A, R, T]=renderer(width,height, objectname,0,0,-0.3,30,150,0,'zxy');
%     % Displays the results.
%     rendered = imresize(rendered, [256 256]);
%     depth = imresize(depth, [256 256], 'nearest');
%     %figure, imshow(depth); 
%     figure, imshow(rendered);
%     imwrite(rendered, 'test.jpg');
%     figure, imshow(depth);
    
end

save('H:\0retry_cv\data\rendereddata.mat', '-v7.3', 'rendereddata');

% save('shapenetData-18.mat', '-v7.3','shapenetdata');

