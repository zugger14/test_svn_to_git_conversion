 -- ==========================================================================================================
 -- Author      : Dewanand Manandhar											            
 -- Date		: 02.Aug.2011															
 -- Description : Add thousand separator in numeric values	
 
 -- Params: 
 --		@value NUMERIC(38,20) -Numeric value which need to be thousand separated
 --		Returns thousand separated string  						
 -- =========================================================================================================

 -- =========================================================================================================
 -- Logic:
 -- First the value passed on this function was separated into numberic part and decimal part
 -- Only numberic part was taken for adding thousand separator
 -- Once numberic part was converted in the thousand separated formate the decimal part after removing 
 -- trailing zeros was concatinated
 
 -- Limitation:
 -- It can only handle value with upto 18 digits numberic part and 15 digits decimal part  
 -- If numeric part is more than 18 digits error is shown (limitation of BIGINT datatype)
 -- If decimal part is more than 15 digits decimal value will be round off (limitation of function 
 -- FNARemoveTrailingZeroes)
 -- =========================================================================================================


SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[FNAAddThousandSeparator]') AND TYPE IN(N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNAAddThousandSeparator]
GO

CREATE FUNCTION [dbo].[FNAAddThousandSeparator](@value NUMERIC(38,20))
	RETURNS VARCHAR(50) 
AS  
BEGIN 
	DECLARE @value_int AS VARCHAR(50)
	DECLARE @neg AS VARCHAR(50)
	DECLARE @return AS VARCHAR(50)	
	DECLARE @dec AS NUMERIC(38, 20)	
	DECLARE @loop TINYINT 	
	
	SET @value_int = CAST(@value AS BIGINT)	
	SET @return = dbo.FNARemoveTrailingZeroes(@value)	
	SET @dec = ABS(@value - CAST(@value AS BIGINT))  	
	
	IF @value < 0 SET @value_int = CAST(@value_int AS BIGINT) * -1 		
	
	SET @loop = LEN(@value_int) % 3 + 1 

	IF @loop = 1 SET @loop = 4  
	
	WHILE (@loop <= LEN(@value_int))  
	BEGIN 
		  SET @value_int = STUFF(@value_int, @loop, 0, ',')			
		  SET @loop += 4  
	END 	
		
	SELECT @return = @value_int + RIGHT(dbo.FNARemoveTrailingZero(@dec), LEN(dbo.FNARemoveTrailingZero(@dec)) - 1)
	
	IF @value < 0 SET @return = '-' + @return			

	RETURN @return
END

GO
