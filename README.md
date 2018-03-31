# Im2Struct: Recovering 3D Shape Structure from a Single RGB Image
#### Chengjie Niu, Jun Li, Kai Xu. In CVPR, 2018 
This repository contains the pre-trained models and testing code for paper [Im2Struct: Recovering 3D Shape Structure from a Single RGB Image](https://kevinkaixu.net/papers/niu_cvpr18_im2struct.pdf).

   
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

Our current release has been tested on Matlab 2015b

#### 1. Download and compile MatConvNet(http://www.vlfeat.org/matconvnet/)
	run matlab/vl_setupnn;   

	vl_compilenn('enableGpu', true, ... 
		     'cudaRoot', '/Developer/NVIDIA/CUDA-X.X', ... 
		     'cudaMethod', 'nvcc');

 
#### 2. Download our pre-trained model



#### 3. run im2struct_demo.m
Use im2struct_demo.m to recover 3D shape structure from an single RGB image with our pre-trained model. The recovered 3D shape structures can be visulized in Matlab.

The recovered 3D shape structures for example images(data/example_1/2/3.jpg) should look as follows:  
![Alt text](https://github.com/chengjieniu/Im2Struct/raw/master/image_show/1.png)
![Alt text](https://github.com/chengjieniu/Im2Struct/raw/master/image_show/2.png)
![Alt text](https://github.com/chengjieniu/Im2Struct/raw/master/image_show/3.png)
  
  


