SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
/*
* Created date - 2013-03-21
* Template Table for source counterparty.
* ixp_location_template
* Template table - will not store any data, is used for import feature 
*/
IF OBJECT_ID(N'[dbo].[ixp_source_counterparty_template]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_source_counterparty_template] (
    	[counterparty_id]                 VARCHAR(500),
    	[counterparty_name]               VARCHAR(500),
    	[counterparty_desc]               VARCHAR(500),
    	[int_ext_flag]                    VARCHAR(100),
    	[netting_parent_counterparty_id]  VARCHAR(100),
    	[counterparty_address1]           VARCHAR(500),
    	[counterparty_address2]           VARCHAR(500),
    	[counterparty_address3]           VARCHAR(500),
    	[counterparty_address4]           VARCHAR(500),
    	[counterparty_contact]            VARCHAR(500),
    	[telephone]                       VARCHAR(500),
    	[fax]                             VARCHAR(500),
    	[counterparty_type]               VARCHAR(20)
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_source_counterparty_template EXISTS'
END
 
GO				