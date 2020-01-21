function drawvolumeandobb(obbs, FV, c1)
%绘制obb和volume信息
%obb是存储有hierarchy信息的数组，FC是存储的点面信息，cl是obb的绘制颜色如‘r’,'b'等
boxNum = size(obbs,2);
figure(1);
%plogygon2voxel(FV(点面信息),体素分辨率，自动，false)，此处的false可以不改变原先的坐标系统，否则和obb的坐标系不对应
plot3D(polygon2voxel(FV,[32,32,32],'au',false)); hold on;

cube_len=32;
box_offset=16.5;

for ii = 1:boxNum
    p = obbs(:,ii);
    center = p(1:3)*cube_len+box_offset;
    lengths = p(4:6)*cube_len; 
    dir_1 = p(7:9);
    dir_2 = p(10:12);

    dir_1 = dir_1/norm(dir_1);
    dir_2 = dir_2/norm(dir_2);
    dir_3 = cross(dir_1,dir_2);
    dir_3 = dir_3/norm(dir_3);  
    cornerpoints = zeros(8,3);

    d1 = 0.5*lengths(1)*dir_1;
    d2 = 0.5*lengths(2)*dir_2;
    d3 = 0.5*lengths(3)*dir_3;
    cornerpoints(1,:) = center-d1-d2-d3;
    cornerpoints(2,:) = center-d1+d2-d3;
    cornerpoints(3,:) = center+d1-d2-d3;
    cornerpoints(4,:) = center+d1+d2-d3;
    cornerpoints(5,:) = center-d1-d2+d3;
    cornerpoints(6,:) = center-d1+d2+d3;
    cornerpoints(7,:) = center+d1-d2+d3;
    cornerpoints(8,:) = center+d1+d2+d3;

    plot3([cornerpoints(1,1),cornerpoints(2,1)],[cornerpoints(1,2),cornerpoints(2,2)],[cornerpoints(1,3),cornerpoints(2,3)],c1);hold on;
    plot3([cornerpoints(1,1),cornerpoints(3,1)],[cornerpoints(1,2),cornerpoints(3,2)],[cornerpoints(1,3),cornerpoints(3,3)],c1);hold on;
    plot3([cornerpoints(2,1),cornerpoints(4,1)],[cornerpoints(2,2),cornerpoints(4,2)],[cornerpoints(2,3),cornerpoints(4,3)],c1);hold on;
    plot3([cornerpoints(3,1),cornerpoints(4,1)],[cornerpoints(3,2),cornerpoints(4,2)],[cornerpoints(3,3),cornerpoints(4,3)],c1);hold on;
    plot3([cornerpoints(5,1),cornerpoints(6,1)],[cornerpoints(5,2),cornerpoints(6,2)],[cornerpoints(5,3),cornerpoints(6,3)],c1);hold on;
    plot3([cornerpoints(5,1),cornerpoints(7,1)],[cornerpoints(5,2),cornerpoints(7,2)],[cornerpoints(5,3),cornerpoints(7,3)],c1);hold on;
    plot3([cornerpoints(6,1),cornerpoints(8,1)],[cornerpoints(6,2),cornerpoints(8,2)],[cornerpoints(6,3),cornerpoints(8,3)],c1);hold on;
    plot3([cornerpoints(7,1),cornerpoints(8,1)],[cornerpoints(7,2),cornerpoints(8,2)],[cornerpoints(7,3),cornerpoints(8,3)],c1);hold on;
    plot3([cornerpoints(1,1),cornerpoints(5,1)],[cornerpoints(1,2),cornerpoints(5,2)],[cornerpoints(1,3),cornerpoints(5,3)],c1);hold on;
    plot3([cornerpoints(2,1),cornerpoints(6,1)],[cornerpoints(2,2),cornerpoints(6,2)],[cornerpoints(2,3),cornerpoints(6,3)],c1);hold on;
    plot3([cornerpoints(3,1),cornerpoints(7,1)],[cornerpoints(3,2),cornerpoints(7,2)],[cornerpoints(3,3),cornerpoints(7,3)],c1);hold on;
    plot3([cornerpoints(4,1),cornerpoints(8,1)],[cornerpoints(4,2),cornerpoints(8,2)],[cornerpoints(4,3),cornerpoints(8,3)],c1);hold on;
%    axis equal;
end

end

