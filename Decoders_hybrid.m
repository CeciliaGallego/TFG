bin_size = 3;
BinToPast = 5;
name = 'mod_lfp';
folds = 10;
filename = 'Chewie_10_23_2019.mat';

% load('Chewie_CO_CS_2016-10-21.mat');
[trial_data, pars_td] = loadTDfiles( filename, ...
                    { @getTDidx, 'result', 'R' }, ...
                    { @trimTD, {'idx_movement_on',-20}, {'idx_movement_on',70} }, ...
                    { @binTD, bin_size}, ...
                    { @removeBadTrials},...
                    { @sqrtTransform, 'M1_spikes' }, ...
                    { @smoothSignals, struct('signals','M1_spikes','calc_fr',true,'width',0.05) });



total_vaf = [];
disp('lfp'); vaf_lfp = [];
for n = 1:folds
    [vaf_lfp(n,1), vaf_lfp(n,2),~,~,~,~] = TD_ComputeModelAndPlotLFP(trial_data,BinToPast,name);
end
total_vaf(1,1) = mean(vaf_lfp(:,1)); total_vaf(1,2) = mean(vaf_lfp(:,2));
total_vaf(1,3) = std(vaf_lfp(:,1)); total_vaf(1,4) = std(vaf_lfp(:,2));
disp('spikes'); vaf_spk = [];
name = 'M1_spikes';
for n = 1:folds
    [vaf_spk(n,1), vaf_spk(n,2),~,~,~,~] = TD_ComputeModelAndPlotLFP(trial_data,BinToPast,name);
end
total_vaf(2,1) = mean(vaf_spk(:,1)); total_vaf(2,2) = mean(vaf_spk(:,2));
total_vaf(2,3) = std(vaf_spk(:,1)); total_vaf(2,4) = std(vaf_spk(:,2));
disp('hybrid'); vaf_hyb = [];
name = 'M1_lfp'; aux_trial_data = trial_data;
for n = 1:length(trial_data)
    aux_trial_data(n).M1_lfp = cat(2,trial_data(n).M1_lfp,trial_data(n).M1_spikes);
end
for n = 1:folds
    [vaf_hyb(n,1), vaf_hyb(n,2),~,~,~,~] = TD_ComputeModelAndPlotLFP(aux_trial_data,BinToPast,name);
end
total_vaf(3,1) = mean(vaf_hyb(:,1)); total_vaf(3,2) = mean(vaf_hyb(:,2));
total_vaf(3,3) = std(vaf_hyb(:,1)); total_vaf(3,4) = std(vaf_hyb(:,2));

figure
b = bar(total_vaf(:,[1,2]));
b(1).FaceColor = 'b'; b(2).FaceColor = 'r';
hold on
x = [0.85:2.85;1.15:3.15]';
data = total_vaf(:,[1,2]);
e = total_vaf(:,[3,4]);
er = errorbar(x,data,e,e,'LineWidth',1.5);
er(1).Color = [0 0 0];  er(2).Color = [0 0 0];                            
er(1).LineStyle = 'none'; er(2).LineStyle = 'none'; 

l = legend('x velocity component','y velocity component'); l.FontSize = 9;
title('VAF with different inputs'); ylabel('VAF'); 
set(gca, 'XTick', 1:3, 'XTickLabel',{'LFP','Spikes','LFP+Spikes'});