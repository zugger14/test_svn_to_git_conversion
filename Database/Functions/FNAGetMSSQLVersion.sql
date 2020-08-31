IF OBJECT_ID(N'[dbo].[FNAGetMSSQLVersion]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAGetMSSQLVersion]
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: mshrestha@pioneersolutionsglobal.com
-- Create date: 2013-12-09
-- Description: Function to provide Major Version Number of MSSQL DB
 
-- Params:
-- returns INT Major version Number (e.g. 9 for MSSQL 2005, 10 for MSSQL 2008, 11 for MSSQL 2012)
-- ===========================================================================================================
CREATE FUNCTION [dbo].[FNAGetMSSQLVersion]()
    RETURNS INT
AS
BEGIN
    RETURN dbo.FNAGetSplitPart(CAST(SERVERPROPERTY('productversion') AS VARCHAR(100)), '.', 1) 
END
GO