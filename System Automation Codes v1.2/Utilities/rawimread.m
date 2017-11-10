function [ output ] = rawimread( file,rows,cols )
%%read .raw image file into matlab. 12bit ADC, Alex camera
%% usage: img = rawimread('test.raw',2048,2048);
%% output is uint16
%% be aware that rows refers to the number of rows (the height of matrix), and cols refers to number of cols (the width)
%% yujia 20171027
img = fopen(file,'r');
data = fread(img); %Pulls data out into n x 1 array
output = zeros(rows*cols,1);
for i = 1:length(output);
    idx = (i-1)*1.5+1;
    if mod(idx,1) == 0
        val = data(idx) + mod(data(idx+1),16)*256;
    else
        idx = idx - 0.5;
        val = data(idx+1)*16 + floor(data(idx)/16);
    end
    output(i) = val;
end
%%the version below is slower.
% for i = 1:3:length(data)  
%     val1 = data(i) + mod(data(i+1),16)*256;
%     val2 = data(i+2)*16 + floor(data(i+1)/16);
%     idx = (i-1)*2/3+1;
%     output(idx:idx+1) = [val1,val2];
% end
output = reshape(output,cols,rows);
output = uint16(output');
imwrite(output, '12BitTest.tiff');
info = imfinfo('12BitTest.tiff');
disp(info.BitDepth);
end