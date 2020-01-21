function draw_vgg16_test_demo
%load('D:\exp_vgg16_mask\test_image\candidate\genShapes.mat');
load('C:\Users\niuchengjie\Desktop\chair\mask\genShapes.mat');
for ii=1:26
%savefilepath_pre = 'D:\exp_vgg16_mask\test_image\candidate\';
savefilepath_pre = 'C:\Users\niuchengjie\Desktop\chair\mask\';
savefilepath=[savefilepath_pre num2str(ii) '.obb'];

recover_boxes = genShapes{ii}.boxes;
%recover_boxes=feature{1};

outputboxes = zeros(15, size(recover_boxes,2));
for jj = 1:size(recover_boxes,2)
    p = recover_boxes(:,jj);
    outputboxes(:,jj) = change2full(p);
end
      
fid = fopen(savefilepath, 'w');
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

end