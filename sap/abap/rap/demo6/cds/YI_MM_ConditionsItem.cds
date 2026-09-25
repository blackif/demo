@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Conditions Item'

@Metadata.ignorePropagatedAnnotations: true

define view entity YI_MM_ConditionsItem
  as select from konp

{
  key knumh as ConditionRecord,
  key kopos as ConditionRecordSeqNo,

      kschl as ConditionType,
      kappl as Application,

      @Semantics.amount.currencyCode: 'konwa'
      kbetr as ConditionPercentage,

      konwa
}
