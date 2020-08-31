/****** Object:  UserDefinedFunction [dbo].[FNARPriceAdder]    Script Date:2015-12-14 10:21:43 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARPriceAdder]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARPriceAdder]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARPriceAdder]    Script Date:2015-12-14 10:21:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNARPriceAdder]
(
	@term_start                DATETIME,
	@counterparty_id           INT,
	@contract_id               INT,
	@source_deal_detail_id     INT,
	@source_deal_header_id     INT,
	@aggregation_level         INT
)

RETURNS FLOAT AS
BEGIN
	DECLARE @price_adder FLOAT
	
	IF @aggregation_level = 19001
	    SELECT @price_adder = MAX(sdd.price_adder)
	    FROM source_deal_detail sdd
			INNER JOIN source_deal_header sdh
	            ON sdd.source_deal_header_id = sdh.source_deal_header_id
	    WHERE sdh.contract_id = @contract_id
			AND sdh.counterparty_id = @counterparty_id
			AND MONTH(sdd.term_start) = MONTH(@term_start)
			AND YEAR(sdd.term_start) = YEAR(@term_start)
			AND leg = 1
	ELSE IF @aggregation_level = 19000
	    SELECT @price_adder = MAX(sdd.price_adder)
	    FROM source_deal_detail sdd
	    WHERE sdd.source_deal_header_id = @source_deal_header_id
	ELSE IF ISNULL(@aggregation_level, 19002) = 19002
	    SELECT @price_adder = MAX(sdd.price_adder)
	    FROM source_deal_detail sdd
	    WHERE sdd.source_deal_detail_id = @source_deal_detail_id
	
	RETURN @price_adder
END