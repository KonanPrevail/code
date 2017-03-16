function [tree] = buildtree(X, Y, maxdepth)
if size(X,2) < maxdepth
  maxdepth = size(X,2);
end

tree = cell(2^size(X,2) +1, 1);   
curmax = 1;
curnode = 1;
tree{1} = struct('parent', -1, 'depth', 0);
queue = [1];
  
while size(queue,2) > 0
  curnode = queue(1);
  
  queue = queue(2:size(queue,2));
  is_nonterm = tree{curnode}.depth < maxdepth;
  tree{curnode}.is_nonterm = is_nonterm;

  if is_nonterm
    % Choose split var
    [used_vars,~] = get_pathvars(tree, curnode);
    
    available_vars = setdiff(1:size(X,2), used_vars);
    % select a variable to split
    % var = choose_split_variable(X, Y, avail_vars);
    X = 
    [best_ind, ~] = infogain(X, Y);
    tree{curnode}.variable = available_vars(best_ind);

    % Add child nodes
    leftchild = curmax + 1;
    rightchild= curmax + 2;
    curmax = curmax + 2;

    tree{curnode}.leftchild = leftchild;
    tree{curnode}.rightchild = rightchild;

    % Create child nodes
    tree{leftchild}  = struct('parent', curnode, 'depth', tree{curnode}.depth+1);
    tree{rightchild} = struct('parent', curnode, 'depth', tree{curnode}.depth+1);

    queue = [queue leftchild rightchild];
  else
    [y0 y1] = leafcat(tree, curnode, X, Y); % count obs in each class at the leaf nodes
    tree{curnode}.y_counts = [y0 y1];
  end
end



