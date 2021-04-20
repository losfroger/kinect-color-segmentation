clc;
close all;
clear all;

% Visualizar el video de la camara y el sensor de profundidad del kinect

colorVid = videoinput('kinect', 1);
irVid = videoinput('kinect', 1, 'Infrared_640x480');
depthVid = videoinput('kinect', 2);

%colorVid.FramesPerTrigger = 1;
depthVid.FramesPerTrigger = 1;
irVid.FramesPerTrigger = 1;

preview(colorVid);
preview(depthVid);
%preview(irVid);

stop([colorVid depthVid irVid]);
