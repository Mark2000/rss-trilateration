% Analysis tool for microphone and speaker omnidirectionality
%
% Theta is rotation of test article on x-y plane, CCW from +x.
% Phi is elevation angle of test article.
% 
% Hence, -theta and -phi should be used when plotting response pattern.
%
% Naming scheme is rec_theta_phi_dist_trialNumber.csv, where dist is the
%   distance in m

clear;

datadir = "Data/omni_test";
exp = "rec_(\d+.?\d*)_(\d+.?\d*)_(\d+.?\d*)_\d+.m4a";

Ftone = 493.88;

files = convertCharsToStrings(strsplit(ls(datadir)));
valid = regexp(files,exp);
valid = [valid{:}] == 1;
files = files(valid);
trials = [];

for fname = files
    params = regexp(fname, exp,'tokens');
    trial.theta = str2double(params{1}(1));
    trial.phi = str2double(params{1}(2));
    trial.dist = str2double(params{1}(3));
    
    trial.x = trial.dist*cosd(-trial.phi)*cosd(-trial.theta);
    trial.y = trial.dist*cosd(-trial.phi)*sind(-trial.theta);
    trial.z = trial.dist*sind(-trial.phi);
    
    [p, Fs] = audioread(fullfile(datadir, fname)); % Change for csv
    trial.Fs = Fs;
    trial.p = p;
    
    P = fft(p);
    L = length(p);
    P2 = abs(P/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = Fs*(0:(L/2))/L;    
    [pk,loc] = findpeaks(P1,f,'NPeaks',1,'SortStr','descend');
    
    trial.pressure = pk;
    trial.peakloc = loc;
    
    %% Save to trials
    if isempty(trials)
        trials = trial;
    else 
        trials(end+1) = trial;
    end
end

scatter3([trials.x],[trials.y],[trials.z],[trials.pressure]*100000,'.')

