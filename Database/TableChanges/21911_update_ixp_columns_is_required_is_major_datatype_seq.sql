DECLARE @ixp_table_id INT 
-- Expiration Calendar Definition
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_holiday_calendar_template'

-- required
UPDATE ic SET is_required = 1 FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'hol_group_value_id'
	,'hol_date'
	,'exp_date'
)

-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'hol_group_value_id'
	,'hol_date'
	,'exp_date'
)

-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'hol_date'
	,'exp_date'
	,'hol_date_to'
)

--seq
UPDATE ic set seq = 10  FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'hol_group_value_id'
UPDATE ic set seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'hol_date'
UPDATE ic set seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'description'
UPDATE ic set seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'exp_date'
UPDATE ic set seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'hol_date_to'

-- =====================================================================================================================
-- Forecast Volume
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_deal_detail_hour_template'

-- required
UPDATE ic SET is_required = 1 FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'profile'
	,'term_date'
	,'is_dst'
	,'volume'
)

-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'profile'
	,'term_date'
	,'Hour'
	,'interval'
	,'is_dst'
)

-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'term_date'
)

--seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'profile'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'term_date'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Hour'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'interval'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'is_dst'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'volume'

-- =====================================================================================================================
-- Shaped Volume
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_source_deal_detail_15min_template'

-- required
UPDATE ic SET is_required = 1 FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'deal_id'
	,'term_date'
	,'hr'
	,'minute'
	,'is_dst'
	,'leg'
	,'volume'
)

-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'deal_id'
	,'term_date'
	,'hr'
	,'minute'
	,'is_dst'
	,'leg'
)

-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'term_date'
)

--seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'deal_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'term_date'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'hr'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'minute'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'is_dst'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'leg'
UPDATE ic SET seq = 70 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'volume'
UPDATE ic SET seq = 80 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'actual_volume'
UPDATE ic SET seq = 90 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'schedule_volume'
UPDATE ic SET seq = 100 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'price'

-- =====================================================================================================================
-- Holiday Calendar Definition
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_holiday_calendar_template'

-- required
UPDATE ic SET is_required = 1 FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'hol_group_value_id'
	,'hol_date'
	,'description'
)

-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'hol_group_value_id'
	,'hol_date'
)

-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'hol_date'
)

--seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'hol_group_value_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'description'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'hol_date'
-- =====================================================================================================================
-- Location Definition
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_location_template'

-- required
UPDATE ic SET is_required = 1 FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'location_id'
	,'Location_Name'
	,'Commodity_id'
)

-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'location_id'
)

-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'effective_date'
)

--seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'location_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Location_Name'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Location_Description'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'source_major_location_ID'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Commodity_id'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'term_pricing_index'
UPDATE ic SET seq = 70 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'profile_id'
UPDATE ic SET seq = 80 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'proxy_profile_id'
UPDATE ic SET seq = 90 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Meter_ID'
UPDATE ic SET seq = 100 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'meter_type'
UPDATE ic SET seq = 110 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'effective_date'

-- =====================================================================================================================
-- Trader Definition
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_source_trader_template'

-- required
UPDATE ic SET is_required = 1 FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'code'
	,'name'
)

-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'code'
)


--seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'trader_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'trader_name'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'trader_desc'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'user_login_id'

-- =====================================================================================================================
-- Commodity Definition
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_source_commodity_template'

-- required
UPDATE ic SET is_required = 1 FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'commodity_id'
	,'commodity_name'
)

-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'commodity_id'
)

--seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'commodity_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'commodity_name'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'commodity_desc'

-- ===================================================================================================================== **
-- Counterparty Credit Information
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_counterparty_credit_info_template'

-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'Counterparty_id'
	,'curreny_code'
)

-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'Counterparty_id'
)

-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'Date_established'
	,'Next_review_date'
	,'Last_review_date'
)
-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Counterparty_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'account_status'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Risk_rating'
UPDATE ic SET seq = 70 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Debt_rating'
UPDATE ic SET seq = 80 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Debt_Rating2'
UPDATE ic SET seq = 90 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Debt_Rating3'
UPDATE ic SET seq = 100 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Debt_Rating4'
UPDATE ic SET seq = 110 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Debt_Rating5'
UPDATE ic SET seq = 120 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Industry_type1'
UPDATE ic SET seq = 130 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Industry_type2'
UPDATE ic SET seq = 140 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'SIC_Code'
UPDATE ic SET seq = 150 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Duns_No'
UPDATE ic SET seq = 160 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Ticker_symbol'
UPDATE ic SET seq = 170 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Date_established'
UPDATE ic SET seq = 180 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Next_review_date'
UPDATE ic SET seq = 190 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Last_review_date'
UPDATE ic SET seq = 200 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Customer_since'
UPDATE ic SET seq = 210 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'curreny_code'

-- ===================================================================================================================== **
-- Contract Definition
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_contract_template'

-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'source_contract_id'
	,'contract_name'
	,'contract_type_def_id'
	,'currency'
	,'volume_uom'
	,'commodity'
	,'volume_granularity'
	,'invoice_report_template'
	,'contract_report_template'
	,'netting_template'
	,'contract_email_template'
)

-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'source_contract_id'
)

-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'source_contract_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'contract_name'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'contract_desc'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'contract_type_def_id'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'contract_status'
UPDATE ic SET seq = 100 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'currency'
UPDATE ic SET seq = 110 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'volume_uom'
UPDATE ic SET seq = 120 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'commodity'
UPDATE ic SET seq = 130 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'volume_granularity'
UPDATE ic SET seq = 140 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'contract_charge_type_id'
UPDATE ic SET seq = 200 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'settlement_date'
UPDATE ic SET seq = 210 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'settlement_days'
UPDATE ic SET seq = 230 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'invoice_due_date'
UPDATE ic SET seq = 240 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'payment_days'
UPDATE ic SET seq = 260 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'netting_statement'
UPDATE ic SET seq = 280 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'invoice_report_template'
UPDATE ic SET seq = 290 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'contract_report_template'
UPDATE ic SET seq = 300 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'netting_template'
UPDATE ic SET seq = 310 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'contract_email_template'

-- ===================================================================================================================== **
-- Counterparty Contact Definition
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_counterparty_contacts'

-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'counterparty_id'
	,'id'
)

-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'counterparty_id'
	,'is_primary'
)

-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'counterparty_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'title'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'name'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'contact_type'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'id'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'address1'
UPDATE ic SET seq = 70 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'address2'
UPDATE ic SET seq = 80 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'zip'
UPDATE ic SET seq = 90 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'state'
UPDATE ic SET seq = 100 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'region'
UPDATE ic SET seq = 110 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'city'
UPDATE ic SET seq = 120 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'country'
UPDATE ic SET seq = 130 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'telephone'
UPDATE ic SET seq = 140 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'cell_no'
UPDATE ic SET seq = 150 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'fax'
UPDATE ic SET seq = 160 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'email'
UPDATE ic SET seq = 170 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'email_cc'
UPDATE ic SET seq = 180 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'email_bcc'
UPDATE ic SET seq = 190 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'comment'
UPDATE ic SET seq = 200 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'is_primary'
UPDATE ic SET seq = 210 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'is_active'

-- ===================================================================================================================== **
-- Counterparty Contract Definition
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_counterparty_contract_address_template'

-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'counterparty_id'
	,'contract_id'
)

-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'counterparty_id'
	,'contract_id'
	,'internal_counterparty_id'
)

-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'contract_date'
	,'contract_start_date'
	,'contract_end_date'
)

-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'counterparty_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'contract_id'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'internal_counterparty_id'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'contract_status'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'contract_date'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'contract_start_date'
UPDATE ic SET seq = 70 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'contract_end_date'
UPDATE ic SET seq = 120 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'margin_provision'
UPDATE ic SET seq = 130 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'company_trigger'
UPDATE ic SET seq = 140 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'counterparty_trigger'
UPDATE ic SET seq = 150 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'rounding'
UPDATE ic SET seq = 160 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'interest_method'
UPDATE ic SET seq = 170 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'interest_rate'
UPDATE ic SET seq = 180 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'threshold_provided'
UPDATE ic SET seq = 190 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'threshold_received'
UPDATE ic SET seq = 210 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'offset_method'
UPDATE ic SET seq = 250 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'apply_netting_rule'
UPDATE ic SET seq = 260 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'billing_start_month'
UPDATE ic SET seq = 270 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'receivables'
UPDATE ic SET seq = 280 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'payables'
UPDATE ic SET seq = 290 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'confirmation'

-- ===================================================================================================================== **
-- Counterparty Definition
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_source_counterparty_template'

-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'counterparty_name'
	,'int_ext_flag'
)

-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'counterparty_id'
)

-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'counterparty_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'counterparty_name'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'counterparty_desc'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'parent_counterparty_id'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'int_ext_flag'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'type_of_entity'
UPDATE ic SET seq = 110 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'delivery_method'
-- ===================================================================================================================== **
-- Product Detail
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_product_detail_template'

-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'deal_id'
	,'in_or_not'
)

-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'deal_id'
	,'in_or_not'
	,'region'
	,'jurisdiction'
	,'tier'
	,'technology'
	,'vintage'
)

-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'deal_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'in_or_not'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'region'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'jurisdiction'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'tier'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'technology'
UPDATE ic SET seq = 70 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'vintage'
-- ===================================================================================================================== 
-- REC Certificate
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_rec_certified_volume'

-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'deal_id'
	,'production_start_date'
	,'production_end_date'
	,'jurisdiction'
	,'tier'
	,'issue_date'
	,'expiry_date'
	,'year'
	,'certificate_start_id'
	,'certificate_end_id'
	,'certificate_seq_from'
	,'certificate_seq_to'
)
-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'deal_id'
	,'production_start_date'
	,'production_end_date'
	,'jurisdiction'
	,'tier'
	,'certification_entity'
)
-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'production_start_date'
	,'production_end_date'
	,'issue_date'
	,'expiry_date'
)
-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'deal_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'production_start_date'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'production_end_date'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'jurisdiction'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'tier'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'certification_entity'
UPDATE ic SET seq = 70 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'issue_date'
UPDATE ic SET seq = 80 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'expiry_date'
UPDATE ic SET seq = 90 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'year'
UPDATE ic SET seq = 100 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'certificate_start_id'
UPDATE ic SET seq = 110 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'certificate_end_id'
UPDATE ic SET seq = 120 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'certificate_seq_from'
UPDATE ic SET seq = 130 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'certificate_seq_to'
-- ===================================================================================================================== 
-- REC Deal Import
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_source_deal_template'
-- major set to 0
UPDATE ic
SET is_major = 0
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'deal_id'
	,'deal_date'
	,'sub_book'
	,'trader_id'
	,'counterparty_id'
	,'contract_id'
	,'pricing_type'
	,'source_deal_type_id'
	,'template_id'
	,'header_buy_sell_flag'
	,'term_start'
	,'term_end'
	,'curve_id'
	,'fixed_price_currency_id'
)
-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'deal_id'
	,'term_start'
)
-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'deal_date'
	,'delivery_date'
)
-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'deal_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'deal_date'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'sub_book'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'trader_id'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'counterparty_id'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'contract_id'
UPDATE ic SET seq = 70 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'pricing_type'
UPDATE ic SET seq = 80 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'source_deal_type_id'
UPDATE ic SET seq = 90 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'template_id'
UPDATE ic SET seq = 100 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'header_buy_sell_flag'
UPDATE ic SET seq = 111 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'generator_id'
UPDATE ic SET seq = 120 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'term_start'
UPDATE ic SET seq = 130 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'term_end'
UPDATE ic SET seq = 141 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'vintage_id'
UPDATE ic SET seq = 150 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'match_type'
UPDATE ic SET seq = 161 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'delivery_date'
UPDATE ic SET seq = 171 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'product_classification'
UPDATE ic SET seq = 181 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'state_value_id'
UPDATE ic SET seq = 191 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'tier_id'
UPDATE ic SET seq = 200 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'curve_id'
UPDATE ic SET seq = 210 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'meter_id'
UPDATE ic SET seq = 220 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'contractual_volume'
UPDATE ic SET seq = 230 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'schedule_volume'
UPDATE ic SET seq = 240 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'actual_volume'
UPDATE ic SET seq = 260 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'fixed_price'
UPDATE ic SET seq = 270 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'fixed_price_currency_id'
UPDATE ic SET seq = 280 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'formula_curve_id'
UPDATE ic SET seq = 290 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'price_adder'
UPDATE ic SET seq = 300 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'formula_id'
UPDATE ic SET seq = 310 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'status'
-- ===================================================================================================================== 
-- REC Volume
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_rec_volumes'

-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'deal_id'
	,'vintage_start'
)
-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'deal_id'
	,'vintage_start'
)
-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'vintage_start'
)
-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'deal_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'vintage_start'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'forecast_volume'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'actual_volume'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'certified_volume'
-- ===================================================================================================================== 
-- REC Inventory
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_rec_inventory'

-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'generator'
	,'vintage_month'
	,'vintage_year'
	,'jurisdiction'
	,'tier'
	,'certificate_serial_numbers_from'
	,'certificate_serial_numbers_to'
	,'volume'
	,'certificate_seq_from'
	,'certificate_seq_to'
	,'issue_date'
	,'expiry_date'
)
-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'generator'
	,'vintage_month'
	,'vintage_year'
	,'jurisdiction'
	,'tier'
)
-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'issue_date'
	,'expiry_date'
)
-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'generator'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'vintage_month'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'vintage_year'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'jurisdiction'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'tier'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'certificate_serial_numbers_from'
UPDATE ic SET seq = 70 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'certificate_serial_numbers_to'
UPDATE ic SET seq = 80 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'volume'
UPDATE ic SET seq = 90 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'certificate_seq_from'
UPDATE ic SET seq = 100 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'certificate_seq_to'
UPDATE ic SET seq = 110 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'issue_date'
UPDATE ic SET seq = 120 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'expiry_date'
-- ===================================================================================================================== 
-- REC RPS Import
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_rec_rps_import_template'

-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'compliance_period'
	,'retirement_types'
	,'vintage_year'
	,'vintage_month'
	,'jurisdiction'
	,'tier'
	,'transferee_counterparty'
	,'volume'
	,'certificate_from'
	,'sequence_to'
	,'certificate_to'
	,'sequence_from'
)
-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'compliance_period'
	,'retirement_types'
	,'vintage_year'
	,'vintage_month'
	,'jurisdiction'
	,'tier'
)
-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'delivery_date'
)
-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'compliance_period'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'retirement_types'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'vintage_year'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'vintage_month'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'delivery_date'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'jurisdiction'
UPDATE ic SET seq = 70 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'tier'
UPDATE ic SET seq = 80 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'generator'
UPDATE ic SET seq = 90 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'transferee_counterparty'
UPDATE ic SET seq = 100 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'transferor_counterparty'
UPDATE ic SET seq = 110 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'volume'
UPDATE ic SET seq = 120 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'certificate_from'
UPDATE ic SET seq = 130 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'certificate_to'
UPDATE ic SET seq = 140 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'sequence_from'
UPDATE ic SET seq = 150 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'sequence_to'
-- ===================================================================================================================== 
-- Counterparty Enhancement Data
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'

-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'counterparty_credit_info_id'
	,'enhance_type'
	,'eff_date'
	,'amount'
	,'currency_code'
)
-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'counterparty_credit_info_id'
	,'contract_id'
	,'internal_counterparty'
	,'enhance_type'
	,'eff_date'
)
-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'eff_date'
	,'expiration_date'
)
-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'counterparty_credit_info_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'contract_id'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'internal_counterparty'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'enhance_type'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'deal_id'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'guarantee_counterparty'
UPDATE ic SET seq = 80 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'eff_date'
UPDATE ic SET seq = 90 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'expiration_date'
UPDATE ic SET seq = 100 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'amount'
UPDATE ic SET seq = 110 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'currency_code'
UPDATE ic SET seq = 120 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'margin'
UPDATE ic SET seq = 130 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'exclude_collateral'
-- ===================================================================================================================== 
-- Counterparty Unsecured Limit
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_counterparty_credit_limits_template'

-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'counterparty_id'
	,'effective_Date'
	,'credit_limit'
	,'currency_id'
)
-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'counterparty_id'
	,'contract_id'
	,'internal_counterparty_id'
	,'effective_Date'
)
-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'effective_Date'
)
-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'counterparty_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'contract_id'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'internal_counterparty_id'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'effective_Date'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'credit_limit'
UPDATE ic SET seq = 70 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'credit_limit_to_us'
UPDATE ic SET seq = 80 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'currency_id'
UPDATE ic SET seq = 90 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'max_threshold'
UPDATE ic SET seq = 100 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'min_threshold'
UPDATE ic SET seq = 110 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'tenor_limit'
-- ===================================================================================================================== 
-- Deals
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_source_deal_template'
-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'deal_id'
	,'deal_date'
	,'physical_financial_flag'
	,'trader_id'
	,'counterparty_id'
	,'contract_id'
	,'commodity_id'
	,'source_deal_type_id'
	,'template_id'
	,'pricing_type'
	,'header_buy_sell_flag'
	,'Leg'
	,'term_start'
	,'term_end'
	,'curve_id'
	,'deal_status'
	,'confirm_status_type'
	,'internal_desk_id'
	,'sub_book'
	,'deal_volume_frequency'
	,'deal_volume_uom_id'
	,'fixed_price_currency_id'
	,'deal_category_value_id'
	,'buy_sell_flag'
	,'fixed_float_leg'
)
-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'deal_id'
	,'Leg'
	,'term_start'
)
-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'deal_date'
	,'contract_expiration_date'
	,'payment_date'
)
-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'deal_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'deal_date'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'ext_deal_id'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'physical_financial_flag'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'trader_id'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'counterparty_id'
UPDATE ic SET seq = 70 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'contract_id'
UPDATE ic SET seq = 80 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'broker_id'
UPDATE ic SET seq = 90 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'commodity_id'
UPDATE ic SET seq = 100 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'source_deal_type_id'
UPDATE ic SET seq = 110 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'template_id'
UPDATE ic SET seq = 120 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'pricing_type'
UPDATE ic SET seq = 130 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'option_flag'
UPDATE ic SET seq = 140 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'option_type'
UPDATE ic SET seq = 151 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'option_excercise_type'
UPDATE ic SET seq = 160 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'header_buy_sell_flag'
UPDATE ic SET seq = 170 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Leg'
UPDATE ic SET seq = 180 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'term_start'
UPDATE ic SET seq = 190 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'term_end'
UPDATE ic SET seq = 200 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'location_id'
UPDATE ic SET seq = 210 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'curve_id'
UPDATE ic SET seq = 230 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'physical_financial_flag_detail'
UPDATE ic SET seq = 240 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'deal_status'
UPDATE ic SET seq = 250 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'confirm_status_type'
UPDATE ic SET seq = 260 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'internal_desk_id'
UPDATE ic SET seq = 270 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'block_define_id'
UPDATE ic SET seq = 280 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'profile_id'
UPDATE ic SET seq = 290 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'sub_book'
UPDATE ic SET seq = 300 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'deal_volume'
UPDATE ic SET seq = 310 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'deal_volume_frequency'
UPDATE ic SET seq = 320 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'deal_volume_uom_id'
UPDATE ic SET seq = 330 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'position_uom'
UPDATE ic SET seq = 340 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'multiplier'
UPDATE ic SET seq = 350 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'volume_multiplier2'
UPDATE ic SET seq = 360 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'standard_yearly_volume'
UPDATE ic SET seq = 370 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'fixed_price'
UPDATE ic SET seq = 380 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'option_strike_price'
UPDATE ic SET seq = 390 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'fixed_price_currency_id'
UPDATE ic SET seq = 400 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'fixed_cost'
UPDATE ic SET seq = 420 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'formula_curve_id'
UPDATE ic SET seq = 430 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'price_adder'
UPDATE ic SET seq = 440 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'adder_currency_id'
UPDATE ic SET seq = 450 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'formula_id'
UPDATE ic SET seq = 470 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'description1'
UPDATE ic SET seq = 480 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'description2'
UPDATE ic SET seq = 490 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'description3'
UPDATE ic SET seq = 500 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'description4'
UPDATE ic SET seq = 510 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'internal_portfolio_id'
UPDATE ic SET seq = 520 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'contract_expiration_date'
UPDATE ic SET seq = 530 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'counterparty_id2'
UPDATE ic SET seq = 540 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'trader_id2'
UPDATE ic SET seq = 550 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'fas_deal_type_value_id'
UPDATE ic SET seq = 560 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'profile_granularity'
UPDATE ic SET seq = 570 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'contractual_volume'
UPDATE ic SET seq = 580 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'internal_deal_subtype_value_id'
UPDATE ic SET seq = 590 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'internal_deal_type_value_id'
UPDATE ic SET seq = 600 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'meter_id'
UPDATE ic SET seq = 610 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'fx_conversion_rate'
UPDATE ic SET seq = 620 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'upstream_contract'
UPDATE ic SET seq = 630 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'upstream_counterparty'
UPDATE ic SET seq = 640 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'payment_date'
UPDATE ic SET seq = 650 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'strike_granularity'
UPDATE ic SET seq = 660 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'no_of_strikes'
UPDATE ic SET seq = 670 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'fx_conversion_market'
UPDATE ic SET seq = 680 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'fx_rounding'
UPDATE ic SET seq = 690 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'fx_option'
UPDATE ic SET seq = 700 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'internal_counterparty'
UPDATE ic SET seq = 710 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'counterparty_trader'
UPDATE ic SET seq = 720 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'status'
UPDATE ic SET seq = 730 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'actual_volume'
UPDATE ic SET seq = 740 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'schedule_volume'
UPDATE ic SET seq = 750 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'counterparty2_trader'
UPDATE ic SET seq = 770 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'deal_category_value_id'
UPDATE ic SET seq = 780 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'buy_sell_flag'
UPDATE ic SET seq = 790 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'fixed_float_leg'
-- ===================================================================================================================== 
-- Meter Definition
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_meter_id_template'
-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'recorderid'
	,'granularity'
	,'source_uom_id'
)
-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'recorderid'
)
-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'recorderid'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'granularity'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'source_uom_id'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'commodity_id'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'description'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'counterparty_id'
UPDATE ic SET seq = 70 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'channel'
UPDATE ic SET seq = 80 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'channel_description'
UPDATE ic SET seq = 90 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'mult_factor'
-- ===================================================================================================================== 
-- Price Curve Definition
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_source_price_curve_def_template'
-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'curve_id'
	,'curve_name'
	,'source_curve_type_value_id'
	,'commodity_id'
	,'source_currency_id'
	,'uom_id'
	,'Granularity'
)
-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'curve_id'
)
-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'curve_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'curve_name'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'source_curve_type_value_id'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'commodity_id'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'source_currency_id'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'uom_id'
UPDATE ic SET seq = 70 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Granularity'
UPDATE ic SET seq = 80 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'block_define_id'
UPDATE ic SET seq = 90 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'market_value_desc'
UPDATE ic SET seq = 100 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'market_value_id'
UPDATE ic SET seq = 110 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'source_currency_to_id'
UPDATE ic SET seq = 120 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'proxy_source_curve_def_id'
UPDATE ic SET seq = 130 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'monthly_index'
UPDATE ic SET seq = 140 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'proxy_curve_id3'
UPDATE ic SET seq = 150 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'settlement_curve_id'
UPDATE ic SET seq = 160 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'exp_calendar_id'
UPDATE ic SET seq = 170 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'holiday_calendar_id'
UPDATE ic SET seq = 180 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'curve_des'
-- ===================================================================================================================== 
-- Jurisdiction Market
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_compliance_jurisdiction'
-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'code'
	,'description'
)
-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'code'
)
-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'program_beginning_date'
)
-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'code'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'description'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'program_beginning_date'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'region'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'from_month'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'to_month'
UPDATE ic SET seq = 70 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'program_scope'

-- ===================================================================================================================== 
-- Tier Mapping
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_tier_mapping'
-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'state_value'
	,'tier'
	,'technology'
	,'banking_years'
)
-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'state_value'
	,'tier'
	,'technology'
	,'technology_subtype'
)
-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'state_value'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'tier'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'technology'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'technology_subtype'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'banking_years'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'price_index'
-- ===================================================================================================================== 
-- REC Generator
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_rec_generator'
-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'unit_id'
	,'start_date'
	,'facility_id'
	,'facility_name'
	,'facility_owner'
	,'generation_state'
	,'technology'
	,'eligibility_mapping_template'
)
-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'unit_id'
)
-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'start_date'
)
-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'unit_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'start_date'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'facility_id'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'facility_name'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'unit_name'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'facility_owner'
UPDATE ic SET seq = 70 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'generation_state'
UPDATE ic SET seq = 80 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'technology'
UPDATE ic SET seq = 90 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'eligibility_mapping_template'
UPDATE ic SET seq = 100 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'fuel_type'
UPDATE ic SET seq = 110 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'sub_book'
-- ===================================================================================================================== 
-- Eligibility Mapping
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_eligibility_mapping_template'
-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'template_name'
	,'jurisdiction_market'
	,'tier'
)
-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'template_name'
	,'jurisdiction_market'
	,'tier'
)
-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'template_name'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'jurisdiction_market'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'tier'
-- ===================================================================================================================== 
-- Price Curve Data
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_source_price_curve_template'
-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'source_curve_def_id'
	,'as_of_date'
	,'curve_source_value_id'
	,'maturity_date'
	,'is_dst'
	,'curve_value'
)
-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	'source_curve_def_id'
	,'as_of_date'
	,'curve_source_value_id'
	,'maturity_date'
	,'hour'
	,'minute'
	,'is_dst'
)
UPDATE ic
SET is_major = 0
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'bid_value'
	,'curve_value'
	,'ask_value'
)
-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'source_curve_def_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'as_of_date'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'curve_source_value_id'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'maturity_date'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'hour'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'minute'
UPDATE ic SET seq = 70 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'is_dst'
UPDATE ic SET seq = 80 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'bid_value'
UPDATE ic SET seq = 90 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'curve_value'
UPDATE ic SET seq = 100 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'ask_value'
-- ===================================================================================================================== 
-- Meter Data
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_meter_data_template'
-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'meter_id'
	,'channel'
	,'date'
	,'is_dst'
	,'value'
)
-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'meter_id'
	,'channel'
	,'date'
	,'hour'
	,'period'
	,'is_dst'
)
-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'date'
)
-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'meter_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'channel'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'date'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'hour'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'period'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'is_dst'
UPDATE ic SET seq = 70 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'value'
-- ===================================================================================================================== 
-- REC Meter Data
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables 
WHERE ixp_tables_name = 'ixp_import_rec_meters'
-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'meter_id'
	,'channel'
	,'date'
	,'is_dst'
	,'volume'
)
-- major
UPDATE ic
SET is_major = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'meter_id'
	,'channel'
	,'date'
	,'hour'
	,'minute'
	,'is_dst'
)
-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'date'
)
-- seq
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'meter_id'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'channel'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'date'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'hour'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'minute'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'is_dst'
UPDATE ic SET seq = 70 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'volume'