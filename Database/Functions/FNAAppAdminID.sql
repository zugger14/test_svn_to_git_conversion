IF OBJECT_ID(N'FNAAppAdminID', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAAppAdminID]
 GO 


CREATE FUNCTION [dbo].[FNAAppAdminID] ()
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @FNAAppAdminID VARCHAR(50)
	
	--IF [dbo].FNAIsWindowsAuth() = 1
	IF EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 4200 AND code <> '')
	BEGIN
		SELECT @FNAAppAdminID = code FROM static_data_value WHERE value_id = 4200
	END
	ELSE
	BEGIN
		SET @FNAAppAdminID = 'farrms_admin'
	END
	RETURN(@FNAAppAdminID)
END





