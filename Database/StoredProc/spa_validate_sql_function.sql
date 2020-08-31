IF OBJECT_ID(N'[dbo].[spa_validate_sql_function]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_validate_sql_function]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/**
	Validate SQL and function queries.
 
	Parameters
	@flag : Operation flag.
		u for user defined function
		f for default function
	@tsql : SQl queries. eg 'select * fraom application_usears'.
*/

CREATE PROCEDURE [dbo].[spa_validate_sql_function]
	@flag CHAR(1),
    @tsql VARCHAR(MAX) = NULL
AS

SET NOCOUNT ON

DECLARE @str_formula VARCHAR(8000)
DECLARE @error_msg VARCHAR(50)
SET @tsql = REPLACE(@tsql, 'adiha_add', '+')
SET @tsql = REPLACE(@tsql, 'adiha_space', ' ')

IF @flag = 'u' -- syntax checking
BEGIN
	DECLARE @return INT 
	EXEC @return = spa_check_sql_syntax @tsql
	IF @return = 0 
	BEGIN
	
		EXEC spa_ErrorHandler 0,
			 'alert_sql_statement',
			 'spa_alert_sql_statement',
			 'Success',
			 'SQL Statement is Valid.',
			 ''
	END
	ELSE-- IF @return = 1
	BEGIN
		set @return = @return 
		set @error_msg = 'SQL Statement is invalid. Error at line - '+CAST(@return as varchar(50))
		EXEC spa_ErrorHandler -1,
			 'alert_sql_statement',
			 'spa_alert_sql_statement',
			 'Error',
			 @error_msg,
			 ''
	END 
END
ELSE IF @flag = 'f'
BEGIN
	set @str_formula = @tsql
	set @str_formula = replace(@str_formula,'SumVolume()','1')
	set @str_formula = replace(@str_formula,'OnPeakvolume()','1')
	set @str_formula = replace(@str_formula,'OffpeakVolume()','1')
	set @str_formula = replace(@str_formula,'Volume()','1')
	set @str_formula = replace(@str_formula,'OnPeakPeriodhour()','1')
	set @str_formula = replace(@str_formula,'OffPeakPeriodhour()','1')
	set @str_formula = replace(@str_formula,'OnPeakMxHour()','1')
	set @str_formula = replace(@str_formula,'OffPeakMxHour()','1')
	set @str_formula = replace(@str_formula,'TotalPeriodhour()','1')
	set @str_formula = replace(@str_formula,'TotalMxhour()','1')

	--PRINT @str_formula
	SET @str_formula =  dbo.[FNAFormulaResolveParamSeperator](@str_formula, 's');
	set @str_formula=dbo.FNAFormulaFormat(@str_formula,'d')
	--PRINT @str_formula;

	-- replacing '-' by '+' to avoid divide by zero error	
	SET @str_formula = REPLACE (@str_formula, '-', '+')
	
	--PRINT @str_formula
	BEGIN TRY
		
		EXEC spa_resolve_function_parameter @flag='c',@tsql = @str_formula
		Exec spa_ErrorHandler 0, "Formula", 
					"spa_formula_editor", "DB Success", 
					"Valid Syntax.", ''
	END TRY
	BEGIN CATCH
		Set @return  = ERROR_LINE()-1
		SET @error_msg = 'Invalid Syntax. Error at line - '+ CAST(@return AS varchar(10)); 
		Exec spa_ErrorHandler -1, "Formula", 
					"spa_formula_editor", "DB Error", 
					@error_msg, ''
	END CATCH	
END
