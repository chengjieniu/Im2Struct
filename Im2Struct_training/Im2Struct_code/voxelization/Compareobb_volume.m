%compare the obb_box with volume_obj
function Compareobb_volume
%% ����obbdata.mat�� OBJXXX.mat��ȡ���м�ע�Ͳ������ɣ�
%����ʹ���м䲿������OBJXXX.matʱ��һ��Ҫ��ע�͵�����������load���
  load('obbdata.mat');
  load('OBJ153.mat');
%% �ҵ�obj�ļ���·��
%rootpath='H:\0retry_cv\training_data_models\';
rootpath='H:\0retry_cv\chair_aligned_obj_obb_200\chair_aligned_obj_obb_200\*.obj';
files = dir(rootpath);
sizefiles = size(files);
length = sizefiles(1);

%% %�洢obj�ĵ�����Ϣ��OBJXXX.mat
% % for i=1:length-2
% for i=1:length
%     disp(i); 
% %    obbpath = strcat( rootpath,files(i+2).name,'/model_seg.obj' );
%     objpath = strcat( 'H:\0retry_cv\chair_aligned_obj_obb_200\chair_aligned_obj_obb_200\',files(i).name );
       %��ȡobj�ļ��ĵ�����Ϣ
%     [vertices,faces]=obj__read(objpath);
%     %��obj�ļ����Ļָ�������ԭ��
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
      %��obj�ļ���һ��
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
% %�洢obj
% save OBJ153 Volume;

%% ����obb��mesh����volume���Ƚ�ƥ��Ч�������ʱ����Ҫ�õ�ǰ���load�����ص��ļ�
%for i=1:length-2
for i=1:length
    %����һ��figure���µľ�����
    hold off;
%    set(0,'DefaultFigureVisible', 'off');
    %���������obb
    drawmeshandobb(obbdata{i}.boxes, OBJ153(i),'r');
    %����volume��obb
 %   drawvolumeandobb(obbdata{i}.boxes, OBJ400(i),'r')
    %����figure�ӽ�
    view(0,90);
    %����figureͼƬ
    saveas(gcf,['H:\0retry_cv\training_data_models_images_model_obb\',obbdata{i}.obbname,'.jpg'])
end

end