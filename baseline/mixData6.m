function [XX,pc] = mixData6(X, dim)

rand = randperm(size(X,1));
r=size(X,1);

if(dim<1000) 
    A = X(rand(1:r),:);
else
    if dim>r
        A = X(rand(1:r),:);
    else
        A = X(rand(1:dim),:);
    end
end

B = A;
XX = X*B';

K = B*B';
[V,l] = eig(double(K));

[a,b] = sort(diag(l),'descend');
l = diag(a);
V = V(:,b);

XX = XX*V*pinv(l)*l.^(1/2);
pc = B'*V*pinv(l)*l.^(1/2);

if dim < size(XX,2)
    XX = XX(:,1:dim);
    pc = pc(:,1:dim);
end















