-- ===========================================================================================================
-- Author: rsharma@pioneersolutionsglobal.com
-- Create date: 2015-02-10
-- Updated date: 2015-05-28
-- Description: Script to add PK in those tables which has IDENTITY column defined.
-- Updates: addd PK existence check for tables which have clustered index keys.
-- Issue ID: 12386
-- Database: TRMTracker_New_Framework
-- ===========================================================================================================
IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'adjustment_default_gl_codes_detail'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.adjustment_default_gl_codes_detail ADD CONSTRAINT PK_adjustment_default_gl_codes_detail PRIMARY KEY CLUSTERED (detail_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_adjustment_default_gl_codes_detail already exist in adjustment_default_gl_codes_detail'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'alert_actions'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.alert_actions ADD CONSTRAINT PK_alert_actions PRIMARY KEY CLUSTERED (alert_actions_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_alert_actions already exist in alert_actions'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'alert_output_status'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.alert_output_status ADD CONSTRAINT PK_alert_output_status PRIMARY KEY CLUSTERED (alert_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_alert_output_status already exist in alert_output_status'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'alert_table_relation'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.alert_table_relation ADD CONSTRAINT PK_alert_table_relation PRIMARY KEY CLUSTERED (alert_table_relation_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_alert_table_relation already exist in alert_table_relation'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'alert_table_where_clause'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.alert_table_where_clause ADD CONSTRAINT PK_alert_table_where_clause PRIMARY KEY CLUSTERED (alert_table_where_clause_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_alert_table_where_clause already exist in alert_table_where_clause'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'alert_users'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.alert_users ADD CONSTRAINT PK_alert_users PRIMARY KEY CLUSTERED (alert_users_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_alert_users already exist in alert_users'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'alert_workflows'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.alert_workflows ADD CONSTRAINT PK_alert_workflows PRIMARY KEY CLUSTERED (alert_workflows_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_alert_workflows already exist in alert_workflows'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'cached_curves'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.cached_curves ADD CONSTRAINT PK_cached_curves PRIMARY KEY CLUSTERED (ROWID)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_cached_curves already exist in cached_curves'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'calc_formula_value'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.calc_formula_value ADD CONSTRAINT PK_calc_formula_value PRIMARY KEY CLUSTERED (ID)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_calc_formula_value already exist in calc_formula_value'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'counterparty_contract_address'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.counterparty_contract_address ADD CONSTRAINT PK_counterparty_contract_address PRIMARY KEY CLUSTERED (counterparty_contract_address_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_counterparty_contract_address already exist in counterparty_contract_address'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'counterparty_contract_rate_schedule'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.counterparty_contract_rate_schedule ADD CONSTRAINT PK_counterparty_contract_rate_schedule PRIMARY KEY CLUSTERED (counterparty_contract_rate_schedule_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_counterparty_contract_rate_schedule already exist in counterparty_contract_rate_schedule'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'counterparty_limit_calc_result'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.counterparty_limit_calc_result ADD CONSTRAINT PK_counterparty_limit_calc_result PRIMARY KEY CLUSTERED (rowid)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_counterparty_limit_calc_result already exist in counterparty_limit_calc_result'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'counterpartyt_netting_stmt_status'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.counterpartyt_netting_stmt_status ADD CONSTRAINT PK_counterpartyt_netting_stmt_status PRIMARY KEY CLUSTERED (netting_stmt_status_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_counterpartyt_netting_stmt_status already exist in counterpartyt_netting_stmt_status'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'credit_exposure_calculation_log'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.credit_exposure_calculation_log ADD CONSTRAINT PK_credit_exposure_calculation_log PRIMARY KEY CLUSTERED (calculation_log_log_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_credit_exposure_calculation_log already exist in credit_exposure_calculation_log'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'deal_attestation_form'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.deal_attestation_form ADD CONSTRAINT PK_deal_attestation_form PRIMARY KEY CLUSTERED (attestation_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_deal_attestation_form already exist in deal_attestation_form'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'deal_confirmation_status'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.deal_confirmation_status ADD CONSTRAINT PK_deal_confirmation_status PRIMARY KEY CLUSTERED (deal_confirmation_status_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_deal_confirmation_status already exist in deal_confirmation_status'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'deal_position_break_down'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.deal_position_break_down ADD CONSTRAINT PK_deal_position_break_down PRIMARY KEY CLUSTERED (breakdown_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_deal_position_break_down already exist in deal_position_break_down'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'deal_reference_id_prefix'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.deal_reference_id_prefix ADD CONSTRAINT PK_deal_reference_id_prefix PRIMARY KEY CLUSTERED (deal_reference_id_prefix_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_deal_reference_id_prefix already exist in deal_reference_id_prefix'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'deal_schedule'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.deal_schedule ADD CONSTRAINT PK_deal_schedule PRIMARY KEY CLUSTERED (deal_schedule_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_deal_schedule already exist in deal_schedule'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'deal_status_group'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.deal_status_group ADD CONSTRAINT PK_deal_status_group PRIMARY KEY CLUSTERED (deal_status_group_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_deal_status_group already exist in deal_status_group'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'deal_status_privileges'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.deal_status_privileges ADD CONSTRAINT PK_deal_status_privileges PRIMARY KEY CLUSTERED (deal_status_privilege_ID)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_deal_status_privileges already exist in deal_status_privileges'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'dedesignation_criteria'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.dedesignation_criteria ADD CONSTRAINT PK_dedesignation_criteria PRIMARY KEY CLUSTERED (dedesignation_criteria_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_dedesignation_criteria already exist in dedesignation_criteria'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'dedesignation_criteria_result'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.dedesignation_criteria_result ADD CONSTRAINT PK_dedesignation_criteria_result PRIMARY KEY CLUSTERED (row_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_dedesignation_criteria_result already exist in dedesignation_criteria_result'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'default_holiday_calendar'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.default_holiday_calendar ADD CONSTRAINT PK_default_holiday_calendar PRIMARY KEY CLUSTERED (id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_default_holiday_calendar already exist in default_holiday_calendar'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'delivery_path'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.delivery_path ADD CONSTRAINT PK_delivery_path PRIMARY KEY CLUSTERED (path_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_delivery_path already exist in delivery_path'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'edr_as_imported'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.edr_as_imported ADD CONSTRAINT PK_edr_as_imported PRIMARY KEY CLUSTERED (RECID)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_edr_as_imported already exist in edr_as_imported'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'edr_file_map_detail'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.edr_file_map_detail ADD CONSTRAINT PK_edr_file_map_detail PRIMARY KEY CLUSTERED (RECID)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_edr_file_map_detail already exist in edr_file_map_detail'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'embedded_deal'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.embedded_deal ADD CONSTRAINT PK_embedded_deal PRIMARY KEY CLUSTERED (embedded_deal_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_embedded_deal already exist in embedded_deal'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'ems_activity_data_sample'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.ems_activity_data_sample ADD CONSTRAINT PK_ems_activity_data_sample PRIMARY KEY CLUSTERED (id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_ems_activity_data_sample already exist in ems_activity_data_sample'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'ems_company_source_model_effective'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.ems_company_source_model_effective ADD CONSTRAINT PK_ems_company_source_model_effective PRIMARY KEY CLUSTERED (id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_ems_company_source_model_effective already exist in ems_company_source_model_effective'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'ems_source_input_limit'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.ems_source_input_limit ADD CONSTRAINT PK_ems_source_input_limit PRIMARY KEY CLUSTERED (input_limit_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_ems_source_input_limit already exist in ems_source_input_limit'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'eod_process_status'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.eod_process_status ADD CONSTRAINT PK_eod_process_status PRIMARY KEY CLUSTERED (id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_eod_process_status already exist in eod_process_status'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'event_trigger'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.event_trigger ADD CONSTRAINT PK_event_trigger PRIMARY KEY CLUSTERED (event_trigger_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_event_trigger already exist in event_trigger'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'exclude_st_forecast_dates'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.exclude_st_forecast_dates ADD CONSTRAINT PK_exclude_st_forecast_dates PRIMARY KEY CLUSTERED (exclude_st_forecast_dates_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_exclude_st_forecast_dates already exist in exclude_st_forecast_dates'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'expected_return'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.expected_return ADD CONSTRAINT PK_expected_return PRIMARY KEY CLUSTERED (expected_return_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_expected_return already exist in expected_return'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'explain_delivered_mtm'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.explain_delivered_mtm ADD CONSTRAINT PK_explain_delivered_mtm PRIMARY KEY CLUSTERED (source_deal_pnl_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_explain_delivered_mtm already exist in explain_delivered_mtm'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'explain_modified_mtm'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.explain_modified_mtm ADD CONSTRAINT PK_explain_modified_mtm PRIMARY KEY CLUSTERED (source_deal_pnl_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_explain_modified_mtm already exist in explain_modified_mtm'
END

--IF NOT EXISTS (
--		SELECT 1
--		FROM INFORMATION_SCHEMA.TABLES t
--		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
--		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
--			AND tc.Constraint_name = ccu.Constraint_name
--			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
--		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
--			AND idx.type = 1
--		WHERE t.TABLE_NAME = 'external_source_import'
--			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
--		)
--BEGIN
--	ALTER TABLE dbo.external_source_import ADD CONSTRAINT PK_external_source_import PRIMARY KEY CLUSTERED (esi_id)
--END
--ELSE
--BEGIN
--	PRINT 'CONSTRAINT: PK_external_source_import already exist in external_source_import'
--END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'fas_link_header_detail_audit_map'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.fas_link_header_detail_audit_map ADD CONSTRAINT PK_fas_link_header_detail_audit_map PRIMARY KEY CLUSTERED (map_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_fas_link_header_detail_audit_map already exist in fas_link_header_detail_audit_map'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'finalize_approve_test_run_log'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.finalize_approve_test_run_log ADD CONSTRAINT PK_finalize_approve_test_run_log PRIMARY KEY CLUSTERED (finalize_test_run_log_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_finalize_approve_test_run_log already exist in finalize_approve_test_run_log'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'first_day_gain_loss_decision'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.first_day_gain_loss_decision ADD CONSTRAINT PK_first_day_gain_loss_decision PRIMARY KEY CLUSTERED (first_day_gain_loss_decision_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_first_day_gain_loss_decision already exist in first_day_gain_loss_decision'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'formula_editor_parameter'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.formula_editor_parameter ADD CONSTRAINT PK_formula_editor_parameter PRIMARY KEY CLUSTERED (formula_param_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_formula_editor_parameter already exist in formula_editor_parameter'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'forward_curve_mapping'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.forward_curve_mapping ADD CONSTRAINT PK_forward_curve_mapping PRIMARY KEY CLUSTERED (rowid)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_forward_curve_mapping already exist in forward_curve_mapping'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'forward_value_report'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.forward_value_report ADD CONSTRAINT PK_forward_value_report PRIMARY KEY CLUSTERED (Rowid)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_forward_value_report already exist in forward_value_report'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'gas_allocation_map_ebase'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.gas_allocation_map_ebase ADD CONSTRAINT PK_gas_allocation_map_ebase PRIMARY KEY CLUSTERED (gas_allocation_map_ebase_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_gas_allocation_map_ebase already exist in gas_allocation_map_ebase'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'generic_mapping_definition'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.generic_mapping_definition ADD CONSTRAINT PK_generic_mapping_definition PRIMARY KEY CLUSTERED (generic_mapping_definition_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_generic_mapping_definition already exist in generic_mapping_definition'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'generic_mapping_values'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.generic_mapping_values ADD CONSTRAINT PK_generic_mapping_values PRIMARY KEY CLUSTERED (generic_mapping_values_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_generic_mapping_values already exist in generic_mapping_values'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'gis_reconcillation_log'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.gis_reconcillation_log ADD CONSTRAINT PK_gis_reconcillation_log PRIMARY KEY CLUSTERED (gis_reconcillation_log_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_gis_reconcillation_log already exist in gis_reconcillation_log'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'group_meter_mapping'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.group_meter_mapping ADD CONSTRAINT PK_group_meter_mapping PRIMARY KEY CLUSTERED (group_meter_mapping_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_group_meter_mapping already exist in group_meter_mapping'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'import_filter_deal'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.import_filter_deal ADD CONSTRAINT PK_import_filter_deal PRIMARY KEY CLUSTERED (import_filter_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_import_filter_deal already exist in import_filter_deal'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'Import_Transactions_Log'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.Import_Transactions_Log ADD CONSTRAINT PK_Import_Transactions_Log PRIMARY KEY CLUSTERED (Import_Transaction_log_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_Import_Transactions_Log already exist in Import_Transactions_Log'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'interest_expense'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.interest_expense ADD CONSTRAINT PK_interest_expense PRIMARY KEY CLUSTERED (interest_expenses_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_interest_expense already exist in interest_expense'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'interrupt_data'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.interrupt_data ADD CONSTRAINT PK_interrupt_data PRIMARY KEY CLUSTERED (interrupt_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_interrupt_data already exist in interrupt_data'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'inventory_accounting_log'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.inventory_accounting_log ADD CONSTRAINT PK_inventory_accounting_log PRIMARY KEY CLUSTERED (mtm_test_run_log_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_inventory_accounting_log already exist in inventory_accounting_log'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'invoice_cash_received'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.invoice_cash_received ADD CONSTRAINT PK_invoice_cash_received PRIMARY KEY CLUSTERED (id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_invoice_cash_received already exist in invoice_cash_received'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'iptrace'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.iptrace ADD CONSTRAINT PK_iptrace PRIMARY KEY CLUSTERED (id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_iptrace already exist in iptrace'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'ipx_privileges'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.ipx_privileges ADD CONSTRAINT PK_ipx_privileges PRIMARY KEY CLUSTERED (ipx_privileges_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_ipx_privileges already exist in ipx_privileges'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'ixp_custom_import_mapping'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.ixp_custom_import_mapping ADD CONSTRAINT PK_ixp_custom_import_mapping PRIMARY KEY CLUSTERED (ixp_custom_import_mapping_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_ixp_custom_import_mapping already exist in ixp_custom_import_mapping'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'ixp_import_data_mapping'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.ixp_import_data_mapping ADD CONSTRAINT PK_ixp_import_data_mapping PRIMARY KEY CLUSTERED (ixp_import_data_mapping_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_ixp_import_data_mapping already exist in ixp_import_data_mapping'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'ixp_import_data_source'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.ixp_import_data_source ADD CONSTRAINT PK_ixp_import_data_source PRIMARY KEY CLUSTERED (ixp_import_data_source_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_ixp_import_data_source already exist in ixp_import_data_source'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'ixp_import_query_builder_relation'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.ixp_import_query_builder_relation ADD CONSTRAINT PK_ixp_import_query_builder_relation PRIMARY KEY CLUSTERED (ixp_import_query_builder_relation_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_ixp_import_query_builder_relation already exist in ixp_import_query_builder_relation'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'ixp_import_relation'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.ixp_import_relation ADD CONSTRAINT PK_ixp_import_relation PRIMARY KEY CLUSTERED (ixp_import_relation_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_ixp_import_relation already exist in ixp_import_relation'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'ixp_import_where_clause'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.ixp_import_where_clause ADD CONSTRAINT PK_ixp_import_where_clause PRIMARY KEY CLUSTERED (ixp_import_where_clause_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_ixp_import_where_clause already exist in ixp_import_where_clause'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'ixp_ssis_parameters'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.ixp_ssis_parameters ADD CONSTRAINT PK_ixp_ssis_parameters PRIMARY KEY CLUSTERED (ixp_ssis_parameters_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_ixp_ssis_parameters already exist in ixp_ssis_parameters'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'lock_as_of_date'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.lock_as_of_date ADD CONSTRAINT PK_lock_as_of_date PRIMARY KEY CLUSTERED (lock_as_of_date_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_lock_as_of_date already exist in lock_as_of_date'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'map_function_category'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.map_function_category ADD CONSTRAINT PK_map_function_category PRIMARY KEY CLUSTERED (map_function_category_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_map_function_category already exist in map_function_category'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'meter_counterparty'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.meter_counterparty ADD CONSTRAINT PK_meter_counterparty PRIMARY KEY CLUSTERED (meter_counterparty_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_meter_counterparty already exist in meter_counterparty'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'meter_id_channel'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.meter_id_channel ADD CONSTRAINT PK_meter_id_channel PRIMARY KEY CLUSTERED (id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_meter_id_channel already exist in meter_id_channel'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'module_events'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.module_events ADD CONSTRAINT PK_module_events PRIMARY KEY CLUSTERED (module_events_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_module_events already exist in module_events'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'mv90_data'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.mv90_data ADD CONSTRAINT PK_mv90_data PRIMARY KEY CLUSTERED (meter_data_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_mv90_data already exist in mv90_data'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'mv90_data_hour'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.mv90_data_hour ADD CONSTRAINT PK_mv90_data_hour PRIMARY KEY CLUSTERED (recid)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_mv90_data_hour already exist in mv90_data_hour'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'mv90_data_mins'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.mv90_data_mins ADD CONSTRAINT PK_mv90_data_mins PRIMARY KEY CLUSTERED (recid)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_mv90_data_mins already exist in mv90_data_mins'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'mv90_data_proxy'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.mv90_data_proxy ADD CONSTRAINT PK_mv90_data_proxy PRIMARY KEY CLUSTERED (rec_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_mv90_data_proxy already exist in mv90_data_proxy'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'mv90_data_proxy_mins'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.mv90_data_proxy_mins ADD CONSTRAINT PK_mv90_data_proxy_mins PRIMARY KEY CLUSTERED (recid)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_mv90_data_proxy_mins already exist in mv90_data_proxy_mins'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'my_report'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.my_report ADD CONSTRAINT PK_my_report PRIMARY KEY CLUSTERED (my_report_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_my_report already exist in my_report'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'my_report_group'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.my_report_group ADD CONSTRAINT PK_my_report_group PRIMARY KEY CLUSTERED (my_report_group_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_my_report_group already exist in my_report_group'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'netting_group_detail_contract'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.netting_group_detail_contract ADD CONSTRAINT PK_netting_group_detail_contract PRIMARY KEY CLUSTERED (netting_contract_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_netting_group_detail_contract already exist in netting_group_detail_contract'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'open_position'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.open_position ADD CONSTRAINT PK_open_position PRIMARY KEY CLUSTERED (open_position_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_open_position already exist in open_position'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'power_allocation_map_ebase'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.power_allocation_map_ebase ADD CONSTRAINT PK_power_allocation_map_ebase PRIMARY KEY CLUSTERED (power_allocation_map_ebase_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_power_allocation_map_ebase already exist in power_allocation_map_ebase'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'power_bidding_nomination_mapping'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.power_bidding_nomination_mapping ADD CONSTRAINT PK_power_bidding_nomination_mapping PRIMARY KEY CLUSTERED (power_bidding_nomination_mapping_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_power_bidding_nomination_mapping already exist in power_bidding_nomination_mapping'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'printer_configuration'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.printer_configuration ADD CONSTRAINT PK_printer_configuration PRIMARY KEY CLUSTERED (printer_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_printer_configuration already exist in printer_configuration'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'process_map_table'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.process_map_table ADD CONSTRAINT PK_process_map_table PRIMARY KEY CLUSTERED (id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_process_map_table already exist in process_map_table'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'process_risk_controls_reminders'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.process_risk_controls_reminders ADD CONSTRAINT PK_process_risk_controls_reminders PRIMARY KEY CLUSTERED (risk_control_reminder_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_process_risk_controls_reminders already exist in process_risk_controls_reminders'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'process_settlement_invoice_log'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.process_settlement_invoice_log ADD CONSTRAINT PK_process_settlement_invoice_log PRIMARY KEY CLUSTERED (log_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_process_settlement_invoice_log already exist in process_settlement_invoice_log'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'proxy_term'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.proxy_term ADD CONSTRAINT PK_proxy_term PRIMARY KEY CLUSTERED (id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_proxy_term already exist in proxy_term'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'RDB_Mapping_Data'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.RDB_Mapping_Data ADD CONSTRAINT PK_RDB_Mapping_Data PRIMARY KEY CLUSTERED (rdb_map_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_RDB_Mapping_Data already exist in RDB_Mapping_Data'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'rec_assign_log'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.rec_assign_log ADD CONSTRAINT PK_rec_assign_log PRIMARY KEY CLUSTERED (rec_assign_log_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_rec_assign_log already exist in rec_assign_log'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'rec_generator_group'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.rec_generator_group ADD CONSTRAINT PK_rec_generator_group PRIMARY KEY CLUSTERED (generator_group_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_rec_generator_group already exist in rec_generator_group'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'report_netted_gross_net'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.report_netted_gross_net ADD CONSTRAINT PK_report_netted_gross_net PRIMARY KEY CLUSTERED (netted_gross_net_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_report_netted_gross_net already exist in report_netted_gross_net'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'risks_criteria_detail'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.risks_criteria_detail ADD CONSTRAINT PK_risks_criteria_detail PRIMARY KEY CLUSTERED (risks_criteria_detail_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_risks_criteria_detail already exist in risks_criteria_detail'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'save_confirm_detail'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.save_confirm_detail ADD CONSTRAINT PK_save_confirm_detail PRIMARY KEY CLUSTERED (save_confirm_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_save_confirm_detail already exist in save_confirm_detail'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'setup_menu'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.setup_menu ADD CONSTRAINT PK_setup_menu PRIMARY KEY CLUSTERED (setup_menu_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_setup_menu already exist in setup_menu'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'source_book_map_GL_codes'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.source_book_map_GL_codes ADD CONSTRAINT PK_source_book_map_GL_codes PRIMARY KEY CLUSTERED (source_book_map_GL_codes_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_source_book_map_GL_codes already exist in source_book_map_GL_codes'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'source_deal_cva'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.source_deal_cva ADD CONSTRAINT PK_source_deal_cva PRIMARY KEY CLUSTERED (rowid)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_source_deal_cva already exist in source_deal_cva'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'source_deal_cva_simulation'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.source_deal_cva_simulation ADD CONSTRAINT PK_source_deal_cva_simulation PRIMARY KEY CLUSTERED (rowid)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_source_deal_cva_simulation already exist in source_deal_cva_simulation'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'source_deal_pnl'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.source_deal_pnl ADD CONSTRAINT PK_source_deal_pnl PRIMARY KEY CLUSTERED (source_deal_pnl_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_source_deal_pnl already exist in source_deal_pnl'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'source_deal_pnl_detail'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.source_deal_pnl_detail ADD CONSTRAINT PK_source_deal_pnl_detail PRIMARY KEY CLUSTERED (source_deal_pnl_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: PK_source_deal_pnl_detail already exist in source_deal_pnl_detail'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'source_deal_pnl_detail_WhatIf'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.source_deal_pnl_detail_WhatIf ADD CONSTRAINT PK_source_deal_pnl_detail_WhatIf PRIMARY KEY CLUSTERED (source_deal_pnl_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: Primary Key or clustered index already exists in source_deal_pnl_detail_WhatIf'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'source_deal_pnl_eff'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.source_deal_pnl_eff ADD CONSTRAINT PK_source_deal_pnl_eff PRIMARY KEY CLUSTERED (source_deal_pnl_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: Primary Key or clustered index already exists in source_deal_pnl_eff'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'source_deal_pnl_settlement'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.source_deal_pnl_settlement ADD CONSTRAINT PK_source_deal_pnl_settlement PRIMARY KEY CLUSTERED (source_deal_pnl_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: Primary Key or clustered index already exists in source_deal_pnl_settlement'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'source_internal_desk'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.source_internal_desk ADD CONSTRAINT PK_source_internal_desk PRIMARY KEY CLUSTERED (source_internal_desk_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: Primary Key or clustered index already exists in source_internal_desk'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'source_internal_portfolio'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.source_internal_portfolio ADD CONSTRAINT PK_source_internal_portfolio PRIMARY KEY CLUSTERED (source_internal_portfolio_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: Primary Key or clustered index already exists in source_internal_portfolio'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'source_product'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.source_product ADD CONSTRAINT PK_source_product PRIMARY KEY CLUSTERED (source_product_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: Primary Key or clustered index already exists in source_product'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'source_system_data_import_status'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.source_system_data_import_status ADD CONSTRAINT PK_source_system_data_import_status PRIMARY KEY CLUSTERED (status_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: Primary Key or clustered index already exists in source_system_data_import_status'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'source_system_data_import_status_detail'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.source_system_data_import_status_detail ADD CONSTRAINT PK_source_system_data_import_status_detail PRIMARY KEY CLUSTERED (status_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: Primary Key or clustered index already exists in source_system_data_import_status_detail'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'source_system_data_import_status_vol'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.source_system_data_import_status_vol ADD CONSTRAINT PK_source_system_data_import_status_vol PRIMARY KEY CLUSTERED (status_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: Primary Key or clustered index already exists in source_system_data_import_status_vol'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'source_system_data_import_status_vol_detail'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.source_system_data_import_status_vol_detail ADD CONSTRAINT PK_source_system_data_import_status_vol_detail PRIMARY KEY CLUSTERED (status_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: Primary Key or clustered index already exists in source_system_data_import_status_vol_detail'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'st_forecast_hour'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.st_forecast_hour ADD CONSTRAINT PK_st_forecast_hour PRIMARY KEY CLUSTERED (st_forecast_hour_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: Primary Key or clustered index already exists in st_forecast_hour'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'st_forecast_mins'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.st_forecast_mins ADD CONSTRAINT PK_st_forecast_mins PRIMARY KEY CLUSTERED (st_forecast_mins_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: Primary Key or clustered index already exists in st_forecast_mins'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'static_data_category'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.static_data_category ADD CONSTRAINT PK_static_data_category PRIMARY KEY CLUSTERED (category_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: Primary Key or clustered index already exists in static_data_category'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'system_access_log'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.system_access_log ADD CONSTRAINT PK_system_access_log PRIMARY KEY CLUSTERED (system_access_log_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: Primary Key or clustered index already exists in system_access_log'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'system_formula'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.system_formula ADD CONSTRAINT PK_system_formula PRIMARY KEY CLUSTERED (sno)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: Primary Key or clustered index already exists in system_formula'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'targeted_syv_mapping'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.targeted_syv_mapping ADD CONSTRAINT PK_targeted_syv_mapping PRIMARY KEY CLUSTERED (traget_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: Primary Key or clustered index already exists in targeted_syv_mapping'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'tbl_sims_status'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.tbl_sims_status ADD CONSTRAINT PK_tbl_sims_status PRIMARY KEY CLUSTERED (sid)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: Primary Key or clustered index already exists in tbl_sims_status'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'transportation_contract_capacity'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.transportation_contract_capacity ADD CONSTRAINT PK_transportation_contract_capacity PRIMARY KEY CLUSTERED (ID)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: Primary Key or clustered index already exists in transportation_contract_capacity'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'Trayport_Staging_Error'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.Trayport_Staging_Error ADD CONSTRAINT PK_Trayport_Staging_Error PRIMARY KEY CLUSTERED (staging_sno)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: Primary Key or clustered index already exists in Trayport_Staging_Error'
END

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES t
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON t.TABLE_NAME = tc.TABLE_NAME
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
			AND tc.Constraint_name = ccu.Constraint_name
			AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
		LEFT JOIN sys.indexes idx ON idx.object_id = OBJECT_ID(t.TABLE_NAME)
			AND idx.type = 1
		WHERE t.TABLE_NAME = 'valuation_curve_mapping'
			AND ISNULL(ccu.TABLE_CATALOG, idx.object_id) IS NOT NULL
		)
BEGIN
	ALTER TABLE dbo.valuation_curve_mapping ADD CONSTRAINT PK_valuation_curve_mapping PRIMARY KEY CLUSTERED (valuation_curve_mapping_id)
END
ELSE
BEGIN
	PRINT 'CONSTRAINT: Primary Key or clustered index already exists in valuation_curve_mapping'
END
