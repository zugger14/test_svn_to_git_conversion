SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/*
* Created date - 2015-03-9
* Template Table for counterparty_contacts.
* ixp_counterparty_contacts
* Template table - will not store any data, is used for import feature 
*/
IF OBJECT_ID(N'[dbo].[ixp_counterparty_contacts]', N'U') IS NOT NULL
BEGIN
	DROP TABLE ixp_counterparty_contacts
END
IF OBJECT_ID(N'[dbo].[ixp_counterparty_contacts]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_counterparty_contacts] (
    	company VARCHAR(250),
    	counterparty_id	VARCHAR(250),
    	contact_type VARCHAR(250),
    	title VARCHAR(250),
    	name VARCHAR(250),
		id VARCHAR(250),
		address1 VARCHAR(250),
		address2 VARCHAR(250),
		city VARCHAR(250),
		[state] VARCHAR(250),
		zip	VARCHAR(250),
		telephone VARCHAR(250),
		fax	VARCHAR(250),
		email VARCHAR(250),
		country	VARCHAR(250),
		region VARCHAR(250),
		comment	VARCHAR(250),
		is_active VARCHAR(250),
		is_primary VARCHAR(250)
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_counterparty_contacts EXISTS'
END
