/************************************************************
 * Code formatted by SoftTree SQL Assistant © v4.6.12
 * Time: 12/24/2012 3:15:58 PM
 ************************************************************/

IF OBJECT_ID(N'FNAEncrypt', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAEncrypt]
GO 

/*
=======================================================================================
Execute below EXEC statement to list parameters with detail. If description column is blank for any parameter then goto to end of this script and add description for missing parameter.
----------------------------------------------
Possible values for @object_type: 'PROCEDURE','FUNCTION','TABLE','VIEW'
EXEC [spa_object_documentation] @flag = 'a', @object_type = 'FUNCTION', @object_name = 'FNAEncrypt'

======================================================================================
*/


CREATE FUNCTION [dbo].[FNAEncrypt]
(
	@str AS NVARCHAR(1000)
)
RETURNS VARBINARY(1000)
AS
	BEGIN
		DECLARE @encript VARBINARY(1000)
		SET @encript = ENCRYPTBYPASSPHRASE('KEY',@str)
	RETURN (@encript)
END
GO 

/* Add or update extended property value of SP and its parameters. To add extended property value for SP put 'name' blank */
IF  EXISTS (SELECT 1 FROM sys.objects WHERE name = 'spa_object_documentation' AND TYPE IN (N'P', N'PC'))
BEGIN
	EXECUTE [spa_object_documentation] @json_string =
					N'
					{
						"object_type":"FUNCTION","object_name":"FNAEncrypt",
						"parameter": [ 
										{"name":"","desc":"Encrypt data with a  passphrase"},
										{"name":"@str","desc":"Data to encrypt"}
							]
						}'
END