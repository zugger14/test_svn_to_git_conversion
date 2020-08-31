IF OBJECT_ID(N'FNARDealFVolm', N'FN') IS NOT NULL
DROP FUNCTION dbo.FNARDealFVolm
 GO 

CREATE FUNCTION dbo.FNARDealFVolm (
				@source_deal_header_id INT,
				@source_deal_detail_id INT,
				@as_of_date DATETIME,
				@term_start DATETIME,
				@aggregation_level INT,
				@udf_type_value_id INT
				)
RETURNS float AS  
BEGIN 
	DECLARE @deal_fees_volume FLOAT
	
	IF @aggregation_level=19000
	BEGIN
		If dbo.FNAGETContractMonth(@term_start) > dbo.FNAGETContractMonth(@as_of_date) 					
			SELECT @deal_fees_volume =	SUM(volume)
			FROM
				index_fees_breakdown ifb inner join
				source_deal_detail sdd on sdd.source_deal_header_id = ifb.source_deal_header_id and
					sdd.leg = ifb.leg
			WHERE
				sdd.source_deal_header_id = @source_deal_header_id
				AND field_id = 	@udf_type_value_id
				AND dbo.FNAGETContractMonth(as_of_date) = dbo.FNAGETContractMonth(@as_of_date)
				AND dbo.FNAGETContractMonth(ifb.term_start) = dbo.FNAGETContractMonth(@term_start)
		Else
			SELECT @deal_fees_volume =	SUM(volume)
			FROM
				index_fees_breakdown_settlement ifb inner join
				source_deal_detail sdd on sdd.source_deal_header_id = ifb.source_deal_header_id and
					sdd.leg = ifb.leg
				AND (ifb.set_type = 'f' AND ifb.as_of_date = @as_of_date OR ( ifb.set_type = 's' AND @as_of_date>=ifb.term_end))		
			WHERE
				sdd.source_deal_header_id = @source_deal_header_id
				AND field_id = 	@udf_type_value_id
				--AND dbo.FNAGETContractMonth(as_of_date) = dbo.FNAGETContractMonth(@as_of_date)
				AND dbo.FNAGETContractMonth(ifb.term_start) = dbo.FNAGETContractMonth(@term_start)
		END
		ELSE
		BEGIN
		If dbo.FNAGETContractMonth(@term_start) > dbo.FNAGETContractMonth(@as_of_date) 					
			SELECT @deal_fees_volume =	SUM(volume)
			FROM
				index_fees_breakdown ifb inner join
				source_deal_detail sdd on sdd.source_deal_header_id = ifb.source_deal_header_id and
					sdd.leg = ifb.leg
			WHERE
				sdd.source_deal_detail_id = @source_deal_detail_id
				AND field_id = 	@udf_type_value_id
				AND dbo.FNAGETContractMonth(as_of_date) = dbo.FNAGETContractMonth(@as_of_date)
				AND dbo.FNAGETContractMonth(ifb.term_start) = dbo.FNAGETContractMonth(@term_start)
		Else
			SELECT @deal_fees_volume =	SUM(volume)
			FROM
				index_fees_breakdown_settlement ifb inner join
				source_deal_detail sdd on sdd.source_deal_header_id = ifb.source_deal_header_id and
					sdd.leg = ifb.leg
				AND (ifb.set_type = 'f' AND ifb.as_of_date = @as_of_date OR ( ifb.set_type = 's' AND @as_of_date>=ifb.term_end))		
			WHERE
				sdd.source_deal_detail_id = @source_deal_detail_id
				AND field_id = 	@udf_type_value_id
				--AND dbo.FNAGETContractMonth(as_of_date) = dbo.FNAGETContractMonth(@as_of_date)
				AND dbo.FNAGETContractMonth(ifb.term_start) = dbo.FNAGETContractMonth(@term_start)
		
		END		
	RETURN isnull(@deal_fees_volume, 0)
END




