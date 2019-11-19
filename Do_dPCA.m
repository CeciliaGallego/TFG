close all; clear; clc;

%% Do dPCA used trial_data code

% Open TD
trial_data = loadTDfiles('Mihili_CO_20140403.mat',{@getTDidx,{'result','R'}});

% Smoothing the spikes
trial_data = smoothSignals(trial_data,struct('signals','M1_spikes','sqrt_transform',true,'do_smoothing',true,'width',0.05));

% Get only the data when the monkey is moving
trial_data = trimTD(trial_data, {'idx_movement_on',-12},{'idx_movement_on',42});
% trial_data = trimTD(trial_data, {'idx_movement_on',-50},{'idx_movement_on',50});

trial_data = binTD(trial_data,3);

% Get only LMP band
isFreq = trial_data(1).M1_lfp_guide(:,3) == 25;
for n = 1:length(trial_data)
    trial_data(n).M1_lfp = trial_data(n).M1_lfp(:,isFreq);
end

% dPCA
params.signals = 'M1_lfp';
params.marg_names = {'time','target'};
params.marg_colors = [150 150 150; 23 100 171]/256; % blue, red
params.do_plot = true;

[~, dPCA_info] = runDPCA(trial_data,'tgtDir',params);


%% Separate dPC from target and time (PROBLEM: Time PCs not informative enough)
% and compute CCA between dPC from spikes and LFPs at different frequencies



% time = find(dPCA_info.which_marg == 1);
% target = find(dPCA_info.which_marg == 2);
% 
% [trial_data,~] = dimReduce(trial_data, struct('signals','M1_spikes','num_dims',15));
% 
% for n = 1:length(trial_data)
%     trial_data(n).dpca_time = trial_data(n).M1_spikes*dPCA_info.W(:,time);
%     trial_data(n).dpca_target = trial_data(n).M1_spikes*dPCA_info.W(:,target);
% end
% fq = trial_data(1).M1_lfp_guide(1:7,3);
% dpca_time = []; r_time = []; dpca_targ = []; r_targ = [];
% boot_time = []; boot_targ = []; r_boot_time = []; r_boot_targ = [];
% pca = []; r_pca = []; boot_pca = []; r_boot_pca = [];
% boot_idx = randperm(length(trial_data));
% for band = fq'
%     idx = trial_data(1).M1_lfp_guide(:,3) == band;
%     idx = idx(1:size(trial_data(1).mod_lfp,2));
%     lfp = [];
%     for trial = 1:length(trial_data)
%         if band == 4
%             dpca_time = cat(1,dpca_time,trial_data(trial).dpca_time);
%             dpca_targ = cat(1,dpca_targ,trial_data(trial).dpca_target); 
%             boot_time = cat(1,boot_time,trial_data(boot_idx(trial)).dpca_time);
%             boot_targ = cat(1,boot_targ,trial_data(boot_idx(trial)).dpca_target);
%             pca = cat(1,pca,trial_data(trial).M1_pca);
%             boot_pca = cat(1,boot_pca,trial_data(boot_idx(trial)).M1_pca);
%         end
%         lfp = cat(1,lfp,trial_data(trial).mod_lfp(:,idx));
%     end  
%     [~,~,aux] = canoncorr(lfp,dpca_time);
%     r_time = cat(1,r_time,aux);
%     [~,~,aux] = canoncorr(lfp,dpca_targ);
%     r_targ = cat(1,r_targ,aux);
%     [~,~,aux] = canoncorr(lfp,boot_time);
%     r_boot_time = cat(1,r_boot_time,aux);
%     [~,~,aux] = canoncorr(lfp,boot_targ);
%     r_boot_targ = cat(1,r_boot_targ,aux);
%     [~,~,aux] = canoncorr(lfp,pca);
%     r_pca = cat(1,r_pca,aux);
%     [~,~,aux] = canoncorr(lfp,boot_pca);
%     r_boot_pca = cat(1,r_boot_pca,aux);
% end
% 
% c = parula(7);
% figure
% for band = 1:7
%     subplot(1,3,1)
%     hold on; plot(r_time(band,:),'color',c(band,:)); ylim([0 1]);
%     title(['Time: ' num2str(sum(dPCA_info.expl_var.componentVar(time))) '%']);
%     subplot(1,3,2)
%     hold on; plot(r_targ(band,:),'color',c(band,:)); ylim([0 1]);
%     title(['Target: ' num2str(sum(dPCA_info.expl_var.componentVar(target))) '%']);
%     subplot(1,3,3)
%     hold on; plot(r_pca(band,:),'color',c(band,:)); ylim([0 1]);
%     title('PCA: 100%');
% end
% subplot(1,3,1)
% hold on; plot(mean(r_boot_time,1),'color','k','linewidth',2);
% subplot(1,3,2)
% hold on; plot(mean(r_boot_targ,1),'color','k','linewidth',2);
% subplot(1,3,3)
% hold on; plot(mean(r_boot_pca,1),'color','k','linewidth',2);
