%add background
%load('H:\backgroundadd\frontdata\testdata.mat');
%load('h:\backgroundadd\frontdata\rendereddata1.mat')

load('H:\0retry_cv\data\backgroundadd\fbrendereddata.mat');
backpath = 'h:\backgroundadd\backgrounddata';
folderlist = dir(backpath);
% maskdata.raw=zeros(224,224,3,2400);
% maskdata.label=zeros(56,56,1,2400);
count=0;
for jj=1:400
    for kk=1:12
    count=count+1;
    disp(count);
    front=fbrendereddata{jj}.images{kk};
    front_depth = fbrendereddata{jj}.depths{kk};
    background=imread(['backgrounddata\' folderlist(mod(count,22)+3,1).name]);
    inputSize=[224,224,3];
    front=imresize(front,inputSize(1:2));
    background=imresize(background,inputSize(1:2));

% [m,n]=find(front_depth==0);
% for ii=1:length(n)
%     front(m(ii),n(ii),:)=0;
% end
% background(find(abs(front-0)>0))=0;
    label=zeros(224,224,1);
    %目标为5，非目标为9
    label(:,:,1)=2;
%     %非目标
%     label(:,:,2)=1;
    [m,n]=find(front_depth~=0);
    for ii=1:length(n)
         background(m(ii),n(ii),:)=front(m(ii),n(ii),:);
         %前景：
         label(m(ii),n(ii),1)=1;
%          %背景
%          label(m(ii),n(ii),2)=0;
    end
% background(find(abs(front-0)>0))=0;

%join=(front+background);
    join=background;
    maskdata.modelname{count}=fbrendereddata{jj}.modelname;
    maskdata.raw(:,:,:,count)=join;
    maskdata.label(:,:,:,count)=imresize(label,[56,56],'nearest');

%    imshow(join);
%     if mod(jj,12)==0
%         rendereddata{fix((jj-1)/12)+1}.images{12}=join;
%     else
%         rendereddata{fix((jj-1)/12)+1}.images{mod(jj,12)}=join;
%     end
       imwrite(join, [ 'H:\0retry_cv\data\backgroundadd\outputpicture\' fbrendereddata{jj}.modelname '_' num2str(kk)  '.jpg']);
    end
end

%     maskdata.label( maskdata.label>0.5)=5;
%     maskdata.label( maskdata.label<=0.5)=9;
save ('H:\0retry_cv\data\backgroundadd\maskdata.mat', '-v7.3', 'maskdata');
%save ('frontdata\rendereddata.mat', '-v7.3', 'rendereddata');
