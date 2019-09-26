function [trial_data] = FindMovementOn (trial_data)
% Do not work, maybe study at the same time x and y components and take the
% higher resulting index

threshold = 0.05;

% Start with y coponent

for n = 1:length(trial_data)
    ini_idx = trial_data(n).idx_goCueTime;
    fin_idx = trial_data(n).idx_endTime;
    
    s = abs(trial_data(n).pos(ini_idx:fin_idx,2)+30);
    if mean(s) < 1   % There is no info in this component
        s = abs(trial_data(n).pos(ini_idx:fin_idx,1));
    end
        
    ds = diff(s);
    bool = ds > threshold;
    
    idx = find(bool,1);
      
    if isempty(idx)
        warning('Not movement onset found for trial %d',n);
    end
    
    trial_data(n).idx_movement_on = idx+ini_idx; %-(10/(trial_data(n).bin_size*100));
    trial_data = reorderTDfields(trial_data);
end