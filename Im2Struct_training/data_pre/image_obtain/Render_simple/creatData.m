%datapath = 'G:\Download\chair_data\training';
datapath='H:\0retry_cv\chair_300';
width=1024;
height=width;
folderlist = dir(datapath);

shapenetdata = struct( 'images', zeros(256,256,3,4500,'uint8'), ...
                   'depths', zeros(256,256,1,4500,'uint16'),...
                   'set', zeros(1,4500,'uint8'));

count = 1;
for ii = 3:270
    disp(ii);
    if strcmp('.',folderlist(ii,1).name) || strcmp('..',folderlist(ii,1).name)
        continue;
    end
    
    objectname = fullfile(datapath, folderlist(ii,1).name, 'model.obj');
    for jj = 1:6
        [depth, rendered, unproject, A, R, T]=renderer(width,height, objectname,0,0,-0.3,15,-30*(jj-1),1,'zxy');
        rendered = imresize(rendered, [256 256]);
        depth = uint16(depth*10000);
        depth = imresize(depth, [256 256], 'nearest');
        shapenetdata.images(:,:,:,count) = rendered;
        shapenetdata.depths(:,:,:,count) = uint16(depth);
        shapenetdata.set(:,count) = 1;
        count = count+1;
    end
    
    for jj = 1:6
        [depth, rendered, unproject, A, R, T]=renderer(width,height, objectname,0,0,-0.3,30,-30*(jj-1),0,'zxy');
        rendered = imresize(rendered, [256 256]);
        depth = uint16(depth*10000);
        depth = imresize(depth, [256 256], 'nearest');
        shapenetdata.images(:,:,:,count) = rendered;
        shapenetdata.depths(:,:,:,count) = uint16(depth);
        shapenetdata.set(:,count) = 1;
        count = count+1;
    end
    
    for jj = 1:6
        [depth, rendered, unproject, A, R, T]=renderer(width,height, objectname,0,0,-0.3,45,-30*(jj-1),0,'zxy');
        rendered = imresize(rendered, [256 256]);
        depth = uint16(depth*10000);
        depth = imresize(depth, [256 256], 'nearest');
        shapenetdata.images(:,:,:,count) = rendered;
        shapenetdata.depths(:,:,:,count) = uint16(depth);
        shapenetdata.set(:,count) = 1;
        count = count+1;
    end
    
    for kk = 1:2
        for jj = 1:6
            w1 = rand*60;
            w2 = -rand*90-(kk-1)*90;
            [depth, rendered, unproject, A, R, T]=renderer(width,height, objectname,0,0,-0.3,w1,w2,0,'zxy');
            rendered = imresize(rendered, [256 256]);
            depth = uint16(depth*10000);
            depth = imresize(depth, [256 256], 'nearest');
            shapenetdata.images(:,:,:,count) = rendered;
            shapenetdata.depths(:,:,:,count) = uint16(depth);
            shapenetdata.set(:,count) = 1;
            count = count+1;
        end
    end

%     
%     
%     [depth, rendered, unproject, A, R, T]=renderer(width,height, objectname,0,0,-0.3,30,150,0,'zxy');
%     % Displays the results.
%     rendered = imresize(rendered, [256 256]);
%     depth = imresize(depth, [256 256], 'nearest');
%     %figure, imshow(depth); 
%     figure, imshow(rendered);
%     imwrite(rendered, 'test.jpg');
%     figure, imshow(depth);
    
end

save('shapenetData-18.mat', '-v7.3','shapenetdata');

