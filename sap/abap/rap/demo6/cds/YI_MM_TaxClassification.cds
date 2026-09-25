@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Tax Classification'

@Metadata.ignorePropagatedAnnotations: true

define view entity YI_MM_TaxClassification
  as select from a003

{
  key kappl as Application,
  key kschl as ConditionType,
  key aland as Country,
  key mwskz as TaxCode,

      knumh as ConditionRecord
}
