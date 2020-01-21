function drawmeshandobb(obbs, FV, c1)
%����obb��mesh
%obb�Ǵ洢��hierarchy��Ϣ�����飬FC�Ǵ洢�ĵ�����Ϣ��cl��obb�Ļ�����ɫ�确r��,'b'��
boxNum = size(obbs,2);
figure(1);
%ϵͳ�Դ�����
trimesh(FV.faces,FV.vertices(:,1),FV.vertices(:,2),FV.vertices(:,3)); hold on;

for ii = 1:boxNum
    p = obbs(:,ii);
    center = p(1:3);
    lengths = p(4:6);
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
    axis equal;
end

end

