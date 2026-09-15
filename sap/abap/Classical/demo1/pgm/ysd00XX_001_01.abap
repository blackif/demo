*&---------------------------------------------------------------------*
*& Include ysd00XX_001_01
*&---------------------------------------------------------------------*
" Expansion of billing document splitting for GI
YCLSD00XX_001_01=>daten_kopieren_901( EXPORTING kvgr2  = vbrp-kvgr2
                                      CHANGING  vbrk_s = vbrk ).
