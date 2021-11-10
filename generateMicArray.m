function mics = generateMicArray(x,y,z)
[X,Y,Z] = meshgrid(x,y,z);
X = reshape(X,[],1);
Y = reshape(Y,[],1);
Z = reshape(Z,[],1);
mics = [X,Y,Z];
end
