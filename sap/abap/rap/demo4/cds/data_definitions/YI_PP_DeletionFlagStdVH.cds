@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: 'AlternativeBOM Value Help'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@AbapCatalog.viewEnhancementCategory: [ #NONE ]
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define view entity YI_PP_DeletionFlagStdVH 
    as select from I_Language
{
  @Search: {defaultSearchElement: true, ranking: #LOW, fuzzinessThreshold: 0.8}
  key cast( ' ' as abap.char(1) ) as Flag
}
where Language = $session.system_language

union all

select from I_Language
{
  key cast( 'X' as abap.char(1) ) as Flag
}
where Language = $session.system_language