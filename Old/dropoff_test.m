trials = trials5mmoving;
mics = mics5m;
fndropoff = 'a./x^2';

scaling = [9.7562   10.3190    6.5313    3.5332    6.1716    6.1839    3.8613    3.4860];
colors = colororder;

allpoints = [];
figure("Name","L_dropoff")
for imic = 1:8
    stand = ceil(imic/2);
    if mod(imic,2) == 1
        formats = "-";
        height = "Low";
    else
        formats = "--";
        height = "High";
    end

    powers = zeros(length(trials),3);
    for itrial = 1:length(trials)
        trial = trials(itrial);
        powers(itrial,1) = norm(mics(imic).pos - trial.pos);
        powers(itrial,2) = mean(trial.mic(imic).p)*scaling(imic);
        powers(itrial,3) = (max(trial.mic(imic).p)-min(trial.mic(imic).p))/2*scaling(imic);
        hold on
    end
    powers = sortrows(powers);
    allpoints = [allpoints;powers];
    errorbar(powers(:,1),powers(:,2),powers(:,3),'.'+formats,"Color",colors(stand,:),"DisplayName","Mic " + imic)
end

allpoints = sortrows(allpoints);
f = fit(allpoints(:,1),allpoints(:,2),fndropoff);
coeffs = coeffvalues(f);
plot(linspace(0.1,10),coeffs./linspace(0.1,10).^2,':k',"HandleVisibility","off")
xlim([1,6])
ylim([0,6])
xlabel("Distance [m]")
ylabel("Power [-]")

legend()