%根据12d的box表示，恢复其15d的box
function full_box = change2full( p )

center = p(1:3);
lengths = p(4:6);
dir_1 = p(7:9);
dir_2 = p(10:12);

dir_1 = dir_1/norm(dir_1);
dir_2 = dir_2/norm(dir_2);
dir_3 = cross(dir_1,dir_2);
dir_3 = dir_3/norm(dir_3); 

full_box = zeros(15,1);

full_box(1:3) = center;

full_box(7:15) = [dir_1,dir_2,dir_3];

full_box(4:6) = lengths;


end

