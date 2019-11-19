close all; clear; clc;

% Open TD
trial_data = loadTDfiles('Chewie_CO_20162110.mat',{@getTDidx,{'result','R'}});

td = trimTD(trial_data, {'idx_movement_on',-100},{'idx_movement_on',80});
td = trialAverage(td,'tgtDir');

idx_mov = td(1).idx_movement_on;

% Kinematic data
c = hsv(8);
figure
for n = 1:8
    subplot(2,3,1)
    hold on; plot(td(n).pos(:,1),td(n).pos(:,2)+30,'color',c(n,:));
    title('2D plane');
    subplot(2,3,2)
    hold on; plot(td(n).pos(:,1),'color',c(n,:));
    hold on; line([idx_mov, idx_mov], ylim)
    title('X position');
    subplot(2,3,3)
    hold on; plot(td(n).pos(:,2)+30,'color',c(n,:));
    hold on; line([idx_mov, idx_mov], ylim)
    title('Y position');
    subplot(2,3,5)
    hold on; plot(td(n).vel(:,1),'color',c(n,:));
    hold on; line([idx_mov, idx_mov], ylim)
    title('X velocity');
    subplot(2,3,6)
    hold on; plot(td(n).vel(:,2),'color',c(n,:));
    hold on; line([idx_mov, idx_mov], ylim)
    title('Y velocity');
end

% Firing rate
td = smoothSignals(td,struct('signals','M1_spikes','calc_fr',true,'width',0.05));
figure
count = 0;
for n = 1:9
    count = count +1;
    subplot(3,3,count)
    for t = 1:8
        hold on; plot(td(t).M1_spikes(:,n),'color',c(t,:));
    end
    hold on; line([idx_mov, idx_mov], ylim)
    title(['Neuron ' num2str(n)]);
end
    
% PCA
[td,~] = dimReduce(td, struct('signals','M1_spikes','num_dims',10));
figure
count = 0;
for d = 1:9
    count = count +1;
    subplot(3,3,count)
    for n = 1:8
        hold on; plot(td(n).M1_pca(:,d),'color',c(n,:))
    end
    hold on; line([idx_mov, idx_mov], ylim)
    title(['Component ' num2str(d)]);
end

% LFP
figure
freq = length(unique(td(1).M1_lfp_guide(:,3)));
count = 0;
for ch = 50:52
    for f = 1:freq
        count = count +1;
        subplot(3,freq,count)
        for n = 1:8
            hold on; plot(td(n).M1_lfp(:,(f-1)*96+ch),'color',c(n,:));
        end
        hold on; line([idx_mov, idx_mov], ylim)
        title(['Channel ' num2str(ch) ', Freq ' num2str(f)]);
    end
end