import numpy as np
import math
import random

###### function to select a variable to split
def infogain(x, y):
	info_gains = np.zeros(np.size(x, 1))
	# calculate information i(N)
	classes = np.unique(y)  # only binary 0/1
	iN = 0
	for class_value in classes:
		py = list(y).count(class_value) / np.size(y, 0)
		iN = iN - py * math.log(py) / math.log(2)

	# iterate over all variables on columns
	for col in range(np.size(x, 1)):
		values = np.unique(x[:, col]) # only binary 0/1
		# entropy
		iNx = 0
		for class_value in values:
			pf = list(x[:, col]).count(class_value) / np.size(x, 0)
			yf = y[x[:, col]==class_value]
			classes = np.unique(yf) # only binary 0/1
			iNk = 0
			for class_value in classes:
				pyf = list(yf).count(class_value) / np.size(yf, 0)
				iNk = iNk - pyf * math.log(pyf) / math.log(2)
			iNx = iNx + pf * iNk
		info_gains[col] = iN - iNx

	max_gain_feature = np.argmax(info_gains)
	gain = np.amax(info_gains)
	return {'gain':gain, 'max_gain_feature':max_gain_feature}


##### function to find used variables
def varpath(tree, node):
	curdepth = tree[node]['depth']  # get the depth of the node
	varis = [dict() for i in range(curdepth)] # var is used in python
	vals = [dict() for i in range(curdepth)]
	while curdepth > 0:
		current = tree[node] # current node
		parent = tree[tree[node]['parent']] # parent node
		# which variable was the parent node split on?
		varis[curdepth-1] = parent['variable']
		# if the node is the right child, the value=1, if it is the left, the value = 0
		vals[curdepth-1] = parent['rightchild'] == node
		# move up to the parent
		node = current['parent']
		curdepth = curdepth - 1
	return {'varis': varis, 'vals': vals}


##### function to count distribution on leaf
def leafcat(tree, node, X, Y):
	# return the counts of classes and from there to classify instances	
	variables = varpath(tree, node)['varis']
	values = varpath(tree, node)['vals']
	mask = list()
	for i in range(np.size(X, 0)):
		if np.all(X[i][variables] == values):
			mask.append(i)
	num_y0 = list(Y[mask]).count(0)
	num_y1 = list(Y[mask]).count(1)
	return {'num_y0': num_y0, 'num_y1': num_y1}


##### function to print tree
def printree(tree):
	traverse(tree, 0, "")
	return()

def traverse(tree, node, s):
	if not(tree[node]['isLeaf']):
		if len(s) > 0:
			print(s)
		traverse(tree, tree[node]['leftchild'], s+"V"+str(tree[node]['variable'])+'=0 ')
		traverse(tree, tree[node]['rightchild'], s+"V"+str(tree[node]['variable'])+'=1 ')
	else:
		y0 = tree[node]['labels']['num_y0']
		y1 = tree[node]['labels']['num_y1']
		s = s + '=> classify y='+ str((y1>y0)*1) + ', distribution = ['+str(y0)+':'+str(y1)+']'
		print(s)
	return()


def buildtree(X, Y, maxdepth):
	global index
	if np.size(X, 1) < maxdepth:
		maxdepth = size(X, 1)
	tree = [dict() for i in range(2**(maxdepth+1))]
	index = 0 # change for python 
	curnode = 0 # change for python
	parent = -1
	tree = build(tree, parent, curnode, X, Y, maxdepth)
	return tree

def build(tree, parent, curnode, X, Y, maxdepth):
	global index
	if index == 0:
		tree[curnode] = {'parent': parent, 'depth': 0}
	else:
		tree[curnode] = {'parent': parent, 'depth': tree[parent]['depth']+1}
	isLeaf = not(tree[curnode]['depth'] < maxdepth)
	tree[curnode]['isLeaf'] = isLeaf
	if not(isLeaf):
		# choose split var
		used_vars = varpath(tree, curnode)['varis']
		availVars = np.delete(range(0, np.size(X, 1)), used_vars)
		# select a variable to split
		bestIndex = infogain(X[:, availVars], Y)['max_gain_feature']
		tree[curnode]['variable'] = availVars[bestIndex]
		# add child nodes
		leftchild = index + 1
		rightchild = index + 2
		index = index + 2
		tree[curnode]['leftchild'] = leftchild
		tree[curnode]['rightchild'] = rightchild
		# keep generating tree
		v = availVars[bestIndex]
		tree = build(tree, curnode, leftchild, X[X[:, v] == 0, :], Y[X[:, v] == 0], maxdepth)
		tree = build(tree, curnode, rightchild, X[X[:, v] == 1, :], Y[X[:, v] == 1], maxdepth)
	else:
		# count obs in each class at the leaf nodes
		tree[curnode]['labels'] = leafcat(tree, curnode, X, Y)
	return tree

def classify(tree, X):
	n = np.size(X, 0)
	pred = np.zeros(n)
	for i in range(n):
		node = 0
		while True:
			if not(tree[node]['isLeaf']):
				var = tree[node]['variable']
				if X[i, var] == 1:
					node = tree[node]['rightchild']
				else:
					node = tree[node]['leftchild']
			else:
				label = tree[node]['labels']
				if label['num_y0'] == label['num_y1']:
					pred[i] = random.choice([True, False]) #random choice if distribution is equal
				else:
					pred[i] = (label['num_y1']>label['num_y0'])*1
				break
	return(pred)

import pandas
import numpy as np
import math
import random

valnum = 2 # binary situation
train_pc = 0.7
depth = 4

# read data from xls file
datPath = "../data/bankruptcy.xls"

# load data, remove first row of names, skip first column
datafile = pandas.read_excel(datPath, skiprows = 0, parse_cols="B:N")
# convert to matrix
data = datafile.as_matrix()

x = np.array(data[:, 0:12])
y = np.array(data[:, 12]) # keep it simple for binary situation

for i in range(np.size(x, 1)):
	if len(np.unique(x[:, i]))>valnum: # if continuous need to discretize
		binEdges = np.linspace(np.amin(x[:, i]), np.amax(x[:, i]), num = valnum + 1)
		binEdges[valnum] = binEdges[valnum]+1
		binIdx = np.digitize(x[:, i], bins=binEdges)
		x[:, i] = binIdx - 1 #0/1 values instead of 1/2 values

m = np.size(x, 0)
n = np.size(x, 1)
#random.seed(503) # set random seed
size1 = math.floor(train_pc * sum(y == 0))
size2 = math.floor(train_pc * sum(y == 1))
indY1 = np.linspace(0, len(y) - 1, len(y), dtype="int")[y == 0]
indY2 = np.linspace(0, len(y) - 1, len(y), dtype="int")[y == 1]
train_ind = np.concatenate((np.random.choice(indY1, size1, False),
                          (np.random.choice(indY2, size2, False))), axis=0)
yTrain = y[train_ind]
yTest = np.delete(y, train_ind, axis=0)
xTrain = x[train_ind, :]
xTest = np.delete(x, train_ind, axis=0)

tree = buildtree(xTrain, yTrain, depth)
printree(tree)

trainpred = classify(tree, xTrain)
print("Train Accuracy: %f\n" % (np.mean(yTrain == trainpred) * 100))

testpred = classify(tree, xTest)
print("Test Accuracy: %f\n" % (np.mean(yTest == testpred) * 100))