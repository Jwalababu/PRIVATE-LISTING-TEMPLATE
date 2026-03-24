-- =============================================================================
-- PRIVATE LISTING TEMPLATE — Share-Based (No Application Package)
-- =============================================================================
-- Objects shared:
--   SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER
--   SAMPLE_DATA.TPCDS_SF100TCL.ITEM
--   SAMPLE_DATA.TPCDS_SF100TCL.STORE
--   SAMPLE_DATA.TPCDS_SF100TCL.STORE_SALES
-- =============================================================================

-- =============================================================================
-- SECTION 0: ONE-TIME ADMIN SETUP — CCAF & ECO (requires ORGADMIN)
-- =============================================================================
-- Run these commands ONCE per organization/account to enable Cross-Cloud
-- Auto-Fulfillment (CCAF) and Egress Cost Optimizer (ECO).

-- 0a. Enable Cross-Cloud Auto-Fulfillment for this account (ORGADMIN required)
USE ROLE ORGADMIN;
SELECT SYSTEM$ENABLE_GLOBAL_DATA_SHARING_FOR_ACCOUNT('<ACCOUNT_NAME>');

-- 0b. Verify CCAF is enabled
SELECT SYSTEM$IS_GLOBAL_DATA_SHARING_ENABLED_FOR_ACCOUNT('<ACCOUNT_NAME>');

-- 0c. Authorize & enable Egress Cost Optimizer (ECO)
--     ECO authorization at the org level must be done via Snowsight UI:
--       Marketplace > Provider Studio > Home > Get Started > Authorize
--     After org-level authorization, enable ECO at account level via Snowsight:
--       Marketplace > Provider Studio > Settings > Cross-Cloud Auto-Fulfillment
--       > Toggle "Egress Cost Optimizer" ON

-- 0d. (Optional) Delegate CCAF management to a non-ACCOUNTADMIN role
USE ROLE ACCOUNTADMIN;
-- GRANT MANAGE LISTING AUTO FULFILLMENT ON ACCOUNT TO ROLE <role_name>;

-- =============================================================================

USE ROLE ACCOUNTADMIN;

-- =============================================================================
-- SECTION 1: CREATE SHARE AND GRANT ACCESS TO OBJECTS
-- =============================================================================

CREATE SHARE TPCDS_SHARE;

GRANT USAGE ON DATABASE SAMPLE_DATA TO SHARE TPCDS_SHARE;
GRANT USAGE ON SCHEMA SAMPLE_DATA.TPCDS_SF100TCL TO SHARE TPCDS_SHARE;
GRANT SELECT ON TABLE SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER TO SHARE TPCDS_SHARE;
GRANT SELECT ON TABLE SAMPLE_DATA.TPCDS_SF100TCL.ITEM TO SHARE TPCDS_SHARE;
GRANT SELECT ON TABLE SAMPLE_DATA.TPCDS_SF100TCL.STORE TO SHARE TPCDS_SHARE;
GRANT SELECT ON TABLE SAMPLE_DATA.TPCDS_SF100TCL.STORE_SALES TO SHARE TPCDS_SHARE;

-- =============================================================================
-- SECTION 2: VERIFY SHARE
-- =============================================================================

SHOW SHARES;
DESCRIBE SHARE TPCDS_SHARE;

-- =============================================================================
-- SECTION 3: GET YOUR ORGANIZATION NAME
-- =============================================================================

SELECT CURRENT_ORGANIZATION_NAME();

-- =============================================================================
-- SECTION 4: CREATE PRIVATE LISTING
-- =============================================================================
-- Works for both in-region and cross-region consumers. CCAF (Section 0)
-- handles cross-region replication automatically when the consumer is in
-- a different region.
-- Replace <ORG_NAME> and <ACCOUNT_NAME> with the consumer's identifiers.

CREATE EXTERNAL LISTING TPCDS_LISTING
SHARE TPCDS_SHARE AS
$$
title: "TPCDS Sample Data"
subtitle: "Customer, Item, Store, and Store Sales from TPC-DS SF100TCL"
description: "Private listing providing read-only access to TPCDS SF100TCL tables: CUSTOMER, ITEM, STORE, and STORE_SALES. Supports in-region and cross-region consumers via Cross-Cloud Auto-Fulfillment."
listing_terms:
  type: "OFFLINE"
targets:
  accounts: ["<ORG_NAME>.<ACCOUNT_NAME>"]
$$
PUBLISH = FALSE
REVIEW = FALSE;

ALTER LISTING TPCDS_LISTING PUBLISH;

-- =============================================================================
-- SECTION 5: ADD CUSTOMER ACCOUNTS TO THE LISTING
-- =============================================================================

ALTER LISTING TPCDS_LISTING ADD TARGETS
$$
targets:
  accounts: ["<ORG_NAME>.<NEW_ACCOUNT_1>", "<ORG_NAME>.<NEW_ACCOUNT_2>"]
$$;

-- =============================================================================
-- SECTION 6: REMOVE CUSTOMER ACCOUNTS FROM THE LISTING
-- =============================================================================

ALTER LISTING TPCDS_LISTING REMOVE TARGETS
$$
targets:
  accounts: ["<ORG_NAME>.<ACCOUNT_TO_REMOVE>"]
$$;

-- =============================================================================
-- SECTION 7: USEFUL MANAGEMENT COMMANDS
-- =============================================================================

SHOW LISTINGS;

DESCRIBE LISTING TPCDS_LISTING;

-- Unpublish a listing (existing consumers retain access)
-- ALTER LISTING TPCDS_LISTING UNPUBLISH;

-- Drop a listing entirely
-- DROP LISTING TPCDS_LISTING;

-- =============================================================================
-- SECTION 8: CONSUMER INSTALL WORKFLOW (run on consumer account)
-- =============================================================================

-- Create a database from the listing share
-- CREATE DATABASE TPCDS_SHARED FROM LISTING '<LISTING_GLOBAL_NAME>';

-- Verify
-- SHOW SCHEMAS IN DATABASE TPCDS_SHARED;
-- SHOW TABLES IN TPCDS_SHARED.TPCDS_SF100TCL;
-- SELECT * FROM TPCDS_SHARED.TPCDS_SF100TCL.CUSTOMER LIMIT 10;
