clear all; close all; clc;
[Y,txt,raw1] = xlsread('loandata.xlsx','loanrating','A1:J101');
[num,text,raw2] = xlsread('loandata.xlsx','loan','A1:J101');
R = (Y~=0);

n_lenders = size(Y,2);
n_loans = size(Y,1);
n_features = 10;

% Initialization
X = randn(n_loans,n_features);
Theta = randn(n_lenders,n_features);
init_param = [X(:); Theta(:)];

% Optimization
lambda = 10;
maxrun = 10000; % maximum number of iterations
step = 0.001; 
[param,cost_range] = optimizeCost(init_param,Y,R,n_lenders,n_loans,n_features,lambda,step,maxrun);

% Extract X and Theta from the variable theta
X = reshape(param(1:n_loans*n_features),n_loans,n_features);
Theta = reshape(param(n_loans*n_features+1:end),n_lenders,n_features);
pred = X * Theta';

top_n=3;
for j=1:n_lenders
    [rating,ind] = sort(pred(:,j),'descend');
    fprintf('\nTop %d recommendations for lender %d:\n',top_n,j);
    for i=1:top_n
        fprintf('Predicted rating %.1f for loan of %.1f for %s with %s purpose at %.1f percent interest\n', rating(i), num(ind(i),1),text{ind(i)+1,2},strrep(text{ind(i)+1,7},'_',' '),num(ind(i),3));        
    end
end
