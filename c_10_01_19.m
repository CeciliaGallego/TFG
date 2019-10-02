close all; clear; clc;

% Open TD ('Chewie_CO_20162110.mat'   'Chewie_CO_CS_2016-10-21.mat')
trial_data = loadTDfiles('Chewie_CO_20162110_ceci.mat',{@getTDidx,{'result','R'}});

% % Smooth spikes
% trial_data = smoothSignals(trial_data,struct('signals',{{'M1_spikes'}},'width',0.05));

% Get only the data when the monkey is moving
trial_data = trimTD(trial_data, {'idx_movement_on',-12},{'idx_movement_on',42});

% Load the mask of modulated bands
load('C:\Users\Cecilia\Documents\MATLAB\Mis scripts\mod_channelAndBand.mat')
for trial = 1:length(trial_data)
    mod_trial_data(trial).M1_lfp = trial_data(trial).M1_lfp(:,mask);
end

% Get target directions
targets = unique([trial_data.tgtDir]);
idx = zeros(38,8);  % 38 is the maximum number of trials per target
for target = 1:length(targets)
    [index, ~] = getTDidx(trial_data,'tgtDir',targets(target));
    idx(1:length(index),target) = index;
end

% New boxplot (We are going to have 286 - 8 boxplots, one per trial). The
% correlation between the trial with the previous to the SAME target).
box = [];
for n = 1:length(trial_data)
    if rem(find(idx == n),38) ~= 1  % The index is NOT the first trial to a target
        prev = idx((find(idx == n))-1);
        box = cat(2,box,diag(corr (mod_trial_data(n).M1_lfp,mod_trial_data(prev).M1_lfp)));
    end
end
figure
boxplot(box)
figure
plot(mean(box))

c = parula(8);
figure
for t = 1:8
    t_idx = idx(4:end,t);
    t_idx (t_idx == 0) = [];
    hold on; plot(t_idx, mean(box(:,t_idx-8)),'color',c(t,:));
end


