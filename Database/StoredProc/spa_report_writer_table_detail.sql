/****** Object:  StoredProcedure [dbo].[spa_report_writer_table_detail]    Script Date: 07/07/2009 18:40:03 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_report_writer_table_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_report_writer_table_detail]
 GO 
--spa_insert_report_writer_table't','test'
CREATE procedure [dbo].[spa_report_writer_table_detail]
@flag varchar(1),
@table_name varchar(250)=null,
@table_alias varchar(250)=null,
@table_desc varchar(500)=null,
@vw_sql varchar(max)=null
As
SET NOCOUNT ON 
set @vw_sql=replace(@vw_sql,'\','')

if @flag='a'
Begin
		select table_name [Table Name],table_alias [Table Alias],table_description [Table Description]
from report_writer_table 
End
if @flag='t' -- Return table info the clm name for Report.Writer Insert mode
begin
select NULL report_name,Null Report_owner,table_name report_tablename,
		NULL report_groupby,
		NULL	report_where ,
		NULL	report_having,
		NULL    report_orderby,
		NULL    report_public,
		NULL	report_internal_description,
		NULL    report_sql_check, 
		table_alias Alias_table,
		vw_sql report_sql_statement
		from 
		report_writer_table where table_name=@table_name
end
else if @flag='r' -- Return all the clm name for 2nd grid Insert mode
begin
	SELECT 
		NUll report_id,
		NULL column_id,
		'false' column_selected,
		column_name,
		column_name columns,
		default_alias column_alias,
		(CASE WHEN where_required='y' THEN 'true' ELSE 'false' END) filter_column,
		NULL max,
		NULL min,
		NULL count,
		NULL sum,
		NULL average,
		UPPER(where_required) where_required,
		NULL report_column_id,
		NULL user_define,
		data_type,
		control_type, 
		data_source, 
		default_value,
		ISNULL(clm_type, 'n') clm_type
	FROM report_where_column_required
	WHERE table_name = @table_name
end
else if @flag='s'
Begin
	select table_name,table_alias,table_description,vw_sql from report_writer_table where table_name=@table_name
End

else if @flag='i'
BEGIN
	IF EXISTS(SELECT 1 FROM report_writer_table WHERE table_name = @table_name)
		EXEC spa_ErrorHandler -1, 'Table Name already exists.', 'spa_report_writer_table_detail',
						 'DB Error', 'Table Name already exists.', ''
	ELSE IF EXISTS(SELECT 1 FROM report_writer_table WHERE table_alias = @table_alias)
		EXEC spa_ErrorHandler -1, 'Table Alias already exists.', 'spa_report_writer_table_detail',
						 'DB Error', 'Table Alias already exists.', ''
	ELSE
	BEGIN
		DECLARE @identity int
		insert into report_writer_table(table_name,table_alias,table_description,vw_sql) 
		values(@table_name,@table_alias,@table_desc,@vw_sql)
		

		SET @identity = SCOPE_IDENTITY()

		insert into [report_writer_view_users] (function_id, role_id, login_id, entity_id, create_user, create_ts) 
		SELECT @identity,NULL,dbo.FNADBUser(),NULL,dbo.FNADBUser(),GETDATE() 
			

		If @@ERROR <> 0
					Exec spa_ErrorHandler @@ERROR, 'Error on Inserting Table Description.', 
							'spa_report_writer_table_detail', 'DB Error', 
						'Error on Inserting Table Description.', ''
				else
					Exec spa_ErrorHandler 0, 'Table Description successfully inserted.', 
							'spa_report_writer_table_detail', 'Success', 
							'Table Description successfully inserted.', ''
	END
End 
 
else if @flag='u'
Begin
	IF EXISTS(SELECT 1 FROM report_writer_table WHERE  table_alias = @table_alias AND table_name <> @table_name)
		EXEC spa_ErrorHandler -1, 'Table Alias already exists.', 'spa_report_writer_table_detail',
						 'DB Error', 'Table Alias already exists.', ''
	ELSE
	BEGIN
		update report_writer_table set table_name=@table_name,table_alias=@table_alias,table_description=@table_desc ,vw_sql=@vw_sql where table_name=@table_name

			If @@ERROR <> 0
					Exec spa_ErrorHandler @@ERROR, 'Error on Updating Table Description.', 
							'spa_insert_report_writer_table', 'DB Error', 
						'Error on Updating Table Description.', ''
				else
					Exec spa_ErrorHandler 0, 'Table Description successfully updated.', 
							'spa_insert_report_writer_table', 'Success', 
							'Table Description successfully updated.', ''
	END
End

ELSE IF @flag='d'
BEGIN
--	delete from report_writer_table where table_name=@table_name
--
--	If @@ERROR <> 0
--				Exec spa_ErrorHandler @@ERROR, "Rec Generator", 
--						"spa_insert_report_writer_table", "DB Error", 
--					"Error on Deleting Table Description.", ''
--			else
--				Exec spa_ErrorHandler 0, 'Rec Generator', 
--						'spa_insert_report_writer_table', 'Success', 
--						'Table Description successfully Deleted.', ''
	IF EXISTS(SELECT 1 FROM report_record WHERE report_tablename = @table_name)
		EXEC spa_ErrorHandler -1, 'Cannot delete the view. It is being used in report(s). You need to delete them first.', 'spa_report_writer_table_detail',
						 'DB Error', 'Cannot delete the view. It is being used in report(s). You need to delete them first.', ''
	ELSE
	BEGIN
		BEGIN TRY 
			BEGIN TRAN
				
			DELETE FROM report_where_column_required WHERE table_name = @table_name
			DELETE FROM report_writer_table WHERE table_name = @table_name

			EXEC spa_ErrorHandler 0, 'Table Description successfully Deleted.', 
							'spa_report_writer_table_detail', 'Success', 
							'Table Description successfully Deleted.', ''

			COMMIT TRAN
		END TRY
		BEGIN CATCH
			DECLARE @error_no int

			IF @@TRANCOUNT > 0
				ROLLBACK TRAN

			SET @error_no = ERROR_NUMBER()
			EXEC spa_ErrorHandler @error_no, 'Error on Deleting Table Description.', 'spa_report_writer_table_detail', 
						'DB Error', 'Error on Deleting Table Description.', ''
		END CATCH
	END
END











