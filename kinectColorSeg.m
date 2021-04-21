%% Generar la mascara
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