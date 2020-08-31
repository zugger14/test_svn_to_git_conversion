/****** Object:  UserDefinedFunction [dbo].[FNARDPrice]    Script Date: 04/09/2009 16:53:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARDPrice]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARDPrice]
/****** Object:  UserDefinedFunction [dbo].[FNARDPrice]    Script Date: 04/09/2009 16:53:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARDPrice](@source_deal_header_id int,@maturity_date DATETIME,@granularity INT,@he INT,@as_of_date DATETIME)
RETURNS float AS  
BEGIN 
	DECLARE @fixed_price float,@index_price FLOAT
	SET @fixed_price=0
	SET @index_price=0
	

	SELECT 
		@index_price = deal_price
	FROM
		source_deal_settlement sds
	WHERE
		source_deal_header_id=@source_deal_header_id
		--AND as_of_date=@as_of_date
		AND YEAR(term_start)=YEAR(@maturity_date)
		AND MONTH(term_start)=MONTH(@maturity_date)		
		AND (sds.set_type = 'f' AND sds.as_of_date = @as_of_date OR ( sds.set_type = 's' AND @as_of_date>= sds.term_end))	

	--SET @index_price=@fixed_price
	RETURN @index_price
END



