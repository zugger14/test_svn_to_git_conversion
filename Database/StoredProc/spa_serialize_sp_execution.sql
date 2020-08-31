
IF OBJECT_ID(N'spa_serialize_sp_execution', N'P') IS NOT NULL
DROP PROC  [dbo].[spa_serialize_sp_execution]
GO
-- ===============================================================================================================
-- Author: ashakya@pioneersolutionsglobal.com
-- Create date: 2016-03-06
-- Description: Generates parameters in sequential way as declared in the sp 

-- Params:
-- @sp_string VARCHAR(MAX)   - Store Procedure with dynamic parameters 
-- eg. EXEC spa_StaticDataValues  @flag='s', @type_id=800, @code='a', @entity_name_filter='1,2,3,4,5'
-- RETURNS EXEC spa_StaticDataValues 's', 800, default, default, 'a', default, default, default, default, default, default, default, default, '1,2,3,4,5', default
-- ===============================================================================================================

CREATE PROC [dbo].[spa_serialize_sp_execution] 
	@sp_string VARCHAR(MAX)
AS

/*-- Test Code
DECLARE @sp_string VARCHAR(MAX)
SET @sp_string = 'EXEC spa_gen_invoice_variance_report 4689,''2016-01-01'',4163,null,''h'',''2016-07-14'',null,null,null,null,303237,null,null,null,null,''i'',''2016-02-02'',null,null,4,null,@batch_process_id = ''938159c7_051c_4272_b208_01fdc382a6f5'',@batch_report_param = null,@enable_paging = 1,@page_size =100, @page_no = 1'
--*/

SET NOCOUNT ON

DECLARE @delimiter CHAR(1) = '@',  
		@splited_string VARCHAR(MAX),
		@sp_string_validate VARCHAR(MAX)


/*
	* Resolve dynamic date if spa contains DYNDATE TAG	
*/

SET @sp_string = dbo.FNAReplaceDYNDateParam(@sp_string)

IF CHARINDEX('@batch_process_id', @sp_string, 0) <> 0
BEGIN
	SELECT @sp_string_validate = SUBSTRING(@sp_string, 1, CHARINDEX('@batch_process_id', @sp_string, 0) - 2)
	IF CHARINDEX(@delimiter, @sp_string_validate) = 0
	BEGIN
		SELECT @sp_string AS result
		RETURN
	END
	SET @sp_string = @sp_string_validate
END

IF CHARINDEX(@delimiter, @sp_string) <> 0
BEGIN 
	IF OBJECT_ID('tempdb..#output') IS NOT NULL 
		DROP TABLE #output
	
	CREATE TABLE #output (
		split_data VARCHAR(MAX) COLLATE DATABASE_DEFAULT
	)

	SELECT @sp_string = REPLACE(@sp_string, 'EXEC', '')
	
	INSERT INTO #output
    SELECT  CASE WHEN RIGHT(item, 1) = ',' 
				THEN SUBSTRING(item, 1, LEN(item) - 1) 
			ELSE 
				item 
			END 
	FROM dbo.FNASplit(@sp_string, '@')
	
	IF OBJECT_ID('tempdb..#final_output') IS NOT NULL 
		DROP TABLE #final_output
	
	CREATE TABLE #final_output (
		id INT NOT NULL IDENTITY(1, 1),
		params VARCHAR(100) COLLATE DATABASE_DEFAULT,
		value VARCHAR(MAX) COLLATE DATABASE_DEFAULT
	)

	INSERT INTO #final_output (params, value)
	SELECT clm1 params, clm2 value 
	FROM #output o 
		CROSS APPLY dbo.FNASplitAndTranspose(o.split_data, '=')

	DECLARE @list_str VARCHAR(MAX), @spa VARCHAR(100)
	
	SET @spa = (SELECT params FROM #final_output WHERE id = 1)
	
	SELECT @list_str = COALESCE(@list_str + ', ' , '') + params
	FROM (
			SELECT ISNULL(op.value, 'DEFAULT') params
			FROM (
					SELECT
						SO.NAME AS [ObjectName]
						, REPLACE(P.NAME, '@', '') AS [parameter_name]
					FROM sys.objects AS SO
						INNER JOIN sys.parameters AS P
							ON SO.OBJECT_ID = P.OBJECT_ID
					WHERE SO.OBJECT_ID IN (
						SELECT OBJECT_ID
						FROM sys.objects
						WHERE TYPE IN ('P') 
					) AND P.NAME NOT IN ('@batch_process_id', '@batch_report_param', '@enable_paging', '@page_size', '@page_no')
				) a
				LEFT JOIN #final_output op 
					ON op.params = a.[parameter_name]
			WHERE  a.[ObjectName] = @spa
	) a

	SELECT 'EXEC ' + @spa + ' ' + @list_str AS result
END
ELSE
BEGIN
		SELECT REPLACE(@sp_string,'''''','''') AS result
END
GO
