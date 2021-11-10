f_trues = [500,503];
colors = colororder;

figure("Name", "buckets")
for i = 1:2
    f_true = f_trues(i);
    x = 480:5:520;
    gauss = exp(-(x-f_true).^2/5^2);
    x = 480:5:520;
    x = [480-2.5, repelem(482.5:5:517.5, 2), 520+2.5];
    gauss = repelem(gauss,2);
    plot(x,gauss,'--',"Color",colors(i,:))
    hold on
    x = linspace(480,520);
    gauss = exp(-(x-f_true).^2/5^2);
    plot(x,gauss,"Color",colors(i,:))
end

xlabel("$f$ [Hz]")
ylabel("PSD")
