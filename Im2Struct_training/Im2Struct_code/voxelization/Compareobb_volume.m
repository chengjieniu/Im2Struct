%compare the obb_box with volume_obj
function Compareobb_volume
%% 加载obbdata.mat和 OBJXXX.mat（取消中间注释部分生成）
%所以使用中间部分生成OBJXXX.mat时候，一定要先注释掉下面这两个load语句
  load('obbdata.mat');
  load('OBJ153.mat');
%% 找到obj文件的路径
%rootpath='H:\0retry_cv\training_data_models\';
rootpath='H:\0retry_cv\chair_aligned_obj_obb_200\chair_aligned_obj_obb_200\*.obj';
files = dir(rootpath);
sizefiles = size(files);
length = sizefiles(1);

%% %存储obj的点面信息到OBJXXX.mat
% % for i=1:length-2
% for i=1:length
%     disp(i); 
% %    obbpath = strcat( rootpath,files(i+2).name,'/model_seg.obj' );
%     objpath = strcat( 'H:\0retry_cv\chair_aligned_obj_obb_200\chair_aligned_obj_obb_200\',files(i).name );
       %获取obj文件的点面信息
%     [vertices,faces]=obj__read(objpath);
%     %将obj文件中心恢复到坐标原点
%     if(max(vertices(1,:)) + min(vertices(1,:))~=0)
%         vertices(1,:)=vertices(1,:)-((max(vertices(1,:)) + min(vertices(1,:)))/2);
%     end
%     if(max(vertices(2,:)) + min(vertices(2,:))~=0)
%         vertices(2,:)=vertices(2,:)-((max(vertices(2,:)) + min(vertices(2,:)))/2);
%     end
%     if(max(vertices(3,:)) + min(vertices(3,:))~=0)
%         vertices(3,:)=vertices(3,:)-((max(vertices(3,:)) + min(vertices(3,:)))/2);
%     end
%     
      %将obj文件归一化
%     MULT1 = (max(vertices(1,:)) - min(vertices(1,:)));
%     MULT2 = (max(vertices(2,:)) - min(vertices(2,:)));
%     MULT3 = (max(vertices(3,:)) - min(vertices(3,:)));
%     MULT = max(max(MULT1,MULT2), MULT3);
%     vertices(1,:) =  vertices(1,:) / MULT;
%     vertices(2,:) =  vertices(2,:) / MULT;
%     vertices(3,:) =  vertices(3,:) / MULT;
%     
%     FV.vertices=vertices';
%     FV.faces=faces';
% 	  Volume(i)=FV;
% %   ploygon2voxel(volume,) 
% %   plot3D(polygon2voxel(Volume(i),[32,32,32],'au'));
%     clear FV;
%     clear vertices;
%     clear faces;   
% end
% %存储obj
% save OBJ153 Volume;

%% 绘制obb和mesh或者volume，比较匹配效果，这个时候需要用的前面的load语句加载的文件
%for i=1:length-2
for i=1:length
    %将上一个figure留下的句柄清除
    hold off;
%    set(0,'DefaultFigureVisible', 'off');
    %绘制网格和obb
    drawmeshandobb(obbdata{i}.boxes, OBJ153(i),'r');
    %绘制volume和obb
 %   drawvolumeandobb(obbdata{i}.boxes, OBJ400(i),'r')
    %调整figure视角
    view(0,90);
    %保存figure图片
    saveas(gcf,['H:\0retry_cv\training_data_models_images_model_obb\',obbdata{i}.obbname,'.jpg'])
end

end