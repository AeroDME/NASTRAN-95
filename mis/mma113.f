      SUBROUTINE MMA113( ZI, ZC )
C
C     MMA113 PERFORMS THE MATRIX OPERATION IN COMPLEX SINGLE PRECISION
C       (+/-)A(T & NT) * B (+/-)C = D
C     
C     MMA113 USES METHOD 11 WHICH IS AS FOLLOWS:
C       1.  THIS IS FOR "A" NON-TRANSPOSED AND TRANSPOSED
C       2.  UNPACK AS MANY COLUMNS OF "A" INTO MEMORY AS POSSIBLE
C           LEAVING SPACE FOR ONE COLUMN OF "B" AND "D".
C       3.  INITIALIZE EACH COLUMN OF "D" WITH THE DATA FROM "C".
C       4.  UNPACK COLUMNS OF "C" MATRIX BUT USE GETSTR (MMARC1,2,3,4)
C           TO READ COLUMNS OF "B".
C
C     MEMORY FOR EACH COLUMN OF "A" IS AS FOLLOWS:
C         Z(1)   = FIRST NON-ZERO ROW NUMBER FOR COLUMN
C         Z(2)   = LAST NON-ZERO ROW NUMBER FOR COLUMN
C         Z(3-N) = VALUES OF NON-ZERO ROWS
C
      INTEGER           ZI(2)      ,T
      INTEGER           TYPEI      ,TYPEP    ,TYPEU ,SIGNAB, SIGNC
      INTEGER           RD         ,RDREW    ,WRT   ,WRTREW, CLSREW,CLS
      INTEGER           OFILE      ,FILEA    ,FILEB ,FILEC , FILED
      COMPLEX           ZC(2)
      INCLUDE           'MMACOM.COM'
      COMMON / NAMES  / RD         ,RDREW    ,WRT   ,WRTREW, CLSREW,CLS
      COMMON / TYPE   / IPRC(2)    ,NWORDS(4),IRC(4)
      COMMON / MPYADX / FILEA(7)   ,FILEB(7) ,FILEC(7)    
     1,                 FILED(7)   ,NZ       ,T     ,SIGNAB,SIGNC ,PREC1 
     2,                 SCRTCH     ,TIME
      COMMON / SYSTEM / KSYSTM(152)
      COMMON / UNPAKX / TYPEU      ,IUROW1   ,IUROWN, INCRU
      COMMON / PACKX  / TYPEI      ,TYPEP    ,IPROW1, IPROWN , INCRP
      EQUIVALENCE       (KSYSTM( 1),SYSBUF)  , (KSYSTM( 2),NOUT  ) 
      EQUIVALENCE       (FILEA(2)  ,NAC   )  , (FILEA(3)  ,NAR   )
     1,                 (FILEA(4)  ,NAFORM)  , (FILEA(5)  ,NATYPE)
     2,                 (FILEA(6)  ,NANZWD)  , (FILEA(7)  ,NADENS)
      EQUIVALENCE       (FILEB(2)  ,NBC   )  , (FILEB(3)  ,NBR   )
     1,                 (FILEB(4)  ,NBFORM)  , (FILEB(5)  ,NBTYPE)
     2,                 (FILEB(6)  ,NBNZWD)  , (FILEB(7)  ,NBDENS)
      EQUIVALENCE       (FILEC(2)  ,NCC   )  , (FILEC(3)  ,NCR   )
     1,                 (FILEC(4)  ,NCFORM)  , (FILEC(5)  ,NCTYPE)
     2,                 (FILEC(6)  ,NCNZWD)  , (FILEC(7)  ,NCDENS)
      EQUIVALENCE       (FILED(2)  ,NDC   )  , (FILED(3)  ,NDR   )
     1,                 (FILED(4)  ,NDFORM)  , (FILED(5)  ,NDTYPE)
     2,                 (FILED(6)  ,NDNZWD)  , (FILED(7)  ,NDDENS)
C
C
C   OPEN CORE ALLOCATION AS FOLLOWS:
C     Z( 1        ) = ARRAY FOR ONE COLUMN OF "B" MATRIX IN COMPACT FORM
C     Z( IDX      ) = ARRAY FOR ONE COLUMN OF "D" MATRIX
C     Z( IAX      ) = ARRAY FOR MULTIPLE COLUMNS OF "A" MATRIX
C        THROUGH
C     Z( LASMEM   )
C     Z( IBUF4    ) = BUFFER FOR "D" FILE
C     Z( IBUF3    ) = BUFFER FOR "C" FILE
C     Z( IBUF2    ) = BUFFER FOR "B" FILE 
C     Z( IBUF1    ) = BUFFER FOR "A" FILE
C     Z( NZ       ) = END OF OPEN CORE THAT IS AVAILABLE
C
      DO 60000 II = 1, NBC
C
C READ COLUMN FROM THE "B" MATRIX
C
      CALL MMARC3 ( ZI, ZC )
C
C NOW READ "C", OR SCRATCH FILE WITH INTERMEDIATE RESULTS.
C IF NO "C" FILE AND THIS IS THE FIRST PASS, INITIALIZE "D" COLUMN AS ZERO.
C
      IF ( IFILE .EQ. 0 ) GO TO 950            
      IUROW1 = 1
      IUROWN = NDR
      TYPEU  = NDTYPE 
      IF ( IPASS .EQ. 1 ) TYPEU = NDTYPE * SIGNC
      CALL UNPACK (*950, IFILE, ZC( IDX2+1 ) )
      GO TO 980
950   CONTINUE
      DO 970 J = 1, NDR
      ZC( IDX2+J ) = (0.0,0.0)
970   CONTINUE
980   CONTINUE
      NWDDNAR = NWDD*NAR
C
C CHECK IF COLUMN OF "B" IS NULL
C
      IROWB1 = ZI( 1 )
      IROWS  = ZI( 2 ) 
      IROWBN = IROWB1 + IROWS - 1
      INDX   = 1
C
C CHECK FOR NULL COLUMN FROM THE "B" MATRIX
C
      IF ( IROWB1 .EQ. 0 ) GO TO 50000
      IF ( T .NE. 0 ) GO TO 5000
C      
C "A" NON-TRANSPOSE CASE    ( A * B  +  C )      
C
C COMPLEX SINGLE PRECISION
3000  CONTINUE
      DO 3500 I = 1, NCOLPP
      IBROWI = IBROW+I
      INDXA  = IAX + 2*I + ( I-1 )*NWDDNAR 
      IROWA1 = ZI( INDXA-2 )
      IF ( IROWA1 .EQ. 0 ) GO TO 3500   
      IROWAN = ZI( INDXA-1 )
      INDXAV = ( ( INDXA+1 ) / 2 ) - IROWA1
3100  CONTINUE
      IF ( IBROWI .LT. IROWB1 ) GO TO 3500
      IF ( IBROWI .LE. IROWBN ) GO TO 3200
      INDX   = INDX + 2 + IROWS*NWDD
      IF ( INDX .GE. LASIND ) GO TO 50000
      IROWB1 = ZI( INDX )
      IROWS  = ZI( INDX+1 )
      IROWBN = IROWB1 + IROWS - 1
      GO TO 3100
3200  CONTINUE
      INDXV  = IBROWI - IROWB1 + ( INDX + 3 ) / 2
      IF ( ZC( INDXV ) .EQ. (0.0,0.0) ) GO TO 3500
      DO 3400 K = IROWA1, IROWAN
      ZC( IDX2+K ) = ZC( IDX2+K ) +  ZC( INDXAV+K ) * ZC( INDXV )
3400  CONTINUE
3500  CONTINUE
      GO TO 50000
C
C  TRANSPOSE CASE ( A(T) * B + C )
C
5000  CONTINUE      
      IDROW = IBROW
C COMPLEX SINGLE PRECISION
30000 CONTINUE
      DO 35000 I = 1, NCOLPP
      INDX   = 1
      INDXA  = IAX + 2*I + ( I-1 )*NWDDNAR 
      IROWA1 = ZI( INDXA-2 )
      IF ( IROWA1 .EQ. 0 ) GO TO 35000
      IROWAN = ZI( INDXA-1 )
      INDXAV = ( ( INDXA+1 ) / 2 ) - IROWA1    
31000 IF ( INDX .GE. LASIND ) GO TO 35000
      IROWB1 = ZI( INDX )
      IROWS  = ZI( INDX+1 )
      IROWBN = IROWB1 + IROWS - 1
      INDXV  = ( INDX+3 ) / 2
      INDX   = INDX + 2 + IROWS*NWDD
      IROW1  = MAX0( IROWA1, IROWB1 )
      IROWN  = MIN0( IROWAN, IROWBN )
      IF ( IROWN .LT. IROW1 ) GO TO 31000
      IDX2X  = IDX2 + IDROW
      INDXB  = INDXV - IROWB1
      DO 34000 K = IROW1, IROWN
      ZC( IDX2X+I ) = ZC( IDX2X+I ) +  ZC( INDXAV+K ) * ZC( INDXB+K )
34000 CONTINUE
      GO TO 31000
35000 CONTINUE
      GO TO 50000
C END OF PROCESSING THIS COLUMN FOR THIS PASS
50000 CONTINUE
C  NOW SAVE COLUMN 
      CALL PACK ( ZC( IDX2+1 ), OFILE, FILED )
60000 CONTINUE
      RETURN
      END

