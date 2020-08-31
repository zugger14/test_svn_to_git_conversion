IF NOT EXISTS (SELECT 1 FROM sys.[columns] AS c WHERE c.name = N'lock' AND c.[object_id] = OBJECT_ID(N'fas_link_header'))
BEGIN
	ALTER TABLE fas_link_header ADD lock CHAR(1)
END

