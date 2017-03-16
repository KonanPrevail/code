function [num_y0, num_y1] = leafcat(tree, node, X, Y)
% return the counts of classes and from there to classify instances
[variables,values] = varpath(tree, node); % get the variables from the node up to the root
[n,~] = size(X);
mask = true(n,1);
for i=1:size(variables,1) % iterate through variables/columns
  mask = mask & (X(:, variables(i)) == values(i)); % mark instances that were split on each node/variable. Finally mask would have instances onto the current leaf node
end
num_y1 = sum(Y(mask)); % only good for binary
num_y0 = n - num_y1; % only good for binary