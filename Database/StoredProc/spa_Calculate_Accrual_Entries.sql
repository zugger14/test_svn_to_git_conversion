IF OBJECT_ID(N'spa_Calculate_Accrual_Entries', N'P') IS NOT NULL
DROP PROC spa_Calculate_Accrual_Entries
GO


CREATE PROC [dbo].[spa_Calculate_Accrual_Entries] @process_id VARCHAR(50), 
 			@dedesignation_calc CHAR(1) , 
 			@as_of_date VARCHAR(10), 
 			@print_diagnostic INT = 0,
 			@user_login_id VARCHAR(50),
 			@what_if VARCHAR(1) = NULL,
 			@link_filter_id VARCHAR(5000) = NULL
 			
AS

--------------UNCOMMENT THE FOLLOWING TO TEST ---------------
-------------------------------------------------------------
/*
 DECLARE 	@process_id varchar(50), 
 			@dedesignation_calc char(1) , 
 			@as_of_date varchar(10), 
 			@print_diagnostic int,
 			@user_login_id varchar(50),
 			@what_if varchar(1),
 			@link_filter_id int
 
 SET @process_id = '123456'
 SET @dedesignation_calc = 'm'
 SET @print_diagnostic = 1
 SET @user_login_id = 'farrms_admin'
 SET @what_if = 'n'
 SET @link_filter_id = null -- 692
 select @as_of_date = dbo.FNAGetSQLStandardDate(max(as_of_date)) from adiha_process.dbo.calcprocess_deals_farrms_admin_123456


-- select hedge_or_item, sum(d_pnl) d_pnl from adiha_process.dbo.calcprocess_dollar_offset_farrms_admin_123  where link_id= 870 group by hedge_or_item

-- select * from adiha_process.dbo.calcprocess_dollar_offset_farrms_admin_123  where link_id= 870
-- select * from adiha_process.dbo.calcprocess_test_granularity_farrms_admin_123 where link_id= 870
-- select * from adiha_process.dbo.calcprocess_deals_final_farrms_admin_123 where link_id=613
-- select * from #rmv
-- select * from adiha_process.dbo.calcprocess_test_granularity_farrms_admin_123456

drop table adiha_process.dbo.calcprocess_dollar_offset_farrms_admin_123456
drop table adiha_process.dbo.calcprocess_test_granularity_farrms_admin_123456
drop table adiha_process.dbo.calcprocess_deals_final_farrms_admin_123456
drop table adiha_process.dbo.aocirelease_farrms_admin_123456
drop table #temp_count
drop table #links_reg 
drop table #hat
drop table #iat
drop table #aoci_hat
drop table #tt_hedge
drop table #tt_item
drop table #correction_value
drop table #t_expired
drop table #RMV
drop table #m_term
----drop table #l_max_term
--Inventory Hedge Change
drop table #reclassify_aoci
drop table #inventory_reclassify_aoci
drop table #tt_max_item
drop table #disallow_mismatch_link
drop table #same_pnl_sign
drop table #lock_pmtm_assmt_failed
--*/
--------------END OF UNCOMMENT THE FOLLOWING TO TEST ---------------
-------------------------------------------------------------

--select * from #same_pnl_sign

SET STATISTICS IO OFF
SET NOCOUNT OFF
SET ROWCOUNT 0

DECLARE @MTableName VARCHAR(200)
DECLARE @DealProcessTableName VARCHAR(200)
DECLARE @process_books VARCHAR(200)
DECLARE @DealProcessFinalTableName VARCHAR(200)
DECLARE @sqlSelect VARCHAR(MAX)
DECLARE @sqlSelect0 VARCHAR(MAX)
DECLARE @sqlSelect1 VARCHAR(MAX)
DECLARE @sqlSelect2 VARCHAR(MAX)
DECLARE @sqlSelect3 VARCHAR(MAX)
DECLARE @sqlSelect4 VARCHAR(MAX)
DECLARE @sqlSelect5 VARCHAR(MAX)
DECLARE @tempTestGranularity VARCHAR(200)
DECLARE @DollarOffsetTableName VARCHAR(200)
DECLARE @AOCIReleaseSchedule VARCHAR(200)
DECLARE @AOCIRelease VARCHAR(200)
DECLARE @rollfor_fix_pnl VARCHAR(20)
DECLARE @std_as_of_date VARCHAR(20)
DECLARE @std_contract_month VARCHAR(20)
DECLARE @std_last_run_date VARCHAR(20)
DECLARE @std_month_end VARCHAR(20)
DECLARE @as_of_date_between_stmt VARCHAR(100)
DECLARE @std_common_as_of_date VARCHAR(20)

DECLARE @log_increment 	INT
DECLARE @proc_begin_time DATETIME
DECLARE @DiscountTableName VARCHAR(200)

SET @proc_begin_time = GETDATE()

SET @AOCIRelease = dbo.FNAProcessTableName('aocirelease', @user_login_id, @process_id)
SET @DealProcessTableName = dbo.FNAProcessTableName('calcprocess_deals', @user_login_id, @process_id)
SET @DealProcessFinalTableName = dbo.FNAProcessTableName('calcprocess_deals_final', @user_login_id, @process_id)
SET @tempTestGranularity = dbo.FNAProcessTableName('calcprocess_test_granularity', @user_login_id, @process_id)
SET @DollarOffsetTableName = dbo.FNAProcessTableName('calcprocess_dollar_offset', @user_login_id, @process_id)
SET @AOCIReleaseSchedule = dbo.FNAProcessTableName('aocirelease_schedule', @user_login_id, @process_id)
SET @process_books = dbo.FNAProcessTableName('process_books', @user_login_id, @process_id)
SET @MTableName = dbo.FNAProcessTableName('max_term', @user_login_id, @process_id)
SET @DiscountTableName = dbo.FNAProcessTableName('calcprocess_discount_factor', @user_login_id, @process_id)

SET @std_as_of_date = dbo.FNAGetSQLStandardDate(@as_of_date)
SET @std_contract_month = dbo.FNAGetContractMonth(@as_of_date)

SET @std_month_end  = dbo.FNAGetSQLStandardDate(dbo.FNALastDayInDate(@as_of_date))
 
SET @as_of_date_between_stmt = ' BETWEEN ''' + @std_contract_month + ''' AND ''' + @std_month_end + ''''

-- last run date which can be null
SELECT @std_last_run_date = dbo.FNAGetSQLStandardDate(MAX(as_of_date)) 
	FROM measurement_run_dates WHERE as_of_date BETWEEN @std_contract_month AND @std_as_of_date

IF @std_last_run_date IS NULL
	SET @std_last_run_date  = @std_as_of_date


--SET @as_of_date = '1/31/2003'
 
--uncomment this to debug
-- If @dedesignation_calc = 'd'
-- 	set @print_diagnostic = 1

--print 'Process Id: ' + @process_id


DECLARE @pr_name VARCHAR(100)
DECLARE @log_time DATETIME

IF @print_diagnostic = 1
BEGIN
	SET @log_increment = 1
	PRINT '******************************************************************************************'
	PRINT '********************START &&&&&&&&&[spa_Calculate_Accrual_Entries]************************'
END

-----------------GET DEFAULT VALUES
--1 means lock prior ineffectiveness pnl values when effectiveness testing (rsq) fails
DECLARE @lock_pmtm_assmt_failed VARCHAR(2)
--get values here from default table
SELECT @lock_pmtm_assmt_failed = var_value FROM adiha_default_codes_values
WHERE instance_no = 1 AND seq_no = 1 AND default_code_id = 35
IF @lock_pmtm_assmt_failed  IS NULL
	SET @lock_pmtm_assmt_failed = '0'

--save same pnl signn value by subsidiary so that each subisidiary can have seperate same pnl sign value
SELECT	fas_subsidiary_id, 
		ISNULL(var_value,@lock_pmtm_assmt_failed) lock_pmtm_assmt_failed  
INTO #lock_pmtm_assmt_failed
FROM fas_subsidiaries d_sub_id LEFT JOIN
adiha_default_codes_values dv ON instance_no = -1 * fas_subsidiary_id AND
	default_code_id=35 AND seq_no =1
WHERE fas_subsidiary_id <> -1


-- 0 means use valulation date as the as of date, 1 means use end day in the month as as of date always
DECLARE @use_common_as_of_date INT
SELECT  @use_common_as_of_date   = var_value 
FROM         adiha_default_codes_values
WHERE     (instance_no = '1') AND (default_code_id = 38) AND (seq_no = 1)
IF @use_common_as_of_date IS NULL
	SET @use_common_as_of_date = 0

IF @use_common_as_of_date = 0
	SET @std_common_as_of_date = @std_as_of_date
ELSE
	SET @std_common_as_of_date = dbo.FNAGetSQLStandardDate(dbo.FNALastDayInDate(@as_of_date))


DECLARE @same_pnl_sign VARCHAR(2) -- 0 treat as it is ineffective only in the current period, 1 treat cumulatively ineffective, 2 always use absolute value

--Same sign value for hedge and item
SELECT @same_pnl_sign = var_value FROM adiha_default_codes_values
WHERE instance_no = 1 AND seq_no = 1 AND default_code_id = 15
IF @same_pnl_sign IS NULL
	SET @same_pnl_sign = '1'

--save same pnl signn value by subsidiary so that each subisidiary can have seperate same pnl sign value
SELECT	fas_subsidiary_id, 
		ISNULL(var_value,@same_pnl_sign) same_pnl_sign_value  
INTO #same_pnl_sign
FROM fas_subsidiaries d_sub_id LEFT JOIN
adiha_default_codes_values dv ON instance_no = -1 * fas_subsidiary_id AND
	default_code_id=15 AND seq_no =1
WHERE fas_subsidiary_id <> -1


--Asset/Liabilities: 0 means at Link level default and 1 means at deal level
DECLARE @asset_liab_deal INT
SELECT @asset_liab_deal = var_value FROM adiha_default_codes_values
WHERE instance_no = 1 AND seq_no = 1 AND default_code_id = 28
IF @asset_liab_deal IS NULL
	SET @asset_liab_deal = 0


--Mismatch Tenor AOCI Release: 0 means at % each month is based on total, 1 means % based on each contract month
--% defined as Item value/Hedge Value when Hedge value exceeds item value
DECLARE @mismatch_per INT
SELECT @mismatch_per = var_value FROM adiha_default_codes_values
WHERE instance_no = 1 AND seq_no = 1 AND default_code_id = 31
IF @mismatch_per IS NULL
	SET @mismatch_per = 0

---------------------------------	CHECK IF TO CONTINUE -----------------------------------

----------------------------------GRAB CONFIGURATION PARAMETERS -----------------------------------

CREATE TABLE #temp_count
(
total_count INT NULL
)

IF EXISTS (SELECT * FROM adiha_process.dbo.sysobjects WHERE id = OBJECT_ID(@DealProcessTableName))
BEGIN

	EXEC ('insert into #temp_count select count(*) total_count from ' + @DealProcessTableName)
	IF (SELECT MAX(total_count) FROM #temp_count) = 0 
	BEGIN
		IF @print_diagnostic = 1
			PRINT '********************No Data to Process.... Process Completed************************'

	DECLARE @deleteStmt1 VARCHAR(1500)
	SET @deleteStmt1 = dbo.FNAProcessDeleteTableSql(@DiscountTableName)
	EXEC (@deleteStmt1)
	SET @deleteStmt1 = dbo.FNAProcessDeleteTableSql(@process_books)
	EXEC (@deleteStmt1)
	SET @deleteStmt1 = dbo.FNAProcessDeleteTableSql(@MTableName)
	EXEC (@deleteStmt1)


		IF @print_diagnostic = 0
		BEGIN

			SET @deleteStmt1 = dbo.FNAProcessDeleteTableSql(@DealProcessTableName)
			EXEC (@deleteStmt1)
			SET @deleteStmt1 = dbo.FNAProcessDeleteTableSql(@AOCIReleaseSchedule)
			EXEC (@deleteStmt1)
		END
		
		--Inventory Hedge Change
		SET @as_of_date = ISNULL(@as_of_date, '1900-01-01')		

		GOTO StatusMessage
		--RETURN
	END
END
ELSE
BEGIN
		IF @print_diagnostic = 1
			PRINT '********************No Data to Process.... Process Completed************************'
		GOTO StatusMessage

END


----------------------------------GRAB CONFIGURATION PARAMETERS -----------------------------------

SELECT @rollfor_fix_pnl =  CAST(var_value AS VARCHAR) FROM adiha_default_codes_values WHERE instance_no = 1 AND seq_no = 1 AND default_code_id = 10
SET @rollfor_fix_pnl = ISNULL(@rollfor_fix_pnl, '2')


----------------------------------END OF GRAB CONFIGURATION PARAMETERS -----------------------------------

---------------------------------------CALCULATE REQUIRED TESTING PARAMETERS -------------------


--by gyan
EXEC('
CREATE TABLE '+@DollarOffsetTableName+' (
	[fas_subsidiary_id] [int] NULL,
	[fas_strategy_id] [int] NULL,
	[fas_book_id] [int] NULL,
	[term_start] [datetime] NOT NULL,
	[hedge_or_item] [varchar](1)   NULL,
	[link_id] [int] NULL,
	[mes_gran_value_id] [int] NULL,
	[hedge_type_value_id] [int] NULL,
	[on_eff_test_approach_value_id] [int] NULL,
	[pnl] [float] NULL,
	[u_pnl] [float] NULL,
	[d_pnl] [float] NULL,
	[u_reg_pnl] [float] NULL,
	[d_reg_pnl] [float] NULL,
	[link_type] [varchar](5)   NULL,
	[perfect_hedge] [char](1)   NULL,
	[use_assessment_values] [float] NULL,
	[test_range_from] [float] NULL,
	[test_range_to] [float] NULL,
	[use_additional_assessment_values] [float] NULL,
	[additional_test_range_from] [float] NULL,
	[additional_test_range_to] [float] NULL,
	[use_additional_assessment_values2] [float] NULL,
	[additional_test_range_from2] [float] NULL,
	[additional_test_range_to2] [float] NULL,
	[strip_trans_value_id] [int] NULL,
	[mismatch_tenor_value_id] [int] NULL,
	[test_settled] [int] NULL,
    [mismatch_per] [int] NULL,
	[same_pnl_sign_value] [int] NULL,
	[lock_pmtm_assmt_failed] [int] NULL,
	[mes_cfv_value_id] [int] NULL
) ON [PRIMARY]
')

SET @sqlSelect1 = 
'insert into '+@DollarOffsetTableName+'
SELECT  MAX(cd.fas_subsidiary_id) fas_subsidiary_id, MAX(fas_strategy_id) fas_strategy_id, MAX(fas_book_id) fas_book_id, 
		term_start, hedge_or_item, cd.link_id, MAX(mes_gran_value_id) mes_gran_value_id,
		MAX(hedge_type_value_id) hedge_type_value_id, MAX(on_eff_test_approach_value_id) on_eff_test_approach_value_id,
		SUM(CASE WHEN( mes_cfv_value_id= 200) THEN
				CASE WHEN(mes_cfv_values_value_id = 225 OR mes_cfv_values_value_id = 401055) THEN final_dis_pnl_intrinsic_remaining ELSE final_dis_pnl_remaining END -
				CASE WHEN(mstm_eff_test_type_id = 4076) THEN isnull(p_d_hedge_mtm, 0)  ELSE 0 END
				- isnull(final_dis_dedesignated_cum_pnl, 0)
			ELSE
				CASE WHEN(mes_cfv_values_value_id = 225 OR mes_cfv_values_value_id = 401055) THEN final_und_pnl_intrinsic_remaining ELSE final_und_pnl_remaining END - 
				CASE WHEN(mstm_eff_test_type_id = 4076) THEN isnull(p_u_hedge_mtm, 0) ELSE 0 END
				- isnull(final_und_dedesignated_cum_pnl, 0)
			END
			- isnull(final_dis_locked_aoci_value, 0) -- remove accrued interest
		) AS pnl, 
		SUM(CASE WHEN(mes_cfv_values_value_id = 225 OR mes_cfv_values_value_id = 401055) THEN final_und_pnl_intrinsic_remaining ELSE final_und_pnl_remaining END - 
			CASE WHEN(mstm_eff_test_type_id = 4076) THEN isnull(p_u_hedge_mtm, 0) ELSE 0 END
		 - isnull(final_dis_locked_aoci_value, 0) - isnull(final_und_dedesignated_cum_pnl, 0)) AS u_pnl, 
		SUM(CASE WHEN(mes_cfv_values_value_id = 225 OR mes_cfv_values_value_id = 401055) THEN final_dis_pnl_intrinsic_remaining ELSE final_dis_pnl_remaining END - 
			CASE WHEN(mstm_eff_test_type_id = 4076) THEN isnull(p_d_hedge_mtm, 0) ELSE 0 END
		 - isnull(final_dis_locked_aoci_value, 0) - isnull(final_dis_dedesignated_cum_pnl, 0)) AS d_pnl, 
		SUM(CASE WHEN(mes_cfv_values_value_id = 225 OR mes_cfv_values_value_id = 401055) THEN final_und_pnl_intrinsic_remaining ELSE final_und_pnl_remaining END - 
			CASE WHEN(mstm_eff_test_type_id = 4076) THEN isnull(p_u_hedge_mtm, 0) ELSE 0 END - isnull(final_und_dedesignated_cum_pnl, 0)
		) AS u_reg_pnl, 
		SUM(CASE WHEN(mes_cfv_values_value_id = 225 OR mes_cfv_values_value_id = 401055) THEN final_dis_pnl_intrinsic_remaining ELSE final_dis_pnl_remaining END - 
			CASE WHEN(mstm_eff_test_type_id = 4076) THEN isnull(p_d_hedge_mtm, 0) ELSE 0 END - isnull(final_dis_dedesignated_cum_pnl, 0)
		) AS d_reg_pnl, 
		MAX(link_type) link_type,
		MAX(perfect_hedge) perfect_hedge, MAX(use_assessment_values) use_assessment_values, MAX(test_range_from) test_range_from,
		MAX(test_range_to) test_range_to, MAX(use_additional_assessment_values) use_additional_assessment_values, 
		MAX(additional_test_range_from) additional_test_range_from, MAX(additional_test_range_to) additional_test_range_to,
		MAX(use_additional_assessment_values2) use_additional_assessment_values2, 
		MAX(additional_test_range_from2) additional_test_range_from2, MAX(additional_test_range_to2) additional_test_range_to2,
		MAX(strip_trans_value_id) strip_trans_value_id,
		MAX(mismatch_tenor_value_id) mismatch_tenor_value_id,
		MAX(test_settled) test_settled,
		MAX(CASE WHEN (mismatch_tenor_value_id = 252) THEN 0 ELSE ' + CAST(ISNULL(@mismatch_per, 0) AS VARCHAR)+ ' END) mismatch_per,
		MAX(spss.same_pnl_sign_value) same_pnl_sign_value,
		MAX(lpaf.lock_pmtm_assmt_failed) lock_pmtm_assmt_failed,
		max(cd.mes_cfv_value_id) mes_cfv_value_id	
FROM ' + @DealProcessTableName + ' cd LEFT JOIN
#same_pnl_sign spss ON spss.fas_subsidiary_id = cd.fas_subsidiary_id LEFT JOIN
#lock_pmtm_assmt_failed lpaf ON lpaf.fas_subsidiary_id = cd.fas_subsidiary_id 
WHERE   (hedge_type_value_id BETWEEN 150 AND 151) AND 
		((strip_trans_value_id = 625 AND ((link_type_value_id <> 450 AND item_term_month > dedesignation_date) OR
											item_term_month > as_of_date OR mismatch_tenor_value_id = 252)) 
			OR (strip_trans_value_id <> 625)
		)
GROUP BY term_start, hedge_or_item, cd.link_id
'



IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
END

--print @sqlSelect1
--return 


EXEC(@sqlSelect1)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************End of Collecting Data for Dollar Offset *****************************'	
END


IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
END

-- DO NOT ALLOW mismatch_per to be 1 if one of the hedge month value is 0 
CREATE TABLE #disallow_mismatch_link (link_id INT)

SET @sqlSelect1 = '
INSERT INTO #disallow_mismatch_link 
select distinct link_id from (
select coalesce(H.link_id, I.link_id ) link_id, coalesce(H.term_start, I.term_start) term_start, 
isnull(H.u_pnl, 0) h_u_pnl, isnull(H.d_pnl, 0) h_d_pnl
from 
(select link_id, term_start, sum(u_pnl) u_pnl, sum(d_pnl) d_pnl from '+@DollarOffsetTableName+'
where hedge_or_item = ''h'' and (mes_gran_value_id = 176 AND mismatch_per = 1)
group by link_id, term_start) H
FULL OUTER JOIN 
(select link_id, term_start, sum(u_pnl) u_pnl, sum(d_pnl) d_pnl from '+@DollarOffsetTableName+'
where hedge_or_item = ''i'' and (mes_gran_value_id = 176 AND mismatch_per = 1)
group by link_id, term_start) I ON
H.link_id = I.link_id AND H.term_start = I.term_start
WHERE H.u_pnl IS NULL OR H.u_pnl=0 OR H.d_pnl IS NULL OR H.d_pnl=0) m
'
EXEC (@sqlSelect1)

SET @sqlSelect1 = '
INSERT INTO #disallow_mismatch_link 
select distinct link_id from 
(select coalesce(H.fas_strategy_id, I.fas_strategy_id ) fas_strategy_id, coalesce(H.term_start, I.term_start) term_start, 
isnull(H.u_pnl, 0) h_u_pnl, isnull(H.d_pnl, 0) h_d_pnl
from 
(select fas_strategy_id, term_start, sum(u_pnl) u_pnl, sum(d_pnl) d_pnl from '+@DollarOffsetTableName+' 
where hedge_or_item = ''h'' and (mes_gran_value_id = 178 AND mismatch_per = 1)
group by fas_strategy_id, term_start) H
FULL OUTER JOIN 
(select fas_strategy_id, term_start, sum(u_pnl) u_pnl, sum(d_pnl) d_pnl from '+@DollarOffsetTableName+' 
where hedge_or_item = ''i'' and (mes_gran_value_id = 178 AND mismatch_per = 1)
group by fas_strategy_id, term_start) I ON
H.fas_strategy_id = I.fas_strategy_id AND H.term_start = I.term_start
WHERE H.u_pnl IS NULL OR H.u_pnl=0 OR H.d_pnl IS NULL OR H.d_pnl=0) ms INNER JOIN
(SELECT distinct fas_strategy_id, link_id from '+@DollarOffsetTableName+') ml ON 
ms.fas_strategy_id = ml.fas_strategy_id
'
EXEC (@sqlSelect1)

SET @sqlSelect1 = '
UPDATE '+@DollarOffsetTableName+' SET mismatch_per = 0
FROM '+@DollarOffsetTableName+'  cdof INNER JOIN
#disallow_mismatch_link dml ON dml.link_id = cdof.link_id
'
EXEC (@sqlSelect1)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************End of Overriding mismatch percentage if hedge amount is 0 in dollar offset table *****************************'	
END

EXEC('
CREATE TABLE '+@tempTestGranularity+'(
	[link_id] [int] NULL,
	[link_type] [varchar](5)   NULL,
	[term_start] [datetime] NOT NULL,
	[dol_offset] [float] NULL,
	[cfv_ratio] [float] NULL,
	[u_cfv_ratio] [float] NULL,
	[d_cfv_ratio] [float] NULL,
	[assessment_test] [int] NULL,
	[same_sign_pnl] [int] NULL,
	[same_pnl_sign_value] [int],
	[lock_pmtm_assmt_failed] [int] NULL
) ON [PRIMARY]
')

--This is contract month level 175
SET @sqlSelect1 = 
'insert INTO ' + @tempTestGranularity + '
SELECT  dot.link_id, dot.link_type, dot.term_start,  res.dol_offset as dol_offset, res.cfv_ratio, res.u_cfv_ratio, res.d_cfv_ratio, 
		res.assessment_test, res.same_sign_pnl, res.same_pnl_sign_value, res.lock_pmtm_assmt_failed
from (select link_id, link_type, term_start from ' + @DollarOffsetTableName + 
' group by link_id, link_type, term_start) dot inner join 
	(SELECT coalesce(h.link_id, i.link_id) link_id, coalesce(h.link_type, i.link_type) link_type,
			coalesce(h.term_start, i.term_start) term_start, 
			CASE	WHEN (coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) = 2 AND ((h.pnl > 0 AND i.pnl > 0) OR (h.pnl < 0 AND i.pnl < 0))) then H.pnl/NULLIF(I.pnl, 0)
					WHEN (H.pnl <> 0 AND I.pnl = 0) THEN 0 
					WHEN (H.pnl = 0 AND I.pnl = 0) Then 1  
					Else H.pnl/NULLIF(I.pnl, 0) * -1 
			END AS dol_offset,
			CASE	
					WHEN (h.perfect_hedge = ''y'' OR h.on_eff_test_approach_value_id = 304) THEN 1
					WHEN (coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) = 2 AND ((h.pnl > 0 AND i.pnl > 0) OR (h.pnl < 0 AND i.pnl < 0))) THEN 
							CASE WHEN (ABS(h.pnl) <= ABS(i.pnl)) THEN 1 ELSE ABS(i.pnl)/nullif(ABS(h.pnl),0) END								
					WHEN ((h.pnl = 0) OR (i.pnl = 0) OR (h.pnl > 0 AND i.pnl > 0) OR (h.pnl < 0 AND i.pnl < 0) OR (h.pnl <> 0 AND i.pnl = 0)) THEN 0
					WHEN (ABS(h.pnl) <= ABS(i.pnl)) THEN 1
					ELSE ABS(i.pnl)/nullif(ABS(h.pnl),0)
			END cfv_ratio,
			CASE	
					WHEN (h.perfect_hedge = ''y'' OR h.on_eff_test_approach_value_id = 304) THEN 1
					WHEN (coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) = 2 AND ((h.pnl > 0 AND i.pnl > 0) OR (h.pnl < 0 AND i.pnl < 0))) THEN 
							CASE WHEN (ABS(h.pnl) <= ABS(i.pnl)) THEN 1 ELSE ABS(i.u_pnl)/nullif(ABS(h.u_pnl),0) END								
					WHEN ((h.pnl = 0) OR (i.pnl = 0) OR (h.pnl > 0 AND i.pnl > 0) OR (h.pnl < 0 AND i.pnl < 0) OR (h.pnl <> 0 AND i.pnl = 0)) THEN 0
					WHEN (ABS(h.pnl) <= ABS(i.pnl)) THEN 1
					ELSE ABS(i.u_pnl)/nullif(ABS(h.u_pnl),0)
			END u_cfv_ratio,
			CASE	
					WHEN (h.perfect_hedge = ''y'' OR h.on_eff_test_approach_value_id = 304) THEN 1
					WHEN (coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) = 2 AND ((h.pnl > 0 AND i.pnl > 0) OR (h.pnl < 0 AND i.pnl < 0))) THEN 
							CASE WHEN (ABS(h.pnl) <= ABS(i.pnl)) THEN 1 ELSE ABS(i.d_pnl)/nullif(ABS(h.d_pnl),0) END								
					WHEN ((h.pnl = 0) OR (i.pnl = 0) OR (h.pnl > 0 AND i.pnl > 0) OR (h.pnl < 0 AND i.pnl < 0) OR (h.pnl <> 0 AND i.pnl = 0)) THEN 0
					WHEN (ABS(h.pnl) <= ABS(i.pnl)) THEN 1
					ELSE ABS(i.d_pnl)/nullif(ABS(h.d_pnl),0)   
			END d_cfv_ratio,
			CASE WHEN(h.perfect_hedge = ''y'' OR h.on_eff_test_approach_value_id = 304 OR h.on_eff_test_approach_value_id = 320) THEN 1
			ELSE dbo.FNATestAssessment(h.on_eff_test_approach_value_id, 
			CASE WHEN (h.on_eff_test_approach_value_id = 302) THEN 
				CASE	WHEN (H.pnl <> 0 AND I.pnl = 0) THEN 0  
						WHEN (H.pnl = 0 AND I.pnl = 0) THEN 1  ELSE H.pnl / NULLIF (I.pnl, 0) * -1 END 
			ELSE h.use_assessment_values END, h.test_range_from, h.test_range_to, 
			h.use_additional_assessment_values, h.additional_test_range_from, h.additional_test_range_to,
			h.use_additional_assessment_values2, h.additional_test_range_from2, h.additional_test_range_to2) 
			END AS assessment_test,
			case when ((h.pnl > 0 AND i.pnl > 0) OR (h.pnl < 0 AND i.pnl < 0)) then 1 else 0 end same_sign_pnl,
			coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) same_pnl_sign_value,
			coalesce(h.lock_pmtm_assmt_failed, i.lock_pmtm_assmt_failed) lock_pmtm_assmt_failed '
 SET @sqlSelect2 = '	from
	(SELECT     fas_subsidiary_id, fas_strategy_id, fas_book_id, term_start, 
				link_id, link_type, hedge_type_value_id, on_eff_test_approach_value_id, 
				SUM(pnl) + SUM(ISNULL(CASE WHEN(mes_cfv_value_id = 200) THEN d_correction_value ELSE u_correction_value END, 0))   AS pnl, 
				SUM(u_pnl) + SUM(ISNULL(cv.u_correction_value, 0)) AS u_pnl, 
				SUM(d_pnl) + SUM(ISNULL(cv.d_correction_value, 0)) AS d_pnl,
				MAX(perfect_hedge) perfect_hedge, MAX(use_assessment_values) use_assessment_values, MAX(test_range_from) test_range_from,
				MAX(test_range_to) test_range_to, MAX(use_additional_assessment_values) use_additional_assessment_values, 
				MAX(additional_test_range_from) additional_test_range_from, MAX(additional_test_range_to) additional_test_range_to,
				MAX(use_additional_assessment_values2) use_additional_assessment_values2, 
				MAX(additional_test_range_from2) additional_test_range_from2, MAX(additional_test_range_to2) additional_test_range_to2,
				MAX(same_pnl_sign_value) same_pnl_sign_value, MAX(lock_pmtm_assmt_failed) lock_pmtm_assmt_failed  
      FROM           ' + @DollarOffsetTableName + ' LEFT JOIN
				fx_correction_values cv ON cv.cor_link_id = link_id AND
					cv.cor_term_start = term_start AND cv.cor_hedge_item = hedge_or_item
					AND cv.as_of_date =''' + @std_as_of_date + '''
      WHERE      (mes_gran_value_id = 175) AND (hedge_or_item = ''h'')
	  GROUP BY	fas_subsidiary_id, fas_strategy_id, fas_book_id, term_start, 
				link_id, link_type, hedge_type_value_id , on_eff_test_approach_value_id 
		) H FULL OUTER JOIN
      (SELECT   fas_subsidiary_id, fas_strategy_id, fas_book_id, term_start, 
				link_id, link_type, hedge_type_value_id , on_eff_test_approach_value_id, 
				SUM(pnl) + SUM(ISNULL(CASE WHEN(mes_cfv_value_id = 200) THEN d_correction_value ELSE u_correction_value END, 0))   AS pnl, 
				SUM(u_pnl) + SUM(ISNULL(cv.u_correction_value, 0)) AS u_pnl, 
				SUM(d_pnl) + SUM(ISNULL(cv.d_correction_value, 0)) AS d_pnl,
				MAX(same_pnl_sign_value) same_pnl_sign_value, MAX(lock_pmtm_assmt_failed) lock_pmtm_assmt_failed 
        FROM           ' + @DollarOffsetTableName + ' LEFT JOIN
				fx_correction_values cv ON cv.cor_link_id = link_id AND
					cv.cor_term_start = term_start AND cv.cor_hedge_item = hedge_or_item
					AND cv.as_of_date =''' + @std_as_of_date + '''
        WHERE      (mes_gran_value_id = 175) AND (hedge_or_item = ''i'')
        GROUP BY fas_subsidiary_id, fas_strategy_id, fas_book_id, term_start , 
		link_id, link_type, hedge_type_value_id , on_eff_test_approach_value_id 
		) I 
	ON H.fas_subsidiary_id = I.fas_subsidiary_id AND 
	H.fas_strategy_id = I.fas_strategy_id AND H.fas_book_id = I.fas_book_id AND H.term_start = I.term_start 
	AND H.link_id = I.link_id AND H.link_type = I.link_type) res ON res.link_id = dot.link_id AND
	res.link_type = dot.link_type AND res.term_start = dot.term_start
'

--print @sqlSelect1

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
END
--PRINT(@sqlSelect1)
--PRINT(@sqlSelect2)
EXEC(@sqlSelect1+@sqlSelect2)
--return

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************End of Calculating Dollar Offset - Contract Month Level*****************************'	
END


--This is Link level 176: 1 means CFV Ratio for each month is based on monthly item/hedge when hedge total value > item total value
-- 0 mean s
--IF @mismatch_per = 1
--BEGIN
	SET @sqlSelect1 = 
	'insert INTO ' + @tempTestGranularity + '
	SELECT  dot.link_id, dot.link_type, dot.term_start,  res.dol_offset as dol_offset, res.cfv_ratio, res.u_cfv_ratio, res.d_cfv_ratio, res.assessment_test, res.same_sign_pnl, res.same_pnl_sign_value, res.lock_pmtm_assmt_failed
	from (select link_id, link_type, term_start from ' + @DollarOffsetTableName + 
	' group by link_id, link_type, term_start) dot inner join 
		(SELECT coalesce(h.link_id, i.link_id) link_id, coalesce(h.link_type, i.link_type) link_type,
				coalesce(h.term_start, i.term_start) term_start, 
				CASE	WHEN (coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) = 2 AND ((h.pnl > 0 AND i.pnl > 0) OR (h.pnl < 0 AND i.pnl < 0))) then H.pnl/NULLIF(I.pnl, 0)
						WHEN (H.pnl <> 0 AND I.pnl = 0) THEN 0 	WHEN (H.pnl = 0 AND I.pnl = 0) Then 1  	Else H.pnl/NULLIF(I.pnl, 0) * -1 
				END AS dol_offset,
				CASE	WHEN (h.perfect_hedge = ''y'' OR h.on_eff_test_approach_value_id = 304) THEN 1
						WHEN (coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) = 2 AND ((h.pnl > 0 AND i.pnl > 0) OR (h.pnl < 0 AND i.pnl < 0))) THEN 
								CASE WHEN (ABS(h.pnl) <= ABS(i.pnl)) THEN 1 ELSE ABS(i.cpnl)/nullif(ABS(h.cpnl),0) END								
						WHEN ((h.pnl = 0) OR (i.pnl = 0) OR (h.pnl > 0 AND i.pnl > 0) OR (h.pnl < 0 AND i.pnl < 0) OR (h.pnl <> 0 AND i.pnl = 0)) THEN 0
						WHEN (ABS(h.pnl) <= ABS(i.pnl)) THEN 1 ELSE -1 * i.cpnl/nullif(h.cpnl,0)
				END cfv_ratio,
				CASE	WHEN (h.perfect_hedge = ''y'' OR h.on_eff_test_approach_value_id = 304) THEN 1
						WHEN (coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) = 2 AND ((h.pnl > 0 AND i.pnl > 0) OR (h.pnl < 0 AND i.pnl < 0))) THEN 
								CASE WHEN (ABS(h.pnl) <= ABS(i.pnl)) THEN 1 ELSE ABS(i.u_pnl)/nullif(ABS(h.u_pnl),0) END								
						WHEN ((h.pnl = 0) OR (i.pnl = 0) OR (h.pnl > 0 AND i.pnl > 0) OR (h.pnl < 0 AND i.pnl < 0) OR (h.pnl <> 0 AND i.pnl = 0)) THEN 0
						WHEN (ABS(h.pnl) <= ABS(i.pnl)) THEN 1	ELSE -1 * i.u_pnl/nullif(h.u_pnl,0)
				END u_cfv_ratio,
				CASE	WHEN (h.perfect_hedge = ''y'' OR h.on_eff_test_approach_value_id = 304) THEN 1
						WHEN (coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) = 2 AND ((h.pnl > 0 AND i.pnl > 0) OR (h.pnl < 0 AND i.pnl < 0))) THEN 
								CASE WHEN (ABS(h.pnl) <= ABS(i.pnl)) THEN 1 ELSE ABS(i.d_pnl)/nullif(ABS(h.d_pnl),0) END								
						WHEN ((h.pnl = 0) OR (i.pnl = 0) OR (h.pnl > 0 AND i.pnl > 0) OR (h.pnl < 0 AND i.pnl < 0) OR (h.pnl <> 0 AND i.pnl = 0)) THEN 0
						WHEN (ABS(h.pnl) <= ABS(i.pnl)) THEN 1	ELSE -1 * i.d_pnl/nullif(h.d_pnl,0)   
				END d_cfv_ratio,
				CASE WHEN(h.perfect_hedge = ''y'' OR h.on_eff_test_approach_value_id = 304 OR h.on_eff_test_approach_value_id = 320) THEN 1
				ELSE dbo.FNATestAssessment(h.on_eff_test_approach_value_id, 
					CASE WHEN (h.on_eff_test_approach_value_id = 302) THEN 
						CASE	WHEN (H.pnl <> 0 AND I.pnl = 0) THEN 0  
								WHEN (H.pnl = 0 AND I.pnl = 0) THEN 1  ELSE H.pnl / NULLIF (I.pnl, 0) * -1 END 
					ELSE h.use_assessment_values END, h.test_range_from, h.test_range_to, 
					h.use_additional_assessment_values, h.additional_test_range_from, h.additional_test_range_to,
					h.use_additional_assessment_values2, h.additional_test_range_from2, h.additional_test_range_to2) 
				END AS assessment_test,	case when ((h.pnl > 0 AND i.pnl > 0) OR (h.pnl < 0 AND i.pnl < 0)) then 1 else 0 end same_sign_pnl,
				coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) same_pnl_sign_value,coalesce(h.lock_pmtm_assmt_failed, i.lock_pmtm_assmt_failed) lock_pmtm_assmt_failed
	'
	SET @sqlSelect2 = '	from
		(SELECT     fas_subsidiary_id, fas_strategy_id, fas_book_id, term_start, link_id, link_type, hedge_type_value_id, on_eff_test_approach_value_id, max(pnl1) pnl, 
					SUM(pnl) + SUM(ISNULL(CASE WHEN(mes_cfv_value_id = 200) THEN d_correction_value ELSE u_correction_value END, 0)) AS cpnl, 
					SUM(u_pnl) + SUM(ISNULL(cv.u_correction_value, 0)) AS u_pnl, SUM(d_pnl) + SUM(ISNULL(cv.d_correction_value, 0)) AS d_pnl, 
					MAX(perfect_hedge) perfect_hedge, MAX(use_assessment_values) use_assessment_values, MAX(test_range_from) test_range_from,
					MAX(test_range_to) test_range_to, MAX(use_additional_assessment_values) use_additional_assessment_values, 
					MAX(additional_test_range_from) additional_test_range_from, MAX(additional_test_range_to) additional_test_range_to,
					MAX(use_additional_assessment_values2) use_additional_assessment_values2, 
					MAX(additional_test_range_from2) additional_test_range_from2, MAX(additional_test_range_to2) additional_test_range_to2,
					MAX(same_pnl_sign_value) same_pnl_sign_value, MAX(lock_pmtm_assmt_failed) lock_pmtm_assmt_failed
			FROM           ' + @DollarOffsetTableName + ' INNER JOIN
					(select link_id link_id1, link_type link_type1, 
							sum(pnl) + SUM(ISNULL(CASE WHEN(mes_cfv_value_id = 200) THEN d_correction_value ELSE u_correction_value END, 0)) pnl1 
						from ' + @DollarOffsetTableName + ' LEFT JOIN
								fx_correction_values cv ON cv.cor_link_id = link_id AND	cv.cor_term_start = term_start AND cv.cor_hedge_item = hedge_or_item
								AND cv.as_of_date =''' + @std_as_of_date + '''
						WHERE      (mes_gran_value_id = 176 AND mismatch_per = 1) AND (hedge_or_item = ''h'') 
						group by link_id, link_type) tp ON link_id1 = link_id AND link_type1 = link_type  LEFT JOIN
								fx_correction_values cv ON cv.cor_link_id = link_id AND	cv.cor_term_start = term_start AND cv.cor_hedge_item = hedge_or_item
								AND cv.as_of_date =''' + @std_as_of_date + '''						
						   WHERE      (mes_gran_value_id = 176 AND mismatch_per = 1) AND (hedge_or_item = ''h'')
						   GROUP BY fas_subsidiary_id, fas_strategy_id, fas_book_id, term_start, link_id, link_type, hedge_type_value_id , on_eff_test_approach_value_id 
			) H 
			FULL OUTER JOIN
					  (SELECT     fas_subsidiary_id, fas_strategy_id, fas_book_id, term_start, link_id, link_type, hedge_type_value_id , on_eff_test_approach_value_id, 
						max(pnl1) pnl, SUM(pnl) + SUM(ISNULL(CASE WHEN(mes_cfv_value_id = 200) THEN d_correction_value ELSE u_correction_value END, 0)) AS cpnl, 
						SUM(u_pnl) + SUM(ISNULL(cv.u_correction_value, 0)) AS u_pnl, SUM(d_pnl) + SUM(ISNULL(cv.d_correction_value, 0)) AS d_pnl,
						MAX(same_pnl_sign_value) same_pnl_sign_value, MAX(lock_pmtm_assmt_failed) lock_pmtm_assmt_failed
						FROM  ' + @DollarOffsetTableName + ' INNER JOIN
						(select link_id link_id1, link_type link_type1, 
							sum(pnl) + SUM(ISNULL(CASE WHEN(mes_cfv_value_id = 200) THEN d_correction_value ELSE u_correction_value END, 0)) pnl1 
						from ' + @DollarOffsetTableName + ' LEFT JOIN
								fx_correction_values cv ON cv.cor_link_id = link_id AND
								cv.cor_term_start = term_start AND cv.cor_hedge_item = hedge_or_item AND cv.as_of_date =''' + @std_as_of_date + '''
						WHERE      (mes_gran_value_id = 176 AND mismatch_per = 1) AND (hedge_or_item = ''i'')
						group by link_id, link_type) tp ON 
						link_id1 = link_id AND link_type1 = link_type LEFT JOIN
								fx_correction_values cv ON cv.cor_link_id = link_id AND	cv.cor_term_start = term_start AND cv.cor_hedge_item = hedge_or_item
								AND cv.as_of_date =''' + @std_as_of_date + '''												
						WHERE      (mes_gran_value_id = 176 AND mismatch_per = 1) AND (hedge_or_item = ''i'')
						GROUP BY fas_subsidiary_id, fas_strategy_id, fas_book_id, term_start , 
				link_id, link_type, hedge_type_value_id , on_eff_test_approach_value_id) I 
	ON H.fas_subsidiary_id = I.fas_subsidiary_id AND H.fas_strategy_id = I.fas_strategy_id AND H.fas_book_id = I.fas_book_id AND H.term_start = I.term_start 
	AND H.link_id = I.link_id AND H.link_type = I.link_type) res ON res.link_id = dot.link_id AND res.link_type = dot.link_type AND res.term_start = dot.term_start
	'
--END
--ELSE
--BEGIN
--PRINT(@sqlSelect1)
--PRINT(@sqlSelect2)
	EXEC(@sqlSelect1+@sqlSelect2)

	SET @sqlSelect1 = 
	'INSERT INTO ' + @tempTestGranularity + '
	SELECT  dot.link_id, dot.link_type, dot.term_start,  res.dol_offset as dol_offset, res.cfv_ratio, res.u_cfv_ratio, res.d_cfv_ratio, 
			res.assessment_test, res.same_sign_pnl, res.same_pnl_sign_value, res.lock_pmtm_assmt_failed 
	from (select link_id, link_type, term_start from ' + @DollarOffsetTableName + 
	' group by link_id, link_type, term_start) dot inner join 
	(
	SELECT	COALESCE (H.link_id, I.link_id) AS link_id, 
			COALESCE (H.link_type, I.link_type) AS link_type,
			CASE	
					WHEN (coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) = 2 AND ((h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0))) then H.pnl/NULLIF(I.pnl, 0)
					WHEN (H.pnl <> 0 AND I.pnl = 0) THEN 0 
					WHEN (H.pnl = 0 AND I.pnl = 0) Then 1  
					ELSE H.pnl/NULLIF(I.pnl, 0) * -1 
			END AS dol_offset,
			CASE	WHEN (h.perfect_hedge = ''y'' OR h.on_eff_test_approach_value_id = 304) THEN 1
					WHEN (coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) = 2 AND ((h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0))) THEN 
								CASE WHEN (ABS(h.cfv_ratio_pnl) <= ABS(i.cfv_ratio_pnl)) THEN 1 ELSE ABS(i.cfv_ratio_pnl)/nullif(ABS(h.cfv_ratio_pnl),0) END				
					WHEN ((h.cfv_ratio_pnl = 0) OR (i.cfv_ratio_pnl = 0) OR (h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0) OR (h.cfv_ratio_pnl <> 0 AND i.cfv_ratio_pnl = 0)) THEN 0
					WHEN (ABS(h.cfv_ratio_pnl) <= ABS(i.cfv_ratio_pnl)) THEN 1
					ELSE ABS(i.cfv_ratio_pnl)/nullif(ABS(h.cfv_ratio_pnl),0)
			END cfv_ratio,
			CASE	WHEN (h.perfect_hedge = ''y'' OR h.on_eff_test_approach_value_id = 304) THEN 1
					WHEN (coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) = 2 AND ((h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0))) THEN 
								CASE WHEN (ABS(h.cfv_ratio_pnl) <= ABS(i.cfv_ratio_pnl)) THEN 1 ELSE ABS(i.u_cfv_ratio_pnl)/nullif(ABS(h.u_cfv_ratio_pnl),0) END				
					WHEN ((h.cfv_ratio_pnl = 0) OR (i.cfv_ratio_pnl = 0) OR (h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0) OR (h.cfv_ratio_pnl <> 0 AND i.cfv_ratio_pnl = 0)) THEN 0
					WHEN (ABS(h.cfv_ratio_pnl) <= ABS(i.cfv_ratio_pnl)) THEN 1
					ELSE ABS(i.u_cfv_ratio_pnl)/nullif(ABS(h.u_cfv_ratio_pnl),0)
			END u_cfv_ratio,
			CASE	WHEN (h.perfect_hedge = ''y'' OR h.on_eff_test_approach_value_id = 304) THEN 1
					WHEN (coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) = 2 AND ((h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0))) THEN 
								CASE WHEN (ABS(h.cfv_ratio_pnl) <= ABS(i.cfv_ratio_pnl)) THEN 1 ELSE ABS(i.d_cfv_ratio_pnl)/nullif(ABS(h.d_cfv_ratio_pnl),0) END				
					WHEN ((h.cfv_ratio_pnl = 0) OR (i.cfv_ratio_pnl = 0) OR (h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0) OR (h.cfv_ratio_pnl <> 0 AND i.cfv_ratio_pnl = 0)) THEN 0
					WHEN (ABS(h.cfv_ratio_pnl) <= ABS(i.cfv_ratio_pnl)) THEN 1
					ELSE ABS(i.d_cfv_ratio_pnl)/nullif(ABS(h.d_cfv_ratio_pnl),0)
			END d_cfv_ratio,
			CASE WHEN(h.perfect_hedge = ''y'' OR h.on_eff_test_approach_value_id = 304 OR h.on_eff_test_approach_value_id = 320) THEN 1
			ELSE dbo.FNATestAssessment(h.on_eff_test_approach_value_id, 
					CASE WHEN (h.on_eff_test_approach_value_id = 302) THEN 
						CASE	WHEN (H.pnl <> 0 AND I.pnl = 0) THEN 0  
								WHEN (H.pnl = 0 AND I.pnl = 0) THEN 1  ELSE H.pnl / NULLIF (I.pnl, 0) * -1 END 
					ELSE h.use_assessment_values END, h.test_range_from, h.test_range_to, 
					h.use_additional_assessment_values, h.additional_test_range_from, h.additional_test_range_to,
					h.use_additional_assessment_values2, h.additional_test_range_from2, h.additional_test_range_to2) 
			END AS assessment_test,
			case when ((h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0)) then 1 else 0 end same_sign_pnl,
			coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) same_pnl_sign_value,
			coalesce(h.lock_pmtm_assmt_failed, i.lock_pmtm_assmt_failed) lock_pmtm_assmt_failed '
	SET @sqlSelect2=' FROM	(SELECT	fas_subsidiary_id, fas_strategy_id, fas_book_id, link_id, link_type, hedge_type_value_id, on_eff_test_approach_value_id, 
					SUM(pnl) + SUM(ISNULL(CASE WHEN(mes_cfv_value_id = 200) THEN d_correction_value ELSE u_correction_value END, 0)) AS pnl, 
					MAX(perfect_hedge) perfect_hedge, MAX(use_assessment_values) use_assessment_values, MAX(test_range_from) test_range_from,
					MAX(test_range_to) test_range_to, MAX(use_additional_assessment_values) use_additional_assessment_values, 
					MAX(additional_test_range_from) additional_test_range_from, MAX(additional_test_range_to) additional_test_range_to,
					MAX(use_additional_assessment_values2) use_additional_assessment_values2, 
					MAX(additional_test_range_from2) additional_test_range_from2, MAX(additional_test_range_to2) additional_test_range_to2,
					SUM(pnl) + SUM(ISNULL(CASE WHEN(mes_cfv_value_id = 200) THEN d_correction_value ELSE u_correction_value END, 0)) AS cfv_ratio_pnl, 
					SUM(u_pnl) + SUM(ISNULL(cv.u_correction_value, 0)) AS u_cfv_ratio_pnl, 
					SUM(d_pnl) + SUM(ISNULL(cv.d_correction_value, 0)) AS d_cfv_ratio_pnl,
					MAX(same_pnl_sign_value) same_pnl_sign_value, MAX(lock_pmtm_assmt_failed) lock_pmtm_assmt_failed
				FROM           ' + @DollarOffsetTableName + ' LEFT JOIN
								fx_correction_values cv ON cv.cor_link_id = link_id AND
								cv.cor_term_start = term_start AND cv.cor_hedge_item = hedge_or_item
								AND cv.as_of_date= ''' + @std_as_of_date + '''
				WHERE      (mes_gran_value_id = 176 AND mismatch_per = 0) AND (hedge_or_item = ''h'')
						   GROUP BY fas_subsidiary_id, fas_strategy_id, fas_book_id, link_id, link_type, hedge_type_value_id, 
					on_eff_test_approach_value_id) H FULL OUTER JOIN
				(SELECT     fas_subsidiary_id, fas_strategy_id, fas_book_id, link_id, link_type, hedge_type_value_id, on_eff_test_approach_value_id, 
							SUM(pnl) + SUM(ISNULL(CASE WHEN(mes_cfv_value_id = 200) THEN d_correction_value ELSE u_correction_value END, 0)) AS pnl, 
							SUM(pnl) + SUM(ISNULL(CASE WHEN(mes_cfv_value_id = 200) THEN d_correction_value ELSE u_correction_value END, 0)) AS cfv_ratio_pnl, 
							SUM(u_pnl) + SUM(ISNULL(cv.u_correction_value, 0)) AS u_cfv_ratio_pnl, 
							SUM(d_pnl) + SUM(ISNULL(cv.d_correction_value, 0)) AS d_cfv_ratio_pnl,
							MAX(same_pnl_sign_value) same_pnl_sign_value, MAX(lock_pmtm_assmt_failed) lock_pmtm_assmt_failed
								FROM           ' + @DollarOffsetTableName + ' LEFT JOIN
								fx_correction_values cv ON cv.cor_link_id = link_id AND
								cv.cor_term_start = term_start AND cv.cor_hedge_item = hedge_or_item
								AND cv.as_of_date =''' + @std_as_of_date + '''
					WHERE      (mes_gran_value_id = 176 AND mismatch_per = 0) AND (hedge_or_item = ''i'')
								GROUP BY fas_subsidiary_id, fas_strategy_id, fas_book_id, link_id, link_type, hedge_type_value_id , on_eff_test_approach_value_id) I ON H.fas_subsidiary_id = I.fas_subsidiary_id AND 
						  H.fas_strategy_id = I.fas_strategy_id AND H.fas_book_id = I.fas_book_id 
				AND H.link_id = I.link_id AND H.link_type = I.link_type
	) res ON res.link_id = dot.link_id AND
	res.link_type = dot.link_type 		
	'
--END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
END

--print @sqlSelect1
--return
EXEC(@sqlSelect1+@sqlSelect2)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************End of Calculating Dollar Offset - Link/Book Level*****************************'	
END
--==============================
--select * from prior_correction_values
SELECT book.parent_entity_id strategy_id, hedge_item, SUM(ISNULL(prior_value, 0)) prior_value
INTO #correction_value
FROM prior_correction_values pcv INNER JOIN 
	 portfolio_hierarchy book ON book.entity_id = -1* pcv.link_id
GROUP BY book.parent_entity_id, hedge_item


--This is Strategy level 178
--Strategy level is needed since link id are the book level (-book_id)
--IF @mismatch_per = 1
--BEGIN
	SET @sqlSelect1 = 
	'INSERT INTO ' + @tempTestGranularity + '
	SELECT  dot.link_id, dot.link_type, dot.term_start,  res.dol_offset as dol_offset, res.cfv_ratio, res.u_cfv_ratio, res.d_cfv_ratio, 
			res.assessment_test, res.same_sign_pnl, res.same_pnl_sign_value, res.lock_pmtm_assmt_failed
	from (select link_id, link_type, term_start, fas_strategy_id from ' + @DollarOffsetTableName + 
	' group by link_id, link_type, term_start, fas_strategy_id) dot inner join 
	(
	SELECT  
		COALESCE (H.fas_strategy_id, I.fas_strategy_id) AS fas_strategy_id,
		COALESCE (H.term_start, I.term_start) AS term_start,
		CASE	WHEN (coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) = 2 AND ((h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0))) then H.pnl/NULLIF(I.pnl, 0)
				WHEN (H.pnl <> 0 AND I.pnl = 0) THEN 0 
				WHEN (H.pnl = 0 AND I.pnl = 0) Then 1  
				ELSE H.pnl/NULLIF(I.pnl, 0) * -1 
		END AS dol_offset,
		CASE	WHEN (h.perfect_hedge = ''y'' OR h.on_eff_test_approach_value_id = 304) THEN 1
				WHEN (coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) = 2 AND ((h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0))) THEN
					CASE WHEN (ABS(h.cfv_ratio_pnl) <= ABS(i.cfv_ratio_pnl)) THEN 1 ELSE ABS(i.ccfv_ratio_pnl)/nullif(ABS(h.ccfv_ratio_pnl),0) END
				WHEN ((h.cfv_ratio_pnl = 0) OR (i.cfv_ratio_pnl = 0) OR (h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0) OR (h.cfv_ratio_pnl <> 0 AND i.cfv_ratio_pnl = 0)) THEN 0
				WHEN (ABS(h.cfv_ratio_pnl) <= ABS(i.cfv_ratio_pnl)) THEN 1
				ELSE -1 * i.ccfv_ratio_pnl/nullif(h.ccfv_ratio_pnl,0)
		END cfv_ratio,
		CASE	WHEN (h.perfect_hedge = ''y'' OR h.on_eff_test_approach_value_id = 304) THEN 1
				WHEN (coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) = 2 AND ((h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0))) THEN
					CASE WHEN (ABS(h.cfv_ratio_pnl) <= ABS(i.cfv_ratio_pnl)) THEN 1 ELSE ABS(i.u_cfv_ratio_pnl)/nullif(ABS(h.u_cfv_ratio_pnl),0) END
				WHEN ((h.cfv_ratio_pnl = 0) OR (i.cfv_ratio_pnl = 0) OR (h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0) OR (h.cfv_ratio_pnl <> 0 AND i.cfv_ratio_pnl = 0)) THEN 0
				WHEN (ABS(h.cfv_ratio_pnl) <= ABS(i.cfv_ratio_pnl)) THEN 1
				ELSE -1 * i.u_cfv_ratio_pnl/nullif(h.u_cfv_ratio_pnl,0)
		END u_cfv_ratio,
		CASE	WHEN (h.perfect_hedge = ''y'' OR h.on_eff_test_approach_value_id = 304) THEN 1
				WHEN (coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) = 2 AND ((h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0))) THEN
					CASE WHEN (ABS(h.cfv_ratio_pnl) <= ABS(i.cfv_ratio_pnl)) THEN 1 ELSE ABS(i.d_cfv_ratio_pnl)/nullif(ABS(h.d_cfv_ratio_pnl),0) END
				WHEN ((h.cfv_ratio_pnl = 0) OR (i.cfv_ratio_pnl = 0) OR (h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0) OR (h.cfv_ratio_pnl <> 0 AND i.cfv_ratio_pnl = 0)) THEN 0
				WHEN (ABS(h.cfv_ratio_pnl) <= ABS(i.cfv_ratio_pnl)) THEN 1
				ELSE -1 * i.d_cfv_ratio_pnl/nullif(h.d_cfv_ratio_pnl,0)
		END d_cfv_ratio,
		CASE WHEN(h.perfect_hedge = ''y'' OR h.on_eff_test_approach_value_id = 304 OR h.on_eff_test_approach_value_id = 320) THEN 1
		ELSE dbo.FNATestAssessment(h.on_eff_test_approach_value_id, 
				CASE WHEN (h.on_eff_test_approach_value_id = 302) THEN 
					CASE	WHEN (H.pnl <> 0 AND I.pnl = 0) THEN 0  
							WHEN (H.pnl = 0 AND I.pnl = 0) THEN 1  ELSE H.pnl / NULLIF (I.pnl, 0) * -1 END 
				ELSE h.use_assessment_values END, h.test_range_from, h.test_range_to, 
				h.use_additional_assessment_values, h.additional_test_range_from, h.additional_test_range_to,
				h.use_additional_assessment_values2, h.additional_test_range_from2, h.additional_test_range_to2) 
		END AS assessment_test,
		case when ((h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0)) then 1 else 0 end same_sign_pnl,
		coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) same_pnl_sign_value,
		coalesce(h.lock_pmtm_assmt_failed, i.lock_pmtm_assmt_failed) lock_pmtm_assmt_failed   
	FROM (SELECT	dot.fas_subsidiary_id, dot.fas_strategy_id, term_start, hedge_type_value_id , on_eff_test_approach_value_id, 
					SUM(pnl) AS pnl, 
					MAX(perfect_hedge) perfect_hedge, MAX(use_assessment_values) use_assessment_values, MAX(test_range_from) test_range_from,
					MAX(test_range_to) test_range_to, MAX(use_additional_assessment_values) use_additional_assessment_values, 
					MAX(additional_test_range_from) additional_test_range_from, MAX(additional_test_range_to) additional_test_range_to,
					MAX(use_additional_assessment_values2) use_additional_assessment_values2, 
					MAX(additional_test_range_from2) additional_test_range_from2, MAX(additional_test_range_to2) additional_test_range_to2,
					MAX(cfv_ratio_pnl1) cfv_ratio_pnl, SUM(pnl) AS ccfv_ratio_pnl, SUM(u_pnl) AS u_cfv_ratio_pnl, SUM(d_pnl) AS d_cfv_ratio_pnl,
					MAX(same_pnl_sign_value) same_pnl_sign_value, MAX(lock_pmtm_assmt_failed) lock_pmtm_assmt_failed
		  From		' + @DollarOffsetTableName + ' dot INNER JOIN
		  (select   dot.fas_subsidiary_id, dot.fas_strategy_id, SUM(pnl) - MAX(isnull(cv.prior_value, 0)) AS cfv_ratio_pnl1
		   FROM      ' + @DollarOffsetTableName + ' dot LEFT OUTER JOIN
					#correction_value cv ON cv.strategy_id = dot.fas_strategy_id and cv.hedge_item = ''h''
 		   WHERE    (mes_gran_value_id = 178 AND mismatch_per = 1) AND (hedge_or_item = ''h'')
		   GROUP BY dot.fas_subsidiary_id, dot.fas_strategy_id) tp ON tp.fas_subsidiary_id = dot.fas_subsidiary_id and tp.fas_strategy_id = dot.fas_strategy_id
		  WHERE     (mes_gran_value_id = 178 AND mismatch_per = 1) AND (hedge_or_item = ''h'')
		  GROUP BY dot.fas_subsidiary_id, dot.fas_strategy_id, dot.term_start, dot.hedge_type_value_id , dot.on_eff_test_approach_value_id
		) H FULL OUTER JOIN
		(
			 SELECT dot.fas_subsidiary_id, dot.fas_strategy_id, term_start, hedge_type_value_id , on_eff_test_approach_value_id, 
					SUM(pnl) AS pnl, MAX(cfv_ratio_pnl1) cfv_ratio_pnl, SUM(pnl) AS ccfv_ratio_pnl,
					SUM(u_pnl) AS u_cfv_ratio_pnl, SUM(d_pnl) AS d_cfv_ratio_pnl,
					MAX(same_pnl_sign_value) same_pnl_sign_value, MAX(lock_pmtm_assmt_failed) lock_pmtm_assmt_failed
			 FROM   ' + @DollarOffsetTableName + ' dot INNER JOIN
		  (select   dot.fas_subsidiary_id, dot.fas_strategy_id, SUM(pnl) - MAX(isnull(cv.prior_value, 0)) AS cfv_ratio_pnl1
		   FROM      ' + @DollarOffsetTableName + ' dot LEFT OUTER JOIN
					#correction_value cv ON cv.strategy_id = dot.fas_strategy_id and cv.hedge_item = ''i''
 		   WHERE    (mes_gran_value_id = 178 AND mismatch_per = 1) AND (hedge_or_item = ''i'')
		   GROUP BY dot.fas_subsidiary_id, dot.fas_strategy_id) tp ON tp.fas_subsidiary_id = dot.fas_subsidiary_id and tp.fas_strategy_id = dot.fas_strategy_id
		  WHERE     (mes_gran_value_id = 178 AND mismatch_per = 1) AND (hedge_or_item = ''i'')
		  GROUP BY dot.fas_subsidiary_id, dot.fas_strategy_id, dot.term_start, dot.hedge_type_value_id , dot.on_eff_test_approach_value_id
		) I ON H.fas_subsidiary_id = I.fas_subsidiary_id AND 
				  H.fas_strategy_id = I.fas_strategy_id	AND H.term_start = I.term_start	
	) res on dot.fas_strategy_id=res.fas_strategy_id AND dot.term_start = res.term_start
	'
--END
--ELSE
--BEGIN
	EXEC(@sqlSelect1)

	SET @sqlSelect1 = 
	'INSERT INTO ' + @tempTestGranularity + '
	SELECT  dot.link_id, dot.link_type, dot.term_start,  res.dol_offset as dol_offset, res.cfv_ratio, res.u_cfv_ratio, res.d_cfv_ratio, 
			res.assessment_test, res.same_sign_pnl, res.same_pnl_sign_value, res.lock_pmtm_assmt_failed
	from (select link_id, link_type, term_start, fas_strategy_id from ' + @DollarOffsetTableName + 
	' group by link_id, link_type, term_start, fas_strategy_id) dot inner join 
	(

	SELECT  
		COALESCE (H.fas_strategy_id, I.fas_strategy_id) AS fas_strategy_id,
		CASE	WHEN (coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) = 2 AND ((h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0))) then H.pnl/NULLIF(I.pnl, 0)
				WHEN (H.pnl <> 0 AND I.pnl = 0) THEN 0 
				WHEN (H.pnl = 0 AND I.pnl = 0) Then 1  
				ELSE H.pnl/NULLIF(I.pnl, 0) * -1 
		END AS dol_offset,
		CASE	WHEN (h.perfect_hedge = ''y'' OR h.on_eff_test_approach_value_id = 304) THEN 1
				WHEN (coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) = 2 AND ((h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0))) THEN
					CASE WHEN (ABS(h.cfv_ratio_pnl) <= ABS(i.cfv_ratio_pnl)) THEN 1 ELSE ABS(i.cfv_ratio_pnl)/nullif(ABS(h.cfv_ratio_pnl),0) END
				WHEN ((h.cfv_ratio_pnl = 0) OR (i.cfv_ratio_pnl = 0) OR (h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0) OR (h.cfv_ratio_pnl <> 0 AND i.cfv_ratio_pnl = 0)) THEN 0
				WHEN (ABS(h.cfv_ratio_pnl) <= ABS(i.cfv_ratio_pnl)) THEN 1
				ELSE ABS(i.cfv_ratio_pnl)/nullif(ABS(h.cfv_ratio_pnl),0)
		END cfv_ratio,
		CASE	WHEN (h.perfect_hedge = ''y'' OR h.on_eff_test_approach_value_id = 304) THEN 1
				WHEN (coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) = 2 AND ((h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0))) THEN
					CASE WHEN (ABS(h.cfv_ratio_pnl) <= ABS(i.cfv_ratio_pnl)) THEN 1 ELSE ABS(i.u_cfv_ratio_pnl)/nullif(ABS(h.u_cfv_ratio_pnl),0) END
				WHEN ((h.cfv_ratio_pnl = 0) OR (i.cfv_ratio_pnl = 0) OR (h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0) OR (h.cfv_ratio_pnl <> 0 AND i.cfv_ratio_pnl = 0)) THEN 0
				WHEN (ABS(h.cfv_ratio_pnl) <= ABS(i.cfv_ratio_pnl)) THEN 1
				ELSE ABS(i.u_cfv_ratio_pnl)/nullif(ABS(h.u_cfv_ratio_pnl),0)
		END u_cfv_ratio,
		CASE	WHEN (h.perfect_hedge = ''y'' OR h.on_eff_test_approach_value_id = 304) THEN 1
				WHEN (coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) = 2 AND ((h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0))) THEN
					CASE WHEN (ABS(h.cfv_ratio_pnl) <= ABS(i.cfv_ratio_pnl)) THEN 1 ELSE ABS(i.d_cfv_ratio_pnl)/nullif(ABS(h.d_cfv_ratio_pnl),0) END
				WHEN ((h.cfv_ratio_pnl = 0) OR (i.cfv_ratio_pnl = 0) OR (h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0) OR (h.cfv_ratio_pnl <> 0 AND i.cfv_ratio_pnl = 0)) THEN 0
				WHEN (ABS(h.cfv_ratio_pnl) <= ABS(i.cfv_ratio_pnl)) THEN 1
				ELSE ABS(i.d_cfv_ratio_pnl)/nullif(ABS(h.d_cfv_ratio_pnl),0)
		END d_cfv_ratio,
		CASE WHEN(h.perfect_hedge = ''y'' OR h.on_eff_test_approach_value_id = 304 OR h.on_eff_test_approach_value_id = 320) THEN 1
		ELSE dbo.FNATestAssessment(h.on_eff_test_approach_value_id, 
				CASE WHEN (h.on_eff_test_approach_value_id = 302) THEN 
					CASE	WHEN (H.pnl <> 0 AND I.pnl = 0) THEN 0  
							WHEN (H.pnl = 0 AND I.pnl = 0) THEN 1  ELSE H.pnl / NULLIF (I.pnl, 0) * -1 END 
				ELSE h.use_assessment_values END, h.test_range_from, h.test_range_to, 
				h.use_additional_assessment_values, h.additional_test_range_from, h.additional_test_range_to,
				h.use_additional_assessment_values2, h.additional_test_range_from2, h.additional_test_range_to2) 
		END AS assessment_test,
		case when ((h.cfv_ratio_pnl > 0 AND i.cfv_ratio_pnl > 0) OR (h.cfv_ratio_pnl < 0 AND i.cfv_ratio_pnl < 0)) then 1 else 0 end same_sign_pnl,
		coalesce(h.same_pnl_sign_value, i.same_pnl_sign_value) same_pnl_sign_value, 
		coalesce(h.lock_pmtm_assmt_failed, i.lock_pmtm_assmt_failed) lock_pmtm_assmt_failed   
	FROM (SELECT	fas_subsidiary_id, fas_strategy_id, hedge_type_value_id , on_eff_test_approach_value_id, 
					SUM(pnl) - MAX(isnull(cv.prior_value, 0)) AS pnl, 
					MAX(perfect_hedge) perfect_hedge, MAX(use_assessment_values) use_assessment_values, MAX(test_range_from) test_range_from,
					MAX(test_range_to) test_range_to, MAX(use_additional_assessment_values) use_additional_assessment_values, 
					MAX(additional_test_range_from) additional_test_range_from, MAX(additional_test_range_to) additional_test_range_to,
					MAX(use_additional_assessment_values2) use_additional_assessment_values2, 
					MAX(additional_test_range_from2) additional_test_range_from2, MAX(additional_test_range_to2) additional_test_range_to2,
					SUM(pnl) - MAX(isnull(cv.prior_value, 0)) AS cfv_ratio_pnl,
					SUM(u_pnl) - MAX(isnull(cv.prior_value, 0)) AS u_cfv_ratio_pnl, 
					SUM(d_pnl) - MAX(isnull(cv.prior_value, 0)) AS d_cfv_ratio_pnl,
					MAX(same_pnl_sign_value) same_pnl_sign_value, MAX(lock_pmtm_assmt_failed) lock_pmtm_assmt_failed
		  FROM           ' + @DollarOffsetTableName + ' dot LEFT OUTER JOIN
					#correction_value cv ON cv.strategy_id = dot.fas_strategy_id and cv.hedge_item = ''h''
		   WHERE     (mes_gran_value_id = 178 AND mismatch_per = 0) AND (hedge_or_item = ''h'')
		  GROUP BY fas_subsidiary_id, fas_strategy_id, hedge_type_value_id , on_eff_test_approach_value_id
		) H FULL OUTER JOIN
		(
			 SELECT fas_subsidiary_id, fas_strategy_id, hedge_type_value_id , on_eff_test_approach_value_id, 
					SUM(pnl) - MAX(isnull(cv.prior_value, 0)) AS pnl,
					SUM(pnl) - MAX(isnull(cv.prior_value, 0)) AS cfv_ratio_pnl,
					SUM(u_pnl) - MAX(isnull(cv.prior_value, 0)) AS u_cfv_ratio_pnl,
					SUM(d_pnl) - MAX(isnull(cv.prior_value, 0)) AS d_cfv_ratio_pnl,
					MAX(same_pnl_sign_value) same_pnl_sign_value, MAX(lock_pmtm_assmt_failed) lock_pmtm_assmt_failed
			 FROM           ' + @DollarOffsetTableName + ' dot LEFT OUTER JOIN
					#correction_value cv ON cv.strategy_id = dot.fas_strategy_id and cv.hedge_item = ''i''
			 WHERE    (mes_gran_value_id = 178 AND mismatch_per = 0) AND (hedge_or_item = ''i'')
			 GROUP BY fas_subsidiary_id, fas_strategy_id, hedge_type_value_id , on_eff_test_approach_value_id
		) I ON H.fas_subsidiary_id = I.fas_subsidiary_id AND 
				  H.fas_strategy_id = I.fas_strategy_id		
	) res on dot.fas_strategy_id=res.fas_strategy_id
	'
--END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
END

--print @sqlSelect1
--return

EXEC(@sqlSelect1)

--Now create index on the test granularity table
EXEC('create index [ix_test_gran] on ' + @tempTestGranularity + ' (link_id, link_type, term_start)')

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************End of Calculating Dollar Offset - Strategy Level*****************************'	
END

EXEC('
CREATE TABLE '+@DealProcessFinalTableName +' (
	[fas_subsidiary_id] [int] NOT NULL,
	[fas_strategy_id] [int] NOT NULL,
	[fas_book_id] [int] NOT NULL,
	[source_deal_header_id] [int] NOT NULL,
	[deal_date] [datetime] NOT NULL,
	[deal_type] [int] NOT NULL,
	[deal_sub_type] [int] NULL,
	[source_counterparty_id] [int] NULL,
	[physical_financial_flag] [char](1)   NULL,
	[as_of_date] [datetime] NOT NULL,
	[term_start] [datetime] NOT NULL,
	[term_end] [datetime] NOT NULL,
	[Leg] [int] NOT NULL,
	[contract_expiration_date] [datetime] NOT NULL,
	[fixed_float_leg] [char](1)   NOT NULL,
	[buy_sell_flag] [char](1)   NOT NULL,
	[curve_id] [int] NULL,
	[fixed_price] [float] NULL,
	[fixed_price_currency_id] [int] NULL,
	[option_strike_price] [float] NULL,
	[deal_volume] [float] NOT NULL,
	[deal_volume_frequency] [char](1)   NOT NULL,
	[deal_volume_uom_id] [int] NOT NULL,
	[block_description] [varchar](100)   NULL,
	[deal_detail_description] [varchar](100)   NULL,
	[hedge_or_item] [varchar](1)   NULL,
	[link_id] [int] NULL,
	[percentage_included] [float] NOT NULL,
	[link_effective_date] [datetime] NULL,
	[dedesignation_link_id] [int] NULL,
	[link_type] [varchar](5)   NOT NULL,
	[discount_factor] [float] NOT NULL,
	[func_cur_value_id] [int] NOT NULL,
	[und_pnl] [float] NULL,
	[und_intrinsic_pnl] [float] NULL,
	[und_extrinsic_pnl] [float] NULL,
	[pnl_currency_id] [int] NULL,
	[pnl_conversion_factor] [float] NULL,
	[pnl_source_value_id] [int] NULL,
	[link_active] [char](1)   NULL,
	[fully_dedesignated] [char](1)   NULL,
	[perfect_hedge] [char](1)   NULL,
	[eff_test_profile_id] [int] NULL,
	[link_type_value_id] [int] NULL,
	[dedesignated_link_id] [int] NULL,
	[hedge_type_value_id] [int] NOT NULL,
	[fx_hedge_flag] [char](1)   NOT NULL,
	[no_links] [char](1)   NOT NULL,
	[mes_gran_value_id] [int] NOT NULL,
	[mes_cfv_value_id] [int] NOT NULL,
	[mes_cfv_values_value_id] [int] NOT NULL,
	[gl_grouping_value_id] [int] NOT NULL,
	[mismatch_tenor_value_id] [int] NULL,
	[strip_trans_value_id] [int] NOT NULL,
	[asset_liab_calc_value_id] [int] NOT NULL,
	[test_range_from] [float] NULL,
	[test_range_to] [float] NOT NULL,
	[additional_test_range_from] [float] NULL,
	[additional_test_range_to] [float] NULL,
	[additional_test_range_from2] [float] NULL,
	[additional_test_range_to2] [float] NULL,
	[include_unlinked_hedges] [char](1)   NOT NULL,
	[include_unlinked_items] [char](1)   NOT NULL,
	[no_link] [char](1)   NULL,
	[use_eff_test_profile_id] [int] NULL,
	[on_eff_test_approach_value_id] [int] NULL,
	[no_links_fas_eff_test_profile_id] [int] NULL,
	[dedesignation_pnl_currency_id] [int] NULL,
	[pnl_ineffectiveness_value] [float] NULL,
	[pnl_dedesignation_value] [float] NULL,
	[locked_aoci_value] [float] NULL,
	[pnl_cur_coversion_factor] float NOT NULL,
	[ded_pnl_cur_conversion_factor] float NOT NULL,
	[eff_pnl_cur_conversion_factor] float NOT NULL,
	[assessment_values] [float] NULL,
	[additional_assessment_values] [float] NULL,
	[additional_assessment_values2] [float] NULL,
	[use_assessment_values] [float] NULL,
	[use_additional_assessment_values] [float] NULL,
	[use_additional_assessment_values2] [float] NULL,
	[assessment_date] [datetime] NULL,
	[ddf] [int] NULL,
	[alpha] [varchar](30)   NULL,
	[eff_und_pnl] [float] NULL,
	[eff_und_intrinsic_pnl] [float] NULL,
	[eff_und_extrinsic_pnl] [float] NULL,
	[eff_pnl_source_value_id] [int] NULL,
	[eff_pnl_currency_id] [int] NULL,
	[eff_pnl_conversion_factor] [float] NULL,
	[eff_pnl_as_of_date] [datetime] NULL,
	[pnl_as_of_date] [datetime] NULL,
	[dedesignation_date] [datetime] NULL,
	[deal_id] [varchar](50)   NULL,
	[option_flag] [char](1)   NULL,
	[final_dis_pnl] [float] NULL,
	[final_dis_instrinsic_pnl] [float] NULL,
	[final_dis_extrinsic_pnl] [float] NULL,
	[final_dis_locked_aoci_value] float NOT NULL,
	[final_dis_dedesignated_cum_pnl] float NOT NULL,
	[final_dis_pnl_ineffectiveness_value] float NOT NULL,
	[final_dis_pnl_dedesignation_value] float NOT NULL,
	[final_dis_pnl_remaining] [float] NULL,
	[final_dis_pnl_intrinsic_remaining] [float] NULL,
	[final_dis_pnl_extrinsic_remaining] [float] NULL,
	[final_und_pnl] [float] NOT NULL,
	[final_und_instrinsic_pnl] [float] NOT NULL,
	[final_und_extrinsic_pnl] [float] NOT NULL,
	[final_und_locked_aoci_value] float NOT NULL,
	[final_und_dedesignated_cum_pnl] float NOT NULL,
	[final_und_pnl_ineffectiveness_value] float NOT NULL,
	[final_und_pnl_dedesignation_value] float NOT NULL,
	[final_und_pnl_remaining] [float] NULL,
	[final_und_pnl_intrinsic_remaining] [float] NULL,
	[final_und_pnl_extrinsic_remaining] [float] NULL,
	[item_match_term_month] [datetime] NULL,
	[item_term_month] [datetime] NULL,
	[long_term_months] [int] NULL,
	[source_system_id] [int] NULL,
	[include] [varchar](1)   NOT NULL,
	[hedge_term_month] [datetime] NULL,
	[eff_test_result_id] [int] NULL,
	[notional_pay_pnl] float NOT NULL,
	[notional_rec_pnl] float NOT NULL,
	[receive_float] [varchar](1)   NOT NULL,
	[carrying_amount] float NOT NULL,
	[carrying_set_amount] float NOT NULL,
	[interest_debt] float NULL,
	[short_cut_method] [char](1)   NULL,
	[exclude_spot_forward_diff] [char](1)   NULL,
	[option_premium] [float] NULL,
	[options_premium_approach] [int] NULL,
	[options_amortization_factor] [float] NULL,
	[fd_und_pnl] [float] NOT NULL,
	[fd_und_intrinsic_pnl] [float] NOT NULL,
	[fd_und_extrinsic_pnl] [float] NOT NULL,
	[fd_und_ignored_pnl] [float] NOT NULL,
	[link_dedesignated_percentage] [float] NOT NULL,
	[fas_deal_type_value_id] [int] NULL,
	[fas_deal_sub_type_value_id] [int] NULL,
	[mstm_eff_test_type_id] [int] NOT NULL,
	[p_u_hedge_mtm] [float] NULL,
	[p_d_hedge_mtm] [float] NULL,
	[p_u_aoci] [float] NULL,
	[p_d_aoci] [float] NULL,
	[p_u_total_pnl] [float] NULL,
	[p_d_total_pnl] [float] NULL,
	[test_settled] [int] NOT NULL,
	[rollout_per_type] [int] NULL,
	[tax_perc] [float] NULL,
	[oci_rollout_approach_value_id] [int] NULL,
	[link_end_date] [datetime] NULL,
	[dis_pnl] float NULL,
	[assessment_test] [int] NULL,
	[u_aoci] [float] NULL,
	[u_pnl_ineffectiveness] [float] NULL,
	[u_extrinsic_pnl] [float] NOT NULL,
	[u_pnl_mtm] [float] NULL,
	[cfv_ratio] [float] NULL,
	[dol_offset] [float] NULL,
	[d_aoci] [float] NULL,
	[d_pnl_ineffectiveness] [float] NULL,
	[d_extrinsic_pnl] [float] NOT NULL,
	[d_pnl_mtm] [float] NULL,
	[prior_assessment_test] [int] NULL
) ON [PRIMARY]
')

DECLARE @u_mtm VARCHAR(1000)
DECLARE @d_mtm VARCHAR(1000)
DECLARE @u_extrinsic_pnl VARCHAR(1000)
DECLARE @d_extrinsic_pnl VARCHAR(1000)
DECLARE @u_delta_mtm VARCHAR(1000)
DECLARE @d_delta_mtm VARCHAR(1000)
DECLARE @u_aoci VARCHAR(5000)
DECLARE @d_aoci VARCHAR(5000)


SET @u_mtm = ' ISNULL(CASE WHEN (mes_cfv_values_value_id = 225 OR mes_cfv_values_value_id = 401055) THEN final_und_pnl_intrinsic_remaining ELSE final_und_pnl_remaining END, 0) 
				- CASE WHEN (lock_pmtm_assmt_failed = 1) THEN final_und_dedesignated_cum_pnl ELSE 0 END 
				'		
SET @d_mtm = ' ISNULL(CASE WHEN (mes_cfv_values_value_id = 225 OR mes_cfv_values_value_id = 401055) THEN final_dis_pnl_intrinsic_remaining 
ELSE final_dis_pnl_remaining END, 0) 
				- CASE WHEN (lock_pmtm_assmt_failed = 1) THEN final_dis_dedesignated_cum_pnl  ELSE 0 END 
				'

SET @u_extrinsic_pnl = ' ISNULL(CASE WHEN (mes_cfv_values_value_id = 225) THEN 
							  CASE WHEN ((hedge_type_value_id = 150 AND hedge_or_item = ''i'') OR mes_cfv_values_value_id = 401055) THEN 0 ELSE final_und_pnl_extrinsic_remaining END
						 ELSE 0 END, 0) '

SET @d_extrinsic_pnl = ' ISNULL(CASE WHEN (mes_cfv_values_value_id = 225) THEN 
							  CASE WHEN ((hedge_type_value_id = 150 AND hedge_or_item = ''i'') OR mes_cfv_values_value_id = 401055) THEN 0 ELSE final_dis_pnl_extrinsic_remaining END
						 ELSE 0 END, 0) '
		
SET @u_delta_mtm = ' ISNULL(CASE WHEN (mes_cfv_values_value_id = 225 OR mes_cfv_values_value_id = 401055) THEN final_und_pnl_intrinsic_remaining ELSE final_und_pnl_remaining END - p_u_hedge_mtm, 0) '
SET @d_delta_mtm = ' ISNULL(CASE WHEN (mes_cfv_values_value_id = 225 OR mes_cfv_values_value_id = 401055) THEN final_dis_pnl_intrinsic_remaining ELSE final_dis_pnl_remaining END - p_d_hedge_mtm, 0) '

SET @u_aoci = ' (CASE	WHEN (hedge_type_value_id = 150 AND link_type_value_id = 452) THEN  0
						WHEN (hedge_type_value_id = 150 AND hedge_or_item = ''h'') THEN  
							CASE	
									--reclass due to dedesignaton from probable to not probable (aoci must be 0 now)
									WHEN (ra.source_deal_header_id IS NOT NULL) THEN 0
									--Inventory Hedge Change
									WHEN (oci_rollout_approach_value_id <> 500 AND  item_match_term_month < ''' + @std_as_of_date + ''') THEN p_u_aoci 													
									--Inventory Hedge Change   Added oci_rollout_approach_value_id = 500 AND 
									WHEN ((mes_gran_value_id=175 OR strip_trans_value_id=625) AND oci_rollout_approach_value_id = 500 AND mismatch_tenor_value_id = 250 AND test_settled > 0) THEN  p_u_aoci
									WHEN (mismatch_tenor_value_id = 252 AND ' + @rollfor_fix_pnl + ' = 3 AND  item_match_term_month < ''' + @std_as_of_date + ''')' + ' THEN p_u_aoci 								
									WHEN ( link_type_value_id = 451 AND prior_assessment_Test=0) THEN  p_u_aoci 							
									WHEN ((lock_pmtm_assmt_failed <> 2 AND (assessment_test = 0 AND dol_offset > 0) OR (tg.same_sign_pnl = 1 AND tg.same_pnl_sign_value = 0))) THEN p_u_aoci 
							ELSE ISNULL(u_cfv_ratio, 0) * CASE WHEN (mstm_eff_test_type_id = 4075) THEN ' + @u_mtm	+ ' ELSE ' + @u_delta_mtm  + '  END 
							+ CASE WHEN (mstm_eff_test_type_id = 4075) THEN 0 ELSE isnull(p_u_aoci, 0) END --for delta method add prior cum aoci value	
						END						
				ELSE 0 END -- isnull(ra.reclass_aoci_value, 0)
				--Inventory Hedge Change
				- isnull(ira.reclass_aoci_value, 0)
				+ ISNULL(CASE WHEN (mes_cfv_values_value_id = 401055) THEN 
							  CASE WHEN (hedge_type_value_id = 150 AND hedge_or_item = ''i'') THEN 0 ELSE final_und_pnl_extrinsic_remaining END
						 ELSE 0 END, 0)
				) 
			   '

SET @d_aoci = ' (CASE	WHEN (hedge_type_value_id = 150 AND link_type_value_id = 452) THEN  0
						WHEN (hedge_type_value_id = 150 AND hedge_or_item = ''h'') THEN  
							CASE	
									--reclass due to dedesignaton from probable to not probable (aoci must be 0 now)
									WHEN (ra.source_deal_header_id IS NOT NULL) THEN 0
									--Inventory Hedge Change
									WHEN (oci_rollout_approach_value_id <> 500 AND  item_match_term_month < ''' + @std_as_of_date + ''') THEN p_d_aoci 													
									--Inventory Hedge Change   Added oci_rollout_approach_value_id = 500 AND 
									WHEN ((mes_gran_value_id=175 OR strip_trans_value_id=625) AND oci_rollout_approach_value_id = 500 AND mismatch_tenor_value_id = 250 AND test_settled > 0) THEN  p_d_aoci
									WHEN (mismatch_tenor_value_id = 252 AND ' + @rollfor_fix_pnl + ' = 3 AND  item_match_term_month < ''' + @std_as_of_date + ''')' + ' THEN p_d_aoci 								
									WHEN ( link_type_value_id = 451 AND prior_assessment_Test=0) THEN p_d_aoci 							
									WHEN ((lock_pmtm_assmt_failed <> 2 AND (assessment_test = 0 AND dol_offset > 0) OR (tg.same_sign_pnl = 1 AND tg.same_pnl_sign_value = 0))) THEN p_d_aoci 
							ELSE ISNULL(d_cfv_ratio, 0) * CASE WHEN (mstm_eff_test_type_id = 4075) 
							THEN ' + @d_mtm	+ ' ELSE ' + @d_delta_mtm  + '  END 
							+ CASE WHEN (mstm_eff_test_type_id = 4075) THEN 0 ELSE isnull(p_d_aoci, 0) END --for delta method add prior cum aoci value	
						END						
				ELSE 0 END -- isnull(ra.reclass_aoci_value, 0)
				--Inventory Hedge Change
				- isnull(ira.reclass_aoci_value, 0)
				+ ISNULL(CASE WHEN (mes_cfv_values_value_id = 401055) THEN 
							  CASE WHEN (hedge_type_value_id = 150 AND hedge_or_item = ''i'') THEN 0 ELSE final_dis_pnl_extrinsic_remaining END
						 ELSE 0 END, 0)				) 
			   '

SET @sqlSelect0 = 'insert into '+@DealProcessFinalTableName+'
	SELECT	
			cd.[fas_subsidiary_id], cd.[fas_strategy_id], cd.[fas_book_id], cd.[source_deal_header_id], cd.[deal_date], cd.[deal_type],
			cd.[deal_sub_type], cd.[source_counterparty_id], cd.[physical_financial_flag], cd.[as_of_date], cd.[term_start],
			cd.[term_end], cd.[Leg], cd.[contract_expiration_date], cd.[fixed_float_leg], cd.[buy_sell_flag], cd.[curve_id],
			cd.[fixed_price], cd.[fixed_price_currency_id], cd.[option_strike_price], cd.[deal_volume], cd.[deal_volume_frequency],
			cd.[deal_volume_uom_id], cd.[block_description], cd.[deal_detail_description], cd.[hedge_or_item], cd.[link_id],
			cd.[percentage_included], cd.[link_effective_date], cd.[dedesignation_link_id], cd.[link_type], cd.[discount_factor],
			cd.[func_cur_value_id],cd.[und_pnl], cd.[und_intrinsic_pnl], cd.[und_extrinsic_pnl], cd.[pnl_currency_id], cd.[pnl_conversion_factor],
			cd.[pnl_source_value_id], cd.[link_active], cd.[fully_dedesignated], cd.[perfect_hedge], cd.[eff_test_profile_id],
			cd.[link_type_value_id], cd.[dedesignated_link_id], cd.[hedge_type_value_id], cd.[fx_hedge_flag], cd.[no_links], cd.[mes_gran_value_id],
			cd.[mes_cfv_value_id], cd.[mes_cfv_values_value_id], cd.[gl_grouping_value_id], cd.[mismatch_tenor_value_id],
			cd.[strip_trans_value_id], cd.[asset_liab_calc_value_id], cd.[test_range_from], cd.[test_range_to], cd.[additional_test_range_from],
			cd.[additional_test_range_to], cd.[additional_test_range_from2], cd.[additional_test_range_to2],	cd.[include_unlinked_hedges],
			cd.[include_unlinked_items], cd.[no_link], cd.[use_eff_test_profile_id], cd.[on_eff_test_approach_value_id], 
			cd.[no_links_fas_eff_test_profile_id], cd.[dedesignation_pnl_currency_id], cd.[pnl_ineffectiveness_value],
			cd.[pnl_dedesignation_value], cd.[locked_aoci_value], cd.[pnl_cur_coversion_factor], cd.[ded_pnl_cur_conversion_factor],
			cd.[eff_pnl_cur_conversion_factor], cd.[assessment_values], cd.[additional_assessment_values],
			cd.[additional_assessment_values2], cd.[use_assessment_values], cd.[use_additional_assessment_values],
			cd.[use_additional_assessment_values2], cd.[assessment_date], cd.[ddf], cd.[alpha], cd.[eff_und_pnl], cd.[eff_und_intrinsic_pnl],
			cd.[eff_und_extrinsic_pnl], cd.[eff_pnl_source_value_id], cd.[eff_pnl_currency_id], cd.[eff_pnl_conversion_factor],
			cd.[eff_pnl_as_of_date], cd.[pnl_as_of_date], cd.[dedesignation_date], cd.[deal_id], cd.[option_flag], cd.[final_dis_pnl],
			cd.[final_dis_instrinsic_pnl], cd.[final_dis_extrinsic_pnl],	cd.[final_dis_locked_aoci_value], ' +
			'final_dis_dedesignated_cum_pnl + CASE WHEN(assessment_test=0 AND isnull(lock_pmtm_assmt_failed, 0)=1) THEN  ' + @d_delta_mtm + ' ELSE 0 END final_dis_dedesignated_cum_pnl, ' +
			'cd.[final_dis_pnl_ineffectiveness_value], cd.[final_dis_pnl_dedesignation_value],
			cd.[final_dis_pnl_remaining], cd.[final_dis_pnl_intrinsic_remaining], cd.[final_dis_pnl_extrinsic_remaining],
			cd.[final_und_pnl], cd.[final_und_instrinsic_pnl], cd.[final_und_extrinsic_pnl], cd.[final_und_locked_aoci_value], ' +
			'final_und_dedesignated_cum_pnl + CASE WHEN(assessment_test=0 AND isnull(lock_pmtm_assmt_failed, 0)=1) THEN  ' + @u_delta_mtm + ' ELSE 0 END final_und_dedesignated_cum_pnl, ' +
			'cd.[final_und_pnl_ineffectiveness_value], cd.[final_und_pnl_dedesignation_value],
			cd.[final_und_pnl_remaining], cd.[final_und_pnl_intrinsic_remaining], cd.[final_und_pnl_extrinsic_remaining],
			cd.[item_match_term_month], cd.[item_term_month], cd.[long_term_months], cd.[source_system_id], cd.[include],
			cd.[hedge_term_month], cd.[eff_test_result_id], cd.[notional_pay_pnl], cd.[notional_rec_pnl], cd.[receive_float],
			cd.[carrying_amount], cd.[carrying_set_amount], cd.[interest_debt], cd.[short_cut_method], cd.[exclude_spot_forward_diff],
			cd.[option_premium], cd.[options_premium_approach], cd.[options_amortization_factor], cd.[fd_und_pnl],
			cd.[fd_und_intrinsic_pnl], cd.[fd_und_extrinsic_pnl],	cd.[fd_und_ignored_pnl], cd.[link_dedesignated_percentage],
			cd.[fas_deal_type_value_id], cd.[fas_deal_sub_type_value_id], cd.[mstm_eff_test_type_id], cd.[p_u_hedge_mtm],
			cd.[p_d_hedge_mtm], cd.[p_u_aoci], cd.[p_d_aoci], cd.[p_u_total_pnl], cd.[p_d_total_pnl], cd.[test_settled],
			cd.[rollout_per_type], cd.[tax_perc], cd.[oci_rollout_approach_value_id], cd.[link_end_date], cd.[dis_pnl], '

SET @sqlSelect = '
			assessment_test, ' + @u_aoci + ' AS u_aoci, 
			CASE	WHEN (hedge_type_value_id = 150 AND hedge_or_item = ''h'') THEN ' + @u_mtm + ' - ' + @u_aoci + ' + case when (mes_cfv_values_value_id = 401055) then final_und_pnl_extrinsic_remaining else 0 end
					WHEN (hedge_type_value_id = 151) THEN 
						CASE WHEN (assessment_test = 1 OR (assessment_test = 0 AND hedge_or_item = ''h'')) THEN ' + @u_mtm  + ' ELSE p_u_hedge_mtm END
			ELSE 0 	END + case when (hedge_or_item=''h'') then final_und_dedesignated_cum_pnl else 0 end AS u_pnl_ineffectiveness, ' +
			@u_extrinsic_pnl + ' AS u_extrinsic_pnl, 
			CASE WHEN ((hedge_type_value_id = 152 OR cd.link_type = ''deal'') AND hedge_or_item = ''h'') THEN final_und_pnl_remaining ELSE 0 END u_pnl_mtm,
			cfv_ratio, tg.dol_offset,
			' + @d_aoci + ' AS d_aoci, '

SET @sqlSelect1 = 
'
			CASE	WHEN (hedge_type_value_id = 150 AND hedge_or_item = ''h'') THEN ' + @d_mtm + ' - ' + @d_aoci + ' + case when (mes_cfv_values_value_id = 401055) then final_dis_pnl_extrinsic_remaining else 0 end
					WHEN (hedge_type_value_id = 151) THEN 
						CASE WHEN (assessment_test = 1 OR (assessment_test = 0 AND hedge_or_item = ''h'')) THEN ' + @d_mtm  + ' ELSE p_d_hedge_mtm END
			ELSE 0 	END + case when (hedge_or_item=''h'') then final_dis_dedesignated_cum_pnl else 0 end AS d_pnl_ineffectiveness, ' +
			@d_extrinsic_pnl + ' AS u_extrinsic_pnl, 
			CASE WHEN ((hedge_type_value_id = 152 OR cd.link_type = ''deal'') AND hedge_or_item = ''h'') THEN final_dis_pnl_remaining ELSE 0 END d_pnl_mtm,
			cd.prior_assessment_test

from ' + @DealProcessTableName + ' cd LEFT OUTER JOIN ' + @tempTestGranularity + ' tg ON
	tg.link_id = cd.link_id AND tg.link_type = cd.link_type AND tg.term_start = cd.term_start '
+
--Inventory Hedge Change
+
'
LEFT OUTER JOIN #reclassify_aoci ra on ra.link_id = cd.link_id and ra.source_deal_header_id = cd.source_deal_header_id 
LEFT OUTER JOIN #inventory_reclassify_aoci ira on ira.link_id = cd.link_id and ira.source_deal_header_id = cd.source_deal_header_id and
ira.term_start = cd.term_start 
'

--Inventory Hedge Change
CREATE TABLE #reclassify_aoci
(
link_id INT,
source_deal_header_id INT 
) 
--CREATE TABLE #reclassify_aoci
--(
--link_id int,
--source_deal_header_id int, 
--term_start datetime,
--reclass_aoci_value float
--) 

CREATE TABLE #inventory_reclassify_aoci
(
link_id INT,
source_deal_header_id INT, 
term_start DATETIME,
reclass_aoci_value FLOAT
) 

INSERT INTO #reclassify_aoci
SELECT  link_id, source_deal_header_id--, term_start, sum(reclass_aoci_value) reclass_aoci_value
FROM    reclassify_aoci 
WHERE	reclassify_date <= @std_as_of_date
GROUP BY link_id, source_deal_header_id--, term_start

CREATE INDEX ix_reclassify_aoci ON #reclassify_aoci (link_id, source_deal_header_id) --, term_start)

INSERT INTO #inventory_reclassify_aoci
SELECT  link_id, source_deal_header_id, term_start, SUM(reclass_aoci_value) reclass_aoci_value
FROM    inventory_reclassify_aoci 
WHERE	dbo.FNAGetContractMonth(reclassify_date) = @std_contract_month --<= @std_as_of_date
GROUP BY link_id, source_deal_header_id, term_start

CREATE INDEX ix_inventory_reclassify_aoci ON #inventory_reclassify_aoci (link_id, source_deal_header_id, term_start)

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
END

--print @sqlSelect0 
--print @sqlSelect 
--print @sqlSelect1




/* UB DEBUG
return

select * from static_data_value where value_id=150 --Cash-flow Hedges
select * from static_data_value where value_id=452 --DeDesignation - Not Probable
select * from static_data_value where value_id=500 --AOCI to Earnings
select * from static_data_value where value_id=175 --Contract-month Level
select * from static_data_value where value_id=625 --Do not apply strip logic
select * from static_data_value where value_id=250 --Ignore Term Mismatch
select * from static_data_value where value_id=252 --Apply Hedge/Item Term Mismatch
select * from static_data_value where value_id=4075 --Cum Dollar Test
select * from static_data_value where value_id=225 --Extrinsic Values in PNL
select * from static_data_value where value_id=401055 --Extrinsic Values in AOCI

		(CASE	WHEN (hedge_type_value_id = 150 AND link_type_value_id = 452) THEN  0
						WHEN (hedge_type_value_id = 150 AND hedge_or_item = 'h') THEN  
							CASE	
									--reclass due to dedesignaton from probable to not probable (aoci must be 0 now)
									WHEN (ra.source_deal_header_id IS NOT NULL) THEN 0
									--Inventory Hedge Change
									WHEN (oci_rollout_approach_value_id <> 500 AND  item_match_term_month < '2018-11-22') THEN p_u_aoci 													
									--Inventory Hedge Change   Added oci_rollout_approach_value_id = 500 AND 
									WHEN ((mes_gran_value_id=175 OR strip_trans_value_id=625) AND oci_rollout_approach_value_id = 500 AND mismatch_tenor_value_id = 250 AND test_settled > 0) THEN  p_u_aoci
									WHEN (mismatch_tenor_value_id = 252 AND 3 = 3 AND  item_match_term_month < '2018-11-22') THEN p_u_aoci 								
									WHEN ((lock_pmtm_assmt_failed <> 2 AND (assessment_test = 0 AND dol_offset > 0) OR (tg.same_sign_pnl = 1 AND tg.same_pnl_sign_value = 0))) THEN p_u_aoci 
							ELSE ISNULL(u_cfv_ratio, 0) * CASE WHEN (mstm_eff_test_type_id = 4075) THEN  ISNULL(CASE WHEN (mes_cfv_values_value_id = 225 OR mes_cfv_values_value_id = 401055) 
							THEN final_und_pnl_intrinsic_remaining ELSE final_und_pnl_remaining END, 0) 
				
				- CASE WHEN (lock_pmtm_assmt_failed = 1) THEN final_und_dedesignated_cum_pnl ELSE 0 END 
				 ELSE  ISNULL(CASE WHEN (mes_cfv_values_value_id = 225) THEN final_und_pnl_intrinsic_remaining ELSE final_und_pnl_remaining END - p_u_hedge_mtm, 0)   END 
							+ CASE WHEN (mstm_eff_test_type_id = 4075) THEN 0 ELSE isnull(p_u_aoci, 0) END --for delta method add prior cum aoci value	
						END						
				ELSE 0 END -- isnull(ra.reclass_aoci_value, 0)
				--Inventory Hedge Change
				- isnull(ira.reclass_aoci_value, 0)
				+ ISNULL(CASE WHEN (mes_cfv_values_value_id = 401055) THEN 
							  CASE WHEN (hedge_type_value_id = 150 AND hedge_or_item = 'i') THEN 0 ELSE final_und_pnl_extrinsic_remaining END
						 ELSE 0 END, 0)
				) 
			    AS u_aoci, 


SELECT	
			cd.[source_deal_header_id], cd.[term_start],assessment_test,  lock_pmtm_assmt_failed,p_d_aoci,
			
				 (CASE	WHEN (hedge_type_value_id = 150 AND link_type_value_id = 452) THEN  0
						WHEN (hedge_type_value_id = 150 AND hedge_or_item = 'h') THEN  
							CASE	
									--reclass due to dedesignaton from probable to not probable (aoci must be 0 now)
									WHEN (ra.source_deal_header_id IS NOT NULL) THEN 0
									--Inventory Hedge Change
									WHEN (oci_rollout_approach_value_id <> 500 AND  item_match_term_month < '2018-11-22') THEN p_d_aoci 													
									--Inventory Hedge Change   Added oci_rollout_approach_value_id = 500 AND 
									WHEN ((mes_gran_value_id=175 OR strip_trans_value_id=625) AND oci_rollout_approach_value_id = 500 AND mismatch_tenor_value_id = 250 AND test_settled > 0) THEN  p_d_aoci
									WHEN (mismatch_tenor_value_id = 252 AND 3 = 3 AND  item_match_term_month < '2018-11-22') THEN p_d_aoci 								
									WHEN (lock_pmtm_assmt_failed=1) then  p_d_aoci 
									WHEN ((lock_pmtm_assmt_failed <> 2 AND (assessment_test = 0 AND dol_offset > 0) OR (tg.same_sign_pnl = 1 AND tg.same_pnl_sign_value = 0))) THEN p_d_aoci 

							ELSE ISNULL(d_cfv_ratio, 0) * CASE WHEN (mstm_eff_test_type_id = 4075) 
								THEN  ISNULL(CASE WHEN (mes_cfv_values_value_id = 225 OR mes_cfv_values_value_id = 401055) THEN final_dis_pnl_intrinsic_remaining 
						ELSE final_dis_pnl_remaining END, 0)
				
				- CASE WHEN (lock_pmtm_assmt_failed = 1) THEN final_dis_dedesignated_cum_pnl  ELSE 0 END 

				 ELSE  ISNULL(CASE WHEN (mes_cfv_values_value_id = 225) THEN final_dis_pnl_intrinsic_remaining ELSE final_dis_pnl_remaining END - p_d_hedge_mtm, 0)   END 
							+ CASE WHEN (mstm_eff_test_type_id = 4075) THEN 0 ELSE isnull(p_d_aoci, 0) END --for delta method add prior cum aoci value	
						END						
				ELSE 0 END -- isnull(ra.reclass_aoci_value, 0)
				--Inventory Hedge Change
				- isnull(ira.reclass_aoci_value, 0)
				+ ISNULL(CASE WHEN (mes_cfv_values_value_id = 401055) THEN 
							  CASE WHEN (hedge_type_value_id = 150 AND hedge_or_item = 'i') THEN 0 ELSE final_dis_pnl_extrinsic_remaining END
						 ELSE 0 END, 0)				
				) 
			   AS d_aoci
			   ,u_cfv_ratio, d_cfv_ratio,final_und_pnl_intrinsic_remaining,final_dis_pnl_intrinsic_remaining
			   ,final_und_pnl_remaining,final_dis_pnl_remaining
			   ,final_und_dedesignated_cum_pnl, final_dis_dedesignated_cum_pnl
			   ,p_u_hedge_mtm,p_d_hedge_mtm
from adiha_process.dbo.calcprocess_deals_farrms_admin_123456 cd LEFT OUTER JOIN adiha_process.dbo.calcprocess_test_granularity_farrms_admin_123456 tg ON
	tg.link_id = cd.link_id AND tg.link_type = cd.link_type AND tg.term_start = cd.term_start 
LEFT OUTER JOIN #reclassify_aoci ra on ra.link_id = cd.link_id and ra.source_deal_header_id = cd.source_deal_header_id 
LEFT OUTER JOIN #inventory_reclassify_aoci ira on ira.link_id = cd.link_id and ira.source_deal_header_id = cd.source_deal_header_id and
ira.term_start = cd.term_start 
WHERE cd.link_id = 1671 and cd.source_deal_header_id = 365438 and cd.term_Start = '2019-01-01'



*/

EXEC(@sqlSelect0  + @sqlSelect + @sqlSelect1)


EXEC('create index ix_DealProcessFinalTableName on '+ @DealProcessFinalTableName+' (as_of_date,source_deal_header_id,link_id,term_start)')

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************End of Calculating Final Calcprocess Deals *****************************'	
END

EXEC('
CREATE TABLE '+@aocirelease+ '(
	[source_deal_header_id] [int] NOT NULL,
	[leg] [int] NOT NULL,
	[long_term_months] [int] NULL,
	[as_of_date] [datetime] NOT NULL,
	[link_id] [int] NULL,
	[link_type] [varchar](4)   NOT NULL,
	[h_term] [datetime] NOT NULL,
	[strip_months] [tinyint] NULL,
	[lagging_months] [tinyint] NULL,
	[strip_item_months] [tinyint] NULL,
	[i_term] [datetime] NULL,
	[per_pnl] [float] NULL,
	[per_vol] [float] NULL,
	[u_aoci] [float] NULL,
	[aoci_allocation_pnl] [float] NULL,
	[aoci_allocation_vol] [float] NULL,
	[d_aoci_allocation_pnl] [float] NULL,
	[d_aoci_allocation_vol] [float] NULL,
	[mismatch_tenor_value_id] [int] NOT NULL,
	[rollout_per_type] [int] NULL,
	[oci_rollout_approach_value_id] [int] NULL,
	[d_aoci] [float] NULL
	
) ON [PRIMARY]
')


SET @sqlSelect = 'insert into '+@AOCIRelease +' 
select cd.source_deal_header_id, cd.leg, cd.long_term_months, cd.as_of_date, cd.link_id, ''link'' as link_type, cd.term_start h_term, 
	isnull(ars.strip_months, 0) strip_months, isnull(ars.lagging_months, 0) lagging_months, isnull(ars.strip_item_months, 0) strip_item_months,
	isnull(ars.i_term, cd.term_start) term_start, isnull(ars.per_pnl, 1) per_pnl, isnull(ars.per_vol, 1) per_vol, cd.u_aoci u_aoci, 
	isnull(ars.per_pnl, 1) * cd.u_aoci aoci_allocation_pnl, 
	isnull(ars.per_vol, 1) * cd.u_aoci aoci_allocation_vol,
	isnull(ars.per_d_pnl, 1) * cd.d_aoci d_aoci_allocation_pnl, 
	isnull(ars.per_vol, 1) * cd.d_aoci d_aoci_allocation_vol,
	cd.mismatch_tenor_value_id, cd.rollout_per_type, cd.oci_rollout_approach_value_id,
	cd.d_aoci
	
FROM ' + @DealProcessFinalTableName + '	cd LEFT OUTER JOIN	'  + @AOCIReleaseSchedule + ' ars  ON
	cd.source_deal_header_id = ars.source_deal_header_id AND cd.link_id = ars.link_id AND ars.h_term = cd.term_start AND
	cd.as_of_date = ars.as_of_date
WHERE cd.hedge_type_value_id = 150 AND cd.hedge_or_item = ''h'' AND cd.u_aoci <> 0
'



IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
END

--print @sqlSelect
--return
EXEC (@sqlSelect)

--Now create index 
EXEC('create index [ix_aoci_release] on ' + @AOCIRelease + '  (link_id, link_type, i_term, as_of_date)')


IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************End of Calculating AOCI Release *****************************'	
END
----print @sqlSelect 

-------===============================ASSET/LIAB TEST AND TAX ASSET/LIAB TEST ============================================

DECLARE @sqlSelectHAT VARCHAR(8000)
DECLARE @sqlSelectHAT1 VARCHAR(8000)
DECLARE @sqlAOCITaxHAT VARCHAR(8000)
DECLARE @sqlSelectIAT VARCHAR(8000)
DECLARE @sqlSelectIAT1 VARCHAR(8000)

CREATE TABLE #hat
(link_id INT NULL, link_type VARCHAR(50) COLLATE DATABASE_DEFAULT NULL, source_deal_header_id INT, as_of_date DATETIME NULL, term_start DATETIME NULL, 
hedge_asset_test INT NULL, d_hedge_asset_test INT NULL)

CREATE TABLE #iat
(link_id INT NULL, link_type VARCHAR(50) COLLATE DATABASE_DEFAULT NULL, as_of_date DATETIME NULL, term_start DATETIME NULL, 
item_asset_test INT NULL, d_item_asset_test INT NULL)

CREATE TABLE #aoci_hat
(link_id INT NULL, link_type VARCHAR(50) COLLATE DATABASE_DEFAULT NULL, as_of_date DATETIME NULL, term_start DATETIME NULL, aoci_asset_test INT NULL)

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
END



SET @sqlSelectHAT = 
'
insert into #hat
SELECT	deal.link_id, deal.link_type, deal.source_deal_header_id, deal.as_of_date, deal.term_start, 
		CASE WHEN (isnull(total_val.u_mtm, 0) >= 0) THEN 1 ELSE 0 END hedge_asset_test,
		CASE WHEN (isnull(total_val.d_mtm, 0) >= 0) THEN 1 ELSE 0 END d_hedge_asset_test
FROM 
(
SELECT link_id, link_type, source_deal_header_id, as_of_date, term_start
from ' + @DealProcessTableName + '
where hedge_or_item = ''h'' AND term_start <= dateadd(mm, long_term_months - 1, ''' + @std_as_of_date + ''') AND leg = 1
group by link_id, link_type, source_deal_header_id, as_of_date, term_start
) deal LEFT OUTER JOIN
(
SELECT link_id, link_type, as_of_date, sum(final_und_pnl_remaining) u_mtm, sum(final_dis_pnl_remaining) d_mtm
from ' + @DealProcessTableName + '
where hedge_or_item = ''h'' AND term_start > ''' + @std_as_of_date + ''' AND 
		term_start <= dateadd(mm, long_term_months - 1, ''' + @std_as_of_date + ''')
group by link_id, link_type, as_of_date
) total_val ON total_val.link_id = deal.link_id AND total_val.link_type = deal.link_type AND 
total_val.as_of_date = deal.as_of_date
'

SET @sqlSelectHAT1 = 
'
insert into #hat
SELECT	deal.link_id, deal.link_type, deal.source_deal_header_id, deal.as_of_date, deal.term_start, 
		CASE WHEN (isnull(total_val.u_mtm, 0) >= 0) THEN 1 ELSE 0 END hedge_asset_test,
		CASE WHEN (isnull(total_val.d_mtm, 0) >= 0) THEN 1 ELSE 0 END d_hedge_asset_test
FROM 
(
SELECT link_id, source_deal_header_id, link_type, as_of_date, term_start
from ' + @DealProcessTableName + '
where hedge_or_item = ''h'' AND term_start <= dateadd(mm, long_term_months - 1, ''' + @std_as_of_date + ''') AND leg = 1
group by link_id, source_deal_header_id, link_type, as_of_date, term_start
) deal LEFT OUTER JOIN
(
SELECT source_deal_header_id, as_of_date, SUM(u_mtm) u_mtm, SUM(d_mtm) d_mtm from (
SELECT source_deal_header_id, as_of_date, term_start, max(und_pnl) u_mtm, max(dis_pnl) d_mtm
from ' + @DealProcessTableName + '
where hedge_or_item = ''h'' AND term_start > ''' + @std_as_of_date + ''' AND 
		term_start <= dateadd(mm, long_term_months - 1, ''' + @std_as_of_date + ''')
group by source_deal_header_id, as_of_date, term_start ) xx
group by source_deal_header_id, as_of_date
) total_val ON total_val.source_deal_header_id = deal.source_deal_header_id AND total_val.as_of_date = deal.as_of_date
'

IF (@asset_liab_deal = 1) 
	EXEC(@sqlSelectHAT1)
ELSE
	EXEC(@sqlSelectHAT)


--print @sqlSelectHAT
--return

SET @sqlSelectHAT = 
'INSERT INTO #hat
SELECT	deal.link_id, deal.link_type, deal.source_deal_header_id, deal.as_of_date, deal.term_start, 
		CASE WHEN (isnull(total_val.u_mtm, 0) >= 0) THEN 1 ELSE 0 END hedge_asset_test,
		CASE WHEN (isnull(total_val.d_mtm, 0) >= 0) THEN 1 ELSE 0 END d_hedge_asset_test
FROM 
(
SELECT link_id, link_type, source_deal_header_id, as_of_date, term_start
from ' + @DealProcessTableName + '
where hedge_or_item = ''h'' and term_start > dateadd(mm, long_term_months - 1, ''' + @std_as_of_date + ''') and leg = 1
group by link_id, link_type, source_deal_header_id, as_of_date, term_start
) deal LEFT OUTER JOIN
(
SELECT link_id, link_type, as_of_date, sum(final_und_pnl_remaining) u_mtm, sum(final_dis_pnl_remaining) d_mtm
from ' + @DealProcessTableName + '
where hedge_or_item = ''h'' AND term_start > dateadd(mm, long_term_months - 1, ''' + @std_as_of_date + ''')
group by link_id, link_type, as_of_date
) total_val ON total_val.link_id = deal.link_id AND total_val.link_type = deal.link_type AND 
total_val.as_of_date = deal.as_of_date 
'

SET @sqlSelectHAT1 = 
'
insert into #hat
SELECT	deal.link_id, deal.link_type, deal.source_deal_header_id, deal.as_of_date, deal.term_start, 
		CASE WHEN (isnull(total_val.u_mtm, 0) >= 0) THEN 1 ELSE 0 END hedge_asset_test,
		CASE WHEN (isnull(total_val.d_mtm, 0) >= 0) THEN 1 ELSE 0 END d_hedge_asset_test
FROM 
(
SELECT link_id, source_deal_header_id, link_type, as_of_date, term_start
from ' + @DealProcessTableName + '
where hedge_or_item = ''h'' AND term_start > dateadd(mm, long_term_months - 1, ''' + @std_as_of_date + ''') AND leg = 1
group by link_id, source_deal_header_id, link_type, as_of_date, term_start
) deal LEFT OUTER JOIN
(
SELECT source_deal_header_id, as_of_date, SUM(u_mtm) u_mtm, SUM(d_mtm) d_mtm from (
SELECT source_deal_header_id, as_of_date, term_start, max(und_pnl) u_mtm, max(dis_pnl) d_mtm
from ' + @DealProcessTableName + '
where hedge_or_item = ''h'' AND term_start > dateadd(mm, long_term_months - 1, ''' + @std_as_of_date + ''')
group by source_deal_header_id, as_of_date, term_start ) xx
group by source_deal_header_id, as_of_date
) total_val ON total_val.source_deal_header_id = deal.source_deal_header_id AND total_val.as_of_date = deal.as_of_date

'

IF (@asset_liab_deal = 1) 
	EXEC(@sqlSelectHAT1)
ELSE
	EXEC(@sqlSelectHAT)

--Now create index 
CREATE INDEX [ix_hat] ON #hat (link_id, link_type, term_start)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************End of Creating Hedge Asset Test *****************************'	
END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
END

SET @sqlSelectIAT = 
'
insert into #iat
SELECT	deal.link_id, deal.link_type, deal.as_of_date, deal.term_start, 
		CASE WHEN (ISNULL(total_val.u_mtm, 0) >= 0) THEN 1 ELSE 0 END item_asset_test,
		CASE WHEN (ISNULL(total_val.d_mtm, 0) >= 0) THEN 1 ELSE 0 END d_item_asset_test
FROM 
(
SELECT link_id, link_type, as_of_date, term_start
from ' + @DealProcessTableName + '
where hedge_or_item = ''i'' and term_start <= dateadd(mm, long_term_months - 1, ''' + @std_as_of_date + ''') and leg = 1
and hedge_type_value_id = 151
group by link_id, link_type, as_of_date, term_start
) deal LEFT OUTER JOIN
(
SELECT link_id, link_type, as_of_date, sum(final_und_pnl_remaining) u_mtm, sum(final_dis_pnl_remaining) d_mtm
from ' + @DealProcessTableName + '
where hedge_or_item = ''i'' AND term_start > ''' + @std_as_of_date + ''' AND 
		term_start <= dateadd(mm, long_term_months - 1, ''' + @std_as_of_date + ''') 
and hedge_type_value_id = 151
group by link_id, link_type, as_of_date
) total_val ON total_val.link_id = deal.link_id AND total_val.link_type = deal.link_type AND 
total_val.as_of_date = deal.as_of_date
'

SET @sqlSelectIAT1 = 
'
insert into #iat
SELECT	deal.link_id, deal.link_type, deal.as_of_date, deal.term_start, 
		CASE WHEN (isnull(total_val.u_mtm, 0) >= 0) THEN 1 ELSE 0 END item_asset_test,
		CASE WHEN (isnull(total_val.d_mtm, 0) >= 0) THEN 1 ELSE 0 END d_item_asset_test
FROM 
(
SELECT link_id, source_deal_header_id, link_type, as_of_date, term_start
from ' + @DealProcessTableName + '
where hedge_or_item = ''i'' AND term_start <= dateadd(mm, long_term_months - 1, ''' + @std_as_of_date + ''') AND leg = 1
and hedge_type_value_id = 151
group by link_id, source_deal_header_id, link_type, as_of_date, term_start
) deal LEFT OUTER JOIN
(
SELECT source_deal_header_id, as_of_date, SUM(u_mtm) u_mtm, SUM(d_mtm) d_mtm from (
SELECT source_deal_header_id, as_of_date, term_start, max(und_pnl) u_mtm, max(dis_pnl) d_mtm
from ' + @DealProcessTableName + '
where hedge_or_item = ''i'' AND term_start > ''' + @std_as_of_date + ''' AND 
		term_start <= dateadd(mm, long_term_months - 1, ''' + @std_as_of_date + ''')
and hedge_type_value_id = 151
group by source_deal_header_id, as_of_date, term_start ) xx
group by source_deal_header_id, as_of_date
) total_val ON total_val.source_deal_header_id = deal.source_deal_header_id AND total_val.as_of_date = deal.as_of_date

'

IF (@asset_liab_deal = 1) 
	EXEC(@sqlSelectIAT1)
ELSE
	EXEC(@sqlSelectIAT)


SET @sqlSelectIAT = 
' INSERT INTO #iat
SELECT	deal.link_id, deal.link_type, deal.as_of_date, deal.term_start, 
		CASE WHEN (isnull(total_val.u_mtm, 0) >= 0) THEN 1 ELSE 0 END item_asset_test,
		CASE WHEN (isnull(total_val.d_mtm, 0) >= 0) THEN 1 ELSE 0 END d_item_asset_test
FROM 
(
SELECT link_id, link_type, as_of_date, term_start
from ' + @DealProcessTableName + '
where hedge_or_item = ''i'' and term_start > dateadd(mm, long_term_months - 1, ''' + @std_as_of_date + ''') and leg = 1
and hedge_type_value_id = 151
group by link_id, link_type, as_of_date, term_start
) deal LEFT OUTER JOIN
(
SELECT link_id, link_type, as_of_date, sum(final_und_pnl_remaining) u_mtm, sum(final_dis_pnl_remaining) d_mtm
from ' + @DealProcessTableName + '
where hedge_or_item = ''i'' and term_start > dateadd(mm, long_term_months - 1, ''' + @std_as_of_date + ''')
and hedge_type_value_id = 151
group by link_id, link_type, as_of_date
) total_val ON total_val.link_id = deal.link_id AND total_val.link_type = deal.link_type AND 
total_val.as_of_date = deal.as_of_date
'

SET @sqlSelectIAT1 = 
'
insert into #iat
SELECT	deal.link_id, deal.link_type, deal.as_of_date, deal.term_start, 
		CASE WHEN (isnull(total_val.u_mtm, 0) >= 0) THEN 1 ELSE 0 END item_asset_test,
		CASE WHEN (isnull(total_val.d_mtm, 0) >= 0) THEN 1 ELSE 0 END d_item_asset_test
FROM 
(
SELECT link_id, source_deal_header_id, link_type, as_of_date, term_start
from ' + @DealProcessTableName + '
where hedge_or_item = ''i'' AND term_start > dateadd(mm, long_term_months - 1, ''' + @std_as_of_date + ''') AND leg = 1
and hedge_type_value_id = 151
group by link_id, source_deal_header_id, link_type, as_of_date, term_start
) deal LEFT OUTER JOIN
(
SELECT source_deal_header_id, as_of_date, SUM(u_mtm) u_mtm, SUM(d_mtm) d_mtm from (
SELECT source_deal_header_id, as_of_date, term_start, max(und_pnl) u_mtm, max(dis_pnl) d_mtm
from ' + @DealProcessTableName + '
where hedge_or_item = ''i'' AND term_start > dateadd(mm, long_term_months - 1, ''' + @std_as_of_date + ''')
and hedge_type_value_id = 151
group by source_deal_header_id, as_of_date, term_start ) xx
group by source_deal_header_id, as_of_date
) total_val ON total_val.source_deal_header_id = deal.source_deal_header_id AND total_val.as_of_date = deal.as_of_date
'

IF (@asset_liab_deal = 1) 
	EXEC(@sqlSelectIAT1)
ELSE
	EXEC(@sqlSelectIAT)

--Now create index 
CREATE INDEX [ix_iat] ON #iat (link_id, link_type, term_start)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************End of Creating Item Asset Test *****************************'	
END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
END

--select * from #aoci_hat

SET @sqlAOCITaxHAT = 
'
insert into #aoci_hat
SELECT i_terms.link_id, i_terms.link_type, i_terms.as_of_date, i_terms.i_term term_start, 
CASE WHEN (isnull(arelease_s.aoci, 0) < 0) THEN 1 ELSE 0 END aoci_asset_test
FROM 
(
SELECT link_id, link_type, as_of_date, i_term
from ' + @AOCIRelease + '
where i_term <= dateadd(mm, long_term_months - 1, ''' + @std_as_of_date + ''') 
group by link_id, link_type, as_of_date, i_term
) i_terms LEFT OUTER JOIN
(
SELECT	link_id, link_type, as_of_date, 
		SUM(CASE WHEN (rollout_per_type in (521, 523)) THEN isnull(aoci_allocation_pnl, 0) 
					ELSE isnull(aoci_allocation_vol, 0) END) aoci
from ' + @AOCIRelease + '
where i_term > ''' + @std_as_of_date + ''' AND i_term <= dateadd(mm, long_term_months - 1, ''' + @std_as_of_date + ''')
group by link_id, link_type, as_of_date
) arelease_s ON i_terms.link_id = arelease_s.link_id AND i_terms.link_type = arelease_s.link_type AND 
i_terms.as_of_date = arelease_s.as_of_date  

UNION ALL

SELECT i_terms.link_id, i_terms.link_type, i_terms.as_of_date, i_terms.i_term term_start, CASE WHEN (isnull(arelease_s.aoci, 0) < 0) THEN 1 ELSE 0 END aoci_asset_test
FROM 
(
SELECT link_id, link_type, as_of_date, i_term
from ' + @AOCIRelease + '
where i_term > dateadd(mm, long_term_months - 1, ''' + @std_as_of_date + ''') 
group by link_id, link_type, as_of_date, i_term
) i_terms LEFT OUTER JOIN
(
SELECT	link_id, link_type, as_of_date, 
		SUM(CASE WHEN (rollout_per_type in (521, 523)) THEN isnull(aoci_allocation_pnl, 0) 
					ELSE isnull(aoci_allocation_vol, 0) END) aoci
from ' + @AOCIRelease + '
where i_term > dateadd(mm, long_term_months - 1, ''' + @std_as_of_date + ''') 
group by link_id, link_type, as_of_date
) arelease_s ON i_terms.link_id = arelease_s.link_id AND i_terms.link_type = arelease_s.link_type AND 
i_terms.as_of_date = arelease_s.as_of_date  
'

EXEC(@sqlAOCITaxHAT)

--Now create index 
CREATE INDEX [ix_aoci_hat] ON #aoci_hat (link_id, link_type, term_start)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************End of Creating AOCI Asset Test *****************************'	
END

--select * from #tt_hedge
--select * from #tt_item

--exec(@sqlAOCITaxHAT)
--print 	@sqlAOCITaxHAT
--return


--------------------------------------END OF ASSET/LIAB TEST AND TAX ASSET/LIAB TEST ---------------------------------
DECLARE @assessment_desc VARCHAR(2500)
SET @assessment_desc =
'
CASE		 
		WHEN (max(cd.link_type) = ''deal'') then ''N/A''	
		WHEN (max(cd.on_eff_test_approach_value_id)  = 300) THEN ''Cor''
		WHEN (max(cd.on_eff_test_approach_value_id)  = 301) THEN ''RSQ''	
		WHEN (max(cd.on_eff_test_approach_value_id)  = 302) THEN ''DolOffset''	
		WHEN (max(cd.on_eff_test_approach_value_id)  = 303) THEN ''UserInput''	
		WHEN (max(cd.on_eff_test_approach_value_id)  = 304) THEN ''NoInef''	
		WHEN (max(cd.on_eff_test_approach_value_id)  = 305) THEN ''TTest''	
		WHEN (max(cd.on_eff_test_approach_value_id)  = 306) THEN ''FTest''	
		WHEN (max(cd.on_eff_test_approach_value_id)  = 307) THEN ''RSQ/TTest''	
		WHEN (max(cd.on_eff_test_approach_value_id)  = 308) THEN ''RSQ/FTest''	
		WHEN (max(cd.on_eff_test_approach_value_id)  = 309) THEN ''Cor/TTest''	
		WHEN (max(cd.on_eff_test_approach_value_id)  = 310) THEN ''Cor/FTest''	
		WHEN (max(cd.on_eff_test_approach_value_id)  = 311) THEN ''Cor/TTest/Slope''	
		WHEN (max(cd.on_eff_test_approach_value_id)  = 312) THEN ''Cor/FTest/Slope''	
		WHEN (max(cd.on_eff_test_approach_value_id)  = 313) THEN ''RSQ/TTest/Slope''	
		WHEN (max(cd.on_eff_test_approach_value_id)  = 314) THEN ''RSQ/FTest/Slope''
		WHEN (max(cd.on_eff_test_approach_value_id)  = 315) THEN ''RSQ/Slope''
		WHEN (max(cd.on_eff_test_approach_value_id)  = 316) THEN ''Cor/Slope''
		WHEN (max(cd.on_eff_test_approach_value_id)  = 317) THEN ''UnderTerms''
		WHEN (max(cd.on_eff_test_approach_value_id)  = 320) THEN ''EffTestNotRequired''	
		WHEN (max(assessment_test) = 1) THEN ''Perfect'' 
		ELSE ''UNKNOWN'' 
END
'

CREATE TABLE [dbo].[#tt_hedge](
	[as_of_date] [DATETIME] NULL,
	[fas_subsidiary_id] [INT]  NULL,
	[fas_strategy_id] [INT]  NULL,
	[fas_book_id] [INT]  NULL,
	[link_id] [INT] NULL,
	[link_deal_flag] [VARCHAR](1)   NULL,
	[term_start] [DATETIME]  NULL,
	[hedge_or_item] [VARCHAR](1)  NULL,
	[assessment_type] [VARCHAR](24)   NULL,
	[use_assessment_values] [FLOAT] NULL,
	[u_hedge_mtm] [FLOAT] NULL,
	[u_pnl_extrinsic] [FLOAT] NULL,
	[u_pnl_dedesignation] [FLOAT]  NULL,
	[u_pnl_ineffectiveness] [FLOAT] NULL,
	[u_pnl_mtm] [FLOAT] NULL,
	[u_total_pnl] [FLOAT] NULL,
	[d_hedge_mtm] [FLOAT] NULL,
	[d_pnl_extrinsic] [FLOAT] NULL,
	[d_pnl_dedesignation] [FLOAT]  NULL,
	[d_pnl_ineffectiveness] [FLOAT] NULL,
	[d_pnl_mtm] [FLOAT] NULL,
	[d_total_pnl] [FLOAT] NULL,
	[discount_factor] [FLOAT] NULL,
	[on_eff_test_approach_value_id] [INT] NULL,
	[short_term_test] [INT] NULL,
	[pnl_currency_id] [INT] NULL,
	[assessment_date] [DATETIME] NULL,
	[settled_test] [INT] NULL,
	[assessment_test] [INT] NULL,
	[cfv_test] [FLOAT] NULL,
	[hedge_type_value_id] [INT] NULL,
	[hedge_asset_test] [INT] NULL,
	[d_hedge_asset_test] [INT] NULL,
	[rollout_per_type] [INT] NULL,
	[gl_grouping_value_id] [INT] NULL,
	[oci_rollout_approach_value_id] [INT] NULL,
	[tax_perc] [FLOAT] NULL,
	[link_type_value_id] [INT] NULL
) 

CREATE TABLE [dbo].[#tt_item](
	[fas_subsidiary_id] [INT] NULL,
	[fas_strategy_id] [INT] NULL,
	[fas_book_id] [INT] NULL,
	[link_id] [INT] NULL,
	[link_deal_flag] [VARCHAR](1)   NULL,
	[assessment_type] [VARCHAR](24)   NULL,
	[as_of_date] [DATETIME] NULL,
	[use_assessment_values] [FLOAT] NULL,
	[term_start] [DATETIME] NULL,
	[u_item_mtm] [FLOAT] NULL,
	[d_item_mtm] [FLOAT] NULL,
	[aoci_allocation_pnl] [FLOAT] NULL,
	[aoci_allocation_vol] [FLOAT] NULL,
	[d_aoci_allocation_pnl] [FLOAT] NULL,
	[d_aoci_allocation_vol] [FLOAT] NULL,
	[gl_grouping_value_id] [INT] NULL,
	[item_asset_test] [INT] NULL,
	[d_item_asset_test] [INT] NULL,
	[settled_test] [INT] NOT NULL,
	[hedge_type_value_id] [INT] NULL,
	[short_term_test] [INT] NULL,
	[discount_factor] [FLOAT] NULL,
	[pnl_currency_id] [INT] NULL,
	[assessment_date] [DATETIME] NULL,
	[assessment_test] [INT] NULL,
	[oci_rollout_approach_value_id] [INT] NULL,
	[rollout_per_type] [INT] NULL,
	[aoci_asset_test] [INT] NULL,
	[tax_perc] [FLOAT] NULL,
	[u_pnl_ineffectiveness] [FLOAT] NULL,
	[d_pnl_ineffectiveness] [FLOAT] NULL,
	[link_type_value_id] [INT] NULL
)


IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
END


--This is the Hedge for cross join for final output
SET @sqlSelect2 = 
'
INSERT INTO #tt_hedge
SELECT	cd.as_of_date, cd.fas_subsidiary_id, cd.fas_strategy_id, cd.fas_book_id, cd.link_id,
		CASE WHEN (max(cd.link_type) = ''deal'') THEN ''d'' ELSE ''l'' END link_deal_flag, cd.term_start, 
		max(cd.hedge_or_item) hedge_or_item, 
		' + @assessment_desc + ' AS assessment_type, 	
		CASE WHEN (max(on_eff_test_approach_value_id) <> 302) THEN MAX(cd.use_assessment_values) ELSE MAX(dol_offset) END use_assessment_values, 
		sum(cd.final_und_pnl_remaining) u_hedge_mtm,
		sum(cd.u_extrinsic_pnl) u_pnl_extrinsic,
		sum(cd.final_und_dedesignated_cum_pnl) u_pnl_dedesignation, --locked und pnl ineff dut to assmt failed
		sum(cd.u_pnl_ineffectiveness) u_pnl_ineffectiveness,
		sum(cd.u_pnl_mtm) u_pnl_mtm,
		sum(cd.u_extrinsic_pnl + cd.u_pnl_ineffectiveness +cd.u_pnl_mtm) u_total_pnl,
		sum(cd.final_dis_pnl_remaining) d_hedge_mtm,
		sum(cd.d_extrinsic_pnl) d_pnl_extrinsic,
		sum(cd.final_dis_dedesignated_cum_pnl) as d_pnl_dedesignation, --locked dis pnl ineff dut to assmt failed
		sum(cd.d_pnl_ineffectiveness) d_pnl_ineffectiveness,
		sum(cd.d_pnl_mtm) d_pnl_mtm,
		sum(cd.d_extrinsic_pnl + cd.d_pnl_ineffectiveness + cd.d_pnl_mtm) d_total_pnl,
		max(cd.discount_factor) discount_factor,
		max(cd.on_eff_test_approach_value_id) on_eff_test_approach_value_id,
		max(case when (isnull(cd.no_links, ''n'') = ''y'' OR cd.term_start <= dateadd(mm, cd.long_term_months - 1, cd.as_of_date)) then 1 else 0 end) short_term_test,
		max(cd.pnl_currency_id) pnl_currency_id,
		max(cd.assessment_date) assessment_date,
		max(cd.test_settled) settled_test,
		max(cd.assessment_test) assessment_test,
		max(cd.cfv_ratio) cfv_test,
		max(cd.hedge_type_value_id) hedge_type_value_id,
		max(hat.hedge_asset_test) hedge_asset_test,	
		max(hat.d_hedge_asset_test) d_hedge_asset_test,	
		max(cd.rollout_per_type) rollout_per_type,
		max(cd.gl_grouping_value_id) gl_grouping_value_id,
		max(cd.oci_rollout_approach_value_id) oci_rollout_approach_value_id,
		max(cd.tax_perc) tax_perc, max(cd.link_type_value_id) link_type_value_id

FROM ' + @DealProcessFinalTableName + ' cd LEFT OUTER JOIN
	fas_strategy fs ON fs.fas_strategy_id = cd.fas_strategy_id ' +
' LEFT OUTER JOIN ' +
' #hat hat ON hat.link_id = cd.link_id AND hat.link_type = cd.link_type AND hat.term_start = cd.term_start AND
		hat.source_deal_header_id = cd.source_deal_header_id
WHERE cd.hedge_or_item = ''h'' 
GROUP BY cd.as_of_date, cd.fas_subsidiary_id, cd.fas_strategy_id, cd.fas_book_id, cd.link_id, cd.term_start
'
--select * from report_measurement_values where link_id = 248 and as_of_date = '2009-07-31'


EXEC (@sqlSelect2)


CREATE INDEX [index_tt_hedge] ON #tt_hedge(as_of_date, link_id, link_deal_flag, term_start)


IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************End of Creating Hedge for Final Transposing *****************************'	
END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
END

--InventoryHedges Changes
--This is to support release in hedge item month even though there is no actual deal
CREATE TABLE [dbo].[#tt_max_item](
	[link_id] [INT] NULL,
	[link_type] VARCHAR (5)  NULL,
	[fas_subsidiary_id] [INT] NULL,
	[fas_strategy_id] [INT] NULL,
	[fas_book_id] [INT] NULL,
	[assessment_type] [VARCHAR](24)   NULL,
	[gl_grouping_value_id] [INT] NULL,
	[discount_factor] [FLOAT] NULL,
	[pnl_currency_id] [INT] NULL,
	[oci_rollout_approach_value_id] [INT] NULL,
	[rollout_per_type] [INT] NULL,
	[tax_perc] [FLOAT] NULL,
	[link_type_value_id] [INT] NULL,
	assessment_test INT NULL,
	hedge_type_value_id INT NULL
)

SET @sqlSelect1 = 
'
insert into #tt_max_item
select link_id, link_type, max(fas_subsidiary_id) fas_subsidiary_id, max(fas_strategy_id) fas_strategy_id, max(fas_book_id) fas_book_id,
' + @assessment_desc + ' AS assessment_type,
max(gl_grouping_value_id) gl_grouping_value_id,
max(discount_factor) discount_factor, max(pnl_currency_id) pnl_currency_id, max(oci_rollout_approach_value_id) oci_rollout_approach_value_id,
max(rollout_per_type) rollout_per_type, max(tax_perc) tax_perc, max(link_type_value_id) link_type_value_id,
max(assessment_test) assessment_test, max(hedge_type_value_id) hedge_type_value_id
from ' + @DealProcessFinalTableName + ' cd
where link_type = ''link''
group by link_id, link_type
'
EXEC(@sqlSelect1)


CREATE INDEX [ix_tt_max_item] ON #tt_max_item (link_id)
--coalesce(max(tmi.assessment_type), ' + @assessment_desc + ') AS assessment_type, 
--This is the Item for cross join for final output
SET @sqlSelect3 = '
INSERT INTO #tt_item
SELECT	coalesce(cd.fas_subsidiary_id, tmi.fas_subsidiary_id) fas_subsidiary_id, 
		coalesce(cd.fas_strategy_id, tmi.fas_strategy_id) fas_strategy_id, 
		coalesce(cd.fas_book_id, tmi.fas_book_id) fas_book_id,
		coalesce(cd.link_id, ar.link_id) link_id, CASE WHEN (max(cd.link_type) = ''deal'') THEN ''d'' ELSE ''l'' END link_deal_flag, 
		max(tmi.assessment_type) assessment_type,
		coalesce(cd.as_of_date, ar.as_of_date) as_of_date, 
		CASE WHEN (max(on_eff_test_approach_value_id) <> 302) THEN MAX(cd.use_assessment_values) ELSE MAX(dol_offset) END use_assessment_values, 
		coalesce(cd.term_start, ar.term_start) term_start, 
		sum(isnull(cd.final_und_pnl_remaining, 0)) u_item_mtm, sum(isnull(cd.final_dis_pnl_remaining, 0)) d_item_mtm, 
		sum(isnull(ar.aoci_allocation_pnl, 0)) aoci_allocation_pnl, sum(isnull(ar.aoci_allocation_vol, 0)) aoci_allocation_vol,
		sum(isnull(ar.d_aoci_allocation_pnl, 0)) d_aoci_allocation_pnl
		, sum(isnull(ar.d_aoci_allocation_vol, 0)) d_aoci_allocation_vol,

		max(isnull(cd.gl_grouping_value_id, tmi.gl_grouping_value_id)) gl_grouping_value_id,
		max(iat.item_asset_test) item_asset_test, max(iat.d_item_asset_test) d_item_asset_test,
		CASE WHEN (coalesce(cd.term_start, ar.term_start) <= coalesce(cd.as_of_date, ar.as_of_date)) THEN 1 ELSE 0 END settled_test,
		max(coalesce(cd.hedge_type_value_id, tmi.hedge_type_value_id)) hedge_type_value_id,
		max(case when (cd.no_links = ''y'' OR coalesce(cd.term_start, ar.term_start) <= dateadd(mm, long_term_months - 1, coalesce(cd.as_of_date, ar.as_of_date))) then 1 else 0 end) short_term_test,
		max(isnull(cd.discount_factor, tmi.discount_factor)) discount_factor,
		max(isnull(cd.pnl_currency_id, tmi.pnl_currency_id)) pnl_currency_id,
		max(assessment_date) assessment_date,
		max(isnull(cd.assessment_test, tmi.assessment_test)) assessment_test,
		max(isnull(cd.oci_rollout_approach_value_id, tmi.oci_rollout_approach_value_id)) oci_rollout_approach_value_id,
		max(isnull(cd.rollout_per_type, tmi.rollout_per_type)) rollout_per_type,
		max(ath.aoci_asset_test) aoci_asset_test,
		max(isnull(cd.tax_perc, tmi.tax_perc)) tax_perc,
		sum(isnull(cd.u_pnl_ineffectiveness, 0)) u_pnl_ineffectiveness,
		sum(isnull(cd.d_pnl_ineffectiveness, 0)) d_pnl_ineffectiveness,
		max(isnull(cd.link_type_value_id, tmi.link_type_value_id)) link_type_value_id

FROM (SELECT	cdf.fas_subsidiary_id, cdf.fas_strategy_id, cdf.fas_book_id, cdf.link_id, cdf.as_of_date, cdf.term_start, max(cdf.link_type) link_type, 
	max(cdf.on_eff_test_approach_value_id) on_eff_test_approach_value_id, max(cdf.use_assessment_values) use_assessment_values, 
	max(cdf.dol_offset) dol_offset, sum(cdf.final_und_pnl_remaining) final_und_pnl_remaining, sum(cdf.final_dis_pnl_remaining) final_dis_pnl_remaining,
	sum(cdf.u_pnl_ineffectiveness) u_pnl_ineffectiveness, sum(cdf.d_pnl_ineffectiveness) d_pnl_ineffectiveness,
	max(cdf.gl_grouping_value_id) gl_grouping_value_id, max(cdf.hedge_type_value_id) hedge_type_value_id, max(cdf.discount_factor) discount_factor,
	max(cdf.pnl_currency_id) pnl_currency_id, max(cdf.assessment_date) assessment_date, max(cdf.assessment_test) assessment_test,
	max(cdf.oci_rollout_approach_value_id) oci_rollout_approach_value_id, max(cdf.rollout_per_type) rollout_per_type, max(cdf.long_term_months) long_term_months,
	max(cdf.tax_perc) tax_perc, max(cdf.link_type_value_id) link_type_value_id, max(isnull(fs.no_links, ''n'')) no_links FROM
' + @DealProcessFinalTableName + ' cdf LEFT OUTER JOIN
	fas_strategy fs ON fs.fas_strategy_id = cdf.fas_strategy_id 
	WHERE cdf.hedge_or_item = ''i'' and cdf.leg = 1 
	group by cdf.fas_subsidiary_id, cdf.fas_strategy_id, cdf.fas_book_id, cdf.link_id, cdf.as_of_date, cdf.term_start) cd ' + 
' FULL OUTER JOIN 
(select link_id, i_term term_start, as_of_date, sum(isnull(aoci_allocation_pnl, 0)) aoci_allocation_pnl, 
	sum(isnull(aoci_allocation_vol, 0)) aoci_allocation_vol, sum(isnull(d_aoci_allocation_pnl, 0)) d_aoci_allocation_pnl, 
	sum(isnull(d_aoci_allocation_vol, 0)) d_aoci_allocation_vol
from '  

SET @sqlSelect4 = @AOCIRelease + 
	' group by link_id, i_term, as_of_date) 
	
	
	ar ON
	cd.link_id = ar.link_id AND cd.term_start = ar.term_start AND cd.as_of_date = ar.as_of_date LEFT OUTER JOIN 
#tt_max_item tmi ON tmi.link_id = isnull(ar.link_id, cd.link_id) and (cd.link_type is null OR cd.link_type = ''link'') LEFT OUTER JOIN
#iat iat ON iat.link_id = coalesce(cd.link_id, ar.link_id) AND iat.link_type = isnull(cd.link_type, ''link'') AND 
iat.term_start = coalesce(cd.term_start, ar.term_start) LEFT OUTER JOIN 
#aoci_hat ath ON ath.link_id = cd.link_id AND ath.link_type = isnull(cd.link_type, ''link'') AND ath.term_start = coalesce(cd.term_start, ar.term_start)
--WHERE cd.hedge_or_item = ''i'' AND leg = 1 
GROUP BY coalesce(cd.fas_subsidiary_id, tmi.fas_subsidiary_id), coalesce(cd.fas_strategy_id, tmi.fas_strategy_id), 
coalesce(cd.fas_book_id, tmi.fas_book_id), coalesce(cd.link_id, ar.link_id), 
coalesce(cd.as_of_date, ar.as_of_date), coalesce(cd.term_start, ar.term_start)
'

EXEC(@sqlSelect3 + @sqlSelect4)
--print @sqlSelect3
--print @sqlSelect4

CREATE INDEX [index_tt_item] ON #tt_item(as_of_date, link_id, link_deal_flag, term_start)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************End of Creating Item for Final Transposing *****************************'	
END

IF @link_filter_id IS NOT NULL 
BEGIN
	SET @sqlSelect =
	' 
		DELETE report_measurement_values
		FROM report_measurement_values fdla
		INNER JOIN ' + @DealProcessTableName + ' cdl
		ON fdla.link_id = cdl.link_id
		AND fdla.link_deal_flag = CASE WHEN (cdl.link_type = ''deal'') THEN ''d'' ELSE ''l'' END ' +
		' AND fdla.as_of_date ' + @as_of_date_between_stmt
--		' AND fdla.as_of_date = ''' + @std_last_run_date + ''''

END	
ELSE
BEGIN		
	SET @sqlSelect =
	' 
		DELETE report_measurement_values
		FROM report_measurement_values fdla
		INNER JOIN ' + @process_books + ' cdl
		ON fdla.book_entity_id = cdl.fas_book_id ' +
		' WHERE fdla.as_of_date  ' + @as_of_date_between_stmt 
--		' WHERE fdla.as_of_date  = ''' + @std_last_run_date + ''''
END


IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
END

EXEC (@sqlSelect)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************Deleting Prior Data From Report Measurement Values Table *****************************'	
END

CREATE TABLE #RMV(
	[as_of_date] [DATETIME] NOT NULL,
	[sub_entity_id] [INT] NOT NULL,
	[strategy_entity_id] [INT] NOT NULL,
	[book_entity_id] [INT] NOT NULL,
	[link_id] [INT] NOT NULL,
	[link_deal_flag] [CHAR](10) COLLATE DATABASE_DEFAULT NOT NULL,
	[term_month] [DATETIME] NOT NULL,
	[hedge_item_flag] [CHAR](10) COLLATE DATABASE_DEFAULT NULL,
	[assessment_type] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
	[assessment_value] [FLOAT] NULL,
	[u_hedge_mtm] [FLOAT] NOT NULL,
	[u_item_mtm] [FLOAT] NOT NULL,
	[u_hedge_st_asset] [FLOAT] NOT NULL,
	[u_hedge_lt_asset] [FLOAT] NOT NULL,
	[u_hedge_st_liability] [FLOAT] NOT NULL,
	[u_hedge_lt_liability] [FLOAT] NOT NULL,
	[u_item_st_asset] [FLOAT] NOT NULL,
	[u_item_lt_asset] [FLOAT] NOT NULL,
	[u_item_st_liability] [FLOAT] NOT NULL,
	[u_item_lt_liability] [FLOAT] NOT NULL,
	[u_laoci] [FLOAT] NOT NULL,
	[u_aoci] [FLOAT] NOT NULL,
	[u_total_aoci] [FLOAT] NOT NULL,
	[u_pnl_extrinsic] [FLOAT] NOT NULL,
	[u_pnl_dedesignation] [FLOAT] NOT NULL,
	[u_pnl_ineffectiveness] [FLOAT] NOT NULL,
	[u_pnl_mtm] [FLOAT] NOT NULL,
	[u_pnl_settlement] [FLOAT] NOT NULL,
	[u_total_pnl] [FLOAT] NOT NULL,
	[U_cash] [FLOAT] NOT NULL,
	[discount_factor] [FLOAT] NOT NULL,
	[d_hedge_mtm] [FLOAT] NOT NULL,
	[d_item_mtm] [FLOAT] NOT NULL,
	[d_hedge_st_asset] [FLOAT] NOT NULL,
	[d_hedge_lt_asset] [FLOAT] NOT NULL,
	[d_hedge_st_liability] [FLOAT] NOT NULL,
	[d_hedge_lt_liability] [FLOAT] NOT NULL,
	[d_item_st_asset] [FLOAT] NOT NULL,
	[d_item_lt_asset] [FLOAT] NOT NULL,
	[d_item_st_liability] [FLOAT] NOT NULL,
	[d_item_lt_liability] [FLOAT] NOT NULL,
	[d_laoci] [FLOAT] NOT NULL,
	[d_aoci] [FLOAT] NOT NULL,
	[d_total_aoci] [FLOAT] NOT NULL,
	[d_pnl_extrinsic] [FLOAT] NOT NULL,
	[d_pnl_dedesignation] [FLOAT] NOT NULL,
	[d_pnl_ineffectiveness] [FLOAT] NOT NULL,
	[d_pnl_mtm] [FLOAT] NOT NULL,
	[d_pnl_settlement] [FLOAT] NOT NULL,
	[d_total_pnl] [FLOAT] NOT NULL,
	[d_cash] [FLOAT] NOT NULL,
	[currency_unit] [INT] NULL,
	[gl_code_hedge_st_asset] [INT] NULL,
	[gl_code_hedge_st_liability] [INT] NULL,
	[gl_code_hedge_lt_asset] [INT] NULL,
	[gl_code_hedge_lt_liability] [INT] NULL,
	[gl_code_item_st_asset] [INT] NULL,
	[gl_code_item_st_liability] [INT] NULL,
	[gl_code_item_lt_asset] [INT] NULL,
	[gl_code_item_lt_liability] [INT] NULL,
	[gl_aoci] [INT] NULL,
	[gl_pnl] [INT] NULL,
	[gl_settlement] [INT] NULL,
	[gl_cash] [INT] NULL,
	[assessment_date] [DATETIME] NULL,
	[settled_test] [INT] NULL,
	[assessment_test] [INT] NULL,
	[cfv_test] [FLOAT] NULL,
	[hedge_type_value_id] [INT] NULL,
	[hedge_asset_test] [INT] NULL,
	[item_asset_test] [INT] NULL,
	[u_unlinked_pnl_ineffectiveness] [FLOAT] NULL,
	[u_current_pnl_ineffectiveness] [FLOAT] NULL,
	[d_unlinked_pnl_ineffectiveness] [FLOAT] NULL,
	[d_current_pnl_ineffectiveness] [FLOAT] NULL,
	[u_des_pnl_ineffectiveness] [FLOAT] NULL,
	[d_des_pnl_ineffectiveness] [FLOAT] NULL,
	[gl_inventory] [INT] NULL,
	[u_pnl_inventory] [FLOAT] NULL,
	[d_pnl_inventory] [FLOAT] NULL,
	[u_aoci_released] [FLOAT] NULL,
	[aoci_asset_test] [INT] NULL,
	[u_st_tax_asset] [FLOAT] NULL,
	[u_lt_tax_asset] [FLOAT] NULL,
	[u_st_tax_liability] [FLOAT] NULL,
	[u_lt_tax_liability] [FLOAT] NULL,
	[u_tax_reserve] [FLOAT] NULL,
	[d_st_tax_asset] [FLOAT] NULL,
	[d_lt_tax_asset] [FLOAT] NULL,
	[d_st_tax_liability] [FLOAT] NULL,
	[d_lt_tax_liability] [FLOAT] NULL,
	[d_tax_reserve] [FLOAT] NULL,
	[gl_id_st_tax_asset] [INT] NULL,
	[gl_id_st_tax_liab] [INT] NULL,
	[gl_id_lt_tax_asset] [INT] NULL,
	[gl_id_lt_tax_liab] [INT] NULL,
	[gl_id_tax_reserve] [INT] NULL,
	[link_type_value_id] [INT] NULL,
	[create_user] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
	[create_ts] [DATETIME] NULL,
	[valuation_date] DATETIME NULL, 
	[d_aoci_released] FLOAT NULL
) 


SET @sqlSelect = 
'	insert into #RMV
	select ''' + @std_common_as_of_date + ''' as_of_date, coalesce(h.fas_subsidiary_id, i.fas_subsidiary_id) fas_subsidiary_id, 
		coalesce(h.fas_strategy_id, i.fas_strategy_id) fas_strategy_id, coalesce(h.fas_book_id, i.fas_book_id) fas_book_id, 
		coalesce(h.link_id, i.link_id) link_id, coalesce(h.link_deal_flag, i.link_deal_flag) link_deal_flag, 
		coalesce(h.term_start, i.term_start) term_start, coalesce(h.hedge_or_item, ''h'') hedge_item_flag, 
		coalesce(h.assessment_type, i.assessment_type) assessment_type, 	
		coalesce(h.use_assessment_values, i.use_assessment_values) use_assessment_value, 
		isnull(h.u_hedge_mtm, 0) u_hedge_mtm, isnull(i.u_item_mtm, 0) u_item_mtm, 
		CASE WHEN (h.settled_test > 0) THEN 0 ELSE			
				CASE WHEN(h.hedge_asset_test > 0 AND h.short_term_test > 0) THEN isnull(u_hedge_mtm,0) ELSE 0 END
		END As u_hedge_st_asset,		
		CASE WHEN (h.settled_test > 0) THEN 0 ELSE			
				CASE WHEN(h.hedge_asset_test > 0 AND h.short_term_test = 0) THEN isnull(u_hedge_mtm,0) ELSE 0 END
		END As u_hedge_lt_asset,
		CASE WHEN (h.settled_test > 0) THEN 0 ELSE			
				CASE WHEN(h.hedge_asset_test = 0 AND h.short_term_test > 0) THEN isnull(u_hedge_mtm,0) ELSE 0 END
		END * -1 As u_hedge_st_liability,		
		CASE WHEN (h.settled_test > 0) THEN 0 ELSE			
				CASE WHEN(h.hedge_asset_test = 0 AND h.short_term_test = 0) THEN isnull(u_hedge_mtm,0) ELSE 0 END
		END * -1 As u_hedge_lt_liability,
		CASE WHEN (i.settled_test > 0 OR i.hedge_type_value_id <> 151) THEN 0 ELSE			
				CASE WHEN(i.item_asset_test > 0 AND i.short_term_test > 0) THEN isnull(u_item_mtm,0) ELSE 0 END
		END As u_item_st_asset,		
		CASE WHEN (i.settled_test > 0 OR i.hedge_type_value_id <> 151) THEN 0 ELSE			
				CASE WHEN(i.item_asset_test > 0 AND i.short_term_test = 0) THEN isnull(u_item_mtm,0) ELSE 0 END
		END As u_item_lt_asset,
		CASE WHEN (i.settled_test > 0 OR i.hedge_type_value_id <> 151) THEN 0 ELSE			
				CASE WHEN(i.item_asset_test = 0 AND i.short_term_test > 0) THEN isnull(u_item_mtm,0) ELSE 0 END
		END * -1 As u_item_st_liability,		
		CASE WHEN (i.settled_test > 0 OR i.hedge_type_value_id <> 151) THEN 0 ELSE			
				CASE WHEN(i.item_asset_test = 0 AND i.short_term_test = 0) THEN isnull(u_item_mtm,0) ELSE 0 END
		END * -1 As u_item_lt_liability,
		0 u_laoci,
		CASE WHEN (coalesce(h.hedge_type_value_id, i.hedge_type_value_id) <> 150) THEN 0 ELSE
			CASE WHEN (coalesce(i.settled_test, h.settled_test) = 0 OR (coalesce(i.settled_test, h.settled_test) > 0 AND
						coalesce(h.oci_rollout_approach_value_id, i.oci_rollout_approach_value_id) = 502)) THEN 
					CASE WHEN (coalesce(h.rollout_per_type, i.rollout_per_type) in (521, 523)) THEN isnull(aoci_allocation_pnl, 0) 
					ELSE isnull(aoci_allocation_vol, 0) END 
			ELSE 0 END
		END u_aoci,
		CASE WHEN (coalesce(h.hedge_type_value_id, i.hedge_type_value_id) <> 150) THEN 0 ELSE
			CASE WHEN (coalesce(i.settled_test, h.settled_test) = 0 OR (coalesce(i.settled_test, h.settled_test) > 0 AND
						coalesce(h.oci_rollout_approach_value_id, i.oci_rollout_approach_value_id) = 502)) THEN 
					CASE WHEN (coalesce(h.rollout_per_type, i.rollout_per_type) in (521, 523)) THEN isnull(aoci_allocation_pnl, 0) 
					ELSE isnull(aoci_allocation_vol, 0) END 
			ELSE 0 END
		END u_total_aoci,
		CASE WHEN (h.settled_test > 0) THEN 0 ELSE isnull(h.u_pnl_extrinsic, 0) END u_pnl_extrinsic, 
		CASE WHEN (h.settled_test > 0) THEN 0 ELSE isnull(h.u_pnl_dedesignation, 0)	END u_pnl_dedesignation,
		CASE WHEN (h.settled_test > 0) THEN 0 ELSE isnull(h.u_pnl_ineffectiveness, 0) + isnull(i.u_pnl_ineffectiveness, 0) END u_pnl_ineffectiveness, 
		CASE WHEN (h.settled_test > 0) THEN 0 ELSE isnull(h.u_pnl_mtm, 0) END u_pnl_mtm,
		CASE WHEN (coalesce(i.settled_test, h.settled_test) > 0) THEN 
			CASE WHEN (coalesce(h.hedge_type_value_id, i.hedge_type_value_id) = 152) THEN isnull(h.u_hedge_mtm, 0) ELSE 0 END +
			CASE WHEN (coalesce(h.hedge_type_value_id, i.hedge_type_value_id) = 151) THEN isnull(h.u_hedge_mtm, 0) + isnull(i.u_item_mtm, 0) ELSE 0 END + -- fair value hedge
			CASE WHEN (coalesce(h.hedge_type_value_id, i.hedge_type_value_id) = 150) THEN isnull(h.u_total_pnl, 0) +
				CASE WHEN (coalesce(h.oci_rollout_approach_value_id, i.oci_rollout_approach_value_id) <> 502) THEN 
					CASE WHEN (coalesce(h.rollout_per_type, i.rollout_per_type) in (521, 523)) THEN isnull(aoci_allocation_pnl, 0) 
					ELSE isnull(aoci_allocation_vol, 0) END 
				ELSE 0 END
			ELSE 0 END	
		ELSE 0 END u_pnl_settlement,
		CASE WHEN (h.settled_test > 0) THEN 0 ELSE isnull(h.u_total_pnl, 0) + isnull(i.u_pnl_ineffectiveness, 0) END u_total_pnl, 
		CASE WHEN (h.settled_test = 0) THEN 0 ELSE isnull(h.u_hedge_mtm,0) +
			CASE WHEN (i.hedge_type_value_id = 151) THEN isnull(u_item_mtm,0) ELSE 0 END
		END u_cash,
		coalesce(h.discount_factor, i.discount_factor, 1) discount_factor, 
		isnull(h.d_hedge_mtm, 0) d_hedge_mtm, 
		isnull(i.d_item_mtm, 0) d_item_mtm, 
		CASE WHEN (h.settled_test > 0) THEN 0 ELSE			
				CASE WHEN(h.d_hedge_asset_test > 0 AND h.short_term_test > 0) THEN isnull(d_hedge_mtm,0) ELSE 0 END
		END As d_hedge_st_asset,		
		CASE WHEN (h.settled_test > 0) THEN 0 ELSE			
				CASE WHEN(h.d_hedge_asset_test > 0 AND h.short_term_test = 0) THEN isnull(d_hedge_mtm,0) ELSE 0 END
		END As d_hedge_lt_asset,
		CASE WHEN (h.settled_test > 0) THEN 0 ELSE			
				CASE WHEN(h.d_hedge_asset_test = 0 AND h.short_term_test > 0) THEN isnull(d_hedge_mtm,0) ELSE 0 END
		END * -1 As d_hedge_st_liability,		
		CASE WHEN (h.settled_test > 0) THEN 0 ELSE			
				CASE WHEN(h.d_hedge_asset_test = 0 AND h.short_term_test = 0) THEN isnull(d_hedge_mtm,0) ELSE 0 END
		END * -1 As d_hedge_lt_liability,
		CASE WHEN (i.settled_test > 0 OR i.hedge_type_value_id <> 151) THEN 0 ELSE			
				CASE WHEN(i.d_item_asset_test > 0 AND i.short_term_test > 0) THEN isnull(d_item_mtm,0) ELSE 0 END
		END As d_item_st_asset,		
		CASE WHEN (i.settled_test > 0 OR i.hedge_type_value_id <> 151) THEN 0 ELSE			
				CASE WHEN(i.d_item_asset_test > 0 AND i.short_term_test = 0) THEN isnull(d_item_mtm,0) ELSE 0 END
		END As d_item_lt_asset,
		CASE WHEN (i.settled_test > 0 OR i.hedge_type_value_id <> 151) THEN 0 ELSE			
				CASE WHEN(i.d_item_asset_test = 0 AND i.short_term_test > 0) THEN isnull(d_item_mtm,0) ELSE 0 END
		END * -1 As d_item_st_liability,		
		CASE WHEN (i.settled_test > 0 OR i.hedge_type_value_id <> 151) THEN 0 ELSE			
				CASE WHEN(i.d_item_asset_test = 0 AND i.short_term_test = 0) THEN isnull(d_item_mtm,0) ELSE 0 END
		END * -1 As d_item_lt_liability, '


SET @sqlSelect0 = 
'
		0 d_laoci,
		CASE WHEN (coalesce(h.hedge_type_value_id, i.hedge_type_value_id) <> 150) THEN 0 ELSE
			CASE WHEN (coalesce(i.settled_test, h.settled_test) = 0 OR (coalesce(i.settled_test, h.settled_test) > 0 AND
						coalesce(h.oci_rollout_approach_value_id, i.oci_rollout_approach_value_id) = 502)) THEN 
					CASE WHEN (coalesce(h.rollout_per_type, i.rollout_per_type) in (521, 523)) THEN isnull(d_aoci_allocation_pnl, 0) 
					ELSE isnull(d_aoci_allocation_vol, 0) END 
			ELSE 0 END
		END d_aoci,		
		CASE WHEN (coalesce(h.hedge_type_value_id, i.hedge_type_value_id) <> 150) THEN 0 ELSE
			CASE WHEN (coalesce(i.settled_test, h.settled_test) = 0 OR (coalesce(i.settled_test, h.settled_test) > 0 AND
						coalesce(h.oci_rollout_approach_value_id, i.oci_rollout_approach_value_id) = 502)) THEN 
					CASE WHEN (coalesce(h.rollout_per_type, i.rollout_per_type) in (521, 523)) THEN isnull(d_aoci_allocation_pnl, 0) 
					ELSE isnull(d_aoci_allocation_vol, 0) END 
			ELSE 0 END
		END d_tota_aoci,		
		CASE WHEN (h.settled_test > 0) THEN 0 ELSE isnull(h.d_pnl_extrinsic, 0) END d_pnl_extrinsic, 
		CASE WHEN (h.settled_test > 0) THEN 0 ELSE isnull(h.d_pnl_dedesignation, 0)	END d_pnl_dedesignation,
		CASE WHEN (h.settled_test > 0) THEN 0 ELSE isnull(h.d_pnl_ineffectiveness, 0) + isnull(i.d_pnl_ineffectiveness, 0) END d_pnl_ineffectiveness, 
		CASE WHEN (h.settled_test > 0) THEN 0 ELSE isnull(h.d_pnl_mtm, 0) END d_pnl_mtm,
		CASE WHEN (coalesce(i.settled_test, h.settled_test) > 0) THEN 
			CASE WHEN (coalesce(h.hedge_type_value_id, i.hedge_type_value_id) = 152) THEN isnull(h.d_hedge_mtm, 0) ELSE 0 END +
			CASE WHEN (coalesce(h.hedge_type_value_id, i.hedge_type_value_id) = 151) THEN isnull(h.d_hedge_mtm, 0) + isnull(i.d_item_mtm, 0) ELSE 0 END + -- fair value hedge
			CASE WHEN (coalesce(h.hedge_type_value_id, i.hedge_type_value_id) = 150) THEN isnull(h.d_total_pnl, 0) +
				CASE WHEN (coalesce(h.oci_rollout_approach_value_id, i.oci_rollout_approach_value_id) <> 502) THEN 
					CASE WHEN (coalesce(h.rollout_per_type, i.rollout_per_type) in (521, 523)) THEN isnull(d_aoci_allocation_pnl, 0) 
					ELSE isnull(d_aoci_allocation_vol, 0) END 
				ELSE 0 END
			ELSE 0 END	
		ELSE 0 END d_pnl_settlement,
		CASE WHEN (h.settled_test > 0) THEN 0 ELSE isnull(h.d_total_pnl, 0) + isnull(i.d_pnl_ineffectiveness, 0) END d_total_pnl, 
		CASE WHEN (h.settled_test = 0) THEN 0 ELSE isnull(h.d_hedge_mtm,0) +
			CASE WHEN (i.hedge_type_value_id = 151) THEN isnull(d_item_mtm,0) ELSE 0 END
		END d_cash,
		coalesce(h.pnl_currency_id, i.pnl_currency_id) pnl_currency_id, 
		CASE WHEN (coalesce(h.gl_grouping_value_id, i.gl_grouping_value_id) = 350) THEN fs.gl_number_id_st_asset
		     ELSE  fb.gl_number_id_st_asset
		END gl_code_hedge_st_asset,
		CASE WHEN (coalesce(h.gl_grouping_value_id, i.gl_grouping_value_id) = 350) THEN fs.gl_number_id_st_liab
		     ELSE  fb.gl_number_id_st_liab
		END gl_code_hedge_st_liability,
		CASE WHEN (coalesce(h.gl_grouping_value_id, i.gl_grouping_value_id) = 350) THEN fs.gl_number_id_lt_asset
		     ELSE  fb.gl_number_id_lt_asset
		END gl_code_hedge_lt_asset,
		CASE WHEN (coalesce(h.gl_grouping_value_id, i.gl_grouping_value_id) = 350) THEN fs.gl_number_id_lt_liab
		     ELSE  fb.gl_number_id_lt_liab
		END gl_code_hedge_lt_liability,
		CASE WHEN (coalesce(h.gl_grouping_value_id, i.gl_grouping_value_id) = 350) THEN fs.gl_number_id_item_st_asset
		     ELSE  fb.gl_number_id_item_st_asset
		END gl_code_item_st_asset,
		CASE WHEN (coalesce(h.gl_grouping_value_id, i.gl_grouping_value_id) = 350) THEN fs.gl_number_id_item_st_liab
		     ELSE  fb.gl_number_id_item_st_liab
		END gl_code_item_st_liability,
		CASE WHEN (coalesce(h.gl_grouping_value_id, i.gl_grouping_value_id) = 350) THEN fs.gl_number_id_item_lt_asset
		     ELSE  fb.gl_number_id_item_lt_asset
		END gl_code_item_lt_asset,
		CASE WHEN (coalesce(h.gl_grouping_value_id, i.gl_grouping_value_id) = 350) THEN fs.gl_number_id_item_lt_liab
		     ELSE  fb.gl_number_id_item_lt_liab
		END gl_code_item_lt_liability,
		CASE WHEN (coalesce(h.gl_grouping_value_id, i.gl_grouping_value_id) = 350) THEN fs.gl_number_id_aoci
		     ELSE  fb.gl_number_id_aoci
		END gl_aoci,
		CASE WHEN (coalesce(h.gl_grouping_value_id, i.gl_grouping_value_id) = 350) THEN fs.gl_number_id_pnl
		     ELSE  fb.gl_number_id_pnl
		END gl_pnl,
		CASE WHEN (coalesce(h.gl_grouping_value_id, i.gl_grouping_value_id) = 350) THEN fs.gl_number_id_set
		     ELSE  fb.gl_number_id_set
		END gl_settlement,
		CASE WHEN (coalesce(h.gl_grouping_value_id, i.gl_grouping_value_id) = 350) THEN fs.gl_number_id_cash
		     ELSE  fb.gl_number_id_cash
		END gl_cash,
		coalesce(h.assessment_date, i.assessment_date) assessment_date, 
		coalesce(h.settled_test, i.settled_test) settled_test, 
		coalesce(h.assessment_test, i.assessment_test) assessment_test, 
		h.cfv_test cfv_test, 
		coalesce(h.hedge_type_value_id, i.hedge_type_value_id) hedge_type_value_id,
		h.hedge_asset_test, i.item_asset_test, 
		0 as u_unlinked_pnl_ineffectiveness,
		0 as u_current_pnl_ineffectiveness,
		0 as d_unlinked_pnl_ineffectiveness,
		0 as d_current_pnl_ineffectiveness,
		0 AS u_des_pnl_ineffectiveness,
		0 d_des_pnl_ineffectiveness,
		CASE WHEN (coalesce(h.gl_grouping_value_id, i.gl_grouping_value_id) = 350) THEN fs.gl_number_id_inventory
		     ELSE  fb.gl_number_id_inventory
		END gl_inventory,
		CASE WHEN (coalesce(h.hedge_type_value_id, i.hedge_type_value_id) <> 150) THEN 0 ELSE
				CASE WHEN (coalesce(i.settled_test, h.settled_test) > 0 AND 
							coalesce(h.oci_rollout_approach_value_id, i.oci_rollout_approach_value_id) = 501) THEN 
						CASE WHEN (coalesce(h.rollout_per_type, i.rollout_per_type) in (521, 523)) THEN isnull(aoci_allocation_pnl, 0) 
						ELSE isnull(aoci_allocation_vol, 0) END 
				ELSE 0 END 			
		END u_pnl_inventory,
		CASE WHEN (coalesce(h.hedge_type_value_id, i.hedge_type_value_id) <> 150) THEN 0 ELSE
				CASE WHEN (coalesce(i.settled_test, h.settled_test) > 0 AND 
							coalesce(h.oci_rollout_approach_value_id, i.oci_rollout_approach_value_id) = 501) THEN 
						CASE WHEN (coalesce(h.rollout_per_type, i.rollout_per_type) in (521, 523)) THEN isnull(d_aoci_allocation_pnl, 0) 
						ELSE isnull(d_aoci_allocation_vol, 0) END 
				ELSE 0 END 			
		END d_pnl_inventory,
		CASE WHEN (coalesce(i.settled_test, h.settled_test) > 0 AND coalesce(h.hedge_type_value_id, i.hedge_type_value_id) = 150) THEN 
			CASE WHEN (coalesce(h.oci_rollout_approach_value_id, i.oci_rollout_approach_value_id) = 500) THEN 
				CASE WHEN (coalesce(h.rollout_per_type, i.rollout_per_type) in (521, 523)) THEN isnull(aoci_allocation_pnl, 0) 
				ELSE isnull(aoci_allocation_vol, 0) END 
			ELSE 0 END
		ELSE 0 END	u_aoci_released,
'

SET @sqlSelect1 = '
		i.aoci_asset_test aoci_asset_test, 
		CASE WHEN (coalesce(i.settled_test, h.settled_test) = 0 AND coalesce(i.short_term_test, h.short_term_test) > 0 AND 
				isnull(i.aoci_asset_test, 0) > 0) THEN
			-1 * CASE WHEN (coalesce(h.rollout_per_type, i.rollout_per_type) in (521, 523)) THEN isnull(aoci_allocation_pnl, 0) 
						ELSE isnull(aoci_allocation_vol, 0) END * coalesce(h.tax_perc, i.tax_perc) ELSE 0 END u_st_tax_asset,
		CASE WHEN (coalesce(i.settled_test, h.settled_test) = 0 AND coalesce(i.short_term_test, h.short_term_test) = 0 AND 
				isnull(i.aoci_asset_test, 0) > 0 ) THEN
			-1 * CASE WHEN (coalesce(h.rollout_per_type, i.rollout_per_type) in (521, 523)) THEN isnull(aoci_allocation_pnl, 0) 
						ELSE isnull(aoci_allocation_vol, 0) END * coalesce(h.tax_perc, i.tax_perc)  ELSE 0 END u_lt_tax_asset,

		CASE WHEN (coalesce(i.settled_test, h.settled_test) = 0 AND coalesce(i.short_term_test, h.short_term_test) > 0 AND 
				isnull(i.aoci_asset_test, 0) = 0 ) THEN
			CASE WHEN (coalesce(h.rollout_per_type, i.rollout_per_type) in (521, 523)) THEN isnull(aoci_allocation_pnl, 0) 
						ELSE isnull(aoci_allocation_vol, 0) END * coalesce(h.tax_perc, i.tax_perc)  ELSE 0 END u_st_tax_liability,

		CASE WHEN (coalesce(i.settled_test, h.settled_test) = 0 AND coalesce(i.short_term_test, h.short_term_test) = 0 AND 
				isnull(i.aoci_asset_test, 0) = 0)  THEN
			CASE WHEN (coalesce(h.rollout_per_type, i.rollout_per_type) in (521, 523)) THEN isnull(aoci_allocation_pnl, 0) 
						ELSE isnull(aoci_allocation_vol, 0) END * coalesce(h.tax_perc, i.tax_perc)  ELSE 0 END u_lt_tax_liability,
		CASE WHEN (coalesce(i.settled_test, h.settled_test) = 0)  THEN
			CASE WHEN (coalesce(h.rollout_per_type, i.rollout_per_type) in (521, 523)) THEN isnull(aoci_allocation_pnl, 0) 
			ELSE isnull(aoci_allocation_vol, 0) END * coalesce(h.tax_perc, i.tax_perc)  
		ELSE 0 END u_tax_reserve,
		CASE WHEN (coalesce(i.settled_test, h.settled_test) = 0 AND coalesce(i.short_term_test, h.short_term_test) > 0 AND 
				isnull(i.aoci_asset_test, 0) > 0) THEN
			-1 * CASE WHEN (coalesce(h.rollout_per_type, i.rollout_per_type) in (521, 523)) THEN isnull(d_aoci_allocation_pnl, 0) 
						ELSE isnull(d_aoci_allocation_vol, 0) END * coalesce(h.tax_perc, i.tax_perc) ELSE 0 END d_st_tax_asset,
		CASE WHEN (coalesce(i.settled_test, h.settled_test) = 0 AND coalesce(i.short_term_test, h.short_term_test) = 0 AND 
				isnull(i.aoci_asset_test, 0) > 0 ) THEN
			-1 * CASE WHEN (coalesce(h.rollout_per_type, i.rollout_per_type) in (521, 523)) THEN isnull(d_aoci_allocation_pnl, 0) 
						ELSE isnull(d_aoci_allocation_vol, 0) END * coalesce(h.tax_perc, i.tax_perc)  ELSE 0 END d_lt_tax_asset,
		CASE WHEN (coalesce(i.settled_test, h.settled_test) = 0 AND coalesce(i.short_term_test, h.short_term_test) > 0 AND 
				isnull(i.aoci_asset_test, 0) = 0 ) THEN
			CASE WHEN (coalesce(h.rollout_per_type, i.rollout_per_type) in (521, 523)) THEN isnull(d_aoci_allocation_pnl, 0) 
						ELSE isnull(d_aoci_allocation_vol, 0) END * coalesce(h.tax_perc, i.tax_perc)  ELSE 0 END d_st_tax_liability,
		CASE WHEN (coalesce(i.settled_test, h.settled_test) = 0 AND coalesce(i.short_term_test, h.short_term_test) = 0 AND 
				isnull(i.aoci_asset_test, 0) = 0)  THEN
			CASE WHEN (coalesce(h.rollout_per_type, i.rollout_per_type) in (521, 523)) THEN isnull(d_aoci_allocation_pnl, 0) 
						ELSE isnull(d_aoci_allocation_vol, 0) END * coalesce(h.tax_perc, i.tax_perc)  ELSE 0 END d_lt_tax_liability,
		CASE WHEN (coalesce(i.settled_test, h.settled_test) = 0)  THEN
			CASE WHEN (coalesce(h.rollout_per_type, i.rollout_per_type) in (521, 523)) THEN isnull(d_aoci_allocation_pnl, 0) 
			ELSE isnull(d_aoci_allocation_vol, 0) END * coalesce(h.tax_perc, i.tax_perc)  
		ELSE 0 END,
		CASE WHEN (coalesce(h.gl_grouping_value_id, i.gl_grouping_value_id) = 350) THEN fs.gl_id_st_tax_asset
		     ELSE  fb.gl_id_st_tax_asset
		END gl_id_st_tax_asset,
		CASE WHEN (coalesce(h.gl_grouping_value_id, i.gl_grouping_value_id) = 350) THEN fs.gl_id_st_tax_liab
		     ELSE  fb.gl_id_st_tax_liab
		END gl_id_st_tax_liab,
		CASE WHEN (coalesce(h.gl_grouping_value_id, i.gl_grouping_value_id) = 350) THEN fs.gl_id_lt_tax_asset
		     ELSE  fb.gl_id_lt_tax_asset
		END gl_id_lt_tax_asset,
		CASE WHEN (coalesce(h.gl_grouping_value_id, i.gl_grouping_value_id) = 350) THEN fs.gl_id_lt_tax_liab
		     ELSE  fb.gl_id_lt_tax_liab
		END gl_id_lt_tax_liab,
		CASE WHEN (coalesce(h.gl_grouping_value_id, i.gl_grouping_value_id) = 350) THEN fs.gl_id_tax_reserve
		     ELSE  fb.gl_id_tax_reserve
		END gl_id_tax_reserve,	
		coalesce(h.link_type_value_id, i.link_type_value_id) link_type_value_id,
		''' + @user_login_id + ''' as create_user, 
		getdate() create_ts,
		coalesce(h.as_of_date, i.as_of_date) valuation_date,
		CASE WHEN (coalesce(i.settled_test, h.settled_test) > 0 AND coalesce(h.hedge_type_value_id, i.hedge_type_value_id) = 150) THEN 
			CASE WHEN (coalesce(h.oci_rollout_approach_value_id, i.oci_rollout_approach_value_id) = 500) THEN 
				CASE WHEN (coalesce(h.rollout_per_type, i.rollout_per_type) in (521, 523)) THEN isnull(d_aoci_allocation_pnl, 0) 
				ELSE isnull(d_aoci_allocation_vol, 0) END 
			ELSE 0 END
		ELSE 0 END	d_aoci_released

FROM  '	
+
--SET @sqlSelect5 = 
' #tt_hedge h FULL OUTER JOIN #tt_item i  ON
	h.as_of_date = i.as_of_date AND h.link_id = i.link_id AND h.link_deal_flag = i.link_deal_flag AND h.term_start = i.term_start LEFT OUTER JOIN
	fas_strategy fs ON fs.fas_strategy_id = coalesce(h.fas_strategy_id, i.fas_strategy_id) LEFT OUTER JOIN
	fas_books fb ON fb.fas_book_id = coalesce(h.fas_book_id, i.fas_book_id)
--WHERE h.pnl_currency_id IS NOT NULL AND i.pnl_currency_id IS NOT NULL

' 
--temp
--+ ' ORDER BY LINK_ID'
--select * from #tt_hedge
--select * from #tt_item
--select len(@sqlSelect)
--select len(@sqlSelect0)
--select len(@sqlSelect1)


--print @sqlSelect
--PRINT @sqlSelect0
--PRINT @sqlSelect1
--return

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
END

EXEC (@sqlSelect + @sqlSelect0 + @sqlSelect1)

CREATE INDEX index_RMV ON #RMV(link_id, link_deal_flag)

--Save from temporary table to real table
INSERT INTO report_measurement_values
SELECT * FROM #RMV

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************End of Calculating Entries and Inserting in Measurement Values Table******************'	
END


---------------------------------------------------------------------------------------------
-------------------------------------------Saving fully settled values-----------------------

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
END

CREATE TABLE #m_term(link_id INT, link_type VARCHAR(1) COLLATE DATABASE_DEFAULT, max_term_start DATETIME, m_link_type VARCHAR(20) COLLATE DATABASE_DEFAULT)

--select * from adiha_process.dbo.calcprocess_deals_final_urbaral_123

--Get max term for each link_id and link_type. This includes deals also that are not in any links (mtm accounting)
SET @sqlSelect = 
'
insert into #m_term
select cd.link_id, case when(cd.link_type = ''link'') then ''l'' else ''d'' end link_type, 
		max(isnull(mterm.item_end_month, cd.term_start)) max_term_start, link_type m_link_type 
from ' + @DealProcessFinalTableName + ' cd left outer join 
' + @MTableName + ' mterm on
mterm.m_link_id = cd.link_id AND mterm.m_link_type = cd.link_type
where (link_type = ''link'' OR mterm.item_end_month IS NULL)
group by cd.link_id, cd.link_type
'
EXEC(@sqlSelect)

--Commented on Jan 17, 2010 by UB: Now using #m_term table for this.
/*
--Get all distinct ONLY links (link_type='link') with max term
create table #l_max_term(link_id int, link_type varchar(10), max_term_start datetime)
set @sqlSelect = 
'insert into #l_max_term
select link_id, link_type, max(isnull(mterm.item_end_month, cd.term_start)) max_term_start
from ' + @DealProcessFinalTableName + ' cd left outer join 
' + @MTableName + ' mterm on
mterm.m_link_id = cd.link_id 
where link_type = ''link''
group by link_id, link_type
'

exec(@sqlSelect)

select * from #l_max_term

create index index_l_max_term on #l_max_term(link_id, link_type)
*/


--Find out what max term would be if a deal was MTM because it was not fully utilized in a link 
SET @sqlSelect = 
'insert into #m_term
select source_deal_header_id, ''d'' as link_type, max(max_term_start) max_term_start, ''link'' m_link_type 
from #m_term l inner join 
--#l_max_term l inner join
' + @DealProcessFinalTableName + ' cd on  l.link_id = cd.link_id and l.m_link_type = cd.link_type
where cd.link_type = ''link''
group by source_deal_header_id
'

EXEC(@sqlSelect)

CREATE INDEX index_m_term ON #m_term(link_id, link_type)

CREATE TABLE #t_expired(link_id INT, link_type VARCHAR(1) COLLATE DATABASE_DEFAULT, m_link_type VARCHAR(10) COLLATE DATABASE_DEFAULT, max_term_start DATETIME)

SET @sqlSelect = 
'
insert into  #t_expired
select link_id, link_type, case when (link_type = ''l'') then ''link'' else ''deal'' end m_link_type,
max(max_term_start) from #m_term
group by link_id, link_type
having max(max_term_start) <= ''' + @as_of_date + ''''

EXEC(@sqlSelect)

CREATE INDEX index_t_expired ON #t_expired(link_id, link_type, m_link_type)

--Delete old values
DELETE report_measurement_values_expired
FROM report_measurement_values_expired rmve INNER JOIN
#t_expired mrmv ON mrmv.link_id = rmve.link_id AND mrmv.link_type = rmve.link_deal_flag

DELETE calcprocess_deals_expired
FROM calcprocess_deals_expired rmve INNER JOIN
#t_expired mrmv ON mrmv.link_id = rmve.link_id AND mrmv.m_link_type = rmve.link_type


--select * from #RMV	
--Insert new values
INSERT INTO report_measurement_values_expired
SELECT RMV.* FROM 
#t_expired te INNER JOIN #RMV rmv ON te.link_id = rmv.link_id AND te.link_type = rmv.link_deal_flag

SET @sqlSelect = 
'insert into calcprocess_deals_expired(
		  calc_type, fas_subsidiary_id, fas_strategy_id, fas_book_id, source_deal_header_id, deal_date, deal_type, deal_sub_type, source_counterparty_id, 
		  physical_financial_flag, as_of_date, term_start, term_end, Leg, contract_expiration_date, fixed_float_leg, buy_sell_flag, curve_id, fixed_price, 
		  fixed_price_currency_id, option_strike_price, deal_volume, deal_volume_frequency, deal_volume_uom_id, block_description, deal_detail_description, 
		  hedge_or_item, link_id, percentage_included, link_effective_date, dedesignation_link_id, link_type, discount_factor, func_cur_value_id, und_pnl, 
		  und_intrinsic_pnl, und_extrinsic_pnl, pnl_currency_id, pnl_conversion_factor, pnl_source_value_id, link_active, fully_dedesignated, perfect_hedge, 
		  eff_test_profile_id, link_type_value_id, dedesignated_link_id, hedge_type_value_id, fx_hedge_flag, no_links, mes_gran_value_id, mes_cfv_value_id, 
		  mes_cfv_values_value_id, gl_grouping_value_id, mismatch_tenor_value_id, strip_trans_value_id, asset_liab_calc_value_id, test_range_from, 
		  test_range_to, additional_test_range_from, additional_test_range_to, additional_test_range_from2, additional_test_range_to2, 
		  include_unlinked_hedges, include_unlinked_items, no_link, use_eff_test_profile_id, on_eff_test_approach_value_id, no_links_fas_eff_test_profile_id, 
		  dedesignation_pnl_currency_id, pnl_ineffectiveness_value, pnl_dedesignation_value, locked_aoci_value, pnl_cur_coversion_factor, 
		  ded_pnl_cur_conversion_factor, eff_pnl_cur_conversion_factor, assessment_values, additional_assessment_values, 
		  additional_assessment_values2, use_assessment_values, use_additional_assessment_values, use_additional_assessment_values2, 
		  assessment_date, ddf, alpha, eff_und_pnl, eff_und_intrinsic_pnl, eff_und_extrinsic_pnl, eff_pnl_source_value_id, eff_pnl_currency_id, 
		  eff_pnl_conversion_factor, eff_pnl_as_of_date, pnl_as_of_date, dedesignation_date, deal_id, option_flag, final_dis_pnl, final_dis_instrinsic_pnl, 
		  final_dis_extrinsic_pnl, final_dis_locked_aoci_value, final_dis_dedesignated_cum_pnl, final_dis_pnl_ineffectiveness_value, 
		  final_dis_pnl_dedesignation_value, final_dis_pnl_remaining, final_dis_pnl_intrinsic_remaining, final_dis_pnl_extrinsic_remaining, final_und_pnl, 
		  final_und_instrinsic_pnl, final_und_extrinsic_pnl, final_und_locked_aoci_value, final_und_dedesignated_cum_pnl, 
		  final_und_pnl_ineffectiveness_value, final_und_pnl_dedesignation_value, final_und_pnl_remaining, final_und_pnl_intrinsic_remaining, 
		  final_und_pnl_extrinsic_remaining, item_match_term_month, item_term_month, long_term_months, source_system_id, include, hedge_term_month, 
		  eff_test_result_id, notional_pay_pnl, notional_rec_pnl, receive_float, carrying_amount, carrying_set_amount, interest_debt, short_cut_method, 
		  exclude_spot_forward_diff, option_premium, options_premium_approach, options_amortization_factor, fd_und_pnl, fd_und_intrinsic_pnl, 
		  fd_und_extrinsic_pnl, fd_und_ignored_pnl, link_dedesignated_percentage, fas_deal_type_value_id, fas_deal_sub_type_value_id, 
		  mstm_eff_test_type_id, p_u_hedge_mtm, p_d_hedge_mtm, p_u_aoci, p_d_aoci, p_u_total_pnl, p_d_total_pnl, test_settled, rollout_per_type, tax_perc, 
		  oci_rollout_approach_value_id, link_end_date, assessment_test, u_aoci, u_pnl_ineffectiveness, u_extrinsic_pnl, u_pnl_mtm, cfv_ratio, dol_offset, 
		  create_user, create_ts, d_aoci, d_pnl_ineffectiveness, d_extrinsic_pnl, d_pnl_mtm, dis_pnl, valuation_date)
select    ''m'' calc_type, fas_subsidiary_id, fas_strategy_id, fas_book_id, source_deal_header_id, deal_date, deal_type, deal_sub_type, source_counterparty_id, 
		  physical_financial_flag, ''' + @std_common_as_of_date + ''' as_of_date, term_start, term_end, Leg, contract_expiration_date, fixed_float_leg, buy_sell_flag, curve_id, fixed_price, 
		  fixed_price_currency_id, option_strike_price, deal_volume, deal_volume_frequency, deal_volume_uom_id, block_description, deal_detail_description, 
		  hedge_or_item, cd.link_id, percentage_included, link_effective_date, dedesignation_link_id, cd.link_type, discount_factor, func_cur_value_id, und_pnl, 
		  und_intrinsic_pnl, und_extrinsic_pnl, pnl_currency_id, pnl_conversion_factor, pnl_source_value_id, link_active, fully_dedesignated, perfect_hedge, 
		  eff_test_profile_id, link_type_value_id, dedesignated_link_id, hedge_type_value_id, fx_hedge_flag, no_links, mes_gran_value_id, mes_cfv_value_id, 
		  mes_cfv_values_value_id, gl_grouping_value_id, mismatch_tenor_value_id, strip_trans_value_id, asset_liab_calc_value_id, test_range_from, 
		  test_range_to, additional_test_range_from, additional_test_range_to, additional_test_range_from2, additional_test_range_to2, 
		  include_unlinked_hedges, include_unlinked_items, no_link, use_eff_test_profile_id, on_eff_test_approach_value_id, no_links_fas_eff_test_profile_id, 
		  dedesignation_pnl_currency_id, pnl_ineffectiveness_value, pnl_dedesignation_value, locked_aoci_value, pnl_cur_coversion_factor, 
		  ded_pnl_cur_conversion_factor, eff_pnl_cur_conversion_factor, assessment_values, additional_assessment_values, 
		  additional_assessment_values2, use_assessment_values, use_additional_assessment_values, use_additional_assessment_values2, 
		  assessment_date, ddf, alpha, eff_und_pnl, eff_und_intrinsic_pnl, eff_und_extrinsic_pnl, eff_pnl_source_value_id, eff_pnl_currency_id, 
		  eff_pnl_conversion_factor, eff_pnl_as_of_date, pnl_as_of_date, dedesignation_date, deal_id, option_flag, final_dis_pnl, final_dis_instrinsic_pnl, 
		  final_dis_extrinsic_pnl, final_dis_locked_aoci_value, final_dis_dedesignated_cum_pnl, final_dis_pnl_ineffectiveness_value, 
		  final_dis_pnl_dedesignation_value, final_dis_pnl_remaining, final_dis_pnl_intrinsic_remaining, final_dis_pnl_extrinsic_remaining, final_und_pnl, 
		  final_und_instrinsic_pnl, final_und_extrinsic_pnl, final_und_locked_aoci_value, final_und_dedesignated_cum_pnl, 
		  final_und_pnl_ineffectiveness_value, final_und_pnl_dedesignation_value, final_und_pnl_remaining, final_und_pnl_intrinsic_remaining, 
		  final_und_pnl_extrinsic_remaining, item_match_term_month, item_term_month, long_term_months, source_system_id, include, hedge_term_month, 
		  eff_test_result_id, notional_pay_pnl, notional_rec_pnl, receive_float, carrying_amount, carrying_set_amount, interest_debt, short_cut_method, 
		  exclude_spot_forward_diff, option_premium, options_premium_approach, options_amortization_factor, fd_und_pnl, fd_und_intrinsic_pnl, 
		  fd_und_extrinsic_pnl, fd_und_ignored_pnl, link_dedesignated_percentage, fas_deal_type_value_id, fas_deal_sub_type_value_id, 
		  mstm_eff_test_type_id, p_u_hedge_mtm, p_d_hedge_mtm, p_u_aoci, p_d_aoci, p_u_total_pnl, p_d_total_pnl, test_settled, rollout_per_type, tax_perc, 
		  oci_rollout_approach_value_id, link_end_date, assessment_test, u_aoci, u_pnl_ineffectiveness, u_extrinsic_pnl, u_pnl_mtm, cfv_ratio, dol_offset, 
		  ''' + @user_login_id + ''' as create_user, getdate() create_ts, d_aoci, d_pnl_ineffectiveness, d_extrinsic_pnl, d_pnl_mtm, dis_pnl, as_of_date
from #t_expired te INNER JOIN ' + 
@DealProcessFinalTableName + ' cd on te.link_id = cd.link_id and te.m_link_type = cd.link_type '

--SET @sqlSelect = 
--'insert into calcprocess_deals_expired
--select ''m'', cd.*, ''' + @user_login_id + ''' as create_user, getdate() create_ts from #t_expired te INNER JOIN ' + 
--@DealProcessFinalTableName + ' cd on te.link_id = cd.link_id and te.m_link_type = cd.link_type '

EXEC(@sqlSelect)

--set @sqlSelect = 'insert into calcprocess_deals select ''m'', *, ''' + @user_login_id + ''' as create_user, 
--		getdate() create_ts  from ' + @DealProcessFinalTableName

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************End of Saving Data in Expired Table *****************************'	
END

-------------------------------------------End of Saving fully settled values---------------
---------------------------------------------------------------------------------------------


-----DELETE CALCPROCESS_DEALS AND INSERT NEW ONE
SET @sqlSelect = 'DELETE CALCPROCESS_AOCI_RELEASE
		FROM CALCPROCESS_AOCI_RELEASE car
		INNER JOIN ' + @DealProcessTableName + ' cd
		ON car.link_id = cd.link_id ' +
		' AND car.as_of_date  ' + @as_of_date_between_stmt
--		' AND car.as_of_date  = ''' + @std_last_run_date + ''''

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
END

EXEC(@sqlSelect)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************Deleting Prior Data from Calcprocess AOCI Release Table******************'	
END

SET @sqlSelect = 'insert into CALCPROCESS_AOCI_RELEASE 
	(
	source_deal_header_id, leg, long_term_months, as_of_date, link_id, link_type, h_term, strip_months, lagging_months, strip_item_months, i_term, 
	per_pnl, per_vol, u_aoci, aoci_allocation_pnl, aoci_allocation_vol, d_aoci_allocation_pnl, d_aoci_allocation_vol, mismatch_tenor_value_id, 
	rollout_per_type, oci_rollout_approach_value_id, create_user, create_date, d_aoci)
select	source_deal_header_id, leg, long_term_months, ''' + @std_common_as_of_date + ''' as_of_date, link_id, link_type, h_term, strip_months, lagging_months, strip_item_months, i_term, 
		per_pnl, per_vol, u_aoci, aoci_allocation_pnl, aoci_allocation_vol, d_aoci_allocation_pnl, d_aoci_allocation_vol, mismatch_tenor_value_id, 
		rollout_per_type, oci_rollout_approach_value_id, ''' + @user_login_id + ''' as create_user, 
		getdate() create_ts, d_aoci  from ' + @AOCIRelease

--set @sqlSelect = 'insert into CALCPROCESS_AOCI_RELEASE select *, ''' + @user_login_id + ''' as create_user, 
--		getdate() create_ts  from ' + @AOCIRelease

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
END

EXEC(@sqlSelect) 

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************Inserting into  Calcprocess AOCI Release Table******************'	
END

IF @link_filter_id IS NOT NULL 
BEGIN
	SET @sqlSelect =
	' 
		DELETE TOP (5000) calcprocess_deals
		FROM calcprocess_deals fdla
		INNER JOIN ' + @DealProcessTableName + ' cdl
		ON fdla.link_id = cdl.link_id
		AND fdla.link_type = cdl.link_type ' +
		' AND fdla.as_of_date  ' + @as_of_date_between_stmt 
--		' AND fdla.as_of_date  = ''' + @std_last_run_date + '''' 
END	
ELSE
BEGIN		
	SET @sqlSelect =
	' 
		DELETE TOP (5000) calcprocess_deals
		FROM calcprocess_deals fdla
		INNER JOIN ' + @process_books + ' cdl
		ON fdla.fas_book_id = cdl.fas_book_id ' +
		' WHERE fdla.as_of_date  ' + @as_of_date_between_stmt
--		' WHERE fdla.as_of_date  = ''' + @std_last_run_date + '''' 
END


IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
END


WHILE 1 = 1
BEGIN
	EXEC (@sqlSelect)
	IF @@ROWCOUNT < 5000 BREAK;
END

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************Deleting Prior Data from Calcprocess Deals ******************'	
END


SET @sqlSelect = 
'insert into calcprocess_deals(
		  calc_type, fas_subsidiary_id, fas_strategy_id, fas_book_id, source_deal_header_id, deal_date, deal_type, deal_sub_type, source_counterparty_id, 
          physical_financial_flag, as_of_date, term_start, term_end, Leg, contract_expiration_date, fixed_float_leg, buy_sell_flag, curve_id, fixed_price, 
          fixed_price_currency_id, option_strike_price, deal_volume, deal_volume_frequency, deal_volume_uom_id, block_description, deal_detail_description, 
          hedge_or_item, link_id, percentage_included, link_effective_date, dedesignation_link_id, link_type, discount_factor, func_cur_value_id, und_pnl, 
          und_intrinsic_pnl, und_extrinsic_pnl, pnl_currency_id, pnl_conversion_factor, pnl_source_value_id, link_active, fully_dedesignated, perfect_hedge, 
          eff_test_profile_id, link_type_value_id, dedesignated_link_id, hedge_type_value_id, fx_hedge_flag, no_links, mes_gran_value_id, mes_cfv_value_id, 
          mes_cfv_values_value_id, gl_grouping_value_id, mismatch_tenor_value_id, strip_trans_value_id, asset_liab_calc_value_id, test_range_from, 
          test_range_to, additional_test_range_from, additional_test_range_to, additional_test_range_from2, additional_test_range_to2, 
          include_unlinked_hedges, include_unlinked_items, no_link, use_eff_test_profile_id, on_eff_test_approach_value_id, no_links_fas_eff_test_profile_id, 
          dedesignation_pnl_currency_id, pnl_ineffectiveness_value, pnl_dedesignation_value, locked_aoci_value, pnl_cur_coversion_factor, 
          ded_pnl_cur_conversion_factor, eff_pnl_cur_conversion_factor, assessment_values, additional_assessment_values, 
          additional_assessment_values2, use_assessment_values, use_additional_assessment_values, use_additional_assessment_values2, 
          assessment_date, ddf, alpha, eff_und_pnl, eff_und_intrinsic_pnl, eff_und_extrinsic_pnl, eff_pnl_source_value_id, eff_pnl_currency_id, 
          eff_pnl_conversion_factor, eff_pnl_as_of_date, pnl_as_of_date, dedesignation_date, deal_id, option_flag, final_dis_pnl, final_dis_instrinsic_pnl, 
          final_dis_extrinsic_pnl, final_dis_locked_aoci_value, final_dis_dedesignated_cum_pnl, final_dis_pnl_ineffectiveness_value, 
          final_dis_pnl_dedesignation_value, final_dis_pnl_remaining, final_dis_pnl_intrinsic_remaining, final_dis_pnl_extrinsic_remaining, final_und_pnl, 
          final_und_instrinsic_pnl, final_und_extrinsic_pnl, final_und_locked_aoci_value, final_und_dedesignated_cum_pnl, 
          final_und_pnl_ineffectiveness_value, final_und_pnl_dedesignation_value, final_und_pnl_remaining, final_und_pnl_intrinsic_remaining, 
          final_und_pnl_extrinsic_remaining, item_match_term_month, item_term_month, long_term_months, source_system_id, include, hedge_term_month, 
          eff_test_result_id, notional_pay_pnl, notional_rec_pnl, receive_float, carrying_amount, carrying_set_amount, interest_debt, short_cut_method, 
          exclude_spot_forward_diff, option_premium, options_premium_approach, options_amortization_factor, fd_und_pnl, fd_und_intrinsic_pnl, 
          fd_und_extrinsic_pnl, fd_und_ignored_pnl, link_dedesignated_percentage, fas_deal_type_value_id, fas_deal_sub_type_value_id, 
          mstm_eff_test_type_id, p_u_hedge_mtm, p_d_hedge_mtm, p_u_aoci, p_d_aoci, p_u_total_pnl, p_d_total_pnl, test_settled, rollout_per_type, tax_perc, 
          oci_rollout_approach_value_id, link_end_date, assessment_test, u_aoci, u_pnl_ineffectiveness, u_extrinsic_pnl, u_pnl_mtm, cfv_ratio, dol_offset, 
          create_user, create_ts, d_aoci, d_pnl_ineffectiveness, d_extrinsic_pnl, d_pnl_mtm, dis_pnl, valuation_date)
select	  ''m'' calc_type, fas_subsidiary_id, fas_strategy_id, fas_book_id, source_deal_header_id, deal_date, deal_type, deal_sub_type, source_counterparty_id, 
          physical_financial_flag, ''' + @std_common_as_of_date + ''' as_of_date, term_start, term_end, Leg, contract_expiration_date, fixed_float_leg, buy_sell_flag, curve_id, fixed_price, 
          fixed_price_currency_id, option_strike_price, deal_volume, deal_volume_frequency, deal_volume_uom_id, block_description, deal_detail_description, 
          hedge_or_item, link_id, percentage_included, link_effective_date, dedesignation_link_id, link_type, discount_factor, func_cur_value_id, und_pnl, 
          und_intrinsic_pnl, und_extrinsic_pnl, pnl_currency_id, pnl_conversion_factor, pnl_source_value_id, link_active, fully_dedesignated, perfect_hedge, 
          eff_test_profile_id, link_type_value_id, dedesignated_link_id, hedge_type_value_id, fx_hedge_flag, no_links, mes_gran_value_id, mes_cfv_value_id, 
          mes_cfv_values_value_id, gl_grouping_value_id, mismatch_tenor_value_id, strip_trans_value_id, asset_liab_calc_value_id, test_range_from, 
          test_range_to, additional_test_range_from, additional_test_range_to, additional_test_range_from2, additional_test_range_to2, 
          include_unlinked_hedges, include_unlinked_items, no_link, use_eff_test_profile_id, on_eff_test_approach_value_id, no_links_fas_eff_test_profile_id, 
          dedesignation_pnl_currency_id, pnl_ineffectiveness_value, pnl_dedesignation_value, locked_aoci_value, pnl_cur_coversion_factor, 
          ded_pnl_cur_conversion_factor, eff_pnl_cur_conversion_factor, assessment_values, additional_assessment_values, 
          additional_assessment_values2, use_assessment_values, use_additional_assessment_values, use_additional_assessment_values2, 
          assessment_date, ddf, alpha, eff_und_pnl, eff_und_intrinsic_pnl, eff_und_extrinsic_pnl, eff_pnl_source_value_id, eff_pnl_currency_id, 
          eff_pnl_conversion_factor, eff_pnl_as_of_date, pnl_as_of_date, dedesignation_date, deal_id, option_flag, final_dis_pnl, final_dis_instrinsic_pnl, 
          final_dis_extrinsic_pnl, final_dis_locked_aoci_value, final_dis_dedesignated_cum_pnl, final_dis_pnl_ineffectiveness_value, 
          final_dis_pnl_dedesignation_value, final_dis_pnl_remaining, final_dis_pnl_intrinsic_remaining, final_dis_pnl_extrinsic_remaining, final_und_pnl, 
          final_und_instrinsic_pnl, final_und_extrinsic_pnl, final_und_locked_aoci_value, final_und_dedesignated_cum_pnl, 
          final_und_pnl_ineffectiveness_value, final_und_pnl_dedesignation_value, final_und_pnl_remaining, final_und_pnl_intrinsic_remaining, 
          final_und_pnl_extrinsic_remaining, item_match_term_month, item_term_month, long_term_months, source_system_id, include, hedge_term_month, 
          eff_test_result_id, notional_pay_pnl, notional_rec_pnl, receive_float, carrying_amount, carrying_set_amount, interest_debt, short_cut_method, 
          exclude_spot_forward_diff, option_premium, options_premium_approach, options_amortization_factor, fd_und_pnl, fd_und_intrinsic_pnl, 
          fd_und_extrinsic_pnl, fd_und_ignored_pnl, link_dedesignated_percentage, fas_deal_type_value_id, fas_deal_sub_type_value_id, 
          mstm_eff_test_type_id, p_u_hedge_mtm, p_d_hedge_mtm, p_u_aoci, p_d_aoci, p_u_total_pnl, p_d_total_pnl, test_settled, rollout_per_type, tax_perc, 
          oci_rollout_approach_value_id, link_end_date, 
		  CASE WHEN ( link_type_value_id = 451 AND prior_assessment_Test=0) THEN prior_assessment_test ELSE assessment_test END, 
		  u_aoci, u_pnl_ineffectiveness, u_extrinsic_pnl, u_pnl_mtm, cfv_ratio, dol_offset, 
          ''' + @user_login_id + ''' as create_user, getdate() create_ts, d_aoci, d_pnl_ineffectiveness, d_extrinsic_pnl, d_pnl_mtm, dis_pnl, as_of_date
from ' + @DealProcessFinalTableName

--set @sqlSelect = 'insert into calcprocess_deals select ''m'', *, ''' + @user_login_id + ''' as create_user, 
--		getdate() create_ts  from ' + @DealProcessFinalTableName

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
END

EXEC(@sqlSelect) 

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************Inserting Data in Calcprocess Deals ******************'	
END

------------------NOW SAVE REGRESSION PNL SERIES

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
END


CREATE TABLE #links_reg (link_id_reg INT)

EXEC(
'insert into #links_reg 
select l.link_id from 
(select link_id, max(use_eff_test_profile_id) eff_test_profile_id 
from ' + @DealProcessTableName + '
group by link_id) l inner join
fas_eff_hedge_rel_type r on r.eff_test_profile_id = l.eff_test_profile_id
--where r.on_assmt_curve_type_value_id = 79 OR r.on_assmt_curve_type_value_id = 85
'
)

DELETE cum_pnl_series
FROM cum_pnl_series cps INNER JOIN
	 #links_reg lr ON cps.link_id = lr.link_id_reg AND
			cps.as_of_date = @as_of_date

EXEC(
'
insert into cum_pnl_series ([as_of_date],[link_id],[u_h_mtm],[u_i_mtm],[d_h_mtm],[d_i_mtm],[create_user],[create_ts])
select val.* from #links_reg lr INNER JOIN
(
select  ''' + @as_of_date + ''' as_of_date, 
		coalesce(h.link_id, i.link_id) link_id,
		isnull(h.u_reg_pnl, 0) u_h_mtm, isnull(i.u_reg_pnl, 0) u_i_mtm, 
		isnull(h.d_reg_pnl, 0) d_h_mtm, isnull(i.d_reg_pnl, 0) d_i_mtm, 
		''' + @user_login_id + ''' create_user,
		getdate() create_ts
from 
(select link_id, sum(u_reg_pnl) u_reg_pnl, sum(d_reg_pnl) d_reg_pnl  
from ' + @DollarOffsetTableName + '
inner join #links_reg l on link_id_reg = link_id 
where hedge_or_item = ''h''
group by link_id) h
FULL OUTER JOIN
(
select link_id, sum(u_reg_pnl) u_reg_pnl, sum(d_reg_pnl) d_reg_pnl  
from ' + @DollarOffsetTableName + '
inner join #links_reg l on link_id_reg = link_id
where hedge_or_item = ''i''
group by link_id) i ON h.link_id = i.link_id
) val ON lr.link_id_reg = val.link_id
WHERE (u_h_mtm <> 0 OR d_h_mtm <> 0)
'
)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************End of Saving regression PNL series *****************************'	
END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
END

EXEC('DELETE measurement_run_dates WHERE year(as_of_date) = year(''' + @std_as_of_date + ''') AND
month(as_of_date) = month(''' + @std_as_of_date + ''') ')

EXEC('INSERT INTO measurement_run_dates SELECT ''' + @std_common_as_of_date + ''' as_of_date, ''' + @user_login_id + ''' as create_user, getdate() create_ts')

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************End of Saving Run as of Date *****************************'	
END

--Now update the process_table_location which says which table has the results
IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
END

DELETE process_table_location WHERE YEAR(as_of_date) = YEAR(@std_contract_month) AND MONTH(as_of_date) = MONTH(@std_contract_month) AND 
		(tbl_name = 'calcprocess_deals' OR 
		tbl_name = 'calcprocess_aoci_release' OR tbl_name = 'report_measurement_values' OR 
		tbl_name = 'report_netted_gl_entry') 

INSERT process_table_location (as_of_date, tbl_name) VALUES(@std_contract_month , 'calcprocess_deals')
INSERT process_table_location (as_of_date, tbl_name) VALUES(@std_contract_month , 'calcprocess_aoci_release')
INSERT process_table_location (as_of_date, tbl_name) VALUES(@std_contract_month , 'report_measurement_values')
INSERT process_table_location (as_of_date, tbl_name) VALUES(@std_contract_month , 'report_netted_gl_entry')

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************End of Saving Date in process table location *****************************'	
END
---------------------------------------END OF CALCULATE REQUIRED TESTING PARAMETERS -------------------

----=========================CLEAN UP AND FINAL STEPS=============================================

-- Place all hedges cfv not matching to aoci/settlement or assets/liabilities as error
IF @dedesignation_calc <> 'd' AND @print_diagnostic = 1
BEGIN

	IF @print_diagnostic = 1
	BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
		SET @log_time=GETDATE()
		PRINT @pr_name+' Running..............'
	END

	DECLARE @url_m_report VARCHAR(1000)

	--Test to make sure hedge value = assets/liabiltiies + Cash = AOCI + PNL
	SET @url_m_report = './spa_html.php?__user_name__=' + @user_login_id + '&spa=EXEC spa_Create_Hedges_Measurement_Report ''''' + @std_as_of_date + ''''', NULL, NULL, NULL, ' + 
							'''''d'''', ''''a'''', ''''c'''', ''''d'''', ' 

	SET @sqlSelect = '
	INSERT INTO measurement_process_status(subsidiary_entity_id, can_proceed, process_id, status_code, status_description, run_as_of_date)
	SELECT	-100, ''n'', ''' + @process_id + ''', ''Error'',  ' +
	'''' + '<a target="_blank" href="' + @url_m_report + ''''''' +  cast(RMV.link_id as varchar) +  '''''''  + '">' + 
			'Either assets/liabilities or AOCI/Earnings dont match with fair value of hedge for Link: '' + cast(RMV.link_id as varchar) + ''</a> '', '
	+ '''' + @std_as_of_date + ''''  +

	' FROM	portfolio_hierarchy PH2 INNER JOIN
			portfolio_hierarchy PH1 INNER JOIN
			report_measurement_values RMV INNER JOIN
				portfolio_hierarchy PH ON RMV.sub_entity_id = PH.entity_id ON PH1.entity_id = RMV.strategy_entity_id ON 
				PH2.entity_id = RMV.book_entity_id
			INNER JOIN fas_strategy FS ON RMV.strategy_entity_id = FS.fas_strategy_id 

	INNER JOIN (select distinct link_id, CASE WHEN (link_type = ''deal'') THEN ''d'' ELSE ''l'' END link_deal_flag, as_of_date,
		term_start term_month, hedge_type_value_id from ' + @DealProcessFinalTableName + ') dfw ON RMV.link_id = dfw.link_id AND

			RMV.link_deal_flag = dfw.link_deal_flag AND RMV.term_month = dfw.term_month
		AND RMV.as_of_date = dfw.as_of_date
			WHERE dfw.hedge_type_value_id = 150
	GROUP BY RMV.as_of_date, PH.entity_name, PH1.entity_name, PH2.entity_name, RMV.link_id,  
	UPPER(RMV.link_deal_flag)
	HAVING ABS(sum(round(RMV.u_hedge_mtm, 2)) - 
		(sum(round(RMV.u_hedge_st_asset, 2)) - sum(round(RMV.u_hedge_st_liability, 2)) + 
			sum(round(RMV.u_hedge_lt_asset, 2)) - sum(round(RMV.u_hedge_lt_liability, 2)) + sum(round(RMV.u_cash, 2)))) > 1 OR
	ABS(sum(round(RMV.u_hedge_mtm, 2)) - 
	(sum(round(RMV.u_total_aoci, 2)) + sum(round(RMV.u_total_pnl, 2)) + sum(round(RMV.u_pnl_settlement, 2)) + sum(round(RMV.u_pnl_inventory, 2))))  > 1
	order by rmv.link_id
	'

	--print @sqlSelect
	--return

	IF @print_diagnostic = 1
	BEGIN
		SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
		SET @log_increment = @log_increment + 1
		SET @log_time=GETDATE()
		PRINT @pr_name+' Running..............'
	END

	EXEC(@sqlSelect)

	IF @print_diagnostic = 1
	BEGIN
		PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
		PRINT '****************Inserting Links to Measurement report in Message Board ******************'	
	END

END

IF @print_diagnostic = 1
		PRINT 'End of Accrual Calc Entries'

----------------DROP ALL PROCESS TABLES ----------------------------

IF @print_diagnostic = 0
BEGIN
	DECLARE @deleteStmt VARCHAR(1500)

	--print 'DELETING PROCESS TABLES'

	SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@DealProcessTableName)
	EXEC (@deleteStmt)
	SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@DealProcessFinalTableName)
	EXEC (@deleteStmt)
	SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@tempTestGranularity)
	EXEC (@deleteStmt)
	SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@AOCIReleaseSchedule)
	EXEC (@deleteStmt)
	SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@AOCIRelease)
	EXEC (@deleteStmt)
	SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@DollarOffsetTableName)
	EXEC (@deleteStmt)
	SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@process_books)
	EXEC (@deleteStmt)
	SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@MTableName)
	EXEC (@deleteStmt)
END


IF @print_diagnostic = 1 
	PRINT 'END OF Deleting Process Tables'
----==============================================================================================
----------------END OF DROP ALL PROCESS TABLES ---------------------------------------------------

StatusMessage:


DECLARE @error_count INT
DECLARE @desc VARCHAR(8000)
DECLARE @status VARCHAR(10)

SELECT @error_count = COUNT (*) FROM measurement_process_status 
WHERE process_id = @process_id AND can_proceed = 'n' --and calc_type = @dedesignation_calc

IF @error_count > 0
BEGIN
	SET @desc = 'ERROR(s) found during ' + CASE WHEN (@dedesignation_calc = 'd') THEN 
							'De-designation calculation'
							ELSE
							'Measurement calculation' END
							+ ' as of ' + dbo.FNAUserDateFormat(@as_of_date, @user_login_id)
	SET @status= 'Error'
END
ELSE
BEGIN
	SELECT @error_count = COUNT (*) FROM measurement_process_status 
		WHERE process_id = @process_id AND can_proceed = 'y' --and calc_type = @dedesignation_calc

	
	IF @error_count > 0
		SET @desc = 'Warnings(s) found during ' + CASE WHEN (@dedesignation_calc = 'd') THEN 
								'De-designation calculation'
								ELSE
								'Measurement calculation' END
							+  ' as of ' + dbo.FNAUserDateFormat(@as_of_date, @user_login_id) +
							'. Process completed with Warnings.'
	ELSE
		SET @desc = CASE WHEN (@dedesignation_calc = 'd') THEN 
				'De-designation calculation completed.'
				ELSE 'Measurement calculation completed. ' END + ' as of ' + 
				dbo.FNAUserDateFormat(@as_of_date,  @user_login_id)

	SET @status = 'Success'

END

-------insert into status table
IF @@ERROR <> 0
BEGIN

	DECLARE @errorMsg  VARCHAR(500)
	SELECT @errorMsg = (description) FROM master.dbo.sysmessages WHERE
		ERROR = @@ERROR	


	INSERT INTO measurement_process_status_completed(process_id, code, [MODULE], source, TYPE, 
						description, nextsteps, calc_type, create_user)
	VALUES (@process_id, @status, 'Measurement', 'runMeasurement', '', 
			CASE WHEN (@dedesignation_calc = 'd') THEN 
				'De-designation calculation failed Code: '
			ELSE 	'Measurement calculation failed Code: ' 
			END + CAST(@@ERROR AS VARCHAR) + ' as of ' + dbo.FNAUserDateFormat(@as_of_date, @user_login_id),
			@errorMsg, @dedesignation_calc, @user_login_id)
END
ELSE
BEGIN
	IF @what_if = 'n' OR @status = 'Error'
	BEGIN	
		INSERT INTO measurement_process_status_completed(process_id, code, [MODULE], source, TYPE, 
							description, nextsteps, calc_type, create_user)
		VALUES (@process_id, @status, 'Measurement', 'runMeasurement', '', 
				@desc,
				'', @dedesignation_calc, @user_login_id)

	END
END

IF @print_diagnostic = 1
BEGIN
	SET @log_increment = 1
	PRINT '******************************************************************************************'
	PRINT '********************END &&&&&&&&&[spa_Calculate_Accrual_Entries ' + CAST(DATEDIFF(ss,@proc_begin_time,GETDATE()) AS VARCHAR) + ' Secs]************************'
END

