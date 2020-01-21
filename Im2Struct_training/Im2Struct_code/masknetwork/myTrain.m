function myTrain(varargin)

trainOpts.id = 1;
trainOpts.useGpu = true;
trainOpts.batchSize = 16 ;
trainOpts.continue = false ;
trainOpts.gpus = 1 ;
trainOpts.prefetch = false ;
trainOpts.dataDir = '' ;
trainOpts.saveDir = '' ;
trainOpts.outputDir = '' ;
trainOpts.learningRate = 1 * ones(1,200) ;
trainOpts.clip_d = 1*ones(1,200);
trainOpts.numEpochs = 100;
trainOpts.outputN = 1;
trainOpts = vl_argparse(trainOpts, varargin) ;



trainOpts.learningRate(1,1:11)= 5;
trainOpts.learningRate(1,12:22)= 0.5;
trainOpts.learningRate(1,23:trainOpts.numEpochs)= 0.05;

% trainOpts.clip_d(1,1:1) = 0.001;
% trainOpts.clip_d(1,3:5) = 0.1;
trainOpts.clip_d(1,1:1) = 0.1;
trainOpts.clip_d(1,2:11) = 1;
trainOpts.clip_d(1,12:trainOpts.numEpochs) = 10;




%%%%%%



% -------------------------------------------------------------------------
% Train
% -------------------------------------------------------------------------
% Launch SGD
info = my_cnn_train_dag(getBatchWrapper, trainOpts) ;

% -------------------------------------------------------------------------
function fn = getBatchWrapper()
% -------------------------------------------------------------------------
fn = @(imdb,batch,mode,opts) getBatch(imdb,batch,mode,opts) ;
