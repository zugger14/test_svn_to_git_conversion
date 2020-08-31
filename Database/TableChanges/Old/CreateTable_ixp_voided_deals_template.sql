SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
/*
* Created date - 2013-03-21
* Template Table for voided deals.
* ixp_location_template
* Template table - will not store any data, is used for import feature 
*/
IF OBJECT_ID(N'[dbo].[ixp_voided_deals_template]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_voided_deals_template] (
    	[deal_id]     [varchar] (400),
    	[as_of_date]  [varchar] (400),
    	[book]        [varchar] (400)
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_voided_deals_template EXISTS'
END
 
GO				