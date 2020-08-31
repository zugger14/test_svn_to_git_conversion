IF OBJECT_ID(N'[dbo].[FNAGetDefaultCodeValue]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAGetDefaultCodeValue]
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rabhusal@pioneersolutionsglobal.com
-- Create date: 2017-11-13
-- Description: Function to get the value of provided default code id
 
-- Params:
-- returns VARCHAR var_value
-- ===========================================================================================================
--to check
--SELECT dbo.FNAGetDefaultCodeValue(1,2) AS Value
--SELECT dbo.FNAGetDefaultCodeValue(99,2) AS Error

CREATE FUNCTION [dbo].[FNAGetDefaultCodeValue](@default_code_id INT, @seq_no INT)
    RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @var_value VARCHAR(100)

	IF (SELECT 1 FROM adiha_default_codes_values WHERE seq_no = @seq_no and default_code_id = @default_code_id) IS NOT NULL
	BEGIN
		SELECT @var_value = var_value FROM adiha_default_codes_values WHERE seq_no = @seq_no and default_code_id = @default_code_id		
	END
	ELSE 
	BEGIN
		SET @var_value = 'Invalid default code id or sequence number'
	END

	RETURN @var_value

END
GO