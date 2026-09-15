@EndUserText.label: 'Manufacturing Order Component'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@VDM.viewType: #COMPOSITE
define view entity ZI_PP_MOrderComponent
  as select from I_ManufacturingOrder       as _MOrder

    inner join   I_ProductionOrderComponent as _MOrderComponent on _MOrderComponent.ProductionOrder = _MOrder.ManufacturingOrder
  association [0..1] to I_ProductText       as _ProductText     on  _MOrderComponent.Material = _ProductText.Product
                                                                and _ProductText.Language     = 'J'
  association [0..1] to I_Batch as _BatchPlant on  _BatchPlant.Plant    = _MOrderComponent.Plant
                                               and _BatchPlant.Material = _MOrderComponent.Material
                                               and _BatchPlant.Batch    = _MOrderComponent.Batch
  association [0..1] to I_Batch as _Batch      on  _Batch.Plant    = ''
                                               and _Batch.Material = _MOrderComponent.Material
                                               and _Batch.Batch    = _MOrderComponent.Batch
{
  key _MOrder.ManufacturingOrder                as ManufacturingOrder,
  key _MOrderComponent.Material                 as Material,

      @Semantics.text: true
      coalesce(_ProductText.ProductName,_MOrderComponent.MaterialComponentText ) as ProductName,
      _MOrderComponent.Batch                    as Batch,

      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      _MOrderComponent.RequiredQuantity         as Prequiredquantity,

      _MOrderComponent.BaseUnit                 as BaseUnit,
      case when _BatchPlant.BatchBySupplier = '' or _BatchPlant.BatchBySupplier is null then _Batch.BatchBySupplier
           else _BatchPlant.BatchBySupplier
           end                                  as SupplierBatch,
      _MOrderComponent.ProductionOrderOperation as ProductionOrderOperation,
      _MOrderComponent.StorageLocation          as StorageLocation,
      _MOrderComponent.ReservationItem          as ReservationItem,
      _MOrderComponent.ProductionPlant          as ProductionPlant,
      _MOrder.ManufacturingOrderType            as ManufacturingOrderType,
      _MOrder.ManufacturingOrderCategory        as ManufacturingOrderCategory,
      _MOrder.CreationDate                      as CreationDate,
      _MOrder.CreationTime                      as CreationTime,
      _MOrder.LastChangeDate                    as LastChangeDate,
      _MOrder.LastChangeTime                    as LastChangeTime
}
