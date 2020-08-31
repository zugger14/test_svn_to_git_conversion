IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_virtual_storage_constraints]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_virtual_storage_constraints]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_virtual_storage_constraints]
@flag CHAR(1),
@constraint_id INT = NULL,
@constraint_type INT = NULL,
@value BIGINT = NULL,
@uom INT = NULL,
@frequency CHAR(1) = NULL,
@effective_date DATETIME = NULL,
@general_asset_id INT = NULL,
@buy_sell_flag CHAR(1) = NULL

AS 

DECLARE @sql VARCHAR(8000)

IF @flag = 's'
BEGIN
	SELECT 
	vsc.constraint_id AS [Constraint Id],
	sdv.code [Constraint Type],
	value [Value], 
	su.uom_name [UOM], 
	CASE frequency WHEN 'h' THEN 'Hourly'
		WHEN 'd' THEN 'Daily' 
		WHEN 'm' THEN 'Monthly' 
		WHEN 't' THEN 'Term' 
		ELSE '' END [Frequency],
	effective_date [Effective Date] 
	FROM virtual_storage_constraint vsc
		INNER JOIN static_data_value sdv ON vsc.constraint_type =sdv.value_id
		INNER JOIN source_uom su ON vsc.uom = su.source_uom_id
		AND vsc.general_assest_id = @general_asset_id
END

ELSE IF @flag = 'a'
BEGIN
	SELECT 
	constraint_type [Constraint Type], 
	value [Value], 
	uom [UOM],
	frequency [Frequency],
	effective_date [Effective Date] 
	FROM virtual_storage_constraint WHERE constraint_id = @constraint_id
END

ELSE IF @flag = 'i'
BEGIN
	DECLARE @desc VARCHAR(2000)
	SET @desc = 'Constraint has already been set for ' + CAST(@effective_date AS VARCHAR(1000))
	IF EXISTS(SELECT 1 FROM virtual_storage_constraint vsc WHERE vsc.effective_date = @effective_date AND vsc.constraint_type = @constraint_type AND vsc.general_assest_id = @general_asset_id)
	BEGIN
		EXEC spa_ErrorHandler -1
		, 'virtual_storage_constraint' 
		, 'virtual_storage_constraint'
		, 'virtual_storage_constraint'
		, @desc
		, ''	
	END
	ELSE
	BEGIN TRY
	BEGIN TRAN 	
		
		INSERT INTO virtual_storage_constraint
					(
						constraint_type,
						VALUE,
						uom,
						frequency,
						effective_date,
						general_assest_id
					)
		VALUES 
					(
						@constraint_type,
						@value,
						@uom,
						@frequency,
						@effective_date,
						@general_asset_id
					)	
		
		COMMIT 
		
		EXEC spa_ErrorHandler 0, 'virtual_storage_constraint' ,'virtual_storage_constraint','virtual_storage_constraint',
		'Successfully inserted data into virtual_storage_constraint',''
					
	END TRY 
	BEGIN CATCH
	
		EXEC spa_ErrorHandler -1, 'virtual_storage_constraint' ,'virtual_storage_constraint','virtual_storage_constraint',
		'Failed inserting data into virtual_storage_constraint',''
		
		ROLLBACK 
		
	END CATCH	
			
END
ELSE IF @flag = 'u'
BEGIN
	--SET @desc = 'Constraint has already been set for ' + CAST(@effective_date AS VARCHAR(12))
	--IF EXISTS(SELECT 1 FROM virtual_storage_constraint vsc WHERE vsc.effective_date = @effective_date AND vsc.constraint_type = @constraint_type AND vsc.general_assest_id = @general_asset_id)
	--BEGIN
	--	EXEC spa_ErrorHandler -1
	--	, 'virtual_storage_constraint' 
	--	, 'virtual_storage_constraint'
	--	, 'virtual_storage_constraint'
	--	, @desc
	--	, ''	
	--END
	--ELSE
	BEGIN TRY
	BEGIN TRAN 	
	
		UPDATE virtual_storage_constraint
		SET
			constraint_type = @constraint_type,
			[value] = @value,
			uom = @uom,
			frequency = @frequency,
			effective_date = @effective_date
		WHERE constraint_id = @constraint_id
		
		COMMIT 
		
		EXEC spa_ErrorHandler 0
			, 'virtual_storage_constraint' 
			, 'virtual_storage_constraint'
			, 'virtual_storage_constraint'
			, 'Successfully updated data into virtual_storage_constraint'
			, ''
	
	END TRY 
	BEGIN CATCH
		
		EXEC spa_ErrorHandler -1, 'virtual_storage_constraint' ,'virtual_storage_constraint','virtual_storage_constraint',
		'Failed updating data into virtual_storage_constraint',''
		
		ROLLBACK 
		
	END CATCH
END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
	BEGIN TRAN
		DELETE FROM virtual_storage_constraint WHERE constraint_id = @constraint_id
		COMMIT
		EXEC spa_ErrorHandler 0, 'virtual_storage_constraint' ,'virtual_storage_constraint','virtual_storage_constraint',
			'Successfully deleted data from virtual_storage_constraint',''
	END TRY 
	BEGIN CATCH
		EXEC spa_ErrorHandler -1, 'virtual_storage_constraint' ,'virtual_storage_constraint','virtual_storage_constraint',
		'Failed deleting data from virtual_storage_constraint',''
		ROLLBACK 
	END CATCH
END

ELSE IF @flag = 'z' --TO GET injection AND withdrawal amoumt
BEGIN
	BEGIN TRY
	BEGIN TRAN	
		SET @sql = '
			SELECT	top(1) [value], frequency
			FROM	virtual_storage_constraint 
			WHERE	1=1 
					AND effective_date <= ''' + CAST(@effective_date AS VARCHAR(12)) + ''' 
					AND general_assest_id =''' + CAST(@general_asset_id AS VARCHAR(100)) + '''' 
		--PRINT @sql
		IF @buy_sell_flag = 's'
		SET @sql = @sql + ' AND constraint_type = 18601'
		
		ELSE IF @buy_sell_flag = 'b'
		SET @sql = @sql + ' AND constraint_type = 18602'
		SET @sql = @sql + 'ORDER BY effective_date DESC'		
		EXEC spa_print @sql
		EXEC (@sql)		
	COMMIT
	END TRY 
	
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
		, 'virtual_storage_constraint' 
		, 'virtual_storage_constraint'
		, 'virtual_storage_constraint'
		, 'Failed selecting data from virtual_storage_constraint'
		, ''
		ROLLBACK 
	END CATCH
END