CLASS zclfi00XX_001_01 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES t_febcl_t TYPE STANDARD TABLE OF febcl.

    CLASS-METHODS exit_rfebbu10_001
      IMPORTING in_febko  TYPE febko
                in_febep  TYPE febep
      EXPORTING out_febep TYPE febep
                febcl_t   TYPE t_febcl_t.

  PRIVATE SECTION.
    TYPES: BEGIN OF t_customercompany_s,
             customer        TYPE I_CustomerCompany-Customer,
             AccountingClerk TYPE I_CustomerCompany-AccountingClerk,
           END OF t_customercompany_s.
    TYPES: BEGIN OF t_isjpbkcharge_s,
             bankchargeamount TYPE zc_fi_isjpbkcharge-bankchargeamount,
           END OF t_isjpbkcharge_s.
    TYPES: BEGIN OF t_accountingitem_s,
             accountingdocument          TYPE I_OperationalAcctgDocItem-AccountingDocument,
             accountingdocumentitem      TYPE I_OperationalAcctgDocItem-AccountingDocumentItem,
             amountintransactioncurrency TYPE I_OperationalAcctgDocItem-AmountInTransactionCurrency,
             duecalculationbasedate      TYPE I_OperationalAcctgDocItem-DueCalculationBaseDate,
             cashdiscount1days           TYPE I_OperationalAcctgDocItem-CashDiscount1Days,
             addeddate                   TYPE dats,
           END OF t_accountingitem_s.

    TYPES t_isjpbkcharge_t   TYPE SORTED TABLE OF t_isjpbkcharge_s WITH NON-UNIQUE KEY bankchargeamount.
    TYPES t_accountingitem_t TYPE STANDARD TABLE OF t_accountingitem_s.

    CONSTANTS waers_std               TYPE waers     VALUE 'JPY'.
    CONSTANTS paval_val               TYPE paval     VALUE 'ZFI001'.
    CONSTANTS debitcreditcode_s       TYPE char1     VALUE 'S'.
    CONSTANTS clearingjournalentry_bl TYPE char1     VALUE ''.
    CONSTANTS koart_d                 TYPE koart     VALUE 'D'.
    CONSTANTS selfd_belnr             TYPE char5     VALUE 'BELNR'.
    CONSTANTS id_zfi                  TYPE balobj_d  VALUE 'ZFI'.
    CONSTANTS id_subobject            TYPE balsubobj VALUE 'ZFI0009_001_01'.
    CONSTANTS number_004              TYPE symsgno   VALUE '004'.
    CONSTANTS number_005              TYPE symsgno   VALUE '005'.

    CLASS-METHODS parameter_check
      IMPORTING febko_bukrs         TYPE bukrs
      RETURNING VALUE(check_result) TYPE abap_boolean.

    CLASS-METHODS get_data
      IMPORTING febep_partn       TYPE partn_eb
                febko_bukrs       TYPE bukrs
      EXPORTING customercompany_s TYPE t_customercompany_s
                accountingitem_s  TYPE t_accountingitem_t
                isjpbkcharge_t    TYPE t_isjpbkcharge_t.

    CLASS-METHODS get_matched_item
      IMPORTING in_febep             TYPE febep
                in_accountingitem_t  TYPE t_accountingitem_t
                isjpbkcharge_t       TYPE t_isjpbkcharge_t
      EXPORTING out_febep            TYPE febep
                out_accountingitem_t TYPE t_accountingitem_t.

    CLASS-METHODS set_data
      IMPORTING febep_kukey      TYPE kukey_eb
                febep_esnum      TYPE esnum_eb
                !customer        TYPE t_customercompany_s-customer
                accountingitem_t TYPE t_accountingitem_t
      EXPORTING febcl_t          TYPE t_febcl_t.

    CLASS-METHODS create_app_log
      IMPORTING message_num   TYPE symsgno
                message_var_1 TYPE symsgv
                message_var_2 TYPE symsgv OPTIONAL.
ENDCLASS.


CLASS zclfi00XX_001_01 IMPLEMENTATION.
  METHOD exit_rfebbu10_001.
    DATA customercompany_s    TYPE t_customercompany_s.
    DATA accountingitem_t     TYPE t_accountingitem_t.
    DATA isjpbkcharge_t       TYPE t_isjpbkcharge_t.
    DATA out_accountingitem_t TYPE t_accountingitem_t.

    " check company code for processing
    DATA(check_result) = parameter_check( febko_bukrs = in_febko-bukrs ).

    IF check_result = abap_false.
      RETURN.
    ENDIF.

    get_data( EXPORTING febep_partn       = in_febep-partn
                        febko_bukrs       = in_febko-bukrs
              IMPORTING customercompany_s = customercompany_s
                        accountingitem_s  = accountingitem_t
                        isjpbkcharge_t    = isjpbkcharge_t ).

    IF    ( customercompany_s IS INITIAL )
       OR ( accountingitem_t  IS INITIAL )
       OR ( isjpbkcharge_t    IS INITIAL ).
      RETURN.
    ENDIF.

    " select receivable documents
    get_matched_item( EXPORTING in_febep             = in_febep
                                in_accountingitem_t  = accountingitem_t
                                isjpbkcharge_t       = isjpbkcharge_t
                      IMPORTING out_febep            = out_febep
                                out_accountingitem_t = out_accountingitem_t ).

    IF    ( out_febep            IS INITIAL )
       OR ( out_accountingitem_t IS INITIAL ).
      RETURN.
    ENDIF.

    " store items for clearing
    set_data( EXPORTING febep_kukey      = in_febep-kukey
                        febep_esnum      = in_febep-esnum
                        customer         = customercompany_s-customer
                        accountingitem_t = out_accountingitem_t
              IMPORTING febcl_t          = febcl_t[] ).
  ENDMETHOD.

  METHOD parameter_check.
    DATA app_bukrs TYPE symsgv.

    " retrieve company code parameter value
    SELECT SINGLE FROM I_AddlCompanyCodeInformation
      FIELDS @abap_true
      WHERE CompanyCode               = @febko_bukrs
        AND CompanyCodeParameterType  = @paval_val
        AND CompanyCodeParameterValue = @abap_true
      INTO @check_result.

    " Create an application log if retrieval fails
    IF check_result = abap_false.

      app_bukrs = febko_bukrs.

      create_app_log( message_num   = number_004
                      message_var_1 = TEXT-001
                      message_var_2 = app_bukrs ).
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD get_data.
    " retrieve customer code
    SELECT SINGLE FROM I_CustomerCompany
      FIELDS Customer,
             AccountingClerk
      WHERE AccountingClerkPhoneNumber = @febep_partn+0(30)
      INTO @customercompany_s.

    " Create an application log if retrieval fails
    IF sy-subrc <> 0.
      create_app_log( message_num   = number_005
                      message_var_1 = TEXT-002 ).
      RETURN.
    ENDIF.

    " retrieve accounting document line item data
    SELECT FROM I_OperationalAcctgDocItem
      FIELDS AccountingDocument,
             AccountingDocumentItem,
             AmountInTransactionCurrency,
             DueCalculationBaseDate,
             CashDiscount1Days,
             dats_add_days( DueCalculationBaseDate, CAST( CashDiscount1Days AS INT4 ) ) AS addeddate
      WHERE Customer             = @customercompany_s-Customer
        AND ClearingJournalEntry = @clearingjournalentry_bl
      INTO TABLE @accountingitem_s.

    " Create an application log if retrieval fails
    IF sy-subrc <> 0.
      create_app_log( message_num   = number_005
                      message_var_1 = TEXT-003 ).
      RETURN.
    ENDIF.

    " Sorting process
    SORT accountingitem_s BY
      addeddate          ASCENDING
      accountingdocument ASCENDING.

    " retrieve bank fee data
    SELECT FROM zc_fi_isjpbkcharge
      FIELDS bankchargeamount
      WHERE companycode         = @febko_bukrs
        AND bankchargepatternid = @customercompany_s-AccountingClerk
      INTO TABLE @isjpbkcharge_t.

    " Create an application log if retrieval fails
    IF sy-subrc <> 0.
      create_app_log( message_num   = number_005
                      message_var_1 = TEXT-004 ).
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD get_matched_item.
    DATA t_target TYPE t_accountingitem_t.
    DATA v_total  TYPE wrbtr.
    DATA v_diff   TYPE bapicurr-bapicurr.

    " Get the maximum fee
    DATA(max_bankcharge) = isjpbkcharge_t[ lines( isjpbkcharge_t ) ]-bankchargeamount.

    " determine line item amount: total
    LOOP AT in_accountingitem_t ASSIGNING FIELD-SYMBOL(<accountingitem_to>).

      CLEAR v_diff.

      " add document currency amount
      v_total += <accountingitem_to>-AmountInTransactionCurrency.

      " add the current item to the internal table for summation
      t_target = VALUE #( BASE t_target
                          ( <accountingitem_to> ) ).

      " if payment amount is less, continue to next loop
      IF v_total <= in_febep-kwbtr.
        CONTINUE.
      ENDIF.

      v_diff = v_total - in_febep-kwbtr.

      " If the difference exceeds the maximum fee, exit the loop
      IF max_bankcharge < v_diff.
        EXIT.
      ENDIF.

      " when difference equals fee, add item to cleared-docs table and break loop
      IF line_exists( isjpbkcharge_t[ bankchargeamount = v_diff ] ).
        out_accountingitem_t = t_target.

        out_febep = in_febep.

        out_febep-spesk = v_diff.

        RETURN.
      ENDIF.

    ENDLOOP.

    " determine line item amount: individual
    LOOP AT in_accountingitem_t ASSIGNING FIELD-SYMBOL(<accountingitem_ind>) FROM 2.

      CLEAR v_diff.

      v_diff = <accountingitem_ind>-AmountInTransactionCurrency - in_febep-kwbtr.

      " when difference equals fee, add item to cleared-docs table and break loop
      IF line_exists( isjpbkcharge_t[ bankchargeamount = v_diff ] ).

        out_accountingitem_t = VALUE #( BASE out_accountingitem_t
                                        ( <accountingitem_ind> ) ).

        out_febep = in_febep.

        out_febep-spesk = v_diff.
        RETURN.
      ENDIF.

    ENDLOOP.

    " no target
    IF out_accountingitem_t IS INITIAL.
      create_app_log( message_num   = number_005
                      message_var_1 = TEXT-005 ).

    ENDIF.
  ENDMETHOD.

  METHOD set_data.
    DATA v_counter TYPE csnum_eb VALUE 1.

    " set item for clearing
    LOOP AT accountingitem_t ASSIGNING FIELD-SYMBOL(<accountingitem_set>).

      APPEND VALUE #( kukey  = febep_kukey
                      esnum  = febep_esnum
                      csnum  = v_counter
                      koart  = koart_d
                      agkon  = customer
                      selfd  = selfd_belnr
                      selvon = <accountingitem_set>-AccountingDocument
                      selbis = space  ) TO febcl_t.

      v_counter += 1.

    ENDLOOP.
  ENDMETHOD.

  METHOD create_app_log.
    TRY.
        DATA(app_log) = cl_bali_log=>create( ).

        app_log->set_header( header = cl_bali_header_setter=>create( object    = id_zfi
                                                                     subobject = id_subobject ) ).

        DATA(app_msg) = cl_bali_message_setter=>create( id         = id_zfi
                                                        number     = message_num
                                                        variable_1 = message_var_1
                                                        variable_2 = message_var_2 ).

        app_log->add_item( item = app_msg ).

        cl_bali_log_db=>get_instance( )->save_log( log = app_log ).
      CATCH cx_bali_runtime.

    ENDTRY.
  ENDMETHOD.
ENDCLASS.
