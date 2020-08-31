
IF OBJECT_ID(N'[dbo].[spa_check_conflicting_volume_split_nom]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_check_conflicting_volume_split_nom]
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
-- @@process_table VARCHAR(500)        - Process table
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_check_conflicting_volume_split_nom]
    @process_table VARCHAR(500),
    @from_meter CHAR(1) = NULL
AS

----EXEC spa_ixp_rules  @flag='t', @process_id='AABBC6EB_D2D9_4C25_9076_D55F1AAC06B9', @ixp_rules_id=1891, @run_table='adiha_process.dbo.temp_import_data_table_dv_AABBC6EB_D2D9_4C25_9076_D55F1AAC06B9', @source = '21400', @run_with_custom_enable = 'n'

----spa_ixp_generic_import_job 'adiha_process.dbo.ixp_deal_volume_template_0_sa_AABBC6EB_D2D9_4C25_9076_D55F1AAC06B9','ixp_deal_volume_template','AABBC6EB_D2D9_4C25_9076_D55F1AAC06B9','ImportData_1DE604C2_8A8B_48D5_BDB3_D946B5089FC3','n', 12, NULL, 'a',1891,'t', 'Deal Volume Import', NULL, NULL, 'n'

--DECLARE @process_table VARCHAR(500)
--SET @process_table = 'adiha_process.dbo.ixp_deal_volume_template_0_sa_AABBC6EB_D2D9_4C25_9076_D55F1AAC06B9'

IF OBJECT_ID('tempdb..#temp_process_table') IS NOT NULL
	DROP TABLE #temp_process_table

IF OBJECT_ID('tempdb..#temp_location_volume') IS NOT NULL
	DROP TABLE #temp_location_volume

IF OBJECT_ID('tempdb..#difference_in_volume') IS NOT NULL
	DROP TABLE #difference_in_volume

CREATE TABLE #temp_process_table (
	[term_start] VARCHAR(10) COLLATE DATABASE_DEFAULT
)

IF (@from_meter = 'y' OR @from_meter = 'w')
BEGIN
	EXEC('INSERT INTO #temp_process_table ([term_start]) 
	  SELECT MIN(temp.date)
	  FROM ' + @process_table + ' temp')
END
ELSE 
BEGIN
	EXEC('INSERT INTO #temp_process_table ([term_start]) 
	  SELECT MAX(temp.term_date)
	  FROM ' + @process_table + ' temp')
END	


CREATE TABLE #temp_location_volume (route_id INT, gathering_loc INT, delivery_loc INT, primary_secondary CHAR(1) COLLATE DATABASE_DEFAULT, group_id INT, volume FLOAT, contract_id INT)
DECLARE @term_date VARCHAR(10)

SELECT @term_date = MAX(term_start)
FROM #temp_process_table

IF (@from_meter = 'w')
BEGIN
	CREATE TABLE #temp_location (route_id INT, gathering_loc INT, delivery_loc INT, primary_secondary CHAR(1) COLLATE DATABASE_DEFAULT, group_id INT, volume FLOAT, contract_id INT)
	INSERT INTO #temp_location(route_id, gathering_loc, delivery_loc, primary_secondary, group_id, volume ,contract_id)
	EXEC spa_split_nom_volume 's',
				NULL,
				NULL,
				NULL,
				@term_date
	
	INSERT INTO #temp_location_volume(gathering_loc, delivery_loc, primary_secondary, volume, contract_id)
	EXEC('SELECT gathering_loc, delivery_loc, primary_secondary, volume, contract_id
	FROM #temp_location tl
	INNER JOIN ' +  @process_table + ' pt ON tl.gathering_loc = pt.source_minor_location_id
	')
END
ELSE
BEGIN
	INSERT INTO #temp_location_volume(route_id, gathering_loc, delivery_loc, primary_secondary, group_id, volume, contract_id)
	EXEC spa_split_nom_volume 's',
				NULL,
				NULL,
				NULL,
				@term_date
END

DECLARE @term_start VARCHAR(10)
DECLARE @term_end VARCHAR(10)

SET @term_start =  dbo.FNAGetSQLStandardDate(@term_date)
SET @term_end = CONVERT(VARCHAR(10), dbo.FNALastDayInDate(@term_start), 120)

;WITH cte as 
(
	SELECT @term_start [term_start], gathering_loc, delivery_loc, volume
	FROM #temp_location_volume
	WHERE primary_secondary = 'p'

	UNION ALL 

	SELECT CONVERT(VARCHAR(10), DATEADD(dd, 1, [term_start]), 120) [term_start], gathering_loc, delivery_loc, volume
	FROM cte
	WHERE DATEADD(dd, 1, [term_start]) <= @term_end
)
,
cte2 AS (
	SELECT CONVERT(VARCHAR(10), term_start, 120) [term_start], location_id, SUM(volume) [volume]
	FROM equity_gas_allocation
	WHERE CONVERT(VARCHAR(10), term_start, 120) <= @term_end AND CONVERT(VARCHAR(10), term_start, 120) >= @term_start
	GROUP BY location_id, term_start
)

SELECT  cte2.location_id, cte2.[term_start]
INTO #difference_in_volume
FROM cte 
INNER JOIN cte2 
	ON cte.gathering_loc = cte2.location_id
	AND cte.[term_start] = cte2.[term_start]
WHERE cte2.volume <> cte.volume

DECLARE @location_ids VARCHAR(1000)
SELECT distinct @location_ids = COALESCE(@location_ids + ',', '') + CAST(location_id AS VARCHAR(10))
FROM #difference_in_volume
--SET @location_ids = '6043,6044'
IF @location_ids IS NOT NULL
BEGIN
	DELETE ega
	FROM #temp_location_volume temp
	INNER JOIN dbo.SplitCommaSeperatedValues(@location_ids) i ON i.item = temp.gathering_loc
	INNER JOIN source_minor_location_nomination_group smlng on  smlng.source_minor_location_id=i.item
	INNER JOIN source_minor_location_nomination_group lgrp on lgrp.group_id = smlng.group_id and lgrp.info_type='n'
	INNER JOIN equity_gas_allocation ega ON ega.location_id = lgrp.source_minor_location_id
		AND ega.term_start BETWEEN @term_start AND @term_end 


	DECLARE @hyperlink VARCHAR(8000)
	DECLARE @user_login_id VARCHAR(200)
	DECLARE @process_id VARCHAR(400)
	DECLARE @job_name VARCHAR(600)
	SET @user_login_id = dbo.FNADBUser()
	SET @process_id = dbo.FNAGetNewID()
	SET @job_name = 'Split Nom Volume' + @process_id

	SET @hyperlink = 'Prior uploaded entitlement/volume does not match with the total volume split  to multiple locations. Please review and revise again.' + dbo.FNATrmHyperlink('k', 10163800, 'Click Here', @location_ids, @term_start, @term_end, DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)
	EXEC spa_message_board 'i', @user_login_id, NULL, 'Split Nom Volume',  @hyperlink, NULL, NULL, 's', @job_name, NULL, @process_id, NULL, 'n'
END
