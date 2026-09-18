@Metadata.allowExtensions: true
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SingleLevel BOM'
@Metadata.ignorePropagatedAnnotations: true
define view entity YC_PP_SingleLevelBOMT
  as select from YI_PP_BOMT
{
        @Consumption.filter.mandatory: true
        @EndUserText.label: '{@i18n>Item.Plant}'
        @Consumption.valueHelpDefinition: [{
        entity: { name: 'I_PlantStdVH', element: 'Plant'}
        }]
  key   Plant,
        @EndUserText.label: '{@i18n>Item.BOMUsage}'
        @Consumption.valueHelpDefinition: [{
        entity: { name: 'YI_PP_BOMUsageStdVH', element: 'BillOfMaterialVariantUsage'}
        }]
  key   BOMUsage,
        @EndUserText.label: '{@i18n>Item.Material}'
        @Consumption.valueHelpDefinition: [{
        entity: { name: 'I_ProductStdVH', element: 'Product'}
        }]
  key   Material,
  key   cast(BillOfMaterial as abap.char(8))        as BillOfMaterial,
        // key BillOfMaterial,
        @EndUserText.label: '{@i18n>Item.AlternativeBOM}'
        // @Consumption.valueHelpDefinition: [{
        // entity: { name: 'I_BillOfMaterialHeaderDEX', element: 'BillOfMaterialVariant'}
        // }]
  key   AlternativeBOM,
  key   BillOfMaterialItemNodeNumber,
        @EndUserText.label: '{@i18n>Item.FunctionType}'
        FunctionType,
        @EndUserText.label: '{@i18n>Item.ProcessingDate}'
        ProcessingDate,
        @EndUserText.label: '{@i18n>Item.PlantName}'
        PlantName,
        @Consumption.filter.mandatory: true
        @EndUserText.label: '{@i18n>Item.ValidFromDate}'
        //@Semantics.businessDate.from
        ValidFromDate,
        @EndUserText.label: '{@i18n>Item.MaterialDescription}'
        @Consumption.valueHelpDefinition: [{
        entity: { name: 'YI_PP_MatDescVH', element: 'Material'}
        }]
        MaterialDescription,
        @EndUserText.label: '{@i18n>Item.MaterialGroup}'
        @Consumption.valueHelpDefinition: [{
        entity: { name: 'YI_PP_ProductGroupVH', element: 'ProductGroup'}
        }]
        MaterialGroup,
        @EndUserText.label: '{@i18n>Item.MaterialGroupName}'
        MaterialGroupName,
        @EndUserText.label: '{@i18n>Item.AlternativeText}'
        AlternativeText,
        //@Semantics.quantity.unitOfMeasure:'BaseUnit'
        @EndUserText.label: '{@i18n>Item.BaseQuantity}'
        cast(BaseQuantity as abap.dec( 13, 3))      as BaseQuantity,
        //BaseQuantity,
        @EndUserText.label: '{@i18n>Item.BaseUnit}'
        BaseUnit,
        @EndUserText.label: '{@i18n>Item.DeletionFlag}'
        @Consumption.valueHelpDefinition: [{
        entity: { name   : 'YI_PP_DeletionFlagStdVH', element: 'Flag' }
        }]
        cast (DeletionFlag as abap.char(1)) as DeletionFlag,
        @EndUserText.label: '{@i18n>Item.BOMStatus}'
        BOMStatus,
        @EndUserText.label: '{@i18n>Item.HierarchyLevel}'
        HierarchyLevel,
        @EndUserText.label: '{@i18n>Item.ProductionVersion}'
        ProductionVersion,
        @EndUserText.label: '{@i18n>Item.TopLevelMaterial}'
        TopLevelMaterial,
        @EndUserText.label: '{@i18n>Item.PreviousParentMaterial}'
        PreviousParentMaterial,
        @EndUserText.label: '{@i18n>Item.MRPController}'
        @Consumption.valueHelpDefinition: [{
        entity: { name: 'YI_PP_MRPControllerVH', element: 'MRPController'}
        }]
        MRPController,
        @EndUserText.label: '{@i18n>Item.MRPControllerName}'
        MRPControllerName,
        @EndUserText.label: '{@i18n>Item.ProductionSupervisor}'
        @Consumption.valueHelpDefinition: [{
        entity: { name: 'YI_PP_ProdSupervisorVH', element: 'ProductionSupervisor'}
        }]
        ProductionSupervisor,
        @EndUserText.label: '{@i18n>Item.ProductionSupervisorName}'
        ProductionSupervisorName,
        @EndUserText.label: '{@i18n>Item.ItemNumber}'
        cast(ItemNumber as abap.char(4))            as ItemNumber,
        @EndUserText.label: '{@i18n>Item.ItemCategory}'
        ItemCategory,
        @EndUserText.label: '{@i18n>Item.ComponentMaterial}'
        ComponentMaterial,
        @EndUserText.label: '{@i18n>Item.ComponentDescription}'
        ComponentDescription,
        @EndUserText.label: '{@i18n>Item.ItemText}'
        ItemText,
        //@Semantics.quantity.unitOfMeasure:'ComponentUnit'
        @EndUserText.label: '{@i18n>Item.ComponentQuantity}'
        cast(ComponentQuantity as abap.dec( 13, 3)) as ComponentQuantity,
        // ComponentQuantity,
        @EndUserText.label: '{@i18n>Item.ComponentUnit}'
        ComponentUnit,
        @EndUserText.label: '{@i18n>Item.FixedQuantity}'
        cast(FixedQuantity as abap.char(1))         as FixedQuantity,
        @EndUserText.label: '{@i18n>Item.LeadTimeOffset}'
        LeadTimeOffset,
        @EndUserText.label: '{@i18n>Item.IssueLocation}'
        IssueLocation,
        @EndUserText.label: '{@i18n>Item.IssueLocationText}'
        IssueLocationText,
        @EndUserText.label: '{@i18n>Item.Recursive}'
        cast(Recursive as abap.char(1))             as Recursive,
        @EndUserText.label: '{@i18n>Item.RelevancytoCosting}'
        RelevancytoCosting
}