SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
/*
* Created date - 2013-03-21
* Template Table for source currency.
* ixp_location_template
* Template table - will not store any data, is used for import feature 
*/
IF OBJECT_ID(N'[dbo].[ixp_source_currency_template]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_source_currency_template] (
		[currency_id] [varchar] (100) ,
		[currency_name] [varchar] (260) ,
		[currency_desc] [varchar] (260) 
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_source_currency_template EXISTS'
END
 
GO		