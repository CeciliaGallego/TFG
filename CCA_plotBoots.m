% close all; clear; clc;

filename = 'Chewie_CO_20162110.mat';

load(['fullCCA_' filename]);

c = parula(9);
figure
for n = 1:9
    hold on; plot(r_freq(n,:),'color',c(n,:),'linewidth',2);
end
aux_boot = (squeeze(r_boot_freq(1,:,:)))';
hold on; stdshade(aux_boot,0.2,c(1,:));
data = [];
for n = 1:50
    data = cat(1,data,r_boot_freq(:,:,n));
end
stdshade(data,0.2,'k');       

bands = {'LMP','0.5-4','4-8','8-12','12-25','25-50','50-100','100-200','200-400'};
legend(bands)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stdshade(amatrix,alpha,acolor,F,smth)
% usage: stdshading(amatrix,alpha,acolor,F,smth)
% plot mean and sem/std coming from a matrix of data, at which each row is an
% observation. sem/std is shown as shading.
% - acolor defines the used color (default is red) 
% - F assignes the used x axis (default is steps of 1).
% - alpha defines transparency of the shading (default is no shading and black mean line)
% - smth defines the smoothing factor (default is no smooth)
% smusall 2010/4/23
if exist('acolor','var')==0 || isempty(acolor)
    acolor='r'; 
end
if exist('F','var')==0 || isempty(F)
    F=1:size(amatrix,2);
end
if exist('smth','var'); if isempty(smth); smth=1; end
else smth=1; %no smoothing by default
end  
if ne(size(F,1),1)
    F=F';
end
amean = nanmean(amatrix,1); %get man over first dimension
if smth > 1
    amean = boxFilter(nanmean(amatrix,1),smth); %use boxfilter to smooth data
end
astd = nanstd(amatrix,[],1); % to get std shading
% astd = nanstd(amatrix,[],1)/sqrt(size(amatrix,1)); % to get sem shading
if exist('alpha','var')==0 || isempty(alpha) 
    fill([F fliplr(F)],[amean+astd fliplr(amean-astd)],acolor,'linestyle','none');
    acolor='k';
else fill([F fliplr(F)],[amean+astd fliplr(amean-astd)],acolor, 'FaceAlpha', alpha,'linestyle','none');    
end
if ishold==0
    check=true; else check=false;
end
hold on;plot(F,amean,'color',acolor,'linewidth',1.5); %% change color or linewidth to adjust mean line
if check
    hold off;
end
end
function dataOut = boxFilter(dataIn, fWidth)
% apply 1-D boxcar filter for smoothing
dataStart = cumsum(dataIn(1:fWidth-2),2);
dataStart = dataStart(1:2:end) ./ (1:2:(fWidth-2));
dataEnd = cumsum(dataIn(length(dataIn):-1:length(dataIn)-fWidth+3),2);
dataEnd = dataEnd(end:-2:1) ./ (fWidth-2:-2:1);
dataOut = conv(dataIn,ones(fWidth,1)/fWidth,'full');
dataOut = [dataStart,dataOut(fWidth:end-fWidth+1),dataEnd];
end
