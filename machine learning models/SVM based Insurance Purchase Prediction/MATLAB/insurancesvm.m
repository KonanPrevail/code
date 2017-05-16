function main()
	%% ================== Reset the workspace ===================
	clear all;close all;clc;

	%% ================== Insurance Dataset =====================
	[data,txt,raw] = xlsread('insurance.xls','data');
	y = double(strcmp(txt(2:end,31),'Yes')); % 0 and 1
	y(y==0)=-1; % 1 and -1
	X = [data(:,1:7),data(:,9:end)]; % only numeric fields
	X = normalize(X); % binary fields are not affected from min-max normalization
	[m,n] = size(X);
	beta = 0.95;

	% Stratified sampling, 2 strata
	train_pc = 0.7;
	train_ind = [randsample(1:sum(y==-1),floor(train_pc*sum(y==-1))),sum(y==-1)+randsample(1:sum(y==1),floor(train_pc*sum(y==1)))];
	TrainSize = size(train_ind,2);
	yTrain = y(ismember(1:m,train_ind),:);
	yTest = y(~ismember(1:m,train_ind),:);
	XTrain = X(ismember(1:m,train_ind),:);
	XTest = X(~ismember(1:m,train_ind),:);

	% New representation of the training and test data sets
	[XTrain,w] = pca(XTrain,beta);
	XTest=XTest*w; 

	% Gaussian Kernel
	sigma = 0.1;
	K = kernel(XTrain,XTrain,sigma,0);
	a0=eps*ones(TrainSize,1);

	% Inequality that individual alpha>=0
	A = -eye(TrainSize);
	b = zeros(TrainSize,1);

	% Equality that sum(alpha_i*y_i)=0
	Aeq = yTrain';
	beq = 0;

	C = 1e+20; 

	% Change from min to max optimization by multiplying with -1
	H = diag(yTrain)*K*diag(yTrain)+1e-10*eye(TrainSize); % Regularization term to force H positive definite
	f = -ones(TrainSize,1);

	options = optimset('UseParallel','always','Display','iter','MaxIter',100,'MaxFunEvals',1000000,'LargeScale', 'off');
	alpha = quadprog(H,f,A,b,Aeq,beq,zeros(TrainSize,1),C*ones(TrainSize,1),a0,options);

	indx = find(alpha >= eps);
	b = mean(yTrain(indx)-K(indx,:)*(alpha.*yTrain));
	pred = sign(((1+kernel(XTest,XTrain,sigma,0)).^2)*(alpha.*yTrain)+b);
	fprintf('Test Accuracy: %f\n', mean(double(pred==yTest))*100);

	pred = sign(((1+kernel(XTrain,XTrain,sigma,0)).^2)*(alpha.*yTrain)+b);
	fprintf('Train Accuracy: %f\n', mean(double(pred==yTrain))*100);

	function [J,grad] = costFunction(param,Y,r,n_lenders,n_loans,n_features,lambda)
		% Extract X and Theta from param vector
		X = reshape(param(1:n_loans*n_features),n_loans,n_features);
		Theta = reshape(param(n_loans*n_features+1:end),n_lenders,n_features);
					
		% Cost
		predictions = X*Theta'; % prediction,nm x nu
		errors = (predictions-Y).*r; % also nm x nu
		J = (1/2)*sum(sum(errors.^2));

		% Gradients
		X_grad = errors*Theta; % error is  nm x nu,and Theta is nu x n,X_grad is nm x n
		Theta_grad = errors'*X; % error' is  nu x nm,X is nm x n,so Theta_grad is nu x n

		% Regularized cost function to penalize overfitting
		reg_X = (lambda/2)*sum(sum(X.^2));
		reg_Theta = (lambda/2)*sum(sum(Theta.^2));
		J = J+reg_Theta+reg_X;

		% Add regularization terms to gradients
		X_grad = X_grad+lambda*X;
		Theta_grad = Theta_grad+lambda*Theta;

		grad = [X_grad(:); Theta_grad(:)];
	end
	
	function K=kernel(XTest,XTrain,sigma,type);
		% Gaussian kernel
		if type==0 
			K = XTest*XTrain';
		else 
			X1 = sum(XTest.^2,2);
			X2 = sum(XTrain.^2,2)';
			K = bsxfun(@plus,X1,bsxfun(@plus,X2,-2*XTest*XTrain'));
			K = exp(-K/2/sigma);
		end 
	end
	function [Xnorm] = normalize(X)
		[m,n] = size(X);
		maxval = max(X);
		minval = min(X);
		Xnorm = (X-repmat(minval,m,1))./(repmat(maxval,m,1)-repmat(minval,m,1));
	end
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

	end
end