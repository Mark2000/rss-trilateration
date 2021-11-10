trials = falloff;

fndropoff = 'a./x^2';

figure("Name","falloff")
hold on
data = zeros(length(trials),5);
for itrial = 1:length(trials)
    trial = trials(itrial);
    data(itrial,1) = trial.pos(1);
    data(itrial,2) = mean(trial.mic(1).p);
    data(itrial,3) = (max(trial.mic(1).p)-min(trial.mic(1).p))/2;
    data(itrial,4) = mean(trial.mic(2).p);
    data(itrial,5) = (max(trial.mic(2).p)-min(trial.mic(2).p))/2;
end

data = sortrows(data);

data_student = zeros(length(trials)/2,5);
for i = 1:length(data_student)
    data_student(i,1) = data(i*2,1);
    data_student(i,2) = mean(data(i*2-1:i*2,2));
    data_student(i,3) = std(data(i*2-1:i*2,2))*2.92;
    data_student(i,4) = mean(data(i*2-1:i*2,4));
    data_student(i,5) = std(data(i*2-1:i*2,4))*2.92;
end

f = fit([data(:,1);sqrt(data(:,1).^2+1.6^2)],[data(:,2);data(:,4)],fndropoff);
coeffs = coeffvalues(f);

data = data_student;

errorbar(data(:,1),data(:,2),data(:,3),"DisplayName","Lower")
% errorbar(data(:,1),data(:,4),data(:,5))
errorbar(sqrt(data(:,1).^2+1.6^2),data(:,4),data(:,5),"DisplayName","Upper")
plot(linspace(0.1,10),coeffs./linspace(0.1,10).^2,':k',"DisplayName","$A/r^2$")
set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')
xlim([0.2,10])
ylim([1e-3,30])
xlabel("Distance [m]")
ylabel("Power [-]")
legend()