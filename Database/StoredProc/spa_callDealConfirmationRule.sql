

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_callDealConfirmationRule]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_callDealConfirmationRule]
GO

CREATE PROC [dbo].[spa_callDealConfirmationRule]
	@source_deal_header_ids VARCHAR(MAX),
	@event_id INT,
	@process_id VARCHAR(200),
	@deal_status_flag INT = NULL,
	@confirm_status_flag INT = NULL,
	@deal_update INT= NULL,
	@deal_status_from VARCHAR(8000) = NULL,
	@deal_status_deal_id VARCHAR(8000) = NULL

AS
SET NOCOUNT ON

 /*
DECLARE @flag CHAR(1)
DECLARE @source_deal_header_ids VARCHAR(MAX),@process_id VARCHAR(200)
DECLARE @event_id INT
DECLARE @deal_status_flag INT


SET @source_deal_header_ids = 131795
SET @event_id = 19501
SET @process_id = 'B2F40C5F_9EBA_43EC_A612_1091530B9A4E'
SET @deal_status_flag = 1
DROP TABLE #temp_deal_status
-- SELECT * FROM status_rule_header
-- select * from status_rule_detail
-- select * from status_rule_activity
--select * from source_deal_header_template
-- select * from static_data_value where type_id=19500
--select * from confirm_status
--EXEC dbo.spa_callDealConfirmationRule 'i','131791', 19501
-- select deal_status,* from source_deal_header where source_deal_header_id=131791
--select * from static_data_value where value_id=17202
DROP TABLE adiha_process.dbo.work_flow_farrms_admin_B2F40C5F_9EBA_43EC_A612_1091530B9A4E
--select * from adiha_process.dbo.work_flow_farrms_admin_B2F40C5F_9EBA_43EC_A612_1091530B9A4E

--*/
BEGIN	
	
	DECLARE @function_id VARCHAR(1000),@sql VARCHAR(MAX),@spa VARCHAR(500),@activity_id VARCHAR(1000),@table_name VARCHAR(200), @user_login_id VARCHAR(50),@job_name VARCHAR(200),@actionType CHAR(1),@table VARCHAR(200),@temp_source_deal_header_id VARCHAR(2000), @process_id1 VARCHAR(100)
	
	SET @spa = ''
	SET @user_login_id = dbo.FNADBUser();
	

	--- For Insert Event set the default deal status - Event ID =19501,19502,19508
	IF (@event_id =19501 OR (@event_id = 19502 AND @deal_update = 1))
	BEGIN
				
		set @sql ='UPDATE sdh	
			SET
				sdh.deal_status = ISNULL(srd.Change_to_status_id,sdh.deal_status)		
		FROM
			source_deal_header sdh
			INNER JOIN (SELECT item FROM dbo.splitcommaseperatedvalues(''' + @source_deal_header_ids + ''')) it ON sdh.source_deal_header_id = it.Item
			INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
			INNER JOIN status_rule_header srh ON srh.status_rule_id = sdht.deal_rules
			INNER JOIN status_rule_detail srd ON srd.status_rule_id = srh.status_rule_id
			AND ISNULL(srd.from_status_id,' + isnull(@deal_status_from,-1) + ') = ' + isnull(@deal_status_from,-1) 
			+ CASE WHEN @deal_status_deal_id IS NOT NULL then ' INNER JOIN dbo.FNASplit(''' + @deal_status_deal_id + ''','','') f ON dbo.FNAGetSplitPart(f.Item ,'':'' ,1) = sdh.source_deal_header_id
			AND  ISNULL(dbo.FNAGetSplitPart(f.Item ,'':'' ,2), 0) = ISNULL(srd.from_status_id, ISNULL(dbo.FNAGetSplitPart(f.Item ,'':'' ,2), 0))'
			ELSE '' END +' 
		WHERE
				srd.event_id IN (19501,19502,19508) 
				AND srd.event_id IN (' + cast(@event_id AS VARCHAR) + ')
				AND srh.status_rule_type = 5600'
				
		--PRINT @sql
		EXEC(@sql)

		--- For Insert Event set the default confirm status - Event ID =19501,19502,19508
		set @sql = 'INSERT INTO confirm_status(source_deal_header_id,[type],[as_of_date] )	
		SELECT
			sdh.source_deal_header_id,srd.Change_to_status_id,GETDATE()
		FROM
			source_deal_header sdh
			INNER JOIN (SELECT item FROM dbo.splitcommaseperatedvalues(''' + @source_deal_header_ids + ''')) it ON sdh.source_deal_header_id = it.Item
			INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
			INNER JOIN status_rule_header srh ON srh.status_rule_id = sdht.confirm_rule
			INNER JOIN status_rule_detail srd ON srd.status_rule_id = srh.status_rule_id
			AND ISNULL(srd.from_status_id,' + isnull(@deal_status_from,-1) + ') = ' + isnull(@deal_status_from,-1) 
			+ CASE WHEN @deal_status_deal_id IS NOT NULL then ' INNER JOIN dbo.FNASplit(''' + @deal_status_deal_id + ''','','') f ON dbo.FNAGetSplitPart(f.Item ,'':'' ,1) = sdh.source_deal_header_id
			AND  ISNULL(dbo.FNAGetSplitPart(f.Item ,'':'' ,2), 0) = ISNULL(srd.from_status_id, ISNULL(dbo.FNAGetSplitPart(f.Item ,'':'' ,2), 0))'
			ELSE '' END +' 
		WHERE
				srd.event_id IN (19501,19502,19508) 
				AND srd.event_id IN (' + cast(@event_id AS VARCHAR) + ')
				AND srh.status_rule_type = 5600'
				
		--PRINT @sql
		EXEC(@sql)
				

		set @sql ='UPDATE 
			csr
		SET csr.[TYPE] = srd.Change_to_status_id	
		
		FROM
			source_deal_header sdh
			INNER JOIN (SELECT item FROM dbo.splitcommaseperatedvalues(''' + @source_deal_header_ids + ''')) it ON sdh.source_deal_header_id = it.Item
			INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
			INNER JOIN status_rule_header srh ON srh.status_rule_id = sdht.confirm_rule
			INNER JOIN status_rule_detail srd ON srd.status_rule_id = srh.status_rule_id
			INNER JOIN confirm_status_recent csr ON csr.source_deal_header_id = sdh.source_deal_header_id
			AND ISNULL(srd.from_status_id,' + isnull(@deal_status_from,-1) + ') = ' + isnull(@deal_status_from,-1) 
			+ CASE WHEN @deal_status_deal_id IS NOT NULL then ' INNER JOIN dbo.FNASplit(''' + @deal_status_deal_id + ''','','') f ON dbo.FNAGetSplitPart(f.Item ,'':'' ,1) = sdh.source_deal_header_id
			AND  ISNULL(dbo.FNAGetSplitPart(f.Item ,'':'' ,2), 0) = ISNULL(srd.from_status_id, ISNULL(dbo.FNAGetSplitPart(f.Item ,'':'' ,2), 0))'
			ELSE '' END +' 
		WHERE
				srd.event_id IN (19501,19502,19508) 
				AND srd.event_id IN (' + cast(@event_id AS VARCHAR) + ')
				AND srh.status_rule_type = 5600'
				
		--PRINT @sql
		EXEC(@sql)
				
		
		set @sql = 'INSERT INTO confirm_status_recent(source_deal_header_id,[type],[as_of_date] )			
		SELECT
			sdh.source_deal_header_id,srd.Change_to_status_id,GETDATE()
		FROM
			source_deal_header sdh
			INNER JOIN (SELECT item FROM dbo.splitcommaseperatedvalues(''' + @source_deal_header_ids + ''')) it ON sdh.source_deal_header_id = it.Item
			INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
			INNER JOIN status_rule_header srh ON srh.status_rule_id = sdht.confirm_rule
			INNER JOIN status_rule_detail srd ON srd.status_rule_id = srh.status_rule_id
			LEFT JOIN confirm_status_recent csr ON csr.source_deal_header_id = sdh.source_deal_header_id
			AND ISNULL(srd.from_status_id,' + isnull(@deal_status_from,-1) + ') = ' + isnull(@deal_status_from,-1) 
			+ CASE WHEN @deal_status_deal_id IS NOT NULL then ' INNER JOIN dbo.FNASplit(''' + @deal_status_deal_id + ''','','') f ON dbo.FNAGetSplitPart(f.Item ,'':'' ,1) = sdh.source_deal_header_id
			AND  ISNULL(dbo.FNAGetSplitPart(f.Item ,'':'' ,2), 0) = ISNULL(srd.from_status_id, ISNULL(dbo.FNAGetSplitPart(f.Item ,'':'' ,2), 0))'
			ELSE '' END +' 
		WHERE
				srd.event_id IN (19501,19502,19508) 
				AND srd.event_id IN (' + cast(@event_id AS VARCHAR) + ')
				AND srh.status_rule_type = 5600'
				
		--PRINT @sql
		EXEC(@sql)
				
				

		set @sql = 'UPDATE 
			sdh
		SET sdh.confirm_status_type = srd.Change_to_status_id			
		FROM
			source_deal_header sdh
			INNER JOIN (SELECT item FROM dbo.splitcommaseperatedvalues(''' + @source_deal_header_ids + ''')) it ON sdh.source_deal_header_id = it.Item
			INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
			INNER JOIN status_rule_header srh ON srh.status_rule_id = sdht.confirm_rule
			INNER JOIN status_rule_detail srd ON srd.status_rule_id = srh.status_rule_id
			AND ISNULL(srd.from_status_id,' + isnull(@deal_status_from,-1) + ') = ' + isnull(@deal_status_from,-1) 
			+ CASE WHEN @deal_status_deal_id IS NOT NULL then ' INNER JOIN dbo.FNASplit(''' + @deal_status_deal_id + ''','','') f ON dbo.FNAGetSplitPart(f.Item ,'':'' ,1) = sdh.source_deal_header_id
			AND  ISNULL(dbo.FNAGetSplitPart(f.Item ,'':'' ,2), 0) = ISNULL(srd.from_status_id, ISNULL(dbo.FNAGetSplitPart(f.Item ,'':'' ,2), 0))'
			ELSE '' END +' 
		WHERE
				srd.event_id IN (19501,19502,19508) 
				AND srd.event_id IN (' + cast(@event_id AS VARCHAR) + ')
				AND srh.status_rule_type = 5600'
				
		--PRINT @sql
		EXEC(@sql)
				
						
	END	
		
	

	
	IF @process_id IS NULL
		SET @process_id = REPLACE(newid(),'-','_')
	--select @deal_status_flag
	
		SET @table_name = dbo.FNAProcessTableName('work_flow', @user_login_id,@process_id)						
		
	
	IF OBJECT_ID(''+ @table_name+'', 'U') IS NOT NULL
		BEGIN 
			SET @process_id1 = REPLACE(newid(),'-','_')
		END 
	ELSE 
		BEGIN 
			SET @process_id1 = @process_id
		END 
			
	SET @table_name = dbo.FNAProcessTableName('work_flow', @user_login_id,@process_id1)	
		EXEC('CREATE TABLE '+@table_name+'(workflow_function_id INT,activity_id INT,source_deal_header_id INT, status_rule_detail_id INT)')	
			
		IF @event_id IN(19501,19508) OR(@event_id = 19502 AND @deal_update = 1)
		BEGIN
				-- Trigger the workflow activity defined for each rules when insert/update/delete
				SET @sql =' INSERT INTO '+@table_name+'
					SELECT DISTINCT sra.workflow_function_id,pfld.risk_control_id activity_id,sdh.source_deal_header_id,srd.status_rule_detail_id
					FROM 
						source_deal_header sdh
						INNER JOIN (SELECT item FROM dbo.splitcommaseperatedvalues('''+@source_deal_header_ids+''')) it ON sdh.source_deal_header_id = it.Item
						INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
						INNER JOIN status_rule_header srh ON srh.status_rule_id = sdht.deal_rules
							AND srh.status_rule_type = 5600
						INNER JOIN status_rule_detail srd ON srd.status_rule_id = srh.status_rule_id
						INNER JOIN status_rule_activity sra ON srd.event_id = sra.event_id
							AND srd.status_rule_detail_id = sra.status_rule_detail_id
						INNER JOIN process_functions_listing_detail pfld ON pfld.listId = sra.workflow_activity_id 	
					WHERE
						 srd.event_id IN ('+CAST(@event_id AS VARCHAR)+')

					UNION
					
					SELECT sra.workflow_function_id,pfld.risk_control_id activity_id,sdh.source_deal_header_id,srd.status_rule_detail_id
					FROM 
						source_deal_header sdh
						INNER JOIN (SELECT item FROM dbo.splitcommaseperatedvalues('''+@source_deal_header_ids+''')) it ON sdh.source_deal_header_id = it.Item
						INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
						INNER JOIN status_rule_header srh ON srh.status_rule_id = sdht.confirm_rule
							AND srh.status_rule_type = 17200
						INNER JOIN status_rule_detail srd ON srd.status_rule_id = srh.status_rule_id
						INNER JOIN status_rule_activity sra ON srd.event_id = sra.event_id
							AND srd.status_rule_detail_id = sra.status_rule_detail_id
						INNER JOIN process_functions_listing_detail pfld ON pfld.listId = sra.workflow_activity_id 	
					WHERE
						 srd.event_id IN ('+CAST(@event_id AS VARCHAR)+')'
				
					--PRINT @sql
				EXEC(@sql)

			
				CREATE TABLE #temp(source_deal_header_id INT)
				
				EXEC('INSERT INTO #temp SELECT DISTINCT source_deal_header_id FROM '+@table_name)
				
				SET @temp_source_deal_header_id = ''				
				
				SELECT
					  @temp_source_deal_header_id= coalesce(@temp_source_deal_header_id + CASE WHEN @temp_source_deal_header_id = '' THEN '' ELSE  ',' END + cast(source_deal_header_id AS VARCHAR),cast(source_deal_header_id AS VARCHAR)) 
				FROM 
					#temp
						
					
			END
			-- Trigger the workflow activity defined for each rules when status changes


		IF @deal_status_flag = 1 OR @confirm_status_flag =1
		BEGIN
			
			IF @event_id NOT IN(19501,19508)
			BEGIN
				
				SET @table = dbo.FNAProcessTableName('deal_status', @user_login_id,@process_id)
				CREATE TABLE #temp_deal_status(source_deal_header_id INT,deal_status INT,confirm_status INT)
				SET @sql = 'INSERT INTO #temp_deal_status(source_deal_header_id,deal_status,confirm_status)
							SELECT source_deal_header_id,deal_status,confirm_status
							FROM '+@table
					--PRINT @sql
				EXEC(@sql)			
				
			
				
				SET @sql =' INSERT INTO '+@table_name+'
				SELECT sra.workflow_function_id,pfld.risk_control_id,sdh.source_deal_header_id,srd.status_rule_detail_id
				FROM 
					source_deal_header sdh
					INNER JOIN (SELECT item FROM dbo.splitcommaseperatedvalues('''+@source_deal_header_ids+''')) it ON sdh.source_deal_header_id = it.Item
					INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
					INNER JOIN status_rule_header srh ON srh.status_rule_id = sdht.deal_rules
						AND srh.status_rule_type = 5600
					INNER JOIN status_rule_detail srd ON srd.status_rule_id = srh.status_rule_id
					INNER JOIN status_rule_activity sra ON srd.status_rule_detail_id = sra.status_rule_detail_id
					INNER JOIN process_functions_listing_detail pfld ON pfld.listId = sra.workflow_activity_id 
					INNER JOIN 	#temp_deal_status tds ON tds.source_deal_header_id = sdh.source_deal_header_id
						AND tds.deal_status = srd.from_status_id AND sdh.deal_status = srd.to_status_id
							
					WHERE
						srd.event_id IN(19503)'			
				--print @sql
				EXEC(@sql)

				SET @sql =' INSERT INTO '+@table_name+'
				SELECT sra.workflow_function_id,pfld.risk_control_id,sdh.source_deal_header_id,srd.status_rule_detail_id
				FROM 
					source_deal_header sdh
					INNER JOIN (SELECT item FROM dbo.splitcommaseperatedvalues('''+@source_deal_header_ids+''')) it ON sdh.source_deal_header_id = it.Item
					INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
					INNER JOIN status_rule_header srh ON srh.status_rule_id = sdht.confirm_rule
						AND srh.status_rule_type = 17200
					INNER JOIN status_rule_detail srd ON srd.status_rule_id = srh.status_rule_id
					INNER JOIN status_rule_activity sra ON srd.status_rule_detail_id = sra.status_rule_detail_id
					LEFT JOIN process_functions_listing_detail pfld ON pfld.listId = sra.workflow_activity_id 
					INNER JOIN 	#temp_deal_status tds ON tds.source_deal_header_id = sdh.source_deal_header_id
						AND tds.confirm_status = srd.from_status_id	AND sdh.confirm_status_type = srd.to_status_id
					WHERE
						srd.event_id IN(19507)'			
				--PRINT @sql
				EXEC(@sql)				
				
			END

		END	

				IF @event_id = 19502 AND @deal_status_flag =1  
					SET @event_id = 19503
				
				IF @event_id = 19502 AND @confirm_status_flag =1  
					SET @event_id = 19507	

			DECLARE @deal_status_after_update VARCHAR(MAX)
			SELECT @deal_status_after_update =  isnull(@deal_status_after_update,'') + CASE WHEN @deal_status_after_update  IS NULL THEN '' ELSE ',' END  + cast(deal_status AS VARCHAR) FROM source_deal_header sdh
			INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_ids) scsv ON scsv.item = sdh.source_deal_header_id			
			
			DECLARE @deal_status_message INT 
			IF EXISTS(SELECT 'x' FROM dbo.SplitCommaSeperatedValues(@deal_status_after_update) WHERE item = '5606') and @deal_status_from = '5605'
			--if @deal_status_from = '5605' AND @deal_status_after_update = '5606'
				SET @deal_status_message = 1
			ELSE
				SET @deal_status_message = 0
			
						
			SELECT @actionType	= CASE @event_id WHEN 19501 THEN 'i' WHEN 19502 THEN 'u' WHEN 19508 THEN 'r' WHEN 19507 THEN 'c' WHEN 19503 THEN 'd' END
			 
			DECLARE @status_rule_detail_id VARCHAR(8000)
			CREATE TABLE #temp_status_rule_detail_id(status_rule_detail_id VARCHAR(8000) COLLATE DATABASE_DEFAULT )
			exec('INSERT INTO #temp_status_rule_detail_id SELECT DISTINCT status_rule_detail_id  FROM ' + @table_name)
			 
			SELECT @status_rule_detail_id = ISNULL(@status_rule_detail_id,'') + CASE WHEN @status_rule_detail_id IS NULL THEN '' ELSE ',' END +
			 status_rule_detail_id FROM #temp_status_rule_detail_id

		 	SET @spa ='spa_compliance_confirmation_rule NULL,'''''+@actionType+''''','''''  + CAST(ISNULL(NULLIF(@temp_source_deal_header_id,''),@source_deal_header_ids) AS VARCHAR(5000)) + ''''',''''Deal'''',NULL,NULL,NULL,'''''+@process_id+''''',''''' + cast(@event_id AS VARCHAR)+ ''''',''''' + cast(isnull(@deal_status_from,'') AS VARCHAR) + ''''',''''' + cast(isnull(@deal_status_message,'') AS VARCHAR) + ''''',''''' + @status_rule_detail_id + ''''''

			SET @job_name = 'spa_compliance_workflow_109_112' + @process_id		
			
			SET @sql ='
				IF EXISTS(SELECT ''X'' FROM '+@table_name+')
					EXEC spa_run_sp_as_job '''+@job_name+''', '''+@spa+''',''spa_compliance_workflow_109_112'' ,'''+@user_login_id+''''
			--PRINT @sql
			EXEC(@sql)		

	
	
END 
