IF NOT OBJECTPROPERTY(OBJECT_ID('application_notes'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON application_notes (FS_Data TYPE COLUMN type_column_name) KEY INDEX PK_application_notes;
END
ELSE
    PRINT 'FULLTEXT INDEX ON application_notes Already Exists.'
GO

IF NOT OBJECTPROPERTY(OBJECT_ID('[dbo].[contract_group]'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON [dbo].contract_group (
		[contract_name],
		[contract_desc],
		[name],
		[company],
		[address],
		[address2]
	) KEY INDEX PK_contract_group;
	PRINT 'FULLTEXT INDEX ON contract_group created.'
END
ELSE
    PRINT 'FULLTEXT INDEX ON contract_group Already Exists.'
GO

IF NOT OBJECTPROPERTY(OBJECT_ID('counterparty_bank_info'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON counterparty_bank_info (bank_name,wire_ABA,ACH_ABA,Account_no,Address1,Address2,accountname,reference) KEY INDEX PK_counterparty_bank_info;
END
ELSE
    PRINT 'FULLTEXT INDEX ON counterparty_bank_info Already Exists.'
GO

IF NOT EXISTS (SELECT 1 FROM sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[email_notes]'))
	CREATE FULLTEXT INDEX ON [dbo].[email_notes](
	FS_Data TYPE COLUMN type_column_name LANGUAGE [English], 
	notes_object_name LANGUAGE [English], 
	notes_subject LANGUAGE [English], 
	notes_text LANGUAGE [English], 
	attachment_file_name LANGUAGE [English], 
	notes_description LANGUAGE [English], 
	send_from LANGUAGE [English], 
	send_to LANGUAGE [English], 
	send_cc LANGUAGE [English], 
	send_bcc LANGUAGE [English]
	)
	KEY INDEX [PK_email_notes] ON ([TRMTrackerFTI], FILEGROUP [PRIMARY])
	--WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)
GO


IF EXISTS (SELECT * FROM   sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[attachment_detail_info]'))
    DROP FULLTEXT INDEX ON [dbo].[attachment_detail_info]
GO
IF NOT EXISTS (SELECT 1 FROM sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[attachment_detail_info]'))
	CREATE FULLTEXT INDEX ON [dbo].[attachment_detail_info](
		FS_Data TYPE COLUMN attachment_file_ext LANGUAGE [English], 
		attachment_file_name LANGUAGE [English]
	)
	KEY INDEX [PK_attachment_detail_info] ON ([attachment_detail_info_FT], FILEGROUP [PRIMARY])
	--WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)
GO
PRINT 'FULLTEXT INDEX on attachment_detail_info dropped and created.'

IF EXISTS (
       SELECT 1
       FROM   sys.fulltext_indexes fti
       WHERE  fti.object_id = OBJECT_ID(N'[dbo].[master_view_counterparty_contacts]')
   )
BEGIN
	DROP FULLTEXT INDEX ON [dbo].[master_view_counterparty_contacts]
END

IF NOT EXISTS (SELECT 1 FROM sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[master_view_counterparty_contacts]'))
	CREATE FULLTEXT INDEX ON [dbo].[master_view_counterparty_contacts] (
		title,name,address1,address2,city,state,zip,country,region,email,comment,telephone,fax,cell_no,email_cc,email_bcc
	) KEY INDEX PK_master_view_counterparty_contacts;
	PRINT 'FULLTEXT INDEX ON master_view_counterparty_contacts created.'
GO
PRINT 'FULLTEXT INDEX on [master_view_counterparty_contacts] dropped and created.'


IF NOT OBJECTPROPERTY(OBJECT_ID('[dbo].[master_view_counterparty_contract_address]'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON [dbo].[master_view_counterparty_contract_address] (
		[address1],[address2],[address3],[address4],[contract_id],[email],[fax],[telephone],[counterparty_id],[counterparty_full_name],[contract_start_date],[contract_end_date],[contract_date],[contract_status],[contract_active],[cc_mail],[bcc_mail],[remittance_to],[cc_remittance],[bcc_remittance],[internal_counterparty_id],[analyst],[comments], [counterparty_trigger], [company_trigger],[margin_provision],[counterparty_name]
	) KEY INDEX PK_master_view_counterparty_contract_address;
	PRINT 'FULLTEXT INDEX ON master_view_counterparty_contract_address created.'
END
ELSE
    PRINT 'FULLTEXT INDEX ON master_view_counterparty_contract_address Already Exists.'
GO

IF NOT OBJECTPROPERTY(OBJECT_ID('[dbo].[master_view_counterparty_credit_enhancements]'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON [dbo].[master_view_counterparty_credit_enhancements] (
		enhance_type,guarantee_counterparty,comment,currency_code,eff_date,approved_by,expiration_date,contract_id,internal_counterparty,collateral_status
	) KEY INDEX PK_master_view_counterparty_credit_enhancements;
	PRINT 'FULLTEXT INDEX ON master_view_counterparty_credit_enhancements created.'
END
ELSE
    PRINT 'FULLTEXT INDEX ON master_view_counterparty_credit_enhancements Already Exists.'
GO

IF NOT OBJECTPROPERTY(OBJECT_ID('[dbo].[master_view_counterparty_credit_info]'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON [dbo].[master_view_counterparty_credit_info] (
		Counterparty_id,account_status,limit_expiration,curreny_code,Tenor_limit,Industry_type1,Industry_type2,SIC_Code,Duns_No,Risk_rating,Debt_rating,Ticker_symbol,Date_established,Next_review_date,Last_review_date,Customer_since,Approved_by,Settlement_contact_name,Settlement_contact_address,Settlement_contact_address2,Settlement_contact_phone,Settlement_contact_email,payment_contact_name,payment_contact_address,contactfax,payment_contact_phone,payment_contact_email,Debt_Rating2,Debt_Rating3,Debt_Rating4,Debt_Rating5,payment_contact_address2,analyst,rating_outlook
	) KEY INDEX PK_master_view_counterparty_credit_info;
	PRINT 'FULLTEXT INDEX ON master_view_counterparty_credit_info created.'
END
ELSE
    PRINT 'FULLTEXT INDEX ON master_view_counterparty_credit_info Already Exists.'
GO

IF NOT OBJECTPROPERTY(OBJECT_ID('[dbo].[master_view_counterparty_credit_limits]'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON [dbo].[master_view_counterparty_credit_limits] (
		counterparty_id,internal_counterparty_id,contract_id,limit_status
	) KEY INDEX PK_master_view_counterparty_credit_limits;
	PRINT 'FULLTEXT INDEX ON master_view_counterparty_credit_limits created.'
END
ELSE
    PRINT 'FULLTEXT INDEX ON master_view_counterparty_credit_limits Already Exists.'
GO

IF NOT OBJECTPROPERTY(OBJECT_ID('[dbo].[master_view_counterparty_credit_migration]'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON [dbo].[master_view_counterparty_credit_migration] (
		effective_date,counterparty,internal_counterparty,[contract],rating
	) KEY INDEX PK_master_view_counterparty_credit_migration;
	PRINT 'FULLTEXT INDEX ON master_view_counterparty_credit_migration created.'
END
ELSE
    PRINT 'FULLTEXT INDEX ON master_view_counterparty_credit_migration Already Exists.'
GO

IF NOT OBJECTPROPERTY(OBJECT_ID('[dbo].[master_view_counterparty_epa_account]'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON [dbo].[master_view_counterparty_epa_account] (
		counterparty_name,external_type_id,external_value
	) KEY INDEX PK_master_view_counterparty_epa_account;
	PRINT 'FULLTEXT INDEX ON master_view_counterparty_epa_account created.'
END
ELSE
    PRINT 'FULLTEXT INDEX ON master_view_counterparty_epa_account Already Exists.'
GO

IF NOT OBJECTPROPERTY(OBJECT_ID('[dbo].[master_view_counterparty_products]'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON [dbo].[master_view_counterparty_products] (
		[commodity],
		[origin],
		[form],
		[attr1],
		[attr2],
		[attr3],
		[attr4],
		[attr5],
		[trader]
	) KEY INDEX PK_master_view_counterparty_products;
	PRINT 'FULLTEXT INDEX ON master_view_counterparty_products created.'
END
ELSE
    PRINT 'FULLTEXT INDEX ON master_view_counterparty_products Already Exists.'
GO

IF NOT OBJECTPROPERTY(OBJECT_ID('[dbo].[master_view_incident_log]'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON [dbo].[master_view_incident_log] (
		incident_type, incident_description, incident_status, buyer_from, seller_to, [location], date_initiated, date_closed, trader, logistics, corrective_action, preventive_action, [contract], [counterparty], [internal_counterparty]
	) KEY INDEX PK_master_view_incident_log;
	PRINT 'FULLTEXT INDEX ON master_view_incident_log created.'
END
ELSE
    PRINT 'FULLTEXT INDEX ON master_view_incident_log Already Exists.'
GO

IF NOT OBJECTPROPERTY(OBJECT_ID('[dbo].[master_view_incident_log_detail]'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON [dbo].[master_view_incident_log_detail] (
		incident_status,incident_update_date,comments
	) KEY INDEX PK_master_view_incident_log_detail;
	PRINT 'FULLTEXT INDEX ON master_view_incident_log_detail created.'
END
ELSE
    PRINT 'FULLTEXT INDEX ON master_view_incident_log_detail Already Exists.'
GO