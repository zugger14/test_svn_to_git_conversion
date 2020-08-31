IF OBJECT_ID(N'[dbo].[spa_update_power_bidding_nomination]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_update_power_bidding_nomination
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2012-08-15
-- Description: Update report hourly position deal for power bidding and nomination
 
-- Params:
--  @flag CHAR(1) - Operation flag
-- @xmlValue VARCHAR(MAX), 
-- @process_id VARCHAR(MAX) = NULL

--EXEC spa_update_power_bidding_nomination 'u',
--     '<Root><PSRecordset  editGrid1="07-09-2012" editGrid2="1" editGrid3="0" editGrid4="3000" editGrid5="1.6" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="07-09-2012" editGrid2="2" editGrid3="0" editGrid4="3000" editGrid5="1.7" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="07-09-2012" editGrid2="3" editGrid3="0" editGrid4="3000" editGrid5="1.8" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="07-09-2012" editGrid2="4" editGrid3="0" editGrid4="3000" editGrid5="1.9" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="07-09-2012" editGrid2="5" editGrid3="0" editGrid4="3000" editGrid5="1.0" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="07-09-2012" editGrid2="6" editGrid3="0" editGrid4="3000" editGrid5="1" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="07-09-2012" editGrid2="7" editGrid3="0" editGrid4="3000" editGrid5="1.9" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="07-09-2012" editGrid2="8" editGrid3="0" editGrid4="3000" editGrid5="1.3888888888889" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="07-09-2012" editGrid2="9" editGrid3="0" editGrid4="3000" editGrid5="1.3888888888889" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="07-09-2012" editGrid2="10" editGrid3="0" editGrid4="3000" editGrid5="1.3888888888889" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="07-09-2012" editGrid2="11" editGrid3="0" editGrid4="3000" editGrid5="1.3888888888889" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="07-09-2012" editGrid2="12" editGrid3="0" editGrid4="3000" editGrid5="1.3888888888889" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="07-09-2012" editGrid2="13" editGrid3="0" editGrid4="3000" editGrid5="1.3888888888889" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="07-09-2012" editGrid2="14" editGrid3="0" editGrid4="3000" editGrid5="1.3888888888889" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="07-09-2012" editGrid2="15" editGrid3="0" editGrid4="3000" editGrid5="1.3888888888889" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="07-09-2012" editGrid2="16" editGrid3="0" editGrid4="3000" editGrid5="1.3888888888889" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="07-09-2012" editGrid2="17" editGrid3="0" editGrid4="3000" editGrid5="1.3888888888889" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="07-09-2012" editGrid2="18" editGrid3="0" editGrid4="3000" editGrid5="1.3888888888889" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="07-09-2012" editGrid2="19" editGrid3="0" editGrid4="3000" editGrid5="1.3888888888889" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="07-09-2012" editGrid2="20" editGrid3="0" editGrid4="3000" editGrid5="1.3888888888889" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="07-09-2012" editGrid2="21" editGrid3="0" editGrid4="3000" editGrid5="1.3888888888889" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="07-09-2012" editGrid2="22" editGrid3="0" editGrid4="3000" editGrid5="1.3888888888889" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="07-09-2012" editGrid2="23" editGrid3="0" editGrid4="3000" editGrid5="1.3888888888889" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="07-09-2012" editGrid2="24" editGrid3="0" editGrid4="3000" editGrid5="1.3888888888889" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="08-09-2012" editGrid2="1" editGrid3="0" editGrid4="3000" editGrid5="1.3888888888889" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="08-09-2012" editGrid2="2" editGrid3="0" editGrid4="3000" editGrid5="1.3888888888889" editGrid6="-3000"></PSRecordset><PSRecordset  editGrid1="08-09-2012" editGrid2="3" editGrid3="0" editGrid4="3000" editGrid5="1.3888888888889" editGrid6="-3000"></PSRecordset></Root>',
--     '6F684506_41A3_4A37_9FBF_C253F1F469B8'
-- ===========================================================================================================
CREATE PROCEDURE [dbo].spa_update_power_bidding_nomination
    @flag CHAR(1),
    @xmlValue VARCHAR(MAX), 
    @process_id VARCHAR(MAX) = NULL
AS
 
DECLARE @SQL VARCHAR(MAX)
DECLARE @idoc INT

IF @flag = 'u'
BEGIN
	DROP TABLE tbl_xml_pbn
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlValue
	SELECT  term_start,
		       hr,
		       buy_volume,
		       buy_price,
		       sell_volume,
		       sell_price 
	INTO tbl_xml_pbn
	FROM   OPENXML(@idoc, '/Root/PSRecordset', 1) 
		WITH (
			term_start VARCHAR(50) '@editGrid1',
			hr int '@editGrid2',
			buy_volume FLOAT '@editGrid3',
			buy_price FLOAT '@editGrid4',
			sell_volume FLOAT '@editGrid5',
			sell_price FLOAT '@editGrid6'  
		)
	
	DECLARE @process_table_name VARCHAR(150)
	DECLARE @user_login_id VARCHAR(50)

	SET @user_login_id = dbo.FNADBUser()
	SET @process_table_name = dbo.FNAProcessTableName('batch_report', @user_login_id, @process_id)
	SET @sql = '
				UPDATE process_table 
				SET process_table.[MW Buy] = txp.buy_volume,
					process_table.[Buy Price] = txp.buy_price,
					process_table.[MW Sell] = txp.sell_volume,
					process_table.[Sell Price] = txp.sell_price
					 
	          --select *  
	          FROM ' + @process_table_name + ' process_table
				INNER JOIN tbl_xml_pbn txp ON process_table.[Term Start] = txp.term_start
					AND process_table.[APX Order] = txp.hr'
	EXEC spa_ErrorHandler 0
			, 'spa_update_power_bidding_nomination'
			, 'spa_update_power_bidding_nomination'
			, 'Success'
			, 'Data successfully updated.'
			, ''	
	EXEC spa_print @sql
	EXEC(@sql)
END