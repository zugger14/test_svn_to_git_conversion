IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARFXReplaceOptionalParam]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARFXReplaceOptionalParam]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 --============================================================================================================================
 --Create date: 2012-09-11
 --Description:Replaces the optional parameters and returns the where_part. 
               
 --Params:
 --@paramset_id		INT : parameter set ID
 --@root_dataset_id INT : root_dataset ID
 --============================================================================================================================
CREATE FUNCTION [dbo].[FNARFXReplaceOptionalParam](@paramset_id	INT, @root_dataset_id INT)
RETURNS VARCHAR(8000)
AS
/*-------------------------------------------------Test Script-------------------------------------------------------*/
/*
 DECLARE
 	@paramset_id	INT, @root_dataset_id INT
 	SET @paramset_id = 38319
 	SET @root_dataset_id = 44317
	                     
--*/
/*-------------------------------------------------Test Script END -----------------------------------------------------*/

BEGIN
	/* LOGIC
	* sdh.source_deal_header_id IN (@source_deal_header_id) AND sdd.term_start > ''@term_start'' AND sdp.term_start BETWEEN '@term_start' AND '@term_start2'  AND sdh.source_system_id = @source_system_id
	*
	* In above where_part, there are two optional parameter clause as follows
	* i. sdp.term_start BETWEEN '@term_start' AND '@term_start2' [param_name BETWEEN param_value AND param_value2]
	* ii. sdh.source_system_id = @source_system_id [param_name = param_value]
	* 
	* Both need to be replaces as follows to make them work as optional parameters
	* i. ('@term_start' = 'NULL' OR sdp.term_start BETWEEN  '@term_start' AND '@term_start2')
	* ii. ('@source_system_id' = 'NULL' OR sdh.source_system_id = @source_system_id)
	* 
	* For above string transformation to do, following steps are needed:
	* i.	Find param_name [e.g. sdp.term_start].
	* ii.	Replace it to append paramter nullifying start section [e.g. ('@term_start' = 'NULL' OR sdp.term_start...]
	* iii.	Find param_value used by that param_name [e.g. @term_start). In case of BETWEEN clause, append string 2 in param_value [e.g. @term_start2].
	* iv.	Find location of space or new line after param_value found in previous step. If space is not found, it means param_value resides at the end of the string. 
	*		That's where ending parenthesis [)] of parameter nullifying clause is inserted.
	* 
	* The final where_part becomes
	* sdh.source_deal_header_id IN (@source_deal_header_id) AND sdd.term_start > '@term_start' AND ('@term_start' = 'NULL' OR sdp.term_start BETWEEN  '@term_start' AND '@term_start2')  AND ('@source_system_id' = 'NULL' OR sdh.source_system_id = @source_system_id)  
	*/

	DECLARE @temp_map TABLE 
	(
		alias				VARCHAR(100)	--dataset alias
		, name				VARCHAR(500)	--column name                                                                                     
		, combined_name		VARCHAR(1000)	--name with alias (e.g. sdp.term_start)
		, start_index		INT				--start index of optional parameter clause (for debuggin purpose)
		, param_index		INT				--start index of parameter value in optional parameter clause (for debuggin purpose)
		, end_index			INT				--end index of optional parameter clause
		, operator			INT				--operator of paramset column
		, widget_id			INT				--widget of paramset column
		, datatype_id		INT				--datatype of paramset column
	)
	
	DECLARE @new_where_part VARCHAR(5000)
	
	SET @new_where_part =(SELECT where_part FROM report_dataset_paramset WHERE root_dataset_id = @root_dataset_id AND  paramset_id = @paramset_id )
	
	--can we use group by to avoid possible duplication?
	INSERT INTO @temp_map(alias, name, combined_name, start_index, param_index, end_index, operator, widget_id, datatype_id)
	SELECT 
	rd.alias, dsc.name, (rd.alias + '.' + QUOTENAME(dsc.name)) combined_name, pos_param_name.n AS start_index, pos_param_value_start.n param_index, ISNULL(pos_param_value_end.n, LEN(rdp.where_part) + 1) end_index, rp.operator, dsc.widget_id, dsc.datatype_id
	FROM report_dataset_paramset rdp 
	INNER JOIN report_param rp  ON rp.dataset_paramset_id = rdp.report_dataset_paramset_id
	--INNER JOIN report_paramset rps ON rps.report_paramset_id = rp.dataset_paramset_id
	--INNER JOIN report_page rpage ON rps.page_id = rpage.report_page_id
	INNER JOIN report_dataset rd ON rd.report_dataset_id = rp.dataset_id
	INNER JOIN data_source_column dsc ON dsc.data_source_column_id = rp.column_id 
	INNER JOIN report_param_operator rpo ON rpo.report_param_operator_id = rp.operator
	--find the first occurence of param_name
	INNER JOIN dbo.seq pos_param_name ON pos_param_name.n <= LEN(rdp.where_part)
		AND SUBSTRING(rdp.where_part, pos_param_name.n, LEN(rd.alias + '.' + QUOTENAME(dsc.name))) = rd.alias + '.' + QUOTENAME(dsc.name)
	--find the first occurence of param_value after param_name
	OUTER APPLY (
		SELECT TOP 1 n
		FROM dbo.seq
		WHERE n <= LEN(rdp.where_part)
			-- if operator is BETWEEN, pick up second param_value, which starts with 2_ (two characters)
			--1 is added in every case to compensate for @ in the start of the parameter name
			AND SUBSTRING(rdp.where_part, n, LEN(dsc.name) + (CASE WHEN rpo.report_param_operator_id = 8 THEN 3 ELSE 1 END)) 
				 = '@' + (CASE WHEN rpo.report_param_operator_id = 8 THEN ('2_' + dsc.name ) ELSE dsc.name  END) 
			AND n > pos_param_name.n	--index must be greater than start_index
		ORDER BY n
	) pos_param_value_start
	--find the first occurence of space or newline after param_value
	OUTER APPLY (
		SELECT TOP 1 n
		FROM dbo.seq 
		WHERE n <= LEN(rdp.where_part)
			AND SUBSTRING(rdp.where_part, n, 1) IN (' ', CHAR(9), CHAR(10), CHAR(13))
			AND n > pos_param_value_start.n	--index must be greater than param_index
		ORDER BY n 
	) pos_param_value_end	
	WHERE  rdp.root_dataset_id = @root_dataset_id
		AND rdp.paramset_id = @paramset_id 
		AND rp.optional = 1
		AND rpo.report_param_operator_id NOT IN (6, 7)
		
	--SELECT * FROM @temp_map

	--Append ending parenthesis [)] of parameter nullifying clause
	--ORDER BY clause is very important here as appending ) from right preserves index of previous matches from left
	SELECT @new_where_part = STUFF(@new_where_part + ' ', map.end_index, 0, ')')--, map.*
	FROM @temp_map map
	ORDER BY map.end_index DESC

	--Replace param_name to append paramter nullifying start section [('@term_start' = 'NULL' OR sdp.term_start...]
	SELECT @new_where_part = REPLACE(@new_where_part, map.combined_name, '(' + iif(map.operator in (9,10) and map.widget_id = 1 and map.datatype_id IN (1,5), '''NULL'' IN (@' + map.name + ')', QUOTENAME('@' + map.name, '''') + ' = ''NULL''') + ' OR ' + map.combined_name)
	FROM @temp_map map

	RETURN @new_where_part
	--PRINT @new_where_part
END
GO
