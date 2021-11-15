%% Generate a Network
% datadir = "/Users/markstephenson/Projects/rss-trilateration/data/characterization_2";
% exp = "x_(?<x>-?\d+.?\d*)_y_(?<y>-?\d+.?\d*)_z_(?<z>-?\d+.?\d*).*\.xlsx";
% characterization_2 = loadTestFolder(datadir,exp,"fs",30000,"SignalRange",[480,520],"Plot",false);
% 
% datadir = "/Users/markstephenson/Projects/rss-trilateration/data/validation_2";
% validation_2 = loadTestFolder(datadir,exp,"fs",30000,"SignalRange",[480,520],"Plot",false);

[x, y] = generateNNData(characterization_2);
[xval, yval] = generateNNData(validation_2);

[layers, options] = buildNetwork(8,3,20,6);
options.MaxEpochs = 1800;
options.ValidationData = {xval, yval};

net = trainNetwork(x,y,layers,options);
est = predict(net,xval);

figure
scatter3(y(:,1),y(:,2),y(:,3),".")
hold on
scatter3(yval(:,1),yval(:,2),yval(:,3),'s')
scatter3(est(:,1),est(:,2),est(:,3),'s')
quiver3(yval(:,1),yval(:,2),yval(:,3),est(:,1)-yval(:,1),est(:,2)-yval(:,2),est(:,3)-yval(:,3),0)
xlim([0,5])
ylim([0,5])
axis equal

%% Evaluate a Moving Trial
% datadir = "/Users/markstephenson/Projects/rss-trilateration/data/moving_2/walking";
% fname = "x1_0_y1_4_x2_4_y2_4_x3_4_y3_0_z_2.20_trial_1.xlsx";
% Lmove = loadTestFolder(datadir,fname,"fs",30000,"SignalRange",[480,520],"Plot",false);

xL = generateNNData(Lmove,"Outputs",[],"N",inf);
est = predict(net,xL);

figure
plot3(est(:,1),est(:,2),est(:,3),'s-')
hold on
plot3([0,4,4],[4,4,0],2.2*[1,1,1],'k')
xlim([0,5])
ylim([0,5])
axis equal
