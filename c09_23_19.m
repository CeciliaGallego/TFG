% This is a trial
close all; clear; clc;

% Open TD ('Chewie_CO_20162110.mat'   'Chewie_CO_CS_2016-10-21.mat')
trial_data = loadTDfiles('Chewie_CO_20162110.mat',{@getTDidx,{'result','R'}});
c = parula(8);
% % Change bin size
% trial_data = binTD(trial_data,1);  %how many bins do you want to combine

% Get only the data when the monkey is moving
trial_data = trimTD(trial_data, 'idx_goCueTime',{'idx_goCueTime',120});

% Smooth spikes
trial_data = smoothSignals(trial_data,struct('signals',{{'M1_spikes'}},'width',0.05));

% Do PCA
[trial_data,params_pca] = dimReduce(trial_data, struct('signals','M1_spikes','num_dims',10));

figure
fq = trial_data(1).M1_lfp_guide(1:7,3);
bands = {'0-5','5-15','15-30','30-50','50-100','100-200','200-400','all'};
r = [];

for m = 1:7
    a = []; b = [];
    % Get a frequency
    for n = 1: length(trial_data)
        isFreq = trial_data(n).M1_lfp_guide(:,3) == fq(m); % Maximum frequency == 5
        trial_data(n).M1_lfp_SingleFreq = trial_data(n).M1_lfp(:,isFreq);
        a = cat(1,a,trial_data(n).M1_lfp_SingleFreq);
        b = cat(1,b,trial_data(n).M1_pca);
%         [~,~,aux] = canoncorr(trial_data(n).M1_lfp_SingleFreq,trial_data(n).M1_pca);
%         r = cat(1,r,aux);
    end
    [~,~,aux] = canoncorr(a,b);
    r = cat(1,r,aux);
    hold on; plot(r(m,:),'color',c(m,:));
    
end
a = []; b = [];
for n = 1: length(trial_data)
    a = cat(1,a,trial_data(n).M1_lfp);
    b = cat(1,b,trial_data(n).M1_pca);
end
[~,~,aux] = canoncorr(a,b);
r = cat(1,r,aux);
hold on; plot(r(8,:),'color',c(8,:));
legend(bands)

% % Get one target
% targets = unique(cat(1,trial_data.tgtDir));
% [~, data_target] = getTDidx(trial_data,'tgtDir',targets(5));

% c = CorrelationMatrix(data_target,'SingleFreq',1);
