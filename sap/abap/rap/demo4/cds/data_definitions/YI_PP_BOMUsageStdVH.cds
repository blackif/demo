//GENERATED:006:K6jBmqNO7koMiodObS3WWG
//@AbapCatalog.sqlViewName: 'ZIBOMUSAGE_VH'
//@AbapCatalog.compiler.compareFilter: true

@VDM.viewType: #COMPOSITE

@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.representativeKey: 'BillOfMaterialVariantUsage'

@ObjectModel.usageType.serviceQuality: #B
@ObjectModel.usageType.sizeCategory: #S
@ObjectModel.usageType.dataClass: #CUSTOMIZING

@ObjectModel.resultSet.sizeCategory: #XS

@AccessControl.authorizationCheck: #CHECK
//@ClientHandling.algorithm: #SESSION_VARIABLE
@Search.searchable: true
//@AbapCatalog.preserveKey:true 
@Metadata.ignorePropagatedAnnotations: true

@EndUserText.label: 'BOM Usage Std VH'
//define view YI_PP_BOMUsageStdVH as select from I_BillOfMaterialUsageStdVH
define view entity YI_PP_BOMUsageStdVH as select from I_BillOfMaterialUsageStdVH
{
  @ObjectModel.text.element: ['BillOfMaterialVariantUsageDesc']
  @Search.defaultSearchElement: true
  @Search.ranking: #HIGH
  @Search.fuzzinessThreshold: 0.8
  key BillOfMaterialVariantUsage,
   @Semantics.language: true
   @UI.hidden: true
  key Language,
   @Semantics.text: true
   @Search.defaultSearchElement: true
   @Search.fuzzinessThreshold: 0.8
  BillOfMaterialVariantUsageDesc    
}