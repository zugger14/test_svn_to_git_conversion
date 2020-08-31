SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
/*
* Created date - 2013-03-21
* Template Table for source uom.
* ixp_location_template
* Template table - will not store any data, is used for import feature 
*/
IF OBJECT_ID(N'[dbo].[ixp_source_uom_template]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_source_uom_template] (
    	[uom_id]    [varchar] (400),
    	[uom_name]  [varchar] (400),
    	[uom_desc]  [varchar] (400)
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_source_uom_template EXISTS'
END
 
GO				