function [pca,w,k]=pca(X,alpha)
    [n,d]=size(X);
    covm=cov(X);
    [E,D]=eig(covm); % can also use pca functions in Matlab for principal components
    [val,loc]=sort(diag(D),'descend');
    if alpha>=1
        k=alpha;
    else
        k=sum((cumsum(val)/sum(val))<=alpha);
        if k==0 k=1; end;
    end
    E=E(:,loc);
    w=E(:,1:k);
    length=sqrt(sum(w.^2));
    w=w./(ones(d,1)*length);
    pca=X*w; 

