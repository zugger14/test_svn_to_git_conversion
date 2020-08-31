
DELETE fROM contract_group_detail where invoice_line_item_id IS NULL
DROP INDEX [IX_contract_group_detail] ON  contract_group_detail

IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'contract_group_detail' AND COLUMN_NAME = 'invoice_line_item_id')
BEGIN
	ALTER TABLE contract_group_detail ALTER COLUMN invoice_line_item_id INT NOT NULL
END

GO

 CREATE UNIQUE NONCLUSTERED INDEX [IX_contract_group_detail]  ON contract_group_detail
(
	[invoice_line_item_id] ASC,
	[contract_id] ASC,
	[Prod_type] ASC,
	[deal_type] ASC
)



