SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGINS_counterparty_contract_address]'))
    DROP TRIGGER [dbo].[TRGINS_counterparty_contract_address]
GO
-- insert trigger 
CREATE TRIGGER [dbo].[TRGINS_counterparty_contract_address]
ON [dbo].[counterparty_contract_address]
FOR INSERT
AS
BEGIN
	INSERT INTO counterparty_contract_address_audit
	  (
			counterparty_contract_address_id
			,address1
			,address2
			,address3
			,address4
			,contract_id
			,email
			,fax
			,telephone
			,create_user
			,create_ts
			,update_user
			,update_ts
			,counterparty_id
			,counterparty_full_name
			,contract_start_date
			,contract_end_date
			,apply_netting_rule
			,contract_date
			,contract_status
			,contract_active
			,cc_mail
			,bcc_mail
			,remittance_to
			,cc_remittance
			,bcc_remittance
			,billing_start_month
			,internal_counterparty_id
			,rounding
			,margin_provision
			,time_zone
			,offset_method
			,interest_rate
			,interest_method
			,payment_days
			,invoice_due_date
			,holiday_calendar_id
			,counterparty_trigger
			,company_trigger
			,payables
			,receivables
			,confirmation
			,payment_rule
			,bank_account
			,negative_interest
			,no_of_days
			,secondary_counterparty
			,threshold_provided
			,threshold_received
			,analyst
			,min_transfer_amount
			,comments
			,allow_all_products
			,credit
			,amendment_date
			,amendment_description
			,external_counterparty_id
			,[description]
			,user_action                   
	  )
	SELECT counterparty_contract_address_id
			,address1
			,address2
			,address3
			,address4
			,contract_id
			,email
			,fax
			,telephone
			,create_user
			,create_ts
			,update_user
			,update_ts
			,counterparty_id
			,counterparty_full_name
			,contract_start_date
			,contract_end_date
			,apply_netting_rule
			,contract_date
			,contract_status
			,contract_active
			,cc_mail
			,bcc_mail
			,remittance_to
			,cc_remittance
			,bcc_remittance
			,billing_start_month
			,internal_counterparty_id
			,rounding
			,margin_provision
			,time_zone
			,offset_method
			,interest_rate
			,interest_method
			,payment_days
			,invoice_due_date
			,holiday_calendar_id
			,counterparty_trigger
			,company_trigger
			,payables
			,receivables
			,confirmation
			,payment_rule
			,bank_account
			,negative_interest
			,no_of_days
			,secondary_counterparty
			,threshold_provided
			,threshold_received
			,analyst
			,min_transfer_amount
			,comments
			,allow_all_products
			,credit
			,amendment_date
			,amendment_description
			,external_counterparty_id
			,[description]
	        ,'insert'
	FROM   INSERTED
END

GO
--update trigger
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_counterparty_contract_address]'))
    DROP TRIGGER [dbo].[TRGUPD_counterparty_contract_address]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_counterparty_contract_address]
ON [dbo].[counterparty_contract_address]
FOR UPDATE
AS
BEGIN
	IF NOT UPDATE(update_ts)
    BEGIN
        UPDATE cca
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM counterparty_contract_address cca
        INNER JOIN DELETED d ON d.counterparty_contract_address_id = cca.counterparty_contract_address_id
    END

	INSERT INTO counterparty_contract_address_audit
	  (
			counterparty_contract_address_id
			,address1
			,address2
			,address3
			,address4
			,contract_id
			,email
			,fax
			,telephone
			,create_user
			,create_ts
			,update_user
			,update_ts
			,counterparty_id
			,counterparty_full_name
			,contract_start_date
			,contract_end_date
			,apply_netting_rule
			,contract_date
			,contract_status
			,contract_active
			,cc_mail
			,bcc_mail
			,remittance_to
			,cc_remittance
			,bcc_remittance
			,billing_start_month
			,internal_counterparty_id
			,rounding
			,margin_provision
			,time_zone
			,offset_method
			,interest_rate
			,interest_method
			,payment_days
			,invoice_due_date
			,holiday_calendar_id
			,counterparty_trigger
			,company_trigger
			,payables
			,receivables
			,confirmation
			,payment_rule
			,bank_account
			,negative_interest
			,no_of_days
			,secondary_counterparty
			,threshold_provided
			,threshold_received
			,analyst
			,min_transfer_amount
			,comments
			,allow_all_products
			,credit
			,amendment_date
			,amendment_description
			,external_counterparty_id
			,[description]
			,user_action                   
	  )
	SELECT counterparty_contract_address_id
			,address1
			,address2
			,address3
			,address4
			,contract_id
			,email
			,fax
			,telephone
			,create_user
			,create_ts
			,update_user
			,update_ts
			,counterparty_id
			,counterparty_full_name
			,contract_start_date
			,contract_end_date
			,apply_netting_rule
			,contract_date
			,contract_status
			,contract_active
			,cc_mail
			,bcc_mail
			,remittance_to
			,cc_remittance
			,bcc_remittance
			,billing_start_month
			,internal_counterparty_id
			,rounding
			,margin_provision
			,time_zone
			,offset_method
			,interest_rate
			,interest_method
			,payment_days
			,invoice_due_date
			,holiday_calendar_id
			,counterparty_trigger
			,company_trigger
			,payables
			,receivables
			,confirmation
			,payment_rule
			,bank_account
			,negative_interest
			,no_of_days
			,secondary_counterparty
			,threshold_provided
			,threshold_received
			,analyst
			,min_transfer_amount
			,comments
			,allow_all_products
			,credit
			,amendment_date
			,amendment_description
			,external_counterparty_id
			,[description]
	       ,'update'
	FROM   INSERTED
END

GO
-- delete trigger
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGDEL_counterparty_contract_address]'))
    DROP TRIGGER [dbo].[TRGDEL_counterparty_contract_address]
GO
 
CREATE TRIGGER [dbo].[TRGDEL_counterparty_contract_address]
ON [dbo].[counterparty_contract_address]
FOR DELETE
AS
BEGIN
	INSERT INTO counterparty_contract_address_audit
	  (
			counterparty_contract_address_id
			,address1
			,address2
			,address3
			,address4
			,contract_id
			,email
			,fax
			,telephone
			,create_user
			,create_ts
			,update_user
			,update_ts
			,counterparty_id
			,counterparty_full_name
			,contract_start_date
			,contract_end_date
			,apply_netting_rule
			,contract_date
			,contract_status
			,contract_active
			,cc_mail
			,bcc_mail
			,remittance_to
			,cc_remittance
			,bcc_remittance
			,billing_start_month
			,internal_counterparty_id
			,rounding
			,margin_provision
			,time_zone
			,offset_method
			,interest_rate
			,interest_method
			,payment_days
			,invoice_due_date
			,holiday_calendar_id
			,counterparty_trigger
			,company_trigger
			,payables
			,receivables
			,confirmation
			,payment_rule
			,bank_account
			,negative_interest
			,no_of_days
			,secondary_counterparty
			,threshold_provided
			,threshold_received
			,analyst
			,min_transfer_amount
			,comments
			,allow_all_products
			,credit
			,amendment_date
			,amendment_description
			,external_counterparty_id
			,[description]
			,user_action                   
	  )
	SELECT counterparty_contract_address_id
			,address1
			,address2
			,address3
			,address4
			,contract_id
			,email
			,fax
			,telephone
			,create_user
			,create_ts
			,update_user
			,update_ts
			,counterparty_id
			,counterparty_full_name
			,contract_start_date
			,contract_end_date
			,apply_netting_rule
			,contract_date
			,contract_status
			,contract_active
			,cc_mail
			,bcc_mail
			,remittance_to
			,cc_remittance
			,bcc_remittance
			,billing_start_month
			,internal_counterparty_id
			,rounding
			,margin_provision
			,time_zone
			,offset_method
			,interest_rate
			,interest_method
			,payment_days
			,invoice_due_date
			,holiday_calendar_id
			,counterparty_trigger
			,company_trigger
			,payables
			,receivables
			,confirmation
			,payment_rule
			,bank_account
			,negative_interest
			,no_of_days
			,secondary_counterparty
			,threshold_provided
			,threshold_received
			,analyst
			,min_transfer_amount
			,comments
			,allow_all_products
			,credit
			,amendment_date
			,amendment_description
			,external_counterparty_id
			,[description]
	       ,'delete'
	FROM   DELETED
END