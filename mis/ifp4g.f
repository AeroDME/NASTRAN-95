      SUBROUTINE IFP4G (IBIT,FILE)
C
C     TURNS ON BIT -IBIT- IN TRAILER FOR DATA BLOCK -FILE-
C
      EXTERNAL    ORF
      INTEGER     ORF, TRAIL(7), FILE, TWO
      COMMON/TWO/ TWO(32)
C
      TRAIL(1) = FILE
      CALL RDTRL (TRAIL)
      I1 = (IBIT-1)/16 + 2
      I2 = IBIT - (I1-2)*16 + 16
      TRAIL(I1) = ORF(TRAIL(I1),TWO(I2))
      TRAIL(1) = FILE
      CALL WRTTRL (TRAIL)
      RETURN
      END
