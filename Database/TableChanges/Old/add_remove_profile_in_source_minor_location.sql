IF  EXISTS( SELECT 1 FROM sys.columns WHERE [name]='profile' AND [object_id]=object_id('source_minor_location'))
BEGIN
	ALTER TABLE source_minor_location DROP COLUMN [profile]
	ALTER TABLE source_minor_location drop column proxy_profile
END


IF NOT EXISTS( SELECT 1 FROM sys.columns WHERE [name]='profile_id' AND [object_id]=object_id('source_minor_location'))
ALTER TABLE source_minor_location ADD profile_id INT,proxy_profile_id INT

