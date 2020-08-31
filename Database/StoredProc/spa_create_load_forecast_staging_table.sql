IF OBJECT_ID('spa_create_load_forecast_staging_table') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_create_load_forecast_staging_table]
GO

-- ============================================================================================================================
-- Create date: 2011-12-28
-- Description:	Creates staging table to hold load forecast CSV files (new format), so that DST can be handled
--				, which was difficult with flat files
-- Params:
-- @process_id		VARCHAR(50) - Process ID
-- ============================================================================================================================
CREATE PROCEDURE [dbo].[spa_create_load_forecast_staging_table]
	@process_id		VARCHAR(50)
AS
	
SET NOCOUNT ON;

DECLARE @tbl_name VARCHAR(200)
SET @tbl_name = dbo.FNAProcessTableName('load_forecast_csv_new_format', dbo.FNADBUser(), @process_id)

IF OBJECT_ID(@tbl_name, N'U') IS NULL
BEGIN
	EXEC('CREATE TABLE ' + @tbl_name + ' (
			id INT IDENTITY(1, 1)
			, term_date VARCHAR(10)
			, hour TINYINT
			, volume NUMERIC(38, 20)
		)'
	)
END

SELECT @tbl_name AS table_name

GO
