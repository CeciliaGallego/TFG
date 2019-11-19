close all; clear; clc;

filename = 'Chewie_CO_20161410_2.mat';
toSave = true;
trial_data = loadTDfiles(filename,{@getTDidx,{'result','R'}});

% Get only the data when the monkey is moving
idx_end = min([trial_data.idx_trial_end]);
trial_data = trimTD(trial_data, {'idx_movement_on',-12},{'idx_movement_on',42});

% Smooth spikes
trial_data = smoothSignals(trial_data,struct('signals',{{'M1_spikes'}},'width',0.05));

% Do PCA
[dims,~] = estimateDimensionality(trial_data);
disp(['Number of PCA dimensions: ' num2str(dims)])
[trial_data,~] = dimReduce(trial_data, struct('signals','M1_spikes','num_dims',8));
% [trial_data,~] = dimReduce(trial_data, struct('signals','M1_spikes','num_dims',15)); % For no trimmed data 
% % Remember to change saved name and number of dimensions

% Prepare data and perform CCA
name = 'M1_lfp';
fq = unique(trial_data(1).([name '_guide'])(:,3));
bands = {'LMP','0.5-4','4-8','8-12','12-25','25-50','50-100','100-200','200-400'};

pca_data = []; lfp_data = [];
for trial = 1:length(trial_data)
    pca_data = cat(1,pca_data,trial_data(trial).M1_pca);
    lfp_data = cat(1,lfp_data,trial_data(trial).(name));
end
[~,~,r_all] = canoncorr(pca_data,lfp_data);    

r_freq = [];
for band = 1:length(fq)
    isFreq = trial_data(trial).([name '_guide'])(:,3) == fq(band);
    freq_data = lfp_data(:,isFreq);
    [~,~,aux] = canoncorr(pca_data,freq_data); 
    r_freq = cat(1,r_freq,aux);
end

% Bootstrapping
iter = 50; r_boot_freq = []; r_boot_all = [];
for n = 1:iter
    disp(n)
    idx = randperm(length(trial_data));
    pca_data = [];
    for trial = 1:length(trial_data)
        pca_data = cat(1,pca_data,trial_data(idx(trial)).M1_pca);
    end
    [~,~,aux] = canoncorr(pca_data,lfp_data); 
    r_boot_all = cat(1,r_boot_all,aux);
    
    r_aux = [];
    for band = 1:length(fq)
        isFreq = trial_data(trial).([name '_guide'])(:,3) == fq(band);
        freq_data = lfp_data(:,isFreq);
        [~,~,aux] = canoncorr(pca_data,freq_data); 
        r_aux = cat(1,r_aux,aux);
    end
    r_boot_freq = cat(3,r_boot_freq,r_aux);
end

% Plot the resutls
c = parula(length(fq));
figure
for band = 1:length(fq)
    hold on; plot(r_freq(band,:),'color',c(band,:),'linewidth',2)
end
boot = mean(r_boot_freq,3);
hold on; plot(mean(boot,1),'k','linewidth',2);
hold on; plot(boot(1,:),'color',[0.5 0.5 0.5]);
legend([bands 'Boots' 'LMP boots'])

% Save results
if toSave 
    save(['CCA_' filename],'r_all','r_freq','r_boot_all','r_boot_freq','dims');
end