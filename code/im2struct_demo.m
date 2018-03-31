function im2struct_demo
%%
%test the Im2Struct network
%input an image
%the result will be showed in figure

%load structure masking network and recursive structure recovery network
load('model\net_m.mat');
net_m=dagnn.DagNN.loadobj(net_m);
net_m.mode = 'test';
load('model\net_v.mat');
net_v=dagnn.DagNN.loadobj(net_v);
vae_theta=net_v.meta.vae_theta;
net_v.mode = 'test';

% load and preprocess an example image
im=imread('data\example_3.jpg');
im_ = single(im) ; % note: 0-255 range
im_ = imresize(im_, [224 224]) ;
im_ = bsxfun(@minus, im_, net_m.meta.normalization.averageImage) ;
im_ = gpuArray(im_);

%get the feature map of the maskingnetwork
inputs = {'input', im_, 'input2', im_} ;
net_m.eval(inputs);
mask_feature = net_m.vars(net_m.getVarIndex('feature')).value;

%get the 80D fused feature
inputs_v={'input', inputs{2}, 'input2', mask_feature};
net_v.eval(inputs_v);
res=net_v.vars(net_v.getVarIndex('prediction')).value;
feature=gather(squeeze(res));

%decode the fused feature recursively into a box structure
WdecoS1Left = vae_theta.WdecoS1Left; WdecoS1Right = vae_theta.WdecoS1Right; WdecoS2 = vae_theta.WdecoS2;
WsymdecoS1 = vae_theta.WsymdecoS1; WsymdecoS2 = vae_theta.WsymdecoS2;
WdecoBox = vae_theta.WdecoBox;
bdecoS1Left = vae_theta.bdecoS1Left; bdecoS1Right = vae_theta.bdecoS1Right; bdecoS2 = vae_theta.bdecoS2;
bsymdecoS1 = vae_theta.bsymdecoS1; bsymdecoS2 = vae_theta.bsymdecoS2;
bdecoBox = vae_theta.bdecoBox;
Wcat1 = vae_theta.Wcat1; bcat1 = vae_theta.bcat1;
Wcat2 = vae_theta.Wcat2; bcat2 = vae_theta.bcat2;

f = @norm1tanh;

num = 1;
genShapes = cell(1,1);
for ii = 1:num
    %generate the shapes
    count = 1;
    features = gather(feature(:,ii));

    symlist = 10*ones(8,1);
    while (size(features,2))
        p = double(features(:,1));
        sfm = f(Wcat1*p+bcat1);
        sm = softmax(Wcat2*sfm + bcat2);
        [~,l_index] = max(sm);
        if(l_index == 1)
            re_box = f(WdecoBox*p+bdecoBox);
            genShapes{ii}.boxes(:,count) = re_box;
            count = count+1;
            symfeature = symlist(:,1);
            if (abs(symfeature(1)+1) < 0.15 )
                folds = uint8(1/symfeature(8));
                newbox = re_box;
                symfeature(2:4) = symfeature(2:4)/norm(symfeature(2:4));
                for kk = 1:folds-1
                    rotvector = [symfeature(2:4); symfeature(8)*2*pi*single(kk)];
                    rotm = vrrotvec2mat(rotvector);
                    center = re_box(1:3);
                    dir_1 = re_box(7:9);
                    dir_2 = re_box(10:12);
                    newcenter = rotm*(center-symfeature(5:7))+symfeature(5:7);
                    newbox(1:3) = newcenter;
                    newbox(7:9) = rotm*dir_1;
                    newbox(10:12) = rotm*dir_2;
                    genShapes{ii}.boxes(:,count) = newbox;
                    count = count+1;
                end
            end
            if (abs(symfeature(1)) < 0.25 )
                trans = symfeature(2:4);
                trans_end = symfeature(5:7);
                center = re_box(1:3);
                [Transmax,TransmaxIndex]=max(abs(trans));
                dimon=zeros(1,3)';
                dimon(TransmaxIndex)=trans(TransmaxIndex);
                trans_length=Transmax;
                trans_total = sqrt(sum(trans_end-center).^2);
                folds = trans_total/trans_length;
                for kk = 1:folds
                    newbox = re_box;                   
                    newcenter=center+dimon*single(kk);
                    newbox(1:3) = newcenter;
                    genShapes{ii}.boxes(:,count) = newbox;
                    count = count+1;
                end
            end
            if (abs(symfeature(1)-1) < 0.15 )
                ref_normal = symfeature(2:4);
                ref_normal = ref_normal/norm(ref_normal);
                ref_point = symfeature(5:7); 
                newbox = re_box;
                center = re_box(1:3);
                if (dot(ref_normal, ref_point-center) < 0)
                    ref_normal = -ref_normal;
                end

                newcenter = abs(sum((ref_point-center).*ref_normal))*ref_normal*2+center;
                newbox(1:3) = newcenter;
                dir_1 = re_box(7:9);
                if (dot(ref_normal, dir_1) > 0)
                    ref_normal = -ref_normal;
                end
                newbox(7:9) = dir_1 - 2*dot(dir_1, ref_normal)*ref_normal;
                dir_2 = re_box(10:12);
                if (dot(ref_normal, dir_2) > 0)
                    ref_normal = -ref_normal;
                end                
                newbox(10:12) = dir_2 - 2*dot(dir_2, ref_normal)*ref_normal;
                           
                genShapes{ii}.boxes(:,count) = newbox;
                count = count+1;

            end
            symlist(:,1) = [];
            features(:,1) = [];
        else
            if (l_index == 3)
                ym = f(WsymdecoS2*p + bsymdecoS2);
                yp = f(WsymdecoS1*ym + bsymdecoS1);               
                y1 = yp(1:end-8);
                features(:,1) = [];
                features = [features y1];
                symfeature = yp(end-7:end);
                symlist(:,1) = [];
                symlist = [symlist symfeature];               
            else
                if(l_index == 2)
                    ym = f(WdecoS2*p + bdecoS2);
                    y1 = f(WdecoS1Left*ym + bdecoS1Left);
                    y2 = f(WdecoS1Right*ym + bdecoS1Right);
                    features(:,1) = [];
                    features = [features y1 y2];
                    symlist = [symlist symlist(:,1) symlist(:,1)];
                    symlist(:,1) = [];
                end
            end
            
        end
    end    
end
%show the result in figure
showGenshapes(genShapes);
end
