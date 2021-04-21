clc;
close all;
clear all;

%% Cargar imagenes desde una función
[imgColor, imgDepth, imgLab] = cargarImagen(false, false);

%% Generar la mascara
[u, v, ch] = size(imgColor);
imgMask = zeros(u,v);

bwDepth = rgb2hsv(imgColor);
bwDepth = imadjust(bwDepth,[],[],1.2);

%se = strel('disk',50);
%bwDepth = imtophat(bwDepth, se);
lv = 5;
channel = 2;

th = multithresh(bwDepth(:,:,channel), lv);
imSeg = imquantize(bwDepth(:,:,channel), th); 

imgMask(imSeg > 2) = 1;

figure(8)
subplot(1,2,1)
imshow(imSeg, [])
subplot(1,2,2)
imshow(imgMask)


%% Ajustar la mascara
se = strel('disk', 2);

imgMask = imdilate(imgMask, se);
imgMask = imfill(imgMask, 'holes');
imgMask = imerode(imgMask, se);

imgMask = bwareaopen(imgMask, 1000);

%imgMask = imtranslate(imgMask ,[-8, 0],'FillValues',0);

%% Mostrar resultados
finalImg = bsxfun(@times, imgColor, cast(imgMask, 'like', imgColor));

figure(10)
imshow(imSeg, []);
imshowpair(imgColor, finalImg, 'montage')

%% Bounding boxes

bBoxes = regionprops(imgMask);
figure(11)
imshow(finalImg)
hold on;

for index = 1:size(bBoxes, 1)
    x = ceil(bBoxes(index).Centroid(1));
    y = ceil(bBoxes(index).Centroid(2));
    
    rectangle('Position', bBoxes(index).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 3);
	plot(x, y, 'r*');
    
    dist = (double(imgDepth(y, x+8, 2)) * 4000.0) / 255.0;
    dist = dist / 10.0;
	% Mostrar texto de la distancia del punto
    txt = string(round(dist, 1)) + "cm";
    text(x + 5, y, txt, 'Color', 'white')
end

hold off;