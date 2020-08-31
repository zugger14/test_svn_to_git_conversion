IF OBJECT_ID(N'[dbo].[spa_printer_configuration]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_printer_configuration]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2013-03-13
-- Description: CRUD operations for table EXEC spa_printer_configuration
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_printer_configuration]
    @flag CHAR(1)
AS
 
DECLARE @SQL VARCHAR(MAX)
 
IF @flag = 's'
BEGIN
    SELECT pc.printer_id,
           pc.printer_name
    FROM   printer_configuration pc
END
