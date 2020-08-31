/****** Object:  UserDefinedFunction [dbo].[FNARIndexAllocation]    Script Date: 12/15/2010 18:41:32 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARIndexAllocation]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARIndexAllocation]
/****** Object:  UserDefinedFunction [dbo].[FNARIndexAllocation]    Script Date: 12/15/2010 18:41:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
select [dbo].FNARDealFixedVolm(123,1)
*/
CREATE FUNCTION [dbo].[FNARIndexAllocation](
	@source_deal_header_id INT,
	@source_deal_detail_id INT,
	@term_start DATETIME,
	@curve_id INT
)

RETURNS INT AS
BEGIN
	DECLARE @multiplier INT
	
	

	SELECT @multiplier=
			MAX(multiplier) 
	FROM 
		deal_position_break_down 
	WHERE 
		((source_deal_header_id=@source_deal_header_id AND @source_deal_header_id IS NOT NULL)
			OR (source_deal_detail_id = @source_deal_detail_id AND @source_deal_header_id IS NOT NULL))
		AND curve_Id=@curve_id

	IF 	@multiplier IS NULL
		SET @multiplier = 1	
	ELSE IF @multiplier<1
		SET @multiplier = 1
	ELSE
		SET @multiplier = 0
			
	RETURN @multiplier

END


