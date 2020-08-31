
-- ============================================================================================================================
-- Author: Manju Singh
-- Create date: 2013-05-10 
-- Description: Deploy Batch Report.
--              
-- Params:
-- @zip_file   output zip file name
-- @file_to_zip file name to zip  

-- TODO : Permission Management
-- Need to grant execute permission OLE objects to db_farrms role.
-- run create_db_farrms_role.sql file to grant permission.

-- Sample Use
-- EXEC spa_compress_file  'H:\ZipTest\csv\test.zip',  'H:\ZipTest\csv\test.csv'

-- ============================================================================================================================


IF OBJECT_ID(N'dbo.[spa_compress_file]', N'P') IS NOT NULL
    DROP PROC dbo.[spa_compress_file]
GO


CREATE PROCEDURE [spa_compress_file] 
                @zip_file   VARCHAR(8000), 
                @file_to_zip VARCHAR(8000) 
AS 
BEGIN  
	DECLARE @status NVARCHAR(max) 
	EXEC spa_compress_file_v2 @file_to_zip, @zip_file, @status OUTPUT
END
GO

