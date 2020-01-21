%将hierarchy进行绘制
function showGenshapes(genshapes)

for ii =1:length(genshapes)
%for ii =1:1
    recover_boxes = genshapes{ii}.boxes;
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
        draw3dOBB_v2(p,'b');
    end
      
end
end