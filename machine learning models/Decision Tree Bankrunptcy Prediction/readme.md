In this model a bankruptcy data set is used. The following is the information of 
the attributes, from the income statements and balance sheets:

1)  Size

    a.  Sales

2)  Profit

    a.  ROCE: profit before tax=capital employed (%)

    b.  FFTL: funds flow (earnings before interest, tax &
        depreciation)=total liabilities

3)  Gearing

    a.  GEAR: (current liabilities + long-term debt)=total assets

    b.  CLTA: current liabilities=total assets

4)  Liquidity

    a.  CACL: current assets=current liabilities

    b.  QACL: (current assets – stock)=current liabilities

    c.  WCTA: (current assets – current liabilities)=total assets

5)  LAG: number of days between account year end and the date the annual
    report and accounts were filed at company registry.

6)  AGE: number of years the company has been operating since
    incorporation date.

7)  CHAUD: coded 1 if changed auditor in previous three years, 0
    otherwise

8)  BIG6: coded 1 if company auditor is a Big6 auditor, 0 otherwise

The target variable is FAIL, either = 1 or 0. You program a decision
tree model using information gain for splitting.

Node N is split into B branches/partitions (in the assignment B = 2
corresponding to binary values 0 and 1), n~k~ is number of records in
k^th^ partition N~k~, P~k~ is the fraction of training records sent to
node N~k~:

In which entropy at node N (where data is split):

In the main code, all the variables are binarized to 0/1 values. 70% of
data rows were used for training and the rest is for testing. The
maximal depth is set to 4, and can be changed (up to the number of
variables = 12). The root is at the depth of zero. At the leaf nodes,
where their depth is the maximal depth, instances are classified. The
printout of the trained tree is as follows (you can see the order of 4
variables for splitting after training is 3, 9, 2, and 1)

V3=0

V3=0 V9=0

V3=0 V9=0 V2=0

V3=0 V9=0 V2=0 V1=0 =&gt; classify y=0 distribution=\[3,0\]

V3=0 V9=0 V2=0 V1=1 =&gt; classify y=0 distribution=\[1,0\]

V3=0 V9=0 V2=1

V3=0 V9=0 V2=1 V11=0 =&gt; classify y=0 distribution=\[3,3\]

V3=0 V9=0 V2=1 V11=1 =&gt; classify y=1 distribution=\[0,2\]

V3=0 V9=1

V3=0 V9=1 V12=0

V3=0 V9=1 V12=0 V1=0 =&gt; classify y=1 distribution=\[0,9\]

V3=0 V9=1 V12=0 V1=1 =&gt; classify y=0 distribution=\[0,0\]

V3=0 V9=1 V12=1

V3=0 V9=1 V12=1 V11=0 =&gt; classify y=0 distribution=\[2,2\]

V3=0 V9=1 V12=1 V11=1 =&gt; classify y=1 distribution=\[0,1\]

V3=1

V3=1 V9=0

V3=1 V9=0 V1=0

V3=1 V9=0 V1=0 V2=0 =&gt; classify y=0 distribution=\[0,0\]

V3=1 V9=0 V1=0 V2=1 =&gt; classify y=0 distribution=\[6,0\]

V3=1 V9=0 V1=1

V3=1 V9=0 V1=1 V2=0 =&gt; classify y=0 distribution=\[0,0\]

V3=1 V9=0 V1=1 V2=1 =&gt; classify y=0 distribution=\[0,0\]

V3=1 V9=1

V3=1 V9=1 V7=0

V3=1 V9=1 V7=0 V1=0 =&gt; classify y=0 distribution=\[5,3\]

V3=1 V9=1 V7=0 V1=1 =&gt; classify y=0 distribution=\[1,0\]

V3=1 V9=1 V7=1

V3=1 V9=1 V7=1 V1=0 =&gt; classify y=1 distribution=\[0,1\]

V3=1 V9=1 V7=1 V1=1 =&gt; classify y=0 distribution=\[0,0\]

The text at the leaves, for example “classify y=0 distribution=\[3,0\]”
means classification is y=0 as the count for instances with y=0 is 3 vs
the count for instances with y=1 is 0.

Appendix:**

main.m: is the main code

infogain.m: computes the information gain

leafcat.m: computes the counts of instances at the leaf nodes

varpath.m: returns the list of variables from the current node to the
root in order to get a list of unused variables just below it to the
leaves for the next splitting

print.m: prints the tree using Depth First Search method

classify.m: classifies instances

buildtree.m: recursively builds the tree
