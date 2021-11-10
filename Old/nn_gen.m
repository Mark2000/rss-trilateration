trials = [training_data];
data = [];
for trial = trials
%     for i = 5:10:length(trial.t)
        p = zeros(1,length(trial.mic));
        for imic = 1:length(trial.mic)
            p(imic) = mean(trial.mic(imic).p);
        end
        data = [data; p, trial.pos];
%     end
end

writematrix(data,"nn_random.csv")