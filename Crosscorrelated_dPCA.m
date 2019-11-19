%% Initialize data

close all; clear; clc;

% Open TD
filename = 'Mihili_CO_20140303.mat';
trial_data = loadTDfiles(filename,{@getTDidx,{'result','R'}});

% % Smoothing the spikes
% trial_data = smoothSignals(trial_data,struct('signals','M1_spikes','sqrt_transform',true,'do_smoothing',true,'width',0.05));

% Get only the data when the monkey is moving
% trial_data = trimTD(trial_data, {'idx_movement_on',-12},{'idx_movement_on',42});
end_idx = min([trial_data.idx_trial_end]-[trial_data.idx_movement_on]);
ini_idx = min([trial_data.idx_movement_on]);
trial_data = trimTD(trial_data, {'idx_movement_on',-ini_idx+1},{'idx_movement_on',end_idx});

trial_data = binTD(trial_data,3);

%% Do dPCA with all the frequency bands together

mid_idx = round(length(trial_data)/2);
train_td = trial_data(1:mid_idx);
test_td = trial_data(mid_idx+1:end);


% dPCA
params.signals = 'M1_lfp';
params.marg_names = {'time','target'};
params.marg_colors = [150 150 150; 23 100 171]/256; % blue, red
params.do_plot = true;

[~, dPCA_info] = runDPCA(train_td,'tgtDir',params);

decoder = dPCA_info.W;
marg = dPCA_info.which_marg;
var = dPCA_info.expl_var.componentVar;
% 
% c = hsv(8);
% targets = unique([trial_data.tgtDir]);
% mov_idx = trial_data(1).idx_movement_on;
% figure
% for n = 1:9
%     subplot(3,3,n)
%     title([params.marg_names{marg(n)} ' ' num2str(round(var(n))) '%']);
%     for t = 1:8
%         [idx, ~] = getTDidx(test_td,'tgtDir',targets(t));
%         dpc = [];
%         for trial = idx
%             x = test_td(trial).M1_lfp;
%             dpc = cat(2,dpc,x*decoder(:,n));
%         end
%         hold on; plot(mean(dpc,2),'color',c(t,:));
%     end
%     yl = ylim;
%     hold on; line([mov_idx,mov_idx],yl,'color','k')
% end


%% Same but at different frequencies

bands = unique(trial_data(1).M1_lfp_guide(:,3));
low = unique(trial_data(1).M1_lfp_guide(:,2));
% dPCA
params.signals = 'M1_lfp';
params.marg_names = {'time','target'};
params.marg_colors = [150 150 150; 23 100 171]/256; % blue, red
params.do_plot = false;

c = hsv(8);
targets = unique([trial_data.tgtDir]);
mov_idx = trial_data(1).idx_movement_on;

figure
for f = 1:length(bands)
    td = trial_data;
    isFreq = trial_data(1).M1_lfp_guide(:,3) == bands(f);
    for n = 1:length(trial_data)
        td(n).M1_lfp = trial_data(n).M1_lfp(:,isFreq);
    end
    mid_idx = round(length(td)/2);
    train_td = td(1:mid_idx);
    test_td = td(mid_idx+1:end);
    
    
    [~, dPCA_info] = runDPCA(train_td,'tgtDir',params);

    decoder = dPCA_info.W;
    marg = dPCA_info.which_marg;
    var = dPCA_info.expl_var.componentVar;

    
    
    for n = 1:3
        subplot(3,length(bands),((n-1)*length(bands))+f)
        title([params.marg_names{marg(n)} ' ' num2str(round(var(n))) '%  Band ' num2str(low(f)) '-' num2str(bands(f))]);
        for t = 1:8
            [idx, ~] = getTDidx(test_td,'tgtDir',targets(t));
            dpc = [];
            for trial = idx
                x = test_td(trial).M1_lfp;
                dpc = cat(2,dpc,x*decoder(:,n));
            end
            hold on; plot(mean(dpc,2),'color',c(t,:));
        end
        yl = ylim;
        hold on; line([mov_idx,mov_idx],yl,'color','k')
        if f == 1
            ylabel(['Component ' num2str(n)]);
        end
    end
end
suptitle(trial_data(1).monkey);