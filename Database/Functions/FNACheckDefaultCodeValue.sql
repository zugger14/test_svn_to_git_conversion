IF OBJECT_ID(N'[dbo].[FNACheckDefaultCodeValue]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNACheckDefaultCodeValue]
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON 
GO
 
-- ===========================================================================================================
-- Author: rabhusal@pioneersolutionsglobal.com
-- Create date: 2017-11-13
-- var_value: Function to check if the value exists or not
 
-- Params:
-- returns BIT value 1 or 0
-- ===========================================================================================================
--to check
--SELECT dbo.[FNACheckDefaultCodeValue](1,4) as Valid
--SELECT dbo.[FNACheckDefaultCodeValue](1,9) as Valid

CREATE FUNCTION [dbo].[FNACheckDefaultCodeValue](@default_code_id INT, @var_value VARCHAR(1000))
    RETURNS BIT
AS
BEGIN
	DECLARE @is_dd_text INT

	IF NOT EXISTS(SELECT 1 FROM adiha_default_codes_values_possible WHERE default_code_id = @default_code_id)
	BEGIN 
		SET @is_dd_text = 1
	END 
	ELSE IF EXISTS(SELECT 1 FROM adiha_default_codes_values_possible WHERE default_code_id = @default_code_id AND var_value = @var_value)
	BEGIN 
		SET @is_dd_text = 1
	END 
	ELSE 
	BEGIN 
		SET @is_dd_text = 0
	END

	RETURN @is_dd_text
END

GO