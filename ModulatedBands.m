close all; clear; clc;

% Open TD ('Chewie_CO_20162110.mat'   'Chewie_CO_CS_2016-10-21.mat')
trial_data = loadTDfiles('Chewie_CO_20162110_ceci.mat',{@getTDidx,{'result','R'}});

% Get only the data when the monkey is moving
trial_data = trimTD(trial_data, 'idx_goCueTime',{'idx_goCueTime',124});

% Get trials to the same target
target = unique([trial_data.tgtDir]);
avg_data = trialAverage(trial_data,{'tgtDir'});


% % Georgopoulus Tuning Curve
% George_data = binTD(avg_data,size(avg_data(1).pos,1));  % Combine the trial activity into 1 bin
% for band = 1:672
%     points = [];
%     for n = 1:8
%         points(end+1) = (George_data(n).M1_lfp(band));
%     end
%     [f,stats]=fit(target',points','fourier1');
%     figure
%     scatter(target,points,50,'k','filled')
%     hold on; plot(f,'k');
%     xlim([target(1),target(8)])
%     str = ['R^2 = ' num2str(round(stats.rsquare,2))];
%     text(1.5,8.25,str)
% end

% Tunning curves histogram
George_data = binTD(avg_data,size(avg_data(1).pos,1));
r2 = [];
for band = 1:672
    points = [];
    for n = 1:8
        points(end+1) = (George_data(n).M1_lfp(band));
    end    
    [~,stats]=fit(target',points','fourier1');
    r2(end+1) = stats.rsquare;
end
figure
hist(r2);

m = mean (r2); s = std(r2);
disp(m); disp(s);

% I am not using this because I want to study the modulation of each
% individual band

% mod_ch = [];
% for n = 1:7:length(r2)
%     value = mean(r2(n:n+6));
%     if value >= 0.8
%         mod_ch(end+1) = ceil(n/7);
%     end
% end


mask = (r2>=0.8);
% save('mod_channelAndBand.mat','mask');