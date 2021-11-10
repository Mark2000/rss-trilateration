function [I, F, T] = peakSignal(pressure, varargin)
defaultFreq = 41000;
defaultSignalRange = [250,750];
defaultPlot = false;
defaultWindow = 1;
defaultWindowSpacing = 0.25;
defaultBucketSmear = 3;

p = inputParser;
addRequired(p,'pressure');
addOptional(p,'fs',defaultFreq);
addOptional(p,'SignalRange',defaultSignalRange);
addOptional(p,'WindowSize',defaultWindow);
addOptional(p,'WindowSpacing',defaultWindowSpacing);
addOptional(p,'BucketSmear',defaultBucketSmear);
addOptional(p,'Plot',defaultPlot);
parse(p,varargin{:});

pressure = pressure - mean(pressure);
f = p.Results.fs;

%% Parameters
fourier = struct;
fourier.window = ceil(p.Results.WindowSize*f);
fourier.noverlap = floor((p.Results.WindowSize-p.Results.WindowSpacing)*f);

gauss = 'a.*exp(-((x-b)./c).^2)';

% Extract signal
[~,fspect,tspect,ispect] = spectrogram(pressure,fourier.window,fourier.noverlap,[],f,'yaxis');
signal_window = p.Results.SignalRange;
ispect = ispect(fspect>signal_window(1) & fspect < signal_window(2), :);
fspect = fspect(fspect>signal_window(1) & fspect < signal_window(2));

[fridge,iridge,lridge] = tfridge(ispect,fspect);

ifit = zeros(size(tspect));
ffit = zeros(size(tspect));
mu = zeros(size(tspect));
sd = zeros(size(tspect));

halfwindow = p.Results.BucketSmear;
for i = 1:length(tspect)
    span = max(iridge(i)-halfwindow,1):(iridge(i)+halfwindow);
    scale = ispect(lridge(i));
    ffunc = fit(fspect(span),ispect(span,i)/scale,gauss,'StartPoint',[ispect(lridge(i)),fridge(i),3]);
    coeffs = coeffvalues(ffunc);
    ifit(i) = sum(ispect(span,i));
    ffit(i) = coeffs(2);

    mu(i) = coeffs(1)*scale;
    sd(i) = coeffs(3);
end

I = ifit;
F = ffit;
T = tspect;

%% Plots
if p.Results.Plot
    figure("Name","spectro_comp")
    subplot(1,2,1)
    spectrogram(pressure,fourier.window,fourier.noverlap,[],f,'yaxis','power')
    ax = gca;
    ax.Colorbar.TickLabelInterpreter = "latex";
    ax.Colorbar.Label.String = "$I$ [dB]";
    ax.Colorbar.Label.Interpreter = "latex";
    ylim([0,1])
    xlabel("$t$ [s]")
    ylabel("$f$ [Hz]")

    subplot(1,2,2)
    xlabel("t [s]")
    yyaxis left
    plot(T,F,'-',"DisplayName","filtered")
    hold on
    plot(T,fridge,'.:',"DisplayName","peak bin")
    ylabel("$f$ [Hz]","Interpreter","latex")
    flims = ylim();
    
    yyaxis right
    plot(T,I,'-', "DisplayName",'filtered')
    hold on
    % plot(mic.spect.t,abs(mic.spect.p(mic.spect.lridge)),'.:', "HandleVisibility",'off')
    ylabel("$I$ [-]","Interpreter","latex")
    legend
    xlabel("$t$ [s]")
    
    subplot(1,2,1)
    ylim(flims/1000);
    yt = get(ax, 'YTick');
%     set(gca, 'YTick',yt, 'YTickLabel',yt*1E+3)
end