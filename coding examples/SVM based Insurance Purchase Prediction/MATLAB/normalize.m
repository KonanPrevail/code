function [Xnorm] = normalize(X)
[m,n] = size(X);
maxval = max(X);
minval = min(X);
Xnorm = (X-repmat(minval,m,1))./(repmat(maxval,m,1)-repmat(minval,m,1));
end
