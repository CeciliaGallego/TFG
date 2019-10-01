% Variables
pca_dims = 10;
bin_size = 3;
BinToPast = 5;
name = 'M1_lfp';
folds = 3;

% load('Chewie_CO_CS_2016-10-21.mat');
[trial_data, pars_td] = loadTDfiles( 'Chewie_CO_20162110.mat', ...
                    { @getTDidx, 'result', 'R' }, ...
                    { @binTD, bin_size}, ...
                    { @removeBadTrials},...
                    { @sqrtTransform, 'M1_spikes' }, ...
                    { @smoothSignals, struct('signals','M1_spikes','calc_fr',true,'width',0.05) }, ...
                    { @trimTD, {'idx_startTime',0}, {'idx_endTime',0} }, ...
                    { @dimReduce, struct('signals',{'M1_spikes'},'algorithm','pca','num_dims',pca_dims)}, ...
                    { @trimTD, {'idx_goCueTime',-10},{'idx_goCueTime',25} } );

 % Get bands
delta_idx = find(trial_data(1).M1_lfp_guide(:,3)==5);
alpha_idx = find(trial_data(1).M1_lfp_guide(:,3)==15);
beta_idx = find(trial_data(1).M1_lfp_guide(:,3)==30);
gamma1_idx = find(trial_data(1).M1_lfp_guide(:,3)==50);
gamma2_idx = find(trial_data(1).M1_lfp_guide(:,3)==100);
gamma3_idx = find(trial_data(1).M1_lfp_guide(:,3)==200);
gamma4_idx = find(trial_data(1).M1_lfp_guide(:,3)==400);
m_idx = cat(2,delta_idx,alpha_idx,beta_idx,gamma1_idx,gamma2_idx,gamma3_idx,gamma4_idx);
               
band_idx = cat(1,delta_idx,alpha_idx,beta_idx); trial_data_1 = trial_data;
for n = 1:length(trial_data)
    trial_data_1(n).M1_lfp = trial_data(n).M1_lfp(:,band_idx);
end
for n = 1:folds
    disp(n)
    idx = randperm(length(trial_data));
    [vaf_lfp(n,1), vaf_lfp(n,2),~,~,~,~] = TD_ComputeModelAndPlotLFP(trial_data,BinToPast,idx,name);
end

band_idx = cat(1,gamma1_idx,gamma2_idx,gamma3_idx,gamma4_idx); trial_data_2 = trial_data;
for n = 1:length(trial_data)
    trial_data_2(n).M1_lfp = trial_data(n).M1_lfp(:,band_idx);
end
name = 'M1_lfp'; 
trial_data = trial_data(1:89);
for n = 1:folds
    disp(n)
    idx = randperm(length(trial_data));
    [vaf_spk(n,1), vaf_spk(n,2),~,~,~,~] = TD_ComputeModelAndPlotLFP(trial_data,BinToPast,idx,name);
end

figure
minimum = min(min(vaf_lfp,vaf_spk));
[d1,edge1] = histcounts(vaf_spk(:,1),minimum(1):0.01:1); 
[d2,edge2] = histcounts(vaf_lfp(:,1),minimum(1):0.01:1);
hold on;
one = bar(edge1(1:end-1),d1,'histc'); two = bar(edge2(1:end-1),d2,'histc');
one.FaceColor = 'r'; two.FaceColor = [.6 .6 .6];
alpha(one,.5); alpha(two,.5); 
l = legend('High freq','Low freq'); l.FontSize = 9;
title('X Velocity VAF'); xlabel('VAF'); ylabel('Counts')
set(gca, 'TickDir','out', 'FontName', 'Times New Roman', 'Fontsize', 14), box off
set(gcf, 'Position',  [100, 100, 250, 200])

figure
[d1,edge1] = histcounts(vaf_spk(:,2),minimum(2):0.01:1); 
[d2,edge2] = histcounts(vaf_lfp(:,2),minimum(2):0.01:1);
hold on;
one = bar(edge1(1:end-1),d1,'histc'); two = bar(edge2(1:end-1),d2,'histc');
one.FaceColor = 'r'; two.FaceColor = [.6 .6 .6];
alpha(one,.5); alpha(two,.5); 
l = legend('High freq','Low freq'); l.FontSize = 9;
title('Y Velocity VAF'); xlabel('VAF'); ylabel('Counts')
set(gca, 'TickDir','out', 'FontName', 'Times New Roman', 'Fontsize', 14), box off
set(gcf, 'Position',  [100, 100, 250, 200])

% 
% 
% 
% total_vaf = [];
% for m = 1:7
%     disp(m)
%     trial_data_1 = trial_data;
%     band_idx = m_idx(:,m);
%     for n = 1:length(trial_data)
%         trial_data_1(n).M1_lfp = trial_data(n).M1_lfp(:,band_idx);
%     end
%     vaf = [];
%     for n = 1:folds
%         idx = randperm(length(trial_data));
%         [vaf(n,1), vaf(n,2),~,~,~,~] = TD_ComputeModelAndPlotLFP(trial_data_1,BinToPast,idx,name);
%     end
%     total_vaf(m,1) = mean(vaf(:,1)); total_vaf(m,2) = mean(vaf(:,2));
%     total_vaf(m,3) = std(vaf(:,1)); total_vaf(m,4) = std(vaf(:,2));
% end
% disp(8); vaf = [];
% for n = 1:folds
%     idx = randperm(length(trial_data));
%     [vaf(n,1), vaf(n,2),~,~,~,~] = TD_ComputeModelAndPlotLFP(trial_data,BinToPast,idx,name);
% end
% total_vaf(8,1) = mean(vaf(:,1)); total_vaf(8,2) = mean(vaf(:,2));
% total_vaf(8,3) = std(vaf(:,1)); total_vaf(8,4) = std(vaf(:,2));
% 
figure
b = bar(total_vaf(:,[1,2]));
b(1).FaceColor = 'b'; b(2).FaceColor = 'r';
hold on
x = [0.85:7.85;1.15:8.15]';
data = total_vaf(:,[1,2]);
e = total_vaf(:,[3,4]);
er = errorbar(x,data,e,e,'LineWidth',1.5);
er(1).Color = [0 0 0];  er(2).Color = [0 0 0];                            
er(1).LineStyle = 'none'; er(2).LineStyle = 'none'; 

l = legend('x velocity component','y velocity component'); l.FontSize = 9;
title('VAF at different frequencies'); ylabel('VAF'); xlabel('Frequency (Hz)');
bands = {'0-5','5-15','15-30','30-50','50-100','100-200','200-400','All'};
set(gca, 'XTick', 1:8, 'XTickLabel',bands);
set(gca, 'TickDir','out', 'FontName', 'Times New Roman', 'Fontsize', 14), box off
set(gcf, 'Position',  [100, 100, 600, 300])


total_vaf = [];
disp('lfp'); vaf_lfp = [];
for n = 1:folds
    idx = randperm(length(trial_data));
    [vaf_lfp(n,1), vaf_lfp(n,2),~,~,~,~] = TD_ComputeModelAndPlotLFP(trial_data,BinToPast,idx,name);
end
total_vaf(1,1) = mean(vaf_lfp(:,1)); total_vaf(1,2) = mean(vaf_lfp(:,2));
total_vaf(1,3) = std(vaf_lfp(:,1)); total_vaf(1,4) = std(vaf_lfp(:,2));
disp('spikes'); vaf_spk = [];
name = 'M1_spikes';
for n = 1:folds
    idx = randperm(length(trial_data));
    [vaf_spk(n,1), vaf_spk(n,2),~,~,~,~] = TD_ComputeModelAndPlotLFP(trial_data,BinToPast,idx,name);
end
total_vaf(2,1) = mean(vaf_spk(:,1)); total_vaf(2,2) = mean(vaf_spk(:,2));
total_vaf(2,3) = std(vaf_spk(:,1)); total_vaf(2,4) = std(vaf_spk(:,2));
disp('hybrid'); vaf_hyb = [];
name = 'M1_lfp'; trial_data_1 = trial_data;
for n = 1:length(trial_data)
    trial_data_1(n).M1_lfp = cat(2,trial_data(n).M1_lfp,trial_data(n).M1_spikes);
end
for n = 1:folds
    idx = randperm(length(trial_data));
    [vaf_hyb(n,1), vaf_hyb(n,2),~,~,~,~] = TD_ComputeModelAndPlotLFP(trial_data_1,BinToPast,idx,name);
end
total_vaf(3,1) = mean(vaf_hyb(:,1)); total_vaf(3,2) = mean(vaf_hyb(:,2));
total_vaf(3,3) = std(vaf_hyb(:,1)); total_vaf(3,4) = std(vaf_hyb(:,2));

figure
b = bar(total_vaf(:,[1,2]));
b(1).FaceColor = 'b'; b(2).FaceColor = 'r';
hold on
x = [0.85:2.85;1.15:3.15]';
data = total_vaf(:,[1,2]);
e = total_vaf(:,[3,4]);
er = errorbar(x,data,e,e,'LineWidth',1.5);
er(1).Color = [0 0 0];  er(2).Color = [0 0 0];                            
er(1).LineStyle = 'none'; er(2).LineStyle = 'none'; 

l = legend('x velocity component','y velocity component'); l.FontSize = 9;
title('VAF with different inputs'); ylabel('VAF'); 
set(gca, 'XTick', 1:3, 'XTickLabel',{'LFP','Spikes','LFP+Spikes'});
set(gca, 'TickDir','out', 'FontName', 'Times New Roman', 'Fontsize', 14), box off
set(gcf, 'Position',  [100, 100, 600, 200])