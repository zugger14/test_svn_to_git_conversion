IF NOT EXISTS(SELECT 1 FROM internal_deal_type_subtype_types WHERE internal_deal_type_subtype_id = 158)
BEGIN 
	INSERT INTO internal_deal_type_subtype_types(internal_deal_type_subtype_id, internal_deal_type_subtype_type, type_subtype_flag)
	SELECT 158, 'Physical - Oil and Soft', 'y'
END 
GO
