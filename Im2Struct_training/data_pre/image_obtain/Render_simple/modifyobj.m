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
    fid=fopen(savename,'wt');      %�½�һ��txt�ļ�  
    file_oldpath = objectname;                 %Ҫ��ȡ���ĵ����ڵ�·��  
    fpn = fopen (file_oldpath, 'rt');           %���ĵ�  
    while feof(fpn) ~= 1                %�����ж��ļ�ָ��p������ָ���ļ��е�λ�ã�������ļ�ĩ����������1�����򷵻�0  
          file = fgetl(fpn) ;           %��ȡ�ĵ���һ��  
                                        %%%  
                                       %�м��ⲿ���ǶԶ�ȡ���ַ���file�������⴦��                                 
         if strncmp(file,'mtllib',6)                      
             new_str='mtllib model.mtl';
             fprintf(fid,'%s\n',new_str);%�µ��ַ���д�뵱�½���txt�ĵ���
             disp('hello0')
             continue;      
         end
         fprintf(fid,'%s\n',file);%�µ��ַ���д�뵱�½���txt�ĵ���
    end
    fclose(fpn);
    fclose(fid);
end
save shapes;