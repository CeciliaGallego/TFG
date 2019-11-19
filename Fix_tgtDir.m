close all; clear; clc;

toSave = false;
find_onset = false;
filename = 'Mihili_CO_20140603.mat';

% Open TD ('Chewie_CO_20162110.mat'   'Chewie_CO_CS_2016-10-21.mat')
trial_data = loadTDfiles(filename,{@getTDidx,{'result','R'}});

% Find movement onset
if find_onset
    thres = 1;
    trial_data = FindMovementOn(trial_data,thres);
    while (sum(isnan([trial_data.idx_movement_on])) ~= 0) && (thres > 0)
        thres = thres - 0.05;
        trial_data = FindMovementOn(trial_data,thres);
    end
    if sum(isnan([trial_data.idx_movement_on])) ~= 0
        disp('Some movement onsets were not detected');
        return
    end
end

% Trim data
td = trimTD(trial_data, {'idx_movement_on',-12},{'idx_movement_on',42});

targets = unique([td.tgtDir]);

lim = 6;
for trial = 1:length(trial_data)
    x = mean(td(trial).vel(:,1));
    y = mean(td(trial).vel(:,2));
    if (x<-lim) && (abs(y)<lim)
        if targets(1) ~= trial_data(trial).tgtDir
            disp(trial)
            trial_data(trial).tgtDir = targets(1);
        end 
    elseif (y<-lim) && (x<-lim)
        if targets(2) ~= trial_data(trial).tgtDir
            disp(trial)
            trial_data(trial).tgtDir = targets(2);
        end 
    elseif (y<-lim) && (abs(x)<lim)
        if targets(3) ~= trial_data(trial).tgtDir
            disp(trial)
            trial_data(trial).tgtDir = targets(3);
        end 
    elseif (y<-lim) && (x>lim)
        if targets(4) ~= trial_data(trial).tgtDir
            disp(trial)
            trial_data(trial).tgtDir = targets(4);
        end 
    elseif (x>lim) && (abs(y)<lim)
        if targets(5) ~= trial_data(trial).tgtDir
            disp(trial)
            trial_data(trial).tgtDir = targets(5);
        end 
    elseif (y>lim) && (x>lim)
        if targets(6) ~= trial_data(trial).tgtDir
            disp(trial)
            trial_data(trial).tgtDir = targets(6);
        end 
    elseif (y>lim) && (abs(x)<lim)
        if targets(7) ~= trial_data(trial).tgtDir
            disp(trial)
            trial_data(trial).tgtDir = targets(7);
        end 
    elseif (y>lim) && (x<-lim)
        if targets(8) ~= trial_data(trial).tgtDir
            disp(trial)
            trial_data(trial).tgtDir = targets(8);
        end 
    else
        disp(['Trial ' num2str(trial) ' not identified']);  
    end
end


for t = 1:8
    figure
    [~, data_target] = getTDidx(trial_data,'tgtDir',targets(t));
%     data_target = trimTD(data_target, {'idx_movement_on',-12},{'idx_movement_on',42});
    for trial = 1:length(data_target)
        subplot(1,2,1)
        hold on; plot(data_target(trial).vel(:,1)); ylim([-30,30]);
        subplot(1,2,2)
        hold on; plot(data_target(trial).vel(:,2)); ylim([-30,30]);
    end
end


if toSave
    save(filename,'trial_data');
end