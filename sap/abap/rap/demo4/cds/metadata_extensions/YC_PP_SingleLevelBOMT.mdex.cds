@Metadata.layer: #CUSTOMER
@UI: {
headerInfo: {
typeName: '{@i18n>listTitle}',
typeNamePlural: '{@i18n>listTitle}'
}
}
@UI.presentationVariant: [{
  sortOrder: [
    { by: 'Plant',          direction: #ASC },
    { by: 'Material',       direction: #ASC },
    { by: 'AlternativeBOM', direction: #ASC },
    { by: 'ItemNumber',     direction: #ASC }
  ],
  visualizations: [{ type: #AS_LINEITEM }]
}]

annotate entity YC_PP_SingleLevelBOMT with
{

  @UI.selectionField: [{ position: 1 }]
  @UI.lineItem: [{ position: 3, importance: #HIGH }]
  Plant;
  @UI.selectionField: [{ position: 4 }]
  @UI.lineItem: [{ position: 6, importance: #MEDIUM }]
  BOMUsage;
  @UI.selectionField: [{ position: 2 } ]
  @UI.lineItem: [{ position: 7, importance: #MEDIUM, label: '{@i18n>Material}'}]
  Material;
  @UI.hidden: true
  BillOfMaterial;
  @UI.selectionField: [{ position: 5 }]
  @UI.lineItem: [{ position: 11, importance: #MEDIUM }]
  AlternativeBOM;
  @UI.hidden: true
  BillOfMaterialItemNodeNumber;
  @UI.lineItem: [{ position: 1, importance: #HIGH }]
  FunctionType;
  @UI.lineItem: [{ position: 2, importance: #HIGH }]
  ProcessingDate;
  @UI.lineItem: [{ position: 4, importance: #MEDIUM }]
  PlantName;
  @UI.selectionField: [{ position: 6 }]
  @UI.lineItem: [{ position: 5, importance: #HIGH }]
  ValidFromDate;
  @UI.selectionField: [{ position: 3 }]
  @UI.lineItem: [{ position: 8, importance: #MEDIUM, label: '{@i18n>MaterialDescription}'}]
  MaterialDescription;
  @UI.selectionField: [{ position: 7 }]
  @UI.lineItem: [{ position: 9, importance: #MEDIUM }]
  MaterialGroup;
  @UI.lineItem: [{ position: 10, importance: #MEDIUM }]
  MaterialGroupName;
  @UI.lineItem: [{ position: 12, importance: #MEDIUM }]
  AlternativeText;
  @UI.lineItem: [{ position: 13, importance: #MEDIUM }]
  BaseQuantity;
  @UI.lineItem: [{ position: 14, importance: #MEDIUM }]
  BaseUnit;
  @UI.selectionField: [{ position: 10 }]
  @UI.lineItem: [{ position: 15, importance: #MEDIUM }]
  DeletionFlag;
  @UI.lineItem: [{ position: 16, importance: #MEDIUM }]
  BOMStatus;
  @UI.lineItem: [{ position: 17, importance: #MEDIUM }]
  HierarchyLevel;
  @UI.lineItem: [{ position: 18, importance: #MEDIUM }]
  ProductionVersion;
  @UI.lineItem: [{ position: 19, importance: #MEDIUM }]
  TopLevelMaterial;
  @UI.lineItem: [{ position: 20, importance: #MEDIUM }]
  PreviousParentMaterial;
  @UI.selectionField: [{ position: 8 }]
  @UI.lineItem: [{ position: 21, importance: #MEDIUM }]
  MRPController;
  @UI.lineItem: [{ position: 22, importance: #MEDIUM }]
  MRPControllerName;
  @UI.selectionField: [{ position: 9 }]
  @UI.lineItem: [{ position: 23, importance: #MEDIUM }]
  ProductionSupervisor;
  @UI.lineItem: [{ position: 24, importance: #MEDIUM }]
  ProductionSupervisorName;
  @UI.lineItem: [{ position: 25, importance: #MEDIUM }]
  ItemNumber;
  @UI.lineItem: [{ position: 26, importance: #MEDIUM }]
  ItemCategory;
  @UI.lineItem: [{ position: 27, importance: #MEDIUM }]
  ComponentMaterial;
  @UI.lineItem: [{ position: 28, importance: #MEDIUM }]
  ComponentDescription;
  @UI.lineItem: [{ position: 29, importance: #MEDIUM }]
  ItemText;
  @UI.lineItem: [{ position: 30, importance: #MEDIUM }]
  ComponentQuantity;
  @UI.lineItem: [{ position: 31, importance: #MEDIUM }]
  ComponentUnit;
  @UI.lineItem: [{ position: 32, importance: #MEDIUM }]
  FixedQuantity;
  @UI.lineItem: [{ position: 33, importance: #MEDIUM }]
  LeadTimeOffset;
  @UI.lineItem: [{ position: 34, importance: #MEDIUM }]
  IssueLocation;
  @UI.lineItem: [{ position: 35, importance: #MEDIUM }]
  IssueLocationText;
  @UI.lineItem: [{ position: 36, importance: #MEDIUM }]
  Recursive;
  @UI.lineItem: [{ position: 37, importance: #MEDIUM }]
  RelevancytoCosting;
}