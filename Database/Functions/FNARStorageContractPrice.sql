IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARStorageContractPrice]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARStorageContractPrice]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Function to return contract price of storage deals. Returns contract price

	Parameters 
	@source_deal_header_id : Source Deal Header Id.
	@prod_date : Prod Date for price valuation.	Temporarily not in use.
*/

CREATE FUNCTION [dbo].[FNARStorageContractPrice](
	@source_deal_header_id INT,
	@prod_date DATETIME
)
RETURNS FLOAT AS  
BEGIN 
	DECLARE @value FLOAT
	DECLARE @transport_deal_id FLOAT
	DECLARE @as_of_date DATE

	SELECT @transport_deal_id = MAX(transport_deal_id) FROM optimizer_detail 
	WHERE source_deal_header_id = @source_deal_header_id AND up_down_stream = 'U'

	SELECT @as_of_date = MAX(as_of_date)
	FROM source_deal_settlement sds
		INNER JOIN optimizer_detail  od ON od.source_deal_header_id = sds.source_deal_header_id
	WHERE transport_deal_id = @transport_deal_id AND up_down_stream = 'U'
		--AND @prod_date BETWEEN term_start AND term_end

	SELECT @value = SUM(sds.deal_price* od.volume_used)/SUM(od.volume_used)
	FROM source_deal_settlement sds
		INNER JOIN optimizer_detail  od ON od.source_deal_header_id = sds.source_deal_header_id
			AND sds.as_of_date = @as_of_date
	WHERE transport_deal_id = @transport_deal_id AND up_down_stream = 'U'
		--AND @prod_date BETWEEN term_start AND term_end

	RETURN @value
END

GO



