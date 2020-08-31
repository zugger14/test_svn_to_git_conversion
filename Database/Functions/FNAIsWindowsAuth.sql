IF OBJECT_ID(N'FNAIsWindowsAuth', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAIsWindowsAuth]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
--Description: Checks if user login is Windows Authentication or not.
--Returns 0(SQL Authentication) 1(Windows Authentication)
-- ===========================================================================================================


CREATE FUNCTION [dbo].[FNAIsWindowsAuth]()
RETURNS BIT
AS
BEGIN
	RETURN (
		SELECT CASE WHEN ISNULL(nt_user_name, '') <> '' THEN 1 ELSE 0 END
		FROM sys.dm_exec_sessions 
		WHERE session_id = @@SPID
	)
END
