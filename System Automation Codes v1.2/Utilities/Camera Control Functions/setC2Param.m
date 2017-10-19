function setC2Param(cam, camSet, pStruct)
%%
%setC2Param Function
%
%Author: Alex Matlock
%
%Purpose: This function simply groups the various camera control parameters
%for being initialized in a single function. This does not contribute
%anything else to the camera operation. 
%
%Inputs: pStruct - Structure containing the camera's parameters defined by
%                  the user. The values should include:
%                       exp = Camera exposure
%                       shut = camera shutter open time (ms)
%                       gn = camera gain
%                       gam = camera gamma value
%                       sharp = camera sharpness / HP image filtering
%                       br = camera brightness level
%                       fr = frame rate
%
%Outputs: None
%
%-------------------------------------------------------------------------%
cam.FramesPerTrigger = 1;
cam.TriggerRepeat = 0; %Sets Single image acquisition for camera
cam.ReturnedColorspace = 'grayscale';
triggerconfig(cam, 'immediate'); %Sets camera to take immediate image during trigger command

camSet.Exposure = pStruct.exp;
camSet.FrameRate = pStruct.fr; %Sets camera frame rate
camSet.Shutter = pStruct.shut; %Sets shutter exposure time (ms)
camSet.Gain = pStruct.gn; %Turns down controllable electronic gain to zero
camSet.Gamma = pStruct.gam; %Turns down gamma to lowest possible value of 0.5
camSet.Sharpness = pStruct.sharp; %Turns down HP filtering within camera (Range 0-4095)
camSet.Brightness = pStruct.br; %Turns down artificial brightness enhancement to zero
camSet.Strobe1 = 'Off'; %Makes sure camera does not do strobing


end %End of setCamParam function