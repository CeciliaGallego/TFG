function [trial_data] = FindMovementOn (trial_data, threshold)
% Do not work, maybe study at the same time x and y components and take the
% higher resulting index

% Recommended threshold = 0.6

for n = 1:length(trial_data)
    ini_idx = trial_data(n).idx_goCueTime;
    fin_idx = trial_data(n).idx_endTime;
    s1 = abs(trial_data(n).vel(ini_idx:fin_idx,1));
    
    ds1 = diff(s1);
    bool = ds1 > threshold;
    
    if sum(bool) == 0
        s2 = abs(trial_data(n).vel(ini_idx:fin_idx,2)+30);
        ds2 = diff(s2);
        bool = ds2 > threshold;
    end
    
    if sum(bool) == 0
        warning('Not movement onset found for trial %d',n);
    end
    
    trial_data(n).idx_movement_on = find(bool,1)+ini_idx-(10/(trial_data(n).bin_size*100));
    trial_data = reorderTDfields(trial_data);
end