function [param,cost_range] = optimizeCost(param,Y,r,n_lenders,n_loans,n_features,lambda,step,maxrun)
    cost_range = zeros(maxrun,1);
    threshold = 0.001;
    old_J = 0;
    for iter = 1:maxrun
        [J,grad] = costFunction(param,Y,r,n_lenders,n_loans,n_features,lambda);
        param = param - step * grad; % Gradient descent for both X and Theta
        cost_range(iter) = J;
        if abs(J-old_J)<threshold
            disp('Threshold meets');
            break
        end
        old_J = J;
    end
end