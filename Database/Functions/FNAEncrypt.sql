SET NOCOUNT ON

IF OBJECT_ID(N'[dbo].FNAEncrypt', N'FN') IS NOT NULL 
	DROP FUNCTION [dbo].FNAEncrypt
GO

/**
	Encrypt data with a passphrase

	Parameters
	@str	:	Data to encrypt
*/

CREATE FUNCTION [dbo].[FNAEncrypt]
(
	@str AS NVARCHAR(4000)
)
RETURNS VARBINARY(4000)
AS
	BEGIN
		DECLARE @encript VARBINARY(4000)
		SET @encript = ENCRYPTBYPASSPHRASE('KEY',@str)
	RETURN (@encript)
END




GO
