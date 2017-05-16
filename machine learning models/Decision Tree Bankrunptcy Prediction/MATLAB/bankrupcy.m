function main()
	clear all;
	[data,txt,raw] = xlsread('bankruptcy.xls','Sheet1');
	valnum = 2; % binary 0/1, note this code only work for binary data, can extend
	train_pc = 0.7;
	depth = 4;

	x = data(:,1:12);
	y = (data(:,13) == 1);
	for i=1:size(x,2)
		if (length(unique(x(:,i)))>valnum) % if continuous need to discretize 
			binEdges = linspace(min(x(:,i)),max(x(:,i)),valnum+1); % create edges for discretization
			[~,binIdx] = histc(x(:,i),[binEdges(1:end-1) Inf]); % binIdx is the discretized values, which is actually bin number
			x(:,i) = binIdx-1; % values 0/1 instead of 1/2
		end
	end

	[m,n] = size(x);
	% stratified sampling
	train_ind = [randsample(find(y==0),floor(train_pc*sum(y==0)));randsample(find(y==1),floor(train_pc*sum(y==1)))];

	yTrain = y(train_ind,:);
	xTrain = x(train_ind,:);
	tree = buildtree(xTrain, yTrain, depth); % create a tree recursively
	tree = tree(~cellfun('isempty',tree)); % remove unnessary cells which are empty 

	print(tree);

	trainpred = classify(tree, xTrain);
	disp('Training Accuracy:');
	mean(trainpred==yTrain)

	yTest = y(setdiff((1:m),train_ind),:);
	xTest = x(~ismember(1:m,train_ind),:);
	testpred = classify(tree, xTest);
	disp('Test Accuracy:');
	mean(testpred==yTest)
	
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
	end
	
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
	end
	
	function [gain, max_gain_feature] = infogain(x,y)
		info_gains = zeros(1, size(x,2));

		% calculate information i(N)
		classes = unique(y)';
		iN = 0;
		for c=classes
			py = sum(y==c)/size(y,1);
			iN = iN - py*log2(py);
		end

		% iterate over all variables on columns
		for col=1:size(x,2)
			values = unique(x(:,col))';
			% entropy
			iNx = 0;
			for f=values % only binary 0/1 for now
				pf = sum(x(:,col)==f)/size(x,1);
				yf = y(find(x(:,col)==f));
				
				classes = unique(yf)';
				iNk = 0;
				for c=classes
					pyf = sum(yf==c)/size(yf,1);
					iNk = iNk - pyf*log2(pyf);
				end
				iNx = iNx + pf * iNk;
			end
			info_gains(col) = iN - iNx;
		end
		[gain, max_gain_feature] = max(info_gains);
	end
	
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
	end

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
end