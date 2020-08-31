
IF OBJECT_ID(N'[dbo].[spa_interface_edi_report]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_interface_edi_report]
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
CREATE PROCEDURE [dbo].[spa_interface_edi_report]
    @flag CHAR(1),
    @process_id VARCHAR(200)
AS

SET NOCOUNT ON

/*
	DECLARE @flag CHAR(1) = 's'
	DECLARE @process_id VARCHAR(300) = '7517011A_E33F_42CF_983A_2F5C0DF14615'
--*/
 
DECLARE @SQL VARCHAR(MAX)
DECLARE @thread_info_detail VARCHAR(300), 
		@unthread_info_detail VARCHAR(300),
		@thread_info_summary VARCHAR(300),
		@unthread_info_summary VARCHAR(300)
DECLARE @sql_stm VARCHAR(MAX) 
DECLARE @sql_continue VARCHAR(MAX)

IF OBJECT_ID('tempdb..#SLN_List') IS NOT NULL
DROP TABLE #SLN_List

CREATE TABLE #SLN_List(SLN_ID INT)

SET @thread_info_detail = dbo.FNAProcessTableName('thread_info_detail', 'system', @process_id)
SET @unthread_info_detail = dbo.FNAProcessTableName('unthread_info_detail', 'system', @process_id)
SET @thread_info_summary = dbo.FNAProcessTableName('thread_info_summary', 'system', @process_id)
SET @unthread_info_summary = dbo.FNAProcessTableName('unthread_info_summary', 'system', @process_id)
 
IF OBJECT_ID('tempdb..#temp_status') IS NOT NULL
	DROP TABLE #temp_status

CREATE TABLE #temp_status ([Alert] VARCHAR(16) COLLATE DATABASE_DEFAULT)

SET @sql_stm = ' 
		IF NOT EXISTS (SELECT 1 FROM adiha_process.sys.objects WHERE [type] = ''u'' AND [name] = ''' + @thread_info_detail + ''')
		BEGIN
			INSERT INTO #temp_status
			SELECT ''No Record Found.''	status
		END 
		IF NOT EXISTS (SELECT 1 FROM adiha_process.sys.objects WHERE [type] = ''u'' AND [name] = ''' + @unthread_info_detail + ''')
		BEGIN
			INSERT INTO #temp_status
			SELECT ''No Record Found.''	status
		END
		IF NOT EXISTS (SELECT 1 FROM adiha_process.sys.objects WHERE [type] = ''u'' AND [name] = ''' + @thread_info_summary + ''')
		BEGIN
			INSERT INTO #temp_status
			SELECT ''No Record Found.''	status
		END 
		IF NOT EXISTS (SELECT 1 FROM adiha_process.sys.objects WHERE [type] = ''u'' AND [name] = ''' + @unthread_info_summary + ''')
		BEGIN
			INSERT INTO #temp_status
			SELECT ''No Record Found.''	status
		END
		'
EXEC(@sql_stm)

IF EXISTS (SELECT 1 FROM #temp_status)
BEGIN
	SELECT DISTINCT * FROM #temp_status
	RETURN
END

SET @sql_stm = ' INSERT INTO #SLN_List(sln_id)
Select  
  SUBSTRING(description , CHARINDEX(''-'', description )+1, LEN(description )-CHARINDEX(''-'', description )-CHARINDEX(''-'',REVERSE(description  ))) SLN_ID FROM source_system_data_import_status_detail where process_id = '''+@process_id+''' AND description LIKE ''SLN%'' '
 --PRINT(@sql_stm)
EXEC(@sql_stm)
  

IF @flag = 'd'
BEGIN
    SET @sql = '
		SELECT dbo.FNADateFormat(i.term_start) [Flow Date],
			   ''Pathed (Threaded)'' [Type],
			   CASE 
					WHEN udf_tran_type = ''07'' THEN ''07 - Storage Withdrawal''
					WHEN udf_tran_type = ''06'' THEN ''06 - Storage Injection''
					ELSE ''01 - Current Business''
			   END TOS, 
			   ''<span style="cursor: pointer;" onclick="parent.parent.parent.TRMHyperlink(10131010,''+ REPLACE(i.source_deal_header_id, ''-'', '''') +'',''''n'''',''''NULL'''')"><font color="#0000ff"><u>''+ REPLACE(i.source_deal_header_id, ''-'', '''') + ''</u></font></span>'' [Deal ID],
			   i.source_deal_header_id [Package ID],
			   sml.Location_id + '' - '' + sml.Location_Name [Receipt Location],
			   sml2.Location_id + '' - '' + sml2.Location_Name [Delivery Location],
			   leg_1_tsp_location [Receipt Location(DR)],
			   leg_2_tsp_location [Delivery Location(DR)],			   
			   sc.counterparty_id [Counterparty ID],
			   sc.customer_duns_number [Counterparty(Duns)],
			   i.contract_id [Contract],
			   leg_1_loc_rank [Rec Rank],
			   leg_2_loc_rank [Del Rank],			   			   
			   dbo.FNARemoveTrailingZero(dbo.FNAPipelineRound(1, i.deal_volume, 0)) Position
		FROM ' + @thread_info_detail + ' i
		LEFT JOIN source_counterparty sc ON  i.counterparty_id = sc.source_counterparty_id
		left join source_minor_location sml on sml.source_minor_location_id= i.leg_1_location_id 
		left join source_major_location sjl on sjl.source_major_location_id= sml.source_major_location_id 
		left join source_minor_location sml2 on sml2.source_minor_location_id= i.leg_2_location_id 
		left join source_major_location sjl2 on sjl2.source_major_location_id= sml2.source_major_location_id 

		UNION ALL
		SELECT dbo.FNADateFormat(i.term_start) [Flow Date],
			   ''Unthreaded '' + CASE 
									WHEN i.contract_steam = ''UP'' THEN ''Receipt''
									ELSE ''Delivery''
							   END [Type],
			   CASE 
					WHEN i.udf_tran_type = ''07'' THEN ''07 - Storage Withdrawal''
					WHEN i.udf_tran_type = ''06'' THEN ''06 - Storage Injection''
					ELSE ''01 - Current Business''
			   END TOS,
			   ''<span style="cursor: pointer;" onclick="parent.parent.parent.TRMHyperlink(10131010,''+ REPLACE(i.unthread_deal_id, ''-'', '''') +'',''''n'''',''''NULL'''')"><font color="#0000ff"><u>''+ REPLACE(i.unthread_deal_id, ''-'', '''') + ''</u></font></span>'' [Deal ID],
			   i.source_deal_header_id [Package ID],			   
			   sml.Location_id + '' - '' + sml.Location_Name [Receipt Location],
			   sml2.Location_id + '' - '' + sml2.Location_Name [Delivery Location],
			   CASE WHEN unthread_type = ''R'' THEN unthread_tsp_location ELSE NULL END [Receipt Location(DR)],
			   CASE WHEN unthread_type = ''D'' THEN unthread_tsp_location ELSE NULL END [Delivery Location(DR)],
			   CASE WHEN unthread_type = ''R'' THEN sc.counterparty_id ELSE sc_qpc.counterparty_id END [Counterparty ID],
			   i.customer_duns_number [Counterparty(Duns)],			   
			   i.unthread_contract_id [Contract],
			   CASE WHEN unthread_type = ''R'' THEN unthread_location_rank ELSE NULL END [Rec Rank],
			   CASE WHEN unthread_type = ''D'' THEN unthread_location_rank ELSE NULL END [Del Rank],			   			   
			   dbo.FNARemoveTrailingZero(i.deal_volume) Position
		FROM ' + @unthread_info_detail + ' i
		INNER JOIN optimizer_detail od ON od.optimizer_detail_id = REPLACE(i.source_deal_detail_id, ''-'', '''')
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = REPLACE(od.source_deal_detail_id, ''-'', '''')
		INNER JOIN source_counterparty sc_qpc ON sc_qpc.source_counterparty_id = 5234
		LEFT JOIN dbo.source_counterparty sc ON  sc.source_counterparty_id = ISNULL(NULLIF(i.counterparty_id, 5198), 5234)		
		left join source_minor_location sml on sml.source_minor_location_id = sdd.location_id AND i.unthread_type = ''R'' 
		left join source_minor_location sml2 on sml2.source_minor_location_id = sdd.location_id AND i.unthread_type = ''D''

	'
	--PRINT(@sql)
	EXEC(@sql)
END
ELSE IF @flag = 's'
BEGIN
	 SET @sql = '
		SELECT DISTINCT
								CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END + dbo.FNADateFormat(i.term_start) +  CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END   [Flow Date],
						CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END +  ''Pathed (Threaded)'' +  CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END   [Type],
						CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END + 
									   CASE 
											WHEN udf_tran_type = ''07'' THEN ''07 - Storage Withdrawal''
											WHEN udf_tran_type = ''06'' THEN ''06 - Storage Injection''
											ELSE ''01 - Current Business''
									   END 
						+  CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END 			   
									   TOS, 
						CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END +			   REPLACE(i.source_deal_header_id, ''-'', '''') +  CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END [Deal ID],
						CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END +			   i.source_deal_header_id +  CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END  [Package ID],
						CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END +			   sml.Location_id + '' - '' + sml.Location_Name +  CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END  [Receipt Location],
						CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END +			   sml2.Location_id + '' - '' + sml2.Location_Name  +  CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END [Delivery Location],
						CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END +			   leg_1_tsp_location +  CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END [Receipt Location(DR)],
						CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END +			   leg_2_tsp_location +  CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END [Delivery Location(DR)],			   
						CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END +			   sc.counterparty_id +  CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END [Counterparty ID],
						CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END +			   sc.customer_duns_number +  CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END [Counterparty(Duns)],
						CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END +			   i.contract_id +  CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END [Contract],
						CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END +			   leg_1_loc_rank +  CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END [Rec Rank],
						CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END +			   leg_2_loc_rank +  CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END [Del Rank],			   			   
						CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END +			   i.deal_volume +  CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END Position
		FROM ' + @thread_info_summary + ' i
		LEFT JOIN source_counterparty sc ON  i.counterparty_id = sc.source_counterparty_id
		left join source_minor_location sml on sml.source_minor_location_id= i.leg_1_location_id 
		left join source_major_location sjl on sjl.source_major_location_id= sml.source_major_location_id 
		left join source_minor_location sml2 on sml2.source_minor_location_id= i.leg_2_location_id 
		left join source_major_location sjl2 on sjl2.source_major_location_id= sml2.source_major_location_id 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id  = i.source_deal_header_id
		LEFT JOIN #SLN_List sln ON sln.sln_id = sdd.source_deal_detail_id
		UNION ALL'

SET @sql_continue  = ' SELECT 
			CASE WHEN sln.sln_id IS NOT NULL THEN 
				''<font color="red">'' ELSE '''' END + dbo.FNADateFormat(i.term_start) +  
			CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END [Flow Date],
			CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END 
				+   ''Unthreaded '' +
				 CASE 
					WHEN i.contract_steam = ''UP'' THEN ''Receipt''
					ELSE ''Delivery''
				END  + 
				CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END [Type],
				CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END 
			   +CASE 
					WHEN i.udf_tran_type = ''07'' THEN ''07 - Storage Withdrawal''
					WHEN i.udf_tran_type = ''06'' THEN ''06 - Storage Injection''
					ELSE ''01 - Current Business''
			   END +
			   CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END
			   TOS,
			 	CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END +
			   REPLACE(i.unthread_deal_id, ''-'', '''') +
			   CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END [Deal ID],
			  	CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END 
			  + i.unthread_deal_id +
			  CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END
			   [Package ID],
			   CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END + 			   
			   sml.Location_id + '' - '' + sml.Location_Name +
			   CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END [Receipt Location],
			   CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END + 
			   sml2.Location_id + '' - '' + sml2.Location_Name  +
			   CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END [Delivery Location],
			    CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END +
				CASE WHEN unthread_type = ''R'' THEN unthread_tsp_location ELSE NULL END  +
				CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END [Receipt Location(DR)],
			    CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END +
				CASE WHEN unthread_type = ''D'' THEN unthread_tsp_location ELSE NULL END +
				CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END [Delivery Location(DR)],
			    CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END +
				CASE WHEN unthread_type = ''R'' THEN sc.counterparty_id ELSE sc_qpc.counterparty_id END 
				 +CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END[Counterparty ID],
			    CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END +
				i.customer_duns_number +
				CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END [Counterparty(Duns)],			   
			    CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END +
				i.unthread_contract_id +
				CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END[Contract],
			    CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END
				 +CASE WHEN unthread_type = ''R'' THEN unthread_location_rank ELSE NULL END
				  +CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END [Rec Rank],
			   CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END 
			   +CASE WHEN unthread_type = ''D'' THEN unthread_location_rank ELSE NULL END +
			   CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END [Del Rank],				   			   
			   CASE WHEN sln.sln_id IS NOT NULL THEN ''<font color="red">'' ELSE '''' END +
			   i.deal_volume+CASE WHEN sln.sln_id IS NOT NULL THEN ''</font>'' ELSE '''' END
		FROM ' + @unthread_info_summary + ' i		
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = i.source_deal_header_id
		INNER JOIN optimizer_detail od ON od.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN source_counterparty sc_qpc ON sc_qpc.source_counterparty_id = 5234
		LEFT JOIN dbo.source_counterparty sc ON  sc.source_counterparty_id = ISNULL(NULLIF(i.counterparty_id, 5198), 5234)
		left join source_minor_location sml on sml.source_minor_location_id = sdd.location_id AND i.unthread_type = ''R'' AND sdd.leg = 1 
		left join source_minor_location sml2 on sml2.source_minor_location_id = sdd.location_id AND i.unthread_type = ''D''  AND sdd.leg = 2
		LEFT JOIN #SLN_List sln ON sln.SLN_ID = od.optimizer_detail_id
	'
	--PRINT(@sql)
	--PRINT(@sql_continue)
	EXEC(@sql+@sql_continue)
END
