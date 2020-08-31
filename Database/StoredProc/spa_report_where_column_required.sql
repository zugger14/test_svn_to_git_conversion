IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_report_where_column_required]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_report_where_column_required]
GO
/****** Object:  StoredProcedure [dbo].[spa_report_where_column_required]    Script Date: 05/25/2009 14:31:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT * FROM  report_where_column_required WHERE table_name='anoop2'
CREATE proc [dbo].[spa_report_where_column_required]
@flag varchar(1),
@table_name varchar(50)=null,
@column_name varchar(250)=null,
@default_alias varchar(250)=null,
@where_required varchar(250)=null,
@data_type varchar(50)=null,
@clm_type char(1)=NULL,
@control_type varchar(100) = NULL,
@data_source varchar(5000) = NULL,
@default_value varchar(500) = NULL

AS
SET NOCOUNT ON 
if @flag='a'
Begin
	select table_name [TableName],column_name [ColumnName],default_alias [defaultAlias],
	where_required [whereRequired],data_type [dataType],clm_type, control_type [ControlType], data_source [DataSource], default_value [DefaultValue]
	from report_where_column_required where table_name=@table_name and column_name=@column_name
End

else if @flag='s'
Begin
	select table_name [Table Name],column_name [Column Name],default_alias [Default Alias],
	where_required [Where Required],data_type [Data Type],column_name +'('+ data_type +')' [Column Detail]
	, control_type [Control Type], data_source [Data Source], default_value [Default Value]
	from report_where_column_required where table_name=@table_name
End

else if @flag='i'
Begin
	IF EXISTS(SELECT 1 FROM report_where_column_required WHERE column_name = @column_name AND table_name = @table_name)
		EXEC spa_ErrorHandler -1, 'Column Name already exists.', 'spa_report_where_column_required',
							 'DB Error', 'Column Name already exists.', ''
	ELSE IF EXISTS(SELECT 1 FROM report_where_column_required WHERE default_alias = @default_alias AND table_name = @table_name)
		EXEC spa_ErrorHandler -1, 'Default Alias already exists.', 'spa_report_where_column_required',
							 'DB Error', 'Default Alias already exists.', ''
	ELSE
	BEGIN
		INSERT INTO report_where_column_required(table_name, column_name, default_alias, where_required
			, data_type,clm_type, control_type, data_source, default_value)
		VALUES(@table_name, @column_name, @default_alias, (CASE @clm_type WHEN 'Y' THEN 'y' ELSE @where_required END)
			, @data_type,@clm_type, @control_type, @data_source, @default_value)

		INSERT [report_writer_column](
			[report_id], [column_id], [column_selected], [column_name]
			, [columns], [column_alias], [filter_column]
			, [max], [min], [count], [sum], [average]
			, data_type, control_type, data_source, default_value
		)
		SELECT report_id,(SELECT MAX(column_id) + 1 FROM report_writer_column
							WHERE [report_id]=r.report_id) column_id, 'false', @column_name
		, @column_name, @default_alias, 'false'
		, 'false','false','false','false','false'
		, @data_type, @control_type, @data_source, @default_value
		FROM Report_record r 
		WHERE report_tablename = @table_name

		If @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR, 'Error on Inserting Report.', 
						'spa_report_where_column_required', 'DB Error', 
					'Error on Inserting Report.', ''
		ELSE
			EXEC spa_ErrorHandler 0, 'Report successfully inserted.', 
						'spa_report_where_column_required', 'Success', 
						'Report successfully inserted.', ''
	END
End

else if @flag='u'
Begin
	IF EXISTS(SELECT 1 FROM report_where_column_required WHERE default_alias = @default_alias AND table_name = @table_name AND column_name <> @column_name)
	EXEC spa_ErrorHandler -1, 'Default Alias already exists.', 'spa_report_where_column_required',
						 'DB Error', 'Default Alias already exists.', ''
	ELSE
	BEGIN
		Update report_where_column_required set  
				default_alias=@default_alias,
				where_required=(CASE @clm_type WHEN 'Y' THEN 'y' ELSE @where_required END),
				data_type=@data_type,
				clm_type=@clm_type,
				control_type = @control_type,
				data_source = @data_source,
				default_value = @default_value
		 where table_name=@table_name and column_name=@column_name
	     
			If @@ERROR <> 0
					Exec spa_ErrorHandler @@ERROR, "Rec Generator", 
							"spa_report_where_column_required", "DB Error", 
						"Error on Updating Report.", ''
				else
					Exec spa_ErrorHandler 0, 'Report successfully Updated.', 
							'spa_report_where_column_required', 'Success', 
							'Report successfully Updated.', ''
	END
End
else if @flag='d'
Begin
   Delete from report_where_column_required where table_name=@table_name and column_name=@column_name

			If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "Rec Generator", 
						"spa_report_where_column_required", "DB Error", 
					"Error on Deleting Report.", ''
			else
				Exec spa_ErrorHandler 0, 'Rec Generator', 
						'spa_report_where_column_required', 'Success', 
						'Report successfully Deleted.', ''
End





GO
