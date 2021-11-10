clear;
v_sound = 343; % m/s
speeds = linspace(0,15,50); % m/s
f_sounds = linspace(0,2000,100)'; % Hz
% t_sample
% f_shift > f_resolution

f_shift = f_sounds .* abs(1 - v_sound ./ (v_sound + speeds));
[X,Y] = meshgrid(speeds,f_sounds);
figure("Name", "shiftsize")
subplot(1,2,1)
contourf(X, Y, f_shift, 20)
c = colorbar;
c.Label.String = "$f_{\textrm{shift}}$ [Hz]";
c.Label.Interpreter = "latex";
c.TickLabelInterpreter = "latex";
xlabel("$v_d$ [m/s]")
ylabel("$f_d$ [Hz]")

subplot(1,2,2)
fd = [500,1000];
vd = [7.5,15];
theta = linspace(0,90);
for f = fd
    for v = vd
        f_shift = f .* abs(1 - v_sound ./ (v_sound + v.*cosd(theta)));
        plot(theta, 1./(f_shift(1)-f_shift), "DisplayName", "$v_d$ = " + v + "$\frac{\mathrm{m}}{\mathrm{s}}$; $f_d$ = " + f + " Hz")
        hold on
    end
end
xlim([0,90])
xlabel("$\theta$ [deg]")
ylim([0,2])
ylabel("$t_m$ [s]")
l = legend("Location","northeast");
l.Position(1) = l.Position(1) + .2;
saveNiceFigure(gcf,[6.5,2.5],"png")


% labs = c.TickLabels;
% for i = 1:length(labs)
%     f = str2num(labs{i});
%     tm = 1/f
%     c.TickLabels{i} = f + " Hz; $t_m$ = " + num2str(tm,"%.3f") + " s";
% end
% 
% ax = gca;
% ax.Position(3) = ax.Position(3) - 0.1;