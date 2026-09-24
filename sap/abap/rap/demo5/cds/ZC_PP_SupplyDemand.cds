@EndUserText.label: 'BOM Sequence Relationship Data Consumption View'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_PP_SUPPLYDEMAND_QRY'
define root custom entity ZC_PP_SupplyDemand
{
  key Plant                     : werks_d;
  key MRPElementType            : delkz;
  key MRPElement                : del12;
  key AllocMRPElement           : del12;
  key AllocMaterial             : matnr;
  key Material                  : matnr;
      MRPElementDescription     : char60;
      ProductGroup              : matkl;
      MaterialText              : maktx;
      RequirementDate           : dat00;
      AllocMRPElementType       : delkz;
      AllocMRPElementDescription: char60;
      AllocMaterialText         : maktx;
      @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
      AllocQuantity             : lmeng;
      QuantityUnit              : meins;
      AllocRequirementDate      : dat00;
}
