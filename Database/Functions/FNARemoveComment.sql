IF OBJECT_ID(N'FNARemoveComment', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARemoveComment]
 GO 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===============================================================================================================
-- Create date: 2019-05-16
-- Author : Dewanand Manandhar
-- Description: Removes comments from sql string 
--				It will return original sql string if there are any nested multiple line comment
--				It will not remove --[__batch_report__] since there are logic based on this
-- Params:
-- @sql - sql string 
-- ===============================================================================================================

CREATE FUNCTION [dbo].[FNARemoveComment] (
	@sql VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN	
	DECLARE @sql_org VARCHAR(MAX) = @sql 
	DECLARE @count INT = 0

	--PRESERVES --[__batch_report__] FROM REMOVING
	SET @sql = REPLACE(@sql, '--[__batch_report__]', '~~[__batch_report__]')

	DECLARE @len INT

	--REMOVES SINGLE LINE COMMENTS
	WHILE CHARINDEX('--', @sql) <> 0
	BEGIN
		SET @len = IIF(CHARINDEX(CHAR(10), @sql , CHARINDEX('--', @sql) ) - CHARINDEX('--', @sql) < 0 
						, (LEN(@sql) + 1) - CHARINDEX('--', @sql) 
						, CHARINDEX(CHAR(10), @sql , CHARINDEX('--', @sql) ) - CHARINDEX('--', @sql) )
	
		SELECT @sql = STUFF ( @sql 
							, CHARINDEX('--', @sql) 
							, @len
							, ' ' 
							)  
		SET @count = @count + 1 
		IF @count > 500
		BEGIN
			SET @sql = @sql_org
			BREAK
		END
	END 

	SET @count = 0

	--REMOVES MULTILINE COMMENTS
	WHILE CHARINDEX('/*', @sql) <> 0
	BEGIN	
		SET @len = IIF((CHARINDEX('*/', @sql) - CHARINDEX('/*', @sql)) < 0 
									, 0
									, CHARINDEX('*/', @sql) - CHARINDEX('/*', @sql)) + 2
							
		SELECT @sql = STUFF ( @sql 
								, CHARINDEX('/*', @sql) 
								,  @len
								, ' ' 
							)   
		SET @count = @count + 1
		IF @count > 500
		BEGIN
			SET @sql = @sql_org
			BREAK
		END
	END

	SET @sql = REPLACE(@sql, '~~[__batch_report__]', '--[__batch_report__]')

	--RETURNS ORIGINAL SQL STRING IF THERE ARE NESTED MULTIPLE LINE COMMENTS
	IF (CHARINDEX('/*', @sql) <>  0 OR CHARINDEX('*/', @sql) <> 0)
	BEGIN
		SET @sql = @sql_org
	END
		
	RETURN @sql
END
GO











