@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: 'BillOfMaterial Data'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@AbapCatalog.viewEnhancementCategory: [#NONE]
define view entity YI_PP_BillOfMaterial
  as select from I_BillOfMaterialHeaderDEX
    inner join   YI_PP_BOMItemsAPIWrap     as _ZIPPBOMItemsAPIWrap on  I_BillOfMaterialHeaderDEX.BillOfMaterialCategory = _ZIPPBOMItemsAPIWrap.BillOfMaterialCategory
                                                                   and I_BillOfMaterialHeaderDEX.BillOfMaterial         = _ZIPPBOMItemsAPIWrap.BillOfMaterial
                                                                   and I_BillOfMaterialHeaderDEX.BillOfMaterialVariant  = _ZIPPBOMItemsAPIWrap.BillOfMaterialVariant
    inner join   I_BillOfMaterialItemBasic as _BillOfMaterialItem  on  _ZIPPBOMItemsAPIWrap.BillOfMaterialCategory       = _BillOfMaterialItem.BillOfMaterialCategory
                                                                   and _ZIPPBOMItemsAPIWrap.BillOfMaterial               = _BillOfMaterialItem.BillOfMaterial
                                                                   and _ZIPPBOMItemsAPIWrap.BillOfMaterialItemNodeNumber = _BillOfMaterialItem.BillOfMaterialItemNodeNumber
                                                                   and _BillOfMaterialItem.ValidityStartDate             <= $session.system_date
                                                                   and _BillOfMaterialItem.ValidityEndDate               >= $session.system_date
                                                                   and _BillOfMaterialItem.IsDeleted                     = ''
{
  key     I_BillOfMaterialHeaderDEX.BillOfMaterialCategory      as BillOfMaterialCategory,
  key     I_BillOfMaterialHeaderDEX.BillOfMaterial              as BillOfMaterial,
  key     I_BillOfMaterialHeaderDEX.BillOfMaterialVariant       as AlternativeBOM,
  key     I_BillOfMaterialHeaderDEX.BillOfMaterialVariantUsage  as BOMUsage,
  key     _BillOfMaterialItem.BillOfMaterialItemNodeNumber      as BillOfMaterialItemNodeNumber,
          @Semantics.businessDate.from
          I_BillOfMaterialHeaderDEX.HeaderValidityStartDate     as ValidFromDate,
          I_BillOfMaterialHeaderDEX.BOMAlternativeText          as AlternativeText,
          @Semantics.quantity.unitOfMeasure:'BaseUnit'
          I_BillOfMaterialHeaderDEX.BOMHeaderQuantityInBaseUnit as BaseQuantity,
          I_BillOfMaterialHeaderDEX.BOMHeaderBaseUnit           as BaseUnit,
          I_BillOfMaterialHeaderDEX.BOMIsArchivedForDeletion    as DeletionFlag,
          I_BillOfMaterialHeaderDEX.BillOfMaterialStatus        as BOMStatus,
          _BillOfMaterialItem.BillOfMaterialItemNumber          as ItemNumber,
          _BillOfMaterialItem.BillOfMaterialItemCategory        as ItemCategory,
          _BillOfMaterialItem.BillOfMaterialComponent           as ComponentMaterial,
          _BillOfMaterialItem._ProductText.ProductName          as ComponentDescription,
          _BillOfMaterialItem.BOMItemText1                      as ItemText,
          @Semantics.quantity.unitOfMeasure:'ComponentUnit'
          _BillOfMaterialItem.BillOfMaterialItemQuantity        as ComponentQuantity,
          _BillOfMaterialItem.BillOfMaterialItemUnit            as ComponentUnit,
          _BillOfMaterialItem.FixedQuantity                     as FixedQuantity,
          _BillOfMaterialItem.LeadTimeOffset                    as LeadTimeOffset,
          _BillOfMaterialItem.ProdOrderIssueLocation             as IssueLocation,
          _BillOfMaterialItem.IsBOMRecursiveAllowed             as Recursive,
          _BillOfMaterialItem.BOMItemIsCostingRelevant           as RelevancytoCosting
}
where
  I_BillOfMaterialHeaderDEX.BillOfMaterialCategory = 'M'
//   I_BillOfMaterialHeaderDEX.BOMIsArchivedForDeletion = ''