function [xyopt] = findCenterPos(m1,m2,cam1,startPos)
%%

% David's notes:
% Added waitForMovement functions, should speed things up a bit
% Currently the mean2 function causes considerable delays--consider sampling
% only part of image (or even a single pixel!) instead of whole image?
% Reducing sample size to 1024x1024 around center of image
% Center seems to usually be close to 4mm horizontal, 4.15mm vertical

%findCenterPos Function
%Author: Alex Matlock


%Purpose: This function provides a basic optimization approach to finding a
%center position for the illumination source in the microscope objective
%based on the intensity measured by the microscope's main camera. This
%function assumes the intensity will follow a hyperbolic design in 2-D
%space, where the center of the objective will provide the maximum light
%intensity on the object. There is no alternative validation method for
%determining the objective center currently, but a checking method could be
%provided through monitoring the pupil positions in the image fourier
%space. 
%
%
%Inputs: m1, m2 - the motor handles for the imaging system.
%        cam1 - Handle controlling the microscope main camera
%        startPos - 2 x 1 vector describing the x and y starting positions
%                   for the system to begin optimizing
%
%Outputs: xyopt - 2 x 1 vector describing the mm absolute positions found
%                 for the maximum intensity image in the system
%
%-------------------------------------------------------------------------%
%Variable Initialization
maxI = 0;       %Variable holding maximum intensity value
xyopt = [0 ,0]; %Vector holding optimal x,y values
xylast = [0,0]; %Saves prior motor position
checkI = [0,0,0]; %Vector holding three adjacent intensity measurements
opt = [true,true,true];       %While loop control variables
step = 0.5;     %Beginning step size for motors
optCnt = 1;
%Obtain initial intensity measurement at starting position
moveMotor_Basic(m1,startPos(1)); %Moves x-direction motor to start position
moveMotor_Basic(m2,startPos(2)); %Moves y-direction motor to start position
pause(1);
%Save motor positions
[trash,pos] = m1.GetAbsMovePos(0,0);
xyopt(1) = pos;
xylast(1) = pos;
[trash,pos] = m2.GetAbsMovePos(0,0);
xyopt(2) = pos;
xylast(2) = pos;
xy = xyopt;
start(cam1); %Call camera 1 to take an image
dat = getdata(cam1); %Extract data from camera 1
maxI = mean2(dat); %Obtain average pixel intensity value from image, set as initial maximum intensity


%Optimization loop
while (opt(1))
    
    stepSize = step;
    cnt = 0;
    loopCounter = 0
    %Find optimal x position at a given y position
    while(opt(2))
        
        if(xy(1) + stepSize <= 6)
        moveMotor_Basic(m1,xy(1) + stepSize); %Iterate movement for motor 1
        [trash,pos] = m1.GetAbsMovePos(0,0);
        dest = xy(1) + stepSize
        xy(1) = pos;
        %waitForMovement(m1,dest)
        %pause(1); %Pause while motor shifts position
        start(cam1); %Acquire camera 1 image
        %This line below seems to take the most time--look for faster
        %alternative?
        pic = getdata(cam1);
        tmp = mean2(pic(512:end-513,512:end-513)); %Grab intensity from the image 
        disp(tmp);
        %new intensity greater than previous intensity check
        if(tmp > maxI)
            maxI = tmp; %Replace maximum intensity
            checkI(1) = maxI; %Sets first value in intensity checks to max. I
            [trash, pos] = m1.GetAbsMovePos(0,0);
            xylast(1) = xyopt(1); %Move prior motor position to last saved position
            xyopt(1) = pos; %Saves current motor position
            cnt = 0; %Resets counter since new maximum has been found
        elseif (tmp < maxI && cnt < 2 && ((tmp/30000) > 0.1)) %originally 65536
            %confirm intensity is lower than other check positions as well
            if(tmp <= checkI(cnt+1))
                cnt = cnt + 1; %Confirms subsequent intensity is lower
                %disp(cnt);
                checkI(cnt+1) = tmp; %Saves intensity check value
            end
        elseif (tmp < maxI && cnt >= 2&& ((tmp/30000) > 0.1)) %I have found a maximum value, need to reduce step size --originally 65536
            xy = xyopt - [(2*stepSize) 0]; %Move motor position to two steps prior to maximum to scan over maximum region again
            stepSize = stepSize / 2 %Reduce step size by half for finer scanning
            %pause(1);
            start(cam1);
            %tmp = mean2(getdata(cam1));
            pic = getdata(cam1);
            tmp = mean2(pic(512:end-513,512:end-513));
            maxI = tmp; %Resets max intensity before previously found peak to scan through region better
            
        end %End of if-else decision structure
        if(stepSize <= step/(2^5))
            opt(2) = false;  %Ends loop if stepSize exists below 15um
        end
        else %Kill switch
            moveMotor_Basic(m1,xyopt(1) - stepSize);
            xy(1) = xyopt(1)-stepSize;
%             opt(2) = false;
%             opt(1) = false;
%             opt(3) = false; 
%             disp('Kill Switch activated on x motor');
        end
        
        %Ends loop in case of infinite looping
        loopCounter = loopCounter + 1
        if loopCounter > 20
            break
        end
        
    end %End of x-motor optimization loop
    moveMotor_Basic(m1,xyopt(1)); %Move motor to optimal x position for y optimization step
    xy(1) = xyopt(1); %Confirms that xy position is in the previously found optimal position
    stepSize = step;
    cnt = 0;
    %Find optimal y position at a given y position
    
    while(opt(3))
        if(xy(2) + stepSize <= 6)
        moveMotor_Basic(m2,xy(2) + stepSize); %Iterate movement for motor 1
        %pause(1); %Pause while motor shifts position
        %waitForMovement(m2,xy(2) + stepSize)
        [trash,pos] = m2.GetAbsMovePos(0,0);
        xy(2) = pos;
        start(cam1); %Acquire camera 1 image
        pic = getdata(cam1);
        tmp = mean2(pic(512:end-513,512:end-513)); %Grab intensity from the image
        %new intensity greater than previous intensity check
        if(tmp > maxI)
            maxI = tmp; %Replace maximum intensity
            checkI(1) = maxI; %Sets first value in intensity checks to max. I
            [trash, pos] = m2.GetAbsMovePos(0,0);
            xylast(2) = xyopt(2); %Move prior motor position to last saved position
            xyopt(2) = pos; %Saves current motor position
            cnt = 0; %Resets counter since new maximum has been found
        elseif (tmp < maxI && cnt < 2 && ((tmp/30000) > 0.1)) %originally 65536
            %confirm intensity is lower than other check positions as well
            if(tmp <= checkI(cnt+1))
                cnt = cnt + 1; %Confirms subsequent intensity is lower
                checkI(cnt+1) = tmp; %Saves intensity check value
            end
        elseif (tmp < maxI && cnt >= 2 && ((tmp/30000) > 0.1)) %I have found a maximum value, need to reduce step size --originally 65536
            xy = xyopt - [0 (2*stepSize)]; %Move motor position to two steps prior to maximum to scan over maximum region again; %resets motor position to position before optimal value was found
            stepSize = stepSize / 2 %Reduce step size by half
            %pause(1);
            start(cam1);
            %tmp = mean2(getdata(cam1));
            pic = getdata(cam1);
            tmp = mean2(pic(512:end-513,512:end-513));
            maxI = tmp; %Resets max intensity before previously found peak to scan through region better
            
        end %End of if-else decision structure
        if(stepSize <= step/(2^5))
            opt(3) = false;  %Ends loop if stepSize exists below 15um
        end
        else
            moveMotor_Basic(m2,xyopt(2) - stepSize);
            xy(2) = xyopt(2)-stepSize;
%             opt(2) = false;
%             opt(1) = false;
%             opt(3) = false;
%             disp('Kill Switch activated on y motor');
        end
    end %End of y-motor optimization loop
    moveMotor_Basic(m2,xyopt(2)); %Move motor to optimal x position for y optimization step
    xy(2) = xyopt(2);
    %Total optimization loop cancellation
    if(optCnt < 2)
        optCnt = optCnt + 1;
        opt(2) = true;
        opt(3) = true;
        step = step / 6; %Reduce initial step size for higher precision movements
    else

        opt(1) = false;
        opt(2) = false;
        opt(3) = false;
        
    end
end %End of total optimization loop

moveMotor_Basic(m1,xyopt(1));
moveMotor_Basic(m2,xyopt(2));

end