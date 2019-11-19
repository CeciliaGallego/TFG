close all; clear; clc;

% Open TD ('Chewie_CO_20162110.mat'   'Chewie_CO_CS_2016-10-21.mat')
trial_data = loadTDfiles('Chewie_CO_20162110_ceci.mat',{@getTDidx,{'result','R'}});

% Get only the data when the monkey is moving
trial_data = trimTD(trial_data, {'idx_movement_on',-12},{'idx_movement_on',42});

% Trial averaged to each target
trial_data = trialAverage(trial_data,'tgtDir');

% Smooth data
trial_data = smoothSignals(trial_data,struct('signals','M1_spikes','calc_fr',true,'width',0.05));

% Change bin size
trial_data = binTD(trial_data,bin_size);

% Get a single target data
targets = unique([trial_data.tgtDir]);
[idx, trial_data] = getTDidx(trial_data,'tgtDir',targets(t));

% Do PCA
[trial_data,info] = dimReduce(trial_data, struct('signals','M1_spikes','num_dims',10));

% Add binsToThePast
trial_data = dupeAndShift(trial_data,'M1_spikes',-(1:BinToPast));

% Compute VAF
vaf = compute_vaf(x_vel,x_vel_pred);
