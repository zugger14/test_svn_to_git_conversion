IF OBJECT_ID('UX_nomination_group_effective_date', 'UQ') IS NOT NULL 
BEGIN
	ALTER TABLE nomination_group DROP CONSTRAINT UX_nomination_group_effective_date
	ALTER TABLE nomination_group ADD CONSTRAINT UX_nomination_group_effective_date UNIQUE (nomination_group, effective_date, [priority])	
END
    