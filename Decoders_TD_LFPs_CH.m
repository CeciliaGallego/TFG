% Variables
pca_dims = 20;
bin_size = 3;
BinToPast = 5;
folds = 5;
% InputCh = 0.9;

% load('Chewie_CO_CS_2016-10-21.mat');
[trial_data, pars_td] = loadTDfiles( 'Chewie_CO_20162110.mat', ...
                    { @getTDidx, 'result', 'R' }, ...
                    { @binTD, bin_size}, ...
                    { @removeBadTrials},...
                    { @sqrtTransform, 'M1_spikes' }, ...
                    { @smoothSignals, struct('signals','M1_spikes','calc_fr',true,'width',0.05) }, ...
                    { @trimTD, {'idx_startTime',0}, {'idx_endTime',0} }, ...
                    { @trimTD, {'idx_goCueTime',-10},{'idx_goCueTime',25} } );

% Get bands
delta_idx = find(trial_data(1).M1_lfp_guide(:,3)==5);
alpha_idx = find(trial_data(1).M1_lfp_guide(:,3)==15);
beta_idx = find(trial_data(1).M1_lfp_guide(:,3)==30);
gamma1_idx = find(trial_data(1).M1_lfp_guide(:,3)==50);
gamma2_idx = find(trial_data(1).M1_lfp_guide(:,3)==100);
gamma3_idx = find(trial_data(1).M1_lfp_guide(:,3)==200);
gamma4_idx = find(trial_data(1).M1_lfp_guide(:,3)==400);
m_idx = cat(2,delta_idx,alpha_idx,beta_idx,gamma1_idx,gamma2_idx,gamma3_idx,gamma4_idx);
                


name = 'M1_lfp'; lfp_vaf = []; total_idx = 0;
for InputCh = 1:-0.1:0.1
    total_idx = total_idx +1;
    disp(InputCh);
    i = 0; vaf = [];
    for m = 1:5 %Try 5 channel combinations
        aux_td = trial_data;
        channels = randperm(38);
        ch_idx = channels(1:round(38*InputCh));
        ch_idx = m_idx(ch_idx,:); ch_idx = ch_idx(:);
        for n = 1:length(aux_td)
            aux_td(n).M1_lfp = trial_data(n).M1_lfp(:,ch_idx);
        end
        for n = 1:folds
            idx = randperm(length(trial_data));
            i = i+1; %disp(i);
            [vaf(i,1), vaf(i,2),~,~,~,~] = TD_ComputeModelAndPlotLFP(aux_td,BinToPast,idx,name);
        end
    end
    lfp_vaf(total_idx,1) = mean(vaf(:,1)); lfp_vaf(total_idx,2) = mean(vaf(:,2));
    lfp_vaf(total_idx,3) = std(vaf(:,1)); lfp_vaf(total_idx,4) = std(vaf(:,2));
end


name = 'M1_spikes'; spk_vaf = []; total_idx = 0;
for InputCh = 1:-0.1:0.1
    total_idx = total_idx +1;
    disp(InputCh);
    i = 0;  vaf = [];
    for m = 1:5 %Try 5 channel combinations
        aux_td = trial_data;
        channels = randperm(84);
        ch_idx = channels(1:round(84*InputCh));
        for n = 1:length(aux_td)
            aux_td(n).M1_spikes = trial_data(n).M1_spikes(:,ch_idx);
        end
        for n = 1:folds
            idx = randperm(length(trial_data));
            i = i+1; %disp(i);
            [vaf(i,1), vaf(i,2),~,~,~,~] = TD_ComputeModelAndPlotLFP(aux_td,BinToPast,idx,name);
        end
    end
    spk_vaf(total_idx,1) = mean(vaf(:,1)); spk_vaf(total_idx,2) = mean(vaf(:,2));
    spk_vaf(total_idx,3) = std(vaf(:,1)); spk_vaf(total_idx,4) = std(vaf(:,2));
end  


name = 'M1_pca'; lt_vaf = []; total_idx = 0;
for InputCh = 1:-0.1:0.1
    total_idx = total_idx +1;
    disp(InputCh);
    i = 0;  vaf = [];
    for m = 1:5 %Try 5 channel combinations
        aux_td = trial_data;
        channels = randperm(84);
        ch_idx = channels(1:round(84*InputCh));
        for n = 1:length(aux_td)
            aux_td(n).M1_spikes = trial_data(n).M1_spikes(:,ch_idx);
        end
        if length(ch_idx) < pca_dims
            pca_dims = length(ch_idx);
        end
        [aux_td,~] = dimReduce(aux_td, struct('signals','M1_spikes','num_dims',pca_dims));
        for n = 1:folds
            idx = randperm(length(trial_data));
            i = i+1; %disp(i);
            [vaf(i,1), vaf(i,2),~,~,~,~] = TD_ComputeModelAndPlotLFP(aux_td,BinToPast,idx,name);
        end
    end
    lt_vaf(total_idx,1) = mean(vaf(:,1)); lt_vaf(total_idx,2) = mean(vaf(:,2));
    lt_vaf(total_idx,3) = std(vaf(:,1)); lt_vaf(total_idx,4) = std(vaf(:,2));
end  


figure
plot(0:10:90,lfp_vaf(:,1),'b','linewidth',2); 
hold on; plot(0:10:90,spk_vaf(:,1),'r','linewidth',2); 
hold on; plot(0:10:90,lt_vaf(:,1),'g','linewidth',2);
l = legend('LFPs','Spikes','Latent variables'); l.FontSize = 9;
title('X Velocity VAF'); xlabel('Percentage of eliminated inputs'); ylabel('VAF')
set(gca, 'TickDir','out', 'FontName', 'Times New Roman', 'Fontsize', 14), box off
set(gcf, 'Position',  [100, 100, 250, 200])

figure
plot(0:10:90,lfp_vaf(:,2),'b','linewidth',2); 
hold on; plot(0:10:90,spk_vaf(:,2),'r','linewidth',2); 
hold on; plot(0:10:90,lt_vaf(:,2),'g','linewidth',2); 
l = legend('LFPs','Spikes','Latent variables'); l.FontSize = 9;
title('Y Velocity VAF'); xlabel('Percentage of eliminated inputs'); ylabel('VAF')
set(gca, 'TickDir','out', 'FontName', 'Times New Roman', 'Fontsize', 14), box off
set(gcf, 'Position',  [100, 100, 250, 200])
