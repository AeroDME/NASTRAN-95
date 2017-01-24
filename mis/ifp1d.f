      SUBROUTINE IFP1D (MSNO)
C
C     MESSAGE WRITER FOR IFP1
C
      INTEGER         AMSNO
      CHARACTER       UFM*23,UWM*25
      COMMON /XMSSG / UFM,UWM
      COMMON /SYSTEM/ D,NOUT,NOGO,DD(5),NLPP,DDD(2),LINE
      DATA    MAXMSG/ 646   /
C
      AMSNO = IABS(MSNO)
      IF (MSNO  .LT. 0) NOGO = 1
      IF (AMSNO .GT. MAXMSG) GO TO 40
      IF (AMSNO .EQ. 612) CALL PAGE1
      IF (MSNO .LE. 0) WRITE (NOUT,10) UFM,AMSNO
      IF (MSNO .GT. 0) WRITE (NOUT,20) UWM,AMSNO
   10 FORMAT (A23,I7)
   20 FORMAT (A25,I5)
      IF (AMSNO.GE.634 .AND. AMSNO.LE.644) WRITE (NOUT,30)
   30 FORMAT (1H+,37X,'(FROM SCAN)')
      IWHER = AMSNO - 600
      GO TO ( 60, 80,100,120,140,160,180,200,220,240,
     1       260,280,400,420,440,460,480,500, 40, 40,
     2        40,520,540,560,580,600,620,640,660,680,
     3       700,720,740,760,780,800,820,840,860,880,
     4       900,920,940,960,980,1000), IWHER
C
C     619 - 621 ARE DEFINED IN IFP1S
C
   40 WRITE  (NOUT,50) AMSNO
   50 FORMAT (' NO TEXT AVAILABLE FOR MESSAGE',I6)
      GO TO  1100
C
   60 WRITE  (NOUT,70)
   70 FORMAT (' THE KEYWORD ON THE ABOVE CARD TYPE IS ILLEGAL OR MISS',
     1        'PELLED.  SEE THE FOLLOWING LIST FOR LEGAL KEYWORDS.')
      GO TO  1100
   80 WRITE  (NOUT,90)
   90 FORMAT (' TWO OR MORE OF THE ABOVE CARD TYPES DETECTED WHERE ',
     1        'ONLY ONE IS LEGAL.' ,/,' THE LAST FOUND WILL BE USED.')
      LINE = LINE + 1
      GO TO  1100
  100 WRITE  (NOUT,110)
  110 FORMAT (' THE ABOVE CARD DOES NOT END PROPERLY. COMMENTS SHOULD',
     1        'BE PRECEEDED', /,' BY A DOLLAR SIGN.')
      LINE = LINE + 1
      GO TO  1100
  120 WRITE  (NOUT,130)
  130 FORMAT (' THE ABOVE CARD HAS A NON-INTEGER IN AN INTEGER FIELD.')
      GO TO  1100
  140 WRITE  (NOUT,150)
  150 FORMAT (' A SYMSEQ OR SUBSEQ CARD APPEARS WITHOUT A SYMCOM OR ',
     1        'SUBCOM CARD.')
      GO TO  1100
  160 WRITE  (NOUT,170)
  170 FORMAT (' A REQUEST FOR TEMPERATURE DEPENDENT MATERIALS OCCURS AT'
     1,       ' THE SUBCASE LEVEL.', /,' ONLY ONE ALLOWED PER PROBLEM.')
      GO TO  1100
  180 WRITE  (NOUT,190)
  190 FORMAT (' A REPCASE CARD MUST BE PROCEEDED BY A SUBCASE CARD')
      GO TO  1100
  200 WRITE  (NOUT,210)
  210 FORMAT (' THE SET ID SPECIFIED ON THE ABOVE CARD MUST BE DEFINED',
     1        ' PRIOR TO THIS CARD.')
      GO TO  1100
  220 WRITE  (NOUT,230)
  230 FORMAT (' SUBCASE DELIMITER CARDS MUST HAVE A UNIQUE IDENTIFYING',
     1        ' INTEGER.')
      GO TO  1100
  240 WRITE  (NOUT,250)
  250 FORMAT (' NO SET ID SPECIFIED.  ALL WILL BE ASSUMED.')
      GO TO  1100
  260 WRITE  (NOUT,270)
  270 FORMAT (' TEN CARDS HAVE ILLEGAL KEY WORDS. NASTRAN ASSUMES BEGIN'
     1,       ' BULK CARD', /,' IS MISSING. IT WILL NOW PROCESS YOUR ',
     2        'BULK DATA.')
      LINE = LINE + 1
      GO TO  1100
C
C     THE LIST OF CASE CONTROL CARDS IS FORMATTED FOR SHORT PAPER
C
  280 WRITE  (NOUT,290)
  290 FORMAT (///,10(1H-),' THE FOLLOWING IS A LIST OF VALID CASE ',
     1        'CONTROL KEY WORDS EXCEPT FOR THE PLOTTER PACKAGES.',
     2        10(1H-), //6X,'KEYWORD',20X,'MEANING',/)
      WRITE  (NOUT,300)
  300 FORMAT (5X,'ACCELERATION',12X,
     1       'OUTPUT REQUEST FOR ACCELERATION VECTORS',
     2       /6X,'AEROFORCE',15X,
     3       'OUTPUT REQUEST FOR AERODYNAMIC FORCES',
     4       /6X,'AXISYMMETRIC',12X,
     5       'AXISYMMETRIC CASE SELECTION (SINE OR COSINE)',
     6       /6X,'B2PP',20X,
     7       'SELECTION OF STRUCTURAL DAMPING OR THERMAL CAPACITANCE ',
     8       'MATRICES',
     9       /6X,'CMETHOD',17X,
     O       'COMPLEX EIGENVALUE METHOD SELECTION',
     1       /6X,'DEFORM',18X,
     2       'REQUEST FOR ENFORCED ELEMENT DEFORMATION',
     3       /6X,'DISPLACEMENT',12X,
     4       'OUTPUT REQUEST FOR DISPLACEMENT VECTORS',
     5       /6X,'DLOAD',19X,
     6       'DYNAMIC LOAD SELECTION')
      WRITE  (NOUT,310)
  310 FORMAT (6X,'DSCOEFFICIENT',11X,
     1       'DIFFERENTIAL STIFFNESS COEFFICIENT SET SELECTION',
     2       /6X,'ECHO',20X,
     3       'BULK DATA ECHO SELECTOR (SORT,UNSORT,BOTH,NONE,PUNCH)',
     4       /6X,'ELFORCE',17X,
     5       'OUTPUT REQUEST FOR ELEMENT FORCES',
     6       /6X,'ELSTRESS',16X,
     7       'OUTPUT REQUEST FOR ELEMENT STRESSES',
     8       /6X,'ESE',21X,
     9       'REQUEST FOR ELEMENT STRAIN ENERGY OUTPUT',
     O       /6X,'FMETHOD',17X,
     1       'REQUEST FOR AEROELASTIC FLUTTER METHOD',
     2       /6X,'FORCE',18X,
     3       'OUTPUT REQUEST FOR ELEMENT FORCES',
     4       /6X,'FREQUENCY',15X,
     5       'FREQUENCY SET SELECTION')
      WRITE  (NOUT,320)
  320 FORMAT (6X,'GPFORCE',17X,
     1       'REQUEST FOR GRID POINT FORCE BALANCE OUTPUT',
     2       /6X,'GUST',20X,
     3       'AEROELASTIC RESPONSE ANALYSIS INPUT LOADING CONDITION',
     4       /6X,'HARMONICS',15X,
     5       'HARMONICS TO BE PRINTED FOR AXISYMMETRIC SHELL PROBLEM',
     6       /6X,'IC',22X,
     7       'INITIAL CONDITIONS FOR DIRECT TRANSIENT PROBLEM',
     8       /6X,'K2PP',20X,
     9       'SELECTION OF STRUCT-L STIFFNESS OR THERMAL CONDUCTANCE ',
     O       'MATRICES',
     1       /6X,'LABEL',19X,
     2       'DEFINES PRINTER, PLOTTER AND PUNCH OUTPUT LABEL',
     3       /6X,'LINE',20X,
     4       'NUMBER OF LINES PER PAGE (DFLT = 50 -CDC,IBM, 45 -UNIVAC)'
     5,      /6X,'LOAD',20X,
     6       'STATIC ANALYSIS EXTERNAL LOAD SELECTION OR HEAT POWER/',
     7       'FLUX')
      WRITE  (NOUT,330)
  330 FORMAT (6X,'M2PP',20X,
     1       'SELECTION OF INPUT MASS MATRICES VIA DMIG CARDS',
     2       /6X,'MAXLINES',16X,
     3       'MAXIMUM NUMBER OF PRINTER LINES (DEFAULT = 20000)',
     4       /6X,'METHOD',18X,
     5       'REAL EIGENVALUE METHOD SELECTION',
     6       /6X,'MODES',19X,
     7       'DUPLICATE CASE CONTROL THIS MANY TIMES',
     8       /6X,'MPC',21X,
     9       'SELECTS MULTI-POINT CONSTRAINTS OR HEAT TRANSFER ',
     O       'BOUNDARY TEMPS',
     1       /6X,'MPCFORCE',16X,
     2       'OUTPUT REQUEST FOR MULTI-POINT FORCES OF CONSTRAINT',
     3       /6X,'NCHECK',18X,
     4       'OUTPUT REQUEST FOR FORCE AND STRESS PRECISION',
     5       /6X,'NLLOAD',18X,
     6       'OUTPUT REQUEST FOR NON-LINEAR LOADS FOR ANALYSIS SET')
C
      CALL PAGE1
      WRITE  (NOUT,340)
  340 FORMAT (//6X,7HKEYWORD,20X,7HMEANING,
     1       //6X,'NONLINEAR',15X,
     2       'NON-LINEAR LOAD SET FOR TRANSIENT PROBLEMS',
     3       /6X,'OFREQUENCY',14X,
     4       'SELECTS OUTPUT FREQUENCIES OR -IM- PART OF COMPLEX ',
     5       'EIGENVALUES',
     6       /6X,'OLOAD',19X,
     7       'OUTPUT REQUEST FOR APPLIED LOAD',
     8       /6X,'OTIME',19X,
     9       'REQUEST FOR SELECTED OUTPUT TIMES',
     O       /6X,'OUTPUT',18X,
     1       'OUTPUT PACKET DELIMITER (THIS CARD IS OPTIONAL)',
     2       /6X,'OUTPUT(PLOT)',12X,
     3       'STRUCTURE PLOTTER OUTPUT PACKET DELIMITER',
     4       /6X,'OUTPUT(XYOUT)',11X,
     5       'XY OUTPUT PACKET DELIMITER (PLOTTER, PRINTER AND PUNCH)',
     6       /6X,'OUTPUT(XYPLOT)',10X,
     7       'EQUIVALENT TO OUTPUT(XYOUT)')
      WRITE  (NOUT,350)
  350 FORMAT (6X,'PLCOEFFICIENT',11X,
     1       'PIECEWISE LINEAR COEFFICIENT SET SELECTION',
     2       /6X,'PLOTID',18X,
     3       'DEFINES PLOTTER OUTPUT HEADER FRAME TITLE',
     4       /6X,'PRESSURE',16X,
     5       'OUTPUT REQUEST FOR HYDROELASTIC PRESSURE',
     6       /6X,'RANDOM',18X,
     7       'RANDOM ANALYSIS PSDL AND RANDT SET SELECTION',
     8       /6X,'REPCASE',17X,
     9       'REPEAT THE PRECEDING CASE AGAIN',
     O       /6X,'SACCELERATION',11X,
     1       'OUTPUT REQUEST FOR SOLUTION SET ACCELERATION VECTORS',
     2       /6X,'SCAN',20X,
     3       'SCAN AND OUTPUT STRESSES OR FORCES FOR PREDETERMINED ',
     4       'CRITERIA',
     5       /6X,'SDAMPING',16X,
     6       'MODAL FORMULATION STRUCTURAL DAMPING TABULAR FUNCTION ',
     7       'SELECTION',
     8       /6X,'SDISPLACEMENT',11X,
     9       'OUTPUT REQUEST FOR SOLUTION SET DISPLACEMENT VECTORS')
      WRITE  (NOUT,360)
  360 FORMAT (6X,'SET',21X,
     1       'DEFINES OUTPUT SET LIST',
     2       /6X,'SPC',21X,
     3       'SELECTS SINGLE POINT CONSTRAINTS OR HEAT TRANSFER ',
     4       'BOUNDARY TEMP',
     5       /6X,'SPCFORCE',16X,
     6       'REQUESTS SINGLE POINT CONSTRAINT FORCES OR THERMAL POWER',
     7       /6X,'STRAIN',18X,
     8       'OUTPUT REQUEST FOR ELEMENT STRAINS',
     9       /6X,'STRESS',18X,
     O       'OUTPUT REQUEST FOR ELEMENT STRESSES',
     1       /6X,'SUBCASE',17X,
     2       'SUBCASE DELIMITER',
     3       /6X,'SUBCOM',18X,
     4       'THIS CASE IS A LINEAR COMBINATION OF THE PRECEDING ',
     5       'SUBCASES',
     6       /6X,'SUBSEQ',18X,
     7       'DEFINES COEFFICIENTS FOR LINEAR SUBCASE COMBINATION')
      WRITE  (NOUT,370)
  370 FORMAT (6X,'SUBTITLE',16X,
     1       'DEFINES PRINTER, PLOTTER AND PUNCH OUTPUT SUBTITLE',
     2       /6X,'SVECTOR',17X,
     3       'OUTPUT REQUEST FOR SOLUTION SET DISPLACEMENT VECTORS',
     4       /6X,'SVELOCITY',15X,
     5       'OUTPUT REQUEST FOR SOLUTION SET VELOCITY VECTORS',
     6       /6X,'SYM',21X,
     7       'SYMMETRY SUBCASE DELIMITER',
     8       /6X,'SYMCOM',18X,
     9       'THIS CASE IS A LINEAR COMBINATION OF THE PRECEDING SYM ',
     O       'CASES',
     1       /6X,'SYMSEQ',18X,
     2       'DEFINES COEFFICIENTS FOR LINEAR SYM COMBINATION (DEFAULT',
     3       ' = 1.0)',
     4       /6X,'TEMPERATURE(BOTH)',7X,
     5       'THERMAL SET SELECTION FOR BOTH LOAD AND MATERIAL DATA',
     6       /6X,'TEMPERATURE(LOAD)',7X,
     7       'THERMAL LOAD TEMPERATURE SET SELECTION')
C
      CALL PAGE1
      WRITE  (NOUT,380)
  380 FORMAT (//6X,'KEYWORD',20X,'MEANING',
     1       /6X,'TEMPERATURE(MATERIAL)',3X,
     2       'SELECTS THERMAL DEPENDENT MATERIALS OR TEMPERATURE ',
     3       'ESTIMATES',
     4       /6X,'TFL',21X,
     5       'TRANSFER FUNCTION SET SELECTION',
     6       /6X,'THERMAL',17X,
     7       'OUTPUT REQUEST FOR TEMPERATURES IN HEAT TRANSFER ANALYSIS'
     8,      /6X,'TITLE',19X,
     9       'DEFINES PRINTER, PLOTTER AND PUNCH OUTPUT TITLE',
     O       /6X,'TSTEP',19X,
     1       'TIME STEP SET SELECTION FOR TRANSIENT PROBLEMS',
     2       /6X,'VECTOR',18X,
     3       'OUTPUT REQUEST FOR DISPLACEMENT VECTORS',
     4       /6X,'VELOCITY',16X,
     5       'OUTPUT REQUEST FOR VELOCITY VECTORS',
     6       /6X,'BEGIN BULK',14X,
     7       'THIS CARD MARKS THE END OF THE CASE CONTROL DECK')
      GO TO 1110
C
  400 WRITE  (NOUT,410)
  410 FORMAT (' THE ABOVE SET CONTAINS -EXCEPT- WHICH IS NOT PRECEDED ',
     1        'BY -THRU-.')
      GO TO  1100
  420 WRITE  (NOUT,430)
  430 FORMAT (' THE ABOVE SET IS INCORRECTLY SPECIFIED.  CHECK FORMAT ',
     1        'ON THIS OR PREVIOUS CARD.')
      GO TO  1100
  440 WRITE  (NOUT,450)
  450 FORMAT (' AN IMPROPER OR NO NAME GIVEN TO THE ABOVE SET.')
      GO TO  1100
  460 WRITE  (NOUT,470)
  470 FORMAT (' ELEMENT IN THRU RANGE LIES IN RANGE OF PREVIOUS THRU ',
     1        'OR EXCEPT.  MISSING ELEMENT OR INCORRECT USE OF THRU.')
      GO TO  1100
  480 WRITE  (NOUT,490)
  490 FORMAT (' INCORRECT OR MISSING VALUE ON CASE CONTROL CARD. ',
     1        ' CHECK FOR CORRECT CARD FORMAT.')
      GO TO  1100
  500 WRITE  (NOUT,510)
  510 FORMAT (' PLOT OUTPUT IS REQUESTED BUT THE PROPER PLOT TAPE IS ',
     1        'NOT A PHYSICAL TAPE')
      GO TO  1100
C
  520 WRITE  (NOUT,530)
  530 FORMAT (' REAL VALUES NOT ALLOWED IN A THRU SEQUENCE.')
      GO TO  1100
  540 WRITE  (NOUT,550)
  550 FORMAT (' UNEXPECTED END-OF-RECORD ON CASE CONTROL CARD.  CHECK ',
     1        'FOR CORRECT CARD FORMAT.')
      GO TO  1100
  560 WRITE  (NOUT,570)
  570 FORMAT (' BEGIN BULK CARD NOT FOUND.')
      GO TO  1100
  580 WRITE  (NOUT,590)
  590 FORMAT (' TOO LARGE ID ON PRECEDING SUBCASE TYPE CARD. ALL ID-S ',
     1        'MUST BE LESS THAN 99,999,999.')
      GO TO  1100
  600 WRITE  (NOUT,610)
  610 FORMAT (' VALUES IN EXCEPT MUST BE SPECIFIED IN ASCENDING ORDER')
      GO TO  1100
  620 WRITE  (NOUT,630)
  630 FORMAT (' THE ABOVE SUBCASE HAS BOTH A STATIC LOAD AND A REAL ',
     1        'EIGENVALUE METHOD SELECTION - REMOVE ONE.')
      GO TO  1100
  640 WRITE  (NOUT,650)
  650 FORMAT (/,' THERMAL, DEFORMATION, AND EXTERNAL LOADS CANNOT HAVE',
     1        ' THE SAME SET IDENTIFICATION NUMBER.')
      GO TO  1100
  660 WRITE  (NOUT,670)
  670 FORMAT (' ECHO CARD HAS REPEATED OR UNRECOGNIZABLE SPECIFICATION',
     1        ' DATA - ',/11X,'REPEATED SPECIFICATIONS WILL BE IGNORED',
     2        /11X,'UNRECOGNIZABLE SPECIFICATIONS WILL BE TREATED AS ',
     3        'SORT.')
      LINE = LINE + 2
      GO TO  1100
  680 WRITE  (NOUT,690)
  690 FORMAT (' ECHO CARD WITH -NONE- SPECIFICATION HAS ADDITIONAL ',
     1        'SPECIFICATIONS WHICH WILL BE IGNORED.')
      GO TO  1100
  700 WRITE  (NOUT,710)
  710 FORMAT (' PLOT AND/OR SET COMMAND CARD MISSING FROM STRUCTURE ',
     1        'PLOTTER OUTPUT PACKAGE.')
      GO TO  1100
  720 WRITE  (NOUT,730)
  730 FORMAT (' XYPLOT COMMAND CARDS FOUND IN STRUCTURE PLOTTER OUTPUT',
     1        ' PACKAGE.')
      GO TO  1100
  740 WRITE  (NOUT,750)
  750 FORMAT (' SUBCASE LIMIT OF 360 EXCEEDED')
      GO TO  1100
C
C     MESSAGES 634 - 644 (760 THRU 960) ARE CALLED ONLY BY SCAN
C
  760 WRITE  (NOUT,770)
  770 FORMAT (5X,'KEYWORD INSIDE BRACKETS IS ILLEGAL OR MIS-SPELLED')
      GO TO  1100
  780 WRITE  (NOUT,790)
  790 FORMAT (5X,'ONLY ONE SET-ID ALLOWED')
      GO TO  1100
  800 WRITE  (NOUT,810)
  810 FORMAT (5X,'EXTRA VALUE ENCOUNTERED OR WRONG TYPE OF INPUT DATA')
      GO TO  1100
  820 WRITE  (NOUT,830)
  830 FORMAT (5X,'ILLEGAL COMPONENT SPECIFIED')
      GO TO  1100
  840 WRITE  (NOUT,850)
  850 FORMAT (5X,'COMPONENT LIMIT OF 31 IS EXCEEDED')
      GO TO  1100
  860 WRITE  (NOUT,870)
  870 FORMAT (5X,'SET ID ERROR (REQUESTED BEFORE EQUAL SIGN OR ',
     1       'SPLITTED ID)')
      GO TO  1100
  880 WRITE  (NOUT,890)
  890 FORMAT (5X,'TOO MANY COMPONENTS')
      GO TO  1100
  900 WRITE  (NOUT,910)
  910 FORMAT (5X,'MINUS MAX EXCEEDS PLUS MAX')
      GO TO  1100
  920 WRITE  (NOUT,930)
  930 FORMAT (5X,'COMPONENT NAME NOT AVAILABLE FOR ELEMENT SELECTED')
      GO TO  1100
  940 WRITE  (NOUT,950)
  950 FORMAT (5X,'OUTPUT SCAN BY FORCE OR BY STRESS ONLY')
      GO TO  1100
  960 WRITE  (NOUT,970)
  970 FORMAT (5X,'LARGE TOPN VALUE REQUESTED MAY RESULT IN INSUFFICIENT'
     1,      ' CORE IN OUTPUT SCAN MODULE LATER')
      GO TO  1100
C
  980 WRITE  (NOUT,990)
  990 FORMAT (5X,'SORT2 REQUEST FOR STRESSES ON THE LAYERED ELEMENTS ',
     1       'IS CURRENTLY NOT SET UP BY THE RIGID FORMAT')
      GO TO  1100
 1000 WRITE  (NOUT,1010)
 1010 FORMAT (5X,'LAYER OPTION IS AVAILABLE ONLY IN STRESS OR ELSTRESS')
 1100 LINE = LINE + 3
      IF (LINE .GE. NLPP) CALL PAGE
 1110 RETURN
      END
