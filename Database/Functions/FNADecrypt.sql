SET NOCOUNT ON

IF OBJECT_ID(N'[dbo].FNADecrypt', N'FN') IS NOT NULL 
	DROP FUNCTION [dbo].FNADecrypt
GO

/**
	Function decrypts encrypted data using passphase.

	Parameters
	@str	:	Varbinary encrypted data
*/

CREATE FUNCTION [dbo].[FNADecrypt]
(
	@str AS VARBINARY(4000)
)
RETURNS NVARCHAR(4000)
AS
BEGIN
	DECLARE @decript VARBINARY(4000)
		SET @decript = DECRYPTBYPASSPHRASE('KEY',@str)
	RETURN (@decript)
END




GO
