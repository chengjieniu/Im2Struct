%将hierarchy进行绘制
function draw3dOBB

%obbdata = load('H:\0retry_cv\data\obbdata.mat');
obbdata = load('obbdata.mat');
%for ii =1:length(genshapes)

[vertices,faces]=obj__read('H:\0retry_cv\training_data_models\1a6f615e8b1b5ae4dbbc9440457e303e\labeled\obb_new.obj');
% FV.vertices=vertices';
% FV.faces=faces';
% Volume=polygon2voxel(FV,[32,32,32],'au');
% plot3D(Volume);
hold off;
for ii =1:1
    recover_boxes = obbdata.obbdata{ii}.boxes;
 %   recover_boxes=imdb.images.labels(1861).boxes;
    figure(ii+101);
    axis equal;
    axis([-0.7 0.7 -0.7 0.7 -0.7 0.7]);
  %axis([-1 1 -1 1 -1 1]);
 % set(gca,'ydir','reverse','xaxislocation','top');
 
 xlabel ( '--X axis--' )
 ylabel ( '--Y axis--' )
 zlabel ( '--Z axis--' )
    hold on;
    
    for jj = 1:size(recover_boxes,2)
        p = recover_boxes(:,jj);
        draw3dOBB_v2(p,'r');
    end
      
end
%scatter3(vertices(1,:)/5,vertices(2,:)/5,vertices(3,:)/5)

MULT1 = (max(vertices(1,:)) - min(vertices(1,:)));
 MULT2 = (max(vertices(2,:)) - min(vertices(2,:)));
 MULT3 = (max(vertices(3,:)) - min(vertices(3,:)));
 MULT = max(max(MULT1,MULT2), MULT3);
 vertices(1,:) =  vertices(1,:) / MULT;
 vertices(2,:) =  vertices(2,:) / MULT;
 vertices(3,:) =  vertices(3,:) / MULT;
%scatter3(vertices(1,:)*1.35,vertices(2,:)*1.35,vertices(3,:)*1.35,'filled')
scatter3(vertices(1,:),vertices(2,:),vertices(3,:),'filled')
     
end