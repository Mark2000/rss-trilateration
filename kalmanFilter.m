function [xs, Ps] = kalmanFilter(t, zs, fs, mics, actual)
dt = t(2)-t(1);

% State transisition matrix F
F = eye(9);
F(1,2:3) = [dt, dt^2/2];
F(2,3) = dt;
F(4,5:6) = [dt, dt^2/2];
F(5,6) = dt;
F(7,8:9) = [dt, dt^2/2];
F(8,9) = dt;

% Process noise Q
sa = 1; % random acceleration standard deviation

Q = zeros(9);
Qs = [dt^4/4, dt^3/2, dt^2/2;
      dt^3/2, dt^2, dt;
      dt^2/2, dt, 1];
Q(1:3,1:3) = Qs * sa^2;
Q(4:6,4:6) = Qs * sa^2;
Q(7:9,7:9) = Qs * sa^2;

% Observation Matrix
H = [1,0,0,0,0,0,0,0,0;
     0,0,0,1,0,0,0,0,0;
     0,0,0,0,0,0,1,0,0;
     0,1,0,0,0,0,0,0,0;
     0,0,0,0,1,0,0,0,0;
     0,0,0,0,0,0,0,1,0;];
 
% Measurement Uncertainty
sxm = 0.9;
sym = 0.9;
szm = 0.5;
sv = 0.2;
R = eye(6) .* [sxm^2, sym^2, szm^2, sv^2, sv^2, sv^2];

% Initialize
x = zeros(9,1);
P = eye(9)*500;

% Predict
x = F*x;
P = F*P*F' + Q;

xs = zeros(length(t),length(x));
Ps = zeros([length(t),size(P)]);
for i = 1:length(zs)
    % Measure
    z = [zs(i,:)'; dopplerVelocity(fs(i,:),x([1,4,7])',mics)'];
    
    K = P*H'/(H*P*H'+R);
    
    % Estimate
    x = x + K*(z-H*x);
    m = eye(9) - K*H;
    P = m*P*m' + K*R*K';
    
    xs(i,:) = x;
    Ps(i,:,:) = P;
    
    % Predict
    x = F*x;
    P = F*P*F' + Q;
end

figure

subplot(2,2,[1,3])
errorbar(xs(:,1),xs(:,4),Ps(:,1,1),Ps(:,1,1),Ps(:,4,4),Ps(:,4,4),':o');
hold on
plot(zs(:,1),zs(:,2),'.-')
% plot(actual(:,1),actual(:,2),'s-')
% quiver(actual(:,1),actual(:,2),xs(:,1)-actual(:,1),xs(:,4)-actual(:,2),0,"ShowArrowHead",'off')
xlim([0,5])
ylim([0,5])
xlabel("x [m]")
ylabel("y [m]")

subplot(2,2,2)
errorbar(xs(:,1),xs(:,7),Ps(:,1,1),Ps(:,1,1),Ps(:,7,7),Ps(:,7,7),':o');
hold on
plot(zs(:,1),zs(:,3),'.-')
% plot(actual(:,1),actual(:,3),'s-')
% quiver(actual(:,1),actual(:,3),xs(:,1)-actual(:,1),xs(:,7)-actual(:,3),0,"ShowArrowHead",'off')
xlim([0,5])
xlabel("x [m]")
ylabel("z [m]")
axis equal

subplot(2,2,4)
plot3(xs(:,1),xs(:,4),xs(:,7),':o');
hold on
plot3(zs(:,1),zs(:,2),zs(:,3),'.-')
% plot3(actual(:,1),actual(:,2),actual(:,3),'s-')
% quiver3(actual(:,1),actual(:,2),actual(:,3),xs(:,1)-actual(:,1),xs(:,4)-actual(:,2),xs(:,7)-actual(:,3),0,"ShowArrowHead",'off')
xlim([0,5])
ylim([0,5])
xlabel("x [m]")
ylabel("y [m]")
zlabel("z [m]")
axis equal