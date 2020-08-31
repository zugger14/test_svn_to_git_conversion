SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[iptrace]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].iptrace
    (
   		id INT identity(1,1), 
   		ip varchar(30), 
   		date_time datetime 
    )
END
ELSE
BEGIN
    PRINT 'Table iptrace EXISTS'
END
 
GO

