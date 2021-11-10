function mic = sample_summary(p, f, signal_window, plotFig, window, window_freq) % Todo make input better

if nargin < 4
    plotFig = true;
end
if nargin < 3
    signal_window = [450, 550];
end
if nargin < 2
    f = 44100;
end

mic = struct();
mic.p = p;
mic.p = mic.p-mean(mic.p);
mic.f = f;
mic.t = (0:(length(mic.p)-1))/mic.f;

%% Parameters
fourier = struct;
%     window = .125; % s
fourier.window = ceil(window*mic.f);
%     window_freq = 0.1; % s, how often fft is computed
fourier.noverlap = floor((window-window_freq)*mic.f);

gauss = 'a.*exp(-((x-b)./c).^2)';

% Extract signal
[~,fs,ts,ps] = spectrogram(mic.p,fourier.window,fourier.noverlap,[],mic.f,'yaxis');
ps = ps(fs>signal_window(1) & fs < signal_window(2), :);
fs = fs(fs>signal_window(1) & fs < signal_window(2));

[fridge,iridge,lridge] = tfridge(ps,fs);

mic.spect.t = ts;
mic.spect.p = ps;
mic.spect.f = fs;
mic.spect.fridge = fridge;
mic.spect.iridge = iridge;
mic.spect.lridge = lridge; % linear indices of p

mic.spect.pfit = zeros(size(ts));
mic.spect.ffit = zeros(size(ts));
mic.spect.sd = zeros(size(ts));

for i = 1:length(ts)
    halfwindow = 3;
    span = max(iridge(i)-halfwindow,1):(iridge(i)+halfwindow);
    scale = ps(lridge(i));
    f = fit(fs(span),ps(span,i)/scale,gauss,'StartPoint',[ps(lridge(i)),fridge(i),3]);
    coeffs = coeffvalues(f);
%     mic.spect.pfit(i) = coeffs(1)*coeffs(3)*scale; % Sigma-mean product
    mic.spect.pfit(i) = sum(ps(span,i)); % Integral of surrounding bins seems more mathematically sound
    mic.spect.ffit(i) = coeffs(2);

    mic.spect.mu(i) = coeffs(1)*scale;
    mic.spect.sd(i) = coeffs(3);
end

%% Plots
if plotFig
    figure("Name","spectro_comp")
    subplot(1,2,1)
    spectrogram(mic.p,fourier.window,fourier.noverlap,[],mic.f,'yaxis','power')
    ax = gca;
    ax.Colorbar.TickLabelInterpreter = "latex";
    ax.Colorbar.Label.String = "$I$ [dB]";
    ax.Colorbar.Label.Interpreter = "latex";
    ylim([0,1])
    ylim([0.49,0.51])
    yt = get(ax, 'YTick');
    set(gca, 'YTick',yt, 'YTickLabel',yt*1E+3)
    xlabel("$t$ [s]")
    ylabel("$f$ [Hz]")

    subplot(1,2,2)
    xlabel("t [s]")
    yyaxis left
    plot(mic.spect.t,mic.spect.ffit,'-',"DisplayName","filtered")
    hold on
    plot(mic.spect.t,mic.spect.fridge,'.:',"DisplayName","peak bin")
    ylabel("$f$ [Hz]","Interpreter","latex")
    yyaxis right

    plot(mic.spect.t,mic.spect.pfit,'-', "DisplayName",'filtered')
    hold on
    % plot(mic.spect.t,abs(mic.spect.p(mic.spect.lridge)),'.:', "HandleVisibility",'off')
    ylabel("$I$ [-]","Interpreter","latex")
    legend
    xlabel("$t$ [s]")
%         saveNiceFigure(gcf,[6.5,2.5],"png")
end