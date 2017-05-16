import pandas as pd
import numpy as np
import itertools

def aprioriGen(freqSets, k):
     # generate candidate 2-itemsets
    if k == 2:
        Ck = np.array([list(comb) for comb in itertools.combinations(freqSets,2)])
    else:
        # generate candidate k-itemsets (k > 2)
        Ck = []
        for i in range(0,np.shape(freqSets)[1]):
            for j in range(i+1,np.shape(freqSets)[1]):
                # Merge a pair of (k-1) frequent itemsets if k-2 items are identical using Fk-1 x Fk-1 method
                L1 = np.sort(freqSets[i,0:k-2])
                L2 = np.sort(freqSets[j,0:k-2])
                if np.isequal(L1,L2):
                    Ck = np.concatenate((Ck, np.union(freqSets[i,:],freqSets[j,:])),axis = 0)
    return(Ck)

def ismember(d, k):
    bind = {}
    for i, elt in enumerate(k):
        if elt not in bind:
            bind[elt] = 1
    return [[bind.get(itm[0], 0), bind.get(itm[1], 0)] for itm in d]

def myall(hk):
    l = []
    for item in hk:
        if item[0] == 1 and item[1]==1:
            l.append(hk.index(item))
    return l

def generateFreqItemsets(transactions,minSup):

    transactions = pd.Series(transactions, index = np.arange(0,len(transactions)))
    items_generate = [item for transaction in transactions.values for item in transaction ]
    uniqItems,index, oneItemsets = np.unique(items_generate,return_inverse=True, return_counts=True) # index has indices of original items

    N = len(transactions)

    C1 = uniqItems
    supk = (oneItemsets)/ N # support for all candidates
    S = {}
    for j in range(0,len(C1)):
        S[str(j)] = supk[j]


    Lk = {'items': uniqItems[(supk >= minSup).ravel().nonzero()][0],'index':(supk >= minSup).ravel().nonzero()} # must be >= minimal support
    L = [Lk]

    # get all frequent k-itemsets where k >= 2
    k = 2
    while True:
        # Ck: candidate itemsets
        p = L[k-2]['index'][0]
        Ck = aprioriGen(p, k)

        support = np.zeros(np.shape(Ck)[0])
        for i in range(N):     # walk through all transactions
            t = sorted([items.index(item) for item in transactions.values[i]])# which item in ith transaction, returns item index
            support[myall(ismember(Ck,t))] = support[myall(ismember(Ck,t))] + (1/N)  #if all the values in t are members, then it will return 1

        Lk = {'items': items[Ck[support >= minSup,:]],'index':Ck[support >= minSup,:]}

        if not np.isempty(support):
            mapS = {}
            for i in range(len(support)):
                mapS[str(Ck[i,:])] = support[i]

            S = np.concatenate((S, mapS), axis = 0)
        else:
            break

        if not np.isempty(Lk):
            L[k] = Lk
            k = k + 1
        else:
            break
    return([L,S,items])

def generateRules(L,S,minConf):
    rules = {'Antecedent': [],'Consequent' : [],'Conf':[],'Lift': [],'Sup' : []}
    for k in range(1,len(L)):
        freqSets = L[k]['index']; # k-itemsets
        for n in range(1,np.shape(freqSets)[0]):
            freqSet = freqSets[n,:] # one k-itemset
            H1 = np.transpose(freqSet) # get 1-item consequents
            if k > 2:
                rules = generate(freqSet,H1,S,rules,minConf);
            else:
                a,rules = prune(freqSet,H1,S,rules,minConf);
    return(rules)

def generate(freqSet,H,S,rules,minConf):
    # if frequent itemset is longer than consequent by more than 1
    (m,n) = np.shape(H)
    if len(freqSet) > (m+1):
        if m == 1:
            a,rules = prune(freqSet,H,S,rules,minConf) # prune 1-item consequents
            Hm1 = aprioriGen(H,m+1)  # use aprioriGen to generate longer consequents
            [Hm1,rules] = prune(freqSet,Hm1,S,rules,minConf) # prune consequents
            if not np.isempty(Hm1): # recursive if more consequents
                rules = generate(freqSet,Hm1,S,rules,minConf)
    return(rules)

def prune(freqSet,H,S,rules,minConf):
    prunedH = []
    for i in range(np.shape(H)[0]):
        conseq = H[i,:]     # get a consequent
        ante = np.setdiff(freqSet, conseq) # antecedent is the rest of items in the itemset
        freqSetSup =S[str(freqSet)]; # support for freqSet
        anteSup =S[str(ante)]  # support for antecedent
        conseqSup = S[str(conseq)]  # support for consequent
        conf = freqSetSup / anteSup  # confidence
        lift = freqSetSup/(anteSup*conseqSup) # and lift
        if conf >= minConf:
            prunedH = np.concatenate((prunedH, conseq),axis = 1)
            rule = {'Antecedent':ante,'Consequent':conseq,'Conf':conf,'Lift':lift,'Sup':freqSetSup}
            if np.isempty(rules):
                rules = rule
            else:
                rules = np.concatenate((rules, rule), axis = 1)
    return([prunedH,rules])

raw = pd.read_excel('product.xlsx','product')
data = raw.iloc[:,[1,3]]
dict = data.to_dict(orient = 'dict')
pid = data['product_id'].values
products = data['product_name'].values

with open('basket.dat') as f:
    content = f.readlines()
# you may also want to remove whitespace characters like `\n` at the end of each line
content = [x.strip() for x in content]

transactions = []
transnum = 0
while transnum < 1001:
    transactions.append(content[transnum].split(', '))
    transnum += 1

items = sorted(set([item for transaction in transactions for item in transaction ]))
f.close()

minSup = 0.002
L,S = generateFreqItemsets(transactions,minSup)

minConf = 0.01 # minimum confidence threshold 0.01
rules = generateRules(L,S,minConf);
print('Minimum Support        : {0:.3f}\n'.format(minSup))
print('Minimum Confidence     : {0:.3f}  \n'.format(minConf))
print('Number of Rules        : {0:%d}\n\n'.format(len(rules)))

for i in range(len(rules)):
    print('{0:s}  =>  {1:s}' .format(items[rules[i]['Antecedent']],items[rules[i]['Consequent']]))
    print('Conf: {0:.3f} Lift: {1:.3f} Sup: {2:.3f}'.format(rules[i]['Conf'],rules[i]['Lift'],rules[i]['Sup']))
