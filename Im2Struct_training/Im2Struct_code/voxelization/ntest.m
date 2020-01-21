[vertices, faces ]= obj__read( 'model.obj' );
%trimesh(faces', vertices(1,:), vertices(2,:), vertices(3,:),'LineWidth',1,'EdgeColor','k');
%obj_write('myobj.obj',vertices,faces);
vertices=vertices';
faces= faces';
save voxelization\model.mat vertices faces