function pred = classify(tree, X)
[n,~] = size(X);
pred = zeros(n,1);

for i=1:n
  node = 1; % start with the root node
  while true % for each test instance, go through the trained tree until the leaf
    if ~tree{node}.isLeaf
      var = tree{node}.variable;
      if (X(i, var) == 1)
        node = tree{node}.rightchild;
      else
        node = tree{node}.leftchild;
      end
    else
      label = tree{node}.labels;
      if label(1) == label(2)
        pred(i) = randi(2) - 1; % if the counts are ties just randomly assign classes
      else
        pred(i) = label(2) > label(1);
      end
      break;
    end
  end
end


