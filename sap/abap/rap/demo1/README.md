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

## RAP Demo1 流程图

```mermaid
flowchart TD
    A[Service Binding] --> B[ZC_PP_ManufacturingOrder]
    B --> C[ZI_PP_ManufacturingOrder]

    C --> D[I_ManufacturingOrder]
    C --> E[ZI_PP_ACMSystemStatus]
    C --> F[I_ProductionVersion]
    C --> G[I_ProductText]
    C --> H[I_InventoryUsabilityCodeText]
    C --> I[ZI_PP_LongTextMapping]
    C --> J[I_StatusObjectStatusChange]

    B --> K[Virtual Element: LongText]
    K --> L[Z_PP_LONGTEXT_GET]
    L --> M[IF_SADL_EXIT_CALC_ELEMENT_READ]
    M --> N[get_calculation_info]
    M --> O[calculate]
    O --> P[READ_TEXT]
    P --> Q[LongText]

    D --> R[Manufacturing Order Data]
    E --> S[System Status]
    I --> T[Tdname]
    R --> U[Final Result]
    S --> U
    T --> U
    Q --> U

    U --> V[OData V4 Response]
```

## 简要调用关系

1. Service Binding 对外暴露 RAP Service。
2. Projection View `ZC_PP_ManufacturingOrder` 作为对外数据模型。
3. `ZC_PP_ManufacturingOrder` 基于 `ZI_PP_ManufacturingOrder`。
4. `ZI_PP_ManufacturingOrder` 从 `I_ManufacturingOrder` 获取生产订单，并通过 Join / Association 获取状态、生产版本、产品文本、库存可用性文本、长文本名称等数据。
5. `LongText` 是 Virtual Element，不直接从 CDS 数据库查询。
6. SADL 在处理 Virtual Element 时调用 `Z_PP_LONGTEXT_GET` 的 `IF_SADL_EXIT_CALC_ELEMENT_READ` 实现。
7. `calculate` 根据 `Tdname` 调用 `READ_TEXT` 获取长文本，并将结果写入 `LongText`。
8. SADL 将 CDS 数据和计算出的 `LongText` 组合后，通过 OData V4 返回最终结果。

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
└── README.md
```
