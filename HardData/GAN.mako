<%!
import os
import numpy as np
from scipy.stats import norm
import torch
import sys
sys.path.append('../../NonstationaryGANs/')
from models import generators

# load model achitectures

os.environ["CUDA_DEVICE_ORDER"] = "PCI_BUS_ID" 
os.environ["CUDA_VISIBLE_DEVICES"] = "0"
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")


netG = generators.Res_Generator(z_dim = 128, n_classes = 4,base_ch = 52
                                ,att = True,img_ch = 1,leak = 0
                                ,cond_method='conv1x1',SN=False).to(device)

# load checkpoint for artificial dataset (provided by TotalEnergies)

checkpoint = torch.load('../../NonstationaryGANs/trained_models/AR_model.pth',map_location=device)
_ = netG.load_state_dict(checkpoint['netG_state_dict'])
_=netG.eval()

%>

-- *------------------------------------------*
-- *                                          *
-- * base grid model with input parameters    *
-- *                                          *
-- *------------------------------------------*
RUNSPEC

NOSIM

TITLE
 Q5 SPOT MODEL

DIMENS
-- NDIVIX NDIVIY NDIVIZ
   64   64      1 /

-- Gradient option
-- AJGRADNT

-- Gradients readeable
-- UNCODHMD

--BLACKOIL
OIL
WATER
GAS
DISGAS

--IMPES

METRIC

TABDIMS
-- NTSFUN  NTPVT  NSSFUN  NPPVT  NTFIP  NRPVT  NTENDP
     3       1      35      30     5     30      1 /

EQLDIMS
-- NTEQUL  NDRXVD  NDPRVD
   1       5       100 /

WELLDIMS
-- NWMAXZ NCWMAX NGMAXZ MWGMAX 
    10     1     2      20 /

VFPPDIMS
-- MXMFLO MXMTHP MXMWFR MXMGFR MXMALQ NMMVFT
   10     10     10     10     1      1 /

VFPIDIMS
-- MXSFLO MXSTHP NMSVFT
   10     10     1 /

AQUDIMS
-- MXNAQN  MXNAQC NIFTBL NRIFTB NANAQU NCAMAX
   0       0      1      36     2       200/

START
 01 JAN 1967 /

NSTACK
 25 /


NOECHO

GRID
INIT

PERMX
 4096*500.0
/

COPY
 'PERMX'  'PERMY'  /
 'PERMX'  'PERMZ' /
/

DX
 4096*30 /
DY
 4096*30 /
DZ
 4096*30 /

TOPS
 4096*2355 /

PORO
 4096*0.20 /
 
 <%
scale_m = [np.exp(norm.cdf(elem)*(np.log(0.5) - np.log(0.01)) + np.log(0.01)) for elem in m]
M = torch.tensor(np.array(scale_m)).reshape((4,4)).unsqueeze(0).unsqueeze(0)
np.random.seed(member)
with torch.no_grad():
    img = netG(torch.tensor(np.random.randn(128),dtype=torch.float32).unsqueeze(0).to(device=device),M.to(device=device)).cpu().flatten()
multnum = img.numpy()
%>

MULTNUM
% for s in multnum:
  % if s == 1:
  1
  % elif s == -1:
  2
  % else:
  1
  % endif
% endfor
/

MULTIREG
-- PERMX   0.1    3   M  /
 PERMX   0.005  2   M  /
-- PERMY   0.1    3   M  /
 PERMY   0.005  2   M  /
-- PERMZ   0.1    3   M  /
 PERMZ   0.005  2   M  /
/

PROPS    ===============================================================

INCLUDE
 '../../GlobalInclude/example_relperm.relperm' /

INCLUDE
 '../../GlobalInclude/example_pvt.txt' /
/

REGIONS  ===============================================================

-- gen channels and make SATNUM regions

SATNUM
% for s in multnum:
  % if s == 1:
  1
  % elif s == -1:
  2
  % else:
  1
  % endif
% endfor
/



SOLUTION ===============================================================


--    DATUM  DATUM   OWC    OWC    GOC    GOC    RSVD   RVVD   SOLN
--    DEPTH  PRESS  DEPTH   PCOW  DEPTH   PCOG  TABLE  TABLE   METH
EQUIL
     2355.00 200.46 3000 0.00  2355.0 0.000     0     0      0  /

 
RPTSOL
'PRES' 'SWAT' /

RPTRST
 BASIC=2 /



SUMMARY ================================================================

RUNSUM

RPTONLY

WWIR
 'INJ1'
 'INJ2'
/

WOPR
 'PRO1'
 'PRO2'
/

WWPR
 'PRO1'
 'PRO2'
/


SCHEDULE =============================================================

RPTSCHED
 'NEWTON=2' /

RPTRST
 BASIC=2 FIP RPORV /

-- AJGWELLS
-- 'INJ-1' 'WWIR' /
-- 'PRO-1' 'WLPR' /
--/

-- AJGPARAM
-- 'PERMX' 'PORO' /

------------------- WELL SPECIFICATION DATA --------------------------
WELSPECS
'INJ1'  'G'   1  22  2357   WATER     1*   'STD'   3*  /
'INJ2'  'G'   1  44  2357   WATER     1*   'STD'   3*  /
'PRO1'  'G'   64  22  2357   OIL   1*   'STD'   3*  /
'PRO2'  'G'   64  44  2357   OIL   1*   'STD'   3*  /
/
COMPDAT
--                                        RADIUS    SKIN
'INJ1'    1  22   1   1   'OPEN'   2*  0.15  1*  5.0 /
'INJ2'    1  44   1   1   'OPEN'   2*  0.15  1*  5.0 /
'PRO1'    64  22   1   1   'OPEN'   2*  0.15  1*  5.0 /
'PRO2'    64  44   1   1   'OPEN'   2*  0.15  1*  5.0 /
/

WCONINJE
'INJ1' WATER 'OPEN' BHP 2* 275/
'INJ2' WATER 'OPEN' BHP 2* 275/
/

WCONPROD
 'PRO1' 'OPEN' BHP 5* 103 /
 'PRO2' 'OPEN' BHP 5* 103 /
 /
--------------------- PRODUCTION SCHEDULE ----------------------------



TSTEP
10*2500 /

END
