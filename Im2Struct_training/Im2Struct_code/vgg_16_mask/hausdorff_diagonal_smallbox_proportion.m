function hausdorff_diagonal_smallbox_proportion
load('D:\eval_vgg_data\vgg_16_mask\ld_rec_gt_train');
load('D:\eval_vgg_data\vgg_16_mask\ld_rec_gt_test');
load('D:\eval_vgg_data\vgg_16_mask\ld_gt_rec_train');
load('D:\eval_vgg_data\vgg_16_mask\ld_gt_rec_test');

prop=0.1;

switch prop
    case 0.2
        proportion=0.2;
    case 0.15
        proportion=0.15;
    case 0.1
        proportion=0.1;
end
    ld_train_tem1=(ld_rec_gt_train<proportion);
    ld_test_tem1=(ld_rec_gt_test<proportion);

    ld_rec_gt_train1=sum(ld_train_tem1(:))/length(ld_rec_gt_train);
    ld_rec_gt_test1=sum(ld_test_tem1(:))/length(ld_rec_gt_test);

    ld_train_tem3=(ld_gt_rec_train<proportion);
    ld_test_tem3=(ld_gt_rec_test<proportion);

    ld_gt_rec_train3=sum(ld_train_tem3(:))/length(ld_gt_rec_train);
    ld_gt_rec_test3=sum(ld_test_tem3(:))/length(ld_gt_rec_test);

    
end