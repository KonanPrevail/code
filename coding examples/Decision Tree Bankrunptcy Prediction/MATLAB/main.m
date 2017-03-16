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