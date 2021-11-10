trials = {trials5mhigh, trials5mlow, trials10mhigh, trials10mlow}

for 
    trials = trials{1};
    for imic = imics
        for trial = trials
            ring(trial.theta==thetas,imic) = mean(trial.mic(imic).p);
        end
    end
    1./mean(ring)
end