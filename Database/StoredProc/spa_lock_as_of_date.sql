IF OBJECT_ID(N'[dbo].[spa_lock_as_of_date]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_lock_as_of_date
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2013-11-23
-- Description: CRUD operations for table lock_as_of_date
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- @lock_as_of_date_id INT - unique id
-- @sub_ids VARCHAR - sub ids
-- @close_date DATETIME - close date
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_lock_as_of_date]
    @flag CHAR(1) = NULL,
    @lock_as_of_date_id INT = NULL,
    @sub_ids VARCHAR(5000) = NULL,
	@close_date DATETIME = NULL,
	@close_on DATETIME = NULL,
	@close_by VARCHAR(5000) = NULL,
	@xml VARCHAR(MAX) = NULL,
	@del_ids VARCHAR(MAX) = NULL
AS
SET NOCOUNT ON
DECLARE @sql VARCHAR(MAX)

IF @flag IN('i')
BEGIN
	DECLARE @idoc INT
	EXEC sp_xml_preparedocument @idoc OUTPUT,
	     @xml
	     
    IF OBJECT_ID('tempdb..#temp_lock_as_of_date') IS NOT NULL
      DROP TABLE #temp_lock_as_of_date
      
	SELECT NULLIF(lock_as_of_date_id, '') lock_as_of_date_id,
	       NULLIF(sub_ids,'') sub_ids,
	       NULLIF(close_date,'') close_date,
	       NULLIF(close_on, '')     close_on,
	       NULLIF(close_by, '') close_by
	       INTO  #temp_lock_as_of_date
	FROM   OPENXML(@idoc, '/Root/GridGroup/Grid/GridRow', 1)
	       WITH (
	                lock_as_of_date_id INT,
	                sub_ids VARCHAR(500) ,
	                close_date DATETIME,
	                close_on DATETIME,
	                close_by VARCHAR(500) 
	            )   
  
END

IF @flag = 's'
BEGIN
   ;WITH CTE AS(SELECT 
					lock_as_of_date_id  lock_as_of_date_id,
					ph.entity_name AS  [Subsidiary],
					close_date close_date,
					close_on,
					close_by
			FROM lock_as_of_date la
			LEFT JOIN portfolio_hierarchy ph ON ph.entity_id = la.sub_ids
	)
	SELECT MAX(lock_as_of_date_id) ID,
			STUFF((SELECT ',' + [Subsidiary]
					FROM CTE
					WHERE close_date = C.close_date
					FOR XML PATH ('')), 1, 1, '') AS [Subsidiary],
			dbo.FNADateFormat(close_date) AS [Close Date],
			MAX(dbo.FNADateFormat(close_on)) [Close On],
			MAX(close_by) [Close By] 	
	FROM CTE C
	GROUP BY close_date	
	ORDER BY close_date
END

IF @flag = 'g'
BEGIN
	SET @sql = 
	    'SELECT la.lock_as_of_date_id,
	       la.sub_ids,
	       la.close_date,
	       la.close_on,				
	       la.close_by
		FROM lock_as_of_date la'
	
	EXEC (@sql)
END

IF @flag = 'i'
BEGIN	
	BEGIN TRY
		IF EXISTS (
			   SELECT close_date
					 ,sub_ids
					 ,COUNT(*)
			   FROM   #temp_lock_as_of_date tla
			   GROUP BY
					  close_date
					 ,sub_ids
			   HAVING COUNT(*) > 1
		   )
		BEGIN
			EXEC spa_ErrorHandler -1
				,'lock_as_of_date'
				,'spa_lock_as_of_date'
				,'DBError'
				,'Duplicate data in (<b>Subsidiary and Close Date</b>).'
				,''
			RETURN
		END
		
		IF EXISTS (
			SELECT close_date
				  ,sub_ids
			FROM   #temp_lock_as_of_date tla EXCEPT
			SELECT close_date
				  ,sub_ids
			FROM   lock_as_of_date  
		)
		
		BEGIN
		    INSERT INTO lock_as_of_date
		      (
		        sub_ids,
		        close_date,
		        close_on,
		        close_by
		      )
		    SELECT tla.sub_ids,
		           tla.close_date,
		           GETDATE(),
		           dbo.FNADBUSER()
		    FROM   #temp_lock_as_of_date tla
		           LEFT JOIN lock_as_of_date la
		                ON  tla.lock_as_of_date_id = la.lock_as_of_date_id
		    WHERE  tla.lock_as_of_date_id IS NULL
		    
			DECLARE @recommendation_return VARCHAR(1000) = SCOPE_IDENTITY()
		    
		    EXEC spa_ErrorHandler 0,
		         'lock_as_of_date',
		         'spa_lock_as_of_date',
		         'Success',
		         'Data has been successfully saved.',
		         @recommendation_return
		    
		    RETURN
		END
		ELSE 
		BEGIN
			EXEC spa_ErrorHandler -1,
				'lock_as_of_date',
				'spa_lock_as_of_date',
				'DBError',
				'Duplicate data in (<b>Subsidiary and Close Date</b>).',
				''
			RETURN
		END
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1,
		     'lock_as_of_date',
		     'spa_lock_as_of_date',
		     'DB Error',
		     'Duplicate data in (<b>Subsidiary and Close Date</b>).',
		     ''
		RETURN
	END CATCH
END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		DELETE lo
		FROM dbo.FNASplit(@del_ids,',') ids
		INNER JOIN lock_as_of_date lo ON lo.lock_as_of_date_id = ids.item
		
		EXEC spa_ErrorHandler 0
		, 'lock_as_of_date' 
		, 'spa_lock_as_of_date'
		, 'Success'          
		, 'Data has been deleted successfully.'
		, '' 
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, 'lock_as_of_date' 
			, 'spa_lock_as_of_date'
			, 'Error'          
			, 'Could not delete Data.'
			, '' 
	END CATCH
END

ELSE IF @flag = 'c' --check lock as of date
BEGIN
	DECLARE @msg VARCHAR(100)
	SET @msg = 'As of Date (<b>' + dbo.FNADateFormat(@close_date) + '</b>) has been locked. Please unlock first to proceed.'
	
	IF OBJECT_ID('tempdb..#date_subs') IS NOT NULL
		DROP TABLE #date_subs

	SELECT d.item, @close_date close_date
		INTO #date_subs	
	FROM dbo.FNASplit(@sub_ids, ',') d

	IF EXISTS(SELECT 1 
				FROM #date_subs	ds
				INNER JOIN lock_as_of_date lock_dates ON lock_dates.close_date = @close_date
				WHERE lock_dates.close_date = @close_date
					AND ISNULL(lock_dates.sub_ids, 0) = CASE WHEN lock_dates.sub_ids IS NULL THEN ISNULL(lock_dates.sub_ids, 0)
														ELSE 
															CASE WHEN @sub_ids = 'NULL'   
															THEN ISNULL(lock_dates.sub_ids, 0) ELSE ds.item 
															END
														END)
	BEGIN
		EXEC spa_ErrorHandler -1
			, 'lock_as_of_date' 
			, 'spa_lock_as_of_date'
			, 'Error'          
			, @msg
			, '' 
	END
	ELSE 
		EXEC spa_ErrorHandler 0
			, 'lock_as_of_date' 
			, 'spa_lock_as_of_date'
			, 'Success'          
			, 'No lock found'
			, ''
END

IF @flag = 'x'
BEGIN
	SELECT cast (entity_id AS VARCHAR) entity_id,
	       entity_name
	FROM   portfolio_hierarchy ph 
	WHERE  hierarchy_level = 2 
	       AND entity_id > 1  UNION ALL SELECT '' entity_id, ' ' entity_name ORDER BY entity_name
END

GO