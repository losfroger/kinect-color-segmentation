clc;
close all;
clear all;

%% Cargar imagenes desde una función
[imgColor, imgDepth, imgLab, auxLab] = cargarImagen(false, false);

figure(1)
imshow(imgColor);

%% Conseguir coordenada del click
% np = numero de clicks
np = 4;
[x, y] = ginput(np);

x = round(x);
y = round(y);

%% Segmentacion de varios colores

p_c = zeros(2, np);
[u, v, ch] = size(imgColor);

% Segmentacion
imgMask = zeros(u,v);

figure(2)
% Usar tight_subplot para que las graficas queden mas juntas
ha = tight_subplot(ceil(np/2), 2, 0.01, 0.01, 0.01);

for k = 1:np
	% Sacar valor de color a segmentar
	lab_ref = [imgLab(y(k), x(k), 1); imgLab(y(k), x(k), 2); imgLab(y(k), x(k), 3)];
	th = 0.11;

	mSeg = ((auxLab(1, :) - lab_ref(1)).^2 + ...
			(auxLab(2, :) - lab_ref(2)).^2 + ...
			(auxLab(3, :) - lab_ref(3)).^2).^(1/2);
	
	imgProb = zeros(u,v);
	imgProb(:) = (mSeg)/max(mSeg);

	imgMask(imgProb < th) = 1;
    
	% Mostrar las imagenes de probabilidad con la posición en donde se dio el click
    axes(ha(k));
    %subplot(ceil(np/2), 2, k);
    hold on;
    
    imshow(imgProb);
    plot(x(k), y(k), 'ro', 'MarkerSize', 5);
    
    hold off;
end

%% Mostrar resultados
figure(3)
ha = tight_subplot(2, 2, 0.05, 0.05, 0.05);
%subplot(2,2,1);
axes(ha(1));
imshow(imgMask);
title('Mascara');

imgMask = imfill(imgMask, 'holes');
se = strel('disk', 2);
imgMask = imopen(imgMask, se);
imgMask = bwareaopen(imgMask, 500);

%subplot(2,2,2);
axes(ha(2));
imshow(imgMask);
title('Mascara despues de ser procesada');

finalImg = bsxfun(@times, imgColor, cast(imgMask, 'like', imgColor));

%subplot(2,2,3);
axes(ha(3));
imshow(finalImg);
title('Imagen final');

figure(5);
ha = tight_subplot(1, 2, 0.05, 0.05, 0.05);
axes(ha(1))
hold on;
imshow(imgColor);
for i = 1:np
	% Mostrar punto de donde se hizo click
    plot(x(i), y(i), 'ro', 'MarkerSize', 5);
    % Distancia en mm, luego convertida a cm
	% Nota: Se le debe de sumar 8 a x, porque el sensor de profundidad
	% siempre tiene una franja vacia de pixeles del lado izquierdo
    dist = (double(imgDepth(y(i), x(i)+8, 1)) * 4000.0) / 255.0;
    dist = dist / 10.0;
	% Mostrar texto de la distancia del punto
    txt = string(round(dist, 1)) + "cm";
    text(x(i) + 5, y(i), txt, 'Color', 'white')
end
title('Imagen final, con los puntos y sus distancias')
hold off;

axes(ha(2))
hold on;
imshow(imgDepth);
for i = 1:np
	% Mostrar punto de donde se hizo click
    plot(x(i)+8, y(i), 'ro', 'MarkerSize', 5);
    % Distancia en mm, luego convertida a cm
	% Nota: Se le debe de sumar 8 a x, porque el sensor de profundidad
	% siempre tiene una franja vacia de pixeles del lado izquierdo
    dist = (double(imgDepth(y(i), x(i)+8, 1)) * 4000.0) / 255.0;
    dist = dist / 10.0;
	% Mostrar texto de la distancia del punto
    txt = string(round(dist, 1)) + "cm";
    %text(x(i) + 5, y(i), txt, 'Color', 'white')
end
title('Imagen profundidad, con los puntos y sus distancias')
hold off;
