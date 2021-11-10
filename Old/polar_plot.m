% clear;

datadir = "/Users/markstephenson/Desktop/441/441 Data/mic_omnidirectionality_fine_increments";
exp = "theta_(-?\d+.?\d*)_phi_(-?\d+.?\d*)_trial_\d+.csv";

% trials = load_mic_data(datadir, exp, 41000);

Ftone = 493.88;

phi = zeros(size(trials));
p = zeros(size(trials));
dp = 0;

for i = 1:length(trials)
    phi(i) = trials(i).phi;
    p(i) = mean(trials(i).mic(1).p);
    dp = max(std(trials(i).mic(1).p), dp);
end


[phi, I] = sort(phi);
dp = dp/max(p);
p = p(I)/max(p);


figure("Name","Polar")
% subplot(1,2,1);
% errorbar(phi,p/mean(p),dp/mean(p),'.')
% xlabel("$\phi$ [deg]")
% ylabel("Normalized Intensity")

% subplot(1,2,2);
col = colororder;
% polarplot(phi*pi/180,p,"Color",col(1,:),"LineWidth",2);
% polarplot(pi-phi*pi/180,p,"Color",col(1,:));

phi = [phi, fliplr(180-phi)]*pi/180;
p = [p, fliplr(p)];

phi = mod([phi(end-1:end), phi, phi(1:2)],0);
p = [p(end-1:end), p, p(1:2)];

for d = linspace(-dp,dp,200)
    if d == -dp
        polarplot(phi,p+d,"Color",col(1,:),"DisplayName", "Microphone Response");
        hold on
    else
        polarplot(phi,p+d,"Color",col(1,:),"HandleVisibility", "off");
    end
end
polarplot(linspace(0,2*pi),ones(1,100),':k',"HandleVisibility","off")
legend()
ax = gca;
ax.TickLabelInterpreter = "latex";