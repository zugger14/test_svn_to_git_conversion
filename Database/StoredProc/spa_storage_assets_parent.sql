/************************************************************
 * Code formatted by SoftTree SQL Assistant © v9.1.261
 * Time: 2/9/2018 7:00:45 PM
 ************************************************************/

IF OBJECT_ID(N'[dbo].[spa_storage_asset_parent]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_storage_asset_parent]
GO

-- ===========================================================================================================
-- Author: bmaharjan@pioneersolutionsglobal.com
-- Create date: 2015-05-27
-- Description: CRUD operation for Counterparty Invoice
 
-- Params:
-- @flag     CHAR - Operation flag

-- ===========================================================================================================

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_storage_asset_parent]
	@flag CHAR(1),
	@storage_asset_id VARCHAR(100) = NULL,
	@asset_xml TEXT = NULL,
	@effective_date VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @idoc INT
	IF @flag IN ('i', 'u')
	BEGIN	
		EXEC sp_xml_preparedocument @idoc OUTPUT,
			 @asset_xml
	
		IF OBJECT_ID('tempdb..#temp_asset_form') IS NOT NULL
			DROP TABLE #temp_asset_form
	
		SELECT storage_asset_id      storage_asset_id,
			   asset_name         asset_name,
			   asset_description  asset_description,
			   commodity_id          commodity_id,
			   location_id           location_id
		INTO   #temp_asset_form
		FROM   OPENXML(@idoc, '/FormXML', 1)
			   WITH (
				   storage_asset_id VARCHAR(10) '@storage_asset_id',
				   asset_name VARCHAR(200) '@asset_name',
				   asset_description VARCHAR(200) '@asset_description',
				   commodity_id INT '@commodity_id',
				   location_id INT '@location_id'
			   )	
	
		IF @flag = 'i'
		BEGIN
			INSERT INTO storage_asset
			  (
				asset_name,
				asset_description,
				commodity_id,
				location_id
			  )
			SELECT asset_name,
				   asset_description,
				   commodity_id,
				   location_id
			FROM   #temp_asset_form AS taf
	    
			SET @storage_asset_id = CAST(SCOPE_IDENTITY() AS VARCHAR) + '_parent';

			EXEC spa_ErrorHandler 0,
				 'storage asset parent',
				 'spa_storage_assets_parent',
				 'Success',
				 'Changes have been saved successfully.',
				 @storage_asset_id	
	   
		END
		ELSE IF @flag = 'u'
		BEGIN
			UPDATE sa			  
			SET asset_name = taf.asset_name ,
			asset_description = taf.asset_description,
			commodity_id = taf.commodity_id,
			location_id = taf.location_id
			FROM  storage_asset sa
			INNER JOIN #temp_asset_form AS taf
				ON sa.storage_asset_id = taf.storage_asset_id
			Where sa.storage_asset_id = @storage_asset_id
	    	
			SET @storage_asset_id = CAST(@storage_asset_id AS VARCHAR) + '_parent'

			EXEC spa_ErrorHandler 0,
				 'storage asset parent',
				 'spa_storage_assets_parent',
				 'Success',
				 'Changes have been saved successfully.',
				 @storage_asset_id
		END		
	END
	ELSE IF @flag = 'c'
	BEGIN
		DECLARE @sql VARCHAR(MAX) = NULL
		IF NULLIF(@effective_date,'') IS NOT NULL
		BEGIN
		SET @sql = ' SELECT DISTINCT storage_asset_capacity_id, sac.effective_date, reservoir, reservoir_type, sac.capacity, uom 
						FROM
						(SELECT MAX(sac.effective_date) effective_date, MAX(sac.storage_asset_id) storage_asset_id
							FROM storage_asset_capacity sac
							INNER JOIN storage_asset sa 
							ON sa.storage_asset_id = sac.storage_asset_id
							WHERE REPLACE(sa.asset_name,'' '','''') = ''' + @storage_asset_id + ''''
							+ ' AND sac.effective_date <= ''' + @effective_date + '''
						GROUP BY reservoir,sac.storage_asset_id
						) tbl
						INNER JOIN storage_asset_capacity sac
							ON sac.effective_date =tbl.effective_date
							AND sac.storage_asset_id = tbl.storage_asset_id'
		END
		ELSE
		BEGIN
			SET @sql = ' SELECT DISTINCT storage_asset_capacity_id, sac.effective_date, reservoir, reservoir_type, sac.capacity, uom 
					 FROM storage_asset_capacity	sac		
					 INNER JOIN storage_asset sa 
					 	ON sa.storage_asset_id = sac.storage_asset_id
					 WHERE REPLACE(sa.asset_name,'' '','''') = ''' + @storage_asset_id + ''''
		END
		--print @sql
		EXEC(@sql)
	END
	ELSE IF @flag = 's'
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT, @asset_xml
	
		CREATE TABLE #temp_storage_asset_capacity(							
			reservoir VARCHAR(10) COLLATE database_default,
			reservoir_type VARCHAR(10) COLLATE database_default,
			effective_date VARCHAR(10) COLLATE database_default, 
			capacity VARCHAR(100) COLLATE database_default, 
			uom VARCHAR(10) COLLATE database_default,
			storage_asset VARCHAR(100) COLLATE database_default
		)
		
		INSERT INTO #temp_storage_asset_capacity(											
			reservoir,
			reservoir_type,
			effective_date,
			capacity,
			uom,
			storage_asset 
		)
		SELECT NULLIF(reservoir, ''),
			   NULLIF(reservoir_type, ''),
			   NULLIF(effective_date, ''),
			   NULLIF(capacity, ''),
			   NULLIF(uom, ''),
			   NULLIF(storage_asset, '')				
		FROM   OPENXML (@idoc, '/Grid/GridRow', 2)
		WITH (	
				reservoir VARCHAR(100) '@reservoir', 
				reservoir_type VARCHAR(10) '@reservoir_type',
				effective_date VARCHAR(10) '@effective_date',
				capacity VARCHAR(10) '@capacity',
				uom VARCHAR(10) '@uom',
				storage_asset VARCHAR(100) '@storage_asset'
		)

		DELETE 
		FROM storage_asset_capacity
		WHERE storage_asset_id = @storage_asset_id

		INSERT INTO storage_asset_capacity (reservoir, reservoir_type, effective_date, capacity, uom, storage_asset_id)
		SELECT temp.reservoir,
			   temp.reservoir_type,
			   temp.effective_date,
			   temp.capacity,
			   temp.uom,
			   sa.storage_asset_id
		FROM #temp_storage_asset_capacity temp
		INNER JOIN storage_asset sa
			ON REPLACE(sa.asset_name,' ','') =  temp.storage_asset

		EXEC spa_ErrorHandler 0,
				'storage asset parent',
				'spa_storage_assets_parent',
				'Success',
				'Changes have been saved successfully.',
				'parent'	
	END

	ELSE IF @flag = 'k'
	BEGIN
		 SELECT SUM(sac.capacity) [total_capacity]
			FROM
			(SELECT MAX(sac.effective_date) effective_date, MAX(sac.storage_asset_id) storage_asset_id
				FROM storage_asset_capacity sac
				INNER JOIN storage_asset sa 
				ON sa.storage_asset_id = sac.storage_asset_id
				WHERE REPLACE(sa.asset_name,' ','')	= @storage_asset_id
			AND sac.effective_date <= @effective_date
			GROUP BY reservoir,sac.storage_asset_id
			) tbl
			INNER JOIN storage_asset_capacity sac
				ON sac.effective_date =tbl.effective_date
				AND sac.storage_asset_id = tbl.storage_asset_id

	END
END