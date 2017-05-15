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