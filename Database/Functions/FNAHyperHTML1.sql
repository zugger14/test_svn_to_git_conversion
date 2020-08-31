
IF OBJECT_ID('[FNAHyperHTML1]') IS NOT NULL
	DROP FUNCTION [dbo].FNAHyperHTML1
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE  FUNCTION [dbo].[FNAHyperHTML1](@spa varchar(5000),@label VARCHAR(200))
RETURNS VARCHAR(5000) as
BEGIN
DECLARE @hyper_text varchar(5000)
DECLARE @user_login varchar(100),@start_index int
	SET @user_login=dbo.FNAdbuser()
	SET @start_index=CHARINDEX('\', @user_login,1)
	SET @user_login=substring(@user_login,@start_index+1,len(@user_login)-@start_index+1)
	SET @user_login=replace(@user_login, ' ', '_')

SET @hyper_text='<span onClick="javascript:open_report_in_viewport('''+ REPLACE(@spa, '''', '^') + ''')"><font color=#0000ff><u>'+ @label +'</u></font></span>'
RETURN @hyper_text
END


/************************************* Object: 'FNAHyperHTML' END *************************************/
