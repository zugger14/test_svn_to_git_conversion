IF OBJECT_ID(N'[dbo].[spa_get_report_url]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_get_report_url]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2013-01-31
-- Description: Retrive report URL from email_notes
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- @process_id VARCHAR(200) - process id
-- @notes_id INT - notes id
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_get_report_url]
    @flag CHAR(1),
    @process_id VARCHAR(200)
AS
SET NOCOUNT ON 

IF @flag = 's'
BEGIN
    SELECT TOP(1) en.notes_description [report_url]
    FROM   email_notes en
    WHERE  en.process_id = @process_id AND en.notes_description IS NOT NULL
END