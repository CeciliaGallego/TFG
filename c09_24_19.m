close all; clear; clc;

% Open TD ('Chewie_CO_20162110.mat'   'Chewie_CO_CS_2016-10-21.mat')
trial_data = loadTDfiles('Chewie_CO_20162110.mat',{@getTDidx,{'result','R'}});


% Find movement onset
params.go_cue_name = 'idx_goCueTime';
trial_data = getRWMovements(trial_data,params);


% Smooth spikes
trial_data = smoothSignals(trial_data,struct('signals',{{'M1_spikes'}},'width',0.05));

% Get only the data when the monkey is moving
trial_data = trimTD(trial_data, 'idx_goCueTime',{'idx_goCueTime',124});

% Get target directions
targets = unique(cat(1,trial_data.tgtDir));
idx = zeros(32,8);  % 32 is the minimum number of trials per target
for n = 1:length(targets)
    [index, ~] = getTDidx(trial_data,'tgtDir',targets(n));
    idx(:,n) = index(1:32);
end

% blocks = {}; 
% for n = 1:32
%     data = [];
%     for m = 1:8
%         data = cat(1,data,trial_data(idx(n,m)).M1_lfp);
%     end
%     blocks{n} = data;
% end
% 
% result = [];
% for n = 1:31
%     result = cat(2,result,diag(corr(blocks{n},blocks{n+1})));
% end
% figure
% boxplot(result)

result = [];
for n = 1:31
    cor = [];
    for m = 1:8
        data1 = trial_data(idx(n,m)).M1_lfp;
        data2 = trial_data(idx(n+1,m)).M1_lfp;
        cor = cat(1,cor,diag(corr(data1,data2)));
    end
    result = cat(2,result,cor);
end

figure
boxplot(result)