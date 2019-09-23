% Main code for my TFG analysis
close all; clear; clc;

% Open TD ('Chewie_CO_20162110.mat'   'Chewie_CO_CS_2016-10-21.mat')
trial_data = loadTDfiles('Chewie_CO_20162110.mat',{@getTDidx,{'result','R'}});

% Change bin size
trial_data = binTD(trial_data,1);  %how many bins do you want to combine

% Smooth spikes
trial_data = smoothSignals(trial_data,struct('signals',{{'M1_spikes'}},'width',0.05));

% Look for data with the same target
targets = unique(cat(1,trial_data.tgtDir));
[~, data_target] = getTDidx(trial_data,'tgtDir',targets(5));

% Correlation matrix
c = CorrelationMatrix(data_target,'M1_spikes',41);







%% Plot histogram

for n=1:length(result)
    result(n).VAF(result(n).VAF(:) < 0) = 0;
end
edges=[0.05:0.05:1];
[N_first,edges_first]=histcounts(result(4).VAF(:),edges);
[N_second,edges_second]=histcounts(result(3).VAF(:),edges);
% [N_third,edges_third]=histcounts(result(2).VAF(:),edges);
% [N_fourth,edges_fourth]=histcounts(result(1).VAF(:),edges);

figure
hold on
one = bar(edges_first(1:end-1),N_first,'histc');
two = bar(edges_second(1:end-1),N_second,'histc');
% three = bar(edges_third(1:end-1),N_third,'histc');
% four = bar(edges_fourth(1:end-1),N_fourth,'histc');
one.FaceColor = 'r';
two.FaceColor = [.6 .6 .6];
% three.FaceColor = 'b';
% four.FaceColor = 'g';
alpha(one,.5); alpha(two,.5); %alpha(three,.5);% alpha(four,.5);
set(gcf,'color','w')
set(gca,'TickDir','out','FontSize',14)
xlabel('VAF')
ylabel('Counts')

%% Plot velocity precitions
 
spacing=15;
figure
last_pos=0;
for n=1:length(result)
    trial_length=result(n).trial_length;
    for m=1:length(result(n).y_real)
        if rem(m,trial_length)==0
            time=last_pos+1:last_pos+trial_length;
            x_real=result(n).y_real(m-trial_length+1:m,1);
            x_est=result(n).y_est(m-trial_length+1:m,1);
            last_pos=last_pos+trial_length+spacing;
            hold on; plot(time,x_real(:,1),'b');hold on; plot(time,x_est(:,1),'r');
        end
    end
end