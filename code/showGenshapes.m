%show the structure hierarchy
function showGenshapes(genshapes)

for ii =1:length(genshapes)
    recover_boxes = genshapes{ii}.boxes;
    figure(ii+101);
    axis equal;
    axis([-0.7 0.7 -0.7 0.7 -0.7 0.7]);
 
    xlabel ( '--X axis--' )
    ylabel ( '--Y axis--' )
    zlabel ( '--Z axis--' )
    hold on;
        
    view(145,-30);
    for jj = 1:size(recover_boxes,2)
        p = recover_boxes(:,jj);
        draw3DOBB(p,'r');
    end
      
end
end
