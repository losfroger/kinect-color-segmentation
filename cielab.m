%% Convertir a CieLab largo (el que tenía la maestra)
ng = 255;
An = imgColor / ng;

auxLabReshape = auxLab;

% Pasar a espacio XYZ
mT = [0.412453 0.357580 0.180423;
	  0.212671 0.715160 0.072169;
	  0.019334 0.119193 0.950227];

br = [0.9504; 1.0; 1.088754];
[u, v, ch] = size(imgColor);

imAux = zeros(3, u*v);

for i = 1:3
	imren = An(:, :, i);
	imAux(i, :) = imren(:);	
end

imXYZ = mT * imAux;

for i = 1:3
	imXYZ(i,:) = imXYZ(i,:) / br(i);
end

val = (6/29)^3;
resf = zeros(3, u*v);

for i = 1:3
	resf(i, imXYZ(i,:) > val) = imXYZ(i, imXYZ(i,:) > val).^(1/3);
	resf(i, imXYZ(i,:) <= val) = ((29/6)^2).*imXYZ(i, imXYZ(i,:) <= val)./3+(4/29);
end

auxLab = zeros(3, v*u);
% Ecuaciones para obtener L,a,b
auxLab(1,:) = 116.*resf(2,:) -16;
auxLab(2,:) = 500.*(resf(1,:) - resf(2,:));
auxLab(3,:) = 200.*(resf(2,:) - resf(3,:));

imlab = zeros(u,v,3);
% Regresar la imagen a su tamaño original
for i = 1:3
	imlab(:,:,i) = reshape(auxLab(i,:), u, v);
end

%imlab = uint8(imlab);

figure(4)
subplot(2, 2, 1);
imshow(imlab);

subplot(2, 2, 2);
imshow(uint8(lab));
%imshowpair(imlab, [-128 127], uint8(lab), [0 255], 'montage');

for i = 1:3
	auxLab2(:,:,i) = reshape(auxLab(i,:), u, v);
    auxLabReshape2(:,:,i) = reshape(auxLabReshape(i,:), u, v);
end

subplot(2, 2, 3);
imshow(im2uint8(auxLab2), [-127 128]);
subplot(2, 2, 4);
imshow(uint8(auxLabReshape2));

%figure(5)
%imshowpair(uint8(auxLab2), uint8(auxLabReshape2), 'montage');