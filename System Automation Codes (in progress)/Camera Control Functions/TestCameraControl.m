
%Initialize Camera 1
c1 = videoinput('pointgrey', 1, 'F7_Mono16_2048x2048_Mode0');
c1Param = getselectedsource(c1);

%Set Camera 1 Parameters
c1.FramesPerTrigger = 1;

c1.TriggerRepeat = 0; %Sets Single image acquisition for camera
triggerconfig(c1, 'immediate'); %Sets camera to take immediate image during trigger command
c1Param.Exposure = -7.58;
c1Param.Shutter = 500; %Sets shutter exposure time (ms)
c1Param.FrameRatePercentage = 100; %Not sure what this does yet
c1Param.Gain = 0; %Turns down controllable electronic gain to zero
c1Param.Gamma = 0.5; %Turns down gamma to lowest possible value of 0.5
c1Param.Sharpness = 0; %Turns down HP filtering within camera (Range 0-4095)
c1Param.Brightness = 0; %Turns down artificial brightness enhancement to zero



start(c1);
% stopvid(c1);
imwrite(getdata(c1), 'C:\Users\amatlock\Documents\MATLAB\test3.tiff');
