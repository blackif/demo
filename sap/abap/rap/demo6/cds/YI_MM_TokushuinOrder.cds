@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Payment Notification Data Order'

@Metadata.ignorePropagatedAnnotations: true

define view entity YI_MM_TokushuinOrder
  as select distinct from I_JournalEntryItem as _JournalItem

  association [0..1] to I_Setleaf as _SetInfo
    on _SetInfo.SetClass = '0103'
    and _SetInfo.SetSubClass is initial
    and (   (    _SetInfo.SetRangeOption = 'EQ'
             and _SetInfo.SetRangeFromValue = _JournalItem.OrderID)
         or (    _SetInfo.SetRangeOption = 'BT'
             and _SetInfo.SetRangeFromValue <= _JournalItem.OrderID
             and _SetInfo.SetRangeToValue >= _JournalItem.OrderID))

{
  key _JournalItem.PurchasingDocument,
  key _JournalItem.PurchasingDocumentItem,

      _JournalItem.OrderID,

      @ObjectModel.text.element: [ 'SetDescription' ]
      cast(_SetInfo.SetID as ace_ds_aufnr_grp) as SetID,

      @Semantics.text: true
      cast(_SetInfo._Set._SetHeaderText[Language=$session.system_language].SetDescription as /cum/group_txt) as SetDescription
}

where _JournalItem.OrderID is not initial
  and _JournalItem.PurchasingDocument is not initial
  and _JournalItem.ReferenceDocumentType = 'MKPF'
  and _JournalItem.SourceLedger = '0L'
  and _JournalItem.Ledger = '0L'
  and _SetInfo.SetID like 'T%'
  and _JournalItem._InternalOrder.IntOrderIndividualField10Value = 'X'
