IF OBJECT_ID(N'[dbo].[FNARowSet]', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[FNARowSet]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARowSet] (@sql AS Varchar(8000))  
RETURNS varchar(8000) AS  
BEGIN 
	DECLARE  @return varchar(8000), @userid varchar(150), @pwd varchar(150), @server varchar(150), @provider varchar(150)
	SET @return = ''
	SELECT @provider = provider_type, @server = server_name, @userid = [user_name], @pwd = user_pwd FROM rdb_config
	SET @return = ' OPENROWSET (''' + @provider + ''', ''' + @server + ''';''' + @userid + ''';''' + @pwd + ''',''' + @sql + ''')'
	RETURN (@return)
END
GO