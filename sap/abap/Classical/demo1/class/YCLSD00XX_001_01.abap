*&---------------------------------------------------------------------*
*& Class Definition: YCLSD00XX_001_01
*& Description: ZSD00XX_001 VOFM Routine Logic Implementation Class
*& Created: YYYY/MM/DD
*&---------------------------------------------------------------------*

CLASS YCLSD00XX_001_01 DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    "! Set split criteria for Goods Issue (GI) basis
    "! @parameter kvgr2  | Customer Group 2
    "! @parameter vbrk_s | Billing document header work area
    CLASS-METHODS daten_kopieren_901
      IMPORTING kvgr2  TYPE kvgr2
      CHANGING  vbrk_s TYPE vbrk.

    "! Set split criteria for Goods Acceptance (GA) basis
    "! @parameter kvgr2  | Customer Group 2
    "! @parameter likp_s | Delivery header (VOFM global variable)
    "! @parameter vbrk_s | Billing document header work area
    CLASS-METHODS daten_kopieren_902
      IMPORTING kvgr2  TYPE kvgr2
                likp_s TYPE likp
      CHANGING  vbrk_s TYPE vbrk.

ENDCLASS.



CLASS YCLSD00XX_001_01 IMPLEMENTATION.


*&---------------------------------------------------------------------*
*& Static Public Method YCLSD00XX_001_01=>DATEN_KOPIEREN_901
*&---------------------------------------------------------------------*
  METHOD daten_kopieren_901.
    " Set combination criteria
    vbrk_s-zukri = kvgr2.
  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Static Public Method YCLSD00XX_001_01=>DATEN_KOPIEREN_902
*&---------------------------------------------------------------------*
  METHOD daten_kopieren_902.
    " Set combination criteria
    vbrk_s-zukri = kvgr2.

    " Obtain a pod date.
    " The billing date will be overwritten only if pod date exists (acceptance-based transaction).
    IF likp_s-podat IS NOT INITIAL.
      vbrk_s-fkdat = likp_s-podat.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
