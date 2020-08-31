SET NOCOUNT ON

IF OBJECT_ID(N'dbo.FNAGetIXPSourceColumn', N'TF') IS NOT NULL
    DROP FUNCTION dbo.FNAGetIXPSourceColumn
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/**
	Returns source column name as per user's language.

	Parameters
	@ixp_rule_id : Import Export rule id
	@table_name : Import/Export table name
	@language_translate : Set 1 to translate language to user profile language. Default is 0
	@show_mapped_source_columns_only : Set to 1 to return mapped source column only. Default is 0. Return ixp column name if source column is null.
*/

CREATE FUNCTION dbo.FNAGetIXPSourceColumn
(
	@ixp_rule_id INT,
	@table_name NVARCHAR(500),
	@language_translate BIT,
	@show_mapped_source_columns_only BIT
)
RETURNS @items TABLE (
			rule_id				INT,
			ixp_tables_id		INT,
			ixp_columns_id		INT,
			ixp_columns_name	NVARCHAR(50),
			source_column_name	NVARCHAR(50),
			seq					INT,
			is_major			INT
)
AS
BEGIN
	INSERT INTO @items(rule_id				
					   , ixp_tables_id		
					   , ixp_columns_id		
					   , ixp_columns_name	
					   , source_column_name	
					   , seq					
					   , is_major
	)
	SELECT scd.ixp_rules_id				
		   , scd.ixp_tables_id		
		   , scd.ixp_columns_id		
		   , scd.ixp_columns_name	
		   , ISNULL(vlm.translated_keyword, scd.src_col) source_column_name	
		   , scd.seq					
		   , scd.is_major
	FROM (
		SELECT ir.ixp_rules_id,  
			   it.ixp_tables_id,  
			   ic.ixp_columns_id, 
			   ic.ixp_columns_name, 
			   IIF(iidm.source_column_name = '', ic.ixp_columns_name, IIF(CHARINDEX('[', iidm.source_column_name) > 0,SUBSTRING(iidm.source_column_name, CHARINDEX('[', iidm.source_column_name) + 1, CHARINDEX(']', iidm.source_column_name) - CHARINDEX('[', iidm.source_column_name) - 1 ),iidm.source_column_name)) src_col,
			   ic.seq,
			   ic.is_major
		FROM ixp_rules ir
		INNER JOIN ixp_import_data_mapping iidm ON ir.ixp_rules_id = iidm.ixp_rules_id
		INNER JOIN ixp_tables it  ON iidm.dest_table_id = it.ixp_tables_id    
		INNER JOIN ixp_columns ic ON ic.ixp_table_id = it.ixp_tables_id
			AND ic.ixp_columns_id = iidm.dest_column	 
		WHERE 1 = 1
			AND ir.ixp_rules_id = @ixp_rule_id  
			AND it.ixp_tables_name = ISNULL(@table_name, it.ixp_tables_name)
			AND (@show_mapped_source_columns_only = 0 
					OR (@show_mapped_source_columns_only = 1 AND NULLIF(iidm.source_column_name, '') IS NOT NULL)
				)
	) scd
	LEFT JOIN [dbo].[vw_locale_mapping] vlm ON vlm.original_keyword = scd.src_col AND @language_translate = 1
		
	RETURN
END
GO
