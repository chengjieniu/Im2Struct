% 
mySetup();
% 
load('../../save/trainDAG_final_01/final03_FT-net-3.mat', 'net') ;
net = dagnn.DagNN.loadobj(net) ;
load('../../data/splits.mat');
net.move('cpu') ;
net.mode = 'test' ;
% 
imgpath = 'E:\Work\Indoor scene\semantic segmentation\ucm_seg_cvpr\stanford\images';
gtdepthspath = 'L:\work\Indoor scene\code\depthtransfer\MatlabCode\datasets\datasetNYU\depths';
savepcdir = '../../estpc_final_03';
mkdir(savepcdir);

rel_errors = double(0);
log_errors = double(0);
rm_errors = double(0);
testNum = 654;

rel_list = zeros(testNum, 1, 'single');
log_list = zeros(testNum, 1, 'single');
rm_list = zeros(testNum, 1, 'single');

t1 = 0;
t2 = 0;
t3 = 0;
for ii = 1:testNum
    disp(ii);
    id = num2str(testNdxs(ii), '%06d');
    im = imread([imgpath '\' id '.jpg']) ;
    im_ = single(im) ; % note: 255 range
    im_1 = imresize(im_, [240 320], 'bilinear');
    im_1 = im_1(22:235,20:300,:);
    im_1(:,:,1) = im_1(:,:,1) - net.meta.imgRbgMean.r;
    im_1(:,:,2) = im_1(:,:,2) - net.meta.imgRbgMean.g;
    im_1(:,:,3) = im_1(:,:,3) - net.meta.imgRbgMean.b;
    
    
    im_2 = imresize(im_, [240 320], 'bilinear');
    im_2 = im_2(22:235,20:300,:);
    im_2 = imresize(im_2, [107 140], 'bilinear');
    im_2(:,:,1) = im_2(:,:,1) - net.meta.imgRbgMean.r;
    im_2(:,:,2) = im_2(:,:,2) - net.meta.imgRbgMean.g;
    im_2(:,:,3) = im_2(:,:,3) - net.meta.imgRbgMean.b;
    
    [xx,yy] = meshgrid(1:140, 1:107);
    xx = single(xx)/140;
    yy = single(yy)/107;

    coordmap = zeros(107,140,2,1, 'single');
    coordmap(:,:,1,1) = xx;
    coordmap(:,:,2,1) = yy;
    
    % run the CNN
    predVar = net.getVarIndex('prediction') ;
    inputVar = 'input' ;
    net.eval({inputVar, im_1, 'input2', im_2}) ;
    crop_depth_1 = gather(net.vars(predVar).value) ;
    crop_depth_1 = power(10,crop_depth_1);
    crop_depth_1 = imresize(crop_depth_1, [427 561], 'bilinear');
    
    
    im_1 = flip(im_1, 2);
    im_2 = flip(im_2,2);
    net.eval({inputVar, im_1, 'input2', im_2}) ;
    crop_depth_2 = gather(net.vars(predVar).value) ;
    crop_depth_2 = power(10,crop_depth_2);
    crop_depth_2 = imresize(crop_depth_2, [427 561], 'bilinear');
    crop_depth_2 = flip(crop_depth_2,2);
    
    crop_depths = (crop_depth_1+crop_depth_2)/2;
%     crop_depths = crop_depth_1;
    load([gtdepthspath '\' id '.mat']);
    gt_depth = double(depth(45:471, 41:601))/1000;
    
%     load([savedepthpath '\' id '.mat']);
%     crop_depths = double(crop_depths);


%     for mm = 1:427
%         for nn = 1:561
%             rel_errors = rel_errors+abs(crop_depths(mm,nn)-gt_depth(mm,nn))/gt_depth(mm,nn);
%             log_errors = log_errors+abs(log10(crop_depths(mm,nn))-log10(gt_depth(mm,nn)));
%             rm_errors = rm_errors+(crop_depths(mm,nn)-gt_depth(mm,nn))^2;
%         end
%     end
    
    rel_mean = abs((crop_depths-gt_depth))./gt_depth;
    rel_mean = sum(rel_mean(:));
    rel_errors = rel_errors+rel_mean;
    log_mean = abs(log10(crop_depths)-log10(gt_depth));
    log_mean = sum(log_mean(:));
    log_errors = log_errors+log_mean;
    rm_mean = (crop_depths-gt_depth).^2;
    rm_mean = sum(rm_mean(:));
    rm_errors = rm_errors+rm_mean;
%     save([savedepthpath '\' id '.mat'], 'crop_depths');
    rel_list(ii) = rel_mean;
    log_list(ii) = log_mean;
    rel_list(ii) = rel_mean;

    rel_d1 = crop_depths./gt_depth;
    rel_d2 = gt_depth./crop_depths;
    
    max_rel_d = max(rel_d1,rel_d2);
    t1 = t1 + numel(find(max_rel_d < 1.25));
    t2 = t2 + numel(find(max_rel_d < 1.5625));
    t3 = t3 + numel(find(max_rel_d < 1.953125));

    
    
    depths = zeros(480,640);
    depths(45:471, 41:601) = crop_depths;
    
    points3d = rgb_plane2rgb_world(depths);

    savefile = [savepcdir '\' id '.ply'];
    plywrite(savefile,points3d);

end

rel_f = rel_errors/427/561/testNum;
log_f = log_errors/427/561/testNum;
rm_f = sqrt(rm_errors/427/561/testNum);
fprintf('rel log rm errors are %.4f %.4f %.4f\n', rel_f, log_f, rm_f);

ft1 = t1/(427*561)/testNum;
ft2 = t2/(427*561)/testNum;
ft3 = t3/(427*561)/testNum;

fprintf('<1.25 <1.25^2 <1.25^3 are %.4f %.4f %.4f\n', ft1, ft2, ft3);


