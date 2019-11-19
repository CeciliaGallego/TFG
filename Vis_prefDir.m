close all; clear; clc;

% Open TD
filename = 'Mihili_CO_20140303.mat';
trial_data = loadTDfiles(filename,{@getTDidx,{'result','R'}});
load('Mihili_ArrayMap');

guide = trial_data(1).M1_lfp_guide;
pref_dir = trial_data(1).pref_dir;
bands = unique(guide(:,3));
min_f = unique(guide(:,2));
targets = unique([trial_data.tgtDir]);

% % Study prefered direction of frequency bands (Not very relevant)
% figure
% for f = 1:length(bands)
%     isFreq = guide(:,3) == bands(f);
%     theta = pref_dir(1,isFreq);
%     subplot(3,3,f)
%     rose(theta,8)
%     title([num2str(min_f(f)) '-' num2str(bands(f))]);
% end


% % Study prefered direction of channels
% for ch = 1:96
%     isChan = guide(:,1) == ch;
%     theta = pref_dir(1,isChan);
%     if rem(ch,12) == 1
% %         close all
%         n = 1;
%         figure
%     else
%         n = n+1;
%     end
%     subplot(3,4,n)
%     rose(theta,targets)
%     title(['Channel: ' num2str(ch)])
% end


% % % Channel spatial distribution
% % Choose frequency
% figure
% for f = 1:length(bands)
%     isFreq = guide(:,3) == bands(f);
%     theta = pref_dir(1,isFreq);
%     r2 = pref_dir(2,isFreq);
%     map = zeros(10,10);
%     map(arr_map == 0) = -5;
%     for ch = 1:96
%         if r2(ch) > 0.7
%             map(arr_map == ch) = theta(ch);
%         else
%             map(arr_map == ch) = -5;
%         end
%     end
%     subplot(3,3,f)
%     imagesc(map)
%     title([num2str(min_f(f)) '-' num2str(bands(f))]);
% end



% Compare different days for Mihili
totalMap1 = [];
for f = 1:length(bands)
    isFreq = guide(:,3) == bands(f);
    theta = pref_dir(1,isFreq);
    map = zeros(10,10);
    map(arr_map == 0) = -5;
    for ch = 1:96
        map(arr_map == ch) = theta(ch);
    end
    totalMap1 = cat(3,totalMap1,map);
end


filename = 'Mihili_CO_20140403.mat';
trial_data = loadTDfiles(filename,{@getTDidx,{'result','R'}});
pref_dir = trial_data(1).pref_dir;
totalMap2 = [];
for f = 1:length(bands)
    isFreq = guide(:,3) == bands(f);
    theta = pref_dir(1,isFreq);
    map = zeros(10,10);
    map(arr_map == 0) = -5;
    for ch = 1:96
        map(arr_map == ch) = theta(ch);
    end
    totalMap2 = cat(3,totalMap2,map);
end

filename = 'Mihili_CO_20140603.mat';
trial_data = loadTDfiles(filename,{@getTDidx,{'result','R'}});
pref_dir = trial_data(1).pref_dir;
totalMap3 = [];
for f = 1:length(bands)
    isFreq = guide(:,3) == bands(f);
    theta = pref_dir(1,isFreq);
    map = zeros(10,10);
    map(arr_map == 0) = -5;
    for ch = 1:96
        map(arr_map == ch) = theta(ch);
    end
    totalMap3 = cat(3,totalMap3,map);
end

freq = 9;
figure
subplot(1,3,1)
diffMap = abs(totalMap1 - totalMap2);
diffMap(diffMap > 5) = 0.785; % Consecutive trials
imagesc(diffMap(:,:,freq)); title('03-04')

subplot(1,3,2)
diffMap = abs(totalMap1 - totalMap3);
diffMap(diffMap > 5) = 0.785; % Consecutive trials
imagesc(diffMap(:,:,freq)); title('03-06')

subplot(1,3,3)
diffMap = abs(totalMap3 - totalMap2);
diffMap(diffMap > 5) = 0.785; % Consecutive trials
imagesc(diffMap(:,:,freq)); title('04-06')

