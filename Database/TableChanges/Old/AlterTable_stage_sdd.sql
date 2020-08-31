IF not EXISTS(SELECT * FROM sys.[columns] WHERE [object_id]=object_id('stage_sdd') AND [name]='curve_id_name')
	ALTER TABLE stage_sdd add curve_id_name VARCHAR(50) 