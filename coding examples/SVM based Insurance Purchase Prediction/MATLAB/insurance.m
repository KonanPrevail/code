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
