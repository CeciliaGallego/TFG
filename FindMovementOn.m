function [trial_data] = FindMovementOn (trial_data, threshold)

for n = 1:length(trial_data)
    ini_idx = trial_data(n).idx_goCueTime;
    fin_idx = trial_data(n).idx_endTime;
    s1 = abs(trial_data(n).pos(ini_idx:fin_idx,1));
    
    ds1 = diff(s1);
    bool = ds1 > threshold;
    
    if sum(bool) == 0
        s2 = abs(trial_data(n).pos(ini_idx:fin_idx,2)+30);
        ds2 = diff(s2);
        bool = ds2 > threshold;
    end
    
    if sum(bool) == 0
        warning('Not found for trial %d',n);
    end
    
    trial_data(n).idx_movement_on = find(bool,1)+ini_idx;
    
end