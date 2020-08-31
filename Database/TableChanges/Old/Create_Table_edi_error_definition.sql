IF OBJECT_ID(N'[dbo].[EDI_Error_definition]', N'U') IS NULL
BEGIN
	CREATE TABLE dbo.EDI_Error_definition (
	err_code VARCHAR(50),
	err_Description VARCHAR(500)
	)
END
ELSE 
	PRINT 'Table Present'


/*
BULK
INSERT EDI_Error_definition
FROM 'E:\d\error_code2.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO
*/