@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Payment Notification Data Item'

@Metadata.ignorePropagatedAnnotations: true

define view entity YI_MM_TokushuinItem
  as select from YI_MM_TokushuinBase as _InvoiceItem

{
  key _InvoiceItem.SupplierInvoice,
  key _InvoiceItem.FiscalYear,
  key _InvoiceItem.SupplierInvoiceItem,

      _InvoiceItem.PurchasingOrganization,
      _InvoiceItem.PurchaseOrder,
      _InvoiceItem.PurchaseOrderItem,
      _InvoiceItem.PurchaseOrderItemMaterial,
      _InvoiceItem.PurchaseOrderQuantityUnit,

      _InvoiceItem.TaxCode,

      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
      _InvoiceItem.QuantityInPurchaseOrderUnit,

      _InvoiceItem.CompanyCode,
      _InvoiceItem.Country,
      _InvoiceItem.PostingDate,
      _InvoiceItem.PostingYearMonth,
      _InvoiceItem.InvoicingParty,
      _InvoiceItem.DocumentCurrency,
      _InvoiceItem.PaymentMethod,
      _InvoiceItem.SupplyingCountry,
      _Supplier.AddressID,
      _Supplier.OrganizationBPName1,
      _Supplier.OrganizationBPName2,
      _Supplier.CityName,
      _Supplier.PostalCode,
      _Supplier.StreetName,
      _Supplier.PhoneNumber1,

      _InvoiceItem.PurchaseOrderItemText,
      _InvoiceItem.NetPriceQuantity,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      _InvoiceItem.NetPriceAmount,

      cast(_InvoiceItem._Payment.PaymentMethodName as tx042z_kk) as PaymentMethodName,
      _InvoiceItem.NetDueDate,
      _InvoiceItem.OrderID,
      _InvoiceItem.SetID,
      _InvoiceItem.SetDescription,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      _InvoiceItem.SupplierInvoiceItemAmount_Doc,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      _InvoiceItem.TaxAmount_Doc,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      _InvoiceItem.InvoiceGrossAmount_Doc,

      cast(_InvoiceItem._SupplierPurchasingOrg.PurchaseOrderCurrency as fclm_lp_cv_curr) as SumCurrency,

      @Semantics.amount.currencyCode: 'SumCurrency'
      currency_conversion(amount => _InvoiceItem.SupplierInvoiceItemAmount_Doc,
                          round => '',
                          source_currency => _InvoiceItem.DocumentCurrency,
                          target_currency => _InvoiceItem._SupplierPurchasingOrg.PurchaseOrderCurrency,
                          exchange_rate_date => _InvoiceItem.PostingDate) as ItemAmount_CC,

      @Semantics.amount.currencyCode: 'SumCurrency'
      currency_conversion(amount => _InvoiceItem.TaxAmount_Doc,
                          round => '',
                          source_currency => _InvoiceItem.DocumentCurrency,
                          target_currency => _InvoiceItem._SupplierPurchasingOrg.PurchaseOrderCurrency,
                          exchange_rate_date => _InvoiceItem.PostingDate) as TaxAmount_CC,

      @Semantics.amount.currencyCode: 'SumCurrency'
      currency_conversion(amount => _InvoiceItem.InvoiceGrossAmount_Doc,
                          round => '',
                          source_currency => _InvoiceItem.DocumentCurrency,
                          target_currency => _InvoiceItem._SupplierPurchasingOrg.PurchaseOrderCurrency,
                          exchange_rate_date => _InvoiceItem.PostingDate) as GrossAmount_CC,

      _TaxRate.TaxRate,

      _Taxnumber,
      _Company,
      _TaxRate,
      _Supplier,
      _SupplierPurchasingOrg,
      _Payment,
      _OrderInfo
}
