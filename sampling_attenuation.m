figure("Name", "attenuation")
x = linspace(-5,5,200);
msize = 50;

colors = colororder;

gauss = exp(-x.^2);
plot(x,gauss,"Color",colors(1,:),'DisplayName',"Gaussian")
hold on
plot(x,movmean(gauss,msize),'--',"Color",colors(1,:),'DisplayName',"Gaussian (avg)");

sigmoid = 1./(1+exp(-x));
plot(x, sigmoid,"Color",colors(2,:),'DisplayName',"Sigmoid")
plot(x,movmean(sigmoid,msize),'--',"Color",colors(2,:),'DisplayName',"Sigmoid (avg)");

legend("Location",'northwest')
xlabel("$x$")
ylabel("$y$")

saveNiceFigure(gcf,[4,2.5],"png")
