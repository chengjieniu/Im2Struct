%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Modified by Chao Yao
%  compile the C++ code  to .mexw64 file to use in matlab 2013a 64bit
%  make sure that your OpensceneGraph is x64 version and can run successfully
%  edit the libpath and incpath to your OSG installation directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% clc
cmd1='mex -O -largeArrayDims -DA64BITS renderer.cpp depth.cpp Engine.cpp EngineOSG.cpp util.cpp -lOpenGL32 -lglu32 -losg -losgViewer -losgDB -losgGA -losgUtil -lOpenThreads';

%libpath=fullfile('E:\Depth_Project\Single_Object\code\OSG\OpenSceneGraph-3.0.1','lib');
%incpath=fullfile('E:\Depth_Project\Single_Object\code\OSG\OpenSceneGraph-3.0.1','include');

cmd=[cmd1 sprintf(' -L%s -I%s',libpath,incpath)];

disp('Executing:');
fprintf('%s\n',cmd);
eval(cmd);
