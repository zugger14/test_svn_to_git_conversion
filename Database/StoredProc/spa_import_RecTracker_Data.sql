IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_import_RecTracker_Data]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_import_RecTracker_Data]
GO 


create PROC [dbo].[spa_import_RecTracker_Data] 
	@fromdate varchar(20),		
	@todate varchar(20),
	@user_id varchar(100),
	@source_system_id int=NULL	
AS
 
BEGIN


declare @source varchar(100)

declare @job_name varchar(50)
declare @process_id varchar(100)
declare @desc varchar(500)
declare @spa varchar(5000)


set @process_id = REPLACE(newid(),'-','_')
SET @job_name = 'RecTracker_' + @process_id

DECLARE @year_from int
DECLARE @month_from int		
DECLARE @year_to int
DECLARE @month_to int	
DECLARE @sqlStmt varchar(5000)
DECLARE @tempTable varchar(200)	

SET @year_from=YEAR(@fromdate)
SET @month_from=MONTH(@fromdate)
SET @year_to=YEAR(@todate)
SET @month_to=MONTH(@todate)



set @tempTable=dbo.FNAProcessTableName('RecTracker', @user_id,@process_id)

declare @user_name varchar(100)
set @user_name=dbo.FNADBUser()


EXEC('
CREATE TABLE '+@tempTable+'( 
	ORIS_PLT  varchar(10),
	UNITC varchar(10),
	YR varchar(4),
	MTH varchar(2),
	FUTY varchar(2),
	EIA_SRC varchar(10),
	QU_BRN varchar(50),
	QU_BRN_UOM varchar(50),
	AVE_HT INT,
	ASH_PCT Float,
	MST_PCT FLOAT,
	SULF_PCT FLOAT,
	NGEN FLOAT,
	GGEN FLOAT
)')

SET @sqlStmt= '
INSERT INTO '+@tempTable+'  
select * FROM OPENQUERY(MERIDIUM,''
	select distinct c.MI_GM_UNIT0_ORIS_PLNT_ID_C oris_plt,
	a.mi_gmcaphst_unit_id_c unitc,
	a.mi_gmcaphst_repor_year_c yr,
	a.mi_gmcaphst_repor_month_c mth,
	a.mi_gmcaphst_pri_fuel_code_c futy,
	mi_gmcaphst_eia_energ_src_1_c eia_src,
	a.mi_gmcaphst_pri_quant_burne_n qu_brn,
	a.mi_gmcaphst_prim_burn_uom_c qu_brn_uom,
	a.MI_GMCAPHST_PRI_AVG_HEAT_C_N ave_ht,
	a.MI_GMCAPHST_PRI_PERCE_ASH_N ash_pct,
	a.MI_GMCAPHST_PRI_PERCE_MOIST_N mst_pct,
	a.MI_GMCAPHST_PRI_PERCE_SULFU_N sulf_pct,
	a.mi_gmcaphst_n_actua_gener_n NGen,
	a.mi_gmcaphst_g_actua_gener_n ggen
	from mi_gmcaphst a, mi_gm_plant b, mi_gm_unit0 c
	where a.mi_gmcaphst_plant_id_c = b.mi_gm_plant_plant_id_c and
	c.mi_gm_unit0_unit_id_c = a.mi_gmcaphst_unit_id_c
	and a.MI_GMCAPHST_CAP_HIS_STAT_TP_C = ''''All Incidents''''
	and a.mi_gmcaphst_repor_year_c between ''''' + cast(@year_from as varchar) + ''''' 
	and ''''' + cast(@year_to as varchar) + '''''
	and a.mi_gmcaphst_repor_month_c between '''' + cast(@month_from as varchar) + '''' 
	and ''''' + cast(@month_to as varchar) + '''''
	union select distinct c.MI_GM_UNIT0_ORIS_PLNT_ID_C oris_plt,
	a.mi_gmcaphst_unit_id_c unitc,
	a.mi_gmcaphst_repor_year_c yr,
	a.mi_gmcaphst_repor_month_c mth,
	a.mi_gmcaphst_sec_fuel_code_c futy,
	mi_gmcaphst_eia_energ_src_2_c eia_src,
	a.mi_gmcaphst_sec_quant_burne_n qu_brn,
	a.mi_gmcaphst_secnd_burn_uom_c qu_brn_uom,
	a.mi_gmcaphst_sec_avg_heat_n ave_ht,
	a.MI_GMCAPHST_SEC_PERCE_ASH_N ash_pct,
	a.MI_GMCAPHST_SEC_PERCE_MOIST_N mst_pct,
	a.MI_GMCAPHST_SEC_PERCE_SULFU_N sulf_pct,
	a.mi_gmcaphst_n_actua_gener_n, a.mi_gmcaphst_g_actua_gener_n
	from mi_gmcaphst a, mi_gm_plant b, mi_gm_unit0 c
	where a.mi_gmcaphst_plant_id_c = b.mi_gm_plant_plant_id_c and
	c.mi_gm_unit0_unit_id_c = a.mi_gmcaphst_unit_id_c
	and a.MI_GMCAPHST_CAP_HIS_STAT_TP_C = ''''All Incidents'''' and
	a.mi_gmcaphst_qua_fuel_code_c is not null
	and a.mi_gmcaphst_repor_year_c between ''''' + cast(@year_from as varchar) + ''''' 
	and ''''' + cast(@year_to as varchar) + '''''
	and a.mi_gmcaphst_repor_month_c between ''''' + cast(@month_from as varchar) + ''''' 
	and ''''' + cast(@month_to as varchar) + '''''
	union select distinct c.MI_GM_UNIT0_ORIS_PLNT_ID_C oris_plt,
	a.mi_gmcaphst_unit_id_c unitc,
	a.mi_gmcaphst_repor_year_c yr,
	a.mi_gmcaphst_repor_month_c mth,
	a.mi_gmcaphst_ter_fuel_code_c futy,
	mi_gmcaphst_eia_energ_src_3_c eia_src,
	a.mi_gmcaphst_ter_quant_burne_n qu_brn,
	a.mi_gmcaphst_tertary_burn_uom_c qu_brn_uom,
	a.mi_gmcaphst_ter_avg_heat_n ave_ht,
	a.MI_GMCAPHST_TER_PERCE_ASH_N ash_pct,
	a.MI_GMCAPHST_TER_PERCE_MOIST_N mst_pct,
	a.MI_GMCAPHST_TER_PERCE_SULFU_N sulf_pct,
	a.mi_gmcaphst_n_actua_gener_n, a.mi_gmcaphst_g_actua_gener_n
	from mi_gmcaphst a, mi_gm_plant b, mi_gm_unit0 c
	where a.mi_gmcaphst_plant_id_c = b.mi_gm_plant_plant_id_c and
	c.mi_gm_unit0_unit_id_c = a.mi_gmcaphst_unit_id_c
	and a.MI_GMCAPHST_CAP_HIS_STAT_TP_C = ''''All Incidents'''' and
	a.mi_gmcaphst_qua_fuel_code_c is not null
	and a.mi_gmcaphst_repor_year_c between ''''' + cast(@year_from as varchar) + ''''' and ''''' + cast(@year_to as varchar) + '''''
	and a.mi_gmcaphst_repor_month_c between ''''' + cast(@month_from as varchar) + ''''' and ''''' + cast(@month_to as varchar) + '''''
	UNION select distinct c.MI_GM_UNIT0_ORIS_PLNT_ID_C oris_plt,
	a.mi_gmcaphst_unit_id_c unitc,
	a.mi_gmcaphst_repor_year_c yr,
	a.mi_gmcaphst_repor_month_c mth,
	a.mi_gmcaphst_qua_fuel_code_c futy,
	mi_gmcaphst_eia_energ_src_4_c eia_src,
	a.mi_gmcaphst_qua_quant_burne_n qu_brn,
	a.mi_gmcaphst_quatnry_burn_uom_c qu_brn_uom,
	a.mi_gmcaphst_qua_avg_heat_n ave_ht,
	a.MI_GMCAPHST_QUA_PERCE_ASH_N ash_pct,
	a.MI_GMCAPHST_QUA_PERCE_MOIST_N mst_pct,
	a.MI_GMCAPHST_QUA_PERCE_SULFU_N sulf_pct,
	a.mi_gmcaphst_n_actua_gener_n, a.mi_gmcaphst_g_actua_gener_n
	from mi_gmcaphst a, mi_gm_plant b, mi_gm_unit0 c
	where a.mi_gmcaphst_plant_id_c = b.mi_gm_plant_plant_id_c and
	c.mi_gm_unit0_unit_id_c = a.mi_gmcaphst_unit_id_c
	and a.MI_GMCAPHST_CAP_HIS_STAT_TP_C = ''''All Incidents'''' and
	a.mi_gmcaphst_qua_fuel_code_c is not null
	and a.mi_gmcaphst_repor_year_c between ''''' + cast(@year_from as varchar) + ''''' and ''''' + cast(@year_to as varchar) + '''''
	and a.mi_gmcaphst_repor_month_c between ''''' + cast(@month_from as varchar) + ''''' and ''''' + cast(@month_to as varchar) + '''''
	order by unitc, yr, mth'')
'
EXEC spa_print @sqlStmt
EXEC(@sqlStmt)

--print @tempTable

--set @user_id='farrms_admin'

SET @spa = ' spa_meridium_data_as_job ''' +@fromdate + ''', ' +''''+@todate+ ''', ' +'''' +  @tempTable + '''' + ',''' + @user_id + ''''

EXEC spa_print @job_name
EXEC spa_print @spa

EXEC spa_run_sp_as_job @job_name, @spa, 'MERIDIUM Import', @user_id

EXEC spa_print 'EXEC spa_run_sp_as_job ''', @job_name, ''', ''', @spa, ''', MERIDIUM Import, ''', @user_id, ''

Exec spa_ErrorHandler 0, 'ODMS Import', 
			'spa_meridium_data_as_job', 'Status', 
			'Data Import Process has been run and will complete shortly.', 
			'Please check/refresh your message board.'
END












