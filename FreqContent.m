close all; clear all; clc;


filename = 'Chewie_CO_20162110.mat';
% filename = 'Mihili_CO_20140403.mat';
% filename = 'TestTrialData.mat';
trial_data = loadTDfiles(filename,{@getTDidx,{'result','R'}});

% % Get only the data when the monkey is moving
idx_end = cumsum([trial_data.idx_trial_end]);
relative_idx_mov = [trial_data.idx_movement_on];
idx_mov = zeros(1,length(trial_data));
for n = 1:length(trial_data)
    if n == 1
        idx_mov(n) = relative_idx_mov(n);
    else
        idx_mov(n) = relative_idx_mov(n)+idx_end(n-1);
    end
end
intertrial_time = mean(diff(idx_mov));
intertrial_freq = 1/(intertrial_time*trial_data(1).bin_size);

% Smooth spikes
trial_data = smoothSignals(trial_data,struct('signals',{{'M1_spikes'}},'width',0.05));


% Manually do PCA over all the dataset (without trim)
% spikes = detrend(cell2mat({trial_data.M1_spikes}'),0);
% lfp = detrend(cell2mat({trial_data.M1_lfp}'),0);
% vel = detrend(cell2mat({trial_data.vel}'),0);
spikes = cell2mat({trial_data.M1_spikes}');
lfp = cell2mat({trial_data.M1_lfp}');
guide = trial_data(1).M1_lfp_guide;
vel = cell2mat({trial_data.vel}');
t = 0:trial_data(1).bin_size:trial_data(1).bin_size*(length(vel(:,1))-1);


[~,pc] = pca(spikes);


fs = 1/trial_data(1).bin_size;
n = length(pc(:,1));  
f = (0:n-1)*(fs/n);


y = fft(vel);
vel_power = abs(y).^2/n;
figure; subplot(1,2,1); semilogy(f,vel_power(:,1)); 
xlabel('Frequency'); ylabel('Power'); xlim([0 f(end)/2]);
% hold on; line([intertrial_freq,intertrial_freq],ylim,'color','k')
subplot(1,2,2); semilogy(f,vel_power(:,2));
xlabel('Frequency'); ylabel('Power'); xlim([0 f(end)/2]);
% hold on; line([intertrial_freq,intertrial_freq],ylim,'color','k')
    
y = fft(pc(:,1:8));
pca_power = abs(y).^2/n;
figure; semilogy(f,pca_power(:,1:8)); xlabel('Frequency'); ylabel('Power'); xlim([0 f(end)/2]); %ylim([10^-5,10^5])
% hold on; line([intertrial_freq,intertrial_freq],ylim,'color','k')


bands = unique(trial_data(1).M1_lfp_guide(:,3));
low = unique(trial_data(1).M1_lfp_guide(:,2));
lfp_power = [];
figure
for freq = 1:length(bands)
    isFreq = guide(:,3) == bands(freq);
    data = lfp(:,isFreq);
    y = fft(data);
    power = abs(y).^2/n;
    lfp_power = cat(3,lfp_power,power);
    subplot(3,3,freq); 
%     for n = 1:5:95
%         semilogy(f,power(:,n:n+4)); xlabel('Frequency'); ylabel('Power'); xlim([0 50]);
%         pause(0.5)
%         cla
%     end
        
    semilogy(f,mean(power,2)); xlabel('Frequency'); ylabel('Power'); xlim([0 f(end)/2]);% ylim([10^0 10^10])
% %     hold on; line([intertrial_freq,intertrial_freq],ylim,'color','k')
    title(['Band ' num2str(low(freq)) ' - ' num2str(bands(freq))]);
end

disp('Now see the graphs and change the limits');

% Area under the curve
%Frequency limits
low = input('Lower frequency (recommended ~0.2): ');
high = input('Higher frequency: ');

power = pca_power(:,1);
Ce = sum(power((f>= low) & (f<=high)))/sum(power(f>= low));
disp(Ce)

for band = 1:length(bands)
    power = mean(lfp_power(:,:,band),2);
    Ce = sum(power((f>= low) & (f<=high)))/sum(power(f>= low));
    disp([num2str(band) ' ' num2str(Ce)])
end

power = vel_power(:,1);
Ce = sum(power((f>= low) & (f<=high)))/sum(power(f>= low));
disp(Ce)