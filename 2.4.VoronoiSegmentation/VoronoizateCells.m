function [voronoiSeaStar] = VoronoizateCells(binaryMask, imgCells)
    binaryMask = binaryMask/max(binaryMask(:));

    voronoiSeaStar = imgCells.*cast(binaryMask, class(imgCells));

    perimCells = bwperim(voronoiSeaStar > 0);
    
    %% Get bounded valid pixels
    idsToFill = find(binaryMask == 1 & imgCells == 0);
    [row, col, z] = ind2sub(size(binaryMask), idsToFill);
    labelPerId = zeros(size(idsToFill));
    
    idsPerim = find(perimCells == 1);
    [rowPer, colPer, zPer] = ind2sub(size(binaryMask), idsPerim);
    labelsPerimIds = voronoiSeaStar(perimCells);
    
    %% From valid pixels get closest seed (add this value)

    if isempty(gcp('nocreate'))
        parfor nId = 1:length(idsToFill)
            distCoord = pdist2([col(nId), row(nId), z(nId)], [colPer, rowPer, zPer]);
            [~,idSeedMin] = min(distCoord);
            labelPerId(nId) = labelsPerimIds(idSeedMin);
        end
        poolobj = gcp('nocreate');
        delete(poolobj);
    else
        for nId = 1:length(idsToFill)
            distCoord = pdist2([col(nId), row(nId), z(nId)], [colPer, rowPer, zPer]);
            [~,idSeedMin]=min(distCoord);
            labelPerId(nId) = labelsPerimIds(idSeedMin);
            disp([num2str(nId) '/' num2str(length(idsToFill))])
        end
    end
    voronoiSeaStar(idsToFill) = labelPerId;
end
