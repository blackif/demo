@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'BankChargesView'

@Metadata.ignorePropagatedAnnotations: true

define view entity ZC_FI_IsjpbkCharge
  as select from isjpbkcharge  as _isjp

    inner join   I_CompanyCode as _t001 on _t001.CompanyCode = _isjp.bukrs

{
  key _isjp.bukrs          as CompanyCode,
  key _isjp.patternid      as BankChargePatternID,
  key _isjp.seqno          as SequentialNumber,

      _isjp.operator       as Operator,

      @Semantics.amount.currencyCode: 'currency'
      _isjp.bankchargeamnt as BankChargeAmount,

      _t001.Currency       as currency
}
