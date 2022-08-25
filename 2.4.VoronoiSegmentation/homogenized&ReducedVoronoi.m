mask = readStackTif("mask_T35.tif");
[stainedNuclei, imgInfo] = readStackTif("stk_0035_20200114_miniata_rasGFP_H2BRFP_32cellsTohatch_pos4-1.tif");
nuclei = readStackTif("segmented_nuclei_stk_0035_20200114_miniata_rasGFP_H2BRFP_32cellsTohatch_pos4-1.tif"); 

%% Extract pixel-micron relation
xResolution = imgInfo(1).XResolution;
yResolution = imgInfo(1).YResolution;
spacingInfo = strsplit(imgInfo(1).ImageDescription, 'spacing=');
spacingInfo = strsplit(spacingInfo{2}, '\n');
z_pixel = str2num(spacingInfo{1});
x_pixel = 1/xResolution;
y_pixel = 1/yResolution;

%% Get original image size
shape = size(stainedNuclei);

%% Make homogeneous
numRows = shape(1);
numCols = shape(2);
numSlices = round(shape(3)*(z_pixel/x_pixel));

nuclei = imresize3(nuclei, [numRows, numCols, numSlices], 'nearest');
mask = imresize3(mask, [numRows, numCols, numSlices], 'nearest');
stainedNuclei = imresize3(stainedNuclei, [numRows, numCols, numSlices]);

labelledImage = nuclei;
labelledImage2 = labelledImage;

uniqueLables = unique(labelledImage); 

for cellIx = 2:length(uniqueLables)
    cellId = uniqueLables(cellIx);
    if size(unique(labelledImage2 == cellId), 1) == 2
        cellProps = regionprops3(labelledImage2 == cellId, "Volume", "Centroid");
        labelledImage2(labelledImage2 == cellId) = 0; 
 
        y = round(cellProps.Centroid(1));
        x = round(cellProps.Centroid(2));
        z = round(cellProps.Centroid(3));
        labelledImage2(x, y, z) = cellId;
    end
end

se = strel('sphere', 10);
dilatedImage2 = imdilate(labelledImage2, se);
 
homoNucleiReduced = imresize3(dilatedImage2, 0.3, 'nearest');
homoMaskReduced = imresize3(mask, 0.3, 'nearest');
homoOriginalReduced = imresize3(stainedNuclei, 0.3);

homoVoronoi = VoronoizateCells(homoMaskReduced, homoNucleiReduced);

writeStackTif(homoVoronoi, "homoVoronoi_T35.tif");
