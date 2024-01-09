<%!
import os
import numpy as np
%>

-- *------------------------------------------*
-- *                                          *
-- * base grid model with input parameters    *
-- *                                          *
-- *------------------------------------------*
RUNSPEC

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
 
 
MULTNUM
% for s in multnum:
  % if s == 1:
  1
  % else:
  2
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
 '../../../GlobalInclude/example_relperm.relperm' /

INCLUDE
 '../../../GlobalInclude/example_pvt.txt' /
/

REGIONS  ===============================================================

-- gen channels and make SATNUM regions

SATNUM
% for s in multnum:
  % if s == 1:
  1
  % else:
  2
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
