IF not EXISTS(SELECT * FROM sys.[columns] WHERE [object_id]=object_id('stage_sdd') AND [name]='trade_status')
	ALTER TABLE stage_sdd ADD trade_status VARCHAR(10)