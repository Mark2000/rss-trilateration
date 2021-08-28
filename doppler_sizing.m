clear;
v_sound = 343; % m/s
speeds = linspace(0,15,50); % m/s
f_sounds = linspace(0,2000,100)'; % Hz
% t_sample
% f_shift > f_resolution

f_shift = f_sounds .* abs(1 - v_sound ./ (v_sound + speeds));
[X,Y] = meshgrid(speeds,f_sounds);
figure
contourf(X, Y, f_shift, 20)
c = colorbar;
c.Label.String = "Max $f_{shift}$ [Hz]"
xlabel("$v_d$ [m/s]")
ylabel("$f_d$ [Hz]")