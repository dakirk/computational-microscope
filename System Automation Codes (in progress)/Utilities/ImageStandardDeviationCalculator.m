% Finds standard deviation of an image set
folder = uigetdir('D:\David\SP-IRIS Project\Data\')
imNames = dir(folder);
imList = {}


for i = 3:length(imNames)
    %disp('meep')
    path = strcat(folder, '\', imNames(i,:).name)
    imList = cat(3, imList, imread(path));
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