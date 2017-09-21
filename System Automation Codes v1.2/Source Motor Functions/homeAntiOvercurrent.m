%testing a new homing function
function HomeSafeTest(m)

%Purpose: This function should provide homing of the z806 motors without
%introducing overloading issues from moving too quickly to the home
%position. This function is designed to move slowly, in steps, towards the
%lower hardware limit, and then run the default homing function from there,
%since it should now be within .4mm and therefore perform that action
%safely.
%%
%m1 = initKDC(27250777); %Controls x-direction on source
%m = initKDC(27250826); %Controls y-direction on source motion
%%
[a,b,c,d,e,f] = m.GetStageAxisInfo(0,0,0,0,0,0)
m.SetStageAxisInfo(a,-8,6,d,e,f) 

[g,h,i,j] = m.GetVelParams(0,0,0,0)
m.SetVelParams(g,h,i,.1)

%^params: a unknown, b lower software limit, c upper software limit, d
%unknown, e unknown

notHitEnd = true;

%m2.GetHWLimSwitches(0,0,0)

%Moves by increments of .1mm in negative direction, looking for hardware
%limit--once found, runs homing function (should be safe now because close
%to actual location of the home)
%[tst,pos] = m.GetPosition(0,0);
[tst,pos] = m.GetPosition(0,0);
m.SetAbsMovePos(0,pos-8);
while notHitEnd
    [tst,pos] = m.GetPosition(0,0);
    m.MoveAbsolute(0,0);
    %Timeout(5)
    pause(.1);
    [newTst,newPos] = m.GetPosition(0,0);
    if newPos == pos %if hits end, shouldn't move, so no change in position
        notHitEnd = false;
    end
end

%[tst,pos] = m.GetPosition(0,0);
%moveMotor_Basic(m,pos-8)
fprintf('made it here')
m.MoveHome(0,0);
m.SetVelParams(g,h,i,j)
end