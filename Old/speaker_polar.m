trials = trials10mlow;

imics = 1:8;%length(mics);
thetas = [0:45:315];
ring = zeros(length(thetas),length(imics));
dring = ring;

for imic = imics
    for trial = trials
        ring(trial.theta==thetas,imic) = mean(trial.mic(imic).p);
        dring(trial.theta==thetas,imic) = max(max(trial.mic(imic).p)-mean(trial.mic(imic).p),mean(trial.mic(imic).p)-min(trial.mic(imic).p));
    end
end

normring = ring;
scaling = 1./mean(normring)
dring = dring./mean(normring);
normring = normring./mean(normring); % normalize mics
dring = dring./mean(normring,2);
normring = normring./mean(normring,2); % normalize trials

colors = colororder;
speakerpolar = zeros(size(thetas));

plotmics = 1:1:8;

for imic = plotmics
    stand = ceil(imic/2);
    speakerthetas = mod(135+90*stand-thetas,360);    
    polarang = sortrows([speakerthetas',normring(:,imic)]);
    speakerpolar = speakerpolar + polarang(:,2)';
end
speakerpolar = speakerpolar/length(plotmics);
normfac = 1/max(speakerpolar);
% normfac = 1;

% close loops
polarang = [polarang(:,1);polarang(1)];
speakerpolar = [speakerpolar,speakerpolar(1)];

polarplot(polarang*pi/180,speakerpolar*normfac,".-k","DisplayName","Speaker Polar","LineWidth",2)
hold on

for imic = plotmics
    stand = ceil(imic/2);
    speakerthetas = mod(135+90*stand-thetas,360);
    if mod(imic,2) == 1
        formats = "-";
        height = "Low";
    else
        formats = "--";
        height = "High";
    end
    
    % close loops
    speakerthetas = [speakerthetas(:);speakerthetas(1)];
    micring = [normring(:,imic);normring(1,imic)];
    dmicring = [dring(:,imic);dring(1,imic)];
    
    polarplot(speakerthetas*pi/180,micring*normfac,"."+formats,"Color",colors(stand,:),"DisplayName","Stand " + stand + ", " + height + " (Mic " + imic +")")
    
    for i = 1:length(speakerthetas)
        rs = [micring(i)-dmicring(i),micring(i)+dmicring(i)];
        polarplot(speakerthetas(i)*[1,1]*pi/180,rs*normfac,'.-',"Color",colors(stand,:),"HandleVisibility","off")
    end
end

polarplot(linspace(0,2*pi),ones(1,100),':k',"HandleVisibility",'off');

rlim([0,1.5])
% legend