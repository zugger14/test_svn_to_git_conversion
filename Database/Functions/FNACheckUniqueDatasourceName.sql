
/**
	Check and Drop Constraint for data_source 
	Name : CK_data_source
	Table : data_source
	Column : name, type_id
*/
IF EXISTS( 
	SELECT 1
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
		AND tc.Constraint_name = ccu.Constraint_name    
        AND tc.CONSTRAINT_TYPE = 'CHECK'
        AND tc.Table_Name = 'data_source'
		AND	tc.CONSTRAINT_NAME = 'CK_data_source'
)
BEGIN
	ALTER TABLE 
	/**
		Columns
		name : Name of data_source
	*/
	[dbo].[data_source]
	DROP CONSTRAINT [CK_data_source]
	PRINT 'Check constraint deleted'
END
GO

IF OBJECT_ID(N'[dbo].FNACheckUniqueDatasourceName', N'FN') IS NOT NULL 
	DROP FUNCTION [dbo].FNACheckUniqueDatasourceName
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
/**
	Check if the name of Data Source already exists or not based on type id 1-> Views, 2-> SQL, 3-> Table. Returns BIT value 1 or 0

	Parameters
	@name : Data Source Name
	@type_id : Type ID
	@data_source_id : Data Source ID
	@report_id : Report ID
	
*/
CREATE FUNCTION [dbo].[FNACheckUniqueDatasourceName](@name VARCHAR(200), @type_id INT, @data_source_id INT, @report_id INT)
    RETURNS BIT
AS
BEGIN
	
	DECLARE @is_dd_text INT = 1

	SET @data_source_id = ISNULL(@data_source_id,0)

	IF @type_id <> 2 AND EXISTS (SELECT 1 FROM data_source WHERE [name] = @name AND data_source_id <> @data_source_id)
	BEGIN 
		SET @is_dd_text = 0
	END 
	ELSE IF @type_id = 2 AND EXISTS (SELECT 1 from data_source WHERE [name] = @name AND data_source_id <> @data_source_id AND [report_id] = @report_id)
	BEGIN 
		SET @is_dd_text = 0
	END 

	RETURN @is_dd_text
END
GO

/**
	Check and Add Constraint for data_source 
	Name : CK_data_source
	Table : data_source
	Column : name, type_id
*/
IF NOT EXISTS( 
	SELECT 1
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
		AND tc.Constraint_name = ccu.Constraint_name    
        AND tc.CONSTRAINT_TYPE = 'CHECK'
        AND tc.Table_Name = 'data_source'
		AND	tc.CONSTRAINT_NAME = 'CK_data_source'
)
BEGIN
	ALTER TABLE 
	/**
		Columns
		name : Name of data_source
		type_id : 1-> Views, 2-> SQL, 3-> Tables
		data_source_id : Data Source ID
		report_id : Report ID
	*/
	[dbo].[data_source] WITH NOCHECK 
	ADD CONSTRAINT CK_data_source CHECK (dbo.FNACheckUniqueDatasourceName([name],[type_id],[data_source_id],[report_id]) = 1)
	PRINT 'Check constraint added'
END
GO
