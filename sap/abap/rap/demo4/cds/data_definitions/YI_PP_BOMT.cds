@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BOM Data'
@Metadata.ignorePropagatedAnnotations: true
define view entity YI_PP_BOMT
  as select from I_MaterialBOMLink
    inner join   YI_PP_BillOfMaterial as _BillOfMaterial on  I_MaterialBOMLink.BillOfMaterial             = _BillOfMaterial.BillOfMaterial
                                                         and I_MaterialBOMLink.BillOfMaterialVariant      = _BillOfMaterial.AlternativeBOM
                                                         and I_MaterialBOMLink.BillOfMaterialVariantUsage = _BillOfMaterial.BOMUsage
  association [0..1] to I_StorageLocation   as _IStorageLocation on  $projection.Plant         = _IStorageLocation.Plant
                                                                 and $projection.IssueLocation = _IStorageLocation.StorageLocation
  association [0..1] to I_Plant             as _Plant            on  $projection.Plant = _Plant.Plant
  association [0..1] to YI_PP_MRPController as _MRPController    on  $projection.Material = _MRPController.Material
                                                                 and $projection.Plant    = _MRPController.Plant
  association [0..1] to YI_PP_ProductPlantT as _ProductPlant     on  $projection.Material = _ProductPlant.Material
                                                                 and $projection.Plant    = _ProductPlant.Plant
  association [0..1] to YI_PP_ProductT      as _ProductT         on  $projection.Material = _ProductT.Material
{
  key I_MaterialBOMLink.Plant                      as Plant,
  key I_MaterialBOMLink.BillOfMaterialVariantUsage as BOMUsage,
  key I_MaterialBOMLink.Material                   as Material,
  key I_MaterialBOMLink.BillOfMaterial             as BillOfMaterial,
  key I_MaterialBOMLink.BillOfMaterialVariant      as AlternativeBOM,
  key _BillOfMaterial.BillOfMaterialItemNodeNumber as BillOfMaterialItemNodeNumber,
      cast( '' as abap.char(2) )                   as FunctionType,
      cast( '' as abap.char(8) )                   as ProcessingDate,
      _Plant.PlantName                             as PlantName,
      @Semantics.businessDate.from
      _BillOfMaterial.ValidFromDate                as ValidFromDate,
      _ProductT.MaterialName                       as MaterialDescription,
      _ProductT.MaterialGroup                      as MaterialGroup,
      _ProductT.MaterialGroupName                  as MaterialGroupName,
      _BillOfMaterial.AlternativeText              as AlternativeText,
      @Semantics.quantity.unitOfMeasure:'BaseUnit'
      _BillOfMaterial.BaseQuantity                 as BaseQuantity,
      _BillOfMaterial.BaseUnit                     as BaseUnit,
      _BillOfMaterial.DeletionFlag                 as DeletionFlag,
      _BillOfMaterial.BOMStatus                    as BOMStatus,
      cast( '00' as stufe)                         as HierarchyLevel,
      cast( '' as /ibp/ets_verid)                  as ProductionVersion,
      cast( '' as matnr )                          as TopLevelMaterial,
      cast( '' as matnr)                           as PreviousParentMaterial,
      _MRPController.MRPController                 as MRPController,
      _MRPController.MRPControllerName             as MRPControllerName,
      _ProductPlant.ProductionSupervisor           as ProductionSupervisor,
      _ProductPlant.ProductionSupervisorName       as ProductionSupervisorName,
      _BillOfMaterial.ItemNumber                   as ItemNumber,
      _BillOfMaterial.ItemCategory                 as ItemCategory,
      _BillOfMaterial.ComponentMaterial            as ComponentMaterial,
      _BillOfMaterial.ComponentDescription         as ComponentDescription,
      _BillOfMaterial.ItemText                     as ItemText,
      @Semantics.quantity.unitOfMeasure:'ComponentUnit'
      _BillOfMaterial.ComponentQuantity            as ComponentQuantity,
      _BillOfMaterial.ComponentUnit                as ComponentUnit,
      _BillOfMaterial.FixedQuantity                as FixedQuantity,
      _BillOfMaterial.LeadTimeOffset               as LeadTimeOffset,
      _BillOfMaterial.IssueLocation                as IssueLocation,
      _IStorageLocation.StorageLocationName        as IssueLocationText,
      _BillOfMaterial.Recursive                    as Recursive,
      _BillOfMaterial.RelevancytoCosting           as RelevancytoCosting
}