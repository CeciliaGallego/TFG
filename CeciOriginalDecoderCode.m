% Decoder with position vector instead of velocities
clc; clear; 

%Read the files only with the right results
trial_data=loadTDfiles('Chewie_CO_CS_2016-10-21.mat',{@getTDidx,{'result','R'}});

% Parameters
TrainSet = 276;  % TestSet=36
BinSize = 20;
BinToPast = 5;
PpalCompNum = 20;
NL = 3; % For the comparative, it is easier if NL = 0;
use_pca = true;

% Smooth the data
trial_data = smoothSignals(trial_data,struct('signals',{{'M1_spikes'}},'width',0.05));

% Change bin size
% BinSize should be in ms (i.e. 30ms)
trial_data = binTD(trial_data,BinSize/10);  %how many bins do you want to combine

% Remove trials with NaN in their idx fields
trial_data = removeBadTrials(trial_data);

% Set the time limit
if BinToPast == 0;
    BinToPast = 1;
end
limit = min(cat(1,trial_data(1:length(trial_data)).idx_trial_end)-(cat(1,trial_data(1:length(trial_data)).idx_movement_on)))+1;
limit = limit + BinToPast -1;

% CONCATENATE THE MATICES
idx = 1:length(trial_data);

spikes = []; vel = [];
for n = 1:TrainSet
    InitialPos = trial_data(idx(n)).idx_movement_on-BinToPast+1;
    FinalPos = InitialPos+limit-1;
    spikes = cat(1,spikes,trial_data(idx(n)).M1_spikes(InitialPos:FinalPos,:));
    vel = cat(1,vel,trial_data(idx(n)).vel(InitialPos+BinToPast-1:FinalPos,:));
end

if use_pca
    [coeff,score,~,~,~,mu] = pca(spikes);
size(spikes)
    % % We will take the principal components

    components = score(:,1:PpalCompNum);
    latentvar = coeff(:,1:PpalCompNum);

    % % Dup and shift the ppal components
    Xmodel = [];
    for n = 1:limit:size(components,1)
        temp_x = []; 
        for m = 1:BinToPast
            InitialIndex = n+BinToPast-m;
            FinalIndex = n+limit-m;
            temp_x = cat(2,temp_x,components(InitialIndex:FinalIndex,:));
        end
        Xmodel = cat(1,Xmodel,temp_x);
    end
    
else
    % % Dup and shift the ppal components
    Xmodel = [];
    for n = 1:limit:size(spikes,1)
        temp_x = []; 
        for m = 1:BinToPast
            InitialIndex = n+BinToPast-m;
            FinalIndex = n+limit-m;
            temp_x = cat(2,temp_x,spikes(InitialIndex:FinalIndex,:));
        end
        Xmodel = cat(1,Xmodel,temp_x);
    end
end

% % Get the model!! :)
model=Xmodel\vel;


% % Non-linearity correction setting (we are not using this)
if NL ~= 0
    real = vel;
    est = Xmodel*model;
    x_data = est(:); y_data = real(:);
    p = polyfit(x_data,y_data,NL);
end

% % Evaluate de model
spikes = []; real = []; vaf = [];
for n=TrainSet+1:length(trial_data)
    InitialPos=trial_data(idx(n)).idx_movement_on-BinToPast+1;  % 5 bins before movement
    FinalPos=InitialPos+limit-1;
    spikes = cat(1,spikes,trial_data(idx(n)).M1_spikes(InitialPos:FinalPos,:));
    real = cat(1,real,trial_data(idx(n)).vel(InitialPos+BinToPast-1:FinalPos,:));    
end

trial_length = FinalPos-InitialPos-BinToPast+2;

if use_pca
    
    % Offset correction
    spikes = spikes - ones(size(spikes,1),1)*mu;

    est_components = spikes*latentvar;

    % Dup and shift new ppal components
    X_est = [];
    for n = 1:limit:size(est_components,1)
        temp_x = []; 
        for m = 1:BinToPast
            InitialIndex = n+BinToPast-m;
            FinalIndex = n+limit-m;
            temp_x = cat(2,temp_x,est_components(InitialIndex:FinalIndex,:));
        end
        X_est = cat(1,X_est,temp_x);
    end

else
    % Dup and shift new ppal components
    X_est = [];
    for n = 1:limit:size(spikes,1)
        temp_x = []; 
        for m = 1:BinToPast
            InitialIndex = n+BinToPast-m;
            FinalIndex = n+limit-m;
            temp_x = cat(2,temp_x,spikes(InitialIndex:FinalIndex,:));
        end
        X_est = cat(1,X_est,temp_x);
    end
end

vel_est = X_est*model;


% Non-linearity correction (not used in this script)
if NL~=0
    vel_est(:) = polyval(p,vel_est(:));
end

% Compute VAF

SS=sum((real(:,1)-mean(real(:,1))).^2);
SSE=sum((real(:,1)-vel_est(:,1)).^2);
vaf(1)=1-(SSE/SS);

SS=sum((real(:,2)-mean(real(:,2))).^2);
SSE=sum((real(:,2)-vel_est(:,2)).^2);
vaf(2)=1-(SSE/SS);


% %% Plot histogram
% edges=[0.01:0.01:1];
% [N_first,edges_first]=histcounts(VAF_p(:),edges);
% [N_second,edges_second]=histcounts(VAF_v(:),edges);
% % [N_third,edges_third]=histcounts(result(2).VAF(:),edges);
% % [N_fourth,edges_fourth]=histcounts(result(1).VAF(:),edges);
% 
% figure
% hold on
% one = bar(edges_first(1:end-1),N_first,'histc');
% two = bar(edges_second(1:end-1),N_second,'histc');
% % three = bar(edges_third(1:end-1),N_third,'histc');
% % four = bar(edges_fourth(1:end-1),N_fourth,'histc');
% one.FaceColor = 'r';
% two.FaceColor = [.6 .6 .6];
% % three.FaceColor = 'b';
% % four.FaceColor = 'g';
% alpha(one,.5); alpha(two,.5); %alpha(three,.5);% alpha(four,.5);
% set(gcf,'color','w')
% set(gca,'TickDir','out','FontSize',14)
% xlabel('VAF')
% ylabel('Counts')