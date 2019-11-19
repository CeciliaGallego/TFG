function [result,info] = DecoderMovementOnset(filename,boot)

% Variables
bin_size = 3;
BinToPast = 5;
name = 'M1_lfp';
folds = 20;
% filename = 'Mihili_CO_20140403.mat';
% boot = false

% load('Chewie_CO_CS_2016-10-21.mat');
[trial_data, ~] = loadTDfiles( filename, ...
                    { @getTDidx, 'result', 'R' }, ...
                    { @binTD, bin_size}, ...
                    { @removeBadTrials},...
                    { @sqrtTransform, 'M1_spikes' }, ...
                    { @smoothSignals, struct('signals','M1_spikes','calc_fr',true,'width',0.05) });

                

% Get single band   &   Change velocity field
bands = unique(trial_data(1).M1_lfp_guide(:,3));
    
for n = 1:length(trial_data)
    aux = zeros(size(trial_data(n).vel));
    idx = trial_data(n).idx_movement_on;
    if boot
        idx = randi([11 size(trial_data(n).vel,1)-11]);  %%% This is for bootstraping 
    end
    aux(idx-10:idx+10,:) = 1;
    trial_data(n).vel = aux;
end



% Get models
vaf = {}; act = {};
for b = 1:length(bands)
    disp(['Band ' num2str(b) ' of ' num2str(length(bands))])
    td = trial_data;
    band_idx = trial_data(1).M1_lfp_guide(:,3) == bands(b);
    for n = 1:length(trial_data)
        td(n).M1_lfp = trial_data(n).M1_lfp(:,band_idx);
    end
    aux_vaf = zeros(folds,2); aux_act = []; aux_pred = [];
    for n = 1:folds
        disp(['Fold ' num2str(n) ' of ' num2str(folds)])
        [aux_vaf(n,1), aux_vaf(n,2),aux_act_x,aux_pred_x,~,aux_pred_y] = TD_ComputeModelAndPlotLFP(td,BinToPast,name);

        % save as doubles
        aux_act = cat(1,aux_act,aux_act_x);
        aux_pred = cat(1,aux_pred,[aux_pred_x aux_pred_y]);
    end
    vaf{b} = aux_vaf;
    act{b} = aux_act;
    est{b} = aux_pred;
end



name = 'M1_spikes'; disp('Spikes');
aux_vaf = zeros(n,1); aux_act = []; aux_pred = [];
for n = 1:folds
    disp(['Fold ' num2str(n) ' of ' num2str(folds)])
    [aux_vaf(n,1), aux_vaf(n,2),aux_act_x,aux_pred_x,~,aux_pred_y] = TD_ComputeModelAndPlotLFP(trial_data,BinToPast,name);
    
    % save as doubles
    aux_act = cat(1,aux_act,aux_act_x);
    aux_pred = cat(1,aux_pred,[aux_pred_x aux_pred_y]);
end
vaf{b+1} = aux_vaf;
act{b+1} = aux_act;
est{b+1} = aux_pred;


% % Plot velocity precitions
% figure
% duration = 1:3000;
% band = 4;
% 
% subplot(2,2,1)
% plot(act{band}(duration),'b');
% hold on; plot(est{band}(duration,1),'r');
% title(['X Data ' num2str(band) ': VAF ' num2str(mean(vaf{band}(:,1)))]);
% 
% 
% subplot(2,2,2)
% plot(act{band}(duration),'b');
% hold on; plot(est{band}(duration,2),'r');
% title(['Y Data ' num2str(band) ': VAF ' num2str(mean(vaf{band}(:,2)))]);
% 
% % For spikes
% band = length(vaf);
% band = 5;
%     
% subplot(2,2,3)
% plot(act{band}(duration),'b');
% hold on; plot(est{band}(duration,1),'r');
% title(['X Data ' num2str(band) ': VAF ' num2str(mean(vaf{band}(:,1)))]);
% 
% 
% subplot(2,2,4)
% plot(act{band}(duration),'b');
% hold on; plot(est{band}(duration,2),'r');
% title(['Y Data ' num2str(band) ': VAF ' num2str(mean(vaf{band}(:,2)))]);



% Get value

for band = 1:length(vaf)
    actual = act{band};
    prediction = est{band};
    for n = 1:2  % X and Y components
        signal = prediction(:,n);  % It has to be a vector
        thres = 2*rms(signal);  % Maybe dependent of rms (1.5*rms(est))
        err = 10;   % Number of samples before and after movement onset allowed

        % Find peaks
        [peak,loc] = findpeaks(envelope(signal(:,1),5,'peak'));
        loc = loc(peak>=thres);
        % Find idx of movement
        mov = find(diff(actual)==1)+11;
        bool = actual == 1;
        bool(mov-err:mov+err) = true;
        % Whether peaks are in thre movement range
        good_peaks = bool(loc) == true;

        result(band,n) = (sum(good_peaks)/length(good_peaks))*100;
    end
end
% figure; bar(result)
% xticks(1:10); xticklabels({'LMP','delta','theta','alpha','beta','30-50','50-100','100-200','200-400','Spikes'}) 

info.folds = folds;
info.filename = filename;
info.boot = boot;
info.ticks = {'LMP','delta','theta','alpha','beta','30-50','50-100','100-200','200-400','Spikes'};
info.vaf = vaf;
info.act = act;
info.est = est;

end