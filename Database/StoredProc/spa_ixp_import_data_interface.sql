IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ixp_import_data_interface]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ixp_import_data_interface]
GO
SET ANSI_NULLS ON
GO
  
SET QUOTED_IDENTIFIER ON
GO
  
-- ===============================================================================================================
-- Author: pamatya@pioneersolutionsglobal.com
-- Create date: 2018-10-25
-- Description: Calls ICE Interface CLR to import Deal and Security definition
-- Params:
-- @import_type CHAR(1)         - 1>Deal, 2>Security Definition
-- @as_of_date DATETIME			- Date
-- EXEC spa_ixp_import_data_interface 'g', '2017-01-01'
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_ixp_import_data_interface]
	@flag CHAR(1) = 'g', -- 'g'-> Show in grid, 'i'-> import
	@import_type CHAR(1) = '1',
	@as_of_date DATETIME = NULL,
	@xml TEXT = NULL,
	@import_rule_id INT = NULL,
	@date_from DATETIME = NULL,
	@date_to DATETIME = NULL,
	@import_status INT= NULL,
	@import_data_list VARCHAR(500) = NULL,
	@run_table VARCHAR(500) = NULL,
	@process_id VARCHAR(500) = NULL,
	@staging_deal_id VARCHAR(500) = NULL,
	@batch_process_id VARCHAR(250) ='assdasdasd123123123123qwd_afsasdasdasd',
	@batch_report_param VARCHAR(500) = NULL
AS
/*
DECLARE 
	@flag CHAR(1) = 'g', -- 'g'-> Show in grid, 'i'-> import
	@import_type CHAR(1) = '1',
	@as_of_date DATETIME = NULL,
--	@xml TEXT = NULL,
	@import_rule_id INT = NULL,
	@date_from DATETIME = NULL,
	@date_to DATETIME = NULL,
	@security_def_id VARCHAR(100)= NULL,
	@import_status INT= NULL,
	@import_data_list VARCHAR(500) = NULL,
	@staging_deal_id VARCHAR(500) = NULL,
	@run_table VARCHAR(500) = NULL,
		@process_id VARCHAR(500) = NULL,
	@batch_process_id VARCHAR(250) ='assdasdasd123123123123qwd_afsasdasdasd',
	@batch_report_param VARCHAR(500) = NULL
	SELECT @flag = 'g'--,@import_rule_id= '12782'--,@import_data_list='5405,5406,5407,5408,5409,5410,5411,5412,5413,5414'

--*/
SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX)
DECLARE @table_name VARCHAR(500)
DECLARE @where_condition VARCHAR(MAX)
DECLARE @total_columns INT
DECLARE @alias VARCHAR(100), @new_process_id  VARCHAR(500)
if NULLIF(@process_id,'') IS NULL 
	SELECT @process_id =  newID()

DECLARE @desc VARCHAR(500)
	DECLARE @job_name VARCHAR(250)
	DECLARE @user_id VARCHAR(100)
	DECLARE @url VARCHAR(8000)
	DECLARE @start_time DATETIME,@end_time  DATETIME

		SET @user_id = dbo.FNADBUser()
IF @flag = 'g'
BEGIN
IF OBJECT_ID('tempdb..#ixp_column_list') IS NOT NULL
	DROP TABLE #ixp_column_list
 IF OBJECT_ID('tempdb..#column_list1') IS NOT NULL
	DROP TABLE #column_list1
 IF OBJECT_ID('tempdb..#rules_id') IS NOT NULL
	DROP TABLE #rules_id
IF OBJECT_ID('tempdb..#max_date') IS NOT NULL
	DROP TABLE #max_date
		
DECLARE @rule_id_list VARCHAR(MAX)

IF OBJECT_ID('tempdb..#rules_list') IS NOT NULL
	DROP TABLE #rules_list

SELECT distinct ixp_rule_id INTO #rules_list  FROM ixp_import_data_interface_staging where ISNULL(import_status,'') = '' 



SELECT TOP 1  @rule_id_list =  STUFF((
            SELECT ',' + CAST(ixp_rule_id as VARCHAR(MAX))
            FROM #rules_list
            FOR XML PATH('')
            ), 1, 1, '')
FROM #rules_list

	 SELECT 'ID'+ STUFF((
					SELECT ',' + ic.ixp_columns_name
					FROM ixp_rules r
					INNER JOIN ixp_import_data_mapping iidm ON iidm.ixp_rules_id = r.ixp_rules_id
					INNER JOIN ixp_columns ic ON ic.ixp_columns_id = iidm.dest_column
					WHERE r.ixp_rules_id = ir.ixp_rules_id
					ORDER BY r.ixp_rules_id,seq
					FOR XML PATH('')
					), 1, 0, '') column_name
			,ixp_rules_id
			INTO #column_list1
		FROM ixp_rules ir
		
		CREATE TABLE #rules_id(ixp_rules_id INT)
SELECT @sql = ' INSERT INTO #rules_id SELECT ixp_rules_id  FROM ixp_rules ' + CASE WHEN NULLIF(@import_rule_id,'') IS NULL THEN '' ELSE 'WHERE ixp_rules_id = '+CAST(@import_rule_id as VARCHAR) END
	
	EXEC(@sql)


	CREATE TABLE #max_date(max_date DATETIME,min_date DATETIME,ixp_rule_id INT)
SELECT @sql = 'INSERT INTO #max_date(max_date,min_date,ixp_rule_id)
	SELECT max(create_ts),min(create_ts),ixp_rule_id FROM ixp_import_data_interface_staging ' + CASE WHEN NULLIF(@import_rule_id,'') IS NULL THEN '' ELSE 'WHERE ixp_rule_id = '+CAST(@import_rule_id as VARCHAR) END +' 
	group by ixp_rule_id '
EXEC(@sql)

SET @sql ='SELECT sdv.code [category]
		,ir.ixp_rules_name [date_type]
		,ir.ixp_rules_id [ice_interface_data_id]
		,CASE WHEN ir.import_export_flag = ''i'' THEN ''Import'' ELSE ''Export'' END [rule_type]
		,ir.ixp_rules_id [import_rule_id]
		,cl.column_name  + '',create_user,create_ts''  column_name
		,CASE WHEN NULLIF(iid.import_rule_id,'''') IS NULL THEN ''false'' ELSE ''true'' END display_config
		,CAST(max_date as DATE)max_date
		,CAST(min_date as DATE) min_date
	FROM ixp_rules ir
	INNER JOIN #rules_id r ON r.ixp_rules_id = ir.ixp_rules_id
	INNER JOIN #max_date md ON md.ixp_rule_id = r.ixp_rules_id
	INNER JOIN #column_list1 cl ON cl.ixp_rules_id = ir.ixp_rules_id
	INNER JOIN static_data_value sdv ON sdv.value_id =ir.ixp_category
	LEFT JOIN ice_interface_data iid on iid.import_rule_id =  ir.ixp_rules_id
	WHERE 1 =1 AND NULLIF(cl.column_name,'''') IS NOT NULL
	' + CASE WHEN @rule_id_list IS NOT NULL THEN ' AND ir.ixp_rules_id IN ('+@rule_id_list+') ' ELSE '' END
	
EXEC(@sql)

	


	
END
IF @flag = 's' -- Select list of data to display in grid
BEGIN
 DECLARE @i INT
 SET @i =1;
	SELECT  ic.ixp_columns_name,r.ixp_rules_id
		INTO #column_list
			FROM ixp_rules r
			INNER JOIN ixp_import_data_mapping iidm ON iidm.ixp_rules_id = r.ixp_rules_id
			INNER JOIN ixp_columns ic ON ic.ixp_columns_id = iidm.dest_column
			WHERE r.ixp_rules_id =@import_rule_id
			ORDER BY r.ixp_rules_id
	SELECT @total_columns =count(1) FROM #column_list 
	SET @table_name = 'ixp_import_data_interface_staging'
	SET @sql = ' SELECT ID'

	WHILE @i<=@total_columns
	BEGIN
		SET @sql = @sql + ',column_'+CAST(@i as varchar)+' '
		SET @i = @i+1;
	END
	SELECT @sql = @sql + ',create_user, dbo.FNADateTimeFormat(create_ts,1) FROM '+@table_name
	SET @where_condition = ' WHERE ixp_rule_id = '''+CAST(@import_rule_id as VARCHAR)+''''
	SET @where_condition = @where_condition + ' AND create_ts BETWEEN ''' + CONVERT(VARCHAR,@date_from,120) +''' and '''+ REPLACE(CONVERT(VARCHAR,@date_to,120),'00:00:00','23:59:59')+''''
	SET @where_condition = @where_condition + ' AND ISNULL(import_status,'''') =' + ''''+ CASE WHEN @import_status = '1' THEN 's' ELSE '' END + ''''
	SET @where_condition = ISNULL(@where_condition,'')
	EXEC(@sql+@where_condition + ' order by create_ts desc')
	 
END
IF @flag = 'i'
BEGIN 

SELECT @start_time = GETDATE()
SELECT @alias = data_source_alias  FROM ixp_import_data_source where rules_id =@import_rule_id
SELECT @new_process_id= dbo.FNAGetNewID()
			IF OBJECT_ID('tempdb..#number_of_columns') IS NOT NULL
				DROP TABLE #number_of_columns 

						SELECT source_column_name
							,dest_table_id
							,dest_column
							,ixp_rules_id
							,seq
							,is_major
							,c.ixp_columns_name
							,'column_'+CAST(row_number() OVER(Order by seq) as VARCHAR) staging_table_column_name
							,COALESCE(c.datatype,c.column_datatype) datatype 
						INTO #number_of_columns
						FROM ixp_import_data_mapping iidm 
						INNER JOIN ixp_columns c on iidm.dest_column = c.ixp_columns_id
						WHERE ixp_rules_id = @import_rule_id  AND NULLIF(iidm.source_column_name,'') is not null
						ORDER BY seq
					
							DECLARE @temp_process_table VARCHAR(500) 
							DECLARE @insert_query VARCHAR(MAX)
							DECLARE @select_query VARCHAR(MAX)
							DECLARE @col_staging_table VARCHAR(MAX)
							DECLARE @col_raw_data VARCHAR(MAX) 
							DECLARE @staging_col VARCHAR(MAX)
							DECLARE @column_data VARCHAR(MAX) = '';
							DECLARE @loopCount INT
							SELECT @temp_process_table = 'adiha_process.dbo.temp_import_data_table_'+@alias+'_'+@new_process_id 
							--adiha_process.dbo.temp_import_data_table_d_2D179B43_19DB_4BEF_B068_2F18A1309B05
							SET @col_staging_table =''
							SET @col_raw_data =''
							SET @staging_col = ''
							SET @column_data =''
							SET @insert_query = ' '
							SET @select_query = ' SELECT ' 
							
							DECLARE create_column_list CURSOR FOR     
							SELECT source_column_name,staging_table_column_name FROM #number_of_columns where NULLIF(source_column_name,'') IS NOT NULL	ORDER BY seq
   

							OPEN create_column_list    
  
							FETCH NEXT FROM create_column_list     
							INTO @col_raw_data,@col_staging_table
  
							WHILE @@FETCH_STATUS = 0    
							BEGIN    
								if(@column_data!='')
									SET @column_data =@column_data +','
								
								SET @column_data = @column_data+ @col_staging_table  + ' AS ' +  SUBSTRING(@col_raw_data,LEN(@alias)+2,LEN(@col_raw_data))

								FETCH NEXT FROM create_column_list     
							INTO @col_raw_data,@col_staging_table
   
							END     
							CLOSE create_column_list;    
							DEALLOCATE create_column_list;    
						
					SET @insert_query =  @select_query +@column_data + ' INTO ' + @temp_process_table +' FROM ixp_import_data_interface_staging i WHERE i.ixp_rule_id = '+CAST(@import_rule_id AS VARCHAR) + ' AND i.ID IN (' +CAST(@import_data_list AS VARCHAR(max))+')'
						
							EXEC(@insert_query)
				--same set of record is reinserted in staging table so previous data is deleted.
				SET @sql = 'DELETE FROM ixp_import_data_interface_staging  WHERE ixp_rule_id = '+CAST(@import_rule_id AS VARCHAR) + ' AND ID IN (' +CAST(@import_data_list AS VARCHAR(max))+')'
				EXEC(@sql)

				EXEC spa_ixp_rules  @flag='t', @process_id=@new_process_id, @ixp_rules_id=@import_rule_id, @run_table=@temp_process_table, @source = '21405', @run_with_custom_enable = 'n', @server_path=''
						
		/*	INSERT INTO source_system_data_import_status(Process_id, code, module, source, type, description, recommendation, create_ts, create_user, rules_name,master_process_id) 
 			SELECT @new_process_id,
 					'Success',
 					ixp_rules_name ,
					'Reimport From staging table',
 					'Success',
 					ISNULL(@desc,'Import started Successfully.'),
 					'',
					GETDATE(),
					dbo.FNAdbuser()
					,'Data reimported from Import data Staging'
					,@batch_process_id
					FROM ixp_rules WHERE ixp_rules_id = @import_rule_id
 		SET @job_name = 'Re-import_from_staging_table' + @new_process_id
					
 		SELECT @desc =  'Import data Staging - ' +  ISNULL(ixp_rules_name,'') + ' has been imported successfully.' FROM ixp_rules WHERE ixp_rules_id = @import_rule_id
 				
					
					
		INSERT INTO source_system_data_import_status_detail (process_id, [source], [type], [description])
		SELECT @batch_process_id, 'Import data Staging', 'Success', ISNULL(@desc,'Success')

		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_id + '&spa=exec spa_get_import_process_status ''' + @batch_process_id + ''','''+@user_id+''''
 		SELECT @end_time = GETDATE()
		SELECT @desc = '<a target="_blank" href="' + @url + '"><ul style="padding:0px;margin:0px;list-style-type:none;">' 
 				+ '<li style="border:none">Data reimport has been started sucessfully.<br />Import Rule Executed:<ul style="padding:0px 0px 0px 10px;margin:0px 0px 0px 10px;list-style-type:square;"><ul/></li><li style="border:none">Elasped Time(s): ' + CAST(DATEDIFF(s,@start_time,@end_time) AS VARCHAR(100)) + '.</li>'
 					
		EXEC spa_message_board 'u', @user_id,  NULL, 'Import data Staging', @desc, '', '', 's',  @job_name, NULL, @batch_process_id, '', '', '', 'y'
		*/
		EXEC spa_ErrorHandler 0
			, 'spa_ixp_import_data_interface_staging'
			, 'spa_ixp_import_data_interface_staging'
			, 'Success'
			, 'Command executed Successfully.'
			, ''
END
IF @flag = 'r' 
BEGIN 

	BEGIN TRY
		
	IF EXISTS(SELECT 1 FROM ice_interface_data WHERE import_rule_id = @import_rule_id)
	BEGIN 
		UPDATE ice_interface_data
		SET import_rule_id = @import_rule_id
		WHERE ice_interface_data_id = @import_rule_id
	END
	ELSE
	BEGIN
		INSERT INTO ice_interface_data(import_rule_id,description)
		SELECT ixp_rules_id,ixp_rules_name FROM ixp_rules where ixp_rules_id = @import_rule_id
	END 
	EXEC spa_ErrorHandler 0,
             'spa_ICE_interface',
             'spa_ICE_interface',
             'Success',
             'Changes has been succesfully saved.',
             ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'spa_ICE_interface',
             'spa_ICE_interface',
             'DB Error',
             'Failed to save.',
             ''
	END CATCH
END
IF @flag = 'u' 
BEGIN 
	DECLARE @ixp_rules_id INT
	
	SELECT @ixp_rules_id = ixp_rules_id FROM ixp_rules where ixp_rules_name = 'Epex Spot Deal Import'


	EXEC spa_ixp_rules  @flag='t', @process_id=@process_id, @ixp_rules_id=@ixp_rules_id, @run_table=@run_table, @source = '21400', @run_with_custom_enable = 'n', @server_path='epexspot.csv'
END
IF @flag = 'd'
BEGIN 
	BEGIN TRY
		If OBJECT_ID('tempdb..#deal_list') IS NOT NULL 
			DROP TABLE tempdb..#deal_list
		SELECT *
		INTO #delete_list
		FROM dbo.SplitCommaSeperatedValues(@staging_deal_id) a

		IF (@import_type = 1)  
		BEGIN
			DELETE ice
			FROM ixp_import_data_interface_staging ice
			INNER JOIN #delete_list dl ON dl.item = ice.id
		END 
	
		EXEC spa_ErrorHandler 0,
				 'spa_ixp_import_data_interface',
				 'spa_ixp_import_data_interface',
				 'Success',
				 'Data from staging table has been sucessfully deleted.',
             ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'spa_ixp_import_data_interface',
             'spa_ixp_import_data_interface',
             'DB Error',
             'Failed to Delete.',
             ''
	END CATCH
END
IF @flag = 'c' 
BEGIN
	SELECT COUNT(*) data_present FROM ixp_import_data_interface_staging ixp where ixp.ixp_rule_id = @import_rule_id
END