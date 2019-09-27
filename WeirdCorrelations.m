close all; clear; clc;

% Open TD ('Chewie_CO_20162110.mat'   'Chewie_CO_CS_2016-10-21.mat')
trial_data = loadTDfiles('Chewie_CO_20162110_ceci.mat',{@getTDidx,{'result','R'}});

% Get only the data when the monkey is moving
trial_data = trimTD(trial_data, 'idx_goCueTime',{'idx_goCueTime',124});

% Get trials to the same target
targets = unique([trial_data.tgtDir]);


for band = 1:size(trial_data(1).M1_lfp,2)
    figure
    for n = 1:8
        [~,td_tgt] = getTDidx(trial_data,'tgtDir',targets(n));
        lfps = [];
        for m = 1:length(td_tgt)
            lfps = cat(2,lfps,td_tgt(m).M1_lfp(:,band));
        end
        cor = corr(lfps);
        subplot(2,4,n)
        imagesc(cor); colormap 'jet'; caxis([-1 1]); %colorbar;
        title(round(targets(n),2));

    end
    pause
end

% 
% [~,td_tgt] = getTDidx(trial_data,'tgtDir',targets(1));
% lfps = [];
% for m = 1:length(td_tgt)
%     lfps = cat(2,lfps,td_tgt(m).M1_lfp(:,3));
% end
% cor = corr(lfps);
% figure
% imagesc(cor); colormap 'jet'; caxis([-1 1]); colorbar;
% title(round(targets(1),2));
% 
% mask = tril(true(size(cor)),-1);
% out = cor(mask);
% figure; hist(out);

for band = 1:7:672
    tgt = 1; line = 7;
    [~,td_tgt] = getTDidx(trial_data,'tgtDir',targets(tgt));
    lfps = [];
    for m = 1:length(td_tgt)
        lfps = cat(2,lfps,td_tgt(m).M1_lfp(:,band));
    end
    cor = corr(lfps);
%     figure
%     imagesc(cor); colormap 'jet'; caxis([-1 1]); colorbar;
    figure
    for m = 1:length(td_tgt)
        if cor(m,line) >= 0.4
            hold on; plot(td_tgt(m).M1_lfp(:,band),'r');
        elseif (cor(m,line) >= 0) && (cor(m,1) < 0.4)
            hold on; plot(td_tgt(m).M1_lfp(:,band),'g');
        else 
            hold on; plot(td_tgt(m).M1_lfp(:,band),'b');
        end
    end
    pause(2)
end


% total_cor = {};
% for n = 1:8
%     [~,td_tgt] = getTDidx(trial_data,'tgtDir',targets(n));
%     for k = 1:672
%         lfps = [];
%         for m = 1:length(td_tgt)
%             lfps = cat(2,lfps,td_tgt(m).M1_lfp(:,k));
%         end
%         cor = corr(lfps);
% 
%         mask = tril(true(size(cor)),-1);
%         total_cor{n,k} = cor(mask);
%     end
% end
% 
% wierd = [];
% for k = 1:672
%     for n = 1:8
%         [count,cent] = hist(total_cor{n,k});
%         [~,pos]=min(count);
%         m_cor = cent(pos);
%         if abs(m_cor) < 0.15
%             wierd(end+1,1) = k;
%             wierd(end,2) = n;
%         end
%     end
% end