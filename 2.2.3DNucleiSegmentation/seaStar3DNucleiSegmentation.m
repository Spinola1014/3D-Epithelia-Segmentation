function SeaStar3DNucleiSegmentation(inPath, imageName, outputPath, outputName, scale)
  
    if nargin < 4
        scale = 1;
    end

    originalImage = readStackTif(strcat(inPath, imageName));
    originalImage = imresize3(originalImage, "Scale", scale, "Method", "nearest");
    
    BW = imbinarize(originalImage, "global");
    binaryImage = imfill(BW, 'holes');

    binaryImage = bwareaopen(binaryImage, 30, 26);
    
    se = strel('sphere', 3);
    labeledImage = bwlabeln(binaryImage, 26);
    labeledImage2 = labeledImage;
    
    uniqueLables = unique(labeledImage); 
    
    for cellIx = 2:length(uniqueLables)
        cellId = uniqueLables(cellIx);
        if size(unique(labeledImage2 == cellId), 1) == 2
            cellProps = regionprops3(labeledImage2 == cellId, "Volume", "Centroid");
            labeledImage2(labeledImage2 == cellId) = 0; 
            if cellProps.Volume < 120
                continue
            end
            y = round(cellProps.Centroid(1));
            x = round(cellProps.Centroid(2));
            z = round(cellProps.Centroid(3));
            labeledImage2(x, y, z) = cellId;
        end
    end
    
    dilatedImage2 = imdilate(labeledImage2, se);
    
    writeStackTif(double(dilatedImage2/255), strcat(outputPath, outputName));

end
