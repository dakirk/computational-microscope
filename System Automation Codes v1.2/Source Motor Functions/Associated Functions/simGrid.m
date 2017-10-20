function [NAOut] = simGrid(gType,U,V,lambda,pNA,rNA)
%%
%generateGrid Function
%
%Purpose: This function is meant to generate the valid light source center
%positions given a specified step size for sfx and sfy (provided in NA), a
%range of allowed NA values assuming a circular aperture, and the spatial
%frequency grid for the given camera and imaging system.

%-------------------------------------------------------------------------%
%-------------------------Convert NA to spatial frequency-----------------%
dSF = [abs(U(1,2) - U(1,1)), abs(V(1,1) - V(2,1))]; %Finds U,V grid spatial frequency step size

if(lower(gType(1)) == 's')
    dSF_NA = pNA ./ lambda; %Convert NA pitch into spatial frequency values
    rSF = rNA ./ lambda; %Convert NA range to spatial freq. min and max
    %Round NA SF to be equal integer number of pixels
    dSF_NA = round(dSF_NA ./ dSF); %rounds pixel count to next integer, converts back into spatial frequencies
%-------------------------------------------------------------------------%
%-----------------------Generate Source Centerpoint Grid------------------%
    cntr = [size(U,2)/2+1 size(V,1)/2+1]; %Note: This only works with 
    uPts = [fliplr(U(1,(cntr(1)-dSF_NA(1)):-dSF_NA(1):1)) U(1,cntr(1):dSF_NA(1):end)]; %Identifies horizontal spatial freq. at all possible pitch positions
    vPts = [fliplr((V((cntr(2)-dSF_NA(2)):-dSF_NA(2):1,1))') (V(cntr(2):dSF_NA(2):end,1))']; %Finds vertial spatial freq. at all possible pitch positions

    ptGrid = checkVals(U,uPts) .* checkVals(V,vPts);
    uOut = U .* ptGrid;
    vOut = V .* ptGrid;
    allNA = lambda .* (sqrt(uOut.^2 + vOut.^2));

    if(rNA ~= 0)
        ptGrid(allNA < rNA(1)) = 0;
    %     allNA(allNA < rNA(1)) = 0;
    end
    ptGrid(allNA > rNA(2)) = 0;
    % allNA(allNA > rNA(2)) =0;
    figure
    imagesc(ptGrid);
    axis image
    axis([850 1200 850 1200]);
    NAOut(:,2) = lambda .* U(find(ptGrid == 1)); %Obtain horizontal source spatial freq. positions
    NAOut(:,1) = lambda .* V(find(ptGrid == 1)); %Obtain vertical source spatial freq. positions

%-------------------------------------------------------------------------%
elseif (lower(gType(1)) == 'r' || lower(gType(1)) == 'c')
    theta = 0:pNA(2):(2*pi);    %Generates all angles based on input angle pitch
    rPitch = pNA(1) ./ lambda;   %Convert radial pitch into spatial frequency
    stepR = (rNA(1)./lambda):rPitch:(rNA(2)./lambda);
    nux = stepR' * cos(theta);
    nuy = stepR' * sin(theta);
      stepR_c = [U(1,round(stepR./dSF(1))+1025)' V(round(stepR./dSF(2))+1025,1)];
      ptGrid = zeros(size(U));
      for k = 1:size(stepR_c)
          if(stepR_c(k,1) ~= 0 && stepR_c(k,2) ~= 0)
          tmp = circ(sqrt((U./(stepR_c(k,1)+dSF(1))).^2 + (V./(stepR_c(k,2)+dSF(2))).^2));
          tmp = tmp - circ(sqrt((U./(stepR_c(k,1)-dSF(1))).^2 + (V./(stepR_c(k,2)-dSF(2))).^2)); %Generates single pixel ring of available values for a given radius
          else
              tmp = ones(size(U));
          end
%           figure
%           imagesc(tmp);
%           axis image
%           axis([850 1200 850 1200]);
%           drawnow;
          nux(k,:) = round(nux(k,:)./dSF(1));nuy(k,:) = round(nuy(k,:)./dSF(2));
          uPts = U(1,nux(k,:)+1025);vPts = V(nuy(k,:) + 1025,1);
          ptGrid = ptGrid + tmp .* checkVals(U,uPts) .* checkVals(V,vPts);
      end
      ptGrid(ptGrid >= 1) = 1;
%       figure
%       imagesc(ptGrid);
%       axis image


%     gnux = zeros(size(U,1),size(U,2)); %Preallocate matrix for saving locations of nux values in U grid
%     gnuy = zeros(size(U,1),size(U,2)); %Preallocate matrix for saving locations of nux values in U grid
%     for k = 1:size(nux,1)
%         gnux = gnux + checkVals(U,
    uOut = U .* ptGrid;
    vOut = V .* ptGrid;
    allNA = lambda .* (sqrt(uOut.^2 + vOut.^2));

    if(rNA ~= 0)
        ptGrid(allNA < rNA(1)) = 0;
    %     allNA(allNA < rNA(1)) = 0;
    end
    ptGrid(allNA > rNA(2)) = 0;
    NAOut(:,1) = lambda .* U(find(ptGrid == 1)); %Obtain horizontal source spatial freq. positions
    NAOut(:,2) = lambda .* V(find(ptGrid == 1)); %Obtain vertical source spatial freq. positions
end %End of gType grid statement
end% End of function generateGrid
