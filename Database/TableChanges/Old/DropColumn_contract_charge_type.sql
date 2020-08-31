IF EXISTS ( SELECT COLUMN_NAME
			FROM INFORMATION_SCHEMA.COLUMNS
		    WHERE (   TABLE_NAME = 'contract_charge_type'
			   	  AND COLUMN_NAME = 'time_of_use'
				  )
)
BEGIN
	ALTER TABLE [dbo].[contract_charge_type] DROP COLUMN [time_of_use]
END

IF EXISTS ( SELECT COLUMN_NAME
			FROM INFORMATION_SCHEMA.COLUMNS
		    WHERE (   TABLE_NAME = 'contract_charge_type'
			   	      AND COLUMN_NAME = 'payment_calendar'
				  )
)
BEGIN
	ALTER TABLE [dbo].[contract_charge_type] DROP COLUMN [payment_calendar]
END

IF EXISTS ( SELECT COLUMN_NAME
			FROM INFORMATION_SCHEMA.COLUMNS
		    WHERE (   TABLE_NAME = 'contract_charge_type'
			   	      AND COLUMN_NAME = 'pnl_date'
				  )
)
BEGIN
	ALTER TABLE [dbo].[contract_charge_type] DROP COLUMN [pnl_date]
END

IF EXISTS ( SELECT COLUMN_NAME
			FROM INFORMATION_SCHEMA.COLUMNS
		    WHERE (   TABLE_NAME = 'contract_charge_type'
			   	      AND COLUMN_NAME = 'pnl_calendar'
				  )
)
BEGIN
	ALTER TABLE [dbo].[contract_charge_type] DROP COLUMN [pnl_calendar]
END

IF EXISTS ( SELECT COLUMN_NAME
			FROM INFORMATION_SCHEMA.COLUMNS
		    WHERE (   TABLE_NAME = 'contract_charge_type'
			   	      AND COLUMN_NAME = 'settlement_date'
				  )
)
BEGIN
	ALTER TABLE [dbo].[contract_charge_type] DROP COLUMN [settlement_date]
END

IF EXISTS ( SELECT COLUMN_NAME
			FROM INFORMATION_SCHEMA.COLUMNS
		    WHERE (   TABLE_NAME = 'contract_charge_type'
			   	      AND COLUMN_NAME = 'settlement_calendar'
				  )
)
BEGIN
	ALTER TABLE [dbo].[contract_charge_type] DROP COLUMN [settlement_calendar]
END

IF EXISTS ( SELECT COLUMN_NAME
			FROM INFORMATION_SCHEMA.COLUMNS
		    WHERE (   TABLE_NAME = 'contract_charge_type'
			   	      AND COLUMN_NAME = 'effective_date'
				  )
)
BEGIN
	ALTER TABLE [dbo].[contract_charge_type] DROP COLUMN [effective_date]
END

IF EXISTS ( SELECT COLUMN_NAME
			FROM INFORMATION_SCHEMA.COLUMNS
		    WHERE (   TABLE_NAME = 'contract_charge_type'
			   	      AND COLUMN_NAME = 'aggregration_level'
				  )
)
BEGIN
	ALTER TABLE [dbo].[contract_charge_type] DROP COLUMN [aggregration_level]
END
