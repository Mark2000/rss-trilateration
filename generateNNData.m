function data = generateNNData(trials,varargin)
% Generates a training point from the mean of the trial if no N given, or
% up to N points distributed across the trial if N given

p = inputParser;
addOptional(p,'N',0);
addOptional(p,'fname',[]);
addOptional(p,'Outputs',["pos"])
parse(p,varargin{:});

N = p.Results.N;
fname = p.Results.fname;
outputs = p.Results.Outputs;

data = [];

for trial = trials 
    if N
        for ii = floor(linspace(1,length(trial.t),min(N,length(trial.t))))
            datapoint = trial.i(ii,:);
            for output = outputs
                datapoint = [datapoint, trial.(output)]
            end
            data = [data; datapoint];
        end
    else
        datapoint = mean(trial.i);
        for output = outputs
            datapoint = [datapoint, trial.(output)];
        end
        data = [data; datapoint];
    end
end

if ~isempty(fname)
    writematrix(data,fname);
end
end

