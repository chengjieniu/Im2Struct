function cnn_im2str_datasetup()
%datadir=load('G:\20170619dataprocess\Grass-master\code\gencode.mat');
%datadir=load('G:\20170619dataprocess\Grass-master\code\trainingdata.mat');
%datadir=load('H:\backgroundadd\frontdata\trainingdata.mat');
%load('H:\vgg_16_mask\matconvnet-1.0-beta24\vgg_16_mask\data\maskfeature.mat');
%load('H:\0retry_cv\data\obbdata.mat');
load('vgg_16_mask\data\obbdata_plane.mat');
%obbextra=load('H:\0retry_cv\data\obbdata_extra.mat');
%rendereddata=load('H:\0retry_cv\data\masknetdata\maskfeatureimdb.mat');
rendereddata = load('vgg_16_mask\data\maskfeatureimdb.mat');
dataset=obbdata;

inputSize=[224,224,3];
imdb.images.data=[];
imdb.images.labels=[];
%imdb.images.labels.boxes=[];
%imdb.images.labels.symshapes=[];
%imdb.images.labels.treekids=[];
%imdb.images.labels.symparams={};
imdb.images.set=[];
imdb.meta.sets={'train','val','test'};
%image_counter=0;
trainratio=0.75;
imageindex=0;

imdb.images.data=[];
imdb.images.maskfeature=[];
imdb.images.data=gather(rendereddata.imdb.images.data);
imdb.images.maskfeature=rendereddata.imdb.images.maskfeature;
for i=1:length(dataset)
    
    for j=1:12
        disp((i-1)*12+j);
        if strncmp(dataset{i}.obbname,rendereddata.imdb.modelname{(i-1)*12+j},15)
 %       image=dataset{i}.images{j};
        image=rendereddata.imdb.images.data(:,:,:,(i-1)*12+j);
  %      image=imresize(image,inputSize(1:2));
   %     image=single(image); 
        %不知道为何，如果用imdb.images.data(:,:,:,end+1),
        %则imdb.iamges.data(:,:,:,1)总是全0，而且最后数目总是多此数。
        imageindex=imageindex+1;
        %imdb.images.data(:,:,:,imageindex)=image;
        imdb.images.labels(imageindex).boxes=dataset{i}.boxes;
        imdb.images.labels(imageindex).symshapes=dataset{i}.symshapes;
        imdb.images.labels(imageindex).treekids=dataset{i}.treekids;
        imdb.images.labels(imageindex).symparams=dataset{i}.symparams;
        if i>=(length(dataset))*(1-trainratio)
            imdb.images.set(end+1)=1;
        else
            imdb.images.set(end+1)=3;
        end
        else
            disp('wrong');
            break;
        end
    end
end
% for i=length(dataset)+1:length(dataset)+length(obbextra.obbdata)
%     
%     for j=1:12
%         disp((i-1)*12+j);
%         if strncmp(obbextra.obbdata{i-length(dataset)}.obbname,rendereddata.imdb.modelname{(i-1)*12+j},15)
%  %       image=dataset{i}.images{j};
%         image=rendereddata.imdb.images.data(:,:,:,(i-1)*12+j);
%         image=imresize(image,inputSize(1:2));
%         image=single(image); 
%         %不知道为何，如果用imdb.images.data(:,:,:,end+1),
%         %则imdb.iamges.data(:,:,:,1)总是全0，而且最后数目总是多此数。
%         imageindex=imageindex+1;
%         %imdb.images.data(:,:,:,imageindex)=image;
%         imdb.images.labels(imageindex).boxes=obbextra.obbdata{i-length(dataset)}.boxes;
%         imdb.images.labels(imageindex).symshapes=obbextra.obbdata{i-length(dataset)}.symshapes;
%         imdb.images.labels(imageindex).treekids=obbextra.obbdata{i-length(dataset)}.treekids;
%         imdb.images.labels(imageindex).symparams=obbextra.obbdata{i-length(dataset)}.symparams;
%         if i>=(length(obbextra.obbdata)+length(dataset))*(1-trainratio)
%             imdb.images.set(end+1)=1;
%         else
%             imdb.images.set(end+1)=3;
%         end
%         else
%             disp('wrong');
%             break;
%         end
%     end
% end

% for times=1:9
%     for num=1:12
%         for kk=1:12
%             imageindex=imageindex+1
%             imdb.images.data(:,:,:,imageindex)=gather(rendereddata.imdb.images.data(:,:,:,4800+kk+(num-1)*12));
%             imdb.images.maskfeature(:,:,:,imageindex)=rendereddata.imdb.images.maskfeature(:,:,:,4800+kk+(num-1)*12);
%             imdb.images.labels(imageindex).boxes=obbextra.obbdata{num}.boxes;
%             imdb.images.labels(imageindex).symshapes=obbextra.obbdata{num}.symshapes;
%             imdb.images.labels(imageindex).treekids=obbextra.obbdata{num}.treekids;
%             imdb.images.labels(imageindex).symparams=obbextra.obbdata{num}.symparams;
%             imdb.images.set(end+1)=1;
%         end
%         
%     end
% end

%数据在进行maskfeatureout的时候 已经减去过均值了，故无需再进行均值处理
%dataMean=mean(imdb.images.data,4);

%imdb.images.data=single(bsxfun(@minus,imdb.images.data,dataMean));
%imdb.images.data_mean=dataMean;
%save image2box\imdbV2 imdb;
%save G:\backgroundadd\frontdata\imdb imdb;
%save ('H:\maskgrass_1030\matconvnet-1.0-beta24\im2str\data\im2strimdb.mat','-V7.3', 'imdb');
%save ('H:\0retry_cv\data\vgg_16_mask\im2strimdb.mat','-V7.3', 'imdb');
save('vgg_16_mask\data\im2strimdb.mat','-V7.3', 'imdb');
end