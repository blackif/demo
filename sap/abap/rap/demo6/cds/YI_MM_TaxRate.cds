@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Tax Rate'

@Metadata.ignorePropagatedAnnotations: true

define view entity YI_MM_TaxRate

  as select from YI_MM_TaxClassification as _TaxClassification

  association [0..1] to YI_MM_ConditionsItem as _ConditionsItem
    on (    _ConditionsItem.ConditionRecord      = _TaxClassification.ConditionRecord
        and _ConditionsItem.ConditionType        = _TaxClassification.ConditionType
        and _ConditionsItem.Application          = _TaxClassification.Application
        and _ConditionsItem.ConditionRecordSeqNo = '01')

{
  key _TaxClassification.Country,
  key _TaxClassification.TaxCode,

      sum(div(cast(_ConditionsItem[inner].ConditionPercentage as abap.int4), 10)) as TaxRate
}

where _TaxClassification.Application = 'TX'

group by Application,
         Country,
         TaxCode
