%此脚本用来测试masknetwork训练的效果
%加载测试数据
im=imread('H:\matconvnet-1.0-beta24_20171026\matconvnet-1.0-beta24\masknetwork\data\3.jpg');

% load the pre-trained CNN
load( 'D:\exp_masknet\net-epoch-100.mat') ;
net=dagnn.DagNN.loadobj(net);
net.mode = 'test' ;

% load and preprocess an image
%imshow(im);
im_ = single(im) ; % note: 0-255 range
im_ = imresize(im_, [224 224]) ;
im_ = bsxfun(@minus, im_, net.meta.normalization.averageImage) ;
im_=gpuArray(im_);

% run the CNN
net.eval({'input', im_, 'input2', im_}) ;

front=1./zeros(56,56);
background=1./zeros(56,56);
% obtain the CNN otuput
scores = single(gather(net.vars(net.getVarIndex('prediction')).value)) ;
[~,chat] = max(scores,[],3);
[frow,fcol]=find(chat==1);
[brow,bcol]=find(chat==2);
for i=1:length(frow)
front(frow(i),fcol(i))=scores(frow(i),fcol(i),chat(frow(i),fcol(i)));
end

for i=1:length(brow)
background(brow(i),bcol(i))=scores(brow(i),bcol(i),chat(brow(i),bcol(i)));
end

fmin=(min(min(front)));
front(find(front==Inf))=fmin;
fmax=(max(max(front)));
ranf=fmax-fmin;

bmin=(min(min(background)));
background(find(background==Inf))=bmin;
bmax=(max(max(background)));
ranb=bmax-bmin;

fgray=(bsxfun(@minus, front, fmin)/ranf)*256;
bgray=(bsxfun(@minus,background,bmin)/ranb)*256;




figure(1);
colormap(gray);
image(bgray);

figure(2);
colormap(gray);
image(fgray);

figure(3);
image(im)



disp(1);

% absscores=abs(scores);
% Maxnum=sum(absscores,3);
% bili=bsxfun(@rdivide, absscores, Maxnum) ;
% pgray=bili.*256;
% 
% 
% E = exp(bsxfun(@minus, scores, max(scores,[],3))) ;
% L = sum(E,3) ;
% Y = bsxfun(@rdivide, E, L) ;
% 
% 
% % [~,chat] = max(scores,[],3) ;
% [~,chat] = max(Y,[],3);
% chat=single(gather(chat));
% t = length(find(c ~= chat))/(56*56) 
%scores = squeeze(gather(scores)) ;

% show the classification results
% [bestScore, best] = max(scores) ;
% figure(1) ; clf ; imagesc(im) ;
% title(sprintf('%s (%d), score %.3f',...
% net.meta.classes.description{best}, best, bestScore)) ;