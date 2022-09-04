clc;
clearvars;
workspace;
imtool close all;
format long g;
format compact;

directory = dir(strcat("./originalNuclei/", '*.tif'));
fromPath = "./originalNuclei/";
savePath = "./segmentedNuclei/";

parfor imageIx = 1:size(directory, 1)
    name = directory(imageIx).name;
    SeaStar3DNucleiSegmentation(fromPath, name, savePath, strcat('segmented_nuclei_', name), 1);
    disp(imageIx);
end
