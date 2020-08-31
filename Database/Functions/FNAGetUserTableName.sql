IF OBJECT_ID(N'[dbo].[FNAGetUserTableName]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAGetUserTableName]
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: ssingh@pioneersolutionsglobal.com
-- Create date: 2011-06-15
-- Description: Function to Return the value of table excluding the @exclude_till parameter
 
-- Params:
-- returns table name(varchar)
-- ===========================================================================================================
CREATE FUNCTION [dbo].[FNAGetUserTableName](@table_name VARCHAR(1000), @exclude_till VARCHAR(100))
    RETURNS VARCHAR(1000)
AS
BEGIN
	IF @exclude_till = '[batch_export_'
	BEGIN
   	IF CHARINDEX('[adiha_process].[dbo].[batch_export_', @table_name, 1) > 0
		SET @table_name = REPLACE(
							REPLACE(
								SUBSTRING(@table_name, CHARINDEX(@exclude_till, @table_name, 1) + LEN(@exclude_till), (LEN(@table_name) - CHARINDEX(@exclude_till, @table_name, 1)))
							,'[', '')
						,']', '')
	
	END 
	ELSE IF @exclude_till = '[report_export_'
	BEGIN
		IF CHARINDEX('[adiha_process].[dbo].[report_export_', @table_name, 1) > 0
		SET @table_name = REPLACE(
							REPLACE(
								SUBSTRING(@table_name, CHARINDEX(@exclude_till, @table_name, 1) + LEN(@exclude_till), (LEN(@table_name) - CHARINDEX(@exclude_till, @table_name, 1)))
							,'[', '')
						,']', '')
	END 
	ELSE IF @exclude_till = '.[dbo].'
	BEGIN
		SET @table_name = REPLACE(
							REPLACE(
								SUBSTRING(@table_name, CHARINDEX(@exclude_till, @table_name, 1) + LEN(@exclude_till), (LEN(@table_name) - CHARINDEX(@exclude_till, @table_name, 1)))
							,'[', '')
						,']', '')
	END 
	RETURN @table_name
END
GO