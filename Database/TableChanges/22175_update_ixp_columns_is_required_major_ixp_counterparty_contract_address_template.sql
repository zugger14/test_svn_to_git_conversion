DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_counterparty_contract_address_template'

--update is_required and is_major
UPDATE ixp_columns
SET is_required = 0, is_major = 0
WHERE ixp_table_id = @ixp_table_id

UPDATE ixp_columns
SET is_required = 1
WHERE ixp_table_id = @ixp_table_id 
	AND ixp_columns_name IN ('counterparty_id', 'contract_id')

UPDATE ixp_columns
SET is_major = 1
WHERE ixp_table_id = @ixp_table_id 
	AND ixp_columns_name IN ('counterparty_id', 'contract_id', 'internal_counterparty_id')

--update datatype
UPDATE ixp_columns
SET datatype = NULL
WHERE ixp_table_id = @ixp_table_id

UPDATE ixp_columns
SET datatype = '[datetime]'
WHERE ixp_table_id = @ixp_table_id 
	AND ixp_columns_name IN ('contract_start_date', 'contract_end_date', 'contract_date')

--update sequence
UPDATE ixp_columns
SET seq = NULL
WHERE ixp_table_id = @ixp_table_id
  
SELECT 'counterparty_id' [name], 10 [seq]
INTO #temp
UNION SELECT 'contract_id'				,20
UNION SELECT 'internal_counterparty_id' , 30
UNION SELECT 'contract_status'			, 40
UNION SELECT 'contract_date'			, 50
UNION SELECT 'contract_start_date'		, 60
UNION SELECT 'contract_end_date'		, 70
UNION SELECT 'analyst'					, 80
UNION SELECT 'time_zone'				, 90
UNION SELECT 'comments'					, 100
UNION SELECT 'contract_active'			, 110
UNION SELECT 'margin_provision'			, 120
UNION SELECT 'company_trigger'			, 130
UNION SELECT 'counterparty_trigger'		, 140
UNION SELECT 'rounding'					, 150
UNION SELECT 'interest_method'			, 160
UNION SELECT 'interest_rate'			, 170
UNION SELECT 'threshold_provided'		, 180
UNION SELECT 'threshold_received'		, 190
UNION SELECT 'min_transfer_amount'		, 200
UNION SELECT 'offset_method'			, 210
UNION SELECT 'invoice_due_date'			, 220
UNION SELECT 'payment_days'				, 230
UNION SELECT 'holiday_calendar_id'		, 240
UNION SELECT 'apply_netting_rule'		, 250
UNION SELECT 'billing_start_month'		, 260
UNION SELECT 'receivables'				, 270
UNION SELECT 'payables'					, 280
UNION SELECT 'confirmation'				, 290
UNION SELECT 'secondary_counterparty'	, 300

UPDATE ic SET seq = tmp.seq
FROM ixp_columns ic
INNER JOIN #temp tmp
	ON ic.ixp_columns_name = tmp.[name]
WHERE ixp_table_id = @ixp_table_id
