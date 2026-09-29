@EndUserText.label: 'Role for ZC_EC_PrdCostByOrdAndItem'
@MappingRole: true
define role ZC_EC_PRDCOSTBYORDANDITEM {
  grant
    select
      on
        ZC_EC_PRDCOSTBYORDANDITEM
          where
        // check K_PKSA for Product Cost Collector
         ( Plant ) = aspect pfcg_auth ( K_PKSA, WERKS, ACTVT = '03' )
         or
        // check C_AFKO_AWA for PP Order
         ( OrderCategory, OrderType, Plant ) = aspect pfcg_auth ( C_AFKO_AWA, AUTYP, AUFART, WERKS, ACTVT = '03' )
        ;
}
