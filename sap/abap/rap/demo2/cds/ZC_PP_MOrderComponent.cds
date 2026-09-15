@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manufacturing Order Component'
@VDM.viewType: #CONSUMPTION

define view entity ZC_PP_MOrderComponent
  as select from ZI_PP_MOrderComponent
{
  key ManufacturingOrder,
  key Material,
      ProductName,
      Batch,
      Prequiredquantity,
      BaseUnit,
      SupplierBatch,
      ProductionOrderOperation,
      StorageLocation,
      ReservationItem,
      ProductionPlant,
      ManufacturingOrderType,
      ManufacturingOrderCategory,
      @Semantics.systemDateTime.lastChangedAt: true
      case
          when LastChangeDate is null
            or substring(LastChangeDate,1,4) = '0000'
          then cast( dats_tims_to_tstmp(
                  CreationDate,
                  CreationTime,
                  abap_system_timezone( $session.client, 'NULL' ),
                  $session.client,
                  'NULL'
               )  as timestampl )
          else cast( dats_tims_to_tstmp(
                  LastChangeDate,
                  LastChangeTime,
                  abap_system_timezone( $session.client, 'NULL' ),
                  $session.client,
                  'NULL'
               ) as timestampl )
      end as LastChangeTimestamp
}
