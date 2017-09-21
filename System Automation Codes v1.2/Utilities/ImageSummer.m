% Sums a series of black and white images
folder = uigetdir('D:\David\SP-IRIS Project\Data')
imNames = dir(folder);
imList = {}


for i = 1:length(imNames)
    %disp('meep')
    path = strcat(folder,'\',imNames(i,:).name)
    if strcmp(path(end-3:end),'tiff') | strcmp(path(end-3:end),'.jpg') | strcmp(path(end-3:end),'.png') | strcmp(path(end-3:end),'.bmp') ;
        imList = cat(3, imList, imread(path));
    end
    %imList = cat(3, imList, imread(path));
    %imread(path);
end

for i = 1:length(imList)
    if size(imList{i},3) == 3
        imList{i} = rgb2gray(imList{i});
    end
    imList{i} = imbinarize(imList{i});
end

imMat = cell2mat(imList);
composite = sum(imMat,3);
figure
imshow(composite)


