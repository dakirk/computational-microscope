function [mOut] = checkVals(inMat,cVal)
%%
%checkVals Function
%
%Purpose: This is a simple function for quickly generating a logic matrix
%for every value in inMat that matches any of the values in cVal.
%
%-------------------------------------------------------------------------%
dim = size(inMat);
mOut = zeros(dim(1),dim(2));
tmp = ones(dim(1),dim(2));
for k = 1:length(cVal)
    mOut = mOut + double(inMat == (cVal(k) .* tmp));
end %End of checkVal for loop

end %End of checkVals function