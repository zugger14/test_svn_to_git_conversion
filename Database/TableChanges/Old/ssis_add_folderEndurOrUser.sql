IF not EXISTS(SELECT * FROM sys.[columns] WHERE [object_id]=object_id('stage_sdd') AND [name]='folderEndurOrUser')
	ALTER TABLE stage_sdd ADD folderEndurOrUser VARCHAR(10)