clear;

%% Parameters
% Environment
v_sound = 343; % m/s
noise = 0; % Does nothing
t_span = [0,2]; % s
I0 = 1e-12; % dB reference

% Drone
drone = struct;
drone.t = [0,1,2];
drone.x = [[0,5,3];[3,6,4];[10,4,2]];

% Sound source
sound.f = 44100; % Hz, rate at which sound.wave is played
freq = 440; % Hz, for a pure tone
sound.t = t_span(1):(1/sound.f):t_span(2);
sound.p = sin(2*pi*freq * sound.t);

% Microphones
f_sample = 44100; % Hz

mics(1).x = [0,0,0]; % m
mics(2).x = [0,10,0];
mics(3).x = [10,0,0];
mics(4).x = [10,10,0];

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
    mics(i_mic).p = p_resampled;
end

%% Plots
% Signals
figure
plot(sound.t, sound.p)
hold on
for mic = mics
    plot(mic.t,mic.p, '--')
end

% Spectrograms, hardcoded for 4 mics
figure
for i = 1:4
    mic = mics(i);
    subplot(2,2,i)
    spectrogram(mic.p,[],[],[],mic.f,'yaxis')
    ylim([0.42,0.48])
end

%% Helper Functions
function x = drone_position(drone, t)
    x = interp1(drone.t, drone.x, t, 'linear', 'extrap');
end

function v = drone_velocity(drone, t)
    v = [0,0,0];
end