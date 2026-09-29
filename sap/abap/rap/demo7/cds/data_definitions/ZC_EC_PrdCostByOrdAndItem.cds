@AbapCatalog.sqlViewName: 'ZECVPRDCSTORDITM'
@ClientHandling.type: #CLIENT_DEPENDENT
@ClientHandling.algorithm: #SESSION_VARIABLE
@VDM.viewType: #CONSUMPTION
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Custom: CO Product Cost By Ord./Items'
@ObjectModel.usageType.serviceQuality: #D
@ObjectModel.usageType.sizeCategory: #XXL
@ObjectModel.usageType.dataClass: #MIXED
@Metadata.allowExtensions: true
@AccessControl.personalData.blocking: #BLOCKED_DATA_EXCLUDED
@Search.searchable: false
define view ZC_EC_PrdCostByOrdAndItem
  with parameters
    P_FromFiscalYearPeriod : fincs_fromfiscalyearperiod,
    P_ToFiscalYearPeriod   : fincs_fromfiscalyearperiod,
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_LANGUAGE
    P_Language             : sylangu,
    @Consumption.hidden: true
    @Consumption.defaultValue: '20'
    P_CurrencyRole         : co_ctyp
  as select from I_COProductCostByOrderAndItem(
    P_FromFiscalYearPeriod  : $parameters.P_FromFiscalYearPeriod,
    P_ToFiscalYearPeriod    : $parameters.P_ToFiscalYearPeriod,
    P_PlanningCategory      : '000',
    P_ResultAnalysisVersion : '000',
    P_ValuationType         : ''
  ) _CostByOrderAndItem
{
  key OrderID,
  key cast(ltrim(OrderItem, '0') as fco_order_item preserving type) as OrderItem,
  OrderInternalID,
  ObjectInternalID,
  OrderType,
  OrderCategory,
  ExternalOrder,
  OrderDescription,
  Plant,
  ControllingArea,
  CompanyCode,
  BusinessArea,
  ValidityDate,
  ProfitCenter,
  ResponsibleCostCenter,
  SalesOrder,
  MfgOrderHasMultipleItems,
  ActualCostsCostingVariant,
  _CostByOrderAndItem.CreatedByUser,
  _CostByOrderAndItem.CreationDate,
  _CostByOrderAndItem.LastChangedByUser,
  _CostByOrderAndItem.LastChangeDate,
  TechnicalCompletionDate,
  Material,
  ValuationClass,
  cast(MRPPlant as fis_co_pwerk preserving type) as MRPPlant,
  cast(StorageLocation as fis_lgort_d preserving type) as StorageLocation,
  ProductionVersion,
  ScheduledBasicEndDate,
  ScheduledReleaseDate,
  ActualStartDate,
  ConfirmedEndDate,
  ActualReleasedDate,
  ControllingObjectStatus,
  @Semantics.currencyCode: true
  cast(
    case $parameters.P_CurrencyRole
      when '20' then ControllingAreaCurrency
      else CompanyCodeCurrency
    end as cficuky preserving type
  ) as DisplayCurrency,
  @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
  cast(
    case $parameters.P_CurrencyRole
      when '20' then ActlCostInCtrlgAreaCrcy
      else ActlCostInCoCodeCrcy
    end as fis_actlcost_in_dspcrcy preserving type
  ) as ActlCostInDspCrcy,
  @Semantics: { quantity : {unitOfMeasure: 'ProductionUnit'} }
  PlanOutputQuantity,
  @Semantics: { quantity : {unitOfMeasure: 'ProductionUnit'} }
  ActualOutputQuantity
}
