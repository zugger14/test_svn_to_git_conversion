IF OBJECT_ID(N'dbo.FNAHyperHTML', N'FN') IS NOT NULL
   DROP FUNCTION [dbo].[FNAHyperHTML]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNAHyperHTML](
	@spa VARCHAR(MAX), 
	@label VARCHAR(1000),
	@spa_html_path VARCHAR(1000) = NULL
)
RETURNS VARCHAR(MAX) AS
BEGIN
	DECLARE @hyper_text VARCHAR(MAX)
	DECLARE @user_login VARCHAR(100),
			@start_index INT

	SET @spa_html_path = ISNULL(@spa_html_path, 'spa_html.php');

	SET @user_login = dbo.FNAdbuser()
	SET @start_index = CHARINDEX('\', @user_login,1)
	SET @user_login = SUBSTRING(@user_login, @start_index + 1, LEN(@user_login) - @start_index + 1)
	SET @user_login = REPLACE(@user_login, ' ', '_')

	SET @hyper_text = '<a target="_blank" href="' + @spa_html_path + '?__user_name__=' + @user_login + '&spa=' + @spa + '"><font color=#0000ff><u>' + @label + '</u></font></a>'
	RETURN @hyper_text
END

