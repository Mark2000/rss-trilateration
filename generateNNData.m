function varargout = generateNNData(trials,varargin)
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

X = [];
Y = [];

for trial = trials 
    if N
        for ii = floor(linspace(1,length(trial.t),min(N,length(trial.t))))
            X = [X; trial.i(ii,:)];
            ypoint = [];
            for output = outputs
                ypoint = [ypoint, trial.(output)];
            end
            Y = [Y; ypoint];
        end
    else
        X = [X; mean(trial.i)];
        ypoint = [];
        for output = outputs
            ypoint = [ypoint, trial.(output)];
        end
        Y = [Y; ypoint];
    end
end

if nargout == 1
    varargout{1} = [X, Y];
elseif nargout == 2
    varargout{1} = X;
    varargout{2} = Y;
end

if ~isempty(fname)
    writematrix([X, Y],fname);
end
end

