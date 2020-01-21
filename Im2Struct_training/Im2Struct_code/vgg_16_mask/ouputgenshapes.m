%根据hierarchy恢复它对应的box,形成.obb文件
%savefilepath = 'C:\Users\Administrator\Desktop\jietu\2-10.obb';

%savefilepath = 'D:\plane_table_obj_obb_test0928\test\3.obb';
savefilefolder='C:\Users\niuchengjie\Desktop\cvprimages\obb_400_1.5\';
%savefilefolder='C:\Users\niuchengjie\Desktop\testimage\test400\';
load('C:\Users\niuchengjie\Desktop\cvprimages\vgg16_mask_genShapes.mat');
%load('C:\Users\niuchengjie\Desktop\testimage\vgg16_mask_genShapes');
for ii=1:19
recover_boxes =gather( genShapes{ii}.boxes);
%recover_boxes=feature{1};

outputboxes = zeros(15, size(recover_boxes,2));
for jj = 1:size(recover_boxes,2)
    p = recover_boxes(:,jj);
    outputboxes(:,jj) = change2full(p);
end
savefilepath=[savefilefolder genShapes{ii}.name '.obb']
fid = fopen(savefilepath, 'w+');
fprintf(fid, '# interpolation shape \r\n');
fprintf(fid, 'N %d\r\n', size(outputboxes,2));
for jj = 1:size(outputboxes,2)
    box = outputboxes(:,jj);
    center = box(1:3);
    boxlength = box(4:6);

    dir_1 = box(7:9);
    dir_2 = box(10:12);
    dir_1 = dir_1/norm(dir_1);
    dir_2 = dir_2/norm(dir_2);
    dir_3 = cross(dir_1,dir_2);
    dir_3 = dir_3/norm(dir_3); 

    fprintf(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f \r\n', center(1),center(2),center(3),dir_1(1),dir_1(2),dir_1(3),dir_2(1),dir_2(2),dir_2(3),...
            dir_3(1),dir_3(2),dir_3(3),boxlength(1),boxlength(2),boxlength(3));
end
fclose(fid);
end