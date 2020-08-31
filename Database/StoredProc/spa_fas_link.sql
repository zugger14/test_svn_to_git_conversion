
/********************************************************************
 * Create date: 2010-08-12											*
 * Description: Insert update link for deals						*
 * Params:															*
 * @flag			->	i: insert									*
 *						u: update mode								*
 * @link_id			->	relationship id								*
 * @hedge_or_item	->	hedge or item h:hedge, i:item				*
 * @xmlValue		->	detail values								*
 * ******************************************************************/
 
IF EXISTS (
       SELECT 1
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_fas_link]')
              AND TYPE IN (N'P', N'PC')
   )
    DROP PROCEDURE [dbo].[spa_fas_link]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_fas_link]
	@flag VARCHAR(2),
	@link_id INT,
	@hedge_or_item CHAR(1) = NULL,
	@xmlValue TEXT = NULL
AS
	SET NOCOUNT ON 
	
	DECLARE @idoc INT
	DECLARE @link_effective_date datetime
	DECLARE @error_message VARCHAR(8000)
	DECLARE @percentage_available FLOAT
	DECLARE @percentage_included FLOAT
	DECLARE @source_deal_header_id INT
	DECLARE @sql_stmt VARCHAR(MAX)
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlValue
	
	SELECT source_deal_header_id,
	       refrence_id,
	       percent_included,
	       (
	           CASE 
	                WHEN effective_date = '' THEN NULL
	                --WHEN effective_date = @link_effective_date THEN NULL
	                ELSE dbo.FNACovertToSTDDate(effective_date)
	           END
	       ) AS effective_date 
	INTO #tmp_fas_link_data
	FROM   OPENXML(@idoc, '/Root/PSRecordset', 2)
	       WITH (
	           source_deal_header_id	INT			'@edit_grid1',
	           refrence_id				VARCHAR(50) '@edit_grid2',
	           percent_included			FLOAT		'@edit_grid3',
	           effective_date		    VARCHAR(10) '@edit_grid4'
	       )
	
	
	IF @flag = 'i'
	BEGIN 
		IF EXISTS(	SELECT 1 
					FROM #tmp_fas_link_data tfld
					INNER JOIN fas_link_detail fld 
						ON fld.source_deal_header_id = tfld.source_deal_header_id
					WHERE fld.link_id = @link_id
				)
		BEGIN
			SET @error_message = 'Cannot insert duplicate source deal header id.'
		        
				SELECT 'Error' AS ErrorCode,
					   'Fas Link detail' AS Module,
					   'spa_fas_link-detail' AS Area,
					   'Application Error' AS tatus,
					   ('Failed to Insert Link detail record. ' + @error_message) AS 
					   MESSAGE,
					   @error_message AS Recommendation
		        
				RETURN
		END
	END

	--effective date validation (should be less than @link_effective_date & deal_date)
	IF EXISTS(	SELECT 1 
				FROM #tmp_fas_link_data tfld
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = tfld.source_deal_header_id
				WHERE tfld.effective_date < sdh.deal_date
			)
	BEGIN
		SET @error_message = 
	            'Effective Date can not be less than the Deal Date. One or more selected deals violated this.'
	        
	        SELECT 'Error' AS ErrorCode,
	               'Fas Link detail' AS Module,
	               'spa_fas_link-detail' AS Area,
	               'Application Error' AS tatus,
	               ('Failed to Insert Link detail record. ' + @error_message) AS 
	               MESSAGE,
	               @error_message AS Recommendation
	        
	        RETURN
	END
	ELSE
	BEGIN
		SELECT @link_effective_date = dbo.FNAGetSQLStandardDate(link_effective_date) from fas_link_header where link_id = @link_id
		
		IF EXISTS (SELECT 1 FROM #tmp_fas_link_data tfld WHERE @link_effective_date > effective_date) 
	        BEGIN
	            SET @error_message = 
	                'Effective Date can not be less than the link effective date. One or more selected deals violated this.'
	            
	            SELECT 'Error' AS ErrorCode,
	                   'Fas Link detail' AS Module,
	                   'spa_fas_link-detail' AS Area,
	                   'Application Error' AS tatus,
	                   ('Failed to Insert Link detail record. ' + @error_message) AS 
	                   MESSAGE,
	                   @error_message AS Recommendation
	            
	            RETURN
	        END
	END
	
	EXEC spa_print 'here'
	--- FOR INSERT AND UPDATE FIND what % can be included.. the following is what % has been already linked
	SET @percentage_available = 1.0
	
	CREATE TABLE #temp_per_i
	(
		per_include FLOAT
	)
	SET @sql_stmt = 
	    'INSERT #temp_per_i (per_include)
			SELECT MIN(per) per_include 
			FROM 
				(
					SELECT fld.source_deal_header_id, 
		  				(
							1.0 - ISNULL(
										SUM(
											CASE 
												WHEN (''' + CAST(@link_effective_date AS varchar) + ''' >= ISNULL(flh.link_end_date,'''')) THEN 0 
												ELSE fld.percentage_included 
											END
										), 0)
						)  per
					FROM fas_link_detail fld
					INNER JOIN fas_link_header flh 
						ON flh.link_id = fld.link_id
					INNER JOIN #tmp_fas_link_data tfld 
						ON tfld.source_deal_header_id = fld.source_deal_header_id
					GROUP BY fld.source_deal_header_id
				)  cc'
	
	EXEC spa_print @sql_stmt
	
	EXEC (@sql_stmt)
	SELECT @percentage_included = percent_included, @source_deal_header_id = source_deal_header_id
	FROM   #tmp_fas_link_data
	
	IF @percentage_included > @percentage_available
	BEGIN
	    SET @error_message = 'Deal: ' + CAST(@source_deal_header_id AS VARCHAR) 
	        +
	        ' Can only be included up to: ' + CAST(@percentage_available AS VARCHAR)
	    
	    SELECT 'Error' AS ErrorCode,
	           'Fas Link detail' AS Module,
	           'spa_fas_link-detail' AS Area,
	           'Application Error' AS status,
	           ('Failed to Insert Link detail record. ' + @error_message) AS 
	           MESSAGE,
	           @error_message AS Recommendation
	END
	ELSE
	BEGIN
		IF @flag = 'i'
		BEGIN
			SET @sql_stmt = 
							'
								INSERT INTO fas_link_detail
									(
										link_id,
										source_deal_header_id,
										percentage_included,
										hedge_or_item,
										effective_date
									)
									SELECT ' 
										+ CAST(@link_id AS VARCHAR) + ',
										tfld.source_deal_header_id,
										CAST(tfld.percent_included AS VARCHAR) ,
										''' + @hedge_or_item + ''',
										 CASE 
												   WHEN tfld.effective_date IS NULL THEN NULL
												   ELSE tfld.effective_date
											  END 
										FROM source_deal_header sdh
										INNER JOIN #tmp_fas_link_data tfld 
											ON tfld.source_deal_header_id = sdh.source_deal_header_id
							'
			exec spa_print @sql_stmt
			EXEC (@sql_stmt)
		    
			IF @@ERROR <> 0
				EXEC spa_ErrorHandler @@ERROR,
					 'Fas Link detail table',
					 'spa_fas_link_detail',
					 'DB Error',
					 'Failed to select Link detail record.',
					 ''
			ELSE
				EXEC spa_ErrorHandler 0,
					 'Link Dedesignation Table',
					 'spa_fas_link_detail',
					 'Success',
					 'Link Detail records successfully Inserted.',
					 ''
		END
		ELSE IF @flag = 'u'
		BEGIN
			EXEC spa_print 'update'
			SET @sql_stmt = 
							'
								UPDATE fld
								SET fld.percentage_included = CAST(tfld.percent_included AS VARCHAR),
								fld.effective_date = CASE 
													WHEN tfld.effective_date IS NULL THEN NULL
													ELSE tfld.effective_date
												END
								FROM #tmp_fas_link_data tfld
								INNER JOIN fas_link_detail fld
									ON fld.source_deal_header_id = tfld.source_deal_header_id 
								WHERE fld.link_id = ' + CAST(@link_id AS VARCHAR(50))
							
			exec spa_print @sql_stmt
			EXEC (@sql_stmt)
		    
			IF @@ERROR <> 0
				EXEC spa_ErrorHandler @@ERROR,
					 'Fas Link detail table',
					 'spa_fas_link_detail',
					 'DB Error',
					 'Failed to select Link detail record.',
					 ''
			ELSE
				EXEC spa_ErrorHandler 0,
					 'Link Dedesignation Table',
					 'spa_fas_link_detail',
					 'Success',
					 'Link Detail records successfully Updated.',
					 ''
		END
    
	END