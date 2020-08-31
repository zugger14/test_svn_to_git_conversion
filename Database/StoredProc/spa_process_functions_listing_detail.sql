

IF OBJECT_ID('[dbo].[spa_process_functions_listing_detail]','p') IS NOT NULL
DROP PROC [dbo].[spa_process_functions_listing_detail]
GO
/*
Author : Vishwas Khanal
Dated  : 10.Aug.2009
Purpose: Integration 
Desc   : This will insert/update/delete/display the Grid Data from 'Maintain Filter Details'.
*/
CREATE PROC [dbo].[spa_process_functions_listing_detail]
@flag		CHAR(1) , -- i : insert, u : update, d : delete ,s : select, t: from spa_trigger_compliance_activities
@functionID INT ,
@list		VARCHAR(MAX) = null, -- gets the XML input.
@listID		VARCHAR(100) = null, -- list Ids to be deleted.
@risk_description_id INT = null, -- Group2 Id.
@activity	INT  = null
AS
BEGIN
/*
Notes : 

[Vishwas/13.Aug.2009] - @flag is passed as 'u' when activity is to be mapped or changed from the 'Activity Process Map' UI.
[Vishwas/12.Aug.2009] - Update funcionality was later wiped out, so the flag 'a' is never passed in this SP. The codes has been left 
untouched because on later stage this fucntionality might come into play again.	
[Vishwas/10.Aug.2009] - Whatever ids are passed in @list will be deleted.							
*/
	DECLARE @nodes VARCHAR(500),@sql VARCHAR(8000),@hdoc INT,@nodes_tmp VARCHAR(500),@entity VARCHAR(12),@maxListId INT

	--SELECT @nodes = '',@nodes_tmp = ''
	
	IF @listID = ''
		SELECT @listID = NULL
	
	IF @flag = 'u'		
		UPDATE dbo.process_functions_listing_detail SET risk_control_id = @activity WHERE listId = @listID	
	ELSE IF @flag = 'd'	
		DELETE FROM dbo.process_functions_listing_detail WHERE listId = @listID
	ELSE IF @flag IN ('i','t')
	BEGIN		
		IF OBJECT_ID('tempdb..##tmp') IS NOT NULL
		DROP TABLE ##tmp

--		IF @list IS NULL OR @list = ''
--			SELECT @list = '<root>
--								<row Subsidiary="Vishwas|1" Strategy="Prasad|2" Book="Khanal|4" ></row>
--								<row Subsidiary="Ravi|6" Strategy="Man|7" Book="Shrestha|8" ></row>
--							</root>'
				
		EXEC sp_xml_preparedocument @hdoc OUTPUT, @list

		SELECT @nodes = ISNULL(@nodes+',','')+ '[' + filterID +'] VARCHAR(100)'
			, @nodes_tmp = ISNULL(@nodes_tmp+',','') + '[' + filterID +']' FROM OPENXML(@hdoc, '/root/row') JOIN process_filters ON localname = filterID 
				WHERE nodetype = 2 AND parentid<>0 
					GROUP BY filterID 
						ORDER BY MAX(precedence) ASC  

		IF @flag = 't'-- This will Occur when this is called from the dbo.spa_trigger_compliance_activities
			SELECT @nodes_tmp = ISNULL(@nodes_tmp+',','') + '[' + pfld.filterId +']' FROM process_functions_listing_detail pfld
			JOIN process_filters pf
				ON pfld.filterId = pf.filterId
					WHERE functionId = @functionID														
				  GROUP BY pfld.filterId
					ORDER BY MAX(precedence) ASC  


--		SELECT @nodes = SUBSTRING(@nodes,2,LEN(@nodes)),@nodes_tmp = SUBSTRING(@nodes_tmp,2,LEN(@nodes))

		SELECT @sql = 'DELETE FROM dbo.process_functions_listing_detail WHERE '
					+ CASE WHEN @listID IS NOT NULL THEN ' listId IN ('+@listID+')' ELSE '1=2' END 

		--PRINT @sql

		EXEC (@sql)

		SELECT @maxListId = ISNULL(MAX(listId),0) + 1 FROM PROCESS_FUNCTIONS_LISTING_DETAIL

		SELECT @sql = 
			'DECLARE @hdoc INT
			 EXEC sp_xml_preparedocument @hdoc OUTPUT,'''+ @list +'''			 
 			 SELECT IDENTITY(INT,'+CAST(@maxListId AS VARCHAR)+',1) AS sno,* into ##tmp from OPENXML (@hdoc, ''/root/row'') WITH ('+@nodes+')
			 EXEC sp_xml_removedocument @hdoc '

		--PRINT @sql
		
		EXEC (@sql)
					

		DECLARE @sessionId VARCHAR(100)
	
--		SELECT @sessionId = REPLACE(NEWId(),'-','_')
		SELECT @sessionId = NEWId()
			
		SELECT @sql = 	
		CASE WHEN @activity IS NULL THEN
		'INSERT INTO dbo.process_functions_listing_detail (listId,functionId,risk_description_id,filterId,entityId,entityDesc,sessionId)		 					
			SELECT sno,'+CAST(@functionID AS VARCHAR)+','+CAST(@risk_description_id AS VARCHAR)+',filterID,substring(entityName,charindex(''|'',entityName)+1,len(entityName)) ,substring(entityName,1,charindex(''|'',entityName)-1)'
		ELSE
		'INSERT INTO dbo.process_functions_listing_detail (listId,functionId,risk_description_id,risk_control_id,filterId,entityId,entityDesc,sessionId)		 					
			SELECT sno,'+CAST(@functionID AS VARCHAR)+','+CAST(@risk_description_id AS VARCHAR)+','+CAST(@activity AS VARCHAR)+',filterID,substring(entityName,charindex(''|'',entityName)+1,len(entityName)) ,substring(entityName,1,charindex(''|'',entityName)-1)'
		END +','''+
			@sessionId + ''' FROM 
			   (SELECT sno,'+@nodes_tmp
			   +' FROM ##tmp) p
			UNPIVOT
			   (entityName FOR filterID IN 
				  ('+@nodes_tmp+')
			)AS unpvt;'

			--PRINT @sql

			EXEC (@sql)		
			

			EXEC sp_xml_removedocument @hdoc
	END
			
	IF @flag = 's'
	BEGIN
		CREATE TABLE #nodes_tmp (nodes VARCHAR(500) COLLATE DATABASE_DEFAULT)
		
		SELECT IDENTITY(INT,1,1) AS sno,* INTO #process_functions_listing_detail FROM process_functions_listing_detail 
			WHERE functionId = @functionID
				AND ((risk_description_id = @risk_description_id AND @risk_description_id IS NOT NULL) OR (@risk_description_id IS NULL)) 
		
		SELECT @sql  = 'DECLARE @nodes_tmp VARCHAR(500) 
					 SELECT @nodes_tmp = ISNULL(@nodes_tmp+'','','''') +  filterID from #process_functions_listing_detail where 1=1 '
			
--		IF @flag = 'a'
--			SELECT @sql = @sql + ' and listId = '+CAST(@listId AS VARCHAR)
--		ELSE
			SELECT @sql = @sql +' AND functionId = '+CAST(@functionID AS VARCHAR) +' GROUP BY filterID
			ORDER BY MAX(sno) ASC '
			
		SELECT 	@sql=@sql+'	INSERT INTO #nodes_tmp SELECT @nodes_tmp'
		
		--PRINT (@sql)
		
		IF EXISTS(SELECT 'x' FROM dbo.process_functions_listing_detail)
			EXEC (@sql)

		SELECT @nodes_tmp = nodes FROM #nodes_tmp

--		SELECT @nodes_tmp = SUBSTRING(@nodes_tmp,2,LEN(@nodes_tmp))
	END

	SELECT @entity  =  CASE WHEN @flag = 's' THEN 'entityDesc' ELSE 'entityId' END

--					(SELECT listId,functionId,filterID,'+@entity+' FROM process_functions_listing_detail 
--						WHERE 1=1 '+

	IF OBJECT_ID('tempdb..##listingDetail') IS NOT NULL and @flag = 't'
	DROP TABLE ##listingDetail

			SELECT @sql = 
				'SELECT Id AS [ID],'+
					CASE @flag WHEN 's' THEN
							'dbo.FNAComplianceHyperlink(''a'',10121015,Activity,risk_control_id,default,default,default,default,default,default)'
						ELSE 'Activity'
						END  + ' as Activity,'
					+ @nodes_tmp  +
					CASE @flag WHEN  't' THEN ' INTO ##listingDetail FROM ' ELSE ' FROM ' END +
					'(SELECT listId as ID ,prc.risk_control_description as Activity,prc.risk_control_id,functionId,filterID,'+@entity+' FROM process_functions_listing_detail pfld 
						LEFT OUTER JOIN process_risk_controls prc
							ON pfld.risk_control_id = prc.risk_control_id WHERE 1=1 '+
							CASE @flag WHEN 't' THEN ' AND functionId = ' + CAST(@functionID AS VARCHAR) ELSE '' END + 
					CASE WHEN @flag  = 'i' THEN 
						' AND sessionId IS NOT NULL' 			
						WHEN @flag  = 's' AND @risk_description_id IS NOT NULL THEN 'AND pfld.risk_description_id = '+CAST(@risk_description_id AS VARCHAR) ELSE '' END

						+') AS t
						 PIVOT 
						(
							MIN('+@entity+') FOR filterID IN ('+@nodes_tmp+')
						 ) AS p '


		--PRINT @sql
	
--		SELECT * FROM dbo.process_functions_listing_detail
	
		IF EXISTS(SELECT 'x' FROM dbo.process_functions_listing_detail)		
			EXEC (@sql)		
						
		UPDATE dbo.process_functions_listing_detail SET sessionId = NULL 		
			

END
