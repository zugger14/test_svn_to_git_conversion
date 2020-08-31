SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'FNARGetWACOGPoolPrice') IS NOT NULL
DROP FUNCTION [dbo].[FNARGetWACOGPoolPrice]
GO

CREATE FUNCTION [dbo].[FNARGetWACOGPoolPrice]  (@wacog_group_id INT,@as_of_date datetime,@term_start DATETIME,@source_deal_header_id INT)
RETURNS FLOAT AS  
BEGIN 
	DECLARE @wacog FLOAT
	
	DECLARE @granularity_var VARCHAR(4)
	SELECT @granularity_var = term_frequency FROM source_deal_header where source_deal_header_id=@source_deal_header_id
	IF @granularity_var = 'd'
	BEGIN 
		SELECT @wacog = MAX(wacog)
		FROM calculate_wacog_group AS cwg
		WHERE wacog_group_id = @wacog_group_id
			AND cwg.as_of_date = @as_of_date
			AND cwg.term = @term_start
	END
	IF @granularity_var = 'm' 
	BEGIN
		SELECT @wacog = AVG(wacog)
		FROM calculate_wacog_group AS cwg
		WHERE wacog_group_id = @wacog_group_id
			AND cwg.as_of_date = @as_of_date
			AND YEAR(cwg.term) = YEAR(@term_start)
			AND MONTH(cwg.term) = MONTH(@term_start)
	END
	
			
	RETURN ISNULL(@wacog, 0)
END
