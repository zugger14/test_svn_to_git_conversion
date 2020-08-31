SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
/*
* Created date - 2013-03-21
* Template Table for deal type.
* ixp_location_template
* Template table - will not store any data, is used for import feature 
*/
IF OBJECT_ID(N'[dbo].[ixp_source_deal_type_template]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_source_deal_type_template] (
		[deal_type_id] [varchar] (100) ,
		[source_deal_type_name] [varchar] (100) ,
		[source_deal_desc] [varchar] (260) ,
		[deal_sub_type_flag] [varchar] (1)
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_source_deal_type_template EXISTS'
END
 
GO		