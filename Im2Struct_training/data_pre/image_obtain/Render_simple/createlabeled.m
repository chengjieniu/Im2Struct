%the path that the models you choosed from ShapeNet 
datapath = 'H:\0retry_cv\chair_300_δ�ָ�';
folderlist = dir(datapath);
for ii = 3:164
    disp(ii);
    if strcmp('.',folderlist(ii,1).name) || strcmp('..',folderlist(ii,1).name)
        continue;
    end 
    savename=fullfile(datapath,folderlist(ii,1).name);
%    delete([savename,'\labeled']);%ɾ���ļ�
%   rmdir( [savename,'\labeled']);%ɾ���ļ���
   mkdir( savename,'labeled');      %�½�һ��labeled�ļ��� 

end