<h2>Kmeans Up-Down Stock Movement Clustering</h2>

The given dataset contains the closing stock prices for S&P500 stocks
for a period of time. Their symbols show on the column headers. The
companies operate in 10 sectors as follows (from SP500Companies.xls):

  Health Care</br>
  Financials</br>
  Information Technology</br>
  Industrials</br>
  Utilities</br>
  Materials</br>
  Consumer Staples</br>
  Consumer Discretionary</br>
  Energy</br>
  Telecommunications Services</br>

In the preprocessing step, a new data set is created to indicate if the
stock prices increase compared with the previous day (1 or 0
corresponding to UP or DOWN). The matrix is then transposed such that
the up/down movement of a stock is in in a row. The model clusters
rows/points in a number of clusters. Here the number of clusters is
chosen to be 10 to see if the stocks (or most of) of companies operating
in the same sectors happen to be grouped together.

The km function implements the K-means algorithm. The outer loop loops
for a number of max iterations. The first inner loop assigns each
example/point to a cluster. The second loop re-computes the centroids of
the clusters.

Stocks in group 1 moving up together

ans =

AAPL


Stocks in group 2 moving up together

ans =

APC
APA
BHI
CAM
CF 
CHK
CVX
COP
DNR
DO 
ESV
EOG
XOM
FLR
FTI
FCX
HAL
HP 
HES
JOY
MRO
MPC
MUR
NBR
NOV
NFX
NE 
NBL
OXY
PXD
QEP
RDC
SLB
WMB


Stocks in group 3 moving up together

ans =

AMD 
AA  
ATI 
APOL
COG 
CLF 
CNX 
DVN 
EQT 
FSLR
NFLX
NEM 
BTU 
JCP 
RRC 
SWN 
SPLS
X   
WPX 


Stocks in group 4 moving up together

ans =

ABT  
AGN  
MO   
AMT  
AMGN 
ADM  
T    
BIIB 
HRB  
BMY  
BF.B 
CPB  
CELG 
CTL  
CERN 
CLX  
KO   
CCE  
CL   
CMCSA
CAG  
STZ  
COST 
COV  
CCI  
CVS  
DF   
DTV  
DPS  
EL   
FDO  
FIS  
GIS  
GILD 
HSY  
HRL  
IRM  
JNJ  
K    
KMB  
KR   
LLY  
LO   
MAT  
MKC  
MCD  
MCK  
MJN  
MRK  
TAP  
MDLZ 
MON  
PEP  
PFE  
PM   
PG   
DGX  
RAI  
SIAL 
SJM  
S    
SYY  
TGT  
TWC  
TSN  
VZ   
WMT  


Stocks in group 5 moving up together

ans =

ACT 
ALTR
ABC 
AMAT
BCR 
BAX 
BDX 
BBY 
BSX 
CAH 
CFN 
CSCO
CVH 
DVA 
EW  
EFX 
GRMN
HAS 
HSP 
IGT 
KLAC
KSS 
LIFE
M   
MDT 
MCHP
MU  
NSC 
PRGO
QCOM
PWR 
STX 
STJ 
SYK 
THC 
TSO 
TXN 
TRV 
URBN
VAR 
WAG 
WDC 
WIN 
ZMH 


Stocks in group 6 moving up together

ans =

AIV
AVB
BXP
EQR
HCP
HCN
KIM
PCL
PLD
PSA
SPG
VTR
VNO


Stocks in group 7 moving up together

ans =

ACE 
ADBE
AET 
APD 
ARG 
AIG 
AIZ 
AVY 
AVP 
BLL 
BAC 
BMS 
BLK 
BA  
CVC 
CAT 
CBG 
CBS 
CB  
CI  
CTAS
C   
CSC 
CSX 
CMI 
DRI 
DE  
DLPH
DOW 
ETFC
DD  
ECL 
ESRX
FISV
F   
FRX 
GME 
GD  
GNW 
GS  
GT  
HAR 
HIG 
HPQ 
HCBK
HUM 
IFF 
IP  
JCI 
JPM 
LLL 
LH  
LMT 
L   
LYB 
MET 
MS  
MOS 
MYL 
NWL 
NOC 
NUE 
OI  
PDCO
PSX 
PBI 
PNC 
PCP 
PGR 
PRU 
RTN 
RF  
RSG 
COL 
SWY 
SCHW
SEE 
LUV 
SRCL
UNH 
VLO 
VFC 
V   
WM  
WLP 
WFC 
XRX 
XL  
YUM 


Stocks in group 8 moving up together

ans =

MMM  
AFL  
ALL  
AXP  
AMP  
APH  
ADI  
AON  
ADP  
BBT  
BRK.B
BWA  
COF  
KMX  
CHRW 
CINF 
CME  
CMA  
GLW  
DHR  
XRAY 
DFS  
DOV  
DNB  
ETN  
EMR  
EXPD 
FDX  
FITB 
FHN  
FLIR 
FLS  
FMC  
BEN  
GCI  
GPC  
GWW  
HOG  
HRS  
HON  
HST  
HBAN 
ITW  
IR   
ICE  
IPG  
IVZ  
JBL  
JEC  
JDSU 
KEY  
LRCX 
LM   
LEG  
LUK  
LNC  
LLTC 
MTB  
MAR  
MMC  
MA   
MWV  
MCO  
MSI  
NDAQ 
NTAP 
NTRS 
OMC  
PCAR 
PLL  
PH   
PBCT 
PPG  
PFG  
RHI  
ROK  
ROP  
R    
SLM  
SNA  
SWK  
HOT  
STT  
STI  
SYMC 
TROW 
TEL  
TER  
TXT  
BK   
TMO  
TWX  
TMK  
TYC  
UNP  
UPS  
UTX  
UNM  
USB  
VMC  
DIS  
WAT  
WY   
WHR  
WYN  
XLNX 
XYL  
YHOO 
ZION 


Stocks in group 9 moving up together

ans =

AES
GAS
AEE
AEP
CNP
CMS
ED 
D  
DTE
DUK
EIX
ETR
EXC
FE 
TEG
NEE
NI 
NU 
NRG
OKE
POM
PCG
PNW
PPL
PEG
SCG
SRE
SO 
SE 
TE 
WEC
XEL


Stocks in group 10 moving up together

ans =

ANF  
ACN  
A    
AKAM 
ALXN 
AMZN 
ADSK 
AN   
AZO  
BBBY 
BMC  
BRCM 
CA   
CCL  
CMG  
CTXS 
COH  
CTSH 
DISCA
DG   
DLTR 
EMN  
EBAY 
EA   
EMC  
EXPE 
FFIV 
FAST 
FOSL 
FTR  
GPS  
GE   
HD   
DHI  
INTC 
IBM  
INTU 
ISRG 
JNPR 
KMI  
LEN  
LOW  
MAS  
MSFT 
MNST 
NKE  
JWN  
NVDA 
ORLY 
ORCL 
PAYX 
PNR  
PKI  
PETM 
PX   
PCLN 
PHM  
PVH  
RL   
RHT  
ROST 
CRM  
SNDK 
SNI  
SHW  
SBUX 
TDC  
TIF  
TJX  
TSS  
TRIP 
VRSN 
VIAB 
WU   
WFM  
WYNN 
