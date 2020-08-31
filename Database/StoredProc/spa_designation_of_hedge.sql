IF OBJECT_ID(N'[dbo].[spa_designation_of_hedge]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_designation_of_hedge]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC dbo.spa_designation_of_hedge
	@flag CHAR(1),
	@xml_value XML = NULL
AS
SET NOCOUNT ON
/* 
--TEST Data
--DECLARE @flag CHAR(1) ='u'
,@xml_value XML ='<Root>
<FormXML  fas_book_id="1178" link_id="5" link_description="" eff_test_profile_id="33" link_type_value_id="450" link_effective_date="2015-11-03" link_end_date="" perfect_hedge="n" fully_dedesignated="n" link_active="y"></FormXML>
<GridGroup>
<Grid grid_id="Hedges">
<GridRow  source_deal_header_id="34679" deal_id="test position1" perc_included=".1000" effective_date="10/17/2015" deal_date="10/17/2015" term_start="10/17/2015" term_end="10/17/2015" buy_sell="Buy (Receive)" volume="1000.00" frequency="Daily" uom="MMBTU" index="Default_Curve" price="" currency="USD" link_id="5" fas_link_detail_id="4" hedge_or_item = "h"></GridRow> 
<GridRow  source_deal_header_id="34678" deal_id="testdeal0010" perc_included="1" effective_date="10/01/2015" deal_date="10/01/2015" term_start="" term_end="01/31/1900" buy_sell="Buy (Receive)" volume="" frequency="Daily" uom="24" index="" price="3.00" currency="USD" link_id="5" fas_link_detail_id="" hedge_or_item = "h"></GridRow> 
</Grid>
<Grid grid_id="Items">
<GridRow  source_deal_header_id="34673" deal_id="phy_test" perc_included=".1000" effective_date="10/01/2015" deal_date="10/01/2015" term_start="10/01/2015" term_end="10/31/2015" buy_sell="Buy (Receive)" volume="6300.00" frequency="Daily" uom="BBL" index="Default_Curve" price="3.9" currency="USD" link_id="5" fas_link_detail_id="5" hedge_or_item = "i"></GridRow>
 </Grid>
 </GridGroup>
 </Root>'
*/			
DECLARE @idoc INT
	, @link_id INT, @perfect_hedge CHAR(1), @link_description VARCHAR(200) , @output VARCHAR(500)
	
IF OBJECT_ID(N'tempdb..#form_xml') IS NOT NULL DROP TABLE #form_xml
	
EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_value		

SELECT fas_book_id,
	NULLIF(link_id, '') link_id,
	link_description,
	eff_test_profile_id,
	link_type_value_id,
	link_effective_date,
	link_end_date,
	perfect_hedge,
	fully_dedesignated,
	link_active	
INTO #form_xml
FROM   OPENXML(@idoc, '/Root/FormXML', 1)
		WITH (
			fas_book_id INT '@fas_book_id',
			link_id VARCHAR(100) '@link_id',
			link_description VARCHAR(100) '@link_description',
			eff_test_profile_id INT '@eff_test_profile_id',
			link_type_value_id INT '@link_type_value_id',
			link_effective_date VARCHAR(10) '@link_effective_date',
			link_end_date VARCHAR(10) '@link_end_date',
			perfect_hedge CHAR(1) '@perfect_hedge',
			fully_dedesignated CHAR(1) '@fully_dedesignated',
			link_active CHAR(1) '@link_active'
		)

SELECT @link_id = link_id, @perfect_hedge = perfect_hedge FROM #form_xml 
EXEC sp_xml_removedocument @idoc

declare @doc2 int
IF OBJECT_ID(N'tempdb..#grid_xml') IS NOT NULL DROP TABLE #grid_xml
	
EXEC sp_xml_preparedocument @doc2 OUTPUT, @xml_value		

SELECT source_deal_header_id,
	deal_id,
	percentage_included,
	NULLIF(effective_date, '') effective_date,
	NULLIF(link_id, '') link_id,
	hedge_or_item,
	NULLIF(fas_link_detail_id, '') fas_link_detail_id,
	NULLIF(volume, '') volume,
	NULLIF(dbo.FNAClientToSqlDate(term_Start), '') term_start
INTO #grid_xml
FROM   OPENXML(@doc2, '/Root/GridGroup/Grid/GridRow', 1)
WITH (
	source_deal_header_id INT '@source_deal_header_id',
	deal_id VARCHAR(100) '@deal_id',
	percentage_included FLOAT '@perc_included',
	effective_date DATETIME '@effective_date',
	link_id INT '@link_id',
	hedge_or_item CHAR(1) '@hedge_or_item',
	fas_link_detail_id INT '@fas_link_detail_id',
	volume FLOAT '@volume',
	term_start VARCHAR(20) '@term_start'
)
EXEC sp_xml_removedocument @doc2

DECLARE @error_message VARCHAR(200), @hedge_vol_sum FLOAT, @item_col_sum FLOAT
IF @flag = 'v'
BEGIN

	SELECT @hedge_vol_sum = ISNULL(ROUND(SUM(percentage_included * volume), 2), 0) from #grid_xml WHERE hedge_or_item = 'h'

	SELECT @item_col_sum = ISNULL(ROUND(SUM(rem_vol), 2), 0) 
	FROM (
		SELECT percentage_included * volume rem_vol FROM #grid_xml WHERE hedge_or_item = 'i'
		UNION ALL
		SELECT sdd.deal_volume * fldd.percentage_used rem_vol FROM #grid_xml grd
		INNER JOIN fas_link_detail_dicing fldd ON grd.source_deal_header_id = fldd.source_deal_header_id AND grd.term_start = fldd.term_start
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = grd.source_deal_header_id AND  grd.term_start = sdd.term_start
		WHERE grd.hedge_or_item = 'i'
	) a	
	
	IF @hedge_vol_sum <> @item_col_sum AND @perfect_hedge = 'n'
	BEGIN
		SET @error_message = 'Volume does not match. </br> Difference : ' + CAST(ABS(@hedge_vol_sum - @item_col_sum) AS VARCHAR(20)) + '</br> Do you want to continue?'
	        
		EXEC spa_ErrorHandler 1, 'Fas Link detail',   
				'spa_designation_of_hedge','DB Error', 
				@error_message, '',  ''
		RETURN
	END
	ELSE 
	BEGIN
		EXEC spa_ErrorHandler 0, 'Fas Link detail',   
				'spa_designation_of_hedge','Success', 
				'Volume Match', '',  ''
		RETURN
	END
END

-- Validation starts
	
	IF EXISTS(SELECT link_id FROM #grid_xml
				GROUP BY link_id, source_deal_header_id
				HAVING count(link_id) > 1			
			)
	BEGIN
		SET @error_message = 'Cannot insert same Deal ID in same link.'
	        
			EXEC spa_ErrorHandler 1, 'Fas Link detail',   
					'spa_designation_of_hedge','DB Error', 
					@error_message, '',  ''
			RETURN
	END	
	
	IF EXISTS(SELECT 1 FROM #grid_xml gx
				INNER JOIN fas_link_detail fld ON fld.source_deal_header_id = gx.source_deal_header_id
					AND fld.link_id = gx.link_id AND gx.fas_link_detail_id IS NULL			
			)
	BEGIN
		SET @error_message = 'Cannot insert duplicate source deal header id.'
	        
			EXEC spa_ErrorHandler 1, 'Fas Link detail',   
					'spa_designation_of_hedge','DB Error', 
					@error_message, '',  ''
			RETURN
	END
	
--effective date validation (should be less than @link_effective_date & deal_date)
	IF EXISTS(	SELECT 1 
				FROM #grid_xml grid_data
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = grid_data.source_deal_header_id
				CROSS JOIN #form_xml fx
				WHERE ISNULL(grid_data.effective_date, fx.link_effective_date) < sdh.deal_date 
					OR ISNULL(grid_data.effective_date, fx.link_effective_date) < fx.link_effective_date
			)
	BEGIN
		SET @error_message = 'Failed to Insert Link detail record. Effective Date can not be less than the Deal Date. One or more selected deals violated this.'
	        
        EXEC spa_ErrorHandler 1, 'Fas Link detail',   
				'spa_designation_of_hedge','DB Error',
				@error_message, '',  '' 
        RETURN
	END
	--ELSE
	--BEGIN
	--	SELECT @link_effective_date = dbo.FNAGetSQLStandardDate(link_effective_date) from fas_link_header where link_id = @link_id
	--	-- TODO fas link header n detail effectvie valid 
	--	IF EXISTS (SELECT 1 FROM #tmp_fas_link_data tfld WHERE @link_effective_date > effective_date) 
	--        BEGIN
	--            SET @error_message = 
	--                'Effective Date can not be less than the link effective date. One or more selected deals violated this.'
	            
	--            SELECT 'Error' AS ErrorCode,
	--                   'Fas Link detail' AS Module,
	--                   'spa_fas_link-detail' AS Area,
	--                   'Application Error' AS tatus,
	--                   ('Failed to Insert Link detail record. ' + @error_message) AS 
	--                   MESSAGE,
	--                   @error_message AS Recommendation
	            
	--            RETURN
	--        END
	--END
	
	--- FOR INSERT AND UPDATE FIND what % can be included.. the following is what % has been already linked
	DECLARE @percentage_available FLOAT = 1, @sql_stmt VARCHAR(MAX)
	
	----- FOR INSERT AND UPDATE FIND what % can be included.. the following is what % has been already linked
	SET @percentage_available = 1.0
	----TODO this tmp table is not in use in prev version have to confirm 
	--CREATE TABLE #temp_per_i
	--(
	--	per_include FLOAT
	--)
	--SET @sql_stmt = 
	--    'INSERT #temp_per_i (per_include)
	--		SELECT MIN(per) per_include 
	--		FROM 
	--			(
	--				SELECT fld.source_deal_header_id, 
	--	  				(
	--						1.0 - ISNULL(
	--									SUM(
	--										CASE 
	--											WHEN (''' + CAST(@link_effective_date AS varchar) + ''' >= ISNULL(flh.link_end_date,'''')) THEN 0 
	--											ELSE fld.percentage_included 
	--										END
	--									), 0)
	--					)  per
	--				FROM fas_link_detail fld
	--				INNER JOIN fas_link_header flh 
	--					ON flh.link_id = fld.link_id
	--				INNER JOIN #tmp_fas_link_data tfld 
	--					ON tfld.source_deal_header_id = fld.source_deal_header_id
	--				GROUP BY fld.source_deal_header_id
	--			)  cc'
	
	--PRINT @sql_stmt
	
	--EXEC (@sql_stmt)
	
	
IF EXISTS(SELECT source_deal_header_id FROM #grid_xml where percentage_included > @percentage_available)
BEGIN
	SET @error_message = ''
		--'Deal: ' + CAST(@source_deal_header_id AS VARCHAR) 
  --      +
  --      ' Can only be included up to: ' + CAST(@percentage_available AS VARCHAR)
    
    SELECT 'Error' AS ErrorCode,
           'Fas Link detail' AS Module,
           'spa_fas_link-detail' AS Area,
           'Application Error' AS [status],
           ('Failed to Insert Link detail record. ' + @error_message) AS MESSAGE,
           @error_message AS Recommendation
           
    RETURN
END
ELSE IF @flag = 'i'
BEGIN

	INSERT INTO fas_link_header (fas_book_id
								, perfect_hedge
								, fully_dedesignated
								, link_description
								, eff_test_profile_id
								, link_effective_date
								, link_type_value_id
								, link_active)
 	SELECT fas_book_id
 			, perfect_hedge
			, fully_dedesignated
			, link_description
			, eff_test_profile_id
			, link_effective_date
			, link_type_value_id
			, link_active 
	FROM #form_xml
	
	DECLARE @new_id VARCHAR(100) 
	SET @new_id = CAST(SCOPE_IDENTITY() AS VARCHAR(10))
	
	INSERT INTO fas_link_detail(
								link_id,
								source_deal_header_id,
								percentage_included,
								hedge_or_item,
								effective_date
							)
	
	SELECT @new_id,
		source_deal_header_id,
		percentage_included,
		hedge_or_item,
		effective_date
	FROM #grid_xml

	SET @link_description = 'Hedging relationship for type: ' + @new_id +' created on: ' + CAST(GETDATE() AS VARCHAR(50))

	SELECT @link_description = ISNULL(NULLIF(link_description,''), @link_description) FROM fas_link_header flh WHERE link_id = @new_id	

	UPDATE flh SET link_description = ISNULL(NULLIF(link_description,''), @link_description) FROM fas_link_header flh WHERE link_id = @new_id
	
	SET @output = @new_id + ';' + @link_description	
	IF @@ERROR <> 0  
	EXEC spa_ErrorHandler @@ERROR, 'Fas Link header table',   
		'spa_faslinkheader', 'DB Error',   
		'Failed to insert Fas Link Header data.', ''  
	ELSE  
	EXEC spa_ErrorHandler 0, 'Fas Link Header Table',   
		'spa_faslinkheader','Success',   
		'Fas Link Header Data successfully Inserted.', @output		
END
ELSE IF @flag = 'u'
BEGIN

	BEGIN TRY
	BEGIN TRAN
	DECLARE @prior_link_active CHAR(1) = NULL 

	SELECT @link_description = ISNULL(NULLIF(fd.link_description,''), 'Hedging relationship for type: ' + fd.link_id  +' updated on: ' + CAST(GETDATE() AS VARCHAR(50))) FROM fas_link_header flh 
	INNER JOIN #form_xml fd ON flh.link_id = fd.link_id 	

	SELECT @prior_link_active = flh.link_active 
	FROM fas_link_header flh  
	INNER JOIN #form_xml fd ON flh.link_id = fd.link_id 
 
	UPDATE flh
	SET fas_book_id = fd.fas_book_id
		, perfect_hedge = fd.perfect_hedge
		, fully_dedesignated = fd.fully_dedesignated
		, link_description = @link_description
		, eff_test_profile_id = fd.eff_test_profile_id
		, link_effective_date = fd.link_effective_date
		, link_type_value_id = fd.link_type_value_id
		, link_active = fd.link_active 
	FROM fas_link_header flh
	INNER JOIN #form_xml fd ON flh.link_id = fd.link_id 
	
	IF NOT EXISTS(SELECT 1 FROM #grid_xml)
	BEGIN
		DELETE FROM fas_link_detail
		WHERE link_id = @link_id
		
		DELETE FROM fas_link_detail_dicing WHERE link_id = @link_id
	END
	ELSE
	BEGIN
		MERGE fas_link_detail AS T
		USING #grid_xml AS S
		ON (T.fas_link_detail_id = S.fas_link_detail_id) 
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(link_id, source_deal_header_id, percentage_included, hedge_or_item, effective_date) 
			VALUES(S.link_id, S.source_deal_header_id, S.percentage_included, S.hedge_or_item, S.effective_date)
		WHEN MATCHED THEN 
		UPDATE SET T.source_deal_header_id = S.source_deal_header_id
			, T.percentage_included = S.percentage_included
			, T.hedge_or_item = S.hedge_or_item
			, T.effective_date = S.effective_date
		WHEN NOT MATCHED BY SOURCE AND T.link_id= @link_id THEN 
		DELETE;
		
		--Delete from fas_link_detail_dicing
		MERGE fas_link_detail_dicing AS T
		USING #grid_xml AS S
		ON (T.link_id = S.link_id AND T.source_deal_header_id = S.source_deal_header_id ) 
		WHEN NOT MATCHED BY SOURCE AND T.link_id= @link_id THEN 
		DELETE;
	END
	IF @prior_link_active = 'y'
	BEGIN  
		---Update percentage included of all detail to 0 if the link is made inactive  		
		UPDATE fld
		SET fld.percentage_included = 0
		FROM fas_link_detail fld
		INNER JOIN fas_link_header flh ON flh.link_id = fld.link_id 
		INNER JOIN #form_xml fd ON flh.link_id = fd.link_id AND fd.link_active = 'n'		
	END
	COMMIT

	SET @output = CAST(@link_id AS VARCHAR(20)) + ';' + @link_description	
	EXEC spa_ErrorHandler 0, 'Fas Link Header Table',   
		'spa_faslinkheader', 'Success',   
		'Fas Link Header Data successfully updated.', @output  
	
	END TRY
	BEGIN CATCH
		ROLLBACK		
	
		EXEC spa_ErrorHandler @@ERROR, 'Fas Link header table',   
			'spa_faslinkheader', 'DB Error',   
			'Failed to update Fas Link Header data.', ''  
	
	END CATCH 
END

				
				
				
				