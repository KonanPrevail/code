function [vars,vals] = varpath(tree, node)
curdepth = tree{node}.depth; % get the depth of the node
vars = zeros(tree{node}.depth, 1);
vals = vars;
while curdepth>0
  current = tree{node}; % current node
  parent = tree{tree{node}.parent}; % parent node
  vars(curdepth) = parent.variable; % which variable was the parent node split on?
  vals(curdepth) = parent.rightchild==node;   % if the node is the right child, the value=1, if it is the left, the value = 0
  node = current.parent; % move up to the parent
  curdepth = curdepth - 1; % and reduce the depth correspondingly
end