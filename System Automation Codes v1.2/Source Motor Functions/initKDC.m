function [hndl] = initKDC(SN)
%%
%initKDC function
%
%Purpose: The purpose of this function is to group the activeX commands and
%figure initialization necessary for controlling a thorlabs motor through a
%KDC101 USB-connected driver. This function may work for other motor types
%as well. 
%
%Inputs: SN - serial number of specific motor to connect
%
%Outputs: hndl - Handle allowing commands to be passed to the initialized
%                motor
%
%-------------------------------------------------------------------------%

%Initialize figure for holding motor GUIs
wSize = [400 400 800 600];
mGUI = get(0,'DefaultFigurePosition');
mGUI(1:4) = wSize;
mF = figure('Position',mGUI);

%Initialize ActiveX Motor Controls
hndl = actxcontrol('MGMOTOR.MGMotorCtrl.1',[0 0 800 600],mF);
hndl.StartCtrl;
set(hndl,'HWSerialNum',SN);



end %End of initKDC function