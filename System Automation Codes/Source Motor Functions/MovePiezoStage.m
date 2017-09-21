% Last edited by Oguzhan Avci on 1/23/2016
% This code moves the piezo stage to desired position
% Takes parameters h, target
% h: connection handle from Connect2Piezo
% target = desired z position

function MovePiezoStage(h, flag, target, figure_flag)

if nargin <4
    figure_flag=0;
end

bounds=.01;
within_bounds=0;
timeout_limit = 5; % seconds


timeout_flag=0;
success_flag=0;


start_tic=tic;
time_tracker=[];
pos_tracker=[];
[a, start_pos]=h.GetPosOutput(0,0);

time_tracker(1)=toc(start_tic);
pos_tracker(1)=start_pos;
if flag == 1
    [a, curpos] = h.GetPosOutput(0,0);
    curpos = round(curpos*100)/100;
    h.SetPosOutput(0,target);
    
    %     while(curpos ~= target)
    %         [a, curpos] = h.GetPosOutput(0,0);
    %         curpos = round(curpos*100)/100;
    %     end

    
    loop_flag=1;
    while(loop_flag)
        [a, curpos] = h.GetPosOutput(0,0);
        
        curpos_raw=curpos;
        %         curpos_round = round(curpos*100)/100;
        
        if abs(curpos_raw-target) <=bounds
            within_bounds=within_bounds+1;
        end
        temp_time=toc(start_tic);
        time_tracker(end+1)=temp_time;
        pos_tracker(end+1)=curpos_raw;
        
        if (within_bounds >= 3)
            loop_flag=0;
            success_flag=1;
        elseif temp_time > timeout_limit;
            loop_flag=0;
            timeout_flag=1;
        end
        
    end
    
    if timeout_flag
        
        disp_str=['NANOMAX Timeout Error - Target z: ' num2str(target) ', Measured Z: ' num2str(curpos_raw)];
 
        disp(disp_str);
    end
    
    if figure_flag
        f=figure;
        plot(time_tracker(:),pos_tracker(:),'-b');
        xlabel('Seconds');
        ylabel('Microns');
        title_str=['Start Pos: ' num2str(start_pos) ', Target: ' num2str(target)];
        title(title_str);
    end
    
else disp('No established connection!');
end