function [trial_data] = FindMovementOn (trial_data,threshold)
% Do not work, maybe study at the same time x and y components and take the
% higher resulting index


% Start with y coponent

for n = 1:length(trial_data)
    if isnan(trial_data(n).idx_goCueTime)
        ini_idx = 1;
    else
        ini_idx = trial_data(n).idx_goCueTime;
    end
    if isnan(trial_data(n).idx_endTime)
        fin_idx = length(trial_data(n).pos(:,1));
    else
        fin_idx = trial_data(n).idx_endTime;
    end
    
    %--------- Problem with negatives (maybe use abs(diff()))----------%
    ds = abs(diff(trial_data(n).pos(ini_idx:fin_idx,2)+30));
    if max(ds) < 0.1   % There is no info in this component
        ds = abs(diff(trial_data(n).pos(ini_idx:fin_idx,1)));
    end
        
    bool = ds > threshold;
    
    idx = find(bool,1);
      
    if isempty(idx)
        warning('Not movement onset found for trial %d',n);
        trial_data(n).idx_movement_on = nan;
    else
        
        trial_data(n).idx_movement_on = idx+ini_idx;
    end
    
end
trial_data = reorderTDfields(trial_data);


end