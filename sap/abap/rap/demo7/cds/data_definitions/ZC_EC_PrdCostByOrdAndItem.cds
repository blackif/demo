@AbapCatalog.sqlViewName: 'ZECVPRDCSTORDITM'
@ClientHandling.type: #CLIENT_DEPENDENT
@ClientHandling.algorithm: #SESSION_VARIABLE
@VDM.viewType:  #CONSUMPTION
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
//@AccessControl.privilegedAssociations:  [ '_CreatedByContactCard', '_LastChangedByUserContactCard' ]
@EndUserText.label: 'Custom: CO Product Cost By Ord./Items'
@ObjectModel.usageType.serviceQuality: #D
@ObjectModel.usageType.sizeCategory: #XXL
@ObjectModel.usageType.dataClass: #MIXED
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@AccessControl.personalData.blocking: #BLOCKED_DATA_EXCLUDED
@Search.searchable: false

define view ZC_EC_PrdCostByOrdAndItem
  with parameters
    P_FromFiscalYearPeriod : fincs_fromfiscalyearperiod,
    P_ToFiscalYearPeriod   : fincs_tofiscalyearperiod,
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_LANGUAGE
    P_Language             : sylangu,
    @Consumption.hidden: true
    @Consumption.defaultValue: '20'
    P_CurrencyRole         : co_ctyp
  as select from I_COProductCostByOrderAndItem(
                   P_FromFiscalYearPeriod    : $parameters.P_FromFiscalYearPeriod,
                   P_ToFiscalYearPeriod      : $parameters.P_ToFiscalYearPeriod,
                   P_PlanningCategory        : '000',
                   P_ResultAnalysisVersion   : '000',
                   P_ValuationType           : ''
                   ) _CostByOrderAndItem
  association [0..1] to I_Product         as _Product               on  $projection.Material = _Product.Product
  association [0..1] to I_ProductionOrder as _ProductionOrder       on  $projection.OrderID = _ProductionOrder.ProductionOrder
  association [0..1] to I_Plant           as _Plant                 on  $projection.Plant = _Plant.Plant
  association [1..1] to I_CompanyCode     as _CompanyCode           on  $projection.CompanyCode = _CompanyCode.CompanyCode
  association [1..1] to I_ControllingArea as _ControllingArea       on  $projection.ControllingArea = _ControllingArea.ControllingArea
  association [0..1] to I_OrderCategory   as _OrderCategory         on  $projection.OrderCategory = _OrderCategory.OrderCategory
  association [0..1] to I_OrderType       as _OrderType             on  $projection.OrderType = _OrderType.OrderType
  association [0..1] to I_StorageLocation as _StorageLocation       on  $projection.MRPPlant        = _StorageLocation.Plant
                                                                    and $projection.StorageLocation = _StorageLocation.StorageLocation
  association [0..1] to I_CostCenter      as _ResponsibleCostCenter on  $projection.ControllingArea       =  _ResponsibleCostCenter.ControllingArea
                                                                    and $projection.ResponsibleCostCenter = _ResponsibleCostCenter.CostCenter
                                                                    and $projection.ValidityDate          >= _ResponsibleCostCenter.ValidityStartDate
                                                                    and $projection.ValidityDate          <= _ResponsibleCostCenter.ValidityEndDate
  association [0..1] to I_ProfitCenter    as _ProfitCenter          on  $projection.ControllingArea =  _ProfitCenter.ControllingArea
                                                                    and $projection.ProfitCenter    =  _ProfitCenter.ProfitCenter
                                                                    and $projection.ValidityDate    >= _ProfitCenter.ValidityStartDate
                                                                    and $projection.ValidityDate    <= _ProfitCenter.ValidityEndDate
{
      @Consumption.valueHelpDefinition: [{
          entity: {
          name: 'I_PRODUCTIONORDERSTDVH',
          element: 'ProductionOrder'
          },
        useForValidation: true
        }]
      @UI.selectionField: [{ position: 20 }]
      @UI.lineItem: [
        {
          position: 1,
          type: #WITH_INTENT_BASED_NAVIGATION,
                      semanticObjectAction: 'analyzeProductionCost'
        }
      ]
      @UI.fieldGroup: [{
      qualifier: 'GeneratedGroup'
            ,
            type: #WITH_INTENT_BASED_NAVIGATION,
            semanticObjectAction: 'analyzeProductionCost'
          }]
      @Consumption.semanticObject: 'ProductionOrder'
      @UI.facet: [
        {
            id:'Detail',
            type: #FIELDGROUP_REFERENCE,
            targetQualifier: 'GeneratedGroup',
            label: 'Header',
            position: 10
       }]
  key OrderID,
  key cast(ltrim(OrderItem, '0') as fco_order_item preserving type )                                                as OrderItem,

      @UI.hidden: true
      OrderInternalID,
      @UI.hidden: true
      ObjectInternalID,

      @ObjectModel.text.element: [ 'OrderTypeName' ]
      @UI.textArrangement: #TEXT_LAST
      OrderType,
      _OrderType._Text[1: Language = $parameters.P_Language].OrderTypeName                                          as OrderTypeName,
      @ObjectModel.text.element: [ 'OrderCategoryName' ]
      @UI.textArrangement: #TEXT_LAST
      OrderCategory,
      _OrderCategory._Text[1: Language = $parameters.P_Language].OrderCategoryName                                  as OrderCategoryName,
      ExternalOrder,
      OrderDescription,

      @Consumption.valueHelpDefinition: [{
          entity: {
          name: 'I_PlantStdVH',
          element: 'Plant'
          },
        useForValidation: true
        }]
      @UI.selectionField: [{ position: 10 }]
      @UI.fieldGroup: [{qualifier: 'GeneratedGroup'}]
      @UI.facet: [
        {
            id:'Detail',
            type: #FIELDGROUP_REFERENCE,
            targetQualifier: 'GeneratedGroup',
            label: 'Header',
            position: 10
       }]
      @ObjectModel.text.element: [ 'PlantlName' ]
      @UI.textArrangement: #TEXT_LAST
      @UI.lineItem: [{position: 2}]
      Plant,
      _Plant.PlantName as PlantlName,
      @Semantics.unitOfMeasure:true
      cast(_CostByOrderAndItem.BaseUnit as fis_meinh preserving type ) as ProductionUnit,

      ControllingArea,
      @UI.selectionField: [{ position: 80 }]
      @ObjectModel.text.element: [ 'CompanyCodeName' ]
      @UI.textArrangement: #TEXT_LAST
      CompanyCode,
      _CompanyCode.CompanyCodeName as CompanyCodeName,
      @UI.hidden: true
      BusinessArea,

      @Consumption.hidden: true
      _ProfitCenter.ValidityEndDate as ProfitCenterValidityEndDate,
      @Consumption.hidden: true
      ValidityDate,

      @Consumption.valueHelpDefinition: [{
        entity: {
          name: 'I_PROFITCENTERSTDVH',
          element: 'ProfitCenter'
        }, additionalBinding: [{
          element: 'ControllingArea',
          localElement: 'ControllingArea'
        }, {
          element: 'ValidityEndDate',
          localElement: 'ProfitCenterValidityEndDate'
        }],
      useForValidation: true
      }]
      @UI.selectionField: [{ position: 70 }]
      @ObjectModel.text.element: [ 'ProfitCenterName' ]
      @UI.textArrangement: #TEXT_LAST
      ProfitCenter,
      _ProfitCenter._Text[1:Language= $parameters.P_Language].ProfitCenterName as ProfitCenterName,
      @UI.hidden: true
      ResponsibleCostCenter,
      SalesOrder,

      MfgOrderHasMultipleItems,

      @UI.hidden: true
      ActualCostsCostingVariant,

      _CostByOrderAndItem.CreatedByUser,
      _CostByOrderAndItem.CreationDate,
      _CostByOrderAndItem.LastChangedByUser,
      _CostByOrderAndItem.LastChangeDate,
      TechnicalCompletionDate,

      @ObjectModel.text.element: [ 'MaterialName' ]
      @UI.textArrangement: #TEXT_LAST
      @Consumption.valueHelpDefinition: [{
          entity: {
          name: 'I_ProductStdVH',
          element: 'Product'
          },
        useForValidation: true
        }]
      @UI.selectionField: [{ position: 25 }]
      @UI.lineItem: [{position: 3}]
      Material,

      @Semantics.text: true
      cast(_Product._Text[1: Language = $parameters.P_Language].ProductName as fis_material_text preserving type ) as MaterialName,

      _Product.ZZ1_COSTC_MANUz1_PRD,
      @Consumption.valueHelpDefinition: [{
        entity: {
          name: 'I_COSTCENTERSTDVH',
          element: 'CostCenter'
        }, additionalBinding: [{
          element: 'ControllingArea',
          localElement: 'ZZ1_COSTC_MANUz1_PRD'
        }, {
          element: 'ValidityEndDate',
          localElement: 'ZZ1_COSTC_MANUz3_PRD'
        }],
      useForValidation: true
      }]
      @UI.selectionField: [{ position: 30 }]
      @UI.lineItem: [{position: 4}]
      @ObjectModel.text.element: [ 'COSTC_CostCenterName' ]
      @UI.textArrangement: #TEXT_LAST
      _Product.ZZ1_COSTC_MANUz2_PRD,
      _Product._ZZ1_COSTC_MANU_PRD._Text[1:Language = $parameters.P_Language].CostCenterName as COSTC_CostCenterName,
      _Product.ZZ1_COSTC_MANUz3_PRD,

      _Product.ZZ1_DEP_MANUz1_PRD,
      @ObjectModel.text.element: [ 'DEP_CostCenterName' ]
      @UI.textArrangement: #TEXT_LAST
      _Product.ZZ1_DEP_MANUz2_PRD,
      _Product._ZZ1_DEP_MANU_PRD._Text[1:Language = $parameters.P_Language].CostCenterName as DEP_CostCenterName,
      _Product.ZZ1_DEP_MANUz3_PRD,

      _Product.ZZ1_DEPGP_MANUz1_PRD,
      @ObjectModel.text.element: [ 'DEPGP_CostCenterName' ]
      @UI.textArrangement: #TEXT_LAST
      _Product.ZZ1_DEPGP_MANUz2_PRD,
      _Product._ZZ1_DEPGP_MANU_PRD._Text[1:Language = $parameters.P_Language].CostCenterName as DEPGP_CostCenterName,
      ValuationClass,
      cast(MRPPlant as fis_co_pwerk preserving type ) as MRPPlant,

      @ObjectModel.text.element: [ 'StorageLocationName' ]
      @UI.textArrangement: #TEXT_LAST
      cast(StorageLocation as fis_lgort_d preserving type ) as StorageLocation,
      _StorageLocation.StorageLocationName as StorageLocationName,
      ProductionVersion,

      @UI.hidden: true
      ScheduledBasicEndDate,
      @UI.hidden: true
      ScheduledReleaseDate,
      ActualStartDate,
      ConfirmedEndDate,
      ActualReleasedDate,

      @Consumption.valueHelpDefinition: [{
          entity: {
          name: 'ZC_EC_PrdOrdStatusVH',
          element: 'ControllingObjectStatus'
          },
        useForValidation: true
        }]
      @Consumption.filter: {selectionType: #SINGLE,multipleSelections: false}
      @UI.selectionField: [{ position: 60 }]
      ControllingObjectStatus,

      @Semantics.currencyCode: true
      cast( case $parameters.P_CurrencyRole
          when '20' then ControllingAreaCurrency
          else CompanyCodeCurrency
      end as cficuky preserving type ) as DisplayCurrency,

      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then CreditActlCostInCtrlgAreaCrcy
          else CreditActlCostInCoCodeCrcy
      end as fis_cr_actlcost_in_dspcrcy preserving type ) as CreditActlCostInDspCrcy,

      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then DebitActlCostInCtrlgAreaCrcy
          else DebitActlCostInCoCodeCrcy
      end as fis_dr_actlcost_in_dspcrcy preserving type ) as DebitActlCostInDspCrcy,

      @DefaultAggregation: #SUM
      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      @UI.lineItem: [{position: 10}]
      @UI.fieldGroup: [{qualifier: 'DetailGroup'}]
      @UI.facet: [
        {
            id:'detail',
            type: #FIELDGROUP_REFERENCE,
            targetQualifier: 'DetailGroup',
            label: 'Detail',
            position: 1000
       }]
      cast( case $parameters.P_CurrencyRole
          when '20' then ActlCostInCtrlgAreaCrcy
          else ActlCostInCoCodeCrcy
      end as fis_actlcost_in_dspcrcy preserving type ) as ActlCostInDspCrcy,

      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then DebitActlVarblCostInCOCrcy
          else DebitActlVarblCostInCoCodeCrcy
      end as fis_dr_actlvarblcost_indspcrcy preserving type ) as DebitActlVarblCostInDspCrcy,

      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then CrdtActlVarblCostInCOCrcy
          else CreditActlVarblCostInCCCrcy
      end as fis_cr_actlvarblcost_indspcrcy preserving type ) as CrdtActlVarblCostInDspCrcy,

      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      @UI.lineItem: [{position: 11}]
      cast( case $parameters.P_CurrencyRole
          when '20' then ActlVarblCostInCtrlgAreaCrcy
          else ActlVarblCostInCoCodeCrcy
      end as fis_actlvarblcost_in_dspcrcy preserving type ) as ActlVarblCostInDspCrcy,

      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then CrdtActlFxdCostInCOCrcy
          else CreditActlFixedCostInCCCrcy
      end as fis_cr_actlfxdcost_in_dspcrcy preserving type ) as CrdtActlFxdCostInDspCrcy,

      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then DebitActlFxdCostInCOCrcy
          else DebitActlFixedCostInCoCodeCrcy
      end as fis_dr_actlfxdcost_in_dspcrcy preserving type ) as DebitActlFxdCostInDspCrcy,

      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      @UI.lineItem: [{position: 12}]
      cast( case $parameters.P_CurrencyRole
          when '20' then ActlFixedCostInCtrlgAreaCrcy
          else ActlFixedCostInCoCodeCrcy
      end as fis_actlfixedcost_in_dspcrcy preserving type ) as ActlFixedCostInDspCrcy,

      @UI.hidden: true
      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then CreditPlanCostInCtrlgAreaCrcy
          else CreditPlanCostInCoCodeCrcy
      end as fis_cr_plancost_in_dspcrcy preserving type ) as CreditPlanCostInDspCrcy,

      @UI.hidden: true
      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then DebitPlanCostInCtrlgAreaCrcy
          else DebitPlanCostInCoCodeCrcy
      end as fis_dr_plancost_in_dspcrcy preserving type ) as DebitPlanCostInDspCrcy,

      @UI.hidden: true
      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then CrdtPlnFxdCostInCtrlgAreaCrcy
          else CreditPlanFixedCostInCCCrcy
      end as fis_cr_plnfxdcost_in_dspcrcy preserving type ) as CrdtPlnFxdCostInDspCrcy,

      @UI.hidden: true
      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then DebitPlnFxdCostInCtrlgAreaCrcy
          else DebitPlanFixedCostInCoCodeCrcy
      end as fis_dr_plnfxdcost_in_dspcrcy preserving type ) as DebitPlnFxdCostInDspCrcy,

      @UI.hidden: true
      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then CrdtPlnVarblCostInCOCrcy
          else CreditPlanVarblCostInCCCrcy
      end as fis_cr_plnvarblcost_in_dspcrcy preserving type ) as CrdtPlnVarblCostInDspCrcy,

      @UI.hidden: true
      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then DebitPlnVarblCostInCOCrcy
          else DebitPlanVarblCostInCoCodeCrcy
      end as fis_dr_plnvarblcost_in_dspcrcy preserving type ) as DebitPlnVarblCostInDspCrcy,

      @UI.hidden: true
      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then PlanCostInCtrlgAreaCrcy
          else PlanCostInCoCodeCrcy
      end as fis_plancost_in_dspcrcy preserving type ) as PlanCostInDspCrcy,

      @UI.hidden: true
      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then PlanFixedCostInCtrlgAreaCrcy
          else PlanFixedCostInCoCodeCrcy
      end as fis_planfixedcost_in_dspcrcy preserving type ) as PlanFixedCostInDspCrcy,

      @UI.hidden: true
      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then PlanVarblCostInCtrlgAreaCrcy
          else PlanVarblCostInCoCodeCrcy
      end as fis_planvarblcost_in_dspcrcy preserving type ) as PlanVarblCostInDspCrcy,

      @UI.hidden: true
      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then CrdtTargetCostInCtrlgAreaCrcy
          else CreditTargetCostInCoCodeCrcy
      end as fis_cr_tgtcost_in_dspcrcy preserving type ) as CrdtTargetCostInDspCrcy,

      @UI.hidden: true
      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then DebitTargetCostInCtrlgAreaCrcy
          else DebitTargetCostInCoCodeCrcy
      end as fis_dr_tgtcost_in_dspcrcy preserving type ) as DebitTargetCostInDspCrcy,

      @UI.hidden: true
      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then TargetCostInCtrlgAreaCrcy
          else TargetCostInCoCodeCrcy
      end as fis_tgtcost_in_dspcrcy preserving type ) as TargetCostInDspCrcy,

      @UI.hidden: true
      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then CrdtPlanCtrlCostInGlobCrcy
          else CrdtPlanCtrlCostInCCCrcy
      end as fis_cr_planctrlcost_indspcrcy preserving type ) as CrdtPlanCtrlCostInDspCrcy,

      @UI.hidden: true
      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then DebitPlanCtrlCostInGlobCrcy
          else DebitPlanCtrlCostInCCCrcy
      end as fis_dr_planctrlcost_indspcrcy preserving type ) as DebitPlanCtrlCostInDspCrcy,

      @UI.hidden: true
      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then PlanCtrlCostInGlobCrcy
          else PlanCtrlCostInCoCodeCrcy
      end as fis_planctrlcost_in_dspcrcy preserving type ) as PlanCtrlCostInDspCrcy,

      @UI.hidden: true
      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then CrdtActlCtrlCostInGlobCrcy
          else CrdtActlCtrlCostInCCCrcy
      end as fis_cr_actlctrlcost_indspcrcy preserving type ) as CrdtActlCtrlCostInDspCrcy,

      @UI.hidden: true
      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then DebitActlCtrlCostInGlobCrcy
          else DebitActlCtrlCostInCCCrcy
      end as fis_dr_actlctrlcost_indspcrcy preserving type ) as DebitActlCtrlCostInDspCrcy,

      @UI.hidden: true
      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then ActlCtrlCostInGlobCrcy
          else ActlCtrlCostInCoCodeCrcy
      end as fis_actlctrlcost_in_dspcrcy preserving type ) as ActlCtrlCostInDspCrcy,

      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      @UI.lineItem: [{position: 30}]
      cast( case $parameters.P_CurrencyRole
          when '20' then InptPrVarcAmtInCtrlgAreaCrcy
          else InptPriceVarcAmtInCoCodeCrcy
      end as fis_inptprvarcamt_in_dspcrcy preserving type ) as InptPrVarcAmtInDspCrcy,

      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      @UI.lineItem: [{position: 31}]
      cast( case $parameters.P_CurrencyRole
          when '20' then InptQtyVarcAmtInCtrlgAreaCrcy
          else InptQtyVarcAmtInCoCodeCrcy
      end as fis_inptqtyvarcamt_in_dspcrcy preserving type ) as InptQtyVarcAmtInDspCrcy,

      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      @UI.lineItem: [{position: 32}]
      cast( case $parameters.P_CurrencyRole
          when '20' then RsceUsgeVarcAmtInCtrlgAreaCrcy
          else RsceUsgeVarcAmtInCoCodeCrcy
      end as fis_rsceusgevarcamt_in_dspcrcy preserving type ) as RsceUsgeVarcAmtInDspCrcy,

      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      @UI.lineItem: [{position: 33}]
      cast( case $parameters.P_CurrencyRole
          when '20' then InptRmngVarcAmtInCtrlgAreaCrcy
          else InputRmngVarcAmtInCoCodeCrcy
      end as fis_inptrmngvarcamt_in_dspcrcy preserving type ) as InptRmngVarcAmtInDspCrcy,

      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      @UI.lineItem: [{position: 34}]
      cast( case $parameters.P_CurrencyRole
          when '20' then MixedPrVarcAmtInCtrlgAreaCrcy
          else MixedPrVarcAmtInCoCodeCrcy
      end as fis_mixedprvarcamt_in_dspcrcy preserving type ) as MixedPrVarcAmtInDspCrcy,

      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      @UI.lineItem: [{position: 35}]
      cast( case $parameters.P_CurrencyRole
          when '20' then OutpPrVarcAmtInCtrlgAreaCrcy
          else OutpPrVarcAmtInCoCodeCrcy
      end as fis_outpprvarcamt_in_dspcrcy preserving type ) as OutpPrVarcAmtInDspCrcy,

      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      @UI.lineItem: [{position: 36}]
      cast( case $parameters.P_CurrencyRole
          when '20' then LotSizeVarcAmtInCtrlgAreaCrcy
          else LotSizeVarcAmtInCoCodeCrcy
      end as fis_lotsizevarcamt_in_dspcrcy preserving type ) as LotSizeVarcAmtInDspCrcy,

      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      @UI.lineItem: [{position: 37}]
      cast( case $parameters.P_CurrencyRole
          when '20' then OutpQtyVarcAmtInCtrlgAreaCrcy
          else OutpQtyVarcAmtInCoCodeCrcy
      end as fis_qutpqtyvarcamt_in_dspcrcy preserving type ) as OutpQtyVarcAmtInDspCrcy,

      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      @UI.lineItem: [{position: 38}]
      cast( case $parameters.P_CurrencyRole
          when '20' then OutpRmngVarcAmtInCtrlgAreaCrcy
          else OutputRmngVarcAmtInCoCodeCrcy
      end as fis_outprmngvarcamt_in_dspcrcy preserving type ) as OutpRmngVarcAmtInDspCrcy,

      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      @UI.lineItem: [{position: 39}]
      cast( case $parameters.P_CurrencyRole
          when '20' then ScrapVarcAmtInCtrlgAreaCrcy
          else ScrapVarcAmtInCoCodeCrcy
      end as fis_scrapvarcamt_in_dspcrcy preserving type ) as ScrapVarcAmtInDspCrcy,

      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      @UI.lineItem: [{position: 40}]
      cast ( case $parameters.P_CurrencyRole
          when '20' then InptPrVarcAmtInCtrlgAreaCrcy
                        + InptQtyVarcAmtInCtrlgAreaCrcy
                        + RsceUsgeVarcAmtInCtrlgAreaCrcy
                        + InptRmngVarcAmtInCtrlgAreaCrcy
                        + MixedPrVarcAmtInCtrlgAreaCrcy
                        + OutpPrVarcAmtInCtrlgAreaCrcy
                        + LotSizeVarcAmtInCtrlgAreaCrcy
                        + OutpQtyVarcAmtInCtrlgAreaCrcy
                        + OutpRmngVarcAmtInCtrlgAreaCrcy
          else InptPriceVarcAmtInCoCodeCrcy
                        + InptQtyVarcAmtInCoCodeCrcy
                        + RsceUsgeVarcAmtInCoCodeCrcy
                        + InputRmngVarcAmtInCoCodeCrcy
                        + MixedPrVarcAmtInCoCodeCrcy
                        + OutpPrVarcAmtInCoCodeCrcy
                        + LotSizeVarcAmtInCoCodeCrcy
                        + OutpQtyVarcAmtInCoCodeCrcy
                        + OutputRmngVarcAmtInCoCodeCrcy
      end as fis_costvarc_in_dspcrcy ) as CostVarianceInDspCrcy,

      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then WIPCostInCtrlgAreaCrcy
          else WIPCostInCoCodeCrcy
      end as fis_wipcost_in_dspcrcy preserving type ) as WIPCostInDspCrcy,

      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then UnrlzdCostRsrvAmtInGlobCrcy
          else UnrlzdCostRsrvAmtInCoCodeCrcy
      end as fis_abgruekfk preserving type ) as UnrlzdCostRsrvAmtInDspCrcy,

      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then TotalWIPAmountInCOCrcy
          else TotalWIPAmountInCoCodeCrcy
      end as abgbesges preserving type ) as TotalWIPAmountInDspCrcy,

      @DefaultAggregation: #SUM
      @Semantics: { quantity : {unitOfMeasure: 'ProductionUnit'} }
      @UI.hidden: true
      PlanOutputQuantity,
      @DefaultAggregation: #SUM
      @Semantics: { quantity : {unitOfMeasure: 'ProductionUnit'} }
      ActualOutputQuantity,

      @UI.hidden: true
      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then DebitActlPlnDiffCostInCOCrcy
          else DebitActlPlnDiffCostInCCCrcy
      end as fis_dractlplndiffcostindspcrcy preserving type ) as DebitActlPlnDiffCostInDspCrcy,

      @UI.hidden: true
      @DefaultAggregation: #NONE
      cast( case $parameters.P_CurrencyRole
                when '20' then CtrlgAreaCrcyActlPlanDiffPct
                else CoCodeCrcyActlPlanDiffPercent
            end as fis_dr_cocrcy_actlplndiffpct preserving type ) as DebitActlPlanDiffPercent,

      @UI.hidden: true
      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then DebitActlTgtDiffCostInCOCrcy
          else DebitActlTgtDiffCostInCCCrcy
      end as fis_dractltgtdiffcostindspcrcy preserving type ) as DebitActlTgtDiffCostInDspCrcy,

      @UI.hidden: true
      @DefaultAggregation: #NONE
      cast( case $parameters.P_CurrencyRole
                when '20' then CtrlgAreaCrcyActlTgtDiffPct
                else CoCodeCrcyActlTgtDiffPercent
            end as fis_dr_cocrcy_actltgtdiffpct preserving type ) as DebitActlTgtDiffPercent,

      @UI.hidden: true
      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then (PlanCtrlCostInGlobCrcy - TargetCostInCtrlgAreaCrcy)
          else (PlanCtrlCostInCoCodeCrcy - TargetCostInCoCodeCrcy)
      end as fis_plnctrltgtdiff_indspcrcy ) as PlnCtrlTgtDiffCostInDspCrcy,

      @UI.hidden: true
      @DefaultAggregation: #NONE
      cast( case $parameters.P_CurrencyRole
            when '20' then
      ( case when TargetCostInCtrlgAreaCrcy <> 0
      then round(
             division((PlanCtrlCostInGlobCrcy - TargetCostInCtrlgAreaCrcy),
                        TargetCostInCtrlgAreaCrcy, 5) * 100, 2)
      else case PlanCtrlCostInGlobCrcy - TargetCostInCtrlgAreaCrcy
             when 0 then 0
             else 100
           end
      end )
      else( case when TargetCostInCoCodeCrcy <> 0
      then round(
             division((PlanCtrlCostInCoCodeCrcy - TargetCostInCoCodeCrcy),
                        TargetCostInCoCodeCrcy, 5) * 100, 2)
      else case PlanCtrlCostInCoCodeCrcy - TargetCostInCoCodeCrcy
             when 0 then 0
             else 100
           end
      end )
      end as fis_dspcrcy_plnctrltgtdiffpct ) as DspCrcyPlnCtrlTgtDiffPct,

      @UI.hidden: true
      @Semantics: { amount : {currencyCode: 'DisplayCurrency'} }
      cast( case $parameters.P_CurrencyRole
          when '20' then (ActlCtrlCostInGlobCrcy - TargetCostInCtrlgAreaCrcy)
          else (ActlCtrlCostInCoCodeCrcy - TargetCostInCoCodeCrcy)
      end as fis_actlctrltgtdiff_indspcrcy ) as ActlCtrlTgtDiffCostInDspCrcy,

      @UI.hidden: true
      @DefaultAggregation: #NONE
      cast( case $parameters.P_CurrencyRole
            when '20' then
      ( case when TargetCostInCtrlgAreaCrcy <> 0
      then round(
             division((ActlCtrlCostInGlobCrcy - TargetCostInCtrlgAreaCrcy),
                        TargetCostInCtrlgAreaCrcy, 5) * 100, 2)
      else case ActlCtrlCostInGlobCrcy - TargetCostInCtrlgAreaCrcy
             when 0 then 0
             else 100
           end
      end )
      else( case when TargetCostInCoCodeCrcy <> 0
      then round(
             division((ActlCtrlCostInCoCodeCrcy - TargetCostInCoCodeCrcy),
                        TargetCostInCoCodeCrcy, 5) * 100, 2)
      else case ActlCtrlCostInCoCodeCrcy - TargetCostInCoCodeCrcy
             when 0 then 0
             else 100
           end
      end )
      end as fis_dspcrcy_actlctrltgtdiffpct ) as DspCrcyActlCtrlTgtDiffPct,

      @UI.hidden: true
      @Semantics: { quantity : {unitOfMeasure: 'ProductionUnit'} }
      cast(ActlPlanDiffOutputQuantity as fis_actlplandiffoutputquantity ) as ActlPlanDiffOutputQuantity,

      @UI.hidden: true
      @DefaultAggregation: #NONE
      ActlPlanDiffOutpQtyPercent,

      _CreatedByContactCard,
      _LastChangedByUserContactCard,
      _Product,
      _ProductionOrder,
      _Plant,
      _CompanyCode,
      _ControllingArea,
      _OrderCategory,
      _OrderType,
      _StorageLocation,
      _ResponsibleCostCenter,
      _ProfitCenter
}