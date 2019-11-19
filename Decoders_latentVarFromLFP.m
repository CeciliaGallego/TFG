% close all; 
clear all; clc
%% Individual frequency decoders

toSave = false;
pca_dims = 10;
bin_size = 3;
BinToPast = 5;
name = 'M1_lfp';
folds = 2;
filename = 'Mihili_CO_20140303.mat';

% load('Chewie_CO_CS_2016-10-21.mat');
[trial_data, pars_td] = loadTDfiles( filename, ...
                    { @getTDidx, 'result', 'R' }, ...
                    { @trimTD, {'idx_movement_on',-12}, {'idx_movement_on',42} }, ...
                    { @binTD, bin_size}, ...
                    { @removeBadTrials},...
                    { @sqrtTransform, 'M1_spikes' }, ...
                    { @smoothSignals, struct('signals','M1_spikes','calc_fr',true,'width',0.05) }, ...
                    { @dimReduce, struct('signals',{'M1_spikes'},'algorithm','pca','num_dims',pca_dims)});
 

guide = trial_data(1).([name '_guide']);
band = unique(guide(:,3));


% Single frquencies
total_vaf = []; total_std = [];
for m = 1:length(band)
    disp(m)
    aux_trial_data = trial_data;
    band_idx = guide(:,3) == band(m);
    for n = 1:length(trial_data)
        aux_trial_data(n).(name) = trial_data(n).(name)(:,band_idx);
    end
    vaf = [];
    for n = 1:folds
        [vaf(n,:), actual, predicted] = TD_ComputeModelLFPtoLatVar(aux_trial_data,BinToPast,name);
    end
    total_vaf(m,:) = mean(vaf); total_std(m,:) = std(vaf);
end
% All the frequencies together
disp(m+1); vaf = [];
for n = 1:folds
    idx = randperm(length(trial_data(1).M1_lfp(1,:)));
    for k = 1:length(trial_data)
        aux_trial_data(k).(name) = trial_data(k).(name)(:,idx(1:96));
    end
    disp(n)
    [vaf(n,:), actual, predicted] = TD_ComputeModelLFPtoLatVar(aux_trial_data,BinToPast,name);
end
total_vaf(m+1,:) = mean(vaf); total_std(m+1,:) = std(vaf);

figure
b = bar(total_vaf(:,[1,2,3,4]));
x = repmat(xticks,4,1);
x(1,:) = x(1,:) - 0.27;
x(2,:) = x(2,:) - 0.1;
x(3,:) = x(3,:) + 0.1;
x(4,:) = x(4,:) + 0.27;

hold on
data = total_vaf(:,[1,2,3,4]);
e = total_std(:,[1,2,3,4]);
er = errorbar(x',data,e,e);
er(1).Color = [0 0 0];  er(2).Color = [0 0 0];  er(3).Color = [0 0 0];  er(4).Color = [0 0 0];                            
er(1).LineStyle = 'none'; er(2).LineStyle = 'none'; er(3).LineStyle = 'none'; er(4).LineStyle = 'none'; 

title('Latent variable decoder form LFP'); ylabel('VAF'); xlabel('Frequency (Hz)');
bands = {'LMP','0.5-4','4-8','8-12','12-25','25-50','50-100','100-200','200-400','All'};
set(gca, 'XTick', 1:10, 'XTickLabel',bands);
 
if toSave
    save(['VAF_' filename],'total_vaf');
end

