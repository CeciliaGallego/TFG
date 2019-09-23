% Variables
smooth = false;
pca = false;
bin_size = 20; %ms
pca_dims = 20;
BinToPast = 5;
decode_var = 'vel';
decode_mod = 'linmodel';
pol = 0;
folds = 30;

% load('Chewie_CO_CS_2016-10-21.mat');
trial_data=loadTDfiles('Chewie_CO_CS_2016-10-21.mat',{@getTDidx,{'result','R'}});

% Remove trials with NaN in their idx fields
trial_data = removeBadTrials(trial_data);

% Get only the data when the monkey is moving
trial_data = trimTD(trial_data, {'idx_movement_on',-BinToPast},'idx_trial_end');

vaf = zeros(folds,2);
for n = 1: folds
    disp(n);
    [vaf(n,1), vaf(n,2),x_vel, x_vel_pred, y_vel, y_vel_pred] = TD_ComputeModelAndPlot(trial_data,smooth,pca,bin_size,pca_dims,BinToPast,pol);
end

pol = 3;
vaf_sm = zeros(folds,2);
for n = 1: folds
    disp(n);
    [vaf_sm(n,1), vaf_sm(n,2),x_vel, x_vel_pred, y_vel, y_vel_pred] = TD_ComputeModelAndPlot(trial_data,smooth,pca,bin_size,pca_dims,BinToPast,pol);
end

% Plot histogram
figure
minimum = min(min(vaf),min(vaf_sm));
[d1,edge1] = histcounts(vaf_sm(:,1),minimum(1):0.01:1); 
[d2,edge2] = histcounts(vaf(:,1),minimum(1):0.01:1);
hold on;
one = bar(edge1(1:end-1),d1,'histc'); two = bar(edge2(1:end-1),d2,'histc');
one.FaceColor = 'r'; two.FaceColor = [.6 .6 .6];
alpha(one,.5); alpha(two,.5); 
l = legend('All lat var','28 lat var'); l.FontSize = 9;
title('X Velocity VAF'); xlabel('VAF'); ylabel('Counts')
set(gca, 'TickDir','out', 'FontName', 'Times New Roman', 'Fontsize', 14), box off
set(gcf, 'Position',  [100, 100, 250, 200])

% Plot histogram
figure
minimum = min(min(vaf),min(vaf_sm));
[d1,edge1] = histcounts(vaf_sm(:,2),minimum(2):0.01:1); 
[d2,edge2] = histcounts(vaf(:,2),minimum(2):0.01:1);
hold on;
one = bar(edge1(1:end-1),d1,'histc'); two = bar(edge2(1:end-1),d2,'histc');
one.FaceColor = 'r'; two.FaceColor = [.6 .6 .6];
alpha(one,.5); alpha(two,.5); 
l = legend('All lat var','28 lat var'); l.FontSize = 9;
title('Y Velocity VAF'); xlabel('VAF'); ylabel('Counts')
set(gca, 'TickDir','out', 'FontName', 'Times New Roman', 'Fontsize', 14), box off
set(gcf, 'Position',  [100, 100, 250, 200])

[p,h] = ranksum(vaf(:,1),vaf_sm(:,1))
[p,h] = ranksum(vaf(:,1),vaf_sm(:,1))


% % Figure 3.18
% m_vaf = []; sd_vaf = []; idx = 0;
% for BinToPast = [1,2,3,4,5,6,7,8,9,10]
% idx = idx + 1;
% vaf = zeros(folds,2); 
% disp(BinToPast);
% for n = 1: folds
%     [vaf(n,1), vaf(n,2),~,~,~,~] = TD_ComputeModelAndPlot(trial_data,smooth,pca,bin_size,pca_dims,BinToPast,pol);
% end
% m_vaf(idx,:) = mean(vaf);
% sd_vaf(idx,:) = std(vaf);
% end

% figure
% e = errorbar([0:9],m_vaf(:,1),sd_vaf(:,1),'linewidth',2); xlim([-1,10])
% e.Marker = '.'; e.MarkerSize = 10; e.Color = 'k';
% title('X Velocity VAF'); xlabel('History (number of bins)'); ylabel('VAF')
% set(gca, 'TickDir','out', 'FontName', 'Times New Roman', 'Fontsize', 14), box off
% set(gcf, 'Position',  [100, 100, 250, 200])
% 
% figure
% e = errorbar([0:9],m_vaf(:,2),sd_vaf(:,2),'linewidth',2); xlim([-1,10])
% e.Marker = '.'; e.MarkerSize = 10; e.Color = 'k';
% title('Y Velocity VAF'); xlabel('History (number of bins)'); ylabel('VAF')
% set(gca, 'TickDir','out', 'FontName', 'Times New Roman', 'Fontsize', 14), box off
% set(gcf, 'Position',  [100, 100, 250, 200])
% 


% % Figure 3.21
% m_vaf = []; sd_vaf = []; idx = 0;
% lat_var = [1:84];
% for pca_dims = lat_var;
% idx = idx + 1;
% vaf = zeros(folds,2); 
% disp(pca_dims);
% for n = 1: folds
%     [vaf(n,1), vaf(n,2),~,~,~,~] = TD_ComputeModelAndPlot(trial_data,smooth,pca,bin_size,pca_dims,BinToPast,pol);
% end
% m_vaf(idx,:) = mean(vaf);
% sd_vaf(idx,:) = std(vaf);
% end
% 
% 
% pca = false;
% for n = 1: folds
%     [vaf_s(n,1), vaf_s(n,2),~,~,~,~] = TD_ComputeModelAndPlot(trial_data,smooth,pca,bin_size,pca_dims,BinToPast,pol);
% end
% m_vaf_s(1,:) = mean(vaf_s);
% 
figure
plot(lat_var,m_vaf(:,1),'linewidth',2); xlim([0,85]); ylim([0.7,1]);
% hold on; scatter(84,m_vaf_s(1,1),50,'r','filled')
line ([0 85],[m_vaf_s(1,1) m_vaf_s(1,1)],'color','r','linewidth',2)
title('X Velocity VAF'); xlabel('Number of latent variables'); ylabel('VAF')
l = legend('Latent variables','Spikes'); l.FontSize = 9;
set(gca, 'TickDir','out', 'FontName', 'Times New Roman', 'Fontsize', 14), box off
set(gcf, 'Position',  [100, 100, 250, 200])

figure
plot(lat_var,m_vaf(:,2),'linewidth',2); xlim([0,85]); ylim([0.7,1]);
% hold on; scatter(84,m_vaf_s(1,1),50,'r','filled')
line ([0 85],[m_vaf_s(1,2) m_vaf_s(1,2)],'color','r','linewidth',2)
title('Y Velocity VAF'); xlabel('Number of latent variables'); ylabel('VAF')
l = legend('Latent variables','Spikes'); l.FontSize = 9;
set(gca, 'TickDir','out', 'FontName', 'Times New Roman', 'Fontsize', 14), box off
set(gcf, 'Position',  [100, 100, 250, 200])