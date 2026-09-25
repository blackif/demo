@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Payment Notification Data Aggregate'

@Metadata.ignorePropagatedAnnotations: true

define view entity YI_MM_TokushuinAggregate
  with parameters
    P_YearMonth : vdm_yearmonth

  as select from YI_MM_TokushuinItem

{
  key InvoicingParty,
  key SetID,
  key TaxRate,

  key SumCurrency,

      @Semantics.amount.currencyCode: 'SumCurrency'
      round((cast(sum(ItemAmount_CC) as abap.decfloat34) * TaxRate), 0) as TaxAmount_Sum_Total
}

where PostingYearMonth = $parameters.P_YearMonth

group by InvoicingParty,
         SetID,
         TaxRate,
         SumCurrency
