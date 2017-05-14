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

MMM 
ACN 
ADBE
A   
APD 
ARG 
AKAM
ALTR
APH 
ADI 
AMAT
ADSK
AVY 
BLL 
BWA 
BRCM
CA  
CTAS
CSCO
CTXS
CTSH
CSC 
GLW 
CMI 
DHR 
DLPH
XRAY
DOV 
DOW 
DNB 
DD  
EMN 
ETN 
ECL 
EMC 
EMR 
FFIV
FISV
FLIR
FLS 
FLR 
FMC 
GD  
GE  
HAR 
HRS 
HON 
HSP 
HST 
ITW 
IR  
INTC
IPG 
JBL 
JEC 
JDSU
JCI 
JNPR
KLAC
LRCX
LLTC
LYB 
MAR 
MWV 
MCHP
MU  
MSFT
MOS 
MSI 
NTAP
NOC 
OMC 
ORCL
OI  
PCAR
PLL 
PH  
PNR 
PKI 
PPG 
PX  
PCP 
QCOM
PWR 
RTN 
RHT 
RHI 
ROK 
COL 
R   
SIAL
SNA 
SWK 
HOT 
SYMC
TEL 
TDC 
TER 
TXN 
TXT 
TMO 
TYC 
UTX 
DIS 
WAT 
WDC 
XRX 
XLNX


Stocks in group 2 moving up together

ans =

AA 
ATI
APC
APA
BHI
COG
CAM
CHK
CVX
CLF
COP
CNX
DNR
DVN
DO 
ESV
EOG
EQT
XOM
FTI
FCX
HAL
HP 
HES
MRO
MUR
NBR
NOV
NFX
NEM
NE 
NBL
NUE
OXY
BTU
PXD
QEP
RRC
RDC
SLB
SWN
WMB
X  
WPX


Stocks in group 3 moving up together

ans =

ANF 
AMD 
APOL
AAPL
CAT 
CBG 
CF  
CHRW
CSX 
DE  
EA  
EXPD
FDX 
FSLR
GME 
GT  
HOG 
HPQ 
JOY 
LUK 
MPC 
MYL 
NFLX
NSC 
NVDA
JCP 
PSX 
CRM 
SNDK
STX 
SEE 
SPLS
TSO 
UNP 
VLO 
WYNN
XYL 
YHOO


Stocks in group 4 moving up together

ans =

CVH 
ESRX
MRK 


Stocks in group 5 moving up together

ans =

AET 
ABC 
ADM 
BF.B
CPB 
CAH 
CTL 
CI  
CLX 
KO  
CCE 
CL  
CAG 
STZ 
CVS 
DF  
DPS 
FTR 
GIS 
HSY 
HRL 
HUM 
JNJ 
K   
KMB 
KR  
LLY 
MKC 
MCK 
TAP 
MDLZ
PEP 
PRGO
PFE 
PG  
DGX 
SWY 
SJM 
SYY 
TSN 
UNH 
VZ  
WMT 
WAG 
WLP 


Stocks in group 6 moving up together

ans =

ACE  
AFL  
ALL  
AXP  
AIG  
AMP  
AON  
AIZ  
AVP  
BAC  
BBT  
BRK.B
BLK  
COF  
KMX  
CB   
CINF 
C    
CME  
CMA  
DFS  
ETFC 
FITB 
FHN  
F    
BEN  
GCI  
GNW  
GS   
HIG  
HCBK 
HBAN 
ICE  
IGT  
IVZ  
JPM  
KEY  
LLL  
LM   
LNC  
L    
MTB  
MMC  
MET  
MS   
NDAQ 
NTRS 
PBCT 
PBI  
PNC  
PFG  
PGR  
PRU  
RF   
ROP  
SCHW 
SLM  
STT  
STI  
TROW 
BK   
TMK  
TRV  
UNM  
USB  
V    
VMC  
WFC  
XL   
ZION 


Stocks in group 7 moving up together

ans =

AES 
MO  
AMT 
T   
AN  
CCI 
DG  
FRX 
DHI 
KMI 
LEN 
LO  
MAS 
NRG 
OKE 
PM  
PHM 
RAI 
SHW 
SE  
SRCL
TWC 
TJX 
WIN 


Stocks in group 8 moving up together

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


Stocks in group 9 moving up together

ans =

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
POM
PCG
PNW
PPL
PEG
SCG
SRE
SO 
TE 
WEC
XEL


Stocks in group 10 moving up together

ans =

ABT  
ACT  
ALXN 
AGN  
AMZN 
AMGN 
ADP  
AZO  
BCR  
BAX  
BDX  
BBBY 
BMS  
BBY  
BIIB 
HRB  
BMC  
BA   
BSX  
BMY  
CVC  
CFN  
CCL  
CBS  
CELG 
CERN 
CMG  
COH  
CMCSA
COST 
COV  
DRI  
DVA  
DTV  
DISCA
DLTR 
EBAY 
EW   
EFX  
EL   
EXPE 
FDO  
FAST 
FIS  
FOSL 
GPS  
GRMN 
GPC  
GILD 
GWW  
HAS  
HD   
IBM  
IFF  
IP   
INTU 
ISRG 
IRM  
KSS  
LH   
LEG  
LIFE 
LMT  
LOW  
M    
MA   
MAT  
MCD  
MJN  
MDT  
MON  
MNST 
MCO  
NWL  
NKE  
JWN  
ORLY 
PDCO 
PAYX 
PETM 
PCLN 
PVH  
RL   
RSG  
ROST 
SNI  
LUV  
S    
STJ  
SBUX 
SYK  
TGT  
THC  
TIF  
TWX  
TSS  
TRIP 
UPS  
URBN 
VAR  
VRSN 
VFC  
VIAB 
WM   
WU   
WY   
WHR  
WFM  
WYN  
YUM  
ZMH  
