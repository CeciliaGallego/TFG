close all; clear; clc;

filename = 'Chewie_CO_20161410.mat';
toSave = false;
monkey = 'Chewie';

% Open TD
trial_data = loadTDfiles(filename,{@getTDidx,{'result','R'}});
trial_data = smoothSignals(trial_data,struct('signals','M1_spikes','sqrt_transform',true,'do_smoothing',true,'width',0.05));
trial_data = trimTD(trial_data, {'idx_movement_on',-100},{'idx_movement_on',42});
trial_data = binTD(trial_data,3);


%  Get each band
bands = unique(trial_data(1).M1_lfp_guide(:,3));
min_f = unique(trial_data(1).M1_lfp_guide(:,2));
name = {}; explained = [];

% Do PCA
figure
c = parula(length(bands));
for f = 1:length(bands)
    signal = [];
    isFreq = trial_data(1).M1_lfp_guide(:,3) == bands(f);
    for n = 1:length(trial_data)
        signal = cat(1,signal,trial_data(n).M1_lfp(:,isFreq));
    end
    [~,~,~,~,var] = pca(signal);
    explained = cat(2,explained,var);
    
    hold on; 
    plot(cumsum(var),'color',c(f,:));
    name{end+1} = [num2str(min_f(f)) '-' num2str(bands(f))];
end
legend(name)

if toSave
    save(['PCA_' filename],'explained')
end


% Do dPCA
params.signals = 'M1_lfp';
params.marg_names = {'time','target'};
params.marg_colors = [150 150 150; 23 100 171]/256; % blue, red
params.do_plot = true;

explained = []; name = {};
for f = 1:length(bands)
    isFreq = trial_data(1).M1_lfp_guide(:,3) == bands(f);
    td = trial_data;
    for n = 1:length(trial_data)
        td(n).M1_lfp = trial_data(n).M1_lfp(:,isFreq);
    end
    [~, dPCA_info] = runDPCA(td,'tgtDir',params);
    aux = sum(dPCA_info.expl_var.margVar,2);
    explained = cat(2,explained,aux);
    name{end+1} = [num2str(min_f(f)) '-' num2str(bands(f))];
    pause
end
figure
bar(explained');
set(gca, 'XTick', 1:9, 'XTickLabel',name);
xlabel('Frequency bands'); ylabel('% variance explained');
legend('Time','Target'); title(monkey);

if toSave
    save(['dPCA_' filename],'explained')
end



% Plot results

load(['dPCA_' filename]);
load(['VAF_' filename]);


vaf = mean(total_vaf(1:end-1,1:2),2);
tgt_var = explained(2,:);

bands = 1:9; 
figure
yyaxis left; b = bar(bands,tgt_var); yyaxis right; p = plot(bands,vaf);
title(monkey); xlabel('Frequecy bands'); yyaxis left; ylabel('% Variance (target)'); yyaxis right; ylabel('Decoder performance (VAF)')

name = {'LMP','0.5-4','4-8','8-12','12-25','25-50','50-100','100-200','200-400'};
set(gca, 'XTick', 1:9, 'XTickLabel',name);