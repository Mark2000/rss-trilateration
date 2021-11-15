function [v, fsource] = dopplerVelocity(f,x,mics)
    c = 343; % m/s
    
    function out = optFn(in)
        v = in(1:3);
        fsource = in(4);
        r = x - mics;
        
        err = fsource * c ./ (c + dot(v.*ones(length(r),1), r, 2)) - f';
        out = sum(err.^2);
    end

    options = optimset();
    optim = fminsearch(@optFn,[0, 0, 0 mean(f)],options);
    v = optim(1:3);
    fsource = optim(4);
end