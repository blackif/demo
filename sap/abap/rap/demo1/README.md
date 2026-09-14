# RAP Demo1

这是一个 **SAP RAP（RESTful ABAP Programming Model）** 开发示例。

本 Demo 主要用于说明 **OData V4 - Web API** 的 RAP 开发方式。

## 开发内容

- RAP（RESTful ABAP Programming Model）
- OData V4 - Web API
- CDS View Entity
- Projection View
- Virtual Element
- SADL Exit
- `IF_SADL_EXIT_CALC_ELEMENT_READ`
- OData V4 Service Binding

## 示例概要

本 Demo 以生产订单（Manufacturing Order）为例，通过 RAP 构建 OData V4 Web API Service，并通过 Virtual Element 在运行时计算 Long Text 数据。

主要处理流程：

```text
OData V4 - Web API
        ↓
Service Binding
        ↓
Projection View
ZC_PP_ManufacturingOrder
        ↓
Interface / Composite View
ZI_PP_ManufacturingOrder
        ↓
Virtual Element
LongText
        ↓
SADL Exit
Z_PP_LONGTEXT_GET
        ↓
READ_TEXT
        ↓
OData V4 Response
```

## 目录结构

```text
demo1/
├── cds/
│   ├── ZC_PP_ManufacturingOrder
│   ├── ZI_PP_ACMSystemStatus
│   ├── ZI_PP_LongTextMapping
│   └── ZI_PP_ManufacturingOrder
├── scl/
│   └── z_pp_longtext_get.abap
├── flow_chart.md
└── README.md
```
