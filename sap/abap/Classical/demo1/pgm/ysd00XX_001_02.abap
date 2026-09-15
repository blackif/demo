*&---------------------------------------------------------------------*
*& Include ysd00XX_001_02
*&---------------------------------------------------------------------*
" Expansion of billingdocument splitting for GA
YCLSD00XX_001_01=>daten_kopieren_902( EXPORTING kvgr2  = vbrp-kvgr2
                                                likp_s = likp
                                      CHANGING  vbrk_s = vbrk ).
