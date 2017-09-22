% Last edited by Oguzhan Avci on 1/23/2016
% Test script for Thorlabs BPC301 Piezo controller 

%% Establish connection
 [h, flag] = Connect2Piezo_3axis(); % Default z = 10 um
 pause(2)
%% Move stage to desired position

target_z = 7; % z = 6 um
MovePiezoStage(h(2), flag, target_z); % Moves to z = 6 um
%h(2).SetPosOutput(0,target_z)

pause(.25)
[a,b] = h(2).GetPosOutput(0,0)
