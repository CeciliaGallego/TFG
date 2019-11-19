close all; clear; clc;

% Open TD ('Chewie_CO_20162110.mat'   'Chewie_CO_CS_2016-10-21.mat')
trial_data = loadTDfiles('Mihili_CO_20140603.mat',{@getTDidx,{'result','R'}});

% Smoothing the spikes
trial_data = smoothSignals(trial_data,struct('signals','M1_spikes','sqrt_transform',true,'do_smoothing',true,'width',0.05));

% Get only the data when the monkey is moving
trial_data = trimTD(trial_data, {'idx_movement_on',-12},{'idx_movement_on',42});
% trial_data = trimTD(trial_data, {'idx_movement_on',-100},{'idx_movement_on',50});

% Choose modulated channels
trial_data = ChooseCh(trial_data,0.7);

% Get targets
targets = unique([trial_data.tgtDir]);
guide = trial_data(1).mod_lfp_guide;
bands = unique(guide(:,2));
X = [];

channels = unique(guide(:,1));
for t = 1:8
    [~,td] = getTDidx(trial_data,'tgtDir',targets(t));
    signals = [td.mod_lfp];
    aux_guide = repmat(guide,length(td),1);
    for f = 1:7
        f_idx = find(aux_guide(:,2) == bands(f));
        for ch = 1:length(channels)
            ch_idx = find(aux_guide(:,1) == channels(ch)); 
            idx = intersect(f_idx,ch_idx);
            aux = mean(signals(:,idx),2);
            X(ch,:,f,t) = aux;
        end
    end
end

num_dims = 15;
[W, V, whichMarg] = dpca(X, num_dims, 'combinedParams', {{1},{2, [1 2]},{3, [1 3]}});

expl_var = dpca_explainedVariance(X, W, V,'combinedParams', {{1},{2, [1 2]},{3, [1 3]}});
marg_names = {'time','frequency','target'};
marg_colors = [150 150 150; 23 100 171; 187 20 25]/256; % blue, red, grey, purple
T = size(trial_data(1).mod_lfp,1);
time = (1:T)*trial_data(1).bin_size;

% dpca_plot(X, W, V, @dpca_plot_td, ...
%     'explainedVar', expl_var, ...
%     'marginalizationNames', marg_names, ...
%     'marginalizationColours', marg_colors, ...
%     'whichMarg', whichMarg,                 ...
%     'time', time,                        ...
%     'timeEvents', 1,               ...
%     'timeMarginalization', 1, ...
%     'legendSubplot', num_dims);

pc = 10;
c_t = hsv(8);
c_f = parula(7);
figure
for n = 1:pc
    subplot(2,pc,n); title(marg_names{whichMarg(n)});
    if n == 1
        subplot(2,pc,1); ylabel('Target'); subplot(2,pc,pc+1); ylabel('Frequency')
    end
end
aux = squeeze(mean(X,3));
aux = permute(aux,[2,1,3]);
for t = 1:8
    pcs = aux(:,:,t)*W;
    for n = 1:pc
        subplot(2,pc,n);
        hold on; plot(pcs(:,n),'color',c_t(t,:))
    end
end

aux = squeeze(mean(X,4));
aux = permute(aux,[2,1,3]);
for f = 1:7
    pcs = aux(:,:,f)*W;
    for n = 1:pc
        subplot(2,pc,n+pc);
        hold on; plot(pcs(:,n),'color',c_f(f,:))
    end
end