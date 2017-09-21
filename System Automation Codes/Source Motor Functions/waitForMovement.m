%forces program to wait until motors stop moving
function waitForMovement(m, destination)
%disp(destination)
[tst,pos] = m.GetPosition(0,0);
tic
while round(pos,4) ~= round(destination,4)
    [tst,pos] = m.GetPosition(0,0);
    pause(.1)
    elapsedTime = toc;
    if elapsedTime > 5 %prevents from looping forever
        pos == destination
        disp(pos)
        disp(destination)
        break
    end
end
%disp('Ended!')

end
