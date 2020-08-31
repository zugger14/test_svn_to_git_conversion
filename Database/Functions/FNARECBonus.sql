IF OBJECT_ID(N'FNARECBonus', N'FN') IS NOT NULL
DROP FUNCTION dbo.FNARECBonus
GO 
-- select dbo.FNARECBonus(1083)

--54151

CREATE FUNCTION dbo.FNARECBonus
(
	@deal_id INT
)
RETURNS float AS  
BEGIN

DECLARE @bonus float

SELECT  @bonus = CASE WHEN  (isnull(sdh.status_value_id , 5171) IN (5171, 5177)) THEN 
		--isnull(spb.bonus_per, 0) * 
		COALESCE(spb.bonus_per, spbAll.bonus_per, 0) *
		sdd.deal_volume  
		--CASE WHEN (sdd.buy_sell_flag = 's') THEN -1 * sdd.deal_volume ELSE sdd.deal_volume END
	ELSE 0 END
		
FROM  	source_deal_detail sdd LEFT OUTER JOIN
      	source_deal_header sdh on sdh.source_deal_header_id = sdd.source_deal_header_id 	
	left outer join 
	 rec_generator rg on rg.generator_id = sdh.generator_id 
	left outer join state_properties sp on sp.state_value_id = isnull(sdh.state_value_id, rg.state_value_id)

	left outer join state_properties_bonus spb on  	--specific to where it is generated
			spb.state_value_id = sp.state_value_id and 
			spb.technology = rg.technology and
			isnull(spb.assignment_type_value_id, 5149) =  
				isnull(sdh.assignment_type_value_id, 5149) and
				sdd.term_start between spb.from_date and spb.to_date  and
			spb.gen_code_value = rg.gen_state_value_id

	left outer join state_properties_bonus spbAll on  	
			spbAll.state_value_id = sp.state_value_id and 
			spbAll.technology = rg.technology and
			isnull(spbAll.assignment_type_value_id, 5149) =  
				isnull(sdh.assignment_type_value_id, 5149) and
				sdd.term_start between spbAll.from_date and spbAll.to_date  and
			spbAll.gen_code_value is NULL

						 

WHERE   sdd.source_deal_detail_id = @deal_id

return isnull(@bonus, 0)
	
END

















