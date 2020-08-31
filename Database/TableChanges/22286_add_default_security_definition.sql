IF NOT EXISTS(SELECT 'X' FROM ice_security_definition WHERE product_id=-1)
	INSERT INTO ice_security_definition(product_id,exchange_name,product_name,granularity,hub_name,hub_alias,security_definition_id,leg_symbol,symbol)
	SELECT -1,0,'Default',980,'Default','Default',1,-1,-1

