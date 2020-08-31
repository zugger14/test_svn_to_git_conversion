/****** Object:  StoredProcedure [dbo].[spa_report_writer_table]    Script Date: 07/03/2009 16:43:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_report_writer_table]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_report_writer_table]

/****** Object:  StoredProcedure [dbo].[spa_report_writer_table]    Script Date: 07/03/2009 16:43:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[spa_report_writer_table]
@flag char(1),
@table_name varchar(100)=NULL ,
@role_id INT = NULL,
@user_id VARCHAR(50)=NULL 
AS
SET NOCOUNT ON 
declare @sql varchar(2000),@is_admin BIT

--setting @is_admin	
SELECT @is_admin = dbo.FNAIsUserOnAdminGroup(@user_id, 0)
	
if @flag='s'

	--IF @user_id = 'farrms_admin'
	IF @is_admin = 1
		BEGIN
			set @sql = 'select table_name,table_alias  from (  

			select rt.table_name, rt.table_alias 
			from [report_writer_view_users] rv RIGHT JOIN report_writer_table rt 
			ON   rv.function_id=rt.id AND login_id=dbo.fnadbuser()
			UNION 
			select rt.table_name, rt.table_alias 
			from [report_writer_view_users] rv 
			RIGHT JOIN report_writer_table rt ON   rv.function_id=rt.id 
			INNER JOIN dbo.application_role_user aru ON aru.role_id=rv.role_id and  aru.user_login_id=dbo.fnadbuser()

			) a
			where 1=1 '

			if(@table_name is not null)
				set @sql = @sql + ' AND table_name='''+@table_name+''''
		
		
		END	
	ELSE
		BEGIN
	
			set @sql = 'select table_name,table_alias  from (  

			select rt.table_name, rt.table_alias 
			from [report_writer_view_users] rv INNER JOIN report_writer_table rt 
			ON   rv.function_id=rt.id AND login_id=dbo.fnadbuser()
			UNION 
			select rt.table_name, rt.table_alias 
			from [report_writer_view_users] rv 
			INNER JOIN report_writer_table rt ON   rv.function_id=rt.id 
			INNER JOIN dbo.application_role_user aru ON aru.role_id=rv.role_id and  aru.user_login_id=dbo.fnadbuser()

			) a
			where 1=1 '

			if(@table_name is not null)
				set @sql = @sql + ' AND table_name='''+@table_name+''''
	

end

IF @flag = 'r' 

	SET @sql = 'SELECT id, table_name [Table Name], table_alias [Table Alias] 
            FROM report_writer_table rwt'
            /*
			WHERE NOT EXISTS (SELECT 1 FROM report_writer_view_users rwvu
					WHERE rwvu.function_id = rwt.id AND '
					+ CASE WHEN @user_id IS NOT NULL THEN
						--check for both the user...
						'rwvu.login_id = ''' + @user_id + ''')
			--...and the role the user belongs too
			AND NOT EXISTS (SELECT 1 FROM report_writer_view_users rwvu_role 
					INNER JOIN application_role_user aru ON aru.role_id = rwvu_role.role_id
					WHERE rwvu_role.function_id = rwt.id AND aru.user_login_id = ''' + @user_id + ''')' 
					ELSE 
						--check for the role only
						'rwvu.role_id = ' + CAST(@role_id AS varchar)  + ')' END
			*/
						
						
--PRINT(@sql)

EXEC(@sql)



