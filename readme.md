# MuleSoft E-Commerce Integration Platform

A MuleSoft **API-led connectivity** showcase demonstrating how Experience, Process and System APIs can be designed and combined to expose e-commerce capabilities while integrating CRM and ERP systems.

The project focuses on **API design, orchestration, reusable RAML assets, error handling, idempotency and correlation-based traceability**.

---

## Architecture

The solution follows the three-layer API-led connectivity model:

```text
                         E-Commerce Consumer
                                  |
                                  v
                    +--------------------------+
                    |  Experience API          |
                    |  ecommerce-orders-xapi   |
                    +------------+-------------+
                                 |
                                 v
                    +--------------------------+
                    |  Process API             |
                    |  ecommerce-order-        |
                    |  process-api             |
                    +------------+-------------+
                                 |
                    +------------+-------------+
                    |                          |
                    v                          v
          +-------------------+      +-------------------+
          |   CRM System API  |      |   ERP System API  |
          |   crm-system-api  |      |   erp-system-api  |
          +-------------------+      +-------------------+
                    |                          |
                    v                          v
               Customer                 Products / Stock
                                         / Orders
```

### API Layers

| Layer      | API                           | Responsibility                           |
| ---------- | ----------------------------- | ---------------------------------------- |
| Experience | `ecommerce-orders-xapi`       | Consumer-facing order API                |
| Process    | `ecommerce-order-process-api` | Business orchestration                   |
| System     | `crm-system-api`              | Customer management                      |
| System     | `erp-system-api`              | Products, inventory and order management |

---

## Business Flow

The main business flow is the creation of an order.

```text
Client
  |
  | POST /api/v1/orders
  v
Experience API
  |
  v
Process API
  |
  +----> CRM System API
  |        |
  |        +---- Validate customer
  |
  +----> ERP System API
           |
           +---- Check products / stock
           |
           +---- Reserve stock
           |
           +---- Create order
  |
  v
Order response
```

The Process API is responsible for the business orchestration, while the Experience API provides a consumer-oriented contract.

---

## APIs

### 1. Experience API

**Application:** `ecommerce-orders-xapi`

The Experience API exposes the order capabilities required by the e-commerce consumer.

Main operations:

```text
POST /api/v1/orders
GET  /api/v1/orders/{orderId}
GET  /api/v1/orders/{orderId}/detail
POST /api/v1/orders/{orderId}/cancel
```

Responsibilities:

* Expose consumer-facing JSON APIs
* Validate and standardize API requests
* Propagate correlation information
* Support idempotent operations
* Delegate business processing to the Process API
* Expose consumer-friendly error responses

The XAPI does not directly access CRM or ERP systems.

---

### 2. Process API

**Application:** `ecommerce-order-process-api`

The Process API contains the business orchestration required to process orders.

Main operations:

```text
POST /api/v1/orders
GET  /api/v1/orders/{orderId}/details
POST /api/v1/orders/{orderId}/cancel
```

Responsibilities:

* Validate the customer through CRM
* Coordinate product and inventory operations through ERP
* Reserve stock before creating the order
* Orchestrate order creation
* Orchestrate order cancellation
* Consolidate information from CRM and ERP
* Handle business errors and conflicts

---

### 3. CRM System API

**Application:** `crm-system-api`

The CRM System API abstracts customer information from the underlying CRM system.

Main operation:

```text
GET /api/v1/crm/customers/{customerId}
```

The API returns customer information using XML.

Example:

```xml
<customer>
    <id>9a3d5c7e-1b2f-4d6a-8e9c-0f1a2b3c4d5e</id>
    <name>Marc Lefevre</name>
    <status>ACTIVE</status>
    <isPartner>false</isPartner>
    <email>marc.lefevre@example.com</email>
    <phone>+33656789012</phone>
</customer>
```

---

### 4. ERP System API

**Application:** `erp-system-api`

The ERP System API abstracts product, inventory and order management.

Main operations include:

```text
POST /api/v1/erp/orders
GET  /api/v1/erp/orders/{orderId}
POST /api/v1/erp/orders/{orderId}/canccel
GET  /api/v1/erp/products?ids=...
```

The ERP API manages the system-level operations required by the Process API.

---

## Order Creation Example

A consumer sends:

```http
POST /api/v1/orders
Content-Type: application/json
X-Correlation-Id: 7e4c9e11-3f12-4a89-9a81-28d1c7f0b5d2
Idempotency-Key: 8f1c4d92-231a-4288-9d21-99c011a0b3e1
```

```json
{
  "customerId": "9a3d5c7e-1b2f-4d6a-8e9c-0f1a2b3c4d5e",
  "items": [
    {
      "productId": "PROD-001",
      "quantity": 2,
      "unitPrice": 49.90
    },
    {
      "productId": "PROD-002",
      "quantity": 1,
      "unitPrice": 29.90
    }
  ]
}
```

The XAPI delegates the request to the Process API.

The Process API then coordinates:

```text
1. Validate customer
2. Check product / inventory
3. Reserve stock
4. Create ERP order
5. Return order result
```

Example response:

```json
{
  "orderId": "ORD-2026-000123",
  "status": "CONFIRMED",
  "totalAmount": 129.70,
  "message": "Order created successfully"
}
```

---

## Order Cancellation

Cancellation is also orchestrated by the Process API.

```text
Client
  |
  v
XAPI
  |
  v
Process API
  |
  +----> Retrieve order
  |
  +----> Validate cancellable status
  |
  +----> ERP cancellation
  |
  +----> Release reserved stock
  |
  v
CANCELLED
```

An order that has reached a non-cancellable state, such as `DELIVERED`, is rejected with a business conflict.

---

## API Design & Reusability

The project uses reusable **RAML Libraries and API Fragments** published through Anypoint Exchange.

Shared assets include:

* `OrderLib`
* Error payload definitions
* `X-Correlation-Id` trait
* `Idempotency-Key` trait
* Common error handling trait

Example:

```yaml
uses:
  OrderLib: /exchange_modules/.../order-library/1.0.0/order-library.raml
```

This allows the XAPI and Process API to reuse common data types while keeping their own API contracts.

---

## Error Handling

The APIs expose standardized error responses.

Example:

```json
{
  "code": 409,
  "message": "INSUFFICIENT_STOCK",
  "description": "Insufficient stock for product PROD-002",
  "correlationId": "7e4c9e11-3f12-4a89-9a81-28d1c7f0b5d2",
  "dateTime": "2026-09-28T15:20:00Z"
}
```

The project uses HTTP status codes together with business error codes to distinguish technical and business failures.

Examples include:

```text
400  INVALID_REQUEST
404  ORDER_NOT_FOUND
409  INSUFFICIENT_STOCK
409  ORDER_NOT_CANCELLABLE
500  INTERNAL_ERROR
```

---

## Cross-API Traceability

`X-Correlation-Id` is propagated across the API-led architecture:

```text
E-Commerce Consumer
        |
        | X-Correlation-Id
        v
      XAPI
        |
        | X-Correlation-Id
        v
      PAPI
        |
        +------------------+
        |                  |
        v                  v
      CRM SAPI          ERP SAPI
```

This makes it possible to trace a single business operation across multiple Mule applications.

---

## Idempotency

Idempotency is applied to operations where duplicate requests could create inconsistent business results.

For example:

```http
Idempotency-Key: 8f1c4d92-231a-4288-9d21-99c011a0b3e1
```

The same key can be used to safely retry an order creation request without unintentionally creating a duplicate order.

The same principle is applied to order cancellation.

---

## Project Structure

```text
mulesoft-ecommerce-integration-platform/
│
├── crm-system-api/
│
├── erp-system-api/
│
├── ecommerce-order-process-api/
│
├── ecommerce-orders-xapi/
│
└── README.md
```

Each Mule application is maintained as an independent API.

---

## Architecture Principles

The project demonstrates several MuleSoft integration principles:

* **Separation of concerns** between Experience, Process and System APIs
* **API reusability** through System APIs
* **Business orchestration** through Process APIs
* **Consumer-oriented contracts** through Experience APIs
* **Contract-first API design** with RAML
* **Reusable API assets** through Anypoint Exchange
* **Standardized error handling**
* **Distributed transaction considerations**
* **Idempotent business operations**
* **Cross-API traceability with correlation IDs**

