IF OBJECT_ID('UC_source_minor_location_id_group_id_info_type') IS NULL
BEGIN
	ALTER TABLE [dbo].source_minor_location_nomination_group WITH NOCHECK 
		ADD CONSTRAINT [UC_source_minor_location_id_group_id_info_type] UNIQUE(source_minor_location_id,group_id,info_type)
	PRINT 'Unique Constraints added on source_minor_location_nomination_group.'
END
ELSE
BEGIN
	PRINT 'Unique Constraints on source_minor_location_nomination_group already exists.'
END