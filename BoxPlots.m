close all; clear; clc;

% Open TD ('Chewie_CO_20162110.mat'   'Chewie_CO_CS_2016-10-21.mat')
trial_data = loadTDfiles('Chewie_CO_20162110_ceci.mat',{@getTDidx,{'result','R'}});

% Smooth spikes
trial_data = smoothSignals(trial_data,struct('signals',{{'M1_spikes'}},'width',0.05));

% Get only the data when the monkey is moving
trial_data = trimTD(trial_data, 'idx_goCueTime',{'idx_goCueTime',124});

% Get target directions
targets = unique([trial_data.tgtDir]);
idx = zeros(33,8);  % 33 is the minimum number of trials per target
for n = 1:length(targets)
    [index, a] = getTDidx(trial_data,'tgtDir',targets(n));
    idx(:,n) = index(1:33);
end

% Comparison target by target
blocks = {}; 
for n = 1:33
    for m = 1:8
        blocks{n,m} = trial_data(idx(n,m)).M1_lfp;
    end 
end

result = [];
for n = 1:32
    data = [];
    for m = 1:8
        data = cat(1,data,diag(corr(blocks{n,m},blocks{n+1,m})));
    end
    result = cat(2,result,data);
end

figure
boxplot(result)



% Comparison block by block
blocks = {}; 
for n = 1:33
    data = [];
    for m = 1:8
        data = cat(1,data,trial_data(idx(n,m)).M1_lfp);
    end 
    blocks{n} = data;
end

result = [];
for n = 1:31
    result = cat(2,result,diag(corr(blocks{n},blocks{n+1})));
end
figure
boxplot(result)

%% New section

% So the same analysis but for an specific frequecy band
for band = 1:7
    blocks = {}; 
    for n = 1:33
        for m = 1:8
            blocks{n,m} = trial_data(idx(n,m)).M1_lfp(:,band:7:672);
        end 
    end

    % Only one boxplot
    result = [];
    for n = 1:32
        data = [];
        for m = 1:8
            data = cat(1,data,diag(corr(blocks{n,m},blocks{n+1,m})));
        end
        result = cat(2,result,data);
    end

    figure
    boxplot(result)
end
