MATLAB mesh renderer code for Windows 
------------------------------------
In this package you will find the source code of a C++ mesh renderer to be used from MATLAB (mex file) using OpenSceneGraph
This renders textured 3D models (standard 3D file formats), using either sphere orientation (elevation , azimuth, and yaw) or camera matrix. 
Its output includes a rendered view of the textured model and its corresponding depth-map (inverse depth at each pixel). In addition, it provides an 'unproject' matrix which associates each pixel with the coordinates the 3D surface point projected onto that pixel.  
The result is not rendered on screen but returned to MATLAB as a matrix or saved directly to file. This makes the program suitable to be used either from a regular MATLAB session or from a console versions of MATLAB. It is also usefull in batch mode, in order to process many views / models directly from MATLAB.
OpenGL is used as the backend. 

Its key features include:

    Reads standard 3D CG file formats into MATLAB (.obj, .3ds, etc.)
    Camera control using sphere orientation (elevation , azimuth, and yaw) or camera matrix
    Results rendered off-screen and returned as MATLAB matrices. It is therefore suitable for console versions of MATLAB, as well as batch processing of many views / models
    Outputs depth map (inverse depth at each pixel) along with rendered views; can be used with the MATLAB 'surf' function.
    Outputs an 'unproject' matrix, linking each pixel with the coordinates the 3D surface point projected onto that pixel; it is therefore ideal for calibration / pose estimation using a 3D model as reference.
    Along with the 'calib' function, can be used to compute pose from 2D-3D correspondences, and pose-adjust models to images (see below)
    3D model caching - repeated rendering of the same model automatically use cached data and do not involve re-loading / reading the CG file


This code was developed by Liav Assif and Tal Hassner, modified by Chao Yao, and was used in the following papers: 

T. Hassner, Viewing Real-World Faces in 3D, International Conference on Computer Vision (ICCV), Sydney, Austraila, Dec. 2013
T. Hassner, L. Assif, and L. Wolf, When Standard RANSAC is Not Enough: Cross-Media Visual Matching with Hypothesis Relevancy, Machine Vision and Applications (MVAP), Volume 25, Issue 4, Page 971-983, 2014

Copyright 2015, Liav Assif Tal Hassner

QUICK START GUIDE
---------------------
Note: this version is only for Windows, for the linux version please refer to http://www.openu.ac.il/home/hassner/projects/poses/.
1. Download the Windows version of the programm. 
2. extract the file. A pre-build mexw64 file is provided, first try to directly use this one. If a rebuild must be done, follow step3 and step4.
3. Edit compile_rederer.m, add the OSG installation path on your computer.
   Note: to compile the programm, make sure that you have the right version of OpensceneGraph, x64 version for Matlab 64 bit and x86 version for Matlab 32bit.
4. Run the script "compile_rederer.m".
5. Try the script "Demo", Matlab should display the result of the provided example mesh on screen.

Read the following sections and refer to the FAQ if something goes wrong.    

INSTALLATION
---------------
The code was tested on MATLAB releases 2013a on Windows 7 64bit platform. 

The code depends on:
1. OpenSceneGraph, a high performance 3D graphics toolkit
http://www.openscenegraph.org/

2. OpenSceneGraph depends on the Coin3D library for several of its 3D formats. Some distributions of OpenSceneGraph might already contain Coin3D internally.
http://www.coin3d.org

3. OpenGL. Please make sure pbuffer support is compiled in the OpenGL implementation used. On Linux the Mesa (software) OpenGL implementation was used:
The Mesa 3D Graphics Library. An open-source implementation of the OpenGL specification.
http://www.mesa3d.org

Any use of this code must respect their respective licenses.

COMPILATION
---------------  
A pre-compiled version of the mex file, renderer.mexw64 is already provided for Windows 64-bit. It is best to try to use it first. Please refer to the FAQ section for troubleshooting.
However, in case it is needed to be compiled again using MATLAB's 'mex', the library path to the dependent libraries can be provided using -L switch.


USAGE
-------
The supported mesh files are the formats supported by OpenSceneGraph. While standard mesh files (e.g. .3DS, .WRL, .OBJ.) can be loaded by the renderer, best results are achieved by first exporting the mesh files to COLLADA DOM (using some external utilities) and then using OpenSceneGraph utilities (osgconv) to convert to its native .OSG format. Once this is done, the resulting .OSG file can be used by the renderer as well.

An example mesh file, example.wrl, is provided for demonstration. It is public domain and originally from http://3dprint.nih.gov/discover/3dpx-000013


Usage (from MATLAB) - running renderer without any argument shows the following help:
	[depth_image, rendered_image, unproject, out_A, out_R, out_T]
	= renderer(width, height, filename, writefiles, lighting, sphere orientation (5 arguments)/camera orientation (3 arguments))
Most input and output parameters are optional.
width and height should be unsigned integers.
filename - the input mesh filename.
writefiles can be 0 (disabled, the default) or 1 (outputs depth image: depth.pgm and the rendered image: rendered.png).
	Preferably it should be disabled (0) and the output depth and rendered parameters can be further processed by MATLAB.
lighting should be 0 (disabled) or 1 (enabled).
sphere orientation are the following 5 arguments: distance, elevation , azimuth, yaw and degree order.
	distance - a number added to the (auto calculated) model's bounding sphere radius. 0 is usually suitable.
	elevation, azimuth and yaw are degrees. The camera position on the bounding sphere is specified using them.
	degree order - a string specifying the order, e.g. 'xyz, 'zxy' etc.
camera orientation are 3 arguments: A (intrinsic matrix), R and T (extrinsic)


Examples:
renderer(300,300,'example.wrl');
	Performs the rendering. However, since no output parameters were passed nothing is returned.
renderer(300,300,'example.wrl',1);
	Performs the rendering and writes data files (depth.pgm and rendered.png). Note that this is _not_ the preferred way of usage.
[depth, rendered]=renderer(300, 300, 'example.wrl');
	Returns the depth matrix and rendered image to MATLAB. No output files are written. This is the preferred usage.
figure, imshow(depth); figure, imshow(rendered);
	Displays the results.
[depth, rendered, unproject, A, R, T]=renderer(300, 300, 'example.wrl');
	Also returns the camera matrices - A,R and T as well as the unprojection matrix.
	Now 'unproject(125,149,1:3)' returns the world XYZ coordinate of the image point (x=148,y=124)
[depth, rendered, unproject, A, R, T]=renderer(300, 300, 'example.wrl',0,0,0.5,10,20,30,'zxy');
	Renders the mesh with a distance of 0.5, an elevation of 10 degrees, azimuth of 20 degrees and yaw of 30 degrees.
[depth, rendered, unproject]=renderer(300, 300, 'example.wrl',0,0,A,R,T);
	Providing the camera matrices returned from the previous example will yield the same results.
Animation example:
	for yaw=0:10:360
		[~, rendered]=renderer(300, 300, 'example.wrl',0,0,0.5,10,20,yaw,'zxy'); 
		figure(1); imshow(rendered); pause;
	end
	Rotate in-plane by varying the yaw parameter. Each pressed key shows another frame of the animation
    
    
F.A.Q
-------
Q: Is there a simple usage example?
A: Yes. See demo.m for several. Most of the code snipsets below are taken from it.

Q: I'm getting the following message: "Warning: Could not find plugin to read objects from file "file.obj". ??? Error using ==> renderer Error: could not process file: file.obj"
A: 3D file handling is performed by OpenSceneGraph plugins. Similarly to the first question, make sure that <OSG_ROOT>/lib/osgPlugins-2.8.1/ is in the environment variable. Another
and easy solution is transfer the 3D file to .osg format with 3rd party toolkit.

Q: I'm getting the zlibd1.dll missing error, how to fix it?
A: 3rd party dependencies are provided by Openscenegraph, It seems that zlibd1.dll was not correctly linked during building process. copy the file zlibd1.dll and zlib1.dll to <OSG_ROOT>/bin, so that the programm can find it.
 
Q: How do I know if the 3D file I have is supported?
A: OpenSceneGraph has several binary utilities (which can be obtained from their site or any Linux distribution). One of them is 'osgviewer'. From the command line try for example:
$ osgviewer /path/to/myfile.3ds
and see if it is displayed on screen. If the format is not supported by OpenSceneGraph, it cannot be used by renderer as well.
In case you have the binaries installed, it is usually a good idea to always try it on the 3D file before reporting any problems with the renderer.

Q: Is there anything I can do if the 3D file I have is not supported?
A: You can try to export it to one of the supported formats using an external utility. 

Q: I have a complex/large 3D file which is not rendered correctly (even when using OSG's osgviewer binary)
A: OpenSceneGraph has a binary named 'osgconv' which can be used to convert between some of its supported formats. This might help in some cases. Exporting the file to COLLADA DOM (using some external utilities) and then using 'osgconv' in order to convert to its native .OSG format seems to work well for heavily textured and large 3D files (Google sketchup files etc.).

Q: Does the renderer access the filesystem whenever I call it?
A: There is a model cache, hence repeated rendering of the same 3D model automatically uses cached data and do not involve re-loading / reading the CG file or textures.

Q: After I obtain the intrinsic and extrinsic camera matrices, can I re-render the mesh using a different image size?
A: Yes. Simply edit the intrinsic matrix for the new size. e.g
    >> [~, rendered, ~, A, R, T]=renderer(300, 300, 'example.wrl');
    >> new_width=610; new_height=914;
    >> A(1:2,3)=[new_width/2;new_height/2];
    >> [~, rendered_new]=renderer(new_width, new_height, 'example.wrl',0,0,A,R,T);
    >> imshow(rendered_new)

Q: After I obtain the intrinsic and extrinsic camera matrices, can I post-process them (e.g. rotate/translate the model)?
A: Of-course. For example the rotation animation example from the help usage can also be performed as:
    >> [~, rendered, ~, A, R, T]=renderer(300, 300, 'example.wrl');
    >> for yaw=deg2rad(0:10:360)
    >>      dcm = angle2dcm(-yaw, 0, 0);
    >>      [tmp, rendered]=renderer(300, 300, 'example.wrl',0,0,A,dcm*R,T);
    >>      figure(1); imshow(rendered); pause;
    >> end

Q: I get strange calibration results when using doCalib()
A: Note that calibration must use the same width and height parameters of the original rendering. If you intend to re-render the model using  a different size it should be done after the calibration.

Q: I've added all the libraries folders using addpath() but I still get runtime errors.
A: MATLAB's search path is irrelevant to the libraries path. You do not need to add them using addpath. 

Q: I'm getting some strange rendering results.
A: Verify that you are using either sphere orientation (5 arguments) or camera orientation (3 arguments). They cannot be mixed.

Q: What are the values in the depth buffer? How do I find the z-value of a certain pixel?
A: The renderer returns 1 - depth (not 1/depth) of the OpenGL depth buffer. A value of 1 in OpenGL depth (meaning 0 in the depth matrix the renderer returns) corresponds to the far clipping plane, and a value of 0 (1 in the renderer depth) is the near clipping plane. However values in between are not linear (meaning a values of 0.5 does not mean it is exactly in the middle between the two clipping planes). In general it indeed corresponds to the distance from the camera. You can read more about it in OpenGL references. The renderer uses OpenSceneGraph auto-calculation of the near and far clipping planes.
You can use v_p=A*[R T']*v where [v;1] is a a vector from the returned unproject matrix. The value of v_p(3) should correspond to the z value.
 
Q: Can I view the 3D points of the model?
A: Yes. Use either
    >> surf(unproject(:,:,1),unproject(:,:,2),unproject(:,:,3));
    or
    >> plot3(unproject(:,:,1),unproject(:,:,2),unproject(:,:,3),'.');
    
Q: Can you provide a simple example of pose estimation:
A. Please look at the web page for an example. Here's another one. Assuming you are trying to fit a 2D texture/image to the 3D model:
    >> width=300; height=width;
    >> [depth, rendered, unproject, A, R, T]=renderer(width, height, 'model.wrl');
    >> texture=imresize(your_texture,[height width]);
    Next, annotate m points (landmarks) from 'texture' (2D points) into pts_2D (m by 2 matrix) and 'unproject' (3D points) into pts_3D (m by 3 matrix). 
    >> [A,R,T]=doCalib(width,height,pts_2D,pts_3D,A,R,T);
    >> [~, rendered_new]=renderer(width, height, 'model.wrl',0,0,A,R,T);
    >> imshow(rendered_new);

Q: I have some 2D and 3D correspondences. However I'm getting unusable A,R and T matrices from doCalib() with very high values
A: Most likely the 2D points are not in the same space as the renderer image output. The image your are trying to fit (and collect 2D points from) should have the same size as the rendered image. So should be the width and height arguments (for the renderer() and doCalib() functions).
    
Q: I'm getting "Error: OGL modelview is different than OSG's. Either OGL modelview is the identity matrix or could not calculate the model transformations matrix." 
A: It is usually caused by invalid camera matrices. renderer does not accept any arbitrary A, R and T matrices. It is best to first obtain  the intrinsic and extrinsic camera matrices from renderer, post process them if needed and then supply them as arguments when re-rendering. 

Q: I have a projection matrix P=A*[R T]. I've manually decomposed it into A, R and T. However I cannot use these in renderer.
A: See the above question. Since the decomposition is not unique, it is most likely different than what renderer expects as arguments. For example A(1:2,3) should be equal to half of the image size (width and height). It is best to first obtain the intrinsic and extrinsic camera matrices from renderer, post process them if needed and then supply them as arguments when re-rendering. 

Q: The rendered image seems to be matte
A: Try switching the lighting (fifth) argument on and off.
