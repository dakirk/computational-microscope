function r = IsMoving(StatusBits)
% Read StatusBits returned by GetStatusBits_Bits method and determine if
% the motor shaft is moving; Return 1 if moving, return 0 if stationary
r = ~bitget(abs(StatusBits),5) || ~bitget(abs(StatusBits),6);
disp([num2str(bitget(abs(StatusBits),1)), num2str(bitget(abs(StatusBits),2)),num2str(bitget(abs(StatusBits),3)),num2str(bitget(abs(StatusBits),4)),num2str(bitget(abs(StatusBits),5)),num2str(bitget(abs(StatusBits),6)),num2str(bitget(abs(StatusBits),7)),num2str(bitget(abs(StatusBits),8))]);
%sprintf('Status Bits: %s',dec2bin(StatusBits,8)) % example is for the integer 23



