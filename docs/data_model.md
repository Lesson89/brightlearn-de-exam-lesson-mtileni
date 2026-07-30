# BrightLearn Gold Layer — Data Model

## Overview
The Gold layer implements a Kimball-style star schema: one central fact table
(`fact_sales_line_item`) at the grain of one row per sales line item, surrounded
by five dimension tables, plus a second fact table (`fact_inventory_snapshot`)
for the June 2024 stock snapshot.

## Entity Relationship Diagram

```mermaid
erDiagram
    dim_date ||--o{ fact_sales_line_item : "date_key"
    dim_store ||--o{ fact_sales_line_item : "store_key"
    dim_customer ||--o{ fact_sales_line_item : "customer_key"
    dim_product ||--o{ fact_sales_line_item : "product_key"
    dim_cashier ||--o{ fact_sales_line_item : "cashier_key"
    dim_store ||--o{ fact_inventory_snapshot : "store_key"
    dim_product ||--o{ fact_inventory_snapshot : "product_key"

    dim_date {
        int date_key PK
        date full_date
        int day_num
        int month_num
        string month_name
        int quarter_num
        int year_num
    }

    dim_store {
        int store_key PK
        string store_name
        string store_city
        string store_province
        string store_region
        string store_manager
    }

    dim_customer {
        int customer_key PK
        int source_transaction_id
        string customer_email
        string first_name
        string last_name
        string phone
        string city
        string province
        string loyalty_tier
        date customer_since
        bit is_guest
    }

    dim_product {
        int product_key PK
        string sku
        string product_name
        string category
        string sub_category
        string supplier
        decimal unit_price
        decimal cost_price
    }

    dim_cashier {
        int cashier_key PK
        string cashier_name
    }

    fact_sales_line_item {
        int line_item_key PK
        int transaction_id
        int date_key FK
        int store_key FK
        int customer_key FK
        int product_key FK
        int cashier_key FK
        string payment_method
        decimal unit_price
        decimal cost_price
        int qty
        decimal line_amount
        decimal transaction_amount
        decimal transaction_discount
        bit is_refund
        bit is_guest
    }

    fact_inventory_snapshot {
        int snapshot_key PK
        date snapshot_date
        int store_key FK
        int product_key FK
        int stock_on_hand
        int reorder_threshold
        bit is_below_reorder_threshold
    }