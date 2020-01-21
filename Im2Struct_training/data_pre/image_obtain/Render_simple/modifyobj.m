datapath = 'G:\ncj_chair_selected235';
folderlist = dir(datapath);
for ii = 8:30
    disp(ii);
    if strcmp('.',folderlist(ii,1).name) || strcmp('..',folderlist(ii,1).name)
        continue;
    end
    
  %  objectname = fullfile(datapath, folderlist(ii,1).name, 'model_seg.obj')
  %  objectname = fullfile(datapath,'a4da5746b99209f85da16758ae613576','model.obj')
  objectname= fullfile(datapath,folderlist(ii,1).name,'model_seg_tex.obj')
  savename=fullfile(datapath,folderlist(ii,1).name,'model_seg_texture.obj');
    fid=fopen(savename,'wt');      %新建一个txt文件  
    file_oldpath = objectname;                 %要读取的文档所在的路径  
    fpn = fopen (file_oldpath, 'rt');           %打开文档  
    while feof(fpn) ~= 1                %用于判断文件指针p在其所指的文件中的位置，如果到文件末，函数返回1，否则返回0  
          file = fgetl(fpn) ;           %获取文档第一行  
                                        %%%  
                                       %中间这部分是对读取的字符串file进行任意处理                                 
         if strncmp(file,'mtllib',6)                      
             new_str='mtllib model.mtl';
             fprintf(fid,'%s\n',new_str);%新的字符串写入当新建的txt文档中
             disp('hello0')
             continue;      
         end
         fprintf(fid,'%s\n',file);%新的字符串写入当新建的txt文档中
    end
    fclose(fpn);
    fclose(fid);
end
save shapes;