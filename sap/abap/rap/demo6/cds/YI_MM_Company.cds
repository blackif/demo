@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Company Codes'

@Metadata.ignorePropagatedAnnotations: true

define view entity YI_MM_Company
  as select from t001

{
  key bukrs as CompanyCode,

      mwskv as TaxFreeCode
}
