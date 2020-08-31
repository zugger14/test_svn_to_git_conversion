IF OBJECT_ID(N'FNADecrypt', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNADecrypt]
GO 

/*
=======================================================================================
Execute below EXEC statement to list parameters with detail. If description column is blank for any parameter then goto to end of this script and add description for missing parameter.
----------------------------------------------
Possible values for @object_type: 'PROCEDURE','FUNCTION','TABLE','VIEW'
EXEC [spa_object_documentation] @flag = 'a', @object_type = 'FUNCTION', @object_name = 'FNADecrypt'

======================================================================================
*/

CREATE FUNCTION [dbo].[FNADecrypt]
(
	@str AS VARBINARY(1000)
)
RETURNS NVARCHAR(1000)
AS
BEGIN
	DECLARE @decript VARBINARY(1000)
		SET @decript = DECRYPTBYPASSPHRASE('KEY',@str)
	RETURN (@decript)
END
GO 

/* Add or update extended property value of SP and its parameters. To add extended property value for SP put 'name' blank */
IF  EXISTS (SELECT 1 FROM sys.objects WHERE name = 'spa_object_documentation' AND TYPE IN (N'P', N'PC'))
BEGIN
	EXECUTE [spa_object_documentation] @json_string = 
				N'
				{ 
					"object_type" : "FUNCTION","object_name":"FNADecrypt",
					"parameter": [ 
									{"name":"","desc":"Function decrypts encrypted data using passphase."},
									{"name":"@str","desc":"Varbinary encrypted data"}
								]
				}'
END