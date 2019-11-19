close all; clear; clc

% Variables
pca_dims = 10;
bin_size = 3;
BinToPast = 5;
name = 'M1_lfp';
folds = 3;
filename = 'Chewie_CO_20162110.mat';

% load('Chewie_CO_CS_2016-10-21.mat');
[trial_data, pars_td] = loadTDfiles( filename, ...
                    { @getTDidx, 'result', 'R' }, ...
                    { @binTD, bin_size}, ...
                    { @removeBadTrials},...
                    { @sqrtTransform, 'M1_spikes' }, ...
                    { @smoothSignals, struct('signals','M1_spikes','calc_fr',true,'width',0.05) }, ...
                    { @dimReduce, struct('signals',{'M1_spikes'},'algorithm','pca','num_dims',pca_dims)});

                
% Choose modulated channels
% trial_data = ChooseCh(trial_data,0.7);

% Take a single frequency
idx = trial_data(1).([name '_guide'])(:,3) == 0;
for n = 1:length(trial_data)
    trial_data(n).(name) = trial_data(n).(name)(:,idx);
end

% Get models
for n = 1:folds
    disp(n)
    [vaf_lfp(n,1), vaf_lfp(n,2),x_vel_lfp,x_est_lfp,y_vel_lfp,y_est_lfp] = TD_ComputeModelAndPlotLFP(trial_data,BinToPast,name);
end

name = 'M1_spikes';
for n = 1:folds
    disp(n)
    [vaf_spk(n,1), vaf_spk(n,2),x_vel_spk,x_est_spk,y_vel_spk,y_est_spk] = TD_ComputeModelAndPlotLFP(trial_data,BinToPast,name);
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
l = legend('Spikes','LFP'); l.FontSize = 9;
title('X Velocity VAF'); xlabel('VAF'); ylabel('Counts')

subplot(1,2,2)
[d1,edge1] = histcounts(vaf_spk(:,2),minimum(2):0.01:1); 
[d2,edge2] = histcounts(vaf_lfp(:,2),minimum(2):0.01:1);
hold on;
one = bar(edge1(1:end-1),d1,'histc'); two = bar(edge2(1:end-1),d2,'histc');
one.FaceColor = 'r'; two.FaceColor = [.6 .6 .6];
alpha(one,.5); alpha(two,.5); 
l = legend('Spikes','LFP'); l.FontSize = 9;
title('Y Velocity VAF'); xlabel('VAF'); ylabel('Counts')


% Plot velocity precitions
figure

subplot(2,2,1)
x=x_vel_lfp(1:1000);
y=x_est_lfp(1:1000);
hold on; plot(x(:,1),'b');hold on; plot(y(:,1),'r');
title(['X velocity LFP: VAF ' num2str(vaf_lfp(end,1))]);

subplot(2,2,2)
x=y_vel_lfp(1:1000);
y=y_est_lfp(1:1000);
hold on; plot(x(:,1),'b');hold on; plot(y(:,1),'r');
title(['Y velocity LFP: VAF ' num2str(vaf_lfp(end,1))]);

subplot(2,2,3)
x=x_vel_spk(1:1000);
y=x_est_spk(1:1000);
hold on; plot(x(:,1),'b');hold on; plot(y(:,1),'r');
title(['X velocity Spikes: VAF ' num2str(vaf_spk(end,1))]);

subplot(2,2,4)
x=y_vel_spk(1:1000);
y=y_est_spk(1:1000);
hold on; plot(x(:,1),'b');hold on; plot(y(:,1),'r');
title(['Y velocity Spikes: VAF ' num2str(vaf_spk(end,2))]);
