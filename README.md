# Im2Struct: Recovering 3D Shape Structure from a Single RGB Image
#### Chengjie Niu, Jun Li, Kai Xu. In CVPR, 2018 
This repository contains the pre-trained models and testing code for Recovering 3D Shape Structure from a Single RGB Image.

   
## Citation
If you find our work useful in your research, please consider citing:  

> @inProceedings{niu_cvpr18,  
>   	title={Im2Struct: Recovering 3D Shape Structure from a Single RGB Image},  
>   	author = {Chengjie Niu  
>   	and Jun Li  
>   	and Kai Xu},  
>   	booktitle={Computer Vision and Pattern Regognition (CVPR)},   
>   	year={2018}  
> }

##  Guide:

Our current release has been tested on Matlab

#### 1. Download and compile MatConvNet(http://www.vlfeat.org/matconvnet/)
	run matlab/vl_setupnn;   

	vl_compilenn('enableGpu', true, ... 
		     'cudaRoot', '/Developer/NVIDIA/CUDA-X.X', ... 
		     'cudaMethod', 'nvcc');

 
#### 2. Download our pre-trained model


<https://www.dropbox.com/sh/q007g6wu4jdgakl/AABasIx1C8OucFt2pGCnXqT-a?dl=0>


#### 3. run im2struct_demo.m
Use im2struct_demo.m to generate 3D shape structure based on trained model. The input is an image, the output of 3D shape structure is showed in figure.


