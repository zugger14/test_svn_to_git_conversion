IF NOT EXISTS(SELECT 'x' from INFORMATION_SCHEMA.COLUMNS c where c.TABLE_NAME = 'contract_group_detail' and c.COLUMN_NAME = 'timeofuse')
ALTER TABLE contract_group_detail ADD timeofuse INT
GO

IF NOT EXISTS(SELECT 'x' from INFORMATION_SCHEMA.COLUMNS c where c.TABLE_NAME = 'contract_group_detail' and c.COLUMN_NAME = 'include_charges')
ALTER TABLE contract_group_detail ADD include_charges CHAR(1)

GO
update contract_group_detail set include_charges='y' where invoice_line_item_id IN(292371,292287,292288,292289,292374,292372,292376,292377,292382,292385,292386,292387,292388,292389,292390,292392,292383,292393,292400,292373,292384,292394,291907,291908,292391)

GO