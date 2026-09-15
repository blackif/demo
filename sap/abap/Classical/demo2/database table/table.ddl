@EndUserText.label : 'Table of Variant Variables'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #C
@AbapCatalog.dataMaintenance : #ALLOWED
define table yxacmn0001_001 {

  key mandt : mandt not null;
  key name  : zevari_name not null;
  key type  : zesel_type not null;
  key numb  : zesel_numb not null;
  sign      : zeddsign;
  opti      : zeddoption;
  low       : zevari_val_255;
  high      : zevari_val_255;

}