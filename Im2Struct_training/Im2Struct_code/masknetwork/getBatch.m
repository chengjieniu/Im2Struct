function y = getBatch(imdb, batch, mode, opts )

batchsize = numel(batch);
im = zeros(232,310,3,batchsize, 'uint8');
depths = zeros(111,150,1,batchsize, 'single');

if strcmp(mode,'train')
    for ii = 1:batchsize
        opid = randi(3);
        switch opid
            %%original
            case 1              
                im_temp = imdb.nyudata.images(5:236,6:315,:,batch(ii));
                depths_temp = single(imdb.nyudata.depths(:,:,:,batch(ii)))/1000;
                depths_temp = imresize(depths_temp,2,'nearest');
                depths_temp = depths_temp(11:230,11:310,:);
                depths_temp = imresize(depths_temp, [111 150], 'nearest');
                depths_temp(depths_temp >= 9.99) = 1000;
                depths_temp(depths_temp == 0) = 1000;
                im(:,:,:,ii) = im_temp;
                depths(:,:,:,ii) = depths_temp;
            %%rotate
            case 2                
                im_temp = imdb.nyudata.images(:,:,:,batch(ii));
                im_temp = imresize(im_temp, 1.2, 'bilinear');
                depths_temp = single(imdb.nyudata.depths(:,:,:,batch(ii)))/1000;
                depths_temp = imresize(depths_temp,2,'nearest');
                depths_temp = imresize(depths_temp,1.2,'nearest');
                depths_temp = depths_temp/1.2;
                rot_angle = 1+4*rand;
                rotid = randi(2);
                switch rotid
                    case 1
                        im_temp_rot = imrotate(im_temp, rot_angle, 'bilinear');
                        depths_temp_rot = imrotate(depths_temp, rot_angle, 'nearest');
                        start_y = randi([38 51]);
                        start_x = randi([32 69]);
                        im_temp = im_temp_rot(start_y:start_y+231, start_x:start_x+309,:);
                        depths_temp = depths_temp_rot(start_y+6:start_y+231-6, start_x+5:start_x+309-5,:);
                        depths_temp = imresize(depths_temp, [111 150], 'nearest');
                        depths_temp(depths_temp >= 9.99) = 1000;
                        depths_temp(depths_temp == 0) = 1000;
                        im(:,:,:,ii) = im_temp;
                        depths(:,:,:,ii) = depths_temp;                    
                    case 2
                        rot_angle = -rot_angle;
                        im_temp_rot = imrotate(im_temp, rot_angle, 'bilinear');
                        depths_temp_rot = imrotate(depths_temp, rot_angle, 'nearest');
                        start_y = randi([38 51]);
                        start_x = randi([32 69]);
                        im_temp = im_temp_rot(start_y:start_y+231, start_x:start_x+309,:);
                        depths_temp = depths_temp_rot(start_y+6:start_y+231-6, start_x+5:start_x+309-5,:);
                        depths_temp = imresize(depths_temp, [111 150], 'nearest');
                        depths_temp(depths_temp >= 9.99) = 1000;
                        depths_temp(depths_temp == 0) = 1000;
                        im(:,:,:,ii) = im_temp;
                        depths(:,:,:,ii) = depths_temp;  
                end
            %%scale and translate
            case 3
                while(1)
                    im_temp = imdb.nyudata.images(5:236,6:315,:,batch(ii));
                    depths_temp = single(imdb.nyudata.depths(:,:,:,batch(ii)))/1000;
                    depths_temp = imresize(depths_temp,2,'nearest');
                    depths_temp = depths_temp(5:236,6:315);               
                    sc = 1.05+0.45*rand;
                    im_temp = imresize(im_temp, sc);
                    depths_temp = imresize(depths_temp, sc, 'nearest');
                    depths_temp = depths_temp/sc;
                    height = size(im_temp,1);
                    width = size(im_temp,2);
                    start_x = randi([1 width-310+1]);
                    start_y = randi([1 height-232+1]);
                    im_temp = im_temp(start_y:start_y+231, start_x:start_x+309, :);
                    depths_temp = depths_temp(start_y+6:start_y+231-6, start_x+5:start_x+309-5, :);
                    depths_temp = imresize(depths_temp, [111 150], 'nearest');
                    depths_temp(depths_temp >= 9.99) = 1000;
                    depths_temp(depths_temp == 0) = 1000;
                    im(:,:,:,ii) = im_temp;
                    depths(:,:,:,ii) = depths_temp;
                    
                    validdepthnum = numel(find(depths_temp<10));
                    if validdepthnum > 500
                        break;
                    end
                end
                
        end
    end
    
    setim = zeros(232,310,3,3*batchsize, 'uint8');
    setdepths = zeros(111,150,1,3*batchsize, 'single');
    for ii = 1:batchsize
        setim(:,:,:,3*(ii-1)+1) = im(:,:,:,ii);
        setdepths(:,:,:,3*(ii-1)+1) = depths(:,:,:,ii);
        colorid = randi(6);
        %%brightness and contrast
        switch colorid
            case 1
                %%increase brightness
                sc = 0.1+0.2*rand;
                setim(:,:,:,3*(ii-1)+2) = imadjust(im(:,:,:,ii), [0 1], [sc 1]);
            case 2
                %%decrease brightness
                sc = 0.9-0.3*rand;
                setim(:,:,:,3*(ii-1)+2) = imadjust(im(:,:,:,ii), [0 1], [0 sc]);
            case 3
                %%increase contrast
                sc = 0.9-0.3*rand;
                setim(:,:,:,3*(ii-1)+2) = imadjust(im(:,:,:,ii), [0 sc], [0 1]);
            case 4
                %%decrease contrast
                sc = 0.1+0.2*rand;
                setim(:,:,:,3*(ii-1)+2) = imadjust(im(:,:,:,ii), [sc 1], [0 1]);
            case {5,6}
                sc = 0.8+0.4*rand(1,3);
                setim(:,:,1,3*(ii-1)+2) = im(:,:,1,ii)*sc(1);
                setim(:,:,2,3*(ii-1)+2) = im(:,:,2,ii)*sc(2);
                setim(:,:,3,3*(ii-1)+2) = im(:,:,3,ii)*sc(3);           
        end
        setdepths(:,:,:,3*(ii-1)+2) = depths(:,:,:,ii);
        setim(:,:,:,3*(ii-1)+3) = flip(im(:,:,:,ii), 2);
        setdepths(:,:,:,3*(ii-1)+3) = flip(depths(:,:,:,ii), 2);   
    end

else
    setim = imdb.nyudata.images(5:236,6:315,:,batch);
    setdepths = single(imdb.nyudata.depths(:,:,:,batch))/1000 ;
    setdepths = imresize(setdepths,2,'bilinear');
    setdepths = setdepths(11:230,11:310,:,:);
    setdepths = imresize(setdepths, [111 150], 'bilinear');
end

setim = single(setim);
setim(:,:,1,:) = setim(:,:,1,:)-opts.imgRbgMean.r;
setim(:,:,2,:) = setim(:,:,2,:)-opts.imgRbgMean.g;
setim(:,:,3,:) = setim(:,:,3,:)-opts.imgRbgMean.b;

if opts.useGpu
  setim = gpuArray(setim);
end

y = {'input', setim, 'input2', setim, 'label', setdepths} ;
