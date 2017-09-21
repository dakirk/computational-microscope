% Last edited by Oguzhan Avci on 1/23/2016
% This code establishes connection to Thorlabs BPC301 Controller
% After establishing connection, call MovePiezoStage, and
% pass h, and target z position into that function
function [h, connectionFlag] = Connect2Piezo_3axis()

%disp('HELLO WORLD')
for i = 1:3
    f = figure('Position',[0   0   630   420],'visible','off');
    h(i) = actxcontrol('MGPIEZO.MGPiezoCtrl.1',[20 20 600 400], f);  %h.invoke to view all controls
    SN = 91869650+i; %For BPC301
    set(h(i),'HWSerialNum', SN);
    h(i).StartCtrl;
    pause(2);
    h(i).Identify;
    %h(i).ZeroPosition(0); %Zero the controller
    status=h(i).LLGetStatusBits(0,0);

    disp(['Nanomax Piezo Stage ' num2str(i) ': Connecting...']);

    
    % pause(2); %Just in case curpos = 0 randomly
    % [a, curpos]=h.GetPosOutput(0,0);
    % curpos_round=round(curpos*100)/100;
    % while(curpos_round~=0)
    %     [a, curpos]=h.GetPosOutput(0,0);
    %     curpos_round=round(curpos*100)/100;
    % end
    %pause(15); %pause to allow ZeroPosition to finish
    [error,status]=h(i).LLGetStatusBits(0,0);
    h(i).SetControlMode(0,2); %Change control to software
    SetVoltPosDispMode = h(i).SetVoltPosDispMode(0, 2); %Set activeX display mode to position

    % [a, maxTravel]  = h.GetMaxTravel(0,0);
    % halfTravel = floor(maxTravel/2);
    % h.SetPosOutput(0,halfTravel);
    connectionFlag = 1;
    disp(['Nanomax Piezo Stage ', num2str(i) ': ...Complete']);
end