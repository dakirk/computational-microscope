%Author: David Kirk

%Purpose: This script is useful for determining how different a series of
%images is. It creates a heatmap of the standard deviations of the pixel
%values across all images in a set, and then displays the map in a new
%figure. It was primarily used for determining how much vibration occurred
%in a set of images taken from the same position.

% Finds standard deviation of an image set
folder = uigetdir('D:\David\SP-IRIS Project\Data\')
imNames = dir(folder);
imList = {}


for i = 3:length(imNames)
    %disp('meep')
    path = strcat(folder, '\', imNames(i,:).name)
    imList = cat(3, imList, imread(path)); %creates a list of image matricies
    %imread(path);
end

imList = cat(3, imList{:}); %convert to matrix from cell array
imList = im2double(imList);
standardDevs = std(imList,0,3);
%%
hm = HeatMap(standardDevs);
ax = hm.plot;
colorbar('Peer', ax)
caxis(ax, [0 .02]); % <-- Change scale to suit datasets
%disp(stdOfSet)