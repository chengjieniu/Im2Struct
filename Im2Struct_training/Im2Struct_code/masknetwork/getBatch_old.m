function y = getBatch_old(imdb, batch, mode, opts )

im = imdb.nyudata.images(:,:,:,batch);
im2 = imresize(im, [53 70], 'bilinear');
depths = single(imdb.nyudata.depths(:,:,:,batch))/1000 ;
depths = imresize(depths, [53 70], 'bilinear');

if strcmp(mode,'train')

    batchsize = numel(batch);
    
    if batchsize > 1

        %flip
        flipindex = 2:2:batchsize;
        if numel(flipindex)>0
            im(:,:,:,flipindex) = flip(im(:,:,:,flipindex),2);
            im2(:,:,:,flipindex) = flip(im2(:,:,:,flipindex),2);
            depths(:,:,:,flipindex) = flip(depths(:,:,:,flipindex),2);
        end
        %brightness
%         brightindex = 1:3:batchsize;
%         w = 0.75+0.5*rand;
%         im(:,:,:,brightindex) = im(:,:,:,brightindex)*w;
%         im2(:,:,:,brightindex) = im2(:,:,:,brightindex)*w;

        %casting on R G B channel
%         castingindex = 3:5:batchsize;
%         w1 = 0.85+0.3*rand;
%         w2 = 0.85+0.3*rand;
%         w3 = 0.85+0.3*rand;
%         im(:,:,1,castingindex) = im(:,:,1,castingindex)*w1;
%         im(:,:,2,castingindex) = im(:,:,2,castingindex)*w2;
%         im(:,:,3,castingindex) = im(:,:,3,castingindex)*w3;
%         
%         im2(:,:,1,castingindex) = im2(:,:,1,castingindex)*w1;
%         im2(:,:,2,castingindex) = im2(:,:,2,castingindex)*w2;
%         im2(:,:,3,castingindex) = im2(:,:,3,castingindex)*w3;

        %add noise
%         noiseindex = 2:5:batchsize;
%         w = 0.00025+0.0005*rand;
%         im(:,:,:,noiseindex) = imnoise(im(:,:,:,noiseindex),'gaussian', 0, w);
    end
    
end

im = single(im);
im(:,:,1,:) = im(:,:,1,:)-opts.imgRbgMean.r;
im(:,:,2,:) = im(:,:,2,:)-opts.imgRbgMean.g;
im(:,:,3,:) = im(:,:,3,:)-opts.imgRbgMean.b;

im2 = single(im2);
im2(:,:,1,:) = im2(:,:,1,:)-opts.imgRbgMean.r;
im2(:,:,2,:) = im2(:,:,2,:)-opts.imgRbgMean.g;
im2(:,:,3,:) = im2(:,:,3,:)-opts.imgRbgMean.b;

if opts.useGpu
  im = gpuArray(im) ;
  im2 = gpuArray(im2) ;
end

y = {'input', im, 'input2', im2, 'label', depths} ;
