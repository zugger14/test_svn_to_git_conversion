--Add 'Capacity PWR' internal deal type
IF NOT EXISTS(SELECT TOP 1 1 FROM internal_deal_type_subtype_types WHERE internal_deal_type_subtype_id=165)
BEGIN
	INSERT INTO internal_deal_type_subtype_types(internal_deal_type_subtype_id,internal_deal_type_subtype_type,type_subtype_flag)
	SELECT 165,'Capacity PWR',null

	PRINT 'Added Internal Deal Type ''Capacity PWR''.'
END
ELSE 
PRINT 'Internal Deal Type ''Capacity PWR'' already exists.'