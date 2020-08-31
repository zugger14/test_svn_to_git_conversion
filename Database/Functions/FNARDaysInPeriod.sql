IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARDaysInPeriod]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARDaysInPeriod]
GO

CREATE FUNCTION [dbo].[FNARDaysInPeriod](@source_deal_detail_id INT)
RETURNS FLOAT
AS
BEGIN
	DECLARE @value INT	
	DECLARE @term_start DATETIME,	@term_end DATETIME
	
	--SET @source_deal_detail_id = 6937
	
	SELECT @term_start = sdd.term_start
	FROM   source_deal_detail sdd
	WHERE  sdd.source_deal_detail_id = @source_deal_detail_id
	
	SELECT @term_end = sdd.term_end
	FROM   source_deal_detail sdd
	WHERE  sdd.source_deal_detail_id = @source_deal_detail_id
	
	SET @value = DATEDIFF(DAY, @term_start, @term_end) + 1
	
	RETURN @value
END