%��Ϊobj�ĺܶ�model���ܱ�obb������������Ҫ���и���obj�滻ԭ�ȵ�obj��.mat��Ϣ
rootpath='H:\0retry_cv\training_data_models_images_model_obb\*.obb.jpg';
files = dir(rootpath);
sizefiles = size(files);
length = sizefiles(1);
for i=1:length
    files(i).name=erase(files(i).name,'.jpg');  
    names{i}=files(i).name;
end

load('obbdata.mat');
[~,obbnum]=size(obbdata);
Mesh=load('Mesh.mat');
Mesh_seg=load('Mesh_seg.mat');
for j=1:obbnum
    if ismember(obbdata{j}.obbname,names)
        disp(j);
        Mesh.Volume(j)=Mesh_seg.Volume(j);
    end
end
save OBJ400 Mesh;