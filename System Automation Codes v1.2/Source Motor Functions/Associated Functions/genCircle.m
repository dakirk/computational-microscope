function returnCircle = genCircle(pixelSize, numPixels)

%%
%global illum
mag = 10
lambda = 5.3E-4
NA = .25
deltaSF = 1/(numPixels*(pixelSize/mag))

uh = ((-numPixels/2)*deltaSF):(deltaSF):(((numPixels/2)-1)*deltaSF);
vh = ((-numPixels/2)*deltaSF):(deltaSF):(((numPixels/2)-1)*deltaSF);

[u,v] = meshgrid(uh,vh);

circleMap = sqrt( ((u./(NA/lambda)).^2) + ((v./(NA/lambda)).^2) );
returnCircle = circ(circleMap);

%HeatMap(double(filter));

%result = sum(sum(filter));

%disp(result)
end