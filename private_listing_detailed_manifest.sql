-- =============================================================================
-- PRIVATE LISTING WITH DETAILED YAML MANIFEST
-- =============================================================================
-- This script replaces the inline CREATE LISTING command with a comprehensive
-- YAML manifest covering all relevant fields for a private listing.
--
-- Objects shared via TPCDS_SHARE:
--   SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER
--   SAMPLE_DATA.TPCDS_SF100TCL.ITEM
--   SAMPLE_DATA.TPCDS_SF100TCL.STORE
--   SAMPLE_DATA.TPCDS_SF100TCL.STORE_SALES
--
-- Prerequisites:
--   - TPCDS_SHARE already created with grants (see private_listing_template.sql)
--   - CCAF & ECO enabled (see Section 0 in private_listing_template.sql)
-- =============================================================================

USE ROLE ACCOUNTADMIN;

-- =============================================================================
-- CREATE PRIVATE LISTING WITH DETAILED YAML MANIFEST
-- =============================================================================
-- Replace all <PLACEHOLDER> values before executing.
-- Remove or comment out any optional sections you do not need.

CREATE EXTERNAL LISTING TPCDS_LISTING
SHARE TPCDS_SHARE AS
$$
-- ---------------------------------------------------------------------------
-- LISTING HEADER (required)
-- ---------------------------------------------------------------------------
title: "TPCDS Sample Data"
subtitle: "Customer, Item, Store, and Store Sales from TPC-DS SF100TCL"
description: |
  Private listing providing read-only access to four core TPC-DS SF100TCL tables:

  - **CUSTOMER** — Customer demographics and contact information
  - **ITEM** — Product catalog with pricing and category attributes
  - **STORE** — Retail store locations and operational details
  - **STORE_SALES** — Transactional point-of-sale records

  Supports both in-region and cross-region consumers via Cross-Cloud
  Auto-Fulfillment (CCAF) with Egress Cost Optimizer (ECO) enabled.
custom_contact: "<PROVIDER_EMAIL>"

-- ---------------------------------------------------------------------------
-- LISTING TERMS (required)
-- ---------------------------------------------------------------------------
listing_terms:
  type: "OFFLINE"

-- ---------------------------------------------------------------------------
-- TARGETS (required) — consumer accounts to share with
-- ---------------------------------------------------------------------------
targets:
  accounts: ["<ORG_NAME>.<ACCOUNT_NAME>"]

-- ---------------------------------------------------------------------------
-- AUTO-FULFILLMENT (required for cross-region consumers)
-- ---------------------------------------------------------------------------
auto_fulfillment:
  refresh_schedule: "120 MINUTE"
  refresh_type: "SUB_DATABASE"

-- ---------------------------------------------------------------------------
-- DATA ATTRIBUTES (optional for private listings)
-- ---------------------------------------------------------------------------
data_attributes:
  refresh_rate: DAILY
  geography:
    granularity:
      - COUNTRY
    geo_option: GLOBAL
    time:
      granularity: DAILY
      time_range:
        time_frame: LAST
        unit: YEARS
        value: 5

-- ---------------------------------------------------------------------------
-- DATA DICTIONARY (optional for private listings)
-- ---------------------------------------------------------------------------
data_dictionary:
  featured:
    database: "SAMPLE_DATA"
    objects:
      - name: "CUSTOMER"
        schema: "TPCDS_SF100TCL"
        domain: "TABLE"
      - name: "ITEM"
        schema: "TPCDS_SF100TCL"
        domain: "TABLE"
      - name: "STORE"
        schema: "TPCDS_SF100TCL"
        domain: "TABLE"
      - name: "STORE_SALES"
        schema: "TPCDS_SF100TCL"
        domain: "TABLE"

-- ---------------------------------------------------------------------------
-- DATA PREVIEW (optional for private listings)
-- ---------------------------------------------------------------------------
data_preview:
  has_pii: FALSE

-- ---------------------------------------------------------------------------
-- BUSINESS NEEDS (optional, max 6)
-- ---------------------------------------------------------------------------
business_needs:
  - name: "Market Analysis"
    description: "Retail transaction and store data for market analysis and reporting."

-- ---------------------------------------------------------------------------
-- CATEGORIES (optional for private listings)
-- ---------------------------------------------------------------------------
categories:
  - BUSINESS

-- ---------------------------------------------------------------------------
-- USAGE EXAMPLES (optional, max 10)
-- ---------------------------------------------------------------------------
usage_examples:
  - title: "Top 10 customers by purchase count"
    description: "Identify the most frequent buyers across all stores."
    query: |
      SELECT c.C_CUSTOMER_SK, c.C_FIRST_NAME, c.C_LAST_NAME, COUNT(*) AS purchase_count
      FROM TPCDS_SF100TCL.STORE_SALES ss
      JOIN TPCDS_SF100TCL.CUSTOMER c ON ss.SS_CUSTOMER_SK = c.C_CUSTOMER_SK
      GROUP BY c.C_CUSTOMER_SK, c.C_FIRST_NAME, c.C_LAST_NAME
      ORDER BY purchase_count DESC
      LIMIT 10;
  - title: "Revenue by store"
    description: "Aggregate net sales revenue per store location."
    query: |
      SELECT s.S_STORE_NAME, SUM(ss.SS_NET_PAID) AS total_revenue
      FROM TPCDS_SF100TCL.STORE_SALES ss
      JOIN TPCDS_SF100TCL.STORE s ON ss.SS_STORE_SK = s.S_STORE_SK
      GROUP BY s.S_STORE_NAME
      ORDER BY total_revenue DESC;
  - title: "Items sold by category"
    description: "Count of items sold grouped by item class and category."
    query: |
      SELECT i.I_CLASS, i.I_CATEGORY, COUNT(*) AS items_sold
      FROM TPCDS_SF100TCL.STORE_SALES ss
      JOIN TPCDS_SF100TCL.ITEM i ON ss.SS_ITEM_SK = i.I_ITEM_SK
      GROUP BY i.I_CLASS, i.I_CATEGORY
      ORDER BY items_sold DESC
      LIMIT 20;

-- ---------------------------------------------------------------------------
-- RESOURCES (optional for private listings)
-- ---------------------------------------------------------------------------
resources:
  documentation: "<DOCUMENTATION_URL>"

-- ---------------------------------------------------------------------------
-- RESHARING (optional — default is disabled)
-- ---------------------------------------------------------------------------
resharing:
  enabled: false
$$
PUBLISH = FALSE
REVIEW = FALSE;

-- Publish the listing
ALTER LISTING TPCDS_LISTING PUBLISH;
