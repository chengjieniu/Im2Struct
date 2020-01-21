%Ϊbox����
%load H:\0retry_cv\data\shapes.mat;
%load H:\0retry_cv\chair_aligned_obj_obb_200\labeled\shapes.mat
enhanceshapes = [];
for ii = 1:1
    enhanceshapes = [enhanceshapes shapes];
end
data = cell(1,length(enhanceshapes));
for uu =1:length(enhanceshapes)
    disp(uu);
    data{uu}.obbname=enhanceshapes{uu}.obbname;
    %pick sym box
    boxes = [];
    syms = {};
    shape = enhanceshapes{uu};
    sh_sym = shape.symmetryParams;
    sh_label = shape.labelindex;
    symtotalindex = [];
    allboxes = shape.boxes;
    
    adjIndex = cell(1,size(allboxes,2));
    symIndex = [];
    sym_label = [];
    %����ÿ���Գ��飬�ҵ��������ڵ�box
    for ii = 1:length(sh_sym)
        %�Գ��������
        segIndex = sh_sym(ii).segIndex;
        %�Գ���ĶԳƲ���
        seg_sym = sh_sym(ii).symParams;

        zvalue = zeros(1,length(segIndex));
        for jj = 1:length(segIndex)
            %����Գ����е�ÿ��box��һ�����Ĳ�����ʾ����
            zvalue(jj) = 100*shape.boxes(3,segIndex(jj))+10*shape.boxes(2,segIndex(jj))+shape.boxes(1,segIndex(jj));%0.5*shape.boxes(1,segIndex(jj));
        end
        
        %���Գ����е�����box�����Ĳ������յ���˳������box��index
        [~,sortindex] = sort(zvalue);
        segIndex = segIndex(sortindex);
        
        %��ÿ���Գ��������ĵ�һ��box��index����boxes
        boxes = [boxes shape.boxes(:,segIndex(1))];
        %��ÿ���Գ���ĶԳƲ�������syms
        syms = [syms seg_sym];
        %%��ÿ���Գ��������ĵ�һ��box��label����boxes
        sym_label = [sym_label; sh_label(segIndex(1))];
        
        %�ҵ���ÿһ�ζԳ������ڵ�box��index����adjboxid����һ���Գ��������
        adjboxid = [];
        for jj = 1:length(segIndex)
            p = find(shape.adj(segIndex(jj),:));
            adjboxid = [adjboxid p];
        end
        
        %ʹadjboxid�������ظ���Ψһ
        adjboxid = unique(adjboxid);
        
        %��adjIndex�н���ڼ����Գ������ڵĵ�box��־Ϊ��
        for jj = 1:length(adjboxid)
            adjIndex{adjboxid(jj)} = [adjIndex{adjboxid(jj)} ii];
        end
        %symIndex�洢ÿ���Գ����е�һ��box��index����Ϊ����Գ����index
        symIndex = [symIndex segIndex(1)];
        %symtotalinex�洢���Գ����˳��洢���жԳ����е�box��index
        symtotalindex = [symtotalindex segIndex];
    end
      
    %�����ڶԳ����е�box���Ϊ�գ���ɾ����box��shape.boxes�е���Ϣ
    shape.boxes(:,symtotalindex) = [];
    %�������ڶԳ����е�box��label�洢��nonsym_label��
    nonsym_label = sh_label;
    nonsym_label(symtotalindex) = [];
    %symadjIndex��¼��Գ����������Գ���ĵ�һ��box��index�����ڽӵĶԳ����˳���ţ�1,2,3��������
    symadjIndex = adjIndex(symIndex);
    %adjIndex����ǶԳ����е�box�����ڵĶԳ����˳����
    adjIndex(symtotalindex) = [];
    singleIndex = 1:size(allboxes,2);
    %singleIndex��¼�ǶԳ����е�box���
    singleIndex = setdiff(singleIndex, symtotalindex);
    
    %symmetryboxnum��¼�Գ�����Ŀ
    symmetryboxnum = length(sh_sym);
    %symmetryboxnum��¼�ǶԳ���box��Ŀ
    nonsymmetryboxnum = size(shape.boxes,2);
    %newadj�ڽӾ���Ϊ�Գ�����Ŀ�ͷǶԳ�����Ԫ�ص�box����Ŀ֮��Ϊ������
    newadj = zeros(symmetryboxnum+nonsymmetryboxnum);
    
    %��newadj�н��������ڵģ��Գ���ͷǶԳ�box����Ϊһ���ڽӾ���
    for ii = 1:symmetryboxnum
        for jj = 1:length(symadjIndex{ii})
            newadj(symadjIndex{ii}(jj),ii) = 1;
            newadj(ii,symadjIndex{ii}(jj)) = 1;
        end
        newadj(ii,ii) = 0;
    end
    
    for ii = 1:size(shape.boxes,2)
        boxes = [boxes shape.boxes(:,ii)];
        syms = [syms [1]];
        syms{end} = [];
        for jj = 1:length(adjIndex{ii})
            newadj(adjIndex{ii}(jj),symmetryboxnum+ii) = 1;
            newadj(symmetryboxnum+ii,adjIndex{ii}(jj)) = 1;
        end
        
        for jj = ii:size(shape.boxes,2)
            if (shape.adj(singleIndex(ii),singleIndex(jj)) == 1)
                newadj(symmetryboxnum+ii,symmetryboxnum+jj) = 1;
                newadj(symmetryboxnum+jj,symmetryboxnum+ii) = 1;
            end
        end
        
    end
    %final_label��¼�Գ�������label�ͷǶԳ���box��label
    final_label = [sym_label; nonsym_label];

    %boxes�洢�Գ�������box�ͷǶԳ���box�����ݣ�ǰ����Ϊ���ĵ㣬4-6Ϊy�ᡢz�ᡢx��ĳ��ȣ�
    %7-9Ϊx��ķ���10-12Ϊz��ķ���
    for ii = 1:size(boxes,2)
        newbox = boxes(:,ii);
        oldbox = boxes(:,ii);
        newbox(4:6) = boxes(13:15,ii);
        dirs = [oldbox(4:6) oldbox(7:9) oldbox(10:12)];
        for kk = 1:3
            if(dirs(3,kk) < 0)
                dirs(:,kk) = -dirs(:,kk);
            end        
        end
        lengths = newbox(4:6);
        y_list = [dirs(2,1) dirs(2,2) dirs(2,3)];
        y_list = abs(y_list);
        [~,si] = sort(y_list,'descend');
        dirs = dirs(:,si);
        if(dirs(2,1) < 0)
            dirs(:,1) = -dirs(:,1);
        end
        lengths = lengths(si);
        
        z_list = [dirs(3,2) dirs(3,3)];
        z_list = abs(z_list);
        [~,si] = sort(z_list,'descend');
        dirs(:,2:3) = dirs(:,si+1);
        if(dirs(3,2) < 0)
            dirs(:,2) = -dirs(:,2);
        end
        if(dirs(1,3) < 0)
            dirs(:,3) = -dirs(:,3);
        end
        lengths(2:3) = lengths(si+1);
        
        newbox(4:6) = lengths;
        sub_dirs = dirs(:,1:2);
        newbox(7:12) = sub_dirs(:);
        boxes(:,ii) = newbox;
    end
    boxes = boxes(1:12,:);
    
    for ii = 1:size(allboxes,2)
        newbox = allboxes(:,ii);
        oldbox = allboxes(:,ii);
        newbox(4:6) = allboxes(13:15,ii);
        dirs = [oldbox(4:6) oldbox(7:9) oldbox(10:12)];
        lengths = newbox(4:6);
        [lengths,si] = sort(lengths,'descend');
        newbox(4:6) = lengths;
        dirs = dirs(:,si);
        for kk = 1:3
            if(dirs(3,kk) < 0)
                dirs(:,kk) = -dirs(:,kk);
            end        
        end
        sub_dirs = dirs(:,1:2);
        newbox(7:12) = sub_dirs(:);
        allboxes(:,ii) = newbox;
    end
    allboxes = allboxes(1:12,:);
    %data{uu}.boxes�洢һ��ģ�͵�����boxes,����ǰ����Ϊ���ĵ㣬4-6Ϊx�ᡢy�ᡢz���
    %���ȣ����ճ��ȵݼ���˳��7-9Ϊ���ķ���10-12Ϊ�γ���ķ���
    data{uu}.boxes = allboxes;
    data{uu}.labelindex = sh_label;
    
    %����boxes(�Գ�����Ŀ+�ǶԳ�����Ŀ)�е�һ�У����ĵ��һ��ֵ���������У��Գ���������ǰ��
    %�ǶԳ��������ں󣩣���ӳ�ĶԳƲ�����labelҲҪ�ı�˳�򡣽�boxes�洢��data{uu}.symshapes.
    symboxesforsort = boxes(:,1:symmetryboxnum);
    [~,symsortindex] = sort(symboxesforsort(1,:));
    boxes(:,1:symmetryboxnum) = boxes(:,symsortindex);
    syms(1:symmetryboxnum) = syms(symsortindex);
    final_label(1:symmetryboxnum) = final_label(symsortindex);
    
    nonsymboxesforsort = boxes(:,symmetryboxnum+1:end);
    [~,nonsymsortindex] = sort(nonsymboxesforsort(1,:));
    boxes(:,symmetryboxnum+1:end) = boxes(:,nonsymsortindex+symmetryboxnum);
    syms(symmetryboxnum+1:end) = syms(nonsymsortindex+symmetryboxnum);
    final_label(symmetryboxnum+1:end) = final_label(nonsymsortindex+symmetryboxnum);
    
    data{uu}.symshapes = boxes;
    labelnum = max(final_label)+1;
    symshapenum = size(boxes,2);
    currentnodes = 1:symshapenum;
    currentlabels = final_label+1;
    randkids = [];
    count = symshapenum;
    symparams = syms;
    for ii = 1:labelnum
        
        while(numel(find(currentlabels==ii))>1)
            labelnodes = currentnodes(currentlabels == ii);
            id1 = min(labelnodes);
            len = length(labelnodes);
            if id1 > symmetryboxnum
                id1 = labelnodes(1);
            end
            
            adjparts = find(newadj(id1,:) == 1);
            labelnodes_s = intersect(adjparts, labelnodes);
            if (~isempty(labelnodes_s))               
                id2 = labelnodes_s(1);
                if (labelnodes_s(1) <= symmetryboxnum)
                    id2 = labelnodes_s(1);
                end
            else
                labelnodes_s = setdiff(labelnodes,id1);
                id2 = labelnodes_s(1);
                if (labelnodes_s(1) <= symmetryboxnum)
                    id2 = labelnodes_s(1);
                end
            end


            s1 = symparams{id1};
            s2 = symparams{id2};

            if (~isempty(s1))
                if (~isempty(s2))
                    if (s1(1)==s2(1))
                        if (s1(1)==0)
                           randkids = [randkids; [id1 0 1]];
                           symparams = [symparams [1]];
                           symparams{end} = [];
                           [currentnodes, keepindex] = setdiff(currentnodes,id1);
                           currentnodes = [currentnodes count+1];
                           currentlabels = currentlabels(keepindex);
                           currentlabels = [currentlabels; ii];
                           count = count+1;
                           newadj = [newadj zeros(size(newadj,1),1)];
                           newadj = [newadj; zeros(1,size(newadj,2))];
                           newadj(count,:) = newadj(id1,:);
                           newadj(:,count) = newadj(count,:)';
                           newadj(id1,:) = 0; 
                           newadj(:,id1) = 0;
                        end
                        if (s1(1)==-1)
                           dir_1 = s1(2:4);
                           dir_2 = s2(2:4);
                           p1 = s1(5:7);
                           p2 = s2(5:7);
                           if (abs(dot(dir_1,dir_2))>0.8)
                               randkids = [randkids; [id1 id2 0]];
                               symparams = [symparams s1];
                               [currentnodes, keepindex] = setdiff(currentnodes,[id1 id2]);
                               currentnodes = [currentnodes count+1];
                               currentlabels = currentlabels(keepindex);
                               currentlabels = [currentlabels; ii];
                               count = count+1;
                               newadj = [newadj zeros(size(newadj,1),1)];
                               newadj = [newadj; zeros(1,size(newadj,2))];
                               newadj(count,:) = newadj(id1,:) | newadj(id2,:);
                               newadj(:,count) = newadj(count,:)';
                               newadj(id1,:) = 0; 
                               newadj(id2,:) = 0;
                               newadj(:,id1) = 0;
                               newadj(:,id2) = 0;
                           else
                               randkids = [randkids; [id1 0 1]];
                               symparams = [symparams [1]];
                               symparams{end} = [];
                               [currentnodes, keepindex] = setdiff(currentnodes,id1);
                               currentnodes = [currentnodes count+1];
                               currentlabels = currentlabels(keepindex);
                               currentlabels = [currentlabels; ii];
                               count = count+1;
                               newadj = [newadj zeros(size(newadj,1),1)];
                               newadj = [newadj; zeros(1,size(newadj,2))];
                               newadj(count,:) = newadj(id1,:);
                               newadj(:,count) = newadj(count,:)';
                               newadj(id1,:) = 0; 
                               newadj(:,id1) = 0;
                           end
                        end
                        if (s1(1)==1)
                           dir_1 = s1(2:4);
                           dir_2 = s2(2:4);
                           p1 = s1(5:7);
                           p2 = s2(5:7);
                           %dot�ǵ�˵���˼�����Ϊ1��������������ƽ�мн�Ϊ0��
                           %���Ϊ0���������������н�Ϊ90�����ഹֱ
                           if (abs(dot(dir_1,dir_2))>0.8 && dot(dir_1,(p2-p1)) < 0.1)
                               randkids = [randkids; [id1 id2 0]];
                               symparams = [symparams s1];
                               [currentnodes, keepindex] = setdiff(currentnodes,[id1 id2]);
                               currentnodes = [currentnodes count+1];
                               currentlabels = currentlabels(keepindex);
                               currentlabels = [currentlabels; ii];
                               count = count+1;
                               newadj = [newadj zeros(size(newadj,1),1)];
                               newadj = [newadj; zeros(1,size(newadj,2))];
                               newadj(count,:) = newadj(id1,:) | newadj(id2,:);
                               newadj(:,count) = newadj(count,:)';
                               newadj(id1,:) = 0; 
                               newadj(id2,:) = 0;
                               newadj(:,id1) = 0;
                               newadj(:,id2) = 0;
                           else
                               randkids = [randkids; [id1 0 1]];
                               symparams = [symparams [1]];
                               symparams{end} = [];
                               [currentnodes, keepindex] = setdiff(currentnodes,id1);
                               currentnodes = [currentnodes count+1];
                               currentlabels = currentlabels(keepindex);
                               currentlabels = [currentlabels; ii];
                               count = count+1;
                               newadj = [newadj zeros(size(newadj,1),1)];
                               newadj = [newadj; zeros(1,size(newadj,2))];
                               newadj(count,:) = newadj(id1,:);
                               newadj(:,count) = newadj(count,:)';
                               newadj(id1,:) = 0; 
                               newadj(:,id1) = 0;
                           end

                        end
                    else
                       randkids = [randkids; [id1 0 1]];
                       symparams = [symparams [1]];
                       symparams{end} = [];
                       [currentnodes, keepindex] = setdiff(currentnodes,id1);
                       currentnodes = [currentnodes count+1];
                       currentlabels = currentlabels(keepindex);
                       currentlabels = [currentlabels; ii];
                       count = count+1;
                       newadj = [newadj zeros(size(newadj,1),1)];
                       newadj = [newadj; zeros(1,size(newadj,2))];
                       newadj(count,:) = newadj(id1,:);
                       newadj(:,count) = newadj(count,:)';
                       newadj(id1,:) = 0; 
                       newadj(:,id1) = 0;
                    end
                else
                   randkids = [randkids; [id1 0 1]];
                   symparams = [symparams [1]];
                   symparams{end} = [];
                   [currentnodes, keepindex] = setdiff(currentnodes,id1);
                   currentnodes = [currentnodes count+1];
                   currentlabels = currentlabels(keepindex);
                   currentlabels = [currentlabels; ii];
                   count = count+1;
                   newadj = [newadj zeros(size(newadj,1),1)];
                   newadj = [newadj; zeros(1,size(newadj,2))];
                   newadj(count,:) = newadj(id1,:);
                   newadj(:,count) = newadj(count,:)';
                   newadj(id1,:) = 0; 
                   newadj(:,id1) = 0;
                end
            else
                if (~isempty(s2))
                    randkids = [randkids; [id2 0 1]];
                    symparams = [symparams [1]];
                    symparams{end} = [];
                    [currentnodes, keepindex] = setdiff(currentnodes,id2);
                    currentnodes = [currentnodes count+1];
                    currentlabels = currentlabels(keepindex);
                    currentlabels = [currentlabels; ii];
                    count = count+1;
                    newadj = [newadj zeros(size(newadj,1),1)];
                    newadj = [newadj; zeros(1,size(newadj,2))];
                    newadj(count,:) = newadj(id2,:);
                    newadj(:,count) = newadj(count,:)';
                    newadj(id2,:) = 0;
                    newadj(:,id2) = 0;
                else
                    randkids = [randkids; [id1 id2 0]];
                    symparams = [symparams [1]];
                    symparams{end} = [];
                    [currentnodes, keepindex] = setdiff(currentnodes,[id1 id2]);
                    currentnodes = [currentnodes count+1];
                    currentlabels = currentlabels(keepindex);
                    currentlabels = [currentlabels; ii];
                    count = count+1;
                    newadj = [newadj zeros(size(newadj,1),1)];
                    newadj = [newadj; zeros(1,size(newadj,2))];
                    newadj(count,:) = newadj(id1,:) | newadj(id2,:);
                    newadj(:,count) = newadj(count,:)';
                    newadj(id1,:) = 0; 
                    newadj(id2,:) = 0;
                    newadj(:,id1) = 0;
                    newadj(:,id2) = 0;
                end
            end
        end
        
    end
    

    label_1 = currentnodes(currentlabels == 1);
    s1 = symparams{label_1};
    if (~isempty(s1))
        randkids = [randkids; [label_1 0 1]];
        symparams = [symparams [1]];
        symparams{end} = [];
        [currentnodes, keepindex] = setdiff(currentnodes,label_1);
        currentnodes = [currentnodes count+1];
        currentlabels = currentlabels(keepindex);
        currentlabels = [currentlabels; 1];
        count = count+1;
    end
    label_2 = currentnodes(currentlabels == 2);
    s1 = symparams{label_2};
    if (~isempty(s1))
        randkids = [randkids; [label_2 0 1]];
        symparams = [symparams [1]];
        symparams{end} = [];
        [currentnodes, keepindex] = setdiff(currentnodes,label_2);
        currentnodes = [currentnodes count+1];
        currentlabels = currentlabels(keepindex);
        currentlabels = [currentlabels; 2];
        count = count+1;
    end
    label_3 = currentnodes(currentlabels == 3);
    s1 = symparams{label_3};
    if (~isempty(s1))
        randkids = [randkids; [label_3 0 1]];
        symparams = [symparams [1]];
        symparams{end} = [];
        [currentnodes, keepindex] = setdiff(currentnodes,label_3);
        currentnodes = [currentnodes count+1];
        currentlabels = currentlabels(keepindex);
        currentlabels = [currentlabels; 3];
        count = count+1;
    end
    label_4 = currentnodes(currentlabels == 4);
    if (~isempty(label_4))
        s1 = symparams{label_4};
        if (~isempty(s1))
            randkids = [randkids; [label_4 0 1]];
            symparams = [symparams [1]];
            symparams{end} = [];
            [currentnodes, keepindex] = setdiff(currentnodes,label_4);
            currentnodes = [currentnodes count+1];
            currentlabels = currentlabels(keepindex);
            currentlabels = [currentlabels; 4];
            count = count+1;
        end
    end
    label_5 = currentnodes(currentlabels == 5);
    if (~isempty(label_5))
        s1 = symparams{label_5};
        if (~isempty(s1))
            randkids = [randkids; [label_5 0 1]];
            symparams = [symparams [1]];
            symparams{end} = [];
            [currentnodes, keepindex] = setdiff(currentnodes,label_5);
            currentnodes = [currentnodes count+1];
            currentlabels = currentlabels(keepindex);
            currentlabels = [currentlabels; 5];
            count = count+1;
        end
    end
    max_c_node = max(currentnodes);
    
    label_1 = currentnodes(currentlabels == 1);
    label_2 = currentnodes(currentlabels == 2);
    label_3 = currentnodes(currentlabels == 3);
    label_4 = currentnodes(currentlabels == 4);
    label_5 = currentnodes(currentlabels == 5);
    
    if (~isempty(label_5))
        randkids = [randkids; [label_1 label_5 0]];
        symparams = [symparams [1]];
        symparams{end} = [];
        
        randkids = [randkids; [max_c_node+1 label_2 0]];
        symparams = [symparams [1]];
        symparams{end} = [];
    
        randkids = [randkids; [max_c_node+2 label_3 0]];
        symparams = [symparams [1]];
        symparams{end} = [];
        
        randkids = [randkids; [max_c_node+3 label_4 0]];
        symparams = [symparams [1]];
        symparams{end} = [];
    else
        randkids = [randkids; [label_1 label_2 0]];
        symparams = [symparams [1]];
        symparams{end} = [];
        
        randkids = [randkids; [max_c_node+1 label_3 0]];
        symparams = [symparams [1]];
        symparams{end} = []; 
        
         randkids = [randkids; [max_c_node+2 label_4 0]];
        symparams = [symparams [1]];
        symparams{end} = [];   
    end

    
%     label_1 = currentnodes(currentlabels == 1);
%     label_2 = currentnodes(currentlabels == 2);
%     label_3 = currentnodes(currentlabels == 3);
%     label_4 = currentnodes(currentlabels == 4);
%     
%     randkids = [randkids; [label_2 label_3 0]];
%     symparams = [symparams [1]];
%     symparams{end} = [];
%     
%     randkids = [randkids; [max_c_node+1 label_1 0]];
%     symparams = [symparams [1]];
%     symparams{end} = [];
%     
%     if (~isempty(label_4))
%         randkids = [randkids; [max_c_node+2 label_4 0]];
%         symparams = [symparams [1]];
%         symparams{end} = [];
%     end
    [~,sl] = size(data{uu}.symshapes);
    randkids = [zeros(sl,3); randkids];
    data{uu}.treekids = randkids;
    data{uu}.symparams = symparams;
    
end
obbdata = data;
%save H:\0retry_cv\data\obbdata obbdata;
%save H:\0retry_cv\chair_aligned_obj_obb_200\labeled\obbdata obbdata;
save obbdata_plane obbdata;
% vrrotvec2mat