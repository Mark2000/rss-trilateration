trials = training_data;
ntrials = length(trials);

figure
for imic = 1:8
    pos = zeros(ntrials,3);
    p = zeros(ntrials,1);

    for itrial = 1:ntrials
        pos(itrial,:) = trials(itrial).pos;
        p(itrial) = mean(trials(itrial).mic(imic).p);
    end
    subplot(4,2,imic)
    plot(vecnorm(pos-mics(imic).pos,2,2),p,'.')
    hold on
    title("Mic " + imic)
    xlabel("distance [m]")
    ylabel("power [-]")
%     scatter3(pos(:,1),pos(:,2),pos(:,3),p/mean(p)*100)
%     hold on
end

figure
scatter3(pos(:,1),pos(:,2),pos(:,3),'.',"DisplayName","Sampling Points")
hold on
scatter3(est(:,1),est(:,2),est(:,3),"DisplayName","Estimates")
% scatter3(real(:,1),real(:,2),real(:,3),"DisplayName","Estimates")
quiver3(est(:,1),est(:,2),est(:,3),real(:,1)-est(:,1),real(:,2)-est(:,2),real(:,3)-est(:,3),0,"DisplayName","Error")
axis equal
legend()

figure
scatter3(pos(:,1),pos(:,2),pos(:,3),'.',"DisplayName","Sampling Points")
hold on
scatter3(moving(:,1),moving(:,2),moving(:,3),'o',"DisplayName","Estimates")
quiver3(actual(:,1),actual(:,2),actual(:,3),moving(:,1)-actual(:,1),moving(:,2)-actual(:,2),moving(:,3)-actual(:,3),0,"DisplayName","Error")
scatter3(actual(:,1),actual(:,2),actual(:,3),'o',"DisplayName","Actual")
axis equal
legend()