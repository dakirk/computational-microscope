function [inPosition] = moveMotor_Basic(mH, mmVal)
%%
%moveMotor_Basic Function
%
%Purpose: The purpose of this function is to provide absolute position
%movement of a motor assuming it has been homed properly. This function
%only uses the basic absolute movement commands and does not control motor
%velocity, kickback, or any other aspects of the components. These factors
%will need to be added in future iterations.
%
%Inputs: mH - variable corresponding to a specific motor
%        mmVal - millimeter value for translating the source in a given
%                direction
%
%Outputs: inPosition - boolean describing whether motor has reached the
%                      designated position.
%
%-------------------------------------------------------------------------%

inPosition = 0;
cnt = [0,0]; %counter describing whether motor move command has been sent
while (inPosition == 0)
    %disp(cnt)
    if(cnt(1) == 0)
        mH.SetAbsMovePos(0,mmVal); %Sets position to move to
        mH.MoveAbsolute(0,1);      %Moves motor to position
        cnt(1) = 1;
    end %End of counter check
    [tmp,pos] = mH.GetAbsMovePos(0,0);
    %Checks if motor position and expected value are close to the first
    %decimal point
    if(round(pos,1) == round(mmVal,1))
        inPosition = 1;
    end
    cnt(2) = cnt(2) + 1;
    %Automatic while loop break if values are not close enough
    if(cnt(2) >= 100000)
        inPosition = 1;
        disp(pos)
        disp(mmVal)
    end
end %End of while loop preventing function from ending until distance is reached
pause(.3)

end %End of moveMotor_Basic function