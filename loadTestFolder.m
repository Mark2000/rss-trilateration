function trials = loadTestFolder(datadir, exp, varargin)
% Loads a folder of datasets
% Example exp = "x_(?<x>-?\d+.?\d*)_y_(?<y>-?\d+.?\d*)_z_(?<z>-?\d+.?\d*).*\.xlsx"

%% Data Location
files = convertCharsToStrings(strsplit(ls(datadir)));
valid = regexp(files,exp);
valid = cellfun(@isempty,valid,'UniformOutput',false);
valid = [valid{:}] == 0;
files = files(valid);

% Load Trials
trials = [];
for fname = files
    fprintf("Loading %s (File %.f of %.f)\n", fname,find(fname==files),length(files))
    params = regexp(fname, exp,'names');
    paramnames = fieldnames(params);
    
    for iparam = 1:length(paramnames)
        trial.(paramnames{iparam}) = str2num(params.(paramnames{iparam}));
    end
    
    if isfield(trial, 'x') && isfield(trial, 'y') && isfield(trial, 'z')
        trial.pos = [trial.x, trial.y, trial.z];
    end
    
    data = readmatrix(fullfile(datadir, fname));
    dsize = size(data);
    nmics = dsize(2);
    
    for imic = 1:nmics
        fprintf("\tProcessing mic %.f of %.f\n",imic,nmics)
        [I,F,T] = peakSignal(data(:,imic), varargin);
        if ~isfield(trial,'t')
            trial.t = T;
            trial.f = zeros(length(T),nmics);
            trial.i = zeros(length(T),nmics);
        end
        trial.f(:,imic) = F;
        trial.i(:,imic) = I;
    end
        
    %% Save to trials
    if isempty(trials)
        trials = trial;
    else 
        trials(end+1) = trial;
    end
end
