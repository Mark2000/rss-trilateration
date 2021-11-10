function trials = load_mic_data(datadir, exp, fs)
% Loads a folder of datasets

trials = [];
%% Data Location
files = convertCharsToStrings(strsplit(ls(datadir)));
valid = regexp(files,exp);
valid = cellfun(@isempty,valid,'UniformOutput',false);
valid = [valid{:}] == 0;
files = files(valid);

trials = [];
for fname = files
    fprintf("Loading %s (File %.f of %.f)\n", fname,find(fname==files),length(files))
    itrial = length(trials)+1;
    params = regexp(fname, exp,'tokens');
    
    if length(params{1}) == 2
        trial.theta = str2double(params{1}(1));
        trial.phi = str2double(params{1}(2));
    elseif length(params{1}) == 3
        trial.pos = str2double(params{1}(1:3));
        if length(params{1}) > 3
            trial.theta = str2double(params{1}(4));
        end
    end
    
    data = readmatrix(fullfile(datadir, fname));
    dsize = size(data);
    nmics = dsize(2);
    
    trial.t = [];
    for imic = 1:nmics
        fprintf("\tProcessing mic %.f of %.f\n",imic,nmics)
        processed = sample_summary(data(:,imic), fs, [480,520], false, 1, .25);
        trial.mic(imic).f = processed.spect.ffit;
        trial.mic(imic).p = processed.spect.pfit;
        if trial.t
            assert(all(trial.t==processed.spect.t),"Error: Data must be similar within a trial!")
        else
            trial.t = processed.spect.t;
        end
    end
        
    %% Save to trials
    if isempty(trials)
        trials = trial;
    else 
        trials(end+1) = trial;
    end
end