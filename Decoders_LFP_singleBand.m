% close all; 
clear all; clc
%% Individual frequency decoders

toSave = true;
bin_size = 3;
BinToPast = 5;
name = 'M1_lfp';
folds = 50;
filename = 'Chewie_CO_20161410_2.mat';

% load('Chewie_CO_CS_2016-10-21.mat');
[trial_data, pars_td] = loadTDfiles( filename, ...
                    { @getTDidx, 'result', 'R' }, ...
                    { @trimTD, {'idx_movement_on',-12}, {'idx_movement_on',42} }, ...
                    { @binTD, bin_size}, ...
                    { @removeBadTrials},...
                    { @sqrtTransform, 'M1_spikes' }, ...
                    { @smoothSignals, struct('signals','M1_spikes','calc_fr',true,'width',0.05) });
 

guide = trial_data(1).([name '_guide']);
band = unique(guide(:,3));

% Single frquencies
total_vaf = [];
for m = 1:length(band)
    disp(m)
    aux_trial_data = trial_data;
    band_idx = guide(:,3) == band(m);
    for n = 1:length(trial_data)
        aux_trial_data(n).(name) = trial_data(n).(name)(:,band_idx);
    end
    vaf = [];
    for n = 1:folds
        [vaf(n,1), vaf(n,2),~,~,~,~] = TD_ComputeModelAndPlotLFP(aux_trial_data,BinToPast,name);
    end
    total_vaf(m,1) = mean(vaf(:,1)); total_vaf(m,2) = mean(vaf(:,2));
    total_vaf(m,3) = std(vaf(:,1)); total_vaf(m,4) = std(vaf(:,2));
end
% All the frequencies together
disp(m+1); vaf = [];
for n = 1:folds
    idx = randperm(length(trial_data(1).M1_lfp(1,:)));
    for k = 1:length(trial_data)
        aux_trial_data(k).(name) = trial_data(k).(name)(:,idx(1:96));
    end
    disp(n)
    [vaf(n,1), vaf(n,2),~,~,~,~] = TD_ComputeModelAndPlotLFP(aux_trial_data,BinToPast,name);
end
total_vaf(m+1,1) = mean(vaf(:,1)); total_vaf(m+1,2) = mean(vaf(:,2));
total_vaf(m+1,3) = std(vaf(:,1)); total_vaf(m+1,4) = std(vaf(:,2));

figure
b = bar(total_vaf(:,[1,2]));
b(1).FaceColor = 'b'; b(2).FaceColor = 'r';
hold on
x = [0.85:9.85;1.15:10.15]';
data = total_vaf(:,[1,2]);
e = total_vaf(:,[3,4]);
er = errorbar(x,data,e,e,'LineWidth',1.5);
er(1).Color = [0 0 0];  er(2).Color = [0 0 0];                            
er(1).LineStyle = 'none'; er(2).LineStyle = 'none'; 

l = legend('x velocity component','y velocity component'); l.FontSize = 9;
title('VAF at different frequencies'); ylabel('VAF'); xlabel('Frequency (Hz)');
bands = {'LMP','0.5-4','4-8','8-12','12-25','25-50','50-100','100-200','200-400','All'};
set(gca, 'XTick', 1:10, 'XTickLabel',bands);
 
if toSave
    save(['VAF_' filename],'total_vaf');
end

