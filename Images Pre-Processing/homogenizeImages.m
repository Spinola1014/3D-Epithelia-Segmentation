[originalImage, imgInfo] = readStackTif("T1.tif");

%% Extract pixel-micron relation
xResolution = imgInfo(1).XResolution;
yResolution = imgInfo(1).YResolution;
spacingInfo = strsplit(imgInfo(1).ImageDescription, 'spacing=');
spacingInfo = strsplit(spacingInfo{2}, '\n');
z_pixel = str2num(spacingInfo{1});
x_pixel = 1/xResolution;
y_pixel = 1/yResolution;

%% Get original image size
shape = size(originalImage);

%% Make homogeneous
numRows = shape(1);
numCols = shape(2);
numSlices = round(shape(3)*(z_pixel/x_pixel));

originalImage = imresize3(originalImage, [numRows, numCols, numSlices]);

homoOriginalReduced = imresize3(originalImage, 0.3);

writeStackTif(homoOriginalReduced, "homoOriginalReduced_T1.tif");
