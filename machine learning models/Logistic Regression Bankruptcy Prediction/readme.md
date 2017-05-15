<h2>Logistic Regression based Bankruptcy Prediction</h2>

This model uses the bankruptcy data set from a paper. 
The following is the information of the attributes, from the
income statements and balance sheets:

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

The target variable is FAIL, either = 1 or 0. You program and model
using logistic regression.

In the main code, you can see instead of gradient descent, in MATLAB code, 
fminunc is used to search for the optimum (fminunc is for
unconstrained optimization, and fmincon is for constrained
optimization). Data is normalized. The first part is without
regularization and will give a reasonable accuracy (\~80%) with the
whole data set considered as the training data set. In the second part,
regularization is utilized. The function mapping maps variables to a
higher dimensional space. For example from

1.  Malcolm J. Beynon, Michael J. Peel, Variable precision rough set
    theory and data discretisation: an application to corporate failure
    prediction


