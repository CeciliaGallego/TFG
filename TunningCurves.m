close all; clear; clc;

% Open TD
filename = 'Chewie_CO_20161410_1.mat';
name = 'M1_lfp';
toSave = false;
trial_data = loadTDfiles(filename,{@getTDidx,{'result','R'}});

% Get only the data when the monkey is moving
td = trimTD(trial_data, {'idx_movement_on',-12},{'idx_movement_on',42});

% Get trials to the same target
target = unique([td.tgtDir]);
avg_data = trialAverage(td,{'tgtDir'});


% Tunning curves histogram
George_data = binTD(avg_data,size(avg_data(1).pos,1));
r2 = []; pref_dir = [];
for band = 1:size(trial_data(1).(name),2)
    points = [];
    for n = 1:8
        points(end+1) = (George_data(n).(name)(band));
    end
    x0 = [0 0 0]; 
    fitfun = fittype( @(a,b,c,x) a*sin(x+b)+c );
    [f,stats] = fit(target',points',fitfun,'StartPoint',x0);
%     [f,stats] = fit(target',points','Fourier1');
    r2(end+1) = stats.rsquare;
    [~,pos] = max(points);
    pref_dir(end+1) = target(pos);
%     if stats.rsquare >= 0.8
%         figure
%         plot( f, target', points')
%         title('SI')
%         pause(1)
%     else
%         figure
%         plot( f, target', points')
%         title('NO')
%         pause(1)
%     end
end
figure
subplot(1,2,1)
hist(r2);
subplot(1,2,2)
plot(r2);

for n = 1:length(trial_data)
    trial_data(n).pref_dir = cat(1,pref_dir,r2);
end


if toSave
    save(filename,'trial_data');
end