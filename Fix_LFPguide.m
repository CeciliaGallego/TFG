close all; clear; clc

filename = 'Chewie_CO_20161410.mat';
toSave = true;

% Open TD
trial_data = loadTDfiles(filename);

old_guide = trial_data(1).M1_lfp_guide;
[~,idx] = sort(old_guide(:,2));
new_guide = old_guide(idx,:);

for n = 1:length(trial_data)
    trial_data(n).M1_lfp_guide = new_guide;
end

if toSave
    save(filename,'trial_data','-v7.3');
end