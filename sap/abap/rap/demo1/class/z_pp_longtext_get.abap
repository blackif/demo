CLASS z_pp_longtext_get DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z_PP_LONGTEXT_GET IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

  ENDMETHOD.


METHOD if_sadl_exit_calc_element_read~calculate.

  DATA: lt_original_data TYPE STANDARD TABLE OF zc_pp_manufacturingorder,
        lt_lines         TYPE STANDARD TABLE OF tline.

  lt_original_data = CORRESPONDING #( it_original_data ).

  IF lt_original_data IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_data>).
    IF <fs_data>-Tdname IS INITIAL.
      CONTINUE.
    ENDIF.

    CLEAR lt_lines.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = 'KOPF'
        language                = 'J'
        name                    = <fs_data>-Tdname
        object                  = 'AUFK'
      TABLES
        lines                   = lt_lines
      exceptions
        id                      = 1
        LANGUAGE                = 2
        NAME                    = 3
        not_found               = 4
        OBJECT                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc = 0.
      DATA(lv_tab) = cl_abap_char_utilities=>horizontal_tab.
      DATA(lv_merged_text) = REDUCE string(
        INIT str = ``
        FOR ls_line IN lt_lines
        NEXT str = COND #( WHEN str = `` THEN replace( val = ls_line-tdline sub = lv_tab with = `` occ = 0 )
                           ELSE |{ str }{ replace( val = ls_line-tdline sub = lv_tab with = `` occ = 0 ) }| )
      ).

      CONDENSE lv_merged_text NO-GAPS.

      <fs_data>-LongText = lv_merged_text.
    ENDIF.
  ENDLOOP.

  ct_calculated_data = CORRESPONDING #( lt_original_data ).
ENDMETHOD.
ENDCLASS.
