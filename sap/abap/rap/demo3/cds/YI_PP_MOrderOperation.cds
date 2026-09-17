@EndUserText.label: 'Manufacturing Order Operation'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@VDM.viewType: #COMPOSITE

define view entity YI_PP_MOrderOperation
  as select from    I_ManufacturingOrder          as _MOrder

    inner join      I_ManufacturingOrderOperation as _MOrderOperation on _MOrderOperation.ManufacturingOrder = _MOrder.ManufacturingOrder

    left outer join I_WorkCenter                  as _WorkCenter      on  _WorkCenter.WorkCenterInternalID = _MOrderOperation.WorkCenterInternalID
                                                                      and _WorkCenter.WorkCenterTypeCode   = _MOrderOperation.WorkCenterTypeCode_2

  association [0..1] to I_WorkCenterText as _WorkCenterText on  _WorkCenterText.WorkCenterInternalID = _WorkCenter.WorkCenterInternalID
                                                            and _WorkCenterText.WorkCenterTypeCode   = _WorkCenter.WorkCenterTypeCode
                                                            and _WorkCenterText.Language             = 'J'
{
  key _MOrder.ManufacturingOrder                     as ManufacturingOrder,
  key _MOrderOperation.ManufacturingOrderCategory    as ManufacturingOrderCategory,
  key _MOrderOperation.ManufacturingOrderOperation_2 as ManufacturingOrderOperation_2,

      _MOrderOperation.MfgOrderOperationText         as MfgOrderOperationText,
      _WorkCenter.WorkCenter                         as WorkCenter,
      _WorkCenterText.WorkCenterText                 as WorkCenterText,

      _MOrderOperation.OpErlstSchedldExecStrtDte     as OperLstSchedldExecStrtDte,
      _MOrderOperation.OpLtstSchedldExecStrtDte      as OpLtstSchedldExecStrtDte,

      _MOrderOperation.OperationControlProfile       as OperationControlProfile,
      _MOrderOperation.ExtProcgOperationHasSubcontrg as ExtProcgOperationHasSubcontrg,
      _MOrderOperation.PurchasingInfoRecord          as PurchasingInfoRecord,
      _MOrder.ProductionPlant                        as ProductionPlant,
      _MOrder.ManufacturingOrderType                 as ManufacturingOrderType,
      _MOrder.CreationDate                           as CreationDate,
      _MOrder.CreationTime                           as CreationTime,
      _MOrder.LastChangeDate                         as LastChangeDate,
      _MOrder.LastChangeTime                         as LastChangeTime

}
