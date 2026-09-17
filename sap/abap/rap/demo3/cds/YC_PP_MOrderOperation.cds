@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manufacturing Order Operation'
@VDM.viewType: #CONSUMPTION

define view entity YC_PP_MOrderOperation
  as select from YI_PP_MOrderOperation
{
  key ManufacturingOrder,
  key ManufacturingOrderCategory,
  key ManufacturingOrderOperation_2,
      MfgOrderOperationText,
      WorkCenter,
      WorkCenterText,
      OperLstSchedldExecStrtDte,
      OpLtstSchedldExecStrtDte,
      OperationControlProfile,
      ExtProcgOperationHasSubcontrg,
      PurchasingInfoRecord,
      ProductionPlant,
      ManufacturingOrderType,
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
