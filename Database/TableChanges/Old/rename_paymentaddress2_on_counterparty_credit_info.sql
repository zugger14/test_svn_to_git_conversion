--IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'counterparty_credit_info' AND COLUMN_NAME = 'payment_contact_address2')
--BEGIN
	sp_rename 'counterparty_credit_info.payment_contact_address2', contactfax
--END