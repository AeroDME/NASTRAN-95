      SUBROUTINE NORM11(X,DIV)
C
      DOUBLE PRECISION DIV
      REAL             X(1)      ,MAX
      COMMON   /INVPWX/  FILEK(7)
      EQUIVALENCE        (NCOL,FILEK(2))
      DATA IND1 /1/
C
      MAX = 0.0
      DO 10 I=1,NCOL
      XX = ABS( X(I) )
      IF( XX .LE. MAX ) GO TO 10
      MAX = XX
      IND = I
   10 CONTINUE
      IF( X(IND) .LT. 0.0 ) IND = -IND
      I = IABS(IND1)
      XX = X(I)
      DIV = SIGN(1.,XX)*FLOAT(ISIGN(1,IND1))*MAX
      XX = DIV
      IND1 = IND*IFIX(SIGN(1.,XX))
      MAX = 1.0 /DIV
      DO 20 I=1,NCOL
      XI = X(I)*MAX
      IF (ABS(XI) .LT. 1.E-36) XI = 0.0
   20 X(I)= XI
      RETURN
      END
