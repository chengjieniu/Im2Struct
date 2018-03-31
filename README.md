# Im2Struct
##  Guide:

#### Our current release has been tested on Matlab2015b

#### 1. Download and compile MatConvNet(http://www.vlfeat.org/matconvnet/)
	run matlab/vl_setupnn;   

	vl_compilenn('enableGpu', true, ... 'cudaRoot', '/Developer/NVIDIA/CUDA-7.5', ... 'cudaMethod', 'nvcc');

 
#### 2. Download our network model


<https://www.dropbox.com/sh/q007g6wu4jdgakl/AABasIx1C8OucFt2pGCnXqT-a?dl=0>


#### 3. run im2struct_test.m
