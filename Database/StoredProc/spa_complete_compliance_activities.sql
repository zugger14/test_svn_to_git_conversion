

IF OBJECT_ID('[dbo].[spa_complete_compliance_activities]','p') is not null
	DROP PROC [dbo].[spa_complete_compliance_activities]
go 

CREATE PROC [dbo].[spa_complete_compliance_activities]
@flag CHAR(1), -- 'c' : complete compliance activities.
@functionId INT =  null, -- Integration fucntion Id
@list VARCHAR(max) = null,
@comments VARCHAR(1000) = null,
@status CHAR(1) = 'c' ,-- According to this flag the font color is changed in the message board
@source VARCHAR(150)= NULL,
@source_id VARCHAR(100) = NULL,
@createTrigger CHAR(1) = 'y',
@activity VARCHAR(100) = NULL,
@risk_control_activity_id INT = NULL OUTPUT

AS
SET NOCOUNT ON
BEGIN
	DECLARE @hdoc INT,@nodes  VARCHAR(8000),@sql VARCHAR(8000),@listId INT --,@source VARCHAR(150)
	DECLARE @getdate DATETIME--,@risk_control_activity_id INT
	
	SELECT @getdate = dbo.FNAGetSQLStandardDateTime(GETDATE())
	
	IF @flag = 'c'
	BEGIN
	
		IF OBJECT_ID('tempdb..##performDetail') IS NOT NULL
		DROP TABLE ##performDetail

--		IF @list IS NULL OR @list = ''
--			SELECT @list = '<root>
--								<row Subsidiary="1" Strategy="2" Book="4" ></row>
--								<row Subsidiary="6" Strategy="7" Book="8" ></row>
--							</root>'


		EXEC sp_xml_preparedocument @hdoc OUTPUT, @list

		SELECT @nodes = ISNULL(@nodes+',','') +   filterId + ' VARCHAR(100)' FROM OPENXML(@hdoc, '/root/row')
			INNER JOIN dbo.process_filters
					ON localname = filterId
				WHERE nodetype = 2 AND parentid<>0 
					GROUP BY filterId
						ORDER BY max(precedence) ASC			
		SELECT @sql = 
			'DECLARE @hdoc INT
			 EXEC sp_xml_preparedocument @hdoc OUTPUT,'''+ @list +'''			 
 			 SELECT IDENTITY(INT,1,1) AS sno,* into ##performDetail from OPENXML (@hdoc, ''/root/row'') WITH ('+@nodes+')
			 EXEC sp_xml_removedocument @hdoc '

			--PRINT @sql

			EXEC(@sql)			

			--EXEC dbo.spa_process_functions_listing_detail 't',100			
			EXEC dbo.spa_process_functions_listing_detail 't', @functionId 

			EXEC sp_xml_removedocument @hdoc 

			IF OBJECT_ID('tempdb..##tmp') IS NOT NULL
				DROP TABLE ##tmp
	
			CREATE TABLE ##tmp (listId INT)

			
		IF @activity IS NULL
		BEGIN	
			SELECT @sql = '
				DECLARE @listId INT
				SELECT @listId   = id FROM ##performDetail pd INNER JOIN ##listingDetail ld ON 1=1 '
				
--				SELECT 'performDetail', * FROM ##performDetail
--				SELECT 'listingDetail', * FROM ##listingDetail 
			
			
			-- function_id = 100
			IF EXISTS (SELECT 'X' FROM process_functions_listing_detail WHERE filterId = 'Subsidiary' AND functionId = @functionId and entityId IS NOT NULL)
				SELECT @sql = @sql + ' AND pd.subsidiary = ld.subsidiary ' 

			IF EXISTS (SELECT 'X' FROM process_functions_listing_detail WHERE filterId = 'Strategy' AND functionId = @functionId and entityId IS NOT NULL)
				SELECT @sql = @sql + ' AND pd.strategy = ld.strategy ' 

			IF EXISTS (SELECT 'X' FROM process_functions_listing_detail WHERE filterId = 'Book' AND functionId = @functionId and entityId IS NOT NULL)
				SELECT @sql = @sql + ' AND pd.book = ld.book ' 
			
			IF EXISTS (SELECT 'X' FROM process_functions_listing_detail WHERE filterId = 'Contract' AND functionId = @functionId and entityId IS NOT NULL)
				SELECT @sql = @sql + ' AND pd.contract= ld.contract	'	

			IF EXISTS (SELECT 'X' FROM process_functions_listing_detail WHERE filterId = 'Counterparty' AND functionId = @functionId and entityId IS NOT NULL)
				SELECT @sql = @sql + ' AND pd.counterparty= ld.counterparty	'

			IF EXISTS (SELECT 'X' FROM process_functions_listing_detail WHERE filterId = 'Nymex' AND functionId = @functionId and entityId IS NOT NULL)
				SELECT @sql = @sql + ' AND pd.Nymex= ld.Nymex	'	

			IF EXISTS (SELECT 'X' FROM process_functions_listing_detail WHERE filterId = 'Treasury' AND functionId = @functionId and entityId IS NOT NULL)
				SELECT @sql = @sql + ' AND pd.Treasury= ld.Treasury	'		

			IF EXISTS (SELECT 'X' FROM process_functions_listing_detail WHERE filterId = 'Platts' AND functionId = @functionId and entityId IS NOT NULL)
				SELECT @sql = @sql + ' AND pd.Platts= ld.Platts '		

			IF EXISTS (SELECT 'X' FROM process_functions_listing_detail WHERE filterId = 'Traders' AND functionId = @functionId and entityId IS NOT NULL)
				SELECT @sql = @sql + ' AND pd.Traders= ld.Traders'		

			IF EXISTS (SELECT 'X' FROM process_functions_listing_detail WHERE filterId = 'MiddleOffice' AND functionId = @functionId and entityId IS NOT NULL)
				SELECT @sql = @sql + ' AND pd.MiddleOffice= ld.MiddleOffice'		

			IF EXISTS (SELECT 'X' FROM process_functions_listing_detail WHERE filterId = 'BackOffice' AND functionId = @functionId and entityId IS NOT NULL)
				SELECT @sql = @sql + ' AND pd.BackOffice= ld.BackOffice'		

			IF EXISTS (SELECT 'X' FROM process_functions_listing_detail WHERE filterId = 'ActivityImport' AND functionId = @functionId and entityId IS NOT NULL)
				SELECT @sql = @sql + ' AND pd.ActivityImport= ld.ActivityImport'		

			IF EXISTS (SELECT 'X' FROM process_functions_listing_detail WHERE filterId = 'AllowanceImport' AND functionId = @functionId and entityId IS NOT NULL)
				SELECT @sql = @sql + ' AND pd.AllowanceImport= ld.AllowanceImport'		
				
			IF EXISTS (SELECT 'X' FROM process_functions_listing_detail WHERE filterId = 'DealDeletion' AND functionId = @functionId and entityId IS NOT NULL)
				SELECT @sql = @sql + ' AND pd.DealDeletion= ld.DealDeletion'		
			
			IF EXISTS (SELECT 'X' FROM process_functions_listing_detail WHERE filterId = 'ApproveHedgeRel' AND functionId = @functionId and entityId IS NOT NULL)
				SELECT @sql = @sql + ' AND pd.ApproveHedgeRel= ld.ApproveHedgeRel'
			
			IF EXISTS (SELECT 'X' FROM process_functions_listing_detail WHERE filterId = 'FinalizeHedgeRel' AND functionId = @functionId and entityId IS NOT NULL)
				SELECT @sql = @sql + ' AND pd.FinalizeHedgeRel= ld.FinalizeHedgeRel'
				
			SELECT @sql = @sql + '  INSERT INTO ##tmp SELECT @listId '
			
			--PRINT (@sql)			
			EXEC(@sql)		
			
			SELECT @listId = listId FROM ##tmp
			
		END
		
		

			IF @listId IS NOT NULL OR @activity IS NOT NULL
			BEGIN
			
				IF @activity IS NULL
					SELECT @activity = risk_control_id FROM process_functions_listing_detail WHERE listId = @listId

				
				IF @source IS NULL
					SELECT @source=risk_control_description FROM process_risk_controls WHERE risk_control_id=@activity		
				
				
--				IF @functionId = 100
				BEGIN	
					EXEC spa_Create_Daily_Risk_Control_Activities '',@activity,'y',NULL,NULL,NULL,'n',@createTrigger
				
					UPDATE 
						process_risk_controls_activities 
					SET 
						control_status=732, -- Notified
						comments=@comments,
						[status]=@status,
						source=@source,		
						source_id = @source_id			
					WHERE risk_control_activity_id= (SELECT MAX(risk_control_activity_id) 
							FROM dbo. process_risk_controls_activities WHERE risk_control_id = @activity)
				END
				
				SELECT @risk_control_activity_id = MAX(risk_control_activity_id) FROM dbo. process_risk_controls_activities WHERE risk_control_id = @activity
				
			END						

	END


	--EXEC spa_get_outstanding_control_activities_job @getdate,@activity,@comments,@comments,@source_id,@risk_control_activity_id -- will post the message in the message board
	
	IF OBJECT_ID('tempdb..##performDetail') IS NOT NULL
		DROP TABLE ##performDetail

	
--	DROP TABLE ##listingDetail

END

