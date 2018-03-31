# Im2Struct: Recovering 3D Shape Structure from a Single RGB Image
#### Chengjie Niu, Jun Li, Kai Xu. In CVPR, 2018 
##  Guide:

Our current release has been tested on Matlab

#### 1. Download and compile MatConvNet(http://www.vlfeat.org/matconvnet/)
	run matlab/vl_setupnn;   

	vl_compilenn('enableGpu', true, ... 'cudaRoot', '/Developer/NVIDIA/CUDA-X', ... 'cudaMethod', 'nvcc');

 
#### 2. Download our pre-trained model


<https://www.dropbox.com/sh/q007g6wu4jdgakl/AABasIx1C8OucFt2pGCnXqT-a?dl=0>


#### 3. run im2struct_test.m
