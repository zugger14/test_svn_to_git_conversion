/* Drop Constraints*/
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_var_measurement_criteria_detail_static_data_value]') 
			AND parent_object_id = OBJECT_ID(N'[dbo].[var_measurement_criteria_detail]'))
	ALTER TABLE var_measurement_criteria_detail
		DROP CONSTRAINT FK_var_measurement_criteria_detail_static_data_value

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_var_measurement_criteria_detail_source_book3]') 
			AND parent_object_id = OBJECT_ID(N'[dbo].[var_measurement_criteria_detail]'))
	ALTER TABLE var_measurement_criteria_detail
		DROP CONSTRAINT FK_var_measurement_criteria_detail_source_book3
		
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_var_measurement_criteria_detail_source_book2]') 
			AND parent_object_id = OBJECT_ID(N'[dbo].[var_measurement_criteria_detail]'))
	ALTER TABLE var_measurement_criteria_detail
		DROP CONSTRAINT FK_var_measurement_criteria_detail_source_book2
		
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_var_measurement_criteria_detail_source_book1]') 
			AND parent_object_id = OBJECT_ID(N'[dbo].[var_measurement_criteria_detail]'))
	ALTER TABLE var_measurement_criteria_detail
		DROP CONSTRAINT FK_var_measurement_criteria_detail_source_book1
		
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_var_measurement_criteria_detail_source_book]') 
			AND parent_object_id = OBJECT_ID(N'[dbo].[var_measurement_criteria_detail]'))
	ALTER TABLE var_measurement_criteria_detail
		DROP CONSTRAINT FK_var_measurement_criteria_detail_source_book
/* Drop Columns */

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'var_measurement_criteria_detail' AND column_name = 'use_values')
	ALTER TABLE var_measurement_criteria_detail
		DROP COLUMN use_values
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'var_measurement_criteria_detail' AND column_name = 'what_if')
	ALTER TABLE var_measurement_criteria_detail
		DROP COLUMN what_if
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'var_measurement_criteria_detail' AND column_name = 'source_system_book_id1')
	ALTER TABLE var_measurement_criteria_detail
		DROP COLUMN source_system_book_id1
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'var_measurement_criteria_detail' AND column_name = 'source_system_book_id2')
	ALTER TABLE var_measurement_criteria_detail
		DROP COLUMN source_system_book_id2
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'var_measurement_criteria_detail' AND column_name = 'source_system_book_id3')
	ALTER TABLE var_measurement_criteria_detail
		DROP COLUMN source_system_book_id3
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'var_measurement_criteria_detail' AND column_name = 'source_system_book_id4')
	ALTER TABLE var_measurement_criteria_detail
		DROP COLUMN source_system_book_id4
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'var_measurement_criteria_detail' AND column_name = 'role')
	ALTER TABLE var_measurement_criteria_detail
		DROP COLUMN role
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'var_measurement_criteria_detail' AND column_name = 'include_hypothetical_transactions')
	ALTER TABLE var_measurement_criteria_detail
		DROP COLUMN include_hypothetical_transactions
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'var_measurement_criteria_detail' AND column_name = 'include_options_gamma')
	ALTER TABLE var_measurement_criteria_detail
		DROP COLUMN include_options_gamma
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'var_measurement_criteria_detail' AND column_name = 'data_points')
	ALTER TABLE var_measurement_criteria_detail
		DROP COLUMN data_points
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'var_measurement_criteria_detail' AND column_name = 'calc_vol_cor')
	ALTER TABLE var_measurement_criteria_detail
		DROP COLUMN calc_vol_cor
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'var_measurement_criteria_detail' AND column_name = 'calc_price_curve')
	ALTER TABLE var_measurement_criteria_detail
		DROP COLUMN calc_price_curve
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'var_measurement_criteria_detail' AND column_name = 'parent_netting_group')
	ALTER TABLE var_measurement_criteria_detail
		DROP COLUMN parent_netting_group
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'var_measurement_criteria_detail' AND column_name = 'incremental_scenario_id')
	ALTER TABLE var_measurement_criteria_detail
		DROP COLUMN incremental_scenario_id
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'var_measurement_criteria_detail' AND column_name = 'end_date')
	ALTER TABLE var_measurement_criteria_detail
		DROP COLUMN end_date
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'var_measurement_criteria_detail' AND column_name = 'mc_model')
	ALTER TABLE var_measurement_criteria_detail
		DROP COLUMN mc_model
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'var_measurement_criteria_detail' AND column_name = 'start_date')
	ALTER TABLE var_measurement_criteria_detail
		DROP COLUMN start_date
GO
