@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: 'MRPController Data'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@AbapCatalog.viewEnhancementCategory: [#NONE]
define view entity YI_PP_MRPController
  as select from I_ProductPlantBasic
  association [0..1] to I_MRPController as _MRPController on  $projection.Plant         = _MRPController.Plant
                                                          and $projection.MRPController = _MRPController.MRPController
{
  key I_ProductPlantBasic.Product        as Material,
  key I_ProductPlantBasic.Plant          as Plant,
  key I_ProductPlantBasic.MRPResponsible as MRPController,
      _MRPController.MRPControllerName   as MRPControllerName,
      // association
      _MRPController
}