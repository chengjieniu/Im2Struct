% datapath='H:\0retry_cv\training_data_models'
% savepath='H:\0retry_cv\data\obb';
% folderlist = dir(datapath);
% delete H:\0retry_cv\data\obb\*.obb;
datapath = 'C:\Users\niuchengjie\Desktop\partNet_data\airplane-labeled\airplane-labeled';
savepath = 'C:\Users\niuchengjie\Desktop\partNet_data\airplane-labeled\obb_plane'
folderlist = dir(datapath);
for ii = 3:length(folderlist)
    disp(ii);
    if strcmp('.',folderlist(ii,1).name) || strcmp('..',folderlist(ii,1).name)
        continue;
    end    
    objectname = fullfile(datapath,folderlist(ii,1).name,'labeled\model_seg_2.obb');
    index=ii-2;
    savename=fullfile(savepath,[folderlist(ii,1).name,'.obb']);
    copyfile(objectname,savename);
end