% Regresa las imagenes a color, profundidad y en cielab. Ya rectificadas
function [imgColor, imgDepth, imgLab, auxLab] = cargarImagen(kinect, saveImg)

if kinect == true
	%% Capturar imagen desde el kinect
	colorVid = videoinput('kinect', 1);
	depthVid = videoinput('kinect', 2);
	
	colorVid.FramesPerTrigger = 1;
	depthVid.FramesPerTrigger = 1;
	
	triggerconfig([colorVid depthVid], 'manual');
	
	start([colorVid depthVid]);
	
	% el for solo es por si se quiere capturar mas de una imagen
	for i = 1:1
		trigger([colorVid depthVid])
		% la imagen a color se guarda en imgColor
		[imgColor, ta_color, metaData_Color] = getdata(colorVid);
		% la imagen de profundidad se guarda en imgDepth y la versión
		% sin procesar en imgDepthRaw
		[imgDepthRaw, ta_depth, metaData_Depth] = getdata(depthVid);
	end
	
	stop([colorVid depthVid]);
	
	% Convertir imagen de profundidad en uint8
	imgDepth = mat2gray(imgDepthRaw, [0 4000]);
	imgDepth = imgDepth.*255;
	imgDepth = uint8(imgDepth);

	%% Guardar imagen en el kinect
	if saveImg == true
		imwrite(imgColor, "imageKinect.png");
		imwrite(imgDepth, "imageDepthKinect.png");
	end

else
	%% Cargar imagenes desde los archivos
	imgColor = imread("imageKinect.png");
	imgDepth = imread("imageDepthKinect.png");
end

%% Rectificar imagen
% Es necesario hacer que la imagen de profundidad sea de tres dimensiones
% para poder hacer la rectificación
load('stereoParams.mat')
imgDepth = cat(3, imgDepth, imgDepth, imgDepth);

% Rectificar las imagenes usando la calibracion
[imgColor, imgDepth] = rectifyStereoImages(imgColor, imgDepth, stereoParams);

%% Convertir en cielab
colorTransform = makecform('srgb2lab');
imgLab = applycform(imgColor, colorTransform);
imgLab = double(imgLab);

% Variable auxiliar
auxLab = zeros(3,u*v);
for i = 1:3
	auxLab(i,:) = reshape(imgLab(:,:,i), [u*v, 1]);		
end

end
