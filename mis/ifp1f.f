      SUBROUTINE IFP1F (*,IWORD,II)
C
C     FINDS FIRST 4 NON-BLANK CHARACTERS
C
      DIMENSION       CORE(1),COREY(401)
      COMMON /ZZZZZZ/ COREX(1)
      COMMON /IFP1A / SKIP1(4),NCPW4,SKIP2(4),IZZZBB,SKIP3(3),IBEN
      EQUIVALENCE     (COREX(1),COREY(1)), (CORE(1),COREY(401))
C
      IWORD = IZZZBB
      L  = 1
      II = 0
      DO 10 I = 1,18
      DO 10 J = 1,NCPW4
      K = KHRFN1(IZZZBB,1,CORE(I),J)
      IF (K .EQ. IBEN) GO TO 10
      IF (II .EQ. 0) II = I
      IWORD = KHRFN1(IWORD,L,K,1)
      L = L + 1
      IF (L .GT. NCPW4) GO TO 20
 10   CONTINUE
      RETURN 1
 20   RETURN
      END
