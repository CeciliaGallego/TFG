close all; clear; clc;

% Open TD ('Chewie_CO_20162110.mat'   'Chewie_CO_CS_2016-10-21.mat')
trial_data = loadTDfiles('Chewie_CO_20162110_ceci.mat',{@getTDidx,{'result','R'}});

% Smooth spikes
trial_data = smoothSignals(trial_data,struct('signals',{{'M1_spikes'}},'width',0.05));

% Get only the data when the monkey is moving
trial_data = trimTD(trial_data, 'idx_goCueTime',{'idx_goCueTime',124});

% Load the mask of modulated bands
load('C:\Users\Cecilia\Documents\MATLAB\Mis scripts\BadChannels.mat')
for trial = 1:length(trial_data)
    mod_trial_data(trial).M1_lfp = trial_data(trial).M1_lfp(:,mask);
end
    

% Get target directions
targets = unique([trial_data.tgtDir]);
idx = zeros(33,8);  % 33 is the minimum number of trials per target
for trial = 1:length(targets)
    [index, a] = getTDidx(trial_data,'tgtDir',targets(trial));
    idx(:,trial) = index(1:33);
end

% % Comparison target by target
% blocks = {}; 
% for trial = 1:33
%     for target = 1:8
%         blocks{trial,target} = mod_trial_data(idx(trial,target)).M1_lfp;
%     end 
% end
% 
% result = [];
% for trial = 1:32
%     data = [];
%     for target = 1:8
%         data = cat(1,data,mean(diag(corr(blocks{trial,target},blocks{trial+1,target}))));
%     end
%     result = cat(2,result,data);
% end
% 
% figure
% boxplot(result)

% % Comparison single target
% for target = 1:8
%     result = [];
%     for trial = 1:32
%         result = cat(2,result,diag(corr(blocks{trial,target},blocks{trial+1,target})));
%     end
% 
%     figure
%     boxplot(result)
% end
% % Comparison block by block
% blocks = {}; 
% for trial = 1:33
%     data = [];
%     for target = 1:8
%         data = cat(1,data,mod_trial_data(idx(trial,target)).M1_lfp);
%     end 
%     blocks{trial} = data;
% end
% 
% result = [];
% for trial = 1:31
%     result = cat(2,result,diag(corr(blocks{trial},blocks{trial+1})));
% end
% figure
% boxplot(result)
 
%%%%%%%%%%%%%%%% CONTINUE HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Single band
% final = [];
% for band = 1:size(mod_trial_data(1).M1_lfp,2)
%     
%     blocks = {}; 
%     for trial = 1:33
%         for target = 1:8
%             blocks{trial,target} = mod_trial_data(idx(trial,target)).M1_lfp(:,band);
%         end 
%     end
% 
%     result = [];
%     for trial = 1:32
%         data = [];
%         for target = 1:8
%             data = cat(1,data,corr(blocks{trial,target},blocks{trial+1,target}));
%         end
%         result = cat(1,result,mean(data));
%     end
% 
%     final(:,end+1) = result;
%     
% 
% end
% figure
% boxplot(final')
%     
% [~,idx] = min(final);
% figure;hist(idx,1:32);

% 
% 
% % Analysis of result for each band
% final = [];
% for band = 1:size(mod_trial_data(1).M1_lfp,2)
%     blocks = {}; 
%     for trial = 1:33
%         for target = 1:8
%             blocks{trial,target} = mod_trial_data(idx(trial,target)).M1_lfp(:,band);
%         end 
%     end
% 
%     result = [];
%     for trial = 1:32
%         data = [];
%         for target = 1:8
%             data = cat(1,data,corr(blocks{trial,target},blocks{trial+1,target}));
%         end
%         result = cat(2,result,mean(data));
%     end
%     final(band,:) = result;
% end
% 
% 
% figure
% for trial = 1:size(final,1)
%     hold on; plot(final(trial,:));
% end

%% New section

% So the same analysis but for an specific frequecy band
for band = 1:7
    blocks = {}; 
    for trial = 1:33
        for target = 1:8
            blocks{trial,target} = trial_data(idx(trial,target)).M1_lfp(:,band:7:672);
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
    
    
%     for target = 1:8
%         result = [];
%         for trial = 1:32
%             result = cat(2,result,diag(corr(blocks{trial,target},blocks{trial+1,target})));
%         end
% 
%         figure
%         boxplot(result)
%     end
end
