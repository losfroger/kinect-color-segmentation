%% Generar la mascara
imgMask = zeros(u,v);

lv = 4;
bwDepth = rgb2gray(imgColor);
bwDepth = imadjust(bwDepth,[],[],0.5);

%se = strel('disk',50);

%bwDepth = imtophat(bwDepth, se);

th = multithresh(bwDepth, lv);
imSeg = imquantize(bwDepth, th);

imgMask(imSeg < 4) = 1;

figure(8)
imshowpair(bwDepth, imSeg, 'montage')

%% Ajustar la mascara
se = strel('disk', 2);

imgMask = imdilate(imgMask, se);
imgMask = imfill(imgMask, 'holes');
imgMask = imerode(imgMask, se);
imgMask = bwareafilt(logical(imgMask), [2000 50000]);

%imgMask = imtranslate(imgMask ,[-8, 0],'FillValues',0);

%% Mostrar resultados
finalImg = bsxfun(@times, imgColor, cast(imgMask, 'like', imgColor));

figure(10)
imshow(imSeg, []);
imshowpair(imgMask, finalImg, 'montage')