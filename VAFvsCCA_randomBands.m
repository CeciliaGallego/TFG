% close all; clear all; clc

bin_size = 3;
BinToPast = 5;
name = 'M1_lfp';
folds = 500;
filename = 'Chewie_CO_20162110.mat';

[trial_data, pars_td] = loadTDfiles( filename, ...
                    { @getTDidx, 'result', 'R' }, ...
                    { @binTD, bin_size}, ...
                    { @removeBadTrials},...
                    { @sqrtTransform, 'M1_spikes' }, ...
                    { @smoothSignals, struct('signals','M1_spikes','calc_fr',true,'width',0.05) });

idx = [];
for n = 1:folds
    idx = cat(1,idx,randperm(size(trial_data(1).M1_lfp,2)));
end

vaf = [];
for n = 1:folds
    aux_trial_data = trial_data;
    for k = 1:length(trial_data)
        aux_trial_data(k).(name) = trial_data(k).(name)(:,idx(n,1:96));
    end
    disp(n)
    [vaf(n,1), vaf(n,2),~,~,~,~] = TD_ComputeModelAndPlotLFP(aux_trial_data,BinToPast,name);
end

% Do PCA
idx_end = min([trial_data.idx_endTime]);
trial_data = trimTD(trial_data, {'idx_startTime',0},{'idx_startTime',idx_end-1});

[dims,~] = estimateDimensionality(trial_data);
disp(['Number of PCA dimensions: ' num2str(dims)])
[trial_data,~] = dimReduce(trial_data, struct('signals','M1_spikes','num_dims',8));
% Do CCA
r_all = [];
for n = 1:folds
    disp(n)
    pca_data = []; lfp_data = [];
    for trial = 1:length(trial_data)
        pca_data = cat(1,pca_data,trial_data(trial).M1_pca);
        lfp_data = cat(1,lfp_data,trial_data(trial).(name)(:,idx(n,1:96)));
    end
    [~,~,aux] = canoncorr(pca_data,lfp_data); 
    r_all = cat(1,r_all,aux);
end

vaf = mean(vaf,2);
cca = mean(r_all,2);

hold on
scatter(cca,vaf,'MarkerFaceColor','k','MarkerEdgeColor','k'); 
xlabel('CCA coefficient'); ylabel('Decoder performance');
