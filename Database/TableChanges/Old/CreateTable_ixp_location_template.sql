SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
/*
* Created date - 2013-03-21
* Template Table for Location.
* ixp_location_template
* Template table - will not store any data, is used for import feature 
*/
IF OBJECT_ID(N'[dbo].[ixp_location_template]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_location_template] (
    	location_id           VARCHAR(300),
    	location_name         VARCHAR(300),
    	location_description  VARCHAR(500)
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_location_template EXISTS'
END
 
GO
