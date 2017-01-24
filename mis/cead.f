      SUBROUTINE CEAD
C
C     COMPLEX  EIGENVALUE EXTRACTION  MODULE
C
C     5  INPUT  FILES -  KDD,BDD,MDD,EED,CASECC
C     4  OUTPUT FILES -  PHID,LAMD,OCEIGS,PHIDL
C     12 SCRATCHES FILES
C     1  PARAMETER
C
      IMPLICIT INTEGER (A-Z)
      REAL            EPS
      DIMENSION       EIGC(2),ERROR(2),NAME(2),MCB(7),KZ(1)
      CHARACTER       UFM*23,UWM*25,UIM*29
      COMMON /XMSSG / UFM,UWM,UIM
      COMMON /CINVPX/ IK(7),IM(7),IB(7),ILAM(7),IPHI(7),
     1                IDMPFL,ISCR(11),NOREG,EPS,REG(7,10),PHIDLI
      COMMON /BLANK / NFOUND
      COMMON /SYSTEM/ SYSBUF,NOUT
      COMMON /ZZZZZZ/ IZ(1)
      EQUIVALENCE     (KZ(1),IZ(1))
      DATA    NAME  / 4HCEAD,4H    /
      DATA    HES   / 4HHESS/
      DATA    FEER  / 4HFEER/
      DATA    ERROR / 4HEED ,4HCEAD/
      DATA    KDD   , BDD,MDD,EED,CASECC /
     1        101   , 102,103,104,105    /
      DATA    PHID  , LAMD,OCEIGS,PHIDL  /
     1        201   , 202, 203,   204    /
      DATA    SCR1  , SCR2,SCR3,SCR4,SCR5,SCR6,SCR7,SCR8,SCR9 /
     1        301   , 302, 303 ,304 ,305 ,306 ,307 ,308 ,309  /
      DATA    SCR10 , SCR11,SCR12 /
     1        310   , 311,  312   /
      DATA    DET   , INV,EIGC(1),EIGC(2) /4HDET ,4HINV ,207,2/
      DATA    IZ2   , IZ6,IZ148   /2,6,148/
C
C     FIND SELECTED EIGC CARD IN CASECC
C
      IBUF  = KORSZ(IZ) - SYSBUF
      CALL OPEN (*1,CASECC,IZ(IBUF),0)
      CALL SKPREC (CASECC,1)
      CALL FREAD (CASECC,IZ,166,1)
      CALL CLOSE (CASECC,1)
      J = 148
      METHOD = IZ(J)
      SCR10  = 310
      GO TO 2
    1 METHOD = -1
    2 FILE = EED
      CALL PRELOC (*90,IZ(IBUF),EED)
      CALL LOCATE (*130,IZ(IBUF),EIGC(1),IFLAG)
   10 CALL READ (*110,*140,EED,IZ(1),10,0,IFLAG)
      IF (METHOD.EQ.IZ(1) .OR. METHOD.EQ.-1) GO TO 30
   20 CALL FREAD (EED,IZ,7,0)
      J = 6
      IF (IZ(J) .NE. -1) GO TO 20
      GO TO 10
C
C     FOUND DESIRED  EIGC CARD
C
   30 CALL CLOSE (EED,1)
      J = 2
      CAPP = IZ(J)
      IF (CAPP .EQ.  DET) GO TO 50
      IF (CAPP .EQ.  INV) GO TO 40
      IF (CAPP .EQ.  HES) GO TO 52
      IF (CAPP .EQ. FEER) GO TO 45
      GO TO 130
C
C     INVERSE POWER--
C
   40 IK(1) = KDD
      CALL CLOSE (EED,1)
      CALL RDTRL (IK)
      IM(1) = MDD
      CALL RDTRL (IM)
      IB(1) = BDD
      CALL RDTRL (IB)
      IF (IB(1) .LT. 0) IB(1) = 0
      IF (IB(6) .EQ. 0) IB(1) = 0
      ILAM(1)  = SCR8
      IPHI(1)  = SCR9
      IDMPFL   = OCEIGS
      ISCR( 1) = SCR1
      ISCR( 2) = SCR2
      ISCR( 3) = SCR3
      ISCR( 4) = SCR4
      ISCR( 5) = SCR5
      ISCR( 6) = SCR6
      ISCR( 7) = SCR7
      ISCR( 8) = LAMD
      ISCR( 9) = PHID
      ISCR(10) = SCR10
      ISCR(11) = SCR11
      PHIDLI   = SCR12
      EPS      = .0001
      CALL CINVPR (EED,METHOD,NFOUND)
      NVECT = NFOUND
      GO TO 60
C
C     FEER METHOD
C
   45 CONTINUE
      CALL CFEER (EED,METHOD,NFOUND)
      NVECT = NFOUND
      GO TO 60
C
C     DETERMINANT
C
   50 CALL CDETM (METHOD,EED,MDD,BDD,KDD,SCR8,SCR9,OCEIGS,NFOUND,SCR1,
     1            SCR2,SCR3,SCR4,SCR5,SCR6,SCR7,SCR10)
      NVECT = NFOUND
      GO TO 60
C
C     HESSENBURG METHOD
C
   52 CONTINUE
      MCB(1) = KDD
      CALL RDTRL (MCB)
      NROW   = MCB(2)
      MCB(1) = BDD
      CALL  RDTRL (MCB)
      IF (MCB(1) .GT. 0) NROW = NROW*2
      NZ = KORSZ(KZ)
C
C     IF INSUFFICIENT CORE EXISTS FOR HESSENBURG METHOD.  DEFAULT TO
C     INVERSE POWER.
C
      IF (6*NROW*NROW+NROW*8 .LE. NZ) GO TO 55
      WRITE  (NOUT,53) UIM
   53 FORMAT (A29,' 2365, INSUFFICIENT CORE EXISTS FOR HESSENBURG ',
     1       'METHOD.  CHANGING TO INVERSE POWER OR FEER.')
      GO TO 40
C
C     SUFFICIENT CORE.  PROCEED WITH HESSENBURG METHOD
C
   55 CONTINUE
      CALL HESS1 (KDD,MDD,SCR8,SCR9,OCEIGS,NFOUND,NVECT,BDD,SCR1,SCR2,
     1            SCR3,SCR4,SCR5,SCR6,SCR7,EED,METHOD)
      NFOUND = NVECT
C
C     LAMD ON SCR8, PHID ON SCR9
C
C     SORT EIGENVALUES AND PREPARE OUTPUT FILES
C
   60 IF (NFOUND .NE. 0) GO TO 70
      NFOUND = -1
      GO TO 80
   70 CALL CEAD1A (SCR8,SCR9,PHIDLI,LAMD,PHID,PHIDL,NFOUND,NVECT,CAPP)
   80 RETURN
C
C     ERROR MESAGES
C
   90 IP1 = -1
  100 CALL MESAGE (IP1,FILE,NAME)
  110 IP1 = -2
      GO TO 100
  130 IP1 = -7
      GO TO 100
  140 CALL MESAGE (-31,METHOD,ERROR(1))
      GO TO 140
      END
