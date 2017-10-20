

%[imgName, imgFolder] = uigetfile()
%fullImgPath = fullfile(imgFolder, imgName)
fullImgPath = 'D:\David\SP-IRIS Project\Data\171020\Circular test 1\Camera 1\Image_001.tiff'
img = imread(fullImgPath);
FTImg = abs(fourierTransform(img));

%get the circle with the proper scaling
compareCircle = genCircle(3.45E-3, 2048);

%generate the overlapping circles
overlap = FTImg.*double(compareCircle);


imagesc(FTImg, [1E5, 1E7])
disp(sum(overlap(:)))



