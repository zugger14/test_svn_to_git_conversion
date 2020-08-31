IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_formula_editor_paging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_formula_editor_paging]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_formula_editor_paging]
	@flag CHAR(1),
	@formula_id INT = NULL,
	@formula AS VARCHAR(8000) = NULL,
	@formula_type AS CHAR(1) = 'd',
	@formula_name VARCHAR(200) = NULL,
	@system_defined CHAR(1) = NULL,
	@static_value_id INT = NULL,
	@template CHAR(1) = NULL,
	@formula_xmlValue VARCHAR(MAX) = NULL,
	@formula_group_id INT = NULL,
	@sequence_number INT = NULL,
	@formula_nested_id INT = NULL,
	@formula_source_type CHAR(1) = NULL,
	@udf_query VARCHAR(8000) = NULL,
	@process_id_paging VARCHAR(50) = NULL,
	@page_size INT = NULL ,
	@page_no INT = NULL
AS
DECLARE @user_login_id  VARCHAR(50)
	SET @user_login_id = dbo.FNADBUser()
DECLARE @tempTable VARCHAR(MAX)
DECLARE @sql VARCHAR(MAX) 
DECLARE @flag_paging    CHAR(1)

	

IF @process_id_paging IS NULL
BEGIN
    SET @flag_paging = 'i'
    SET @process_id_paging = REPLACE(NEWID(), '-', '_')
END

SET @tempTable = dbo.FNAProcessTableName(
        'paging_formula',
        @user_login_id,
        @process_id_paging
)
EXEC spa_print @tempTable
IF @flag_paging = 'i'
BEGIN
    IF @flag = 's'
    BEGIN
        SET @sql = 'CREATE TABLE ' + @tempTable + 
            ' (
			sno INT IDENTITY(1,1), 
			Formula_id int,
			Formula_name varchar (200),
			Formula varchar(8000),
			Formula_c varchar(8000),
			Formula_type char(1)
			)'
		EXEC spa_print @sql 
        EXEC (@sql)
		SET @sql = 'INSERT ' + @tempTable + 
            '(formula_id, formula_name, formula, formula_c,Formula_type )'
            +
            ' EXEC spa_formula_editor ' +
				dbo.FNASingleQuote(@flag) + ',' +
				dbo.FNASingleQuote(@formula_id) + ',' +
				dbo.FNASingleQuote(@formula) + ',' +
				dbo.FNASingleQuote(@formula_type) + ',' +
				dbo.FNASingleQuote(@formula_name) + ',' +
				dbo.FNASingleQuote(@template)
				
        EXEC spa_print @sql 
        EXEC (@sql)
		SET @sql = 'select count(*) TotalRow,''' + @process_id_paging + ''' process_id  from ' + @tempTable
        EXEC spa_print @sql
        EXEC (@sql)
    END
END
ELSE
BEGIN
DECLARE @row_from INT, @row_to INT 
	SET @row_to = @page_no * @page_size 
	IF @page_no > 1 
		SET @row_from = ((@page_no-1) * @page_size) + 1
	ELSE 
		SET @row_from = @page_no
	IF @flag='s'
	BEGIN
		EXEC spa_print 'a'
		SET @sql = 
				'SELECT 
					Formula_id [Formula ID],
					Formula_name [Formula Name],
					Formula,
					Formula_c,
					Formula_type 
				  FROM ' + @tempTable
				+ ' WHERE sno BETWEEN ' + CAST(@row_from AS VARCHAR) + ' AND ' + 
				CAST(@row_to AS VARCHAR) + ' ORDER BY sno ASC'
		EXEC spa_print @sql
		exec(@sql)

	END
END