IF OBJECT_ID(N'FNARDealFees', N'FN') IS NOT NULL
DROP FUNCTION FNARDealFees
GO 
CREATE FUNCTION dbo.FNARDealFees (
				@source_deal_header_id INT,
				@as_of_date DATETIME,
				@term_start DATETIME,
				@calc_aggregation INT,
				@counterparty_id INT,
				@contract_id INT,
				@cpt_model_type CHAR(1),
				@udf_type_value_id INT
				)
RETURNS float AS  
BEGIN 
	DECLARE @deal_fees FLOAT
	
	IF @cpt_model_type <> 'm'
	BEGIN
		If dbo.FNAGETContractMonth(@term_start) > dbo.FNAGETContractMonth(@as_of_date) 					
			SELECT @deal_fees =	[value]
			FROM
				index_fees_breakdown ifb inner join
				source_deal_detail sdd on sdd.source_deal_header_id = ifb.source_deal_header_id and
					sdd.leg = ifb.leg
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id	
			WHERE
				((sdd.source_deal_detail_id = @source_deal_header_id AND @calc_aggregation = 19002)
					OR(sdd.source_deal_header_id = @source_deal_header_id AND @calc_aggregation = 19000)
					OR(sdh.contract_id = @contract_id AND sdh.counterparty_id = @counterparty_id AND @calc_aggregation = 19001)
				)	
				AND field_id = 	@udf_type_value_id
				AND dbo.FNAGETContractMonth(as_of_date) = dbo.FNAGETContractMonth(@as_of_date)
				AND dbo.FNAGETContractMonth(ifb.term_start) = dbo.FNAGETContractMonth(@term_start)
		Else
			SELECT @deal_fees =	[value]
			FROM
				index_fees_breakdown_settlement ifb inner join
				source_deal_detail sdd on sdd.source_deal_header_id = ifb.source_deal_header_id and
					sdd.leg = ifb.leg
				AND (ifb.set_type = 'f' AND ifb.as_of_date = @as_of_date OR ( ifb.set_type = 's' AND  @as_of_date >= ifb.term_end))	
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
			WHERE
				((sdd.source_deal_detail_id = @source_deal_header_id AND @calc_aggregation = 19002)
					OR(sdd.source_deal_header_id = @source_deal_header_id AND @calc_aggregation = 19000)
					OR(sdh.contract_id = @contract_id AND sdh.counterparty_id = @counterparty_id AND @calc_aggregation = 19001)
				)	
				AND field_id = 	@udf_type_value_id
				AND dbo.FNAGETContractMonth(ifb.term_start) = dbo.FNAGETContractMonth(@term_start)
	END			
	ELSE
	BEGIN
		SELECT @deal_fees =	SUM([value])
			FROM
				index_fees_breakdown_settlement ifb inner join
				source_deal_detail sdd on sdd.source_deal_header_id = ifb.source_deal_header_id and
					sdd.leg = ifb.leg
				AND (ifb.set_type = 'f' AND ifb.as_of_date = @as_of_date OR ( ifb.set_type = 's' AND  @as_of_date >= ifb.term_end))	
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
				INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
			WHERE
				((sdd.source_deal_detail_id = @source_deal_header_id AND @calc_aggregation = 19002)
					OR(sdd.source_deal_header_id = @source_deal_header_id AND @calc_aggregation = 19000)
					OR(sdht.model_id = @counterparty_id AND @calc_aggregation = 19001)
				)	
				AND field_id = 	@udf_type_value_id
				AND dbo.FNAGETContractMonth(ifb.term_start) = dbo.FNAGETContractMonth(@term_start)
	
	END			
		
	RETURN isnull(@deal_fees, 0)
END




