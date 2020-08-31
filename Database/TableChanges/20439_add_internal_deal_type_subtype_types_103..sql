			 
IF NOT EXISTS(select * FROM internal_deal_type_subtype_types WHERE internal_deal_type_subtype_id=103)
	INSERT INTO internal_deal_type_subtype_types(internal_deal_type_subtype_id,internal_deal_type_subtype_type,type_subtype_flag)
	SELECT 103,'Linear Asset Model',null
	