function main()
	%% ================== Reset the workspace ===================
	clear all; close all; clc;
	%% ================== No regularization =====================
	[data,txt,raw] = xlsread('bankruptcy.xls','Sheet1');
	X = data(:,1:12);
	X = normalize(X);
	y = data(:,13);                                                                                                                                                                                                                                                                                                                                                                                                                                        
	[m,n] = size(X);
	X = [ones(m,1) X];
	theta = zeros(n+1,1);

	% Optimization using fminunc 
	options = optimset('GradObj', 'on', 'MaxIter', 100);
	[theta,cost] = fminunc(@(t)(computeCost(t,X,y)),theta,options);

	% Accuracy with training set
	pred = sigmoid(X*theta) >= 0.5;
	fprintf('Accuracy: %f\n', mean(double(pred==y))*100);

	%% ============= Now use regularization  ====================
	% Reload the data
	[data,txt,raw] = xlsread('bankruptcy.xls','Sheet1');
	X = data(:,1:12);
	X = normalize(X);
	y = data(:,13);

	% Mapping to higher dimensional space
	X = mapping(X,2);
	theta = zeros(size(X,2),1);
	lambda = 0.01;

	% Optimization using fminunc
	options = optimset('GradObj','on','MaxIter',50);
	[theta,cost] = fminunc(@(t)(computeCost(t,X,y,lambda)),theta,options);

	% Compute accuracy on our training set
	pred = sigmoid(X*theta) >= 0.5;
	fprintf('Accuracy: %f\n', mean(double(pred==y))*100);

	function [cost,grad] = computeCost(theta,X,y,lambda)
		m = length(y); % number of training examples
		cost = 0;
		grad = zeros(size(theta));
		if nargin < 4
			lambda = 0; % this lambda=0 make the reularized term to go away, when a value is passed it is the step
		end
		z = X*theta; % z is m x d
		h = sigmoid(z); % same as z
		grad = (1/m * (h-y)' * X) + lambda * [0;theta(2:end)]'/m; % grad is 1 x d, theta(1) - meaning theta_0 should not be regularized
		cost =  1/(m) * sum(-y .* log(h) - (1-y) .* log(1-h)) + lambda/m/2*sum(theta(2:end).^2); % theta(1) - meaning theta_0 should not be regularized
	end

	function Xmap = mapping(X,degree)
		[m,n] = size(X); % m is number of variables
		power = selectk(0:degree,n);
		ind = (sum(power,2)<=degree & sum(power,2)>0);
		power = power(ind,:);
		p = size(power,1); % number of  polynomial terms
		Xmap = ones(m,1);
		for i = 1:p
			aterm = ones(m,1);
			for j = 1:n
				aterm = aterm .* X(:,j).^power(i,j);    
			end
			Xmap(:,end+1) = aterm;
		end
	end
	function [Xnorm] = normalize(X)
		[m,n] = size(X);
		mu = mean(X);
		sigma = std(X);
		Xnorm = (X-repmat(mu,m,1))./repmat(sigma,m,1);
	end
	function [pca,w,k]=pca(data,para)
		[n,d]=size(data);
		covm=cov(data);
		[E,D]=eig(covm); % can also use pca functions in Matlab for principal components
		[val,loc]=sort(diag(D),'descend');
		if para>=1
			k=para;
		else
			k=sum((cumsum(val)/sum(val))<=para);
			if k==0 k=1; end;
		end
		E=E(:,loc);
		w=E(:,1:k);
		length=sqrt(sum(w.^2));
		w=w./(ones(d,1)*length);
		pca= data*w; 
		% pca=(data - repmat(mean(data),n,1))*w; % remove mean before projection
	end
	function y = selectk(v,k)
		m = length(v);
		X = cell(1,k);
		[X{:}] = ndgrid(v);
		X = X(end:-1:1);
		y = cat(k+1,X{:});
		y = reshape(y,[m^k,k]);
	end
	function g = sigmoid(z)
		g = ones(size(z))./(1+exp(-z));
	end	
end