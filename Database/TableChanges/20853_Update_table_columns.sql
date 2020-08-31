IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'description1' AND Object_ID = Object_ID(N'master_deal_view'))
BEGIN
    ALTER TABLE master_deal_view ALTER COLUMN description1 VARCHAR(1000) NULL
END

IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'description2' AND Object_ID = Object_ID(N'master_deal_view'))
BEGIN
    ALTER TABLE master_deal_view ALTER COLUMN description2 VARCHAR(1000)  NULL
END

IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'description3' AND Object_ID = Object_ID(N'master_deal_view'))
BEGIN
    ALTER TABLE master_deal_view ALTER COLUMN description3 VARCHAR(1000) NULL
END

IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'description1' AND Object_ID = Object_ID(N'delete_source_deal_header'))
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN description1 VARCHAR(1000) NULL
END

IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'description2' AND Object_ID = Object_ID(N'delete_source_deal_header'))
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN description2 VARCHAR(1000) NULL
END

IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'description3' AND Object_ID = Object_ID(N'delete_source_deal_header'))
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN description3 VARCHAR(1000) NULL
END

IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'counterparty_desc' AND Object_ID = Object_ID(N'source_counterparty'))
BEGIN
    ALTER TABLE source_counterparty ALTER COLUMN counterparty_desc nvarchar(250) NULL
END

IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'counterparty_desc' AND Object_ID = Object_ID(N'source_counterparty'))
BEGIN
    ALTER TABLE source_counterparty ALTER COLUMN counterparty_desc nvarchar(250) NULL
END

IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'contact_email' AND Object_ID = Object_ID(N'source_counterparty'))
BEGIN
    ALTER TABLE source_counterparty ALTER COLUMN contact_email varchar(8000) NULL
END

IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'description1' AND Object_ID = Object_ID(N'source_deal_header'))
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN description1 VARCHAR(2000) NULL
END

IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'description2' AND Object_ID = Object_ID(N'source_deal_header'))
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN description2 VARCHAR(100) NULL
END

IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'description3' AND Object_ID = Object_ID(N'source_deal_header'))
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN description3 VARCHAR(100) NULL
END
--source_deal_header_audit

IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'description1' AND Object_ID = Object_ID(N'source_deal_header_audit'))
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN description1 VARCHAR(2000) NULL
END

IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'description2' AND Object_ID = Object_ID(N'source_deal_header_audit'))
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN description2 VARCHAR(1000) NULL
END

IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'description3' AND Object_ID = Object_ID(N'source_deal_header_audit'))
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN description3 VARCHAR(1000) NULL
END

--source_deal_header_template
IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'description1' AND Object_ID = Object_ID(N'source_deal_header_template'))
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN description1 VARCHAR(1000) NULL
END

IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'description2' AND Object_ID = Object_ID(N'source_deal_header_template'))
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN description2 VARCHAR(1000) NULL
END

IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'description3' AND Object_ID = Object_ID(N'source_deal_header_template'))
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN description3 VARCHAR(1000) NULL
END

--select * from counterparty_contacts

---source_counterparty_audit
IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'counterparty_desc' AND Object_ID = Object_ID(N'source_counterparty_audit'))
BEGIN
    ALTER TABLE source_counterparty_audit ALTER COLUMN counterparty_desc NVARCHAR(250) NULL
END

IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'contact_email' AND Object_ID = Object_ID(N'source_counterparty_audit'))
BEGIN
    ALTER TABLE source_counterparty_audit ALTER COLUMN contact_email VARCHAR(8000) NULL
END

IF COL_LENGTH('deal_transfer_mapping', 'fixed_adder') IS NULL
BEGIN
ALTER TABLE deal_transfer_mapping ADD fixed_adder FLOAT
END
ELSE 
BEGIN
       ALTER TABLE deal_transfer_mapping ALTER COLUMN  fixed_adder FLOAT
END
GO

IF COL_LENGTH('deal_transfer_mapping', 'fixed') IS NULL
BEGIN
ALTER TABLE deal_transfer_mapping ADD fixed FLOAT
END
ELSE 
BEGIN
       ALTER TABLE deal_transfer_mapping ALTER COLUMN  fixed FLOAT
END
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'email' AND Object_ID = Object_ID(N'counterparty_contacts'))
BEGIN
    ALTER TABLE counterparty_contacts ALTER COLUMN email VARCHAR(8000) NULL
END


IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'email_cc' AND Object_ID = Object_ID(N'counterparty_contacts'))
BEGIN
    ALTER TABLE counterparty_contacts ALTER COLUMN email_cc VARCHAR(5000) NULL
END

IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'address1' AND Object_ID = Object_ID(N'counterparty_contacts'))
BEGIN
    ALTER TABLE counterparty_contacts ALTER COLUMN address1 VARCHAR(255) NULL
END

IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'address2' AND Object_ID = Object_ID(N'counterparty_contacts'))
BEGIN
    ALTER TABLE counterparty_contacts ALTER COLUMN address2 VARCHAR(255) NULL
END

IF COL_LENGTH('email_notes', 'attachment_file_name') IS NOT NULL
BEGIN
 ALTER FULLTEXT INDEX ON email_notes  disable
  
 EXEC sp_fulltext_column       
@tabname =  'email_notes' , 
@colname =  'attachment_file_name' , 
@action =  'drop' 

  ALTER TABLE email_notes
  ALTER COLUMN attachment_file_name VARCHAR(max)

EXEC sp_fulltext_column       
@tabname =  'email_notes' , 
@colname =  'attachment_file_name' ,  
@action =  'add' 

END
GO