/*
* Alter table confirm_status START
*/
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.[COLUMNS] c WHERE c.TABLE_NAME = 'contract_charge_type' AND c.COLUMN_NAME = 'deal_type')
BEGIN
	ALTER TABLE contract_charge_type5
	ADD deal_type INT
END
ALTER TABLE [dbo].[contract_charge_type]  WITH CHECK ADD  CONSTRAINT [FK_contract_charge_type_source_deal_type] FOREIGN KEY([deal_type])
REFERENCES [dbo].[source_deal_type] ([source_deal_type_id])