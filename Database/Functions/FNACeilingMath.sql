IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNACeilingMath]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNACeilingMath]
/****
* Created By: Shushil Bohara (sbohara@pioneersolutionsglobal.com)
* Created DT: 15-Jul-2015
* Description: It calculates rounding value and somehow similar to 'ceilingmath' function of excel.
* **/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNACeilingMath](
	@number NUMERIC(38,20), 
	@signifance NUMERIC(38,20)
)
RETURNS FLOAT 
AS
BEGIN
	DECLARE @ret_val FLOAT, @numberChanged NUMERIC(38,20)
	--DECLARE @number NUMERIC(38,20) = 1468
	--DECLARE @signifance NUMERIC(38,20) = 500

	
	IF @number <> 0 AND @signifance IS NOT NULL
		IF @signifance < ABS(@number)
		BEGIN
			SET @numberChanged = ABS(@number) / @signifance
			--SET @ret_val = (@signifance*((CAST(@number/@signifance) AS INT) +1))
			SET @ret_val = CASE WHEN CEILING(@numberChanged) <> FLOOR(@numberChanged) THEN (@signifance*(CAST(@numberChanged AS INT) +1)) ELSE ABS(@number) END
		END	
		ELSE 
			SET @ret_val = @signifance
	ELSE 
		SET @ret_val = @number		
		
	IF @number < 0
	 SET @ret_val = @ret_val*-1	
		
	RETURN @ret_val	
END