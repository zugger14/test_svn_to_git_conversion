/****** Object:  StoredProcedure [dbo].[spa_report_writer_column]    Script Date: 07/24/2009 17:05:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_report_writer_column]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_report_writer_column]
GO

/****** Object:  StoredProcedure [dbo].[spa_report_writer_column]    Script Date: 10/02/2008 12:08:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- NEW CLM
create procedure [dbo].[spa_report_writer_column]
@flag varchar(1),
@report_id int = NULL,
@column_id int = NULL,
@column_name varchar(100) = NULL,
@default_alias varchar(250) = NULL,
@table_name varchar(100) = NULL,
@report_column_id int = NULL,
@data_type varchar(50) = NULL,
@control_type varchar(100) = NULL,
@data_source varchar(5000) = NULL,
@default_value varchar(500) = NULL
AS
SET NOCOUNT ON 

IF @flag='i'
BEGIN
	DECLARE @isSql varchar(5) 
	SELECT @isSql = report_sql_check FROM report_record WHERE report_id = @report_id

	SELECT @column_id = MAX(column_id) FROM report_writer_column WHERE report_id = @report_id
	  
	SET @column_id = ISNULL(@column_id + 1, 0)
	
	BEGIN TRY
		IF @isSql = 'Y'
		BEGIN
			INSERT INTO report_writer_column
			(report_id, column_id, column_selected, column_name, columns, column_alias, filter_column
			, max, min, count, sum, average, user_define, data_type, control_type, data_source, default_value) 
			SELECT @report_id, @column_id, 'false', @column_name, @column_name, @default_alias, 'true'
			, 'false', 'false', 'false', 'false', 'false', 'y', @data_type, @control_type, @data_source, @default_value
		END
		ELSE
		BEGIN
			--copy details from report_where_column_required for inserted column
			INSERT INTO report_writer_column
			(report_id, column_id, column_selected, column_name, columns, column_alias, filter_column
			, max, min, count, sum, average, user_define, data_type, control_type, data_source, default_value) 
			SELECT @report_id, @column_id, 'false', column_name, column_name, @default_alias, 'false'
			, 'false', 'false', 'false', 'false', 'false', 'y', data_type, control_type, data_source, default_value 
			FROM report_where_column_required	
			WHERE table_name = @table_name AND column_name = @column_name
		END
		
		EXEC spa_ErrorHandler 0, 'ReportWriter', 
						'spa_report_writer_column', 'Success', 
						'Table Description successfully inserted.', ''		
	END TRY
	BEGIN CATCH
	
		DECLARE @error_num INT
		SET @error_num = ERROR_NUMBER()
		EXEC spa_ErrorHandler @error_num, "ReportWriter", 
						"spa_report_writer_column", "DB Error", 
					"Error on Inserting Table Description.", ''
	END CATCH

				
END 

ELSE IF @flag='d'
BEGIN
	delete report_writer_column WHERE report_column_id=@report_column_id


	IF @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "ReportWriter", 
						"spa_report_writer_column", "DB Error", 
					"Error on Delete Column.", ''
			ELSE
				Exec spa_ErrorHandler 0, 'ReportWriter', 
						'spa_report_writer_column', 'Success', 
						'Column successfully deleted.', ''


END

ELSE IF @flag='a'
BEGIN
	select column_name [column NAME], column_alias[default alias], 
	control_type, data_source, default_value, data_type
		from report_writer_column 
	where report_column_id = @report_column_id 
END


ELSE IF @flag='u'
BEGIN
	UPDATE report_writer_column 
		SET 
		columns = REPLACE(columns, column_name, @column_name)
		,column_name = @column_name
		,column_alias = @default_alias
		,data_source = @data_source
		,control_type = ISNULL(@control_type,control_type)
		,default_value = ISNULL(@default_value,default_value)
		,data_type = ISNULL(@data_type,data_type)
	where report_column_id = @report_column_id
	
	IF @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "ReportWriter", 
						"spa_report_writer_column", "DB Error", 
					"Error on Update Column.", ''
			ELSE
				Exec spa_ErrorHandler 0, 'ReportWriter', 
						'spa_report_writer_column', 'Success', 
						'Column successfully updated.', ''

END






