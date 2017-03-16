function [tree] = buildtree(X, Y, maxdepth)
    global index
	if size(X,2) < maxdepth
	  maxdepth = size(X,2);
	end

	tree = cell(2^size(X,2) + 1, 1);   
	index = 1;
	curnode = 1;
    parent = -1;
	tree = build(tree, parent, curnode, X, Y, maxdepth);
end

function [tree] = build(tree, parent, curnode, X, Y, maxdepth)
  global index
  if  index == 1  
      tree{curnode} = struct('parent', parent, 'depth', 0);
  else
      tree{curnode} = struct('parent', parent, 'depth', tree{parent}.depth + 1);
  end
  isLeaf = ~(tree{curnode}.depth < maxdepth);
  tree{curnode}.isLeaf = isLeaf;
  if ~isLeaf
    % Choose split var
    [used_vars,~] = varpath(tree, curnode);
    
    availVars = setdiff(1:size(X,2), used_vars);
    % select a variable to split
    [~, bestIndex] = infogain(X(:,availVars), Y);

    tree{curnode}.variable = availVars(bestIndex);

    % Add child nodes
    leftchild = index + 1;
    rightchild= index + 2;
    index = index + 2;

    tree{curnode}.leftchild = leftchild;
    tree{curnode}.rightchild = rightchild;
    
    % Depth first search (DFS)
    v = availVars(bestIndex);
    % X(X(:,v)==0,:) is the set of observations split to the left child, and
    % X(X(:,v)==1,:) is is the set of observations split to the right child
    tree = build(tree, curnode, leftchild, X(X(:,v)==0,:), Y(X(:,v)==0,:), maxdepth); % to create a left child with the current node as the parent
    tree = build(tree, curnode, rightchild, X(X(:,v)==1,:), Y(X(:,v)==1,:), maxdepth); % to create a right child with the current node as the parent
  else     
    [y0 y1] = leafcat(tree, curnode, X, Y); % count obs in each class at the leaf nodes
    tree{curnode}.labels = [y0 y1];
  end    
end


