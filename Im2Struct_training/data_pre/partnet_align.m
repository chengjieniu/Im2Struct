%align partnet and shapenet
shapenet = load('C:\Users\niuchengjie\Desktop\partNet_data\tabel_image\shapenet\shapenet_depth.mat');
partnet = load('C:\Users\niuchengjie\Desktop\partNet_data\tabel_image\partnet\partnet_depth.mat');
count = 0;
for i = 1:length(shapenet.rendereddata)
    %disp(i)
    for j =1 : length(partnet.rendereddata)
        m = abs(shapenet.rendereddata{i}.images{1} - partnet.rendereddata{j}.images{1});        
        if sum(sum(m))< 1.05e+03
            count = count+1;
            disp('ok')
            disp(sum(sum(m)))
            spalign{count}.shapename = shapenet.rendereddata{i}.modelname;
            spalign{count}.partname = partnet.rendereddata{j}.modelname;
            break
        end
    end
end
% spath = 'C:\Users\niuchengjie\Desktop\partNet_data\tabel_image\shapenet';
% ppath = 'C:\Users\niuchengjie\Desktop\partNet_data\tabel_image\partnet';
% imagesavepath = 'C:\Users\niuchengjie\Desktop\partNet_data\tabel_image\compare';
% for i = 1: length(spalign)
%     disp(i)
%     sdepth = imread([ fullfile(spath, spalign{i}.shapename) '.jpg']);
%     imwrite(sdepth,[imagesavepath '\' num2str(i) '_s.jpg'])
%     pdepth = imread( [fullfile(ppath, spalign{i}.partname) '.jpg']);
%     imwrite(pdepth,[imagesavepath '\' num2str(i) '_p.jpg'])
% end