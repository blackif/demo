CLASS zcl_pp_supplydemand_qry DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

  PRIVATE SECTION.

    " 出力結果の型（CDSフィールド名をそのまま小文字化）
    TYPES: BEGIN OF ty_result,
             plant                      TYPE werks_d,
             mrpelementtype             TYPE delkz,
             mrpelement                 TYPE del12,
             mrpelementdescription      TYPE char60,
             material                   TYPE matnr,
             productgroup               TYPE matkl,
             materialtext               TYPE maktx,
             requirementdate            TYPE dat00,
             allocmrpelementtype        TYPE delkz,
             allocmrpelementdescription TYPE char60,
             allocmrpelement            TYPE del12,
             allocmaterial              TYPE matnr,
             allocmaterialtext          TYPE maktx,
             allocquantity               TYPE lmeng,
             quantityunit               TYPE meins,
             allocrequirementdate       TYPE dat00,
           END OF ty_result,
           tt_result TYPE STANDARD TABLE OF ty_result WITH DEFAULT KEY.

    " 再帰処理履歴の型
    TYPES: BEGIN OF ty_recursion_history,
             plant            TYPE werks_d,
             material         TYPE matnr,
             mrpelement       TYPE del12,
             alloc_plant      TYPE werks_d,
             alloc_material   TYPE matnr,
             alloc_mrpelement TYPE del12,
           END OF ty_recursion_history,
           tt_recursion_history TYPE STANDARD TABLE OF ty_recursion_history WITH DEFAULT KEY.

    " 品目一覧の型
    TYPES: BEGIN OF ty_material_list,
             plant         TYPE werks_d,
             material      TYPE matnr,
             product_group TYPE matkl,
             material_text TYPE maktx,
             base_unit     TYPE meins,
           END OF ty_material_list,
           tt_material_list TYPE STANDARD TABLE OF ty_material_list WITH DEFAULT KEY.

    " I_SUPPLYDEMANDITEMTP 取得用の型
    TYPES: BEGIN OF ty_sd_item,
             mrpplant                  TYPE werks_d,
             material                  TYPE matnr,
             mrpelementcategory        TYPE delkz,
             mrpelement                TYPE del12,
             mrpelementavailyorrqmtdate TYPE dat00,
             mrpelementopenquantity    TYPE p LENGTH 13 DECIMALS 3,
             assembly                  TYPE matnr,
             productionplant           TYPE werks_d,
             mrpelementdocumenttype    TYPE char4,
           END OF ty_sd_item,
           tt_sd_item TYPE STANDARD TABLE OF ty_sd_item WITH DEFAULT KEY.

    " デバッグログの型
    TYPES: BEGIN OF ty_log,
             step     TYPE char12,
             message  TYPE char60,
             plant    TYPE werks_d,
             material TYPE matnr,
           END OF ty_log,
           tt_log TYPE STANDARD TABLE OF ty_log WITH DEFAULT KEY.

    METHODS:
      build_log_result
        IMPORTING
          it_log         TYPE tt_log
        RETURNING
          VALUE(rt_result) TYPE tt_result,

      get_material_by_code
        IMPORTING
          iv_plant    TYPE werks_d
          iv_material TYPE matnr
        RETURNING
          VALUE(rt_list) TYPE tt_material_list,

      get_material_by_group
        IMPORTING
          iv_plant         TYPE werks_d
          iv_product_group TYPE matkl
        RETURNING
          VALUE(rt_list) TYPE tt_material_list,

      process_supply_demand
        IMPORTING
          iv_plant          TYPE werks_d
          iv_material       TYPE matnr
          iv_product_group  TYPE matkl
          iv_material_text  TYPE maktx
          iv_base_unit      TYPE meins
        CHANGING
          ct_result         TYPE tt_result
          ct_recursion_hist TYPE tt_recursion_history
          ct_log            TYPE tt_log,

      get_mrp_element_description
        IMPORTING
          iv_element_ind TYPE c
          iv_order_type  TYPE c OPTIONAL
        RETURNING
          VALUE(rv_description) TYPE char60,

      convert_alloc_element_type
        IMPORTING
          iv_element_ind TYPE c
        RETURNING
          VALUE(rv_converted) TYPE delkz.

ENDCLASS.

CLASS zcl_pp_supplydemand_qry IMPLEMENTATION.
  METHOD if_rap_query_provider~select.

    DATA: lv_plant          TYPE werks_d,
          lv_material       TYPE matnr,
          lv_product_group  TYPE matkl,
          lt_material_list  TYPE tt_material_list,
          lt_result         TYPE tt_result,
          lt_recursion_hist TYPE tt_recursion_history,
          lt_log            TYPE tt_log,
          lt_filter_ranges  TYPE if_rap_query_filter=>tt_name_range_pairs.

    " ページング情報取得（必須呼び出し）
    DATA(lo_paging) = io_request->get_paging( ).

    " フィルタ条件取得
    TRY.
      lt_filter_ranges = io_request->get_filter( )->get_as_ranges( ).
    CATCH cx_rap_query_filter_no_range.
    ENDTRY.

    LOOP AT lt_filter_ranges INTO DATA(ls_filter).
      CASE ls_filter-name.
        WHEN 'PLANT'.
          READ TABLE ls_filter-range INTO DATA(ls_range) INDEX 1.
          IF sy-subrc = 0. lv_plant = ls_range-low. ENDIF.
        WHEN 'MATERIAL'.
          READ TABLE ls_filter-range INTO DATA(ls_range2) INDEX 1.
          IF sy-subrc = 0. lv_material = ls_range2-low. ENDIF.
        WHEN 'PRODUCTGROUP'.
          READ TABLE ls_filter-range INTO DATA(ls_range4) INDEX 1.
          IF sy-subrc = 0. lv_product_group = ls_range4-low. ENDIF.
      ENDCASE.
    ENDLOOP.

    APPEND VALUE #(
      step     = '1_FILTER'
      message  = |Plant={ lv_plant } Grp={ lv_product_group } Mat={ lv_material }|
      plant    = lv_plant
      material = lv_material
    ) TO lt_log.

    IF lv_plant IS INITIAL.
      io_response->set_data( VALUE tt_result( ) ).
      io_response->set_total_number_of_records( 0 ).
      RETURN.
    ENDIF.

    IF lv_product_group IS INITIAL.
      io_response->set_data( VALUE tt_result( ) ).
      io_response->set_total_number_of_records( 0 ).
      RETURN.
    ENDIF.

    IF lv_material IS NOT INITIAL.
      lt_material_list = get_material_by_code(
        iv_plant    = lv_plant
        iv_material = lv_material ).
    ELSE.
      lt_material_list = get_material_by_group(
        iv_plant         = lv_plant
        iv_product_group = lv_product_group ).
    ENDIF.

    APPEND VALUE #(
      step    = '2_MAT_LIST'
      message = |品目取得:{ lines( lt_material_list ) }件|
      plant   = lv_plant
    ) TO lt_log.

    IF lt_material_list IS INITIAL.
      io_response->set_data( VALUE tt_result( ) ).
      io_response->set_total_number_of_records( 0 ).
      RETURN.
    ENDIF.

    LOOP AT lt_material_list INTO DATA(ls_mat).  "#EC CI_SEL_NESTED "#EC CI_SROFC_NESTED
      process_supply_demand(
        EXPORTING
          iv_plant         = ls_mat-plant
          iv_material      = ls_mat-material
          iv_product_group = ls_mat-product_group
          iv_material_text = ls_mat-material_text
          iv_base_unit     = ls_mat-base_unit
        CHANGING
          ct_result          = lt_result
          ct_recursion_hist  = lt_recursion_hist
          ct_log              = lt_log ).
    ENDLOOP.

    " BOM階層順にソート（下位品目→上位品目、同一チェーンは連続出力）
    " チェーンルート：SG23→SG21の場合、SG21のチェーンルート=SG23となり隣接出力される
    TYPES: BEGIN OF ty_bom_level,
             material  TYPE matnr,
             bom_level TYPE i,
           END OF ty_bom_level.
    TYPES: BEGIN OF ty_chain_root,
             material   TYPE matnr,
             sort_chain TYPE matnr,
           END OF ty_chain_root.
    " [修正1] allocmrpelement: num10 → del12（非数値文字でのダンプ防止）
    TYPES: BEGIN OF ty_bom_sort,
             sort_chain        TYPE matnr,
             bom_level         TYPE i,
             requirementdate   TYPE dat00,
             allocmrpelement   TYPE del12,
             orig_idx          TYPE i,
           END OF ty_bom_sort.
    DATA: lt_bom_level     TYPE HASHED TABLE OF ty_bom_level WITH UNIQUE KEY material,
          lt_chain_root    TYPE HASHED TABLE OF ty_chain_root WITH UNIQUE KEY material,
          lt_bom_sort      TYPE STANDARD TABLE OF ty_bom_sort,
          lt_result_sorted TYPE tt_result,
          lv_bom_changed   TYPE abap_bool,
          lv_sort_idx      TYPE i.

    " 出力品目を全てレベル0・チェーンルート=自品目で初期化
    LOOP AT lt_result INTO DATA(ls_bom_res).
      TRY.
        INSERT VALUE ty_bom_level( material = ls_bom_res-material bom_level = 0 )
          INTO TABLE lt_bom_level.
      CATCH cx_sy_itab_duplicate_key. "#EC CAUGHT
      ENDTRY.
      TRY.
        INSERT VALUE ty_chain_root( material = ls_bom_res-material sort_chain = ls_bom_res-material )
          INTO TABLE lt_chain_root.
      CATCH cx_sy_itab_duplicate_key. "#EC CAUGHT
      ENDTRY.
    ENDLOOP.

    " AllocMaterialが他のL003品目の場合、上位品目として+1レベル付与（繰り返し）
    " [修正2] 循環参照（品目A↔品目B相互参照）での無限ループ防止：反復上限追加
    DATA lv_bom_iter TYPE i.
    lv_bom_changed = abap_true.
    WHILE lv_bom_changed = abap_true.
      lv_bom_iter += 1.
      IF lv_bom_iter > lines( lt_bom_level ).
        EXIT.
      ENDIF.
      lv_bom_changed = abap_false.
      LOOP AT lt_result INTO ls_bom_res.
        CHECK ls_bom_res-material <> ls_bom_res-allocmaterial.
        READ TABLE lt_bom_level WITH TABLE KEY material = ls_bom_res-allocmaterial
          ASSIGNING FIELD-SYMBOL(<fs_alloc_bom>).
        CHECK sy-subrc = 0.
        READ TABLE lt_bom_level WITH TABLE KEY material = ls_bom_res-material
          ASSIGNING FIELD-SYMBOL(<fs_mat_bom>).
        CHECK sy-subrc = 0.
        IF <fs_alloc_bom>-bom_level <= <fs_mat_bom>-bom_level.
          <fs_alloc_bom>-bom_level = <fs_mat_bom>-bom_level + 1.
          lv_bom_changed = abap_true.
        ENDIF.
      ENDLOOP.
    ENDWHILE.

    " チェーンルート伝播：下位品目のチェーンルートを上位品目に継承（繰り返し）
    " [修正2] 循環参照ガード：ノード数を超えた反復は打ち切り
    DATA lv_chain_iter TYPE i.
    lv_bom_changed = abap_true.
    WHILE lv_bom_changed = abap_true.
      lv_chain_iter += 1.
      IF lv_chain_iter > lines( lt_chain_root ).
        EXIT.
      ENDIF.
      lv_bom_changed = abap_false.
      LOOP AT lt_result INTO ls_bom_res.
        CHECK ls_bom_res-material <> ls_bom_res-allocmaterial.
        READ TABLE lt_chain_root WITH TABLE KEY material = ls_bom_res-allocmaterial
          ASSIGNING FIELD-SYMBOL(<fs_alloc_chain>).
        CHECK sy-subrc = 0.
        READ TABLE lt_chain_root WITH TABLE KEY material = ls_bom_res-material
          ASSIGNING FIELD-SYMBOL(<fs_mat_chain>).
        CHECK sy-subrc = 0.
        IF <fs_alloc_chain>-sort_chain <> <fs_mat_chain>-sort_chain.
          <fs_alloc_chain>-sort_chain = <fs_mat_chain>-sort_chain.
          lv_bom_changed = abap_true.
        ENDIF.
      ENDLOOP.
    ENDWHILE.

    " チェーンルート・BOMレベル・所要日付順でソートキーを作成
    DATA: lv_bom_lv_val   TYPE i,
          lv_chain_val    TYPE matnr.
    LOOP AT lt_result INTO ls_bom_res.
      lv_sort_idx += 1.
      READ TABLE lt_bom_level WITH TABLE KEY material = ls_bom_res-material
        ASSIGNING FIELD-SYMBOL(<fs_bom_lv>).
      lv_bom_lv_val = COND #( WHEN sy-subrc = 0 THEN <fs_bom_lv>-bom_level ELSE 0 ).
      READ TABLE lt_chain_root WITH TABLE KEY material = ls_bom_res-material
        ASSIGNING FIELD-SYMBOL(<fs_chain>).
      lv_chain_val  = COND #( WHEN sy-subrc = 0 THEN <fs_chain>-sort_chain ELSE ls_bom_res-material ).
      APPEND VALUE ty_bom_sort(
        sort_chain      = lv_chain_val
        bom_level       = lv_bom_lv_val
        requirementdate = ls_bom_res-requirementdate
        allocmrpelement = ls_bom_res-allocmrpelement
        orig_idx        = lv_sort_idx
      ) TO lt_bom_sort.
    ENDLOOP.

    SORT lt_bom_sort BY sort_chain ASCENDING bom_level ASCENDING requirementdate ASCENDING allocmrpelement ASCENDING.

    LOOP AT lt_bom_sort INTO DATA(ls_bom_sort).
      READ TABLE lt_result INDEX ls_bom_sort-orig_idx INTO DATA(ls_bom_sorted).
      APPEND ls_bom_sorted TO lt_result_sorted.
    ENDLOOP.
    lt_result = lt_result_sorted.

    APPEND VALUE #(
      step    = '5_FINAL'
      message = |出力結果:{ lines( lt_result ) }件|
      plant   = lv_plant
    ) TO lt_log.

    " [修正3] RAPページング適用（CX_RAP_QUERY_PAGE_SIZE_OVERRUN防止）
    DATA lv_total_recs TYPE int8.
    lv_total_recs = lines( lt_result ).
    DATA(lv_page_size) = lo_paging->get_page_size( ).
    DATA(lv_offset)    = lo_paging->get_offset( ).
    IF lv_offset > 0.
      DELETE lt_result FROM 1 TO COND i( WHEN lv_offset >= lv_total_recs
                                         THEN lv_total_recs
                                         ELSE lv_offset ).
    ENDIF.
    IF lv_page_size > 0 AND lines( lt_result ) > lv_page_size.
      DELETE lt_result FROM lv_page_size + 1.
    ENDIF.

    io_response->set_data( lt_result ).
    io_response->set_total_number_of_records( lv_total_recs ).

  ENDMETHOD.


  METHOD get_material_by_code.

    SELECT pp~plant,
           pp~product              AS material,
           prod~productgroup       AS product_group,
           text~productdescription AS material_text,
           pp~baseunit             AS base_unit
      FROM i_productplantbasic AS pp
      INNER JOIN i_product AS prod
        ON prod~product = pp~product
      INNER JOIN i_productdescription AS text
        ON text~product  = pp~product
       AND text~language = 'J'
      WHERE pp~product = @iv_material
        AND pp~plant   = @iv_plant
      INTO CORRESPONDING FIELDS OF TABLE @rt_list.

  ENDMETHOD.


  METHOD get_material_by_group.

    SELECT pp~plant,
           pp~product              AS material,
           prod~productgroup       AS product_group,
           text~productdescription AS material_text,
           pp~baseunit             AS base_unit
      FROM i_productplantbasic AS pp
      INNER JOIN i_product AS prod
        ON prod~product = pp~product
      INNER JOIN i_productdescription AS text
        ON text~product  = pp~product
       AND text~language = 'J'
      WHERE prod~productgroup = @iv_product_group
        AND pp~plant          = @iv_plant
      INTO CORRESPONDING FIELDS OF TABLE @rt_list.

  ENDMETHOD.


  METHOD process_supply_demand.

    DATA: lt_items  TYPE tt_sd_item,
          lt_supply TYPE tt_sd_item,
          lt_demand TYPE tt_sd_item,
          ls_item   TYPE ty_sd_item,
          ls_parent TYPE ty_material_list.

    " MRPPlanningSegment/MRPPlanningSegmentType は任意項目のため未指定→全セグメント取得
    " （公式仕様：MRPPlanningSegmentType は MRPPlanningSegment 指定時のみ必須）
    READ ENTITIES OF i_supplydemanditemtp
      ENTITY SupplyDemandItem
      EXECUTE GetItem
      FROM VALUE #( ( %param-material = iv_material
                      %param-mrparea  = iv_plant
                      %param-mrpplant = iv_plant ) )
      RESULT DATA(lt_sdi_result)
      FAILED DATA(lt_sdi_failed)
      REPORTED DATA(lt_sdi_reported).

    APPEND VALUE #(
      step    = 'SDI_COUNT'
      message = |GetItem結果:{ lines( lt_sdi_result ) }件|
      plant   = iv_plant
      material = iv_material
    ) TO ct_log.

    LOOP AT lt_sdi_result INTO DATA(ls_sdi).
      APPEND VALUE #(
        mrpplant                   = ls_sdi-%param-mrpplant
        material                   = ls_sdi-%param-material
        mrpelementcategory         = ls_sdi-%param-mrpelementcategory
        mrpelement                 = ls_sdi-%param-mrpelement
        mrpelementavailyorrqmtdate = ls_sdi-%param-mrpelementavailyorrqmtdate
        mrpelementopenquantity     = ls_sdi-%param-mrpelementopenquantity
        assembly                   = ls_sdi-%param-assembly
        productionplant            = ls_sdi-%param-productionplant
        mrpelementdocumenttype     = ls_sdi-%param-mrpelementdocumenttype
      ) TO lt_items.
    ENDLOOP.

    APPEND VALUE #(
      step     = '3_SD_ITEMS'
      message  = |所要量取得:{ lines( lt_items ) }件 Mat={ iv_material }|
      plant    = iv_plant
      material = iv_material
    ) TO ct_log.

    IF lt_items IS INITIAL.
      RETURN.
    ENDIF.

    DATA lv_wb_boundary_hit TYPE abap_bool.
    DATA lv_safety_stock_qty TYPE p LENGTH 13 DECIMALS 3.
    DATA lv_dbg_seq TYPE i.
    " 供給データと需要データをカテゴリで分割（SHは安全在庫のため先頭配置）
    " 供給 = 需要種別・SH以外のすべて（設計書「上記以外のレコード」に準拠）
    " WBは供給リストに含まれるが需要を消化しない（割当ループでスキップ）
    DATA lv_skip_assembly TYPE i.
    DATA lv_no_output     TYPE abap_bool.
    TYPES tt_mrp_cat TYPE HASHED TABLE OF delkz WITH UNIQUE KEY table_line.
    DATA(lt_output_supply_cats) = VALUE tt_mrp_cat( ( 'FE' ) ( 'PA' ) ( 'BE' ) ( 'BA' ) ( 'PP' ) ).
    DATA(lt_demand_cats)        = VALUE tt_mrp_cat( ( 'AR' ) ( 'SB' ) ( 'UR' ) ( 'U1' ) ).
    LOOP AT lt_items INTO ls_item.
      CASE ls_item-mrpelementcategory.
        WHEN 'SH'.
          INSERT ls_item INTO lt_demand INDEX 1.
        WHEN OTHERS.
          IF line_exists( lt_demand_cats[ table_line = ls_item-mrpelementcategory ] ).
            APPEND ls_item TO lt_demand.
          ELSE.
            APPEND ls_item TO lt_supply.
          ENDIF.
      ENDCASE.
    ENDLOOP.
    APPEND VALUE #(
      step     = '3_DEMAND'
      message  = COND #( WHEN lt_demand IS NOT INITIAL
                         THEN '需要データ:あり'
                         ELSE '需要データ:なし' )
      plant    = iv_plant
      material = iv_material
    ) TO ct_log.

    IF lt_demand IS INITIAL.
      RETURN.
    ENDIF.

    DATA: lv_supply_remain TYPE p LENGTH 13 DECIMALS 3,
          lv_demand_remain TYPE p LENGTH 13 DECIMALS 3,
          lv_alloc_qty     TYPE p LENGTH 13 DECIMALS 3.

    " 引当先品目テキスト一括取得（ループ内SELECT排除・パフォーマンス対策）
    TYPES: BEGIN OF ty_prod_text,
             product            TYPE matnr,
             productdescription TYPE maktx,
           END OF ty_prod_text.
    DATA lt_makt_range TYPE RANGE OF matnr.
    DATA lt_text_hash  TYPE HASHED TABLE OF ty_prod_text WITH UNIQUE KEY product.
    LOOP AT lt_demand INTO DATA(ls_d_tmp) WHERE assembly IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_d_tmp-assembly )
        TO lt_makt_range.
    ENDLOOP.
    SORT lt_makt_range BY low.
    DELETE ADJACENT DUPLICATES FROM lt_makt_range COMPARING low.
    IF lt_makt_range IS NOT INITIAL.
      SELECT product, productdescription  "#EC CI_SEL_NESTED
        FROM i_productdescription
        WHERE product  IN @lt_makt_range
          AND language = 'J'
        INTO CORRESPONDING FIELDS OF TABLE @lt_text_hash.
    ENDIF.

    " 引当先品目情報一括取得（再帰処理用・ループ内SELECT解消）
    TYPES: BEGIN OF ty_parent_key,
             assembly    TYPE matnr,
             alloc_plant TYPE werks_d,
           END OF ty_parent_key.
    DATA: lt_parent_keys TYPE STANDARD TABLE OF ty_parent_key WITH DEFAULT KEY,
          lt_parent_info TYPE SORTED TABLE OF ty_material_list
                         WITH UNIQUE KEY plant material.
    LOOP AT lt_demand INTO DATA(ls_d_key) WHERE assembly IS NOT INITIAL.
      APPEND VALUE #(
        assembly    = ls_d_key-assembly
        alloc_plant = COND #( WHEN ls_d_key-productionplant IS NOT INITIAL
                              THEN ls_d_key-productionplant
                              ELSE iv_plant )
      ) TO lt_parent_keys.
    ENDLOOP.
    SORT lt_parent_keys BY assembly alloc_plant.
    DELETE ADJACENT DUPLICATES FROM lt_parent_keys COMPARING assembly alloc_plant.
    IF lt_parent_keys IS NOT INITIAL.
      SELECT pp~plant,                    "#EC CI_SEL_NESTED
             pp~product              AS material,
             prod~productgroup       AS product_group,
             text~productdescription AS material_text,
             pp~baseunit             AS base_unit
        FROM i_productplantbasic AS pp
        INNER JOIN i_product AS prod
          ON prod~product = pp~product
        INNER JOIN i_productdescription AS text
          ON text~product  = pp~product
         AND text~language = 'J'
        FOR ALL ENTRIES IN @lt_parent_keys
        WHERE pp~product = @lt_parent_keys-assembly
          AND pp~plant   = @lt_parent_keys-alloc_plant
        INTO CORRESPONDING FIELDS OF TABLE @lt_parent_info.
    ENDIF.

    " 全供給種別の実計画日付を BAPI_MATERIAL_STOCK_REQ_LIST から取得
    TYPES: BEGIN OF ty_bapi_date,
             element_ind TYPE char2,
             mrpno       TYPE del12,
             avail_date  TYPE dat00,
           END OF ty_bapi_date.
    DATA: lt_bapi_dates TYPE HASHED TABLE OF ty_bapi_date WITH UNIQUE KEY element_ind mrpno,
          lt_bapi_items TYPE STANDARD TABLE OF bapi_mrp_items,
          lt_bapi_lines TYPE STANDARD TABLE OF bapi_mrp_ind_lines.

    IF lt_supply IS NOT INITIAL.
      CALL FUNCTION 'BAPI_MATERIAL_STOCK_REQ_LIST' "#EC CI_SEL_NESTED
        EXPORTING
          material_long = iv_material
          plant         = iv_plant
        TABLES
          mrp_items     = lt_bapi_items
          mrp_ind_lines = lt_bapi_lines.
      " 安全在庫（BAPI_MATERIAL_STOCK_REQ_LISTのSH行）を取得
      " I_SupplyDemandItemTPには安全在庫がMRP要素として含まれないため、在庫充当時に別途控除する
      READ TABLE lt_bapi_lines WITH KEY mrp_element_ind = 'SH' INTO DATA(ls_bapi_sh).
      IF sy-subrc = 0.
        lv_safety_stock_qty = abs( ls_bapi_sh-rec_reqd_qty ).
      ENDIF.
      LOOP AT lt_bapi_lines INTO DATA(ls_bapi_line)
        WHERE plus_minus = '+'.
        " ELEMNT_DATA 先頭の連続数字部分を要素番号として取得（種別非依存）
        " FE: "000001000020"（12桁）、BE: "4500000099/00010"（10桁+"/"）
        DATA(lv_elemnt_str) = CONV string( ls_bapi_line-elemnt_data ).
        FIND FIRST OCCURRENCE OF REGEX '[^0-9]' IN lv_elemnt_str MATCH OFFSET DATA(lv_pos).
        DATA(lv_mrpno) = CONV del12( COND string(
          WHEN sy-subrc = 0 AND lv_pos > 0 THEN lv_elemnt_str(lv_pos)
          ELSE lv_elemnt_str(12) ) ).
        SHIFT lv_mrpno LEFT DELETING LEADING '0'.
        IF lv_mrpno IS NOT INITIAL.
          INSERT VALUE #(
            element_ind = ls_bapi_line-mrp_element_ind
            mrpno       = lv_mrpno
            avail_date  = ls_bapi_line-avail_date )
            INTO TABLE lt_bapi_dates.
        ENDIF.
      ENDLOOP.
    ENDIF.

    " AR（従属引当）予約番号→製造指図番号マップを事前構築（I_ReservationDocumentHeader使用）
    TYPES: BEGIN OF ty_rsnum_map,
             reservation TYPE rsnum,
             orderid     TYPE aufnr,
           END OF ty_rsnum_map.
    DATA lt_rsnum_map   TYPE HASHED TABLE OF ty_rsnum_map WITH UNIQUE KEY reservation.
    DATA lt_rsnum_range TYPE RANGE OF rsnum.
     LOOP AT lt_demand INTO DATA(ls_d_ar) WHERE assembly IS NOT INITIAL
                                            AND mrpelementcategory = 'AR'.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = CONV rsnum( ls_d_ar-mrpelement ) )
        TO lt_rsnum_range.
    ENDLOOP.
    SORT lt_rsnum_range BY low.
    DELETE ADJACENT DUPLICATES FROM lt_rsnum_range COMPARING low.
    IF lt_rsnum_range IS NOT INITIAL.
      SELECT reservation, orderid
        FROM i_reservationdocumentheader
        WHERE reservation IN @lt_rsnum_range
        INTO CORRESPONDING FIELDS OF TABLE @lt_rsnum_map.
    ENDIF.
    " SB（従属所要量）予約番号→計画手配番号マップを事前構築（A_PlannedOrderComponent使用）
    " I_ReservationDocumentHeaderはAUFNR（製造指図）のみ公開しPLNUM（計画手配）を公開していないため、
    " 計画手配番号を公開しているA_PlannedOrderComponent（リリース済み公開API）を使用する
    TYPES: BEGIN OF ty_plnum_map,
             reservation TYPE rsnum,
             plnum       TYPE plnum,
           END OF ty_plnum_map.
    DATA lt_plnum_map   TYPE HASHED TABLE OF ty_plnum_map WITH UNIQUE KEY reservation.
    DATA lt_plnum_range TYPE RANGE OF rsnum.
    LOOP AT lt_demand INTO DATA(ls_d_sb) WHERE assembly IS NOT INITIAL
                                            AND mrpelementcategory = 'SB'.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = CONV rsnum( ls_d_sb-mrpelement ) )
        TO lt_plnum_range.
    ENDLOOP.
    SORT lt_plnum_range BY low.
    DELETE ADJACENT DUPLICATES FROM lt_plnum_range COMPARING low.
    IF lt_plnum_range IS NOT INITIAL.
      SELECT DISTINCT reservation, plannedorder AS plnum  "#EC CI_SEL_NESTED
        FROM a_plannedordercomponent
        WHERE reservation   IN @lt_plnum_range
          AND material      = @iv_material
          AND plant         = @iv_plant
          AND plannedorder <> @space
        INTO CORRESPONDING FIELDS OF TABLE @lt_plnum_map.
    ENDIF.
    " 供給データをBAPI実日付昇順にソート（PA/FE混在時に早い日付の供給を優先処理）
    LOOP AT lt_supply ASSIGNING FIELD-SYMBOL(<ls_sup>).
      DATA(lv_sup_sort_key) = <ls_sup>-mrpelement.
      SHIFT lv_sup_sort_key LEFT DELETING LEADING '0'.
      READ TABLE lt_bapi_dates WITH TABLE KEY
        element_ind = <ls_sup>-mrpelementcategory
        mrpno       = lv_sup_sort_key
        INTO DATA(ls_bapi_sort).
      IF sy-subrc = 0 AND ls_bapi_sort-avail_date IS NOT INITIAL.
        <ls_sup>-mrpelementavailyorrqmtdate = ls_bapi_sort-avail_date.
      ENDIF.
    ENDLOOP.
     " WBは期首在庫として最優先（MD04の在庫行に相当）
    LOOP AT lt_supply ASSIGNING FIELD-SYMBOL(<ls_wb>) WHERE mrpelementcategory = 'WB'.
      CLEAR <ls_wb>-mrpelementavailyorrqmtdate.
      " 安全在庫を在庫の充当可能量から控除（I_SupplyDemandItemTPには安全在庫がMRP要素として
      " 含まれないため、BAPI_MATERIAL_STOCK_REQ_LISTのSH行から取得した数量を別途差し引く）
      <ls_wb>-mrpelementopenquantity = <ls_wb>-mrpelementopenquantity - lv_safety_stock_qty.
      IF <ls_wb>-mrpelementopenquantity < 0.
        <ls_wb>-mrpelementopenquantity = 0.
      ENDIF.
    ENDLOOP.
    SORT lt_supply BY mrpelementavailyorrqmtdate ASCENDING.
    " SHは需要の先頭として最優先処理、その他需要は日付昇順（MD04累計残高ロジックに準拠）
    LOOP AT lt_demand ASSIGNING FIELD-SYMBOL(<ls_sh_d>) WHERE mrpelementcategory = 'SH'.
      CLEAR <ls_sh_d>-mrpelementavailyorrqmtdate.
    ENDLOOP.
    SORT lt_demand BY mrpelementavailyorrqmtdate ASCENDING.
    " 最初のFE/PA等計画供給日を取得（WBの充当範囲確定）
    DATA lv_first_planned_date TYPE dat00.
    LOOP AT lt_supply INTO DATA(ls_supply_check)
                      WHERE mrpelementcategory <> 'WB'.
      IF line_exists( lt_output_supply_cats[ table_line = ls_supply_check-mrpelementcategory ] ).
        lv_first_planned_date = ls_supply_check-mrpelementavailyorrqmtdate.
        EXIT.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_supply INTO DATA(ls_supply).
      lv_supply_remain = ls_supply-mrpelementopenquantity.

      " 所要日付：全供給種別で BAPI の AVAIL_DATE を優先使用
      DATA(lv_req_date) = ls_supply-mrpelementavailyorrqmtdate.
      DATA(lv_supply_key) = ls_supply-mrpelement.
      SHIFT lv_supply_key LEFT DELETING LEADING '0'.
      READ TABLE lt_bapi_dates WITH TABLE KEY
        element_ind = ls_supply-mrpelementcategory
        mrpno       = lv_supply_key
        INTO DATA(ls_bapi_date).
      IF sy-subrc = 0 AND ls_bapi_date-avail_date IS NOT INITIAL.
        lv_req_date = ls_bapi_date-avail_date.
      ENDIF.

      LOOP AT lt_demand INTO DATA(ls_demand).
        CHECK lv_supply_remain > 0.
        CLEAR lv_no_output.
        CLEAR lv_wb_boundary_hit.
        " WB：最初のFE/PA供給日以降の需要は、境界をまたぐ最初の1件にのみ残数量を充当し、
        " 充当後は在庫を打ち切る（それ以降の需要には従来通りFE/PA等が充当）
        IF ls_supply-mrpelementcategory = 'WB' AND
           ls_demand-assembly IS NOT INITIAL AND
           lv_first_planned_date IS NOT INITIAL AND
           ls_demand-mrpelementavailyorrqmtdate >= lv_first_planned_date.
          lv_wb_boundary_hit = abap_true.
        ENDIF.
        " 引当先品目コード（Assembly）が空の場合
        IF ls_demand-assembly IS INITIAL.
          " U1/UR（在庫移送オーダ/引当）は引当先品目 = 処理中品目として出力
          " I_SupplyDemandItemTPがU1/URのAssemblyを空で返すため、現在品目を設定する
          IF ls_demand-mrpelementcategory = 'U1' OR
             ls_demand-mrpelementcategory = 'UR'.
            ls_demand-assembly = iv_material.
          ELSE.
            " SH等はWBのみ充当可能（MD04論理：安全在庫は在庫で充当）
            IF ls_supply-mrpelementcategory = 'WB'.
              lv_no_output = abap_true.
            ELSE.
              lv_skip_assembly = lv_skip_assembly + 1.
              CONTINUE.
            ENDIF.
          ENDIF.
        ENDIF.

        lv_demand_remain = ABS( ls_demand-mrpelementopenquantity ).
        CHECK lv_demand_remain > 0.

        IF lv_demand_remain <= lv_supply_remain.
          lv_alloc_qty                    = lv_demand_remain.
          lv_supply_remain                = lv_supply_remain - lv_alloc_qty.
          ls_demand-mrpelementopenquantity = 0.
        ELSE.
          lv_alloc_qty                    = lv_supply_remain.
          lv_supply_remain                = 0.
          ls_demand-mrpelementopenquantity = lv_demand_remain - lv_alloc_qty.
        ENDIF.

        MODIFY lt_demand FROM ls_demand.
        " WB：境界をまたぐ需要に1回充当した直後は在庫を打ち切り、以降の需要へは充当しない
        IF lv_wb_boundary_hit = abap_true.
          lv_supply_remain = 0.
        ENDIF.
        " SH等（引当先品目なし）は供給量を消費するが出力・再帰はスキップ
        IF lv_no_output = abap_true.
          CONTINUE.
        ENDIF.

        " 出力対象外の供給種別（WB等）は数量計算に含めるが出力・再帰処理はスキップ
        IF NOT line_exists( lt_output_supply_cats[ table_line = ls_supply-mrpelementcategory ] ). 
          CONTINUE.
        ENDIF.

        " 供給MRP要素番号
        DATA(lv_supply_no) = ls_supply-mrpelement.

        " 引当先情報
        DATA(lv_alloc_type)   = convert_alloc_element_type( ls_demand-mrpelementcategory ).
        DATA(lv_alloc_mrp_no) = ls_demand-mrpelement.
        " AR種別：予約番号→製造指図番号への変換を試みる（該当なしの場合は元の値を使用）
        " ARのみ真の予約(RSNUM)を持つため対象。SB/UR/U1/SHは変換対象外（元の値をそのまま使用）
        IF ls_demand-mrpelementcategory = 'AR'.
          READ TABLE lt_rsnum_map WITH TABLE KEY
            reservation = CONV rsnum( lv_alloc_mrp_no )
            INTO DATA(ls_rsnum_map).
          IF sy-subrc = 0 AND ls_rsnum_map-orderid IS NOT INITIAL.
            lv_alloc_mrp_no = CONV del12( ls_rsnum_map-orderid ).
            SHIFT lv_alloc_mrp_no LEFT DELETING LEADING '0'.
          ENDIF.
        " SB種別：予約番号→計画手配番号への変換を試みる（該当なしの場合は元の値を使用）
        ELSEIF ls_demand-mrpelementcategory = 'SB'.
          READ TABLE lt_plnum_map WITH TABLE KEY
            reservation = CONV rsnum( lv_alloc_mrp_no )
            INTO DATA(ls_plnum_map).
          IF sy-subrc = 0 AND ls_plnum_map-plnum IS NOT INITIAL.
            lv_alloc_mrp_no = CONV del12( ls_plnum_map-plnum ).
            SHIFT lv_alloc_mrp_no LEFT DELETING LEADING '0'.
          ENDIF.
        ENDIF.
        DATA(lv_alloc_plant)  = COND werks_d(
          WHEN ls_demand-productionplant IS NOT INITIAL THEN ls_demand-productionplant
          ELSE iv_plant ).

        " 引当先品目テキスト（自己参照の場合は処理中品目テキスト、それ以外は一括取得済みから参照）
        DATA(lv_alloc_mat_text) = CONV maktx( '' ).
        IF ls_demand-assembly = iv_material.
          lv_alloc_mat_text = iv_material_text.
        ELSE.
          READ TABLE lt_text_hash WITH TABLE KEY product = ls_demand-assembly
            ASSIGNING FIELD-SYMBOL(<fs_text>).
          IF sy-subrc = 0.
            lv_alloc_mat_text = <fs_text>-productdescription.
          ENDIF.
        ENDIF.

        " 重複チェック
        READ TABLE ct_result WITH KEY
          plant           = iv_plant
          mrpelement      = lv_supply_no
          material        = iv_material
          allocmrpelement = lv_alloc_mrp_no
          allocmaterial   = ls_demand-assembly
          TRANSPORTING NO FIELDS.
        IF sy-subrc = 0. CONTINUE. ENDIF.

        " 出力結果格納
        APPEND VALUE #(
          plant                      = iv_plant
          mrpelementtype             = ls_supply-mrpelementcategory
          mrpelement                 = lv_supply_no
          mrpelementdescription      = get_mrp_element_description(
                                         iv_element_ind = ls_supply-mrpelementcategory
                                         iv_order_type  = ls_supply-mrpelementdocumenttype )
          material                   = iv_material
          productgroup               = iv_product_group
          materialtext               = iv_material_text
          requirementdate            = lv_req_date
          allocmrpelementtype        = lv_alloc_type
          allocmrpelementdescription = get_mrp_element_description(
                                         iv_element_ind = lv_alloc_type
                                         iv_order_type  = ls_demand-mrpelementdocumenttype )
          allocmrpelement            = lv_alloc_mrp_no
          allocmaterial              = ls_demand-assembly
          allocmaterialtext          = lv_alloc_mat_text
          allocquantity              = lv_alloc_qty
          quantityunit               = iv_base_unit
          allocrequirementdate       = ls_demand-mrpelementavailyorrqmtdate
        ) TO ct_result.

        " 上位品目の再帰処理
        READ TABLE ct_recursion_hist WITH KEY
          plant            = iv_plant
          material         = iv_material
          mrpelement       = lv_supply_no
          alloc_plant      = lv_alloc_plant
          alloc_material   = ls_demand-assembly
          alloc_mrpelement = lv_alloc_mrp_no
          TRANSPORTING NO FIELDS.

        IF sy-subrc <> 0.
          APPEND VALUE #(
            plant            = iv_plant
            material         = iv_material
            mrpelement       = lv_supply_no
            alloc_plant      = lv_alloc_plant
            alloc_material   = ls_demand-assembly
            alloc_mrpelement = lv_alloc_mrp_no
          ) TO ct_recursion_hist.

          CLEAR ls_parent.
          READ TABLE lt_parent_info INTO ls_parent
            WITH TABLE KEY plant    = lv_alloc_plant
                           material = ls_demand-assembly.

          IF sy-subrc = 0.
            process_supply_demand(
              EXPORTING
                iv_plant         = lv_alloc_plant
                iv_material      = ls_parent-material
                iv_product_group = ls_parent-product_group
                iv_material_text = ls_parent-material_text
                iv_base_unit     = ls_parent-base_unit
              CHANGING
                ct_result         = ct_result
                ct_recursion_hist = ct_recursion_hist
                ct_log            = ct_log ).
          ENDIF.
        ENDIF.
    ENDLOOP.
   ENDLOOP.
    APPEND VALUE #(
      step     = '4_RESULT'
      message  = |供給:{ lines( lt_supply ) } 需要:{ lines( lt_demand ) } Skip:{ lv_skip_assembly }|
      plant    = iv_plant
      material = iv_material
    ) TO ct_log.

  ENDMETHOD.


  METHOD build_log_result.

    LOOP AT it_log INTO DATA(ls_log).
      APPEND VALUE #(
        plant                 = ls_log-plant
        mrpelementtype        = 'ZZ'
        mrpelement            = ls_log-step
        mrpelementdescription = ls_log-message
        material              = ls_log-material
      ) TO rt_result.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_mrp_element_description.

    " PP（計画独立所要量）はオーダ種別コードを説明として使用
    IF iv_element_ind = 'PP'.
      rv_description = iv_order_type.
      RETURN.
    ENDIF.

    " DELKZ ドメイン値テキストを取得（DD07Tは完全バッファリングのためDB負荷なし）
    " 出力テキストは日本語固定のため、ログオンセッション言語(sy-langu)ではなく'J'固定で取得する
    SELECT SINGLE ddtext
      FROM dd07t
      WHERE domname    = 'DELKZ'
        AND domvalue_l = @iv_element_ind
        AND ddlanguage = 'J'
        AND as4local   = 'A'
      INTO @rv_description.

    IF sy-subrc <> 0 OR rv_description IS INITIAL.
      rv_description = iv_element_ind.
    ENDIF.

  ENDMETHOD.


  METHOD convert_alloc_element_type.

    rv_converted = SWITCH #( iv_element_ind
      WHEN 'AR' THEN 'FE'
      WHEN 'SB' THEN 'PA'
      WHEN 'U1' THEN 'BE'
      WHEN 'UR' THEN 'BA'
      ELSE            iv_element_ind ).

  ENDMETHOD.

ENDCLASS.
