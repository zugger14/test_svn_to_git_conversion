--add 'Capacity Release' internal deal type
IF NOT EXISTS(select top 1 1 FROM internal_deal_type_subtype_types WHERE internal_deal_type_subtype_id=157)
begin
	INSERT INTO internal_deal_type_subtype_types(internal_deal_type_subtype_id,internal_deal_type_subtype_type,type_subtype_flag)
	SELECT 157,'Capacity Release',null

	print 'Added Internal Deal Type ''Capacity Release''.'
end
else print 'Internal Deal Type ''Capacity Release'' already exists.'
	