%% Mic Setup
grid_size = 5;
offset = grid_size/2-.42/sqrt(2);
% x = [offset,offset,-offset,-offset,-offset,-offset,offset,offset];
% y = [offset,offset,offset,offset,-offset,-offset,-offset,-offset];
x = [0,0,5,5,5,5,0,0];
y = [0,0,0,0,5,5,5,5];
high = 3.05;
low = 1.45;
z = [low,high,low,high,low,high,low,high];

fs = 30000;

mics = [];
for imic = 1:8
    mic.pos = [x(imic), y(imic), z(imic)];
    
    if isempty(mics)
        mics = mic;
    else 
        mics(end+1) = mic;
    end
end

%% Data Location
datadir = "/Users/markstephenson/Desktop/441/441 Data/5x5lowmove";
exp = "x_(-?\d+.?\d*)_y_(-?\d+.?\d*)_z_(-?\d+.?\d*).*.xlsx";
% exp = "x1_0_y1_1_x2_5_y2_1_z_2.40_trial_1_bike.xlsx";

bike = load_mic_data(datadir, exp, fs);