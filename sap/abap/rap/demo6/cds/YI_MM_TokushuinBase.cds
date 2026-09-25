@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Payment Notification Data Item Base'

@Metadata.ignorePropagatedAnnotations: true

define view entity YI_MM_TokushuinBase

  as select from I_SuplrInvcItemPurOrdRefAPI01 as _InvoiceItem

  association [0..1] to I_SupplierInvoiceAPI01 as _SupplierInvoice
    on _InvoiceItem.SupplierInvoice = _SupplierInvoice.SupplierInvoice
    and _InvoiceItem.FiscalYear = _SupplierInvoice.FiscalYear

  association [0..1] to I_Supplier as _Supplier
    on _Supplier.Supplier = $projection.invoicingparty

  association [0..1] to I_SettlementPaymentMethod as _Payment
    on (    _Payment.CustomerCountryKey = $projection.country
        and _Payment.PrmtHbPaymentMethod = $projection.paymentmethod
        and $projection.paymentmethod is not initial)
    or (    _Payment.CustomerCountryKey = 'JP'
        and _Payment.PrmtHbPaymentMethod = 'R'
        and $projection.paymentmethod is initial)

  association [0..1] to YI_MM_TokushuinOrder as _OrderInfo
    on _OrderInfo.PurchasingDocument = $projection.PurchaseOrder
    and _OrderInfo.PurchasingDocumentItem = $projection.PurchaseOrderItem

  association [0..1] to I_JournalEntryItem as _JournalItem
    on _JournalItem.SourceLedger = '0L'
    and _JournalItem.Ledger = '0L'
    and _JournalItem.ReferenceDocumentType = 'RMRP'
    and _JournalItem.ReferenceDocumentContext = $projection.FiscalYear
    and _JournalItem.ReferenceDocument = $projection.SupplierInvoice
    and _JournalItem.FinancialAccountType = 'K'

  association [0..1] to I_PurchaseOrderAPI01 as _PurchaseOrder
    on _PurchaseOrder.PurchaseOrder = $projection.PurchaseOrder

  association [0..1] to I_PurchaseOrderItemAPI01 as _PurchaseOrderItem
    on _PurchaseOrderItem.PurchaseOrder = $projection.PurchaseOrder
    and _PurchaseOrderItem.PurchaseOrderItem = $projection.PurchaseOrderItem

  association [0..1] to I_SupplierPurchasingOrg as _SupplierPurchasingOrg
    on _SupplierPurchasingOrg.Supplier = $projection.invoicingparty
    and _SupplierPurchasingOrg.PurchasingOrganization = $projection.purchasingorganization

  association [0..1] to I_Businesspartnertaxnumber as _Taxnumber
    on _Taxnumber.BusinessPartner = $projection.invoicingparty
    and _Taxnumber.BPTaxType = 'JP3'

  association [0..1] to YI_MM_Company as _Company
    on _Company.CompanyCode = $projection.companycode

  association [0..1] to YI_MM_TaxRate as _TaxRate
    on _TaxRate.Country = $projection.country
    and _TaxRate.TaxCode = $projection.TaxCode

{
  key _InvoiceItem.SupplierInvoice,
  key _InvoiceItem.FiscalYear,
  key _InvoiceItem.SupplierInvoiceItem,

      _PurchaseOrder.PurchasingOrganization,
      _InvoiceItem.PurchaseOrder,
      _InvoiceItem.PurchaseOrderItem,
      _InvoiceItem.PurchaseOrderItemMaterial,
      _InvoiceItem.TaxCode,
      _InvoiceItem.PurchaseOrderQuantityUnit,

      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
      _InvoiceItem.QuantityInPurchaseOrderUnit,

      _SupplierInvoice.CompanyCode,
      _SupplierInvoice._CompanyCode.Country,
      _SupplierInvoice.PostingDate,
      left(_SupplierInvoice.PostingDate, 6) as PostingYearMonth,
      _SupplierInvoice.InvoicingParty,
      _SupplierInvoice.DocumentCurrency,
      _SupplierInvoice.PaymentMethod,
      _SupplierInvoice.SupplyingCountry,

      _PurchaseOrderItem.PurchaseOrderItemText,
      _PurchaseOrderItem.NetPriceQuantity,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      _PurchaseOrderItem.NetPriceAmount as NetPriceAmount,

      _JournalItem.NetDueDate,
      _OrderInfo.OrderID,
      _OrderInfo[inner].SetID,
      _OrderInfo.SetDescription,

      _InvoiceItem.DebitCreditCode,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      cast(
        (case when _InvoiceItem.DebitCreditCode = 'S'
          then _InvoiceItem.SupplierInvoiceItemAmount
          when _InvoiceItem.DebitCreditCode = 'H'
          then _InvoiceItem.SupplierInvoiceItemAmount * -1
        end)
        as wrbtr_cs) as SupplierInvoiceItemAmount_Doc,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      cast(
        (case when _InvoiceItem.DebitCreditCode = 'S'
          then _InvoiceItem._SupplierInvoiceAPI01._SupplierInvoiceTaxAPI01[TaxCode=$projection.taxcode].TaxAmount
          when _InvoiceItem.DebitCreditCode = 'H'
          then _InvoiceItem._SupplierInvoiceAPI01._SupplierInvoiceTaxAPI01[TaxCode=$projection.taxcode].TaxAmount * -1
        end)
        as fwstev) as TaxAmount_Doc,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      cast(
        (case when _InvoiceItem.DebitCreditCode = 'S'
          then _SupplierInvoice.InvoiceGrossAmount
          when _InvoiceItem.DebitCreditCode = 'H'
          then _SupplierInvoice.InvoiceGrossAmount * -1
        end)
        as rmwwr) as InvoiceGrossAmount_Doc,

      _Taxnumber,
      _Company,
      _TaxRate,
      _Supplier,
      _SupplierPurchasingOrg,
      _Payment,
      _OrderInfo
}
