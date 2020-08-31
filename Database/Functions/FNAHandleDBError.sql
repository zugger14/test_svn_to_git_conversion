SET NOCOUNT ON

IF OBJECT_ID(N'[dbo].FNAHandleDBError', N'FN') IS NOT NULL 
	DROP FUNCTION [dbo].FNAHandleDBError
GO

/**
	This function will parse sql error message for foreign key constraint / unique key costraint violation to user friendly error messages.

	Parameters
	@application_function_id	:	"This is nullable parameter and added to handle special case for 'Deal'. If no values are given to insert in not nullable column then validation is added by resolving its corresponding default label from maintain field deal table."
*/

CREATE FUNCTION [dbo].[FNAHandleDBError] (
	@application_function_id AS INT = NULL
)
RETURNS NVARCHAR(2048)
AS
BEGIN
	DECLARE @error_id INT = ERROR_NUMBER(),
			@start_index INT,
			@err VARCHAR(1024) = '',
			@err_message VARCHAR(1024),
			@conficted_table VARCHAR(1024) = '',
			@gridLabel VARCHAR(1024) = NULL,
			@form_label VARCHAR(500) = NULL, -- Label taken from application_ui_template
			@col_index INT, -- Index on error message for 'column'
			@col_name VARCHAR(100) = NULL,
			@uf_col_name VARCHAR(100) = NULL, -- User Friendly Column Name
			@func_id INT -- Function ID of taken from table which is present in application_ui_template.
	
	IF @error_id = 547 --	Foreign key error, Parse sql foreign key error message
	BEGIN
	    SET @err = ERROR_MESSAGE()
	    SET @start_index = CHARINDEX('dbo.', @err) + 4
		SET @col_index = CHARINDEX('column ''', @err) + 6 -- Getting Index from where 'column' name is started.
		SET @col_name = RTRIM(LTRIM(REPLACE(REPLACE(SUBSTRING(@err, @col_index, LEN(@err)), '''', ''), '.', ''))) -- Get Column Name specified in Error Message.
	    SET @err_message = 'Data used '
	    SET @err = (SELECT SUBSTRING(@err, @start_index, LEN(@err)))
	    SET @err = SUBSTRING(@err, 0, CHARINDEX('"', @err))

		-- When the table has prefix 'source_deal' then the values in column are present in 'maintain_field_deal' and we can get user-friendly column label.
		IF CHARINDEX('source_deal', @err) > 0 AND NULLIF(@col_name, '') IS NOT NULL
		BEGIN
			SELECT @uf_col_name = default_label
			FROM maintain_field_deal
			WHERE farrms_field_id = @col_name

			SET @err_message = 'Data used ' + ISNULL(('by ' + @uf_col_name), '') + ' in Deal' + CASE WHEN CHARINDEX('source_deal_detail', @err) > 0 THEN ' Detail' WHEN CHARINDEX('source_deal_header', @err) > 0 THEN ' Header' ELSE '' END + '.'
		END
		ELSE
		BEGIN
			-- Take Grid Name from Table Name in Error Message.
			SELECT @gridLabel = grid_label
			FROM adiha_grid_definition
			WHERE grid_name = @err

			-- Take Form Name from Table Name in Error Message.
			SELECT @func_id = application_function_id,
				@form_label = template_description
			FROM application_ui_template
			WHERE table_name = @err
			
			-- Take User-Friendly column name from system column name in Error Message.
			IF NULLIF(@col_name, '') IS NOT NULL
				SELECT @uf_col_name = default_label
				FROM application_ui_template_definition
				WHERE field_id = @col_name
					AND application_function_id = @func_id
		
			--SET @err_message = @err_message + @err
			SET @err_message = @err_message + ISNULL(('by ' + @uf_col_name), '') + ' in ' + dbo.FNACapitalizeFirstLetter(REPLACE(COALESCE(@gridLabel, @form_label, @err), '_', ' ') + '.')
		END

		SET @err = 'Error Occurred.<a href="#" onclick="$(this).next(''div'').toggle();"><br/><font size=1>Technical Details.</font></a>'		
		SET @err += '<div style="font-size:10px;color:red;display:none;" id="target"><b><i>' + @err_message + '</i></b></div>'
	END
	ELSE IF @error_id IN(2627, 2601) --	Unique Constraint / Index violation
	BEGIN	    
	    SET @err = ERROR_MESSAGE()
	    DECLARE @constraint_name VARCHAR(1024),
				@table_name VARCHAR(1024)

	    IF @error_id = 2627	--Unique Constraint --	Find which constraint has been violated
	    BEGIN
			SET @start_index = CHARINDEX('''', @err)	    
			SELECT @constraint_name = LEFT(SUBSTRING(@err, @start_index + 1, LEN(@err)), CHARINDEX('''', SUBSTRING(@err, @start_index + 1, LEN(@err))) - 1)
			
			--	Find which table has been violated
			SET @start_index = CHARINDEX('dbo.', @err) + 4
			SET @table_name = SUBSTRING(@err, @start_index, LEN(@err))
			SET @table_name = SUBSTRING(@table_name, 0, CHARINDEX('''', @table_name))
	    END
	    ELSE IF @error_id = 2601 --	Unique index error message parsing
	    BEGIN
	    	SET @start_index = CHARINDEX('dbo.', @err) + 4
			SET @table_name = SUBSTRING(@err, @start_index, LEN(@err))
			SET @table_name = SUBSTRING(@table_name, 0, CHARINDEX('''', @table_name))
			
			--For constraint name while getting unique index error i
			SET @start_index += LEN(@table_name) + 1
			SET @err = SUBSTRING(@err, @start_index, LEN(@err))
			SET @constraint_name = SUBSTRING(@err, CHARINDEX('''', @err) + 1, LEN(@err))
			SET @constraint_name = LEFT(@constraint_name, CHARINDEX('''', @constraint_name) - 1)
	    END
	    --	Grid/form label
	    DECLARE @label VARCHAR(1024)
	    
		SELECT @label = agd.grid_label
		FROM adiha_grid_definition agd
		WHERE agd.grid_name = @table_name
	    
	    --List of form & grid fields with their table / label
	    DECLARE @form_definitions TABLE (
			field_id VARCHAR(1024),
			default_label VARCHAR(1024),
			form_grid CHAR(1),
			table_name VARCHAR(1024),
			group_name VARCHAR(1024),
			is_hidden CHAR(1),
			is_unique CHAR(1)
		)

		INSERT INTO @form_definitions
		SELECT autd.field_id,
			   autd.default_label,
			   'F' [form_grid],
			   aut.table_name,
			   autg.group_name,
			   autd.is_hidden,
			   autd.is_primary
		FROM application_ui_template_group autg
		INNER JOIN application_ui_template_fields autf ON autg.application_group_id = autf.application_group_id
		INNER JOIN application_ui_template aut ON autg.application_ui_template_id = aut.application_ui_template_id
		INNER JOIN application_ui_template_definition autd ON autf.application_ui_field_id = autd.application_ui_field_id
		WHERE (@application_function_id IS NULL OR aut.application_function_id = @application_function_id)
			   AND autd.field_id <> ''
		UNION ALL
		SELECT DISTINCT 
			   agcd.column_name,
			   agcd.column_label,
			   'G' [form_grid],
			   agd.grid_name,
			   agd.grid_label,
			   agcd.is_hidden,
			   agcd.is_unique
		FROM application_ui_template aut
		LEFT JOIN application_ui_template_definition autd ON autd.application_function_id = aut.application_function_id
		LEFT JOIN application_ui_template_group autg ON aut.application_ui_template_id = autg.application_ui_template_id
		LEFT JOIN application_ui_layout_grid aulg ON autg.application_group_id = aulg.group_id
			AND aulg.grid_id <> 'FORM'
		LEFT JOIN adiha_grid_definition agd ON aulg.grid_id = agd.grid_id
		LEFT JOIN adiha_grid_columns_definition agcd ON agd.grid_id = agcd.grid_id
		WHERE (@application_function_id IS NULL OR aut.application_function_id = @application_function_id)
			AND agd.grid_name IS NOT NULL
			AND agcd.column_name IS NOT NULL
		
		DECLARE @tabs VARCHAR(1024)
			    
		SET @err = (
		    SELECT DISTINCT STUFF(ISNULL(fd.default_label, REPLACE(col.name, '_', ' ')),1,0,', ')
		    FROM sys.indexes ind
			INNER JOIN sys.index_columns ic ON  ind.object_id = ic.object_id
				AND ind.index_id = ic.index_id
			INNER JOIN sys.columns col ON  ic.object_id = col.object_id
				AND ic.column_id = col.column_id
			INNER JOIN sys.tables t ON ind.object_id = t.object_id
			INNER JOIN @form_definitions fd ON col.name = fd.field_id
			WHERE ind.name = @constraint_name
				AND t.name = @table_name
				AND ISNULL(fd.is_hidden, 'n') <> 'y'
				AND fd.default_label IS NOT NULL
			FOR XML PATH('')
		)

	    SET @err = RIGHT(@err, LEN(@err) - 2)
	    -- if list contains comma change to and for last comma
	    SET @err = LEFT(@err, LEN(@err) - CHARINDEX(',', REVERSE(@err))) + REPLACE(REVERSE(LEFT(REVERSE(@err), CHARINDEX(',', REVERSE(@err)))), ',', ' and ')
	    --	Remove bold for comma
	    SET @err = REPLACE(@err, ',', '</b>,<b>')
	    --	Remove bold for and
	    SET @err = REPLACE(@err, ' and ', '</b> and <b>')
		
	    SET @err = CASE WHEN @label IS NOT NULL THEN 'Duplicate data in (<b>' +  @err + '</b>) in <b>' + @label + '</b> grid.'
	                    ELSE 'Duplicate data in (<b>' + @err + '</b>).'
				   END
	END
	ELSE IF @error_id = 515 -- Not Nullable column validation
	BEGIN
		SET @err_message = ERROR_MESSAGE()
		SET @err_message = LEFT(@err_message, CHARINDEX(',', @err_message) - 1)
		
		IF @application_function_id = 10131000 --if it is called from deal
		BEGIN
			DECLARE @column_name VARCHAR(500), @column_label VARCHAR(500)
			SET @column_name = REPLACE(SUBSTRING(@err_message, CHARINDEX('''', @err_message), CHARINDEX('''', @err_message)), '''', '')

			SELECT @column_label = default_label
			FROM maintain_field_deal
			WHERE farrms_field_id =  @column_name 

			IF @column_label IS NOT NULL
				SET @err_message = REPLACE(@err_message, @column_name, @column_label)
		END

		SET @err = 'Error Occurred<a href="#" onclick="$(this).next(''div'').toggle();"><br/><font size=1>Technical Details.</font></a>'		
		SET @err += '<div style="font-size:10px;color:red;display:none;" id="target"><b><i>' + @err_message + '</i></b></div>'
	END
	ELSE
	BEGIN
		SET @err = 'Error Occurred<a href="#" onclick="$(this).next(''div'').toggle();"><br/><font size=1>Technical Details.</font></a>'		
		SET @err += '<div style="font-size:10px;color:red;display:none;" id="target">' + ERROR_MESSAGE() + '</div>'
	END
	
	RETURN @err
END




GO
