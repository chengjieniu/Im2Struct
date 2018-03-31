# Im2Struct: Recovering 3D Shape Structure from a Single RGB Image
#### Chengjie Niu, Jun Li, Kai Xu. In CVPR, 2018 
##  Guide:

#### Our current release has been tested on Matlab2015b

#### 1. Download and compile MatConvNet(http://www.vlfeat.org/matconvnet/)
	run matlab/vl_setupnn;   

	vl_compilenn('enableGpu', true, ... 'cudaRoot', '/Developer/NVIDIA/CUDA-7.5', ... 'cudaMethod', 'nvcc');

 
#### 2. Download our network model


<https://www.dropbox.com/sh/q007g6wu4jdgakl/AABasIx1C8OucFt2pGCnXqT-a?dl=0>


#### 3. run im2struct_test.m
<br>
*Note: The training code is coming soon.*
