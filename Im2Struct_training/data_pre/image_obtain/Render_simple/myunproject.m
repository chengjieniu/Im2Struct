

width = 1024;
height = 1024;

depth = zeros(size(in), 'single');
for i = 1:width
    for j = 1:height
        depth(j,i) = in((height-j)*width+i);
    end
end

depth = 1-depth;

load('unpro.mat');

% f_unpro = zeros(3,3,'single');

% for i = 1:3
%     for j = 1:3
%         f_unpro((j-1)*3+i) = unpro((i-1)*3+j);
%     end
% end

t = unpro(:,1);

unpro(:,1) = unpro(:,2);

unpro(:,2) = t;

p3d = zeros(height,width,3,'single');
for winy = height:-1:1
    for winx = 1:width
        winz = depth((winx-1)*height+winy);
        if (winz>0 && winz < 1)
            p = [ winy+1,winx, winz];
            pos = p*(unpro);
            p3d(height+1-winy,winx,1) = pos(1);
            p3d(height+1-winy,winx,2) = pos(2);
            p3d(height+1-winy,winx,3) = pos(3);
        end

    end
end

x = p3d(:,:,1);
y = p3d(:,:,2);
z = p3d(:,:,3);

x = x(:);
x = x(1:10:end);

y = y(:);
y = y(1:10:end);

z = z(:);
z = z(1:10:end);



point3d = [x(:) y(:) z(:)];
plywrite('recover.ply',point3d);

