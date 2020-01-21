%批量读取obb文件，并经过处理将其信息保存到shapes.mat中
%labeledirname = 'F:\Grass\chair_obb_Ge_variation\chair_obb\labeled\*.obb';
%labeledirname = 'H:\0retry_cv\data\obb\*.obb';
%labeledirname='H:\0retry_cv\chair_aligned_obj_obb_200\labeled\*.obb';
labeledirname = 'C:\Users\niuchengjie\Desktop\partNet_data\airplane-labeled\obb_plane\*.obb';
labeledlist = dir(labeledirname);

%shapes= cell(1,length(labeledlist)*20);
shapes=cell(1,length(labeledlist));
for kk = 1:length(labeledlist)
%    disp(kk);
 %   labeledfilename = ['F:\Grass\chair_obb_Ge_variation\chair_obb\labeled' filesep labeledlist(kk).name];
%  labeledfilename = ['H:\0retry_cv\data\obb' filesep labeledlist(kk,1).name];
%   labeledfilename=['H:\0retry_cv\chair_aligned_obj_obb_200\labeled' filesep labeledlist(kk,1).name];
    labeledfilename = ['C:\Users\niuchengjie\Desktop\partNet_data\airplane-labeled\obb_plane' filesep labeledlist(kk,1).name];
   %filesep用于返回当前平台的目录分隔符
    fid = fopen(labeledfilename,'r');
    line = fgets(fid);
    shapes{kk}.obbname=labeledlist(kk).name;
    %将obb每个box标记的类型存入labeledindex
    while ~feof(fid)
        line = fgets(fid);
        if (~isempty(line) && line(1) == 'L')
            pids = sscanf(line, '%s %d');
            boxnum = pids(2);
            labelindex = zeros(boxnum,1);
            for ii = 1:boxnum
                line = fgets(fid);
                pids = sscanf(line, '%d');
                labelindex(ii) = pids(1);
                if (pids(1) == -1)
                    disp(labeledlist(kk).name);
                end
            end
        end
    end
    
    fclose(fid);
    
%    obbdirname = ['F:\Grass\chair_obb_Ge_variation\chair_obb\gen' filesep labeledlist(kk).name(1:end-4) '_rg*'];    
%    obblist = dir(obbdirname);

%    for kk = 1:20
 %    for kk=1:10
%        obbfilename = ['F:\Grass\chair_obb_Ge_variation\chair_obb\gen' filesep obblist(kk).name];
%        obbfilename = ['H:\0retry_cv\data\obb' filesep labeledlist(kk).name];
%        obbfilename= ['H:\0retry_cv\chair_aligned_obj_obb_200\chair_aligned_obj_obb_153' filesep labeledlist(kk).name];
        obbfilename = ['C:\Users\niuchengjie\Desktop\partNet_data\airplane-labeled\obb_plane' filesep labeledlist(kk,1).name];
        fid = fopen(obbfilename,'r');
        line = fgets(fid);
        shapes{kk}.labelindex = labelindex;
        while ~feof(fid)
            line = fgets(fid);
            if length(line) > 0
                if (line(1) == 'N')
                    pids = sscanf(line, '%s %d');
                    boxnum = pids(2);
                    boxes = zeros(15,boxnum);
                    for ii = 1:boxnum
                        line = fgets(fid);
                        pids = sscanf(line, '%f');
                        boxes(:,ii) = pids;
                        boxes(1:3,ii) = boxes(1:3,ii)/5;
                        boxes(13:15,ii) = boxes(13:15,ii)/5;
                    end
                    shapes{kk}.boxes = boxes;           
                end
                %邻接矩阵保存连接信息
                if (line(1) == 'C')
                    adj = zeros(boxnum,boxnum);
                    pids = sscanf(line, '%s %d');
                    connectnum = pids(2);
                    for ii = 1:connectnum
                        line = fgets(fid);
                        pids = sscanf(line, '%d');
                        adj(pids(1)+1,pids(2)+1) = 1;
                        adj(pids(2)+1,pids(1)+1) = 1;
                    end
                    shapes{kk}.adj = adj;
                end

                if (line(1) == 'S')
                    pids = sscanf(line, '%s %d');
                    symgroupnum = pids(2);
                    symmetryParams = struct('segIndex', cell(1,symgroupnum), 'symParams', cell(1,symgroupnum));
                    for ii = 1: symgroupnum
                        line = fgets(fid);
                        pids = sscanf(line, '%d');
                        segIndex = [];
                        centerlist = zeros(pids(1),3);
                        for jj = 1:pids(1)
                            line = fgets(fid);
                            pids = sscanf(line, '%d %f %f %f');
                            segIndex = [segIndex pids(1)+1];
                            centerlist(jj,:) = pids(2:end);
                        end
                        line = fgets(fid);
                        pids = sscanf(line, '%d');
                        symtype = pids(1);
                        symparams = zeros(1,8);
                        line = fgets(fid);
                        pids = sscanf(line, '%f');
                        symparams(5:7) = pids/5;
                        line = fgets(fid);
                        pids = sscanf(line, '%f');
                        symparams(2:4) = pids;
                        
                        [~,max_index] = max(abs(symparams(2:4)));
                        if symparams(1+max_index) < 0
                            symparams(2:4) = -symparams(2:4);
                        end
                        %旋转，点和旋转轴的朝向+symparams(8)来表示旋转的次数
                        if(symtype == 3)
                            symparams(1) = -1;
                            %为了处于一个固定的scale进行训练，所以
%                            symparams(8) = 1.0/single((2+randi(3)));
                             symparams(8) = 1.0/size(centerlist,1);
                        %对称
                        elseif (symtype == 2)
                            symparams(1) = 1;
                        %平移
                        elseif (symtype == 1)
                            symparams(1) = 0;
%                            symparams(2:4) = (centerlist(end,:)-centerlist(1,:))/5/(2+randi(5));
                            [Transmax,TransmaxIndex]=max((centerlist(end,:)-centerlist(1,:))/5/(size(centerlist,1)-1));
                            dimon=zeros(1,3);
                            dimon(TransmaxIndex)=Transmax;
                            symparams(2:4) = dimon(1:3);
                            symparams(5:7) = centerlist(end,:)/5;
                        end
                        symmetryParams(ii).segIndex = segIndex;
                        symmetryParams(ii).symParams = symparams;               
                    end
                    shapes{kk}.symmetryParams = symmetryParams;
                end
            end
        end
        fclose(fid);
        
 %   end
 %want to show failed
%showGenshapes(shapes{kk});

end  

%save H:\0retry_cv\data\shapes shapes;
%save H:\0retry_cv\chair_aligned_obj_obb_200\labeled\shapes shapes;
save shapes_plane shapes;

