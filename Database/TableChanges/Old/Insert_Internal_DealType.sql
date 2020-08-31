-- select * from internal_deal_type_subtype_types
-- select * from source_deal_type

IF NOT EXISTS(select 'X' FROM internal_deal_type_subtype_types WHERE internal_deal_type_subtype_id=19)
	INSERT INTO internal_deal_type_subtype_types(internal_deal_type_subtype_id,internal_deal_type_subtype_type,type_subtype_flag)
	SELECT 19,'Storage Actual','y'
	UNION
	SELECT 20,'Storage Nomination','y'
	UNION
	SELECT 21,'Storage Scheduled','y'

