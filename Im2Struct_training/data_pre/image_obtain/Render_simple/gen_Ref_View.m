%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gen_Ref_View.m
% This script generate all reference views of a 3D modell on sphere
% orientation and provide the depth buffer, camera matrix and rendered image 
% Input: 3D CG file
% Output: depth buffer, each in size of 1024*1024
%         rendered image in grayscale format, 1024*1024
%         camera matrices A, R, T
% writen by Chao Yao
% Technische Universität Dresden, Germany
% Laste edited: 05.02.2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
clc

width=480;     % view size 
height=width;   
model_name='MiPOSat.osg';   % 3D CG file name
distance = 0.5;
azi_Step = 10;   % [degree]
elev_Step = azi_Step;  % [degree]
% yaw_Step = 10;  % [degree]
azi_Loop = numel(0:azi_Step:360);   % number of azimuth sample points
elev_Loop = numel(0:elev_Step:180); % number of elevation sample points
depth = zeros(height,width,azi_Loop*elev_Loop,'single');   % depth buffer: viewsize*viewnumber
rendered_Gray = zeros(height,width,azi_Loop*elev_Loop,'uint8'); % rendered view (grayscale)
Camera_A = zeros(3,3,width,azi_Loop*elev_Loop,'single'); % Camera matrix
Camera_R = zeros(3,3,width,azi_Loop*elev_Loop,'single');
Camera_T = zeros(1,3,width,azi_Loop*elev_Loop,'single');

view_Index = 1;
disp(['view size: ',num2str(width),'*',num2str(height)]);
disp(['Distance: ',num2str(distance),', Azimuth step: ',num2str(azi_Step),',  Elevation step: ',num2str(azi_Step)]);
fprintf('Generating reference views...');
for azimuth = 0:azi_Step:360
    for elevation = 0:elev_Step:180
        [depth(:,:,view_Index), rendered, unproject, Camera_A(:,:,view_Index), Camera_R(:,:,view_Index), Camera_T(:,:,view_Index)]=...
            renderer(width,height, model_name,0,0,distance,elevation,azimuth,0,'zxy');
        rendered_Gray(:,:,view_Index) = rgb2gray(rendered);
        view_Index = view_Index+1;
    end
end
disp('Generating finished!');
disp(['views number: ', num2str(azi_Loop*elev_Loop)]);