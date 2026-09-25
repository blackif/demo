@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Payment Notification Data'

@Metadata.ignorePropagatedAnnotations: true

define view entity YC_MM_Tokushuin
  with parameters
    P_YearMonth : yeyearmonth

  as select from YI_MM_TokushuinItem                      as _list

    inner join   YI_MM_TokushuinAggregate(
                   P_YearMonth : $parameters.P_YearMonth) as _sum
      on  _sum.InvoicingParty = _list.InvoicingParty
      and _sum.SetID          = _list.SetID
      and _sum.TaxRate        = _list.TaxRate
      and _sum.SumCurrency    = _list.SumCurrency

{
  key _list.SupplierInvoice,
  key _list.FiscalYear,
  key _list.SupplierInvoiceItem,

      _list.PurchasingOrganization,
      _list.PurchaseOrder,
      _list.PurchaseOrderItem,
      _list.PurchaseOrderItemMaterial,
      _list.TaxCode,
      _list._TaxRate.TaxRate,
      _list._Company.TaxFreeCode,
      _list.PurchaseOrderQuantityUnit,

      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
      _list.QuantityInPurchaseOrderUnit,

      _list.CompanyCode,
      _list.Country,
      _list.PostingDate,
      _list.InvoicingParty,
      _list.DocumentCurrency,
      _list.PaymentMethod,
      _list._Taxnumber.BPTaxNumber,
      _list.AddressID,
      _list.OrganizationBPName1,
      _list.OrganizationBPName2,
      _list.CityName,
      _list.PostalCode,
      _list.StreetName,
      _list.PhoneNumber1,
      _list.PurchaseOrderItemText,
      _list.NetPriceQuantity,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      _list.NetPriceAmount,

      _list.PaymentMethodName,
      _list.NetDueDate,
      _list.OrderID,
      _list.SetID,
      _list.SetDescription,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      _list.SupplierInvoiceItemAmount_Doc,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      _list.TaxAmount_Doc,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      _list.InvoiceGrossAmount_Doc,

      _list.SumCurrency,

      @Semantics.amount.currencyCode: 'SumCurrency'
      _list.ItemAmount_CC as SupplierInvoiceItemAmount_Sum,

      @Semantics.amount.currencyCode: 'SumCurrency'
      _list.TaxAmount_CC as TaxAmount_Sum,

      @Semantics.amount.currencyCode: 'SumCurrency'
      _list.GrossAmount_CC as InvoiceGrossAmount_Sum,

      @Semantics.amount.currencyCode: 'SumCurrency'
      _sum.TaxAmount_Sum_Total
}

where _list.PostingYearMonth = $parameters.P_YearMonth
