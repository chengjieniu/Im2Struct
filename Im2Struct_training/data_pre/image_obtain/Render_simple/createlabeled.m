%the path that the models you choosed from ShapeNet 
datapath = 'H:\0retry_cv\chair_300_未分割';
folderlist = dir(datapath);
for ii = 3:164
    disp(ii);
    if strcmp('.',folderlist(ii,1).name) || strcmp('..',folderlist(ii,1).name)
        continue;
    end 
    savename=fullfile(datapath,folderlist(ii,1).name);
%    delete([savename,'\labeled']);%删除文件
%   rmdir( [savename,'\labeled']);%删除文件夹
   mkdir( savename,'labeled');      %新建一个labeled文件夹 

end