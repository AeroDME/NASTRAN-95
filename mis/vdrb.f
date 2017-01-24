      SUBROUTINE VDRB (INFIL,OUTFL,IREQQ)
C
C     VDRB PROCESSES VECTORS IN THE ANALYSIS OR MODAL SET. IN
C     ACCORDANCE WITH OUTPUT REQUESTS IN THE CASE CONTROL DATA BLOCK,
C     THESE VECTORS ARE FORMATTED FOR INPUT TO OFP WHERE ACTUAL OUTPUT
C     WILL OCCUR.
C
      EXTERNAL        ANDF
      INTEGER         APP   ,FORM  ,SORT2 ,OUTPUT,Z     ,SYSBUF,DATE  ,
     1                TIME  ,UD    ,UE    ,TWO   ,QTYPE2,CEI   ,FRQ   ,
     2                TRN   ,OUTFL ,MODAL ,DIRECT,CASECC,EQDYN ,USETD ,
     3                INFIL ,OEIGS ,PP    ,BUF   ,BUF1  ,BUF2  ,BUF3  ,
     4                FILE  ,FLAG  ,SILD  ,CODE  ,GPTYPE,ANDF  ,BRANCH,
     5                SETNO ,FSETNO,WORD  ,RET   ,RETX  ,FORMAT,EOF   ,
     6                VDRCOM,SDR2  ,XSET0 ,XSETNO,DEST  ,AXIF  ,VDRREQ,
     7                OHARMS
      DIMENSION       MCB(7)    ,BUF(50)      ,BUFR(50)     ,MASKS(6) ,
     1                ZZ(1)     ,CEI(2)       ,FRQ(2)       ,TRN(2)   ,
     2                MODAL(2)  ,DIRECT(2)    ,NAM(2)       ,VDRCOM(1)
      COMMON /CONDAS/ CONSTS(5)
      COMMON /BLANK / APP(2),FORM(2),SORT2,OUTPUT,SDR2  ,IMODE
      COMMON /VDRCOM/ VDRCOM,IDISP ,IVEL  ,IACC  ,ISPCF ,ILOADS,ISTR  ,
     1                IELF  ,IADISP,IAVEL ,IAACC ,IPNL  ,ITTL  ,ILSYM ,
     2                IFROUT,IDLOAD,CASECC,EQDYN ,USETD ,INFILE,OEIGS ,
     3                PP    ,XYCDB ,PNL   ,OUTFLE,OPNL1 ,SCR1  ,SCR2  ,
     4                BUF1  ,BUF2  ,BUF3  ,NAM   ,BUF   ,MASKS ,CEI   ,
     5                FRQ   ,TRN   ,DIRECT,XSET0 ,VDRREQ,MODAL
      COMMON /ZZZZZZ/ Z(1)
      COMMON /SYSTEM/ SYSBUF,XX(13),DATE(3),TIME,DUM19(19),AXIF
      COMMON /NAMES / RD    ,RDREW ,WRT   ,WRTREW,CLSREW
      COMMON /BITPOS/ UM    ,UO    ,UR    ,USG   ,USB   ,UL    ,UA    ,
     1                UF    ,US    ,UN    ,UG    ,UE    ,UP    ,UNE   ,
     2                UFE   ,UD
      COMMON /TWO   / TWO(32)
      COMMON /UNPAKX/ QTYPE2,I2    ,J2    ,INCR2
      EQUIVALENCE     (CONSTS(2),TWOPI)   ,(CONSTS(3),RADDEG)  ,
     1                (BUF(1),BUFR(1))    ,(Z(1),ZZ(1))
      DATA    IGPF  , IESE,IREIG   /
     1        167   , 170, 4HREIG  /
C
C     PERFORM GENERAL INITIALIZATION.
C
      M8    = -8
      MSKUD = TWO(UD)
      MSKUE = TWO(UE)
      ILIST = 1
      I2    = 1
      INCR2 = 1
      IREQ  = IREQQ
      IF (FORM(1).NE.MODAL(1) .AND. FORM(1).NE.DIRECT(1)) GO TO 1432
C
C     READ TRAILER ON USETD. SET NO. OF EXTRA POINTS.
C     READ TRAILER ON INFIL. SET PARAMETERS.
C     IF MODAL PROBLEM, NO. OF MODES = NO. OF ROWS IN VECTOR - NO. XTRA
C     PTS.
C
      MCB(1) = USETD
      FILE   = USETD
      CALL RDTRL (MCB)
      IF (MCB(1) .NE. USETD) GO TO 2001
      NBREP  = MCB(3)
      MCB(1) = INFIL
      CALL RDTRL (MCB)
      IF (MCB(1) .NE. INFIL) GO TO 1431
      NVECTS = MCB(2)
      NROWS  = MCB(3)
      IF (FORM(1) .EQ. MODAL(1)) NBRMOD = IMODE + NROWS - NBREP - 1
      IF (MCB(5) .GT. 2) GO TO 1022
      IF (APP(1) .EQ. FRQ(1)) GO TO 1022
C
C     REAL VECTOR.
C
      KTYPE  = 1
      QTYPE2 = 1
      NWDS   = 8
      KTYPEX = 0
      GO TO 1030
C
C     COMPLEX VECTOR.
C
 1022 KTYPE  = 2
      QTYPE2 = 3
      NWDS   = 14
      KTYPEX = 1000
C
C     IF DIRECT PROBLEM OR MODAL PROBLEM WITH EXTRA POINTS,
C     READ 2ND TABLE OF EQDYN INTO CORE. THEN READ USETD INTO CORE.
C
 1030 IF (FORM(1).EQ.MODAL(1) .AND. NBREP.EQ.0) GO TO 1050
      FILE = EQDYN
      CALL GOPEN (EQDYN,Z(BUF1),0)
      CALL FWDREC (*2002,EQDYN)
      CALL READ (*2002,*1031,EQDYN,Z,BUF1,1,NEQD)
      CALL MESAGE (M8,0,NAM)
 1031 CALL CLOSE (EQDYN,CLSREW)
      IUSETD = NEQD + 1
      NCORE  = BUF1 - IUSETD
      FILE   = USETD
      CALL GOPEN (USETD,Z(BUF1),0)
      CALL READ (*2002,*1032,USETD,Z(IUSETD),NCORE,1,FLAG)
      CALL MESAGE (M8,0,NAM)
 1032 CALL CLOSE (USETD,CLSRRW)
      ILIST  = IUSETD
      NEQDYN = NEQD - 1
      KN     = NEQD/2
C
C     BRANCH ON PROBLEM TYPE.
C
      IF (FORM(1) .EQ. MODAL(1)) GO TO 1049
C
C     DIRECT - PROCESS EACH ENTRY IN EQDYN. IF POINT IS NOT IN ANALYSIS
C              SET, REPLACE SILD NO. WITH ZERO. OTHERWISE, REPLACE SILD
C              NO. WITH POSITION IN ANALYSIS SET (I.E. ROW INDEX IN
C              VECTOR) AND CODE INDICATING WHICH COMPONENTS OF POINT ARE
C              IN ANALYSIS SET.
C
      DO 1044 I = 1,NEQDYN,2
      SILD   = Z(I+1)/10
      GPTYPE = Z(I+1) - 10*SILD
      NUSETD = IUSETD + SILD - 1
      K = 0
      M = 1
      IF (GPTYPE .EQ. 1) M = 6
      J = NUSETD
      DO 1041 L = 1,M
      IF (ANDF(Z(J),MSKUD) .NE. 0) K = K + MASKS(L)
 1041 J = J + 1
      IF (K .EQ. 0) GO TO 1043
      L = 1
      M = NUSETD - 1
      IF (M .LT. IUSETD) GO TO 1045
      DO 1042 J = IUSETD,M
      IF (ANDF(Z(J),MSKUD) .NE. 0) L = L + 1
 1042 CONTINUE
 1045 Z(I+1) = GPTYPE + K + 256*L
      GO TO 1044
 1043 Z(I+1) = 0
 1044 CONTINUE
      GO TO 1050
C
C     MODAL - PROCESS EACH ENTRY IN EQDYN. IF POINT IS NOT AN EXTRA
C             POINT, REPLACE SILD NO. WITH ZERO. OTHERWISE, REPLACE SILD
C             NO. WITH POSITION IN MODAL SET (I.E. ROW INDEX IN VECTOR).
C
 1049 DO 1048 I = 1,NEQDYN,2
      SILD   = Z(I+1)/10
      GPTYPE = Z(I+1) - 10*SILD
      IF (GPTYPE .NE. 3) GO TO 1047
      NUSETD = IUSETD + SILD - 1
      IF (ANDF(Z(NUSETD),MSKUE) .EQ. 0) GO TO 1047
      K = NBRMOD - IMODE + 1
      DO 1046 J = IUSETD,NUSETD
      IF (ANDF(Z(J),MSKUE) .NE. 0) K = K + 1
 1046 CONTINUE
      Z(I+1) = 10*K + 3
      GO TO 1048
 1047 Z(I+1) = 0
 1048 CONTINUE
C
C     SET PARAMETER FOR APPROACH. THEN OPEN CASE CONTROL,
C     SKIP HEADER RECORD AND BRANCH ON APPROACH.
C
 1050 BRANCH = 0
      IF (APP(1) .EQ. CEI(1)) BRANCH = 1
      IF (APP(1) .EQ. FRQ(1)) BRANCH = 2
      IF (APP(1) .EQ. TRN(1)) BRANCH = 3
      IF (APP(1) .EQ. IREIG ) BRANCH = 4
      IF (BRANCH .EQ. 0) GO TO 1432
      CALL GOPEN (CASECC,Z(BUF1),0)
      GO TO (1060,1070,1070,1060), BRANCH
C
C     COMPLEX EIGENVALUES - READ LIST OF MODE NOS. AND VALUES INTO CORE.
C
 1060 FILE = OEIGS
      CALL GOPEN (OEIGS,Z(BUF2),0)
      CALL FWDREC (*2002,OEIGS)
      I = ILIST
      M = 8 - KTYPE
 1061 CALL READ (*2002,*1062,OEIGS,BUF,M,0,FLAG)
      Z(I  ) = BUF(1)
      Z(I+1) = BUF(3)
      Z(I+2) = BUF(4)
      I = I + 3
      GO TO 1061
 1062 CALL CLOSE (OEIGS,CLSREW)
      NLIST = I - 3
      ICC   = I
      GO TO 1100
C
C     FREQUENCY OR TRANSIENT RESPONSE - READ LIST INTO CORE.
C
 1070 FILE = PP
      CALL OPEN (*2001,PP,Z(BUF2),RDREW)
      I  = ILIST
      M  = 3
      IX = 1
      IF (APP(1) .EQ. FRQ(1)) IX = 2
 1071 CALL READ (*2002,*1072,PP,BUF,M,0,FLAG)
      Z(I  ) = BUF(M)
      Z(I+1) = 0
      I = I + IX
      M = 1
      GO TO 1071
 1072 CALL CLOSE (PP,CLSREW)
      NLIST = I - IX
      ICC   = I
C
C     OPEN OUTPUT FILE. WROTE HEADER RECORD.
C
 1100 FILE = OUTFL
      CALL OPEN (*1431,OUTFL,Z(BUF2),WRTREW)
      MCB(1) = OUTFL
      CALL FNAME (OUTFL,BUF)
      DO 1101 I = 1,3
 1101 BUF(I+2) = DATE(I)
      BUF(6) = TIME
      BUF(7) = 1
      CALL WRITE (OUTFL,BUF,7,1)
C
C     OPEN INPUT FILE. SKIP HEADER RECORD.
C
      FILE = INFIL
      CALL OPEN (*1430,INFIL,Z(BUF3),RDREW)
      CALL FWDREC (*2002,INFIL)
C
C     SET PARAMETERS TO KEEP CASE CONTROL AND VECTORS IN SYNCH.
C
      EOF    = 0
      JCOUNT = 0
      KCOUNT = 1
      JLIST  = ILIST
      KFRQ   = 0
      KWDS   = 0
      INCORE = 0
C
C     READ A RECORD IN CASE CONTROL.
C
 1130 CALL READ (*1400,*1131,CASECC,Z(ICC+1),BUF3-ICC,1,NCC)
      CALL MESAGE (M8,0,NAM)
 1131 IVEC  = ICC + NCC + 1
      IREQX = ICC + IDISP
      IF (Z(IREQX) .NE. 0) SDR2 = 1
      IREQX = ICC + IVEL
      IF (Z(IREQX) .NE. 0) SDR2 = 1
      IREQX = ICC + IACC
      IF (Z(IREQX) .NE. 0) SDR2 = 1
      IREQX = ICC + ISPCF
      IF (Z(IREQX) .NE. 0) SDR2 = 1
      IREQX = ICC + ILOADS
      IF (Z(IREQX) .NE. 0) SDR2 = 1
      IREQX = ICC + ISTR
      IF (Z(IREQX) .NE. 0) SDR2 = 1
      IREQX = ICC + IELF
      IF (Z(IREQX) .NE. 0) SDR2 = 1
      IREQX = ICC + IGPF
      IF (Z(IREQX) .NE. 0) SDR2 = 1
      IREQX = ICC + IESE
      IF (Z(IREQX) .NE. 0) SDR2 = 1
C
C     SET OUTPUT HARMONICS REQUEST WHICH IS USED IF FLUID ELEMENTS
C     ARE IN PROBLEM.
C
      OHARMS = Z(ICC+137)
      IF (OHARMS.LT.0 .AND. AXIF.NE.0) OHARMS = AXIF
C
C     IN THE ABOVE IF OHARMS = -1  THEN ALL IS IMPLIED. IF OHARMS = 0
C     THEN NONE IS IMPLIED AND IF OHARMS IS POSITIVE THEN THAT VALUE
C     MINUS ONE IS IMPLIED.
C
      IF (AXIF   .EQ. 0) GO TO 1140
      IF (OHARMS .EQ. 0) GO TO 1140
      OHARMS =   OHARMS - 1
      OHARMS = 2*OHARMS + 3
C
C     DETERMINE IF OUTPUT REQUEST IS PRESENT. IF NOT, TEST FOR RECORD
C     SKIP ON INFIL, THEN GO TO END OF REQUEST. IF SO, SET POINTERS
C     TO SET DEFINING REQUEST.
C
 1140 IREQX = ICC +IREQ
      SETNO = Z(IREQX  )
      DEST  = Z(IREQX+1)
      XSETNO = -1
      IF (SETNO) 1150,1141,1143
 1141 IF (APP(1) .NE. FRQ(1)) GO TO 1142
      IF (KCOUNT .NE.      1) GO TO 1350
      GO TO 1150
 1142 CALL FWDREC (*2002,INFIL)
      JCOUNT = JCOUNT + 1
      GO TO 1311
 1143 IX = ICC + ILSYM
      ISETNO = IX + Z(IX) + 1
 1144 ISET = ISETNO + 2
      NSET = Z(ISETNO+1) + ISET - 1
      IF (Z(ISETNO) .EQ. SETNO) GO TO 1145
      ISETNO = NSET + 1
      IF (ISETNO .LT. IVEC) GO TO 1144
      GO TO 1150
C
C     IF REQUIRED, LOCATE PRINT/PUNCH SUBSET.
C
 1145 IF (SETNO .LT. XSET0) GO TO 1150
      XSETNO = DEST/10
      DEST   = DEST - 10*XSETNO
      IF (XSETNO .EQ. 0) GO TO 1150
      IXSETN = IX + Z(IX) + 1
 1146 IXSET  = IXSETN + 2
      NXSET  = Z(IXSETN+1) + IXSET - 1
      IF (Z(IXSETN) .EQ. XSETNO) GO TO 1150
      IXSETN = NXSET + 1
      IF (IXSETN .LT. IVEC) GO TO 1146
      XSETNO = -1
      SETNO  = -1
C
C     UNPACK VECTOR INTO CORE (UNLESS VECTOR IS ALREADY IN CORE).
C
 1150 IF (INCORE .NE. 0) GO TO 1160
      IVECN = IVEC + KTYPE*NROWS - 1
      IF (IVECN .GE. BUF3) CALL MESAGE (M8,0,NAM)
      J2 = NROWS
      CALL UNPACK (*1151,INFIL,Z(IVEC))
      GO TO 1153
 1151 DO 1152 I = IVEC,IVECN
 1152 ZZ(I)  = 0.
 1153 JCOUNT = JCOUNT + 1
C
C     TEST FOR CONTINUATION.
C
 1160 IF (APP(1).EQ.FRQ(1) .AND. SETNO.EQ.0) GO TO 1350
C
C     PREPARE TO WRITE ID RECORD ON OUTPUT FILE.
C
      GO TO (1190,1200,1220,1190), BRANCH
C
C     COMPLEX EIGENVALUES.
C
 1190 BUF(2) = 1014
      BUF(5) = Z(JLIST  )
      BUF(6) = Z(JLIST+1)
      BUF(7) = Z(JLIST+2)
      BUF(8) = 0
      GO TO 1250
C
C     FREQUENCY RESPONSE.
C
 1200 IX = ICC + IDLOAD
      BUF(8) = Z(IX)
      BUF(6) = 0
      BUF(7) = 0
      IF (KFRQ .NE. 0) GO TO 1207
C
C     FIRST TIME FOR THIS LOAD VECTOR ONLY - MATCH LIST OF USER
C     REQUESTED FREQS WITH ACTUAL FREQS. MARK FOR OUTPUT EACH ACTUAL
C     FREQ WHICH IS CLOSEST TO USER REQUEST.
C
      KFRQ = 1
      IX   = ICC + IFROUT
      FSETNO = Z(IX)
      IF (FSETNO .LE. 0) GO TO 1202
      IX = ICC + ILSYM
      ISETNF = IX + Z(IX) + 1
 1201 ISETF  = ISETNF + 2
      NSETF  = Z(ISETNF+1) + ISETF - 1
      IF (Z(ISETNF) .EQ. FSETNO) GO TO 1204
      ISETNF = NSETF + 1
      IF (ISETNF .LT. IVEC) GO TO 1201
      FSETNO = -1
 1202 DO 1203 J = ILIST,NLIST,2
 1203 Z(J+1) = 1
      GO TO 1207
 1204 DO 1206 I = ISETF,NSETF
      K    = 0
      DIFF = 1.E+25
      BUFR(1) = ZZ(I)
      DO 1205 J = ILIST,NLIST,2
      IF (Z(J+1) .NE. 0) GO TO 1205
      DIFF1 = ABS(ZZ(J) - BUFR(1))
      IF (DIFF1 .GE. DIFF) GO TO 1205
      DIFF = DIFF1
      K = J
 1205 CONTINUE
      IF (K .NE. 0) Z(K+1) = 1
 1206 CONTINUE
C
C     DETERMINE IF CURRENT FREQ IS MARKED FOR OUTPUT.
C
 1207 IF (Z(JLIST+1) .EQ. 0) GO TO 1350
      BUF(5) = Z(JLIST)
      BUF(2) = KCOUNT + 1014
      GO TO 1250
C
C     TRANSIENT RESPONSE.
C
 1220 BUF(5) = Z(JLIST)
      BUF(2) = KCOUNT + 14
      IF (IREQ .EQ. IPNL) BUF(2) = 12
      IX     = ICC + IDLOAD
      BUF(8) = Z(IX)
      BUF(6) = 0
      BUF(7) = 0
C
C     WRITE ID RECORD ON OUTPUT FILE.
C
 1250 IX = BRANCH + 3
      IF (APP(1) .EQ. CEI(1)) IX = 9
      IF (APP(1) .EQ. IREIG ) IX = 2
      BUF(1) = DEST + 10*IX
      BUF(3) = 0
      BUF(4) = Z(ICC+1)
      IF (Z(IREQX+2) .LT. 0) SORT2 = +1
      FORMAT  = IABS(Z(IREQX+2))
      BUF(9)  = FORMAT
      BUF(10) = NWDS
      CALL WRITE (OUTFL,BUF,50,0)
      IX = ICC + ITTL
      CALL WRITE (OUTFL,Z(IX),96,1)
      OUTPUT = 1
      IF (Z(IREQX+2) .LT. 0) SORT2 = 1
C
C     BUILD DATA RECORD ON OUTPUT FILE.
C
      IF (FORM(1) .EQ. MODAL(1)) GO TO 1270
      IF (SETNO .NE. -1) GO TO 1263
C
C     DIRECT PROBLEM SET .EQ. -ALL- - OUTPUT POINTS IN ANALYSIS SET
C
      KX = 1
      ASSIGN 1262 TO RETX
 1261 WORD = Z(KX+1)
      IF (WORD .EQ. 0) GO TO RETX, (1262,1265,1268)
      J      = WORD/256
      BUF(2) = ANDF(WORD,3)
      CODE   = WORD - 256*J - BUF(2)
      BUF(1) = Z(KX)
      IF (BUF(2) .EQ. 1) GO TO 1300
      GO TO 1290
 1262 KX = KX + 2
      IF (KX .LE. NEQDYN) GO TO 1261
      GO TO 1310
C
C     DIRECT PROBLEM WITH SET .NE. -ALL- OUTPUT POINTS IN REQUESTED SET
C                                        WHICH ARE ALSO IN ANALYSIS SET.
C
 1263 JHARM = 0
 1267 I = ISET
      ASSIGN 1261 TO RET
 1264 BUF(1) = Z(I)
      IF (I   .EQ. NSET) GO TO 1266
      IF (Z(I+1) .GT. 0) GO TO 1266
      N = -Z(I+1)
      I = I + 1
      ASSIGN 1265 TO RETX
      GO TO 3000
 1265 BUF(1) = BUF(1) + 1
      IF (BUF(1) .LE. N) GO TO 3000
      GO TO 1268
 1266 ASSIGN 1268 TO RETX
      GO TO 3000
 1268 I = I + 1
      IF (I .LE. NSET) GO TO 1264
      IF (AXIF .EQ. 0) GO TO 1310
      JHARM = JHARM + 1
      IF (JHARM .LE. OHARMS) GO TO 1267
      GO TO 1310
C
C     MODAL PROBLEM WITH SET .EQ. -ALL- OUTPUT ALL MODAL POINTS. THEN
C                                       IF EXTRA POINTS, OUTPUT THEM.
C
 1270 IF (SETNO .NE. -1) GO TO 1275
      BUF(1) = IMODE
      BUF(2) = 4
      J = 1
      ASSIGN 1271 TO RETX
      GO TO 1290
 1271 BUF(1) = BUF(1) + 1
      J = BUF(1) - IMODE + 1
      IF (BUF(1) .LE. NBRMOD) GO TO 1290
      IF (NBREP .EQ. 0) GO TO 1310
      KX = 1
      ASSIGN 1273 TO RETX
      BUF(2) = 3
 1272 J = Z(KX+1)/10
      GPTYPE = Z(KX+1) - 10*J
      BUF(1) = Z(KX)
      IF (GPTYPE .EQ. 3) GO TO 1290
 1273 KX = KX + 2
      IF (KX .LE. NEQDYN) GO TO 1272
      GO TO 1310
C
C     MODAL PROBLEM WITH SET .NE. -ALL- ASSUME NUMBERS IN REQUESTED SET
C                                       WHICH ARE .LE. NO. OF MODES ARE
C                                       MODAL COORDINATES AND ANY OTHERS
C                                       ARE EXTRA POINTS.
C
 1275 JHARM = 0
 1274 I = ISET
 1276 BUF(1) = Z(I)
      IF (I   .EQ. NSET) GO TO 1281
      IF (Z(I+1) .GT. 0) GO TO 1281
      N = -Z(I+1)
      BUF(2) = 4
      I = I + 1
      ASSIGN 1278 TO RETX
 1277 IF (BUF(1).LT.IMODE .OR. BUF(1).GT.NBRMOD) GO TO 1279
      J = BUF(1) - IMODE + 1
      GO TO 1290
 1278 BUF(1) = BUF(1) + 1
      IF (BUF(1) .LE. N) GO TO 1277
      GO TO 1284
 1279 IF (NBREP .EQ. 0) GO TO 1284
      ASSIGN 1280 TO RET
      BUF(2) = 3
      GO TO 3000
 1280 J = Z(KX+1)/10
      GPTYPE = Z(KX+1) - 10*J
      IF (GPTYPE .EQ. 3) GO TO 1290
      GO TO 1278
 1281 ASSIGN 1284 TO RETX
      IF (BUF(1).LT.IMODE .OR. BUF(1).GT.NBRMOD) GO TO 1282
      ASSIGN 1284 TO RETX
      J = BUF(1) - IMODE + 1
      BUF(2) = 4
      GO TO 1290
 1282 IF (NBREP .EQ. 0) GO TO 1284
      ASSIGN 1283 TO RET
      GO TO 3000
 1283 J = Z(KX+1)/10
      BUF(2) = Z(KX+1) - 10*J
      IF (BUF(2) .EQ. 3) GO TO 1290
 1284 I = I + 1
      IF (I .LE. NSET) GO TO 1276
      IF (AXIF .EQ. 0) GO TO 1310
      JHARM = JHARM + 1
      IF (JHARM .LE. OHARMS) GO TO 1274
      GO TO 1310
C
C     SCALAR, EXTRA OR MODAL POINT.
C
 1290 J = IVEC + KTYPE*(J-1)
      BUFR(3) = ZZ(J)
      DO 1293 K = 4,NWDS
 1293 BUF(K) = 0
      IF (KTYPE .EQ. 1) GO TO 1309
C
C     COMPLEX SCALAR, EXTRA OR MODAL POINT.
C
      BUFR(9) = ZZ(J+1)
      IF (FORMAT .NE. 3) GO TO 1309
      REDNER = SQRT(BUFR(3)**2 + BUFR(9)**2)
      IF (REDNER) 12921,1309,12921
12921 BUFR(9) = ATAN2(BUFR(9),BUFR(3))*RADDEG
      IF (BUFR(9) .LT. -0.00005) BUFR(9) = BUFR(9) + 360.0
      BUFR(3) = REDNER
      GO TO 1309
C
C     GRID POINT.
C
 1300 DO 1301 K = 3,NWDS
 1301 BUF(K) = 1
      J = IVEC + KTYPE*(J-1)
      IF (KTYPE .EQ. 2) GO TO 1303
      DO 1302 K = 1,6
      IF (ANDF(CODE,MASKS(K)) .EQ. 0) GO TO 1302
      BUFR(K+2) = ZZ(J)
      J = J + 1
 1302 CONTINUE
      GO TO 1309
C
C     COMPLEX GRID POINT.
C
 1303 DO 1305 K = 1,6
      IF (ANDF(CODE,MASKS(K)) .EQ. 0) GO TO 1305
      BUFR(K+2) = ZZ(J  )
      BUFR(K+8) = ZZ(J+1)
      J = J + 2
      IF (FORMAT .NE. 3) GO TO 1305
      REDNER = SQRT(BUFR(K+2)**2 + BUFR(K+8)**2)
      IF (REDNER) 13031,1305,13031
13031 BUFR(K+8) = ATAN2(BUFR(K+8),BUFR(K+2))*RADDEG
      IF (BUFR(K+8) .LT. -0.00005) BUFR(K+8)= BUFR(K+8) + 360.0
      BUFR(K+2) = REDNER
 1305 CONTINUE
C
C     DETERMINE DESTINATION FOR ENTRY.
C
C
C     IF A FLUID PROBLEM THEN A CHECK IS NOW MADE TO SEE IF THIS
C     HARMONIC IS TO BE OUTPUT
C
 1309 IF (AXIF) 1315,1314,1315
 1315 IF (BUF(1) .LT. 500000) GO TO 1314
      ITEMP = BUF(1) - MOD(BUF(1),500000)
      ITEMP = ITEMP/500000
      IF (ITEMP .GE. OHARMS) GO TO 1310
 1314 ID = BUF(1)
      BUF(1) = 10*ID + DEST
      IF (XSETNO) 1304,1306,1307
 1306 BUF(1) = 10*ID
      GO TO 1304
 1307 IX = IXSET
 1313 IF (IX  .EQ. NXSET) GO TO 1308
      IF (Z(IX+1) .GT. 0) GO TO 1308
      IF (ID.GE.Z(IX) .AND. ID.LE.-Z(IX+1)) GO TO 1304
      IX = IX + 2
      GO TO 1312
 1308 IF (ID .EQ. Z(IX)) GO TO 1304
      IX = IX + 1
 1312 IF (IX .LE. NXSET) GO TO 1313
      GO TO 1306
C
C     WRITE ENTRY ON OUTPUT FILE.
C
 1304 CALL WRITE (OUTFL,BUF,NWDS,0)
      KWDS = KWDS + NWDS
      BUF(1) = ID
      GO TO RETX, (1262,1265,1268,1271,1273,1278,1284)
C
C     CONCLUDE PROCESSING OF THIS VECTOR.
C
 1310 CALL WRITE (OUTFL,0,0,1)
 1311 GO TO (1340,1350,1360,1340), BRANCH
C
C     COMPLEX EIGENVALUES.
C
 1340 JLIST = JLIST + 3
 1341 IF (JCOUNT .GE. NVECTS) GO TO 1410
      IF (EOF .EQ. 0) GO TO 1130
      GO TO 1140
C
C     FREQUENCY RESPONSE.
C
 1350 IF (KCOUNT .EQ. 3) GO TO 1356
      N = IVECN - 1
      OMEGA = TWOPI*ZZ(JLIST)
      DO 1351 I = IVEC,N,2
      BUFR(1) = -OMEGA*ZZ(I+1)
      ZZ(I+1) =  OMEGA*ZZ(I  )
 1351 ZZ(I  ) =  BUFR(1)
      IF (KCOUNT .EQ. 2) GO TO 1352
      IREQ = IAVEL
      GO TO 1353
 1352 IREQ = IAACC
 1353 KCOUNT = KCOUNT + 1
      INCORE = 1
      GO TO 1140
 1356 KCOUNT = 1
      INCORE = 0
      IREQ   = IADISP
      JLIST  = JLIST + 2
      IF (JLIST.LE.NLIST .AND. JCOUNT.LT.NVECTS) GO TO 1140
      KFRQ  = 0
      JLIST = ILIST
      DO 1357 I = ILIST,NLIST,2
 1357 Z(I+1) = 0
      IF (JCOUNT .LT. NVECTS) GO TO 1130
      GO TO 1410
C
C     TRANSIENT RESPONSE.
C
 1360 IF (IREQ .EQ. IPNL) GO TO 1364
      IF (KCOUNT-2) 1361,1362,1363
 1361 IREQ   = IAVEL
      KCOUNT = 2
      GO TO 1140
 1362 IREQ   = IAACC
      KCOUNT = 3
      GO TO 1140
 1363 IREQ   = IADISP
      KCOUNT = 1
 1364 JLIST  = JLIST + 1
      IF (JLIST.LE.NLIST .AND. JCOUNT.LT.NVECTS) GO TO 1140
      GO TO 1410
C
C     HERE WHEN EOF ENCOUNTERED ON CASE CONTROL.
C
 1400 EOF = 1
      GO TO (1341,1410,1410,1341), BRANCH
C
C     CONCLUDE PROCESSING.
C
 1410 CALL CLOSE (CASECC,CLSREW)
      CALL CLOSE (INFIL, CLSREW)
      CALL CLOSE (OUTFL, CLSREW)
      MCB(1) = OUTFL
      MCB(2) = KWDS/65536
      MCB(3) = KWDS - 65536*MCB(2)
      MCB(4) = 0
      MCB(5) = 0
      MCB(6) = 0
      MCB(7) = 0
      CALL WRTTRL (MCB)
      RETURN
C
C     HERE IF ABNORMAL CONDITION.
C
 1430 CALL CLOSE (OUTFL,CLSREW)
 1431 CALL MESAGE (30,78,0)
 1432 RETURN
C
C     FATAL FILE ERRORS
C
 2001 N = -1
      GO TO 2005
 2002 N = -2
 2005 CALL MESAGE (N,FILE,NAM)
      RETURN
C
C     BINARY SEARCH ROUTINE
C
 3000 KLO = 1
      KHI = KN
      IF (AXIF) 3011,3001,3011
 3011 BUF(1) = JHARM*500000 + BUF(1)
 3001 K  = (KLO+KHI+1)/2
 3002 KX = 2*K - 1
      IF (BUF(1)-Z(KX)) 3003,3009,3004
 3003 KHI = K
      GO TO 3005
 3004 KLO = K
 3005 IF (KHI-KLO-1) 3010,3006,3001
 3006 IF (K .EQ. KLO) GO TO 3007
      K = KLO
      GO TO 3008
 3007 K = KHI
 3008 KLO = KHI
      GO TO 3002
 3009 GO TO RET,  (1261,1280,1283)
 3010 GO TO RETX, (1262,1265,1268,1273,1278,1284)
      END
