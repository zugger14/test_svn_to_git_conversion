IF OBJECT_ID(N'[dbo].[spa_etag_detail]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_etag_detail]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2008-09-09
-- Description: Description of the functionality in brief.
 
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_etag_detail]
    @flag CHAR(1),
    @as_of_date DATETIME = NULL,
    @xml XML = NULL
    
AS
SET NOCOUNT ON
DECLARE @sql VARCHAR(MAX)
DECLARE @DESC VARCHAR(1000)
DECLARE @idoc INT
 
IF @flag = 'u'
BEGIN
	BEGIN TRY				
		/*	
		DECLARE @idoc INT	
		DECLARE @xml XML
		DECLARE @as_of_date DATETIME = '2012-08-01'
		SET @xml = '
		<Root>
			<PSRecordset  oati_tag_id="ABCDEFGHIJKL" etag_id="ABCDEFGHIJKL" id="1" matched_deal="6389" hr1="44856" hr2="44801" hr3="44251" hr4="45499" hr5="43538" hr6="44292" hr7="44235" hr8="44940" hr9="44226" hr10="" hr11="" hr12="" hr13="" hr14="" hr15="" hr16="" hr17="" hr18="" hr19="" hr20="" hr21="" hr22="" hr23="" hr24="" hr25="" ></PSRecordset>
		</Root>'
		*/	
			--Create an internal representation of the XML document.
		EXEC sp_xml_preparedocument @idoc OUTPUT,@xml

		-- Create temp table to store the report_name and report_hash
		IF OBJECT_ID('tempdb..#temp_etag') IS NOT NULL
			DROP TABLE #temp_etag
		
		IF OBJECT_ID('tempdb..#temp_etag_unpivot') IS NOT NULL
			DROP TABLE #temp_etag_unpivot

		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		SELECT  oati_tag_id, [id], 
				NULLIF([hr1], '') [hr1], NULLIF([hr2], '') [hr2], NULLIF([hr3], '') [hr3], NULLIF([hr4], '') [hr4], NULLIF([hr5], '') [hr5], 
				NULLIF([hr6], '') [hr6], NULLIF([hr7], '') [hr7], NULLIF([hr8], '') [hr8], NULLIF([hr9], '') [hr9], NULLIF([hr10], '') [hr10], 
				NULLIF([hr11], '') [hr11], NULLIF([hr12], '') [hr12], NULLIF([hr13], '') [hr13], NULLIF([hr14], '') [hr14], NULLIF([hr15], '') [hr15], 
				NULLIF([hr16], '') [hr16], NULLIF([hr17], '') [hr17], NULLIF([hr18], '') [hr18], NULLIF([hr19], '') [hr19], NULLIF([hr20], '') [hr20], 
				NULLIF([hr21], '') [hr21], NULLIF([hr22], '') [hr22], NULLIF([hr23], '') [hr23], NULLIF([hr24], '') [hr24], NULLIF([hr25], '') [hr25]
		INTO #temp_etag
		FROM OPENXML(@idoc, '/Root/PSRecordset', 1)
		WITH (
			oati_tag_id VARCHAR(500), [id] VARCHAR(10),
			[hr1] VARCHAR(50), [hr2] VARCHAR(50), [hr3] VARCHAR(50), [hr4] VARCHAR(50), [hr5] VARCHAR(50),
			[hr6] VARCHAR(50), [hr7] VARCHAR(50), [hr8] VARCHAR(50), [hr9] VARCHAR(50), [hr10] VARCHAR(50),
			[hr11] VARCHAR(50), [hr12] VARCHAR(50), [hr13] VARCHAR(50), [hr14] VARCHAR(50), [hr15] VARCHAR(50),
			[hr16] VARCHAR(50), [hr17] VARCHAR(50), [hr18] VARCHAR(50), [hr19] VARCHAR(50), [hr20] VARCHAR(50),
			[hr21] VARCHAR(50), [hr22] VARCHAR(50), [hr23] VARCHAR(50), [hr24] VARCHAR(50), [hr25] VARCHAR(50)
		)
		
		SELECT oati_tag_id,
		       id,
			   @as_of_date [term],
		       CAST(REPLACE([hour], 'hr', '') AS INT) [hrs],
		       etag_value
		INTO #temp_etag_unpivot
		FROM #temp_etag
		UNPIVOT(
		    etag_value FOR [hour] IN (hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, 
		                                    hr9, hr10, hr11, hr12, hr13, hr14, 
		                                    hr15, hr16, hr17, hr18, hr19, hr20, 
		                                    hr21, hr22, hr23, hr24, hr25)
		) UnPivo
		
		UPDATE etd
		SET etag_value = temp_etd.etag_value
		FROM etag_detail AS etd
		INNER JOIN dbo.etag AS e ON e.etag_id = etd.etag_id
		INNER JOIN #temp_etag_unpivot temp_etd
			ON  temp_etd.id = e.etag_id
			AND etd.term = @as_of_date
			AND etd.hrs = temp_etd.hrs
		
		INSERT INTO etag_detail (etag_id, term, hrs, etag_value)
		SELECT DISTINCT 
			   e.etag_id,
		       @as_of_date,
		       CAST(temp_et.hrs AS INT),
		       CAST(temp_et.etag_value AS FLOAT)
		FROM   #temp_etag_unpivot temp_et
		INNER JOIN dbo.etag AS e ON  e.oati_tag_id = temp_et.oati_tag_id
		LEFT JOIN etag_detail  AS etd
		    ON  temp_et.id = etd.etag_id
		    AND etd.term = @as_of_date
		    AND etd.hrs = temp_et.hrs
		WHERE etd.etag_detail_id IS NULL AND temp_et.etag_value IS NOT NULL
		
		EXEC spa_ErrorHandler 0,
			 'etag_detail',
			 'spa_etag_detail',
			 'Success',
			 'E-tag detail saved sucessfully.',
			 ''		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		EXEC spa_ErrorHandler -1,
			 'etag_detail',
			 'spa_etag_detail',
			 'Error',
			 @DESC,
			 ''
	END CATCH	
END

IF @flag = 'x'
BEGIN
	BEGIN TRY				
		/*
		DECLARE @idoc INT	
		DECLARE @xml XML
		SET @xml = '
		<Root>
		  <PSRecordset  etag_id="1" oati_tag_id="ABCDEFGHIJKL" control_areas="" transmission_providers="" pse="" point_of_receipt="" point_of_delivery="" scheduling_entity="" ></PSRecordset>
		  <PSRecordset  etag_id="2323232" oati_tag_id="RAZIV" control_areas="" transmission_providers="" pse="" point_of_receipt="" point_of_delivery="" scheduling_entity="" ></PSRecordset>
		</Root>'
		--*/	
			--Create an internal representation of the XML document.
		EXEC sp_xml_preparedocument @idoc OUTPUT,@xml

		-- Create temp table to store the report_name and report_hash
		IF OBJECT_ID('tempdb..#temp_etag_data') IS NOT NULL
			DROP TABLE #temp_etag_data
		

		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		SELECT  NULLIF(etag_id, '') etag_id, 
				NULLIF([oati_tag_id], '') [oati_tag_id],
				NULLIF([control_areas], '') [control_areas], 
				NULLIF([transmission_providers], '') [transmission_providers], 
				NULLIF([pse], '') [pse], 
				NULLIF([point_of_receipt], '') [point_of_receipt], 
				NULLIF([point_of_delivery], '') [point_of_delivery],
				NULLIF([scheduling_entity], '') [scheduling_entity]
		INTO #temp_etag_data
		FROM OPENXML(@idoc, '/Root/PSRecordset', 1)
		WITH (
			etag_id VARCHAR(50), 
			[oati_tag_id] VARCHAR(500),
			[control_areas] VARCHAR(50), 
			[transmission_providers] VARCHAR(50), 
			[pse] VARCHAR(50), 
			[point_of_receipt] VARCHAR(50), 
			[point_of_delivery] VARCHAR(50),
			[scheduling_entity] VARCHAR(50)
		)
		
		UPDATE et
		SET oati_tag_id = temp_et.oati_tag_id,
			control_areas = temp_et.[control_areas],
			transmission_providers = temp_et.transmission_providers,
			pse = temp_et.pse,
			point_of_receipt = temp_et.point_of_receipt,
			point_of_delivery = temp_et.point_of_delivery,
			scheduling_entity = temp_et.scheduling_entity
		FROM etag et
		INNER JOIN #temp_etag_data temp_et ON  temp_et.etag_id = et.etag_id		
		
		INSERT INTO etag (oati_tag_id, control_areas, transmission_providers, pse, point_of_receipt, point_of_delivery, scheduling_entity, match_status)
		SELECT temp_et.oati_tag_id,
		       temp_et.control_areas,
		       temp_et.transmission_providers,
		       temp_et.pse,
		       temp_et.point_of_receipt,
		       temp_et.point_of_delivery,
		       temp_et.scheduling_entity,
		       27202
		FROM #temp_etag_data temp_et
		LEFT JOIN etag et ON  temp_et.oati_tag_id = et.oati_tag_id
		WHERE  et.etag_id IS NULL

		EXEC spa_ErrorHandler 0,
			 'etag_detail',
			 'spa_etag_detail',
			 'Success',
			 'E-tag detail saved sucessfully.',
			 ''		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		EXEC spa_ErrorHandler -1,
			 'etag_detail',
			 'spa_etag_detail',
			 'Error',
			 @DESC,
			 ''
	END CATCH	
END