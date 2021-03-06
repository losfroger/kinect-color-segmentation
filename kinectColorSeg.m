clc;
close all;
clear all;

%% Cargar imagenes desde una función
[imgColor, imgDepth, imgLab, auxLab] = cargarImagen(false, false);

%% Generar la mascara
[u, v, ch] = size(imgColor);
imgMask = zeros(u,v);

% Usar HSV para segmentar
bwDepth = rgb2hsv(imgColor);
bwDepth = imadjust(bwDepth,[],[],1.2);

lv = 5;
channel = 2;
paredMin = 160;

th = multithresh(bwDepth(:,:,channel), lv);
imSeg = imquantize(bwDepth(:,:,channel), th); 

imgMask(imSeg > 2) = 1;

% Eliminar pared a partir de paredMin
depthTranslated = imtranslate(imgDepth ,[-8, 0],'FillValues',0);
imgMask(depthTranslated(:,:,1) > paredMin) = 0;


figure(8)
subplot(2,2,1)
imshow(imSeg, [])

subplot(2,2,2)
imshow(imgMask)

subplot(2,2,3)
imshow(imgDepth)

%% Ajustar la mascara
se = strel('diamond', 3);

imgMask = imdilate(imgMask, se);
imgMask = imfill(imgMask, 'holes');
imgMask = imerode(imgMask, se);

imgMask = bwareaopen(imgMask, 1000);
subplot(2,2,4)
imshow(imgMask)

%% Mostrar resultados
finalImg = bsxfun(@times, imgColor, cast(imgMask, 'like', imgColor));

figure(10)
imshow(imSeg, []);
imshowpair(imgColor, finalImg, 'montage')

%% Etiquetas colores
figure(11)
imshow(finalImg)
hold on;
% Las etiquetas se almacenan en colors
colors = [195 64 63; 46 64 105; 122 58 21; 36 48 40; 26, 8, 7];

% Aplicar la mascara a la imagen en cielab
finalLab = bsxfun(@times, imgLab, cast(imgMask, 'like', imgLab));
% Variable auxiliar
[u, v, ch] = size(imgColor);
auxLab = zeros(3,u*v);
for i = 1:3
	auxLab(i,:) = reshape(finalLab(:,:,i), [u*v, 1]);		
end

% Convertir a cielab
colorTransform = makecform('srgb2lab');
colorsLab = applycform(uint8(colors), colorTransform);
colorsLab  = double(colorsLab);

for i = 1:size(colors, 1)
    imgColorMask = zeros(u,v);
    % Usar el color, convertido a cielab para hacer la operación
	color_ = colorsLab(i,:);
    
    th = 0.11;

	mSeg = ((auxLab(1, :) - color_(1)).^2 + ...
			(auxLab(2, :) - color_(2)).^2 + ...
			(auxLab(3, :) - color_(3)).^2).^(1/2);
	
	imgProb = zeros(u,v);
	imgProb(:) = (mSeg)/max(mSeg);

    % Sacar la máscara
	imgColorMask(imgProb < th) = 1;
    
    % Procesar la máscara
    imgColorMask = imfill(imgColorMask, 'holes');
    se = strel('disk', 2);
    imgColorMask = imopen(imgColorMask, se);
    imgColorMask = bwareaopen(imgColorMask, 100);
    
    % Mostrar rectángulo con el nombre
    bBoxes = regionprops(imgColorMask);
    
    for index = 1:size(bBoxes, 1)
        x = ceil(bBoxes(index).Centroid(1));
        y = ceil(bBoxes(index).Centroid(2));

        rectangle('Position', bBoxes(index).BoundingBox, 'EdgeColor', colors(i,:)./255, 'LineWidth', 0.5);
        text(x, y, 'Color' + string(i), 'Color', 'w', 'HorizontalAlignment', 'center');
    end
end

%% Bounding boxes

bBoxes = regionprops(imgMask);

for index = 1:size(bBoxes, 1)
    x = ceil(bBoxes(index).Centroid(1));
    y = ceil(bBoxes(index).Centroid(2));
    
    rectangle('Position', bBoxes(index).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 3);
	plot(x, y, 'r*');
    
    dist = (double(imgDepth(y, x+8, 2)) * 4000.0) / 255.0;
    dist = dist / 10.0;
	% Mostrar texto de la distancia del punto
    txt = string(round(dist, 1)) + "cm";
    text(x, y - 10, txt, 'Color', 'white', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 12)
end
hold off;
