/*
Added script to create security policy here instead of TableChnages along with the table valued function for the following reason:

1. Hudson/Patch Executor applies TableChanges before functions, which doesn't work for this case 
	as FNAValidateConnectionStringRLS is required first before creating security policy.
2. Function drop statement won't work as it is used in the security policy.
*/

SET NOCOUNT ON

DROP SECURITY POLICY IF EXISTS [dbo].SecurityPolicyRLSConnectionString
GO

DROP FUNCTION IF EXISTS [dbo].FNAValidateConnectionStringRLS;
GO

/**
	Function to return 1 or null which is used as filter predicate function by security policy SecurityPolicyRLSConnectionString.
	If db user if matched with connection string user, return true. If user not matched with connection string user like dev_admin,farrms_admin,etc return true for only default = 1 row of connection string.

	Parameters
	@db_user_name	:	database user name.
	@is_default		:	is default value for row.
*/

CREATE FUNCTION [dbo].FNAValidateConnectionStringRLS(@db_user_name AS SYSNAME, @is_default INT)  
    RETURNS TABLE
WITH SCHEMABINDING  
AS 
RETURN
(
	SELECT 1 AS FNAValidateConnectionStringRLS_result
	WHERE @db_user_name = SYSTEM_USER --user matched case
		OR (NOT EXISTS(SELECT TOP 1 1 FROM dbo.connection_string WHERE db_UserName = SYSTEM_USER) AND @is_default = 1) --user not matched (not available in table), true only for is_default=1
		OR ISNULL(@db_user_name, '') = '' --if single row case for backward compatibility where db_UserName is blank, return true
)

GO

/**
	Security policy to implement Row Level Security on connection_string table. Used UDF 'FNAValidateConnectionStringRLS' as a filter predicate which will return 1 0r 0 as a validtion flag for each row.
*/
CREATE SECURITY POLICY [dbo].SecurityPolicyRLSConnectionString
ADD FILTER PREDICATE [dbo].FNAValidateConnectionStringRLS(db_UserName,is_default)
ON dbo.connection_string
WITH (STATE = ON);

GO