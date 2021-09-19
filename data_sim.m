clear;
global v_sound mics i_tri

%% Parameters
% Environment
v_sound = 343; % m/s
noise = 0; % Does nothing
t_span = [0,2]; % s
I0 = 1e-12; % dB reference

% Drone
drone = struct;
% drone.t = [0,0.75,2];
% drone.x = [[0,5,2];[3,6,4];[10,4,3]];

%statioinary
drone.t = [0,2];
drone.x = [[1,1,4];[1,1,4]];

%line
% drone.t = [0,2];
% drone.x = [[0,5,1.5];[10,5,1.5]];

%circle
% drone.t = linspace(0,2);
% drone.x = [2*sin(linspace(0,4*pi))+3; 2*cos(linspace(0,4*pi))+3; ones(1,100)]';

%passing one mic
% drone.t = [0,2];
% drone.x = [[5,-5,0];[5,5,0]];


% Sound source
sound.f = 44100; % Hz, rate at which sound.wave is played (also used as sampling freq)
freq = 1000; % Hz, for a pure tone
sound.t = t_span(1):(1/sound.f):t_span(2);
sound.p = 0.2*sin(2*pi*freq * sound.t);

% Microphones
f_sample = sound.f; % Hz

fourier = struct;
window = 0.125; % s
fourier.window = ceil(window*f_sample);
window_freq = 0.05; % s, how often fft is computed
fourier.noverlap = floor((window-window_freq)*f_sample);

mics(1).x = [0,0,0]; % m
mics(2).x = [0,0,2]; % m

mics(3).x = [0,10,0];
mics(4).x = [0,10,2]; % m

mics(5).x = [10,0,0];
mics(6).x = [10,0,2];

mics(7).x = [10,10,2]; % m
mics(8).x = [10,10,0]; % m




for i = 1:numel(mics)
    mics(i).f = f_sample;
    mics(i).t = zeros(size(sound.t)); % s
    mics(i).p = zeros(size(sound.t)); % 
end

%% Simulation
for i = 1:length(sound.t)
    t = sound.t(i);
    drone_x = drone_position(drone, t);
    p = sound.p(i);
    for i_mic = 1:numel(mics)
        distance = norm(mics(i_mic).x - drone_x);
        mics(i_mic).t(i) = t + distance/v_sound;
        mics(i_mic).p(i) = p * 1/distance; % Pressure drops at 1/r
    end
end

% Resample sound
for i_mic = 1:numel(mics)
    mic = mics(i_mic);
    t_resampled = t_span(1):(1/mic.f):t_span(2);
    p_resampled = interp1(mic.t, mic.p, t_resampled);
    p_resampled(isnan(p_resampled)) = 0;
    
    mics(i_mic).t = t_resampled;
    mics(i_mic).p = p_resampled.*(0.95+0.1*rand(size(p_resampled)));
end

gauss = 'a.*exp(-((x-b)./c).^2)';

% Extract signal
for i_mic = 1:numel(mics)
    mic = mics(i_mic);
    [~,fs,ts,ps] = spectrogram(mic.p,fourier.window,fourier.noverlap,[],mic.f,'yaxis');
    [fridge,iridge,lridge] = tfridge(ps,fs);
    
    mics(i_mic).spect.t = ts;
    mics(i_mic).spect.p = ps;
    mics(i_mic).spect.f = fs;
    mics(i_mic).spect.fridge = fridge;
    mics(i_mic).spect.iridge = iridge;
    mics(i_mic).spect.lridge = lridge; % linear indices of p
    
    mics(i_mic).spect.pfit = zeros(size(ts));
    mics(i_mic).spect.ffit = zeros(size(ts));
    
    for i = 1:length(ts)
        halfwindow = 3;
        span = (iridge(i)-3):(iridge(i)+3);
        scale = ps(lridge(i));
        f = fit(fs(span),ps(span,i)/scale,gauss,'StartPoint',[ps(lridge(i)),fridge(i),3]);
        coeffs = coeffvalues(f);
        mics(i_mic).spect.pfit(i) = coeffs(1)*scale;
        mics(i_mic).spect.ffit(i) = coeffs(2);
    end
end

%% Processing

% Position
opt = optimset("MaxFunEvals",10000,"MaxIter",10000);
n_t = numel(mics(1).spect.t);
trilaterated = zeros(n_t, 3);

for i_tri = 1:n_t
    loc = fminsearch(@trilaterate, [4,4,2, 30], opt)
    drone_position(drone, mics(1).spect.t(i_tri))
    trilaterated(i_tri,:) = loc(1:3);
end


%% Plots
% Signals
figure
plot(sound.t, sound.p)
hold on
for mic = mics
    plot(mic.t,mic.p, '--')
end
xlabel("t [s]")
ylabel("Sound Pressure")

% System setup
figure("Name","3d_circ")
display = "on"
for mic = mics
    plot3(mic.x(1),mic.x(2),mic.x(3),"bo", 'MarkerSize', 10,"DisplayName", "Mics","HandleVisibility",display)
    hold on
    display = 'off'
end
path = drone_position(drone,mics(1).spect.t);
plot3(path(:,1),path(:,2),path(:,3),'.',"DisplayName","Actual")
plot3(trilaterated(:,1),trilaterated(:,2),trilaterated(:,3),'.',"DisplayName","Trilaterated")
axis equal
xlim([0,10])
ylim([0,10])
zlim([0,2])
xlabel("$x$ [m]")
ylabel("$y$ [m]")
zlabel("$z$ [m]","Interpreter","latex")
legend()
saveNiceFigure(gcf,[5.5,2.5],"png")

% Spectrograms, hardcoded for 4 mics
figure
for i = 1:4
    mic = mics(i);
    subplot(2,2,i)
    spectrogram(mic.p,fourier.window,fourier.noverlap,[],mic.f,'yaxis','power')
    title("Mic " + i)
    ylim(freq*[0.9,1.1]/1000)
end

figure
for i = 1:4
    mic = mics(i);
    subplot(2,2,i)
    title("Mic " + i)
    xlabel("t [s]")
    yyaxis left
    plot(mic.spect.t,mic.spect.ffit)
    hold on
    scatter(mic.spect.t,mic.spect.fridge,'.')
    ylabel("f [Hz]")
    yyaxis right
    plot(mic.spect.t,mic.spect.pfit)
    hold on
    scatter(mic.spect.t,abs(mic.spect.p(mic.spect.lridge)),'.')
    ylabel("$I$ [W/m$^2$]")
end


figure("Name","spectro_comp")
subplot(1,2,1)
mic = mics(1);
spectrogram(mic.p,fourier.window,fourier.noverlap,[],mic.f,'yaxis','power')
ax = gca;
ax.Colorbar.TickLabelInterpreter = "latex";
ax.Colorbar.Label.String = "$I$ [dB]";
ax.Colorbar.Label.Interpreter = "latex";
ylim([.95,1.05])

subplot(1,2,2)
xlabel("t [s]")
yyaxis left
plot(mic.spect.t,mic.spect.ffit,'-',"DisplayName","filtered")
hold on
plot(mic.spect.t,mic.spect.fridge,'.:',"DisplayName","peak bin")
ylabel("f [Hz]","Interpreter","latex")
yyaxis right

plot(mic.spect.t,mic.spect.pfit,'-', "HandleVisibility",'off')
hold on
plot(mic.spect.t,abs(mic.spect.p(mic.spect.lridge)),'.:', "HandleVisibility",'off')
ylabel("$I$ [W/m$^2$]","Interpreter","latex")
legend
saveNiceFigure(gcf,[6.5,2.5],"png")


%% Helper Functions
function x = drone_position(drone, t)
    x = interp1(drone.t, drone.x, t, 'linear', 'extrap');
end

function F = trilaterate(X)
    global mics i_tri;
    x_d = X(1:3);
    P_d = X(4);
    F = zeros(1,4);
    normalization = 1000;
    
    for i_mic = 1:numel(mics)
        mic = mics(i_mic);
        r_i = x_d - mic.x;
        F(i_mic) = sqrt(P_d)/sqrt((mic.spect.pfit(i_tri)*normalization)) - norm(r_i);
    end
    
    F = norm(F);
end

% function F = doppler_trilaterate(X, x_d, mics, i)
%     global v_sound
%     v_d = X(1:3);
%     f_d = X(4);
%     
%     for i_mic = 1:numel(mics)
%         r_i = x_d - mics(i_mic);
%         F(i_mic) = f_d*v_sound/(v_sound + dot(v_d, r_i))
%     end
% end

function v = drone_velocity(drone, t)
    % For comparison with derived
    v = [0,0,0];
end