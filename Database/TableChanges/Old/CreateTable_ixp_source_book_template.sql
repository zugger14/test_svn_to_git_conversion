SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
/*
* Created date - 2013-03-21
* Template Table for book.
* ixp_location_template
* Template table - will not store any data, is used for import feature 
*/
IF OBJECT_ID(N'[dbo].[ixp_source_book_template]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_source_book_template] (
		[source_system_book_id] [varchar] (100) ,
		[source_system_book_type_value_id] [varchar] (100) ,
		[source_book_name] [varchar] (260) ,
		[source_book_desc] [varchar] (260) ,
		[source_parent_book_id] [varchar] (100) ,
		[source_parent_type] [varchar] (100)
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_source_book_template EXISTS'
END
 
GO