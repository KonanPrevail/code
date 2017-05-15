function print(tree)
    % Depth First Search
    traverse(tree, 1, '');
end

function s = traverse(tree, node, s)
    if ~tree{node}.isLeaf
      if (length(s) > 0)
        disp(s);
      end
      traverse(tree, tree{node}.leftchild, strcat(s,' V',num2str(tree{node}.variable),'=0'));
      traverse(tree, tree{node}.rightchild, strcat(s,' V',num2str(tree{node}.variable),'=1'));
    else
      s = strcat(s,' => classify y=', num2str(tree{node}.labels(2)>tree{node}.labels(1)), ' distribution=[',num2str(tree{node}.labels(1)),', ', num2str(tree{node}.labels(2)),']');
      disp(s)
    end  
end

