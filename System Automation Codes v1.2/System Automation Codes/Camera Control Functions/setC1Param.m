function setC1Param(cam, camSet, pStruct)
%%
%setC1Param Function
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
%
%Outputs: None
%
%-------------------------------------------------------------------------%
cam.FramesPerTrigger = 1;
cam.TriggerRepeat = 0; %Sets Single image acquisition for camera
cam.ReturnedColorspace = 'grayscale';
triggerconfig(cam, 'immediate'); %Sets camera to take immediate image during trigger command
%Set camera modes to manual
%camSet.ExposureMode = 'Manual';
%camSet.GainMode = 'Manual';
%camSet.ShutterMode = 'Manual';
camSet.Shutter = pStruct.shut; %Sets shutter exposure time (ms)
camSet.Exposure = pStruct.exp;
% camSet.FrameRate = 2.42;
camSet.FrameRatePercentage = 92; %Not sure what this does yet


camSet.Gain = pStruct.gn; %Turns down controllable electronic gain to zero
camSet.Gamma = pStruct.gam; %Turns down gamma to lowest possible value of 0.5
camSet.Sharpness = pStruct.sharp; %Turns down HP filtering within camera (Range 0-4095)
camSet.Brightness = pStruct.br; %Turns down artificial brightness enhancement to zero
camSet.Strobe1 = 'Off'; %Makes sure camera does not do strobing
camSet.Strobe2 = 'Off';
camSet.Strobe3 = 'Off';
camSet.TriggerDelay = 0; %Sets trigger to occur immediately


end %End of setCamParam function