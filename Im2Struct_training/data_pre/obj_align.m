% align obj 
% datapath = 'H:\0retry_cv\04379243\04379243'
% folderlist = dir(datapath);
% count = 1;
% for ii =1:502
%     disp(ii);
%     if strcmp('.',folderlist(ii,1).name) || strcmp('..',folderlist(ii,1).name)
%         continue;
%     end
%     objectname = fullfile(datapath,folderlist(ii,1).name,'model.obj');
%     [v,f]=obj__read(objectname);
%     vertices=v;
%     MULT1 = (max(vertices(1,:)) - min(vertices(1,:)));
%     MULT2 = (max(vertices(2,:)) - min(vertices(2,:)));
%     MULT3 = (max(vertices(3,:)) - min(vertices(3,:)));
%     MULT = max(max(MULT1,MULT2), MULT3);
%     disp([max(vertices(1,:)),max(vertices(2,:)),max(vertices(3,:))]);
%     disp([min(vertices(1,:)),min(vertices(2,:)),min(vertices(3,:))]);
% %     vertices(1,:) =  vertices(1,:) / MULT*64 +32;
% %     vertices(2,:) =  vertices(2,:) / MULT*64 +32;
% %     vertices(3,:) =  vertices(3,:) / MULT*64 +32;
% %     FV.vertices = vertices';
% end
   
datapath = 'H:\0retry_cv\PartNet_data\Table\Table\models';
savepath = 'H:\0retry_cv\PartNet_data\Table\Table\alignmodels';
folderlist = dir(datapath);
count = 1;
for ii =1:length(folderlist)
    disp(ii);
    if strcmp('.',folderlist(ii,1).name) || strcmp('..',folderlist(ii,1).name)
        continue;
    end
    objectname = fullfile(datapath,folderlist(ii,1).name);
    [v,f]=obj__read(objectname);
    vertices=v;
    MULT1 = (max(vertices(1,:)) - min(vertices(1,:)));
    MULT2 = (max(vertices(2,:)) - min(vertices(2,:)));
    MULT3 = (max(vertices(3,:)) - min(vertices(3,:)));
    MULT = max(max(MULT1,MULT2), MULT3);
%     disp([max(vertices(1,:)),max(vertices(2,:)),max(vertices(3,:))]);
%     disp([min(vertices(1,:)),min(vertices(2,:)),min(vertices(3,:))]);
    vertices(1,:) =  (vertices(1,:)  + (MULT1/2 - max(vertices(1,:)))) / MULT;
    vertices(2,:) =  (vertices(2,:)  + (MULT2/2 - max(vertices(2,:)))) / MULT;
    vertices(3,:) =  (vertices(3,:)  + (MULT3/2 - max(vertices(3,:)))) / MULT;
    vertices = flipud(vertices);
    FV.vertices = vertices';
    obj_write(fullfile(savepath,folderlist(ii,1).name), FV.vertices, f');
end


