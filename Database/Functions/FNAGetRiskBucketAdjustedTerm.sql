/****** Object:  UserDefinedFunction [dbo].[FNAGetRiskBucketAdjustedTerm]    Script Date: 07/30/2010 14:36:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetRiskBucketAdjustedTerm]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [FNAGetRiskBucketAdjustedTerm]
GO
-- ==================================================================================
-- Create date: 2010-01-29 3:070PM
-- Description:	Returns the given bucket adjusted date for a given as_of_date
-- Param: 
--	@as_of_date datetime - as of date
--	@bucket_id int - risk bucket id
-- Returns: Bucket adjusted date
-- ==================================================================================
CREATE FUNCTION [dbo].[FNAGetRiskBucketAdjustedTerm](
	@as_of_date DATETIME,
	@bucket_id INT,
	@use_tenor_from BIT = 1
)
RETURNS DATETIME
AS
BEGIN
	
	DECLARE @tenor_value INT,
			@fromTenor CHAR(1), 
			@toTenor CHAR(1), 
			@year INT,
			@new_as_of_date VARCHAR(100),
			@month INT
	
	SELECT @tenor_value = (CASE WHEN @use_tenor_from = 1 THEN tenor_from ELSE tenor_to END),@fromTenor = fromMonthYear, @toTenor = toMonthYear
	FROM risk_tenor_bucket_detail
	WHERE bucket_detail_id = @bucket_id
	IF @tenor_value=0 
		SET @tenor_value=1
		
	IF @use_tenor_from = 1
	BEGIN
		IF @fromTenor = 'm'
		BEGIN
			SELECT @new_as_of_date = DATEADD(m, @tenor_value, dbo.fnagetcontractmonth(@as_of_date))
		END
		ELSE IF @fromTenor = 'y'
		BEGIN
			SET @year = Year(@as_of_date)
			SELECT @new_as_of_date = (CAST((@year+@tenor_value) AS VARCHAR)+ '-01' +'-01')
		END
	END
	ELSE IF @use_tenor_from = 0
	BEGIN
		IF @toTenor = 'm'
		BEGIN
			SELECT @new_as_of_date = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@as_of_date)+1+@tenor_value,0))
		END
		ELSE IF @toTenor = 'y'
		BEGIN
			SET @year = Year(@as_of_date)
			SELECT @new_as_of_date = (CAST((@year+@tenor_value) AS VARCHAR)+ '-12' +'-31')
		END
	END
	RETURN @new_as_of_date
END

