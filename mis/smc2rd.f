      SUBROUTINE SMC2RD ( ZI, ZD, ZIL, ZOL, NAR, LASROW, DTEMP
     &                  , I1, I2, I3  )
C
C ZIL    = INNER LOOP TERMS (SIZE = MAXNAC * (MAXNCOL+NEXTRA)
C ZOL    = OUTER LOOP TERMS (SIZE = (MAXNCOL+NEXTRA) * 2)
C NAR    = SAVE AREA FOR ACTIVE ROWS OF PREVIOUS COLUMN
C I1     = MAXIMUM NUMBER OF ACTIVE ROWS FOR THIS COLUMN
C I2     = NUMBER OF COLUMNS ALLOCATED FOR STORAGE OF INNER AND 
C          NUMBER OF ROWS ALLOCATED FOR OUTER LOOP
C I3     = MAXIMUM NUMBER OF WORDS FOR DEFINING THE ACTIVE ROWS FOR 
C          ANY COLUMN
C LASROW = LAST NON-ZERO ROW INDEX FOR A GIVEN COLUMN (SIZE = MAXNCOL
C          +NEXTRA)
C
      DOUBLE PRECISION  ZD(10)       ,DTEMP(I3)              
      DOUBLE PRECISION  ZIL( I1, I2 ), ZOL( I2, 2 ), ZOLTMP
      INTEGER           ZI(10), NAR( I3 )
      INTEGER           LASROW(I2)
      INCLUDE           'SMCOMX.COM'                    
C      
C GET ROW VALUES CORRESPONDING TO THE ACTIVE ROWS OF COLUMN K FOR
C EACH COLUMN KFRCOL THROUGH KLSCOL IN ORDER TO FILL INNER LOOP AND
C OUTER LOOP AREAS.
C
C
C BEGIN TO PROCESS EACH COLUMN
C FOR COLUMN K, GET OUTER LOOP TERMS
C    A(K,J) / A(J,J)
C       K = CURRENT PIVOTAL COLUMN
C       J = RANGES FROM FIRST COLUMN DATA NEEDED FOR COLUMN K TO K-1
C    (E.G.,
C         A(5,1)/A(1,1)
C         A(5,2)/A(2,2)
C         A(5,3)/A(3,3)
C         A(5,4)/A(4,4)
C ALSO, GET INNER LOOP TERMS
C    A(I,J)
C       K = CURRENT PIVOTAL COLUMN
C       I = RANGES FROM K TO LAST ACTIVE ROW OF COLUMN K
C       J = RANGES FROM FIRST COLUMN DATA NEEDED FOR COLUMN K TO K-1
C    (E.G.,
C         A(5,1) A(6,1)  .  A(N,1)
C         A(5,2) A(6,2)  .  A(N,2)
C         A(5,3) A(6,3)  .  A(N,3)
C         A(5,4) A(6,4)  .  A(N,4)
C         
C  LOOP 7000 WILL BE ON K
C  LOOP 6000 WILL BE ON J
C    
C      CALL AUDIT ( 'BEGIN   ', 1 )
      IC1     = 1
      IC2     = 2
      IILROW1 = 1
C      print *,' i1,i2,i3,maxncol,maxnac=',i1,i2,i3,maxncol,maxnac
C      CALL AUDIT ( 'DO7000  ', 1 )
      DO 7000 K = 1, NCOL
      KK      = MOD( K, I2 )
      IF ( KK .EQ. 0 ) KK = I2
      LASROW( KK ) = 0
C      PRINT *,' SMC2RD PROCESSING COLUMN K=',K
      KCOL    = K
      KDIR    = K*4 - 3
      KMIDX   = ZI( KDIR   )
C
C SEE IF DATA IS ON IN MEMORY OR ON THE SPILL FILE     
C      
      IF ( KMIDX .NE. 0 ) GO TO 500
C
C DATA IS ON THE SPILL FILE
C      
C      PRINT *,' CALLING SMCSPL FOR K=',K
      CALL SMCSPL ( KCOL, ZI )
      KMIDX  = ZI( KDIR )
500   CONTINUE
      KFRCOLP= KFRCOL
      KLSCOLP= KLSCOL
      KFRCOL = ZI( KDIR+1 )  
      KM2    = ZI( KMIDX+1)
      KRIDXN = KMIDX + 4 + KM2
      KLSCOL = K - 1
      KRIDX  = KMIDX+4
      KRIDXS = KRIDX
      KROW1  = ZI( KRIDX   )
      KROWN  = KROW1 + ZI( KRIDX+1 ) - 1
      KAROWS = 0
      DO 510 KK = 1, KM2, 2
      KAROWS = KAROWS + ZI( KRIDX+KK )
510   CONTINUE
C      PRINT *,' SMC2RD,K,KFRCOL,KLSCOL,KROW1,KROWN,KAROWS='
C      PRINT *,         K,KFRCOL,KLSCOL,KROW1,KROWN,KAROWS
C
C IF THE PREVIOUS COLUMN DID NOT NEED DATA FROM A COLUMN PRECEEDING IT,
C THEN MUST RELOAD THE INNER AND OUTER LOOP ARRAYS
C
      IF ( KLSCOLP .LT. KFRCOLP ) GO TO 1350
C     
C NOW MUST FIND THE ROW AND COLUMN NUMBER FOR THIS PIVOT COLUMN
C THAT IS NOT ALREADY IN THE INNER LOOP AND OUTER LOOP ARRAYS.
C FIRST CHECK THAT THE FIRST REQUIRED ROW IS STORED, IF NOT THEN WE MUST 
C BEGIN AS IF NOTHING STORED.  IF SOME OF THE REQUIRED ROWS ARE PRESENT,
C THEN FIND THE NEXT POSITION AND ROW NUMBER TO BE STORED IN THE INNER
C LOOP ARRAY AND THE NEXT POSITION AND COLUMN NUMBER TO BE STORED IN THE
C OUTER LOOP ARRAY.
C
C IF THE FIRST COLUMN IS LESS THAN FIRST COLUMN OF LAST PIVOT COLUMN
C THEN WE MUST LOAD THE INNER AND OUTER LOOPS FROM THE BEGINNING
C
      IF ( KFRCOL .LT. KFRCOLP ) GO TO 1350
      KR      = 1
      LROW1   = NAR( 1 ) 
      LROWN   = NAR( 1 ) + NAR( 2 ) - 1
C
C  LROW1 = FIRST ROW OF A STRING OF CONTIGUOUS ROWS OF LAST PIVOT 
C          COLUMN PROCESSED
C  LROWN = LAST ROW OF A STRING OF CONTIGUOUS ROWS OF LAST PIVOT COLUMN 
C          PROCESSED
C      
C FIND FIRST ROW IN INNER LOOP THAT MATCHES THE FIRST ROW REQUIRED
C FOR THIS COLUMN
C
C IF THERE IS NO MATCH FOR THE FIRST COLUMN, THEN GO TO 1350
C
1105  CONTINUE
      IF ( LROW1 .GT. KROW1 ) GO TO 1350
      IF ( KROW1 .LT. LROWN ) GO TO 1100
C
C NO OVERLAP WITH THIS STRING, GO AND GET NEXT STRING
C ADJUST 'ILLROW1' WHICH IS THE POINTER TO THE FIRST ROW IN THE INNER
C LOOP THAT CONTAINS THE VALUE OF ROW "KROW1" OF EACH COLUMN.
C
      INCR    = LROWN - LROW1 + 1
      IILROW1 = IILROW1 + INCR
      IF ( IILROW1 .GT. I1 ) IILROW1 = IILROW1 - I1
      KR      = KR + 2    
      LROW1   = NAR( KR )
      IF ( LROW1 .EQ. 0 ) GO TO 1350     
      LROWN   = LROW1 + NAR( KR+1 ) - 1
      GO TO 1105
1100  CONTINUE
C      
C THERE IS AN OVERLAP, SET KROWB, KROWSB, AND IILROW1 TO REFLECT
C THE PROPER ROW NUMBER IN THE INNER LOOP
C
      INCR    = KROW1 - LROW1
      KROWB   = KROW1 
      KROWSB  = KROWN - KROWB + 1 
      KRIDXS  = KRIDX
      IILROW1 = IILROW1 + INCR
      IF ( IILROW1 .GT. I1    ) IILROW1 = IILROW1 - I1
      LROW1   = KROW1
      IILROW  = IILROW1
1120  IF ( LROW1 .NE. KROW1 ) GO TO 1180
      IF ( LROWN .EQ. KROWN ) GO TO 1130
      IF ( LROWN .LT. KROWN ) GO TO 1140
      IF ( LROWN .GT. KROWN ) GO TO 1150
C
C THIS SET OF ROWS MATCHES, GO AND CHECK THE NEXT SET OF ROW NUMBERS
C
1130  CONTINUE
      INCR    = KROWN - KROWB + 1
      IILROW  = IILROW + INCR
      IF ( IILROW .GT. I1 ) IILROW = IILROW - I1
      KRIDX   = KRIDX + 2
      IF ( KRIDX .EQ. KRIDXN ) GO TO 1170
      KR      = KR + 2
      KROW1   = ZI( KRIDX )
      KROWB   = KROW1   
      KROWSB  = ZI( KRIDX+1 )  
      KROWN   = KROW1 + KROWSB -1
      KRIDXS  = KRIDX
      LROW1   = NAR( KR )
      LROWN   = LROW1 + NAR( KR+1 ) - 1
      IF ( LROW1 .EQ. 0 ) GO TO 1180 
      GO TO 1120
C
C LAST ROW NUMBERS DO NOT MATCH, KROWN GT LROWN
C
1140  CONTINUE
      INCR    = LROWN  - KROWB + 1
1145  KROWB   = KROWB  + INCR
      KROWSB  = KROWSB - INCR
      KRIDXS  = KRIDX
      IILROW  = IILROW + INCR
      IF ( IILROW .GT. I1 ) IILROW = IILROW - I1
      GO TO 1180
C
C LAST ROW NUMBERS DO NOT MATCH, KROWN LT LROWN
C
1150  CONTINUE
      INCR    = LROWN - LROW1 + 1
      GO TO 1145
C
C ROWS MATCH FOR INNER LOOP COLUMN VALUES, NOW DETERMINE THE COLUMN INDEX
C FOR THE NEXT COLUMN TO ADD TO THE INNER AND OUTER LOOP ARRAYS.
C SET IILROW TO FIRST ROW POSITION FOR NEW COLUMN DATA.
C
1170  CONTINUE
      KFRCOLG = KLSCOLP+1
      IILROW  = IILROW1
      GO TO 1400
C
C NOT ALL NEEDED ROW VALUES ARE PRESENT, MUST GET NEEDED ROWS
C FOR ALL COLUMNS REQUIRED FOR THIS PIVOT COLUMN
C
1180  CONTINUE
      KFRCOLG = KFRCOL
      GO TO 1400
C
C NO MATCH FOUND, WILL START LOADING THE INNER AND OUTER LOOP ARRAYS
C FROM THE BEGINNING
C
1350  IILROW1 = 1
      IILROW  = 1
      KROWB   = KROW1
      KROWSB  = KROWN - KROW1 + 1
      KFRCOLG = KFRCOL
1400  CONTINUE
      KRIDX   = KMIDX+4
      DO 1450 J = 1, KM2
      NAR( J ) = ZI( KRIDX+J-1 )
1450  CONTINUE
      NAR( KM2+1 ) = 0
      IILROWB = IILROW
C
C KFRCOL  = FIRST COLUMN NEEDED FOR PIVOT COLUMN "K"
C KLSCOL  = LAST COLUMN NEEDED FOR PIVOT COLUMN "K"
C KFRCOLG = FIRST COLUMN TO BE PLACED IN INNER/OUTER LOOP ARRAYS
C KFRCOLP = FIRST COLUMN OF LAST PIVOT COLUMN PROCESSED
C KLSCOLP = LAST COLUMN OF LAST PIVOT COLUMN PROCESSED
C
C      PRINT *,' KFRCOL,KLSCOL,KFRCOLG,KFRCOLP,KLSCOLP,KAROWS='
C      PRINT *,  KFRCOL,KLSCOL,KFRCOLG,KFRCOLP,KLSCOLP,KAROWS
C      PRINT *,' KROWB,KROWSB,IILROW1,IILROW,kridx='
C      PRINT *,  KROWB,KROWSB,IILROW1,IILROW,kridx
C
C KLSCOL WILL BE LESS THAN KFRCOLG FOR THE FIRST COLUMN AND FOR ANY
C COLUMN THAT DOES NOT NEED A PRECEEDING COLUMN OF DATA
C
      IF ( KLSCOL .LT. KFRCOLG ) GO TO 6000
C      CALL AUDIT ( 'DO3000  ', 1 )
      DO 3000 J = KFRCOLG, KLSCOL
C      PRINT *,' 3000,J,IILROW=',J,IILROW
      IILCOL = MOD ( J, I2 )  
      IF ( IILCOL .EQ. 0 ) IILCOL = I2
      JCOL   = J
      JDIR   = J*4 - 3
      JMIDX  = ZI( JDIR   )
C
C SEE IF COLUMN DATA IS IN MEMORY OR ON THE SPILL FILE
C      
      IF (  JMIDX .NE. 0 ) GO TO 1500
C
C DATA IS ON THE SPILL FILE
C      
      CALL SMCSPL ( JCOL, ZI )
      IF ( ZI( JDIR ) .EQ. 0 ) JMIDX = ISPILL
      IF ( ZI( JDIR ) .NE. 0 ) JMIDX = ZI( JDIR )
1500  CONTINUE
      JRIDX  = JMIDX + 4
      JM2    = ZI( JMIDX + 1 )
      JRIDXN = JRIDX + JM2
      JROWL  = ZI( JRIDX+JM2-2 ) + ZI( JRIDX+JM2-1 ) - 1
      JVIDX  = JRIDXN
C
C SAVE DIAGONAL TERM FOR COLUMN J ; (ALWAYS, THE FIRST TERM)
C      
      JVIDX  = JVIDX  / 2 + 1
C      PRINT *,' DIAGONAL TERM,JCOL=',JCOL,ZD(JVIDX)
      ZOL( IILCOL, IC2 )  = 1.0D0 / ZD( JVIDX )
C
C FOR EACH COLUMN J, GET REQUIRED ROWS; I.E, ACTIVE ROWS OF COLUMN K
C      
      IF ( J .GT. KLSCOLP ) GO TO 1530
C
C SET VARIABLES FOR ADDING ROW TERMS TO AN EXISTING COLUMN IN THE INNER LOOP
C
      KRIDX  = KRIDXS   
      KROW   = KROWB
      KROWS  = KROWSB
      IILROW = IILROWB           
C 
C SET LASROW TO ZERO IF THIS COLUMN IS BEING RELOADED INTO ZIL AND NOT
C BEING ADDED TO FROM SOME PREVIOUS COLUMN PROCESSING.
C
      IF ( IILROWB .EQ. IILROW1 ) LASROW( J ) = 0
      GO TO 1540
1530  CONTINUE
C
C  MUST RESET KRIDX, KROW AND KROWS FOR INSERTION OF NEW COLUMN IN INNER LOOP
C
      KRIDX  = KMIDX+4
      KROW   = ZI( KRIDX   )
      KROWS  = ZI( KRIDX+1 )
      IILROW = IILROW1
1540  CONTINUE
      KROWN  = KROW + KROWS - 1
C
C JROWL IS LAST ROW TERM IN COLUMN "J".  IF THIS IS BEFORE THE FIRST ROW 
C "KROW" TERM NEEDED, THEN NO MORE TERMS ARE NEEDED FROM COLUMN "J" AND
C "LASROW" WILL INDICATE THE LAST VALUE STORED FOR COLUMN "J".
C
      IF ( JROWL .LT. KROW ) GO TO 3000
2000  JROW   = ZI( JRIDX )
      JROWS  = ZI( JRIDX+1 )
      JROWN  = JROW + JROWS - 1
2010  CONTINUE      
      IF ( JROWN .LT. KROW  ) GO TO 2895
      IF ( JROW  .GT. KROWN ) GO TO 2400
      MISSIN = KROW - JROW
C
C CHECK TO SEE IF THERE ARE MISSING TERMS, I.E., TERMS CREATED DURING
C THE DECOMPOSITION.  IF THERE ARE MISSING TERMS, THEN SET THEIR VALUES
C TO BE INITIALLY ZERO.
C      
      IF ( MISSIN .GE. 0 ) GO TO 2050
      NZEROS = IABS( MISSIN )
C
C  STORE "NZEROS" NUMBER OF ZEROS FOR INNER LOOP TERMS
C
      IAVAIL = I1 - ( IILROW+NZEROS-1 )
      IF ( IAVAIL .LT. 0 ) GO TO 2022
      DO 2020 I = 1, NZEROS
      ZIL( IILROW+I-1, IILCOL ) = 0.0D0
2020  CONTINUE
      IILROW = IILROW + NZEROS
      GO TO 2028
2022  ILIM1 = I1 - IILROW + 1
      ILIM2 = NZEROS - ILIM1
      DO 2024 I = 1, ILIM1
      ZIL( IILROW+I-1, IILCOL ) = 0.0D0
2024  CONTINUE
      DO 2026 I = 1, ILIM2
      ZIL( I, IILCOL ) = 0.0D0
2026  CONTINUE
      IILROW = ILIM2 + 1
2028  CONTINUE
      KROW  = KROW  + NZEROS 
      KROWS = KROWS - NZEROS 
2050  CONTINUE
      IF ( MISSIN .LE. 0 ) GO TO 2070
      ISKIP  = KROW  - JROW
      JVIDX  = JVIDX + ISKIP*NVTERM
      JROW   = JROW  + ISKIP
2070  CONTINUE
      IROWN  = MIN0 ( KROWN, JROWN )
      NUM    = IROWN - KROW + 1                                    
C
C  MOVE INNER LOOP VALUES FROM IN-MEMORY LOCATION TO 
C  THE INNER LOOP AREA
C      
      NROWS = IROWN - KROW + 1
      IF ( NROWS .GT. ( I1 - IILROW + 1 ) ) GO TO 2120
      DO 2100 I = 1, NROWS
      ZIL( IILROW+I-1, IILCOL ) = ZD(JVIDX+I-1 )
2100  CONTINUE
      IILROW = IILROW + NROWS
      GO TO 2180
2120  ILIM1 = I1 - IILROW + 1
      ILIM2 = NROWS - ILIM1
      DO 2122 I = 1, ILIM1
      ZIL( IILROW+I-1, IILCOL ) = ZD( JVIDX+I-1 )
2122  CONTINUE
      JVTMP = JVIDX + ILIM1
      DO 2124 I = 1, ILIM2
      ZIL( I, IILCOL ) = ZD( JVTMP+I-1 )
2124  CONTINUE
      IILROW = ILIM2 + 1
2180  CONTINUE
      LASROW( IILCOL ) = IILROW 
C
C IF ALL OF THE ROWS ARE NON-ZERO, SET LASROW COUNTER TO IILROW1
C
      IF ( IILROW .EQ. IILROW1 ) LASROW( IILCOL ) = IILROW1
      JVIDX  = JVIDX + NROWS
      JROW   = JROW  + NROWS
      KROW   = IROWN + 1
      KROWS  = KROWN - IROWN 
C
C INCREMENT EITHER KROW OR JROW DEPENDING UPON WHETHER IROWN = JROWN
C OR IROWN = KROWN
C      
      IF ( IROWN .EQ. JROWN ) GO TO 2900
      GO TO 2530
2400  CONTINUE
C
C STORE ZEROS FOR CREATED TERMS AND INCREMENT TO THE NEXT SET OF
C OF ROWS FOR THIS PIVOTAL COLUMN. 
C
      IAVAIL = I1 - ( IILROW+KROWS-1 )
      IF ( IAVAIL .LT. 0 ) GO TO 2522
      DO 2510 I = 1, KROWS
      ZIL( IILROW+I-1, IILCOL ) = 0.0D0
2510  CONTINUE
      IILROW = IILROW + KROWS
      GO TO 2528
2522  CONTINUE
      ILIM2  = KROWS - ( I1 - IILROW + 1 )
      DO 2524 I = IILROW, I1
      ZIL( I, IILCOL ) = 0.0D0
2524  CONTINUE
      DO 2526 I = 1, ILIM2
      ZIL( I, IILCOL ) = 0.0D0
2526  CONTINUE
      IILROW = ILIM2 + 1
2528  CONTINUE
C      
C INCREMENT THE INDEX TO THE NEXT SET OF ROWS FOR COLUMN "K"
C
2530  KRIDX  = KRIDX + 2
C
C IF THERE ARE NO MORE ROWS FOR THIS COLUMN, THEN COLUMN IS COMPLETE
C
      IF ( KRIDX .GE. KRIDXN ) GO TO 3000
      KROW   = ZI( KRIDX )
      KROWS  = ZI( KRIDX+1)
      KROWN  = KROW + KROWS - 1
      GO TO 2010
2895  CONTINUE
C
C INCREMENT "JVIDX" TO POINT TO THE CORRESPONDING VALUE TERM FOR THE 
C NEXT ROW OF COLUMN "J"
C
      JVIDX  = JVIDX + ( JROWN - JROW + 1 )*NVTERM
C
C INCREMENT THE INDEX TO THE NEXT SET OF ROWS FOR COLUMN "J"
C
2900  JRIDX  = JRIDX + 2
      IF ( JRIDX .GE. JRIDXN ) GO TO 3000
      GO TO 2000
3000  CONTINUE
C      CALL AUDIT ( 'DO3000  ', 2 )
      IF ( K .EQ. 1 ) GO TO 6000
C
C COMPUTE THE TERMS FOR THE CURRENT COLUMN OF DATA
C 
C      do 100 k = 1,n
C         do 10  i = k,n
C         temp = 0.
C         do 5  l = 1,k-1
C            temp = temp + a(i,l)*a(k,l) / a(l,l)
C    5       continue
C         a(i,k) = a(i,k) - temp
C   10    continue
C
C  THE FOLLOWING LAST COMPUTATION TAKES PLACE IN SUBROUTINE SMCOUT.
C  THE RESULTS OF THE DIVISION ARE WRITTEN TO THE OUTPUT FILE BUT
C  THE RESULTS OF THE ABOVE (WITHOUT THE DIVISION BELOW) IS
C  MAINTAINED IN MEMORY FOR REMAINING COLUMN COMPUTATIONS.
C
C         do 11 j = k+1,n
C           a(k,j) = a(j,k) / a( k,k )
C   11      continue
C  100 continue
C
C   NROWS  = NUMBER OF ROWS STORED IN INNER LOOP
C   KCOL   = LAST COLUMN NUMBER STORED IN INNER LOOP
C   KFRCOL = FIRST COLUMN NUMBER STORED IN INNER LOOP
C
      NROWS = KAROWS
      KDIR  = ( KCOL-1 ) * 4 + 1
      KMIDX = ZI( KDIR )
      KRIDX = KMIDX + 4
      KM2   = ZI( KMIDX+1 )
      KVIDX = KRIDX + KM2
      KVIDX = ( KVIDX / 2 ) + 1
      ILIM1   = IILROW1 + NROWS - 1
      ILIM2   = 0
      IAVAIL  = I1 - ILIM1
      IF ( IAVAIL .GE. 0 ) GO TO 4010
      ILIM1   = I1
      ILIM2   = NROWS - ( I1 - IILROW1 + 1 )
4010  CONTINUE
      JLIM1   = MOD( KFRCOL, I2 )
      JLIM2   = MOD( KLSCOL, I2 )
      IF ( JLIM1 .EQ. 0 ) JLIM1 = I2
      IF ( JLIM2 .EQ. 0 ) JLIM2 = I2
      JLIM4   = 0
      IF ( KFRCOL .EQ. K ) GO TO 6000
      IF ( JLIM2 .GE. JLIM1 ) GO TO 4015
      JLIM4   = JLIM2
      JLIM2   = I2
4015  CONTINUE
C      PRINT *,' K,ILIM1,ILIM2,JLIM1,JLIM2,JLIM4,IILROW1,NROWS'
C      PRINT *,  K,ILIM1,ILIM2,JLIM1,JLIM2,JLIM4,IILROW1,NROWS
      IF ( K .EQ. 1 ) GO TO 4007
C
C COMPUTE THE OUTER LOOP TERM FOR THIS COLUMN J
C I.E.,   -A(K,J) / A(J,J) 
C  where K = current pivot column number; J = column being processed
C      
C     KAROWS = NUMBER OF ACTIVE ROWS FOR THE CURRENT PIVOTAL COLUMN
C     JCOL   = COLUMN NUMBER OF CURRENT PIVOTAL COLUMN
C     ZOL(KBC,IC1) = FIRST ACTIVE ROW ("IILROW1") TERM OF COLUMN "KBC"
C     ZOL(KBC,IC2) = DIAGONAL TERM FOR COLUMN "KBC"
C
C      CALL AUDIT ( 'COMP-ZOL', 1 )
      DO 4005 KBC = JLIM1, JLIM2           
      ZOL( KBC, IC1 ) = ZIL( IILROW1, KBC ) * ZOL( KBC, IC2 )
C      IF ( K.EQ.16) PRINT *,' KBC,IC1,ZOL-1=',KBC,IC1,ZOL(KBC,IC1)  
C      IF ( K.EQ.16) PRINT *,' ZIL,ZOL=',ZIL(IILROW1,KBC),ZOL(KBC,IC2)
C      IF ( K.EQ.16) PRINT *,' KBC,IC1,IILROW1,IC2=',KBC,IC1,IILROW1,IC2
4005  CONTINUE
      IF ( JLIM4 .EQ. 0 ) GO TO 4007
      DO 4006 KBC = 1, JLIM4
      ZOL( KBC, IC1 ) = ZIL( IILROW1, KBC ) * ZOL( KBC, IC2 )
C      IF ( K.EQ.16 ) PRINT *,' KBC,IC1,ZOL-2=',KBC,IC1,ZOL(KBC,IC1)  
C      IF ( K.EQ.16) PRINT *,' ZIL,ZOL=',ZIL(IILROW1,KBC),ZOL(KBC,IC2)
C      IF ( K.EQ.16) PRINT *,' KBC,IC1,IILROW1,IC2=',KBC,IC1,IILROW1,IC2
4006  CONTINUE
4007  CONTINUE
C      CALL AUDIT ( 'COMP-ZOL', 2 )
C      IF ( K .EQ.16 ) 
C     & CALL KBHELPRD( KFRCOL, KLSCOL, ZOL, ZIL, I1, I2, LASROW )     
C      CALL AUDIT ( 'COMP-ZIL', 1 )
      DO 4008 I = IILROW1, ILIM1
      DTEMP(I) = 0.0D0
4008  CONTINUE
C
C PROCESS COLUMNS JLIM1 THROUGH JLIM2
C      
      DO 4022 J = JLIM1, JLIM2
      LIMIT = ILIM1
      ITEST = LASROW( J )
      IF ( ITEST .EQ. 0 ) GO TO 4022
      IF ( ITEST .GT. IILROW1 ) LIMIT = ITEST - 1
C
C PROCESS ROWS IILROW1 THROUGH LIMIT FOR COLUMNS JLIM1 THROUGH JLIM2
C      
      ZOLTMP = ZOL( J, IC1 )
      CALL SMCCRD ( DTEMP(IILROW1), ZIL( IILROW1,J ), LIMIT-IILROW1+1
     &           , ZOLTMP ) 
C      DO 4020 I = IILROW1, LIMIT
C      DTEMP(I) = DTEMP(I) + ZIL( I, J ) * ZOLTMP 
C      IF ( K .EQ. 16 ) PRINT *,' 1-I,J,DTEMP,ZIL,ZOLTMP='
C      IF ( K .EQ. 16 ) PRINT *,    I,J,DTEMP(I),ZIL(I,J),ZOLTMP
C4020  CONTINUE
4022  CONTINUE
      IF ( JLIM4 .EQ. 0 ) GO TO 4030
C
C PROCESS ROWS IILROW1 THROUGH LIMIT FOR COLUMNS 1 THROUGH JLIM4
C      
      DO 4024 J = 1, JLIM4
      ITEST = LASROW( J )
      IF ( ITEST .EQ. 0 ) GO TO 4024
      LIMIT = ILIM1
      IF ( ITEST .GT. IILROW1 ) LIMIT = ITEST - 1
      ZOLTMP = ZOL( J, IC1 )
      CALL SMCCRD ( DTEMP(IILROW1), ZIL( IILROW1,J ), LIMIT-IILROW1+1
     &           , ZOLTMP ) 
C      DO 4023 I = IILROW1, LIMIT
C      DTEMP(I) = DTEMP(I) + ZIL( I, J ) * ZOLTMP
C      IF ( K .EQ.16 ) PRINT *,' 2-I,J,DTEMP,ZIL,ZOLTMP='
C      IF ( K .EQ.16 ) PRINT *,    I,J,DTEMP(I),ZIL(I,J),ZOLTMP
C4023  CONTINUE
4024  CONTINUE
4030  CONTINUE
      IF ( ILIM2 .EQ. 0 ) GO TO 4060
      DO 4032 I = 1, ILIM2
      DTEMP(I) = 0.0D0
4032  CONTINUE
C
C PROCESS COLUMNS JLIM1 THROUGH JLIM2
C      
      DO 4042 J = JLIM1, JLIM2
      ITEST = LASROW( J )
      IF ( ITEST .EQ. 0 .OR. ITEST .GT. IILROW1 ) GO TO 4042
      LIMIT = ILIM2
      IF ( ITEST .LE. ILIM2 ) LIMIT = ITEST - 1
C
C PROCESS ROWS 1 THROUGH LIMIT FOR COLUMNS JLIM1 THROUGH JLIM2
C      
      ZOLTMP = ZOL( J, IC1 )
      CALL SMCCRD ( DTEMP(1), ZIL( 1,J ), LIMIT, ZOLTMP )  
C      DO 4040 I = 1, LIMIT
C      DTEMP(I) = DTEMP(I) + ZIL( I, J ) * ZOLTMP              
C      IF ( K .EQ.16 ) PRINT *,' 3-I,J,DTEMP,ZIL,ZOLTMP='
C      IF ( K .EQ.16 ) PRINT *,    I,J,DTEMP(I),ZIL(I,J),ZOLTMP
C4040  CONTINUE
4042  CONTINUE
      IF ( JLIM4 .EQ. 0 ) GO TO 4046
C
C PROCESS ROWS 1 THROUGH LIMIT FOR COLUMNS 1 THROUGH JLIM4
C      
      DO 4044 J = 1, JLIM4
      ITEST = LASROW( J )
      IF ( ITEST .EQ. 0 .OR. ITEST .GT. IILROW1 ) GO TO 4044
      LIMIT = ILIM2
      IF ( ITEST .LE. ILIM2 ) LIMIT = ITEST - 1
      ZOLTMP = ZOL( J, IC1 )
      CALL SMCCRD ( DTEMP(1), ZIL( 1,J ), LIMIT, ZOLTMP )  
C      DO 4043 I = 1, LIMIT
C      DTEMP(I) = DTEMP(I) + ZIL( I, J ) * ZOLTMP
C      IF ( K .EQ.16 ) PRINT *,' 4-I,J,DTEMP,ZIL,ZOLTMP='
C      IF ( K .EQ.16 ) PRINT *,    I,J,DTEMP(I),ZIL(I,J),ZOLTMP
C4043  CONTINUE
4044  CONTINUE
4046  CONTINUE
4060  CONTINUE
C      CALL AUDIT ( 'COMP-ZIL', 2 )
C      
C UPDATE EACH ACTIVE ROW TERM FOR COLUMN "K" BY SUBTRACTING "DTEMP"
C
C      CALL AUDIT ( 'UPDATECO', 1 )
      DO 4047 I = IILROW1, ILIM1
      ZD( KVIDX ) = ZD( KVIDX ) - DTEMP(I)
      KVIDX = KVIDX + 1
4047  CONTINUE
      IF ( ILIM2 .EQ. 0 ) GO TO 4070
      DO 4048 I = 1, ILIM2
      ZD( KVIDX ) = ZD( KVIDX ) - DTEMP(I)
      KVIDX = KVIDX + 1
4048  CONTINUE
4070  CONTINUE
C      CALL AUDIT ( 'UPDATECO', 2 )
C
C CALL SMCOUT TO WRITE OUT THE COLUMN TO THE OUTPUT LOWER TRIANGULAR      
C MATRIX FILE
C      
6000  CONTINUE
C      CALL AUDIT ( 'SMCOUT  ',1 )
      CALL SMCOUT ( ZI, ZI, ZD, ZOL( 1,IC1 ), ZOL( 1,IC1 ) )
C      CALL AUDIT ( 'SMCOUT  ',2 )
7000  CONTINUE      
C      CALL AUDIT ( 'DO7000  ', 2 )
C      CALL AUDIT ( 'END     ', 2 )
      RETURN
      END

