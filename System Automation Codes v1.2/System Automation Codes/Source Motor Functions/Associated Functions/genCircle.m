function returnCircle = genCircle(pixelSize, numPixels)

%%
global illum

NA = .25
deltaSF = 1/(numPixels*(pixelSize/illum.Mag))

uh = ((-numPixels/2)*deltaSF):(deltaSF):(((numPixels/2)-1)*deltaSF);
vh = ((-numPixels/2)*deltaSF):(deltaSF):(((numPixels/2)-1)*deltaSF);

[u,v] = meshgrid(uh,vh);

circleMap = sqrt( ((u./(NA/illum.lambda)).^2) + ((v./(NA/illum.lambda)).^2) );
returnCircle = circ(circleMap);

%HeatMap(double(filter));

%result = sum(sum(filter));

%disp(result)
end