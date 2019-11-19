close all; clear; clc

% Variables
pca_dims = 10;
bin_size = 3;
BinToPast = 5;
name = 'M1_lfp';
folds = 10;
filename = 'Mihili_CO_20140403.mat';

% load('Chewie_CO_CS_2016-10-21.mat');
[trial_data, pars_td] = loadTDfiles( filename, ...
                    { @getTDidx, 'result', 'R' }, ...
                    { @trimTD, {'idx_movement_on',-12},{'idx_movement_on',42}}, ...
                    { @binTD, bin_size}, ...
                    { @removeBadTrials},...
                    { @sqrtTransform, 'M1_spikes' }, ...
                    { @smoothSignals, struct('signals','M1_spikes','calc_fr',true,'width',0.05) }, ...
                    { @dimReduce, struct('signals',{'M1_spikes'},'algorithm','pca','num_dims',pca_dims)});

band_idx = trial_data(1).M1_lfp_guide(:,3) == 25;    
for n = 1:length(trial_data)
    trial_data(n).M1_lfp = trial_data(n).M1_lfp(:,band_idx);
end

% Get models
for n = 1:folds
    disp(n)
    [vaf_lfp(n,1), vaf_lfp(n,2),x_vel_lfp(:,n),x_est_lfp(:,n),y_vel_lfp(:,n),y_est_lfp(:,n)] = TD_ComputeModelAndPlotLFP(trial_data,BinToPast,name);
end

name = 'M1_spikes';
for n = 1:folds
    disp(n)
    [vaf_spk(n,1), vaf_spk(n,2),x_vel_spk(:,n),x_est_spk(:,n),y_vel_spk(:,n),y_est_spk(:,n)] = TD_ComputeModelAndPlotLFP(trial_data,BinToPast,name);
end

% Plot histograms
figure
subplot(1,2,1)
minimum = min(min(vaf_lfp,vaf_spk));
[d1,edge1] = histcounts(vaf_spk(:,1),minimum(1):0.01:1); 
[d2,edge2] = histcounts(vaf_lfp(:,1),minimum(1):0.01:1);
hold on;
one = bar(edge1(1:end-1),d1,'histc'); two = bar(edge2(1:end-1),d2,'histc');
one.FaceColor = 'r'; two.FaceColor = [.6 .6 .6];
alpha(one,.5); alpha(two,.5); 
l = legend('Spikes','LMP'); l.FontSize = 9;
title('X Velocity VAF'); xlabel('VAF'); ylabel('Counts')

subplot(1,2,2)
[d1,edge1] = histcounts(vaf_spk(:,2),minimum(2):0.01:1); 
[d2,edge2] = histcounts(vaf_lfp(:,2),minimum(2):0.01:1);
hold on;
one = bar(edge1(1:end-1),d1,'histc'); two = bar(edge2(1:end-1),d2,'histc');
one.FaceColor = 'r'; two.FaceColor = [.6 .6 .6];
alpha(one,.5); alpha(two,.5); 
l = legend('Spikes','LMP'); l.FontSize = 9;
title('Y Velocity VAF'); xlabel('VAF'); ylabel('Counts')


% Plot velocity precitions
figure
[~,idx] = max(vaf_lfp);

trial_num = 15;
spacing=15;
subplot(2,2,1)
last_pos=0;
trial_length=length(x_est_lfp(:,idx(1)))/30;
for m=1:(trial_num*trial_length)
    if rem(m,trial_length)==0
        time=last_pos+1:last_pos+trial_length;
        x=x_vel_lfp(m-trial_length+1:m,idx(1));
        y=x_est_lfp(m-trial_length+1:m,idx(1));
        last_pos=last_pos+trial_length+spacing;
        hold on; plot(time,x(:,1),'b');hold on; plot(time,y(:,1),'r');
    end
end
title(['X velocity LMP: VAF ' num2str(vaf_lfp(idx(1),1))]);

subplot(2,2,2)
last_pos=0;
for m=1:(trial_num*trial_length)
    if rem(m,trial_length)==0
        time=last_pos+1:last_pos+trial_length;
        x=y_vel_lfp(m-trial_length+1:m,idx(2));
        y=y_est_lfp(m-trial_length+1:m,idx(2));
        last_pos=last_pos+trial_length+spacing;
        hold on; plot(time,x(:,1),'b');hold on; plot(time,y(:,1),'r');
    end
end
title(['Y velocity LMP: VAF ' num2str(vaf_lfp(idx(2),2))]);



[~,idx] = max(vaf_spk);

trial_num = 15;
spacing=15;
subplot(2,2,3)
last_pos=0;
trial_length=length(x_est_spk(:,idx(1)))/30;
for m=1:(trial_num*trial_length)
    if rem(m,trial_length)==0
        time=last_pos+1:last_pos+trial_length;
        x=x_vel_spk(m-trial_length+1:m,idx(1));
        y=x_est_spk(m-trial_length+1:m,idx(1));
        last_pos=last_pos+trial_length+spacing;
        hold on; plot(time,x(:,1),'b');hold on; plot(time,y(:,1),'r');
    end
end
title(['X velocity Spikes: VAF ' num2str(vaf_spk(idx(1),1))]);

subplot(2,2,4)
last_pos=0;
for m=1:(trial_num*trial_length)
    if rem(m,trial_length)==0
        time=last_pos+1:last_pos+trial_length;
        x=y_vel_spk(m-trial_length+1:m,idx(2));
        y=y_est_spk(m-trial_length+1:m,idx(2));
        last_pos=last_pos+trial_length+spacing;
        hold on; plot(time,x(:,1),'b');hold on; plot(time,y(:,1),'r');
    end
end
title(['Y velocity Spikes: VAF ' num2str(vaf_spk(idx(2),2))]);
