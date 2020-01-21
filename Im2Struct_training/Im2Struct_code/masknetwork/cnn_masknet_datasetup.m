%datadir=load('G:\20170619dataprocess\Grass-master\code\gencode.mat');
%datadir=load('G:\20170619dataprocess\Grass-master\code\trainingdata.mat');
datadir=load('H:\backgroundadd\frontdata\maskdata.mat');
dataset=datadir.maskdata;
inputSize=[224,224,3];
imdb.images.data=[];
imdb.images.labels=[];

imdb.images.set=[];
imdb.meta.sets={'train','val','test'};
image_counter=0;
trainratio=0.85;
imageindex=0;

imdb.images.data=single(dataset.raw); 
imdb.images.labels=single(dataset.label);
for i=1:length(dataset.raw)
%         image=single(dataset.raw(:,:,:,i)); 
%         imdb.images.data(:,:,:,i)=image;
        if i<=length(dataset.raw)*trainratio
            imdb.images.set(end+1)=1;
        else
            imdb.images.set(end+1)=3;
        end
end
dataMean=mean(imdb.images.data,4);

imdb.images.data=single(bsxfun(@minus,imdb.images.data,dataMean));
imdb.images.data_mean=dataMean;
%save image2box\imdbV2 imdb;
save H:\matconvnet-1.0-beta24_20171026\matconvnet-1.0-beta24\masknetwork\data_modify\imdb imdb;