      SUBROUTINE XDPH
C
C     DATA POOL HOUSEKEEPER (XDPH)
C
C     THIS SUBROUTINE SCANS THE DATA POOL DICT AND TO DETERMINE THE
C     NUMBER AND SIZE OF ANY FILES NO LONGER NEEDED.  IF A SUFFICIENT
C     QUANTITY IS NOT NEEDED, THE FILE IS RECOPIED WITH THE DEAD FILES
C     DELETED.
C
      IMPLICIT INTEGER (A-Z)
      EXTERNAL        RSHIFT,ANDF,ORF
      DIMENSION       NDPD(1),NDPH(2),FEQU(1),FNTU(1),FON(1),FORD(1),
     1                MINP(1),MLSN(1),MOUT(1),MSCR(1),SAL(1),SDBN(1),
     2                SNTU(1),SORD(1)
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25
      COMMON /XMSSG / UFM,UWM,UIM,SFM
      COMMON /SYSTEM/ IBUFSZ,OUTTAP,DUM(36),NBPC,NBPW,NCPW
      COMMON /XFIAT / FIAT(1),FMXLG,FCULG,FILE(1),FDBN(2),FMAT(1)
      COMMON /XFIST / FIST(2)
      COMMON /XPFIST/ NPFIST
      COMMON /XXFIAT/ EXFIAT
      COMMON /XDPL  / DPD(1),DMXLG,DCULG,DDBN(2),DFNU(1)
      COMMON /ZZZZZZ/ ENDSFA(1)
      COMMON /XSFA1 / MD(401),SOS(1501),COMM(20),XF1AT(1),FPUN(1),
     1                FCUM(1),FCUS(1),FKND(1)
      EQUIVALENCE     (DPD(1),DNAF),(FIAT(1),FUNLG),(FILE(1),FEQU(1)),
     1                (FILE(1),FORD(1)),(ENDSFA(1),NDPD(1))
      EQUIVALENCE     (MD(2),MLSN(1)),(MD(3),MINP(1)),(MD(4),MOUT(1)),
     1                (MD(5),MSCR(1)),
     2                (SOS(1),SLGN)  ,(SOS(2),SDBN(1)),(SOS(4),SAL(1)),
     3                (SOS(4),SNTU(1)),(SOS(4),SORD(1)),
     4                (COMM(1),ALMSK),(COMM(2),APNDMK),(COMM(3),CURSNO),
     5                (COMM(4),ENTN1),(COMM(5),ENTN2 ),(COMM(6),ENTN3 ),
     6                (COMM(7),ENTN4),(COMM(8),FLAG  ),(COMM(9),FNX   ),
     7                (COMM(10),LMSK),(COMM(11),LXMSK),
     8                (COMM(13),RMSK),(COMM(14),RXMSK),(COMM(15),S    ),
     9                (COMM(16),SCORNT),(COMM(17),TAPMSK),
     O                (COMM(18),THCRMK),(COMM(19),ZAP),
     1                (XF1AT(1),FNTU(1)),(XF1AT(1),FON(1))
C
      DATA    NCONST/ 100    /
      DATA    SCRN1 / 4HSCRA /, SCRN2 /4HTCH* /
      DATA    POOL  , NPOL   /  4HPOOL,4HNPOL /,  NDPH / 4HXDPH,4H    /
C
C
      FLAG = 0
  100 LMT3 = DCULG*ENTN4
      LMT  = (DCULG-1)*ENTN4 + 1
      NCNT = 0
      NGCNT= 0
      TRIAL= DNAF - 1
C
C     COUNT DEAD FILE SIZE, PUT SIZE IN NCNT
C
      DO 160 I = 1,LMT3,ENTN4
      IF (DDBN(I).NE.0 .OR. DDBN(I+1).NE.0) GO TO 159
      IF (DFNU(I) .GE. 0) GO TO 130
C
C     DEAD FILE IS EQUIV
C
      FLAG = -1
      KK = ANDF(RMSK,DFNU(I))
      DO 110 J = 1,LMT3,ENTN4
      IF (DFNU(J).GE.0 .OR. I.EQ.J) GO TO 110
      IF (KK .NE. ANDF(RMSK,DFNU(J))) GO TO 110
      IF (DDBN(J).NE.0 .OR. DDBN(J+1).NE.0) GO TO 145
      DFNU(J) = 0
  110 CONTINUE
  130 IF (KK  .EQ. TRIAL) GO TO 140
      IF (DFNU(I) .EQ. 0) GO TO 150
      NCNT = NCNT + RSHIFT(ANDF(LMSK,DFNU(I)),16)
      GO TO 150
  140 DNAF = TRIAL
  145 DFNU(I) = 0
  150 IF (I .NE. LMT) GO TO 160
      DCULG = DCULG - 1
      FLAG  = -1
      GO TO 100
C
C     COUNT GOOD STUFF ALSO
C
  159 NGCNT = NGCNT + RSHIFT(ANDF(LMSK,DFNU(I)),16)
  160 CONTINUE
C
C     CHECK FOR BREAKING OF EQUIV
C
      IF (FLAG .EQ. 0) GO TO 200
      DO 180 I = 1,LMT3,ENTN4
      IF (DFNU(I) .GE. 0) GO TO 180
      KK = ANDF(RMSK,DFNU(I))
      DO 170 J = 1,LMT3,ENTN4
      IF (DFNU(J).GE.0  .OR.  I.EQ.J) GO TO 170
      IF (KK .EQ. ANDF(RMSK,DFNU(J))) GO TO 180
  170 CONTINUE
      DFNU(I) = ANDF(ALMSK,DFNU(I))
  180 CONTINUE
C
C     IS NCNT OF SUFFICIENT SIZE TO WARRANT RECOPYING POOL
C
  200 CALL SSWTCH (3,IX)
      IF (IX .NE. 1) GO TO 211
      CALL PAGE1
      WRITE  (OUTTAP,201) NCNT
  201 FORMAT (21H0DPH DEAD FILE COUNT=,I6)
      WRITE  (OUTTAP,202)(DPD(IX),IX=1,3)
  202 FORMAT (16H0DPD BEFORE DPH ,3I4)
      II = DCULG*3 + 3
      DO 210 IX = 4,II,3
      IPRT1 = RSHIFT(DPD(IX+2),NBPW-1)
      IPRT2 = RSHIFT(ANDF(LXMSK,DPD(IX+2)),16)
      IPRT3 = ANDF(RXMSK,DPD(IX+2))
  203 FORMAT (1H ,2A4,3I6)
  210 WRITE  (OUTTAP,203) DPD(IX),DPD(IX+1),IPRT1,IPRT2,IPRT3
C
C     RECOPY POOL IF THERE ARE MORE THAN 500,000 WORD DEAD AND
C     THE GOOD STUFF IS TWICE AS BIG AS THE DEAD STUFF
C
  211 IF (NCNT.GT.NCONST .AND. NCNT.GT.2*NGCNT) GO TO 230
      IF (NCNT.GT.0 .AND. DCULG+5.GE.DMXLG) GO TO 230
      RETURN
C
C     RECOPY POOL, SWITCH POOL FILE POINTERS
C
  230 LMT2 = FUNLG*ENTN1
      KK   = ANDF(THCRMK,SCRN2)
      DO 250 I = 1,LMT2,ENTN1
      IF (FDBN(I).EQ.0 .AND. FDBN(I+1).EQ.0) GO TO 270
      IF (FDBN(I).EQ.SCRN1 .AND. ANDF(THCRMK,FDBN(I+1)).EQ.KK) GO TO 270
  250 CONTINUE
C
C     NO FILE AVAILABLE TO COPY ONTO, FORGET IT
C
      RETURN
C
C     SET-UP FOR A RECOPY
C
  270 ISAV = I
      CALL OPEN (*900,POOL,ENDSFA,0)
      FNX = 1
      FIST(2*NPFIST+4) = ISAV + 2
      FIST(2) = NPFIST + 1
      FIST(2*NPFIST+3) = NPOL
      CALL OPEN (*900,NPOL,ENDSFA(IBUFSZ+1),1)
      M = 2*IBUFSZ
      I = M + 1
      ISTART = I
      M = M + DCULG*3 + 3
      IWKBUF = KORSZ(ENDSFA) - M
      IF (IWKBUF .LT. 100) CALL MESAGE (-8,0,NDPH)
      M = M + 1
      NFILE = 1
      NCULG = 0
      DO 400 J = 1,LMT3,ENTN4
      IF (DDBN(J).EQ. 0 .AND. DDBN(J+1).EQ. 0) GO TO 400
      IF (DDBN(J).EQ.63 .AND. DDBN(J+1).EQ.63) GO TO 400
C
C     RECOPY DICTIONARY
C
      NDPD(I  ) = DDBN(J  )
      NDPD(I+1) = DDBN(J+1)
      NDPD(I+2) = ORF(ANDF(LXMSK,DFNU(J)),NFILE)
      IF (DFNU(J) .GE. 0) GO TO 290
      NDPD(I+2) = ORF(S,NDPD(I+2))
      KK = ANDF(RMSK,DFNU(J))
      DO 280 K  = 1,LMT3,ENTN4
      IF (DFNU(K).GE.0 .OR. J.EQ.K) GO TO 280
      IF (KK .NE. ANDF(RMSK,DFNU(K))) GO TO 280
      I = I + 3
      NCULG   = NCULG + 1
      NDPD(I) = DDBN(K)
      DDBN(K) = 63
      NDPD(I+1) = DDBN(K+1)
      DDBN(K+1) = 63
      NDPD(I+2) = NDPD(I-1)
  280 CONTINUE
  290 I = I + 3
      NCULG = NCULG + 1
C
C     RECOPY NECESSARY FILE
C
      FN = ANDF(RMSK,DFNU(J))
      CALL XFILPS (FN)
      CALL CPYFIL (POOL,NPOL,ENDSFA(M),IWKBUF,FLAG)
      CALL EOF (NPOL)
      NFILE = NFILE + 1
      FNX   = FN + 1
  400 CONTINUE
C
C     COPY TEMPORARY DPD INTO ACTUAL DPD
C
      I  = I - 1
      IX = 0
      DO 420 J = ISTART,I
      IX = IX + 1
  420 DDBN(IX) = NDPD(J)
      DNAF = NFILE
      DCULG= NCULG
      CALL CLOSE (POOL,1)
      CALL CLOSE (NPOL,1)
      FNX = 1
C
C     COPY POOL BACK TO POOL UNIT
C
      CALL OPEN (*900,NPOL,ENDSFA,0)
      CALL OPEN (*900,POOL,ENDSFA(IBUFSZ+1),1)
      NFILE = NFILE - 1
      DO 430 IX = 1,NFILE
      CALL CPYFIL (NPOL,POOL,ENDSFA(M),IWKBUF,FLAG)
      CALL EOF (POOL)
  430 CONTINUE
      CALL CLOSE (POOL,1)
      CALL CLOSE (NPOL,1)
C
C     THE FOLLOWING 3 LINES OF CODE WILL FREE DISK AREA ON SOME CONFIG.
C
      CALL OPEN  (*900,NPOL,ENDSFA,1)
      CALL WRITE (NPOL,NDPH,2,1)
      CALL CLOSE (NPOL,1)
      CALL SSWTCH (3,IX)
      IF (IX .NE. 1) RETURN
C
      WRITE  (OUTTAP,500) (DPD(IX),IX=1,3)
  500 FORMAT (15H0DPD AFTER DPH ,3I4)
      II = DCULG*3 + 3
      DO 510 IX = 4,II,3
      IPRT1 = RSHIFT(DPD(IX+2),NBPW-1)
      IPRT2 = RSHIFT(ANDF(LXMSK,DPD(IX+2)),16)
      IPRT3 = ANDF(RXMSK,DPD(IX+2))
  510 WRITE (OUTTAP,203) DPD(IX),DPD(IX+1),IPRT1,IPRT2,IPRT3
      RETURN
C
  900 WRITE  (OUTTAP,901) SFM
  901 FORMAT (A25,' 1041, OLD/NEW POOL COULD NOT BE OPENED.')
      CALL MESAGE (-37,0,NDPH)
      RETURN
      END
