/****** Object:  UserDefinedFunction [dbo].[FNARRateScheduleFee]    Script Date: 01/11/2011 09:49:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARRateScheduleFee]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARRateScheduleFee]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARRateScheduleFee]    Script Date: 01/11/2011 09:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Function to return rate scheuld fee defined in deal and contract

	Parameters 
	@as_of_date : As Of Date
	@source_deal_header_id : Source Deal Header Id
	@contract_id : Contract ID
	@rate_type_id : Rate Type
	@prod_date : Production Date
	Returns fee value
*/

CREATE FUNCTION [dbo].[FNARRateScheduleFee](@as_of_date DATETIME,@source_deal_header_id INT,@contract_id INT, @rate_type_id INT, @prod_date DATETIME)

RETURNS FLOAT AS
BEGIN
	DECLARE @rate_value FLOAT
	,@rate_value1 FLOAT
	,@rate_schedule INT

	IF NULLIF(@source_deal_header_id, '') IS NOT NULL 
	BEGIN
		SELECT @contract_id = contract_id FROM source_deal_header WHERE source_deal_header_id = @source_deal_header_id
	END

	SET @prod_date = EOMONTH(@prod_date)

	SELECT @rate_schedule = maintain_rate_schedule FROM contract_group WHERE contract_id = @contract_id

	SELECT @rate_value = SUM(CAST(trs1.rate AS FLOAT))
	FROM (
		SELECT MAX(effective_date) effective_date
			, rate_schedule_id
			, rate_type_id
		FROM transportation_rate_schedule trs
		WHERE rate_type_id = @rate_type_id
			AND rate_schedule_id = @rate_schedule
			AND @prod_date >= ISNULL(effective_date, @prod_date)
		GROUP BY rate_schedule_id, rate_type_id
		) trs
	INNER JOIN transportation_rate_schedule trs1 ON ISNULL(trs1.effective_date, '1990-01-01') = ISNULL(trs.effective_date, '1990-01-01')
		AND trs1.rate_schedule_id = trs.rate_schedule_id
		AND trs1.rate_type_id = trs.rate_type_id

	SELECT @rate_value1 = SUM(CAST(vc1.rate AS FLOAT))
	FROM (
		SELECT MAX(effective_date) effective_date
			, rate_schedule_id
			, rate_type_id
		FROM variable_charge
		WHERE rate_type_id = @rate_type_id
			AND rate_schedule_id = @rate_schedule
			AND @prod_date >= ISNULL(effective_date, @prod_date)
		GROUP BY rate_schedule_id, rate_type_id
		) vc
	INNER JOIN variable_charge vc1 ON ISNULL(vc1.effective_date, '1990-01-01') = ISNULL(vc.effective_date, '1990-01-01')
		AND vc1.rate_schedule_id = vc.rate_schedule_id
		AND vc1.rate_type_id = vc.rate_type_id

	RETURN COALESCE(@rate_value, @rate_value1, 0)

END

