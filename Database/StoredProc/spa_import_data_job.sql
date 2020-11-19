/****** Object:  StoredProcedure [dbo].[spa_import_data_job]    Script Date: 11/25/2011 09:41:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_import_data_job]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_import_data_job]
GO

/****** Object:  StoredProcedure [dbo].[spa_import_data_job]    Script Date: 11/25/2011 09:41:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_import_data_job]
	@temp_table_name VARCHAR(500) = '',
	@table_id VARCHAR(100) = '',
	@job_name VARCHAR(100),
	@process_id VARCHAR(100),
	@user_login_id VARCHAR(50),
	@schedule_run VARCHAR(1) = 'n',
	@exec_mode INT = 0, -- 0 means existing logic, 1 = Essent Interface
	@error_log_table_name VARCHAR(500) = NULL, -- Used for Essent
	@import_as_of_date VARCHAR(25) = NULL, -- Used for Essent
	@import_from VARCHAR(500) = NULL,
	@generic_mapping_flag CHAR(1) = NULL,
	@rules_id INT = NULL

AS
/*---------Script for TEST-------------------------------*/
/*
--spa_import_data_job  ''adiha_process.dbo.source_deal_detail_trm_farrms_admin_A40B5FE6_3FEF_45E8_BAAB_E99E5A035675'',''4005'', ''importdata_4028_673FF8B0_49C3_4339_828D_9AC739D524C6'', ''673FF8B0_49C3_4339_828D_9AC739D524C6'',''farrms_admin'',''n'',12
declare @temp_table_name varchar(100),@table_id varchar(100),@job_name varchar(100),@process_id varchar(100),@user_login_id varchar(50),
@schedule_run varchar(1),@exec_mode int, @error_log_table_name varchar(500), @import_as_of_date varchar(20), @import_from VARCHAR(500)

set @temp_table_name='adiha_process.dbo.source_deal_detail_trm_farrms_admin_A40B5FE6_3FEF_45E8_BAAB_E99E5A035675'
set @table_id='4005'
set @job_name='importdata_4028_848D19AB_A89B_4B10_9BA7_05C1EAB7D9F3'
set @process_id='673FF8B0_49C3_4339_828D_9AC739D524C6'
set @user_login_id='farrms_admin'
set @schedule_run='n'
set @exec_mode=12
set @error_log_table_name ='formate2'

--alter table adiha_process.dbo.source_deal_detail_SysFasttrackerT_4FCD0944_38F3_47CE_9109_E1D4A08D0634
--drop column temp_id
/*
drop table #import_status
drop table #temp_table1
drop table #import_list_table
drop table #temp_tot_count
drop table #tmp_erroneous_deals
drop table #MTM_detail
*/

--*/
/*--------------------------------------------------------------*/




IF OBJECT_ID('tempdb..#import_status') IS NOT NULL
    DROP TABLE #import_status

IF OBJECT_ID('tempdb..#temp_table1') IS NOT NULL
    DROP TABLE #temp_table1

--IF OBJECT_ID('tempdb..#import_list_table') IS NOT NULL
--    DROP TABLE #import_list_table

IF OBJECT_ID('tempdb..#temp_tot_count') IS NOT NULL
    DROP TABLE #temp_tot_count

IF OBJECT_ID('tempdb..#updated_deals_confirm') IS NOT NULL
    DROP TABLE #updated_deals_confirm

IF OBJECT_ID('tempdb..#vol_check') IS NOT NULL
    DROP TABLE #vol_check

IF OBJECT_ID('tempdb..#vol_check1') IS NOT NULL
    DROP TABLE #vol_check1

IF OBJECT_ID('tempdb..#total_deals_proceed') IS NOT NULL
    DROP TABLE #total_deals_proceed

IF OBJECT_ID('tempdb..#total_curve_price_proceed') IS NOT NULL
    DROP TABLE #total_curve_price_proceed
--IF object_id('tempdb..#temp_table1') is not null
--drop table #temp_table1
--IF object_id('tempdb..#temp_table1') is not null
--drop table #temp_table1
--IF object_id('tempdb..#temp_table1') is not null
--drop table #temp_table1
--IF object_id('tempdb..#temp_table1') is not null
--drop table #temp_table1
--IF object_id('tempdb..#temp_table1') is not null
--drop table #temp_table1
--IF object_id('tempdb..#temp_table1') is not null
--drop table #temp_table1


DECLARE @sql                    VARCHAR(MAX)
DECLARE @sql1                   VARCHAR(MAX)
DECLARE @sql2                   NVARCHAR(4000)
DECLARE @sql3                   NVARCHAR(3000)
DECLARE @sql4                   NVARCHAR(3000)
DECLARE @tablename              VARCHAR(100)
DECLARE @errorMsg               VARCHAR(200)
DECLARE @errorcode              VARCHAR(200)
DECLARE @detail_errorMsg        VARCHAR(200)
DECLARE @error                  INT
DECLARE @id                     INT
DECLARE @count                  INT
DECLARE @totalcount             INT
DECLARE @url                    VARCHAR(500)
DECLARE @desc                   VARCHAR(500)
DECLARE @todaydate              DATETIME
DECLARE @table_desc             VARCHAR(100)
DECLARE @run_start_time         DATETIME
DECLARE @temp_for_delete        VARCHAR(500)
DECLARE @source_system_desc_id  VARCHAR(20)
DECLARE @source                 VARCHAR(100)
DECLARE @start_ts               DATETIME
SET @run_start_time = GETDATE()


--BEGIN TRY
--drop table  adiha_process.dbo.ccc
--exec('select * into adiha_process.dbo.ccc from '+@temp_table_name)
--return
EXEC('
if not exists(select 1 from adiha_process.sys.columns WITH(NOLOCK) where [name]=''temp_id'' and [object_id]=object_id('''+@temp_table_name+'''))
alter table '+ @temp_table_name+' add temp_id int identity')
EXEC spa_print 'start [spa_import_data_job]'


--RETURN
--Create temporary table to log import status
CREATE TABLE #import_status
	(
	temp_id INT,
	[process_id] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[ErrorCode] VARCHAR(50) COLLATE DATABASE_DEFAULT,
	[MODULE] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[Source] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[TYPE] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[description] VARCHAR(1000) COLLATE DATABASE_DEFAULT,
	[nextstep] VARCHAR(250) COLLATE DATABASE_DEFAULT,
	type_error VARCHAR(500) COLLATE DATABASE_DEFAULT,
	external_type_id VARCHAR(100) COLLATE DATABASE_DEFAULT
	)
		
CREATE TABLE #vol_check	(s_tot FLOAT,d_tot FLOAT,norec INT)
CREATE TABLE #vol_check1 (s_tot FLOAT,d_tot FLOAT,norec INT)

EXEC spa_print 'lllllllllllllll'
CREATE TABLE #total_deals_proceed(tot_deals INT)
CREATE TABLE #total_curve_price_proceed(Curve_id VARCHAR(500) COLLATE DATABASE_DEFAULT,as_of_date DATETIME,curve_record INT,tot_record INT)

CREATE TABLE #temp_table1(
table_name VARCHAR(200) COLLATE DATABASE_DEFAULT)
--begin try --********************************************************************************************************************************
DECLARE @source_table VARCHAR(200)
DECLARE @field_compare_table VARCHAR(200)
DECLARE @sql_stmt VARCHAR(8000)
CREATE TABLE #import_list_table ( temp_table_name VARCHAR(100) COLLATE DATABASE_DEFAULT)

SET @user_login_id = ISNULL(NULLIF(@user_login_id, ''), dbo.FNADBUser())

IF @table_id IS NULL
BEGIN
	SET @table_id=''
	SELECT @table_id=@table_id+CAST(value_id AS VARCHAR)+',' FROM static_data_value WHERE TYPE_ID=4000
	SET @table_id=SUBSTRING(@table_id,1,LEN(@table_id)-1)
END
SET @field_compare_table='fields_'+@table_id
SET @field_compare_table = dbo.FNAProcessTableName(@field_compare_table, @user_login_id, @process_id)

EXEC('
IF OBJECT_ID(''' + @field_compare_table + ''') IS NOT NULL
DROP TABLE ' + @field_compare_table)

EXEC(' create table '+@field_compare_table+ '
	(
ref_table_name varchar(50),ref_field varchar(50),validate_field varchar(50)
)')

DECLARE @s_tot FLOAT,@d_tot FLOAT

EXEC spa_print @field_compare_table
--create temporary table to store count
CREATE TABLE #temp_tot_count (
	totcount INT,
	source VARCHAR(50) COLLATE DATABASE_DEFAULT)

SET @totalcount=0
SET @tablename=''
IF CHARINDEX('4011',@table_id,1)<>0	--source_uom
BEGIN
	EXEC('delete '+@field_compare_table)
	SET @tablename=(SELECT code FROM static_data_value WHERE value_id=4011)
	--if @schedule_run='n'
	--begin
		EXEC('insert into '+@field_compare_table+ ' values (''source_uom'',''uom_id'',''uom_id'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_uom'',''uom_name'',''uom_name'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_uom'',''uom_desc'',''uom_desc'')')
		SET @source_table=@temp_table_name
		EXEC('delete from '+@temp_table_name+' where source_uom_id is null and source_system_id is null and uom_id is null and
			uom_name is null and uom_desc is null')

		EXEC (' insert into #temp_tot_count select count(*) as totcount,'''+ @tablename+''' from '+@temp_table_name)
		EXEC sp_validate_data_type @process_id,@field_compare_table,@source_table
--	end

--Import data ***************************************************************************************
EXEC spa_print '1'		
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data error for uom_id :''+ isnull(a.uom_id,''NULL'')+'' (Data Repetition Error, No of times:''+ cast(b.notimes as varchar)+'' )'',''Please check your data'' 
			from '+@temp_table_name + ' a inner join (select uom_id,count(*) notimes from '+ @temp_table_name+'
			 group by uom_id having count(*)>1) b 
			on a.uom_id=b.uom_id')

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_uom_id :''+ isnull(a.source_uom_id,''NULL'')+'', source_system_id:''+isnull(a.source_system_id,''NULL'')+
			'', uom_id :''+ isnull(a.uom_id,''NULL'')+''.( Data format for source_system_id  ''+isnull(a.source_system_id,''NULL'')+'' 
			or uom_id ''+isnull(a.uom_id,''NULL'')+''  is invalid)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a where isnumeric(a.source_system_id)=0 or a.uom_id is null')

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_uom_id :''+ isnull(a.source_uom_id,''NULL'')+'', source_system_id:''+isnull(a.source_system_id,''NULL'')+
			'', uom_id :''+ isnull(a.uom_id,''NULL'')+''. (Foreign Key source_system_id ''+ISNULL(a.source_system_id,''NULL'')+'' not found)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id left join source_system_description b on 
			b.source_system_id=a.source_system_id

			where #import_status.temp_id is null and b.source_system_id is null')
	
	EXEC('delete '+@temp_table_name + ' from #import_status inner join '+@temp_table_name + ' a on
		#import_status.temp_id=a.temp_id')

	SET @sql='update source_uom  set source_system_id=b.source_system_id,uom_name=b.uom_name,
			uom_desc=b.uom_desc
			from source_uom  inner join '+@temp_table_name+' b on
			source_uom.uom_id=b.uom_id and source_uom.source_system_id=
			b.source_system_id inner join source_system_description d on
			 b.source_system_id = d.source_system_id
			left join #import_status on b.temp_id=#import_status.temp_id where #import_status.temp_id is null '

	SET @sql1='insert into source_uom(source_system_id,uom_id,uom_name,uom_desc)
	 		select  a.source_system_id,a.uom_id,a.uom_name,a.uom_desc from '+@temp_table_name+' a

			inner join source_system_description d on a.source_system_id = d.source_system_id
			left join source_uom g on g.uom_id=a.uom_id
			and g.source_system_id=a.source_system_id left join #import_status on a.temp_id=#import_status.temp_id where #import_status.temp_id is null
			and   g.uom_id is null'
	EXEC(@sql)
	EXEC(@sql1)
	--DELETE FROM #import_list_table

END
IF CHARINDEX('4003',@table_id,1)<>0	--source_currency
BEGIN
	EXEC('delete '+@field_compare_table)
	SET @tablename=(SELECT code FROM static_data_value WHERE value_id=4003)
--	if @schedule_run='n'
--	begin
		EXEC('insert into '+@field_compare_table+ ' values (''source_currency'',''currency_id'',''currency_id'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_currency'',''currency_name'',''currency_name'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_currency'',''currency_desc'',''currency_desc'')')
	--Pre validataing Data Type
		SET @source_table=@temp_table_name
		EXEC('delete from '+@temp_table_name+' where source_currency_id is null and source_system_id is null and currency_id is null and
			currency_name is null and currency_desc is null')
		
		EXEC (' insert into #temp_tot_count select count(*) as totcount,'''+ @tablename+'''  from '+@temp_table_name)
		EXEC sp_validate_data_type @process_id,@field_compare_table,@source_table
--	end

--Data Import ***************************************************************
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data error for currency_id :''+ isnull(a.currency_id,''NULL'')+'' (Data Repetition Error, No of times:''+ cast(b.notimes as varchar)+'' )'',''Please check your data'' 
			from '+@temp_table_name + ' a inner join (select currency_id,count(*) notimes from '+ @temp_table_name+'
			 group by currency_id having count(*)>1) b 
			on a.currency_id=b.currency_id')

	
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_currency_id :''+ isnull(a.source_currency_id,''NULL'')+'', source_system_id:''+isnull(a.source_system_id,''NULL'')+
			'', currency_id :''+ isnull(a.currency_id,''NULL'')+''.( Data format for source_system_id  ''+isnull(a.source_system_id,''NULL'')+'' 
			or currency_id ''+isnull(a.currency_id,''NULL'')+''  is invalid)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a where 
			isnumeric(a.source_system_id)=0 or a.currency_id is null')

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id, '''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_currency_id :''+ isnull(a.source_currency_id,''NULL'')+'', source_system_id:''+isnull(a.source_system_id,''NULL'')+
			'', currency_id :''+ isnull(a.currency_id,''NULL'')+''. (Foreign Key source_system_id ''+ISNULL(a.source_system_id,''NULL'')+'' not found)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id left join source_system_description b on 
			b.source_system_id=a.source_system_id where #import_status.temp_id is null and b.source_system_id is null')
	
	EXEC('delete '+@temp_table_name + ' from #import_status inner join '+@temp_table_name + ' a on
		#import_status.temp_id=a.temp_id')

	SET @sql='update source_currency  set source_system_id=b.source_system_id,currency_name=b.currency_name,
			currency_desc=b.currency_desc
			from source_currency  inner join '+@temp_table_name+' b on
			source_currency.currency_id=b.currency_id and source_currency.source_system_id=
			b.source_system_id inner join source_system_description d on
			 b.source_system_id = d.source_system_id 
			left join #import_status on b.temp_id=#import_status.temp_id where #import_status.temp_id is null'

	SET @sql1='insert into source_currency(source_system_id,currency_id,currency_name,currency_desc)
 			select  a.source_system_id,a.currency_id,a.currency_name,a.currency_desc from '+@temp_table_name+'
			a   inner join source_system_description d on a.source_system_id = d.source_system_id
			left join source_currency e on e.currency_id=a.currency_id
			and e.source_system_id=a.source_system_id left join #import_status on a.temp_id=#import_status.temp_id where #import_status.temp_id is null
			and   e.currency_id is null'
	EXEC(@sql)
	EXEC(@sql1)
END

IF CHARINDEX('4000',@table_id,1)<>0	--	source_book
BEGIN
	EXEC('delete '+@field_compare_table)
	SET @tablename=(SELECT code FROM static_data_value WHERE value_id=4000)
--	if @schedule_run='n'
--	begin
		EXEC('insert into '+@field_compare_table+ ' values (''source_book'',''source_system_book_id'',''source_system_book_id'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_book'',''source_system_book_type_value_id'',''source_system_book_type_value_id'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_book'',''source_book_name'',''source_book_name'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_book'',''source_book_desc'',''source_book_desc'')')
		SET @source_table=@temp_table_name
		EXEC('delete from '+@temp_table_name+' where source_book_id is null and source_system_id is null and source_system_book_id is null and
		source_system_book_type_value_id is null and source_book_name is null and source_book_desc is null and source_parent_book_id is null and source_parent_type is null')

		-- insert into #temp_tot_count tot count from temp table
		EXEC (' insert into #temp_tot_count select count(*) as totcount,'''+ @tablename+'''  from '+@temp_table_name)

		EXEC sp_validate_data_type @process_id,@field_compare_table,@source_table
--	end


---Data Import********************************************************************
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data error for source_system_book_id :''+ isnull(a.source_system_book_id,''NULL'')+'' (Data Repetition Error, No of times:''+ cast(b.notimes as varchar)+'' )'',''Please check your data'' 
			from '+@temp_table_name + ' a inner join (select source_system_book_id,count(*) notimes from '+ @temp_table_name+'
			 group by source_system_book_id having count(*)>1) b 
			on a.source_system_book_id=b.source_system_book_id')
				
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
		''Data error for source_book_id :''+ isnull(a.source_book_id,''NULL'')+'', source_system_id:''+isnull(a.source_system_id,''NULL'')+
			'', source_system_book_id :''+ isnull(a.source_system_book_id,''NULL'')+''.( Data format for source_system_id  ''+isnull(a.source_system_id,''NULL'')+'' 
			or source_system_book_type_value_id ''+isnull(a.source_system_book_type_value_id,''NULL'')+'' or source_book_name  ''+isnull(a.source_book_name,''NULL'')+'' or source_system_book_id  ''+ isnull(a.source_system_book_id,''NULL'')+''  is invalid)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a where isnumeric(a.source_system_id)=0 or
			 isnumeric(a.source_system_book_type_value_id)=0 or a.source_book_name is null or source_system_book_id is null')
		
		
		--Check for Foreign key validation and insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) table if any invalid data found
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_book_id :''+ isnull(a.source_book_id,''NULL'')+'', source_system_id:''+isnull(a.source_system_id,''NULL'')+
			'', source_system_book_id :''+ isnull(a.source_system_book_id,''NULL'')+''. (Foreign Key source_system_id ''+ISNULL(a.source_system_id,''NULL'')+'' not found)'',

			''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
			left join source_system_description b on 
			b.source_system_id=a.source_system_id where #import_status.temp_id is null and b.source_system_id is null')
			
		--Check for Foreign key validation and insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) table if any invalid data found
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_book_id :''+ isnull(a.source_book_id,''NULL'')+'', source_system_id:''+isnull(a.source_system_id,''NULL'')+
			'', source_system_book_id :''+ isnull(a.source_system_book_id,''NULL'')+''. (Foreign Key source_system_book_type_value_id ''+ISNULL(a.source_system_book_type_value_id,''NULL'')+'' not found)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
			where #import_status.temp_id is null and a.source_system_book_type_value_id not in(''50'',''51'',''52'',''53'')')
	
		-- delete from temp table all the invalid data
		EXEC('delete '+@temp_table_name + ' from #import_status inner join '+@temp_table_name + ' a on
		#import_status.temp_id=a.temp_id')

		-- Update  actual table from temp table
		SET @sql='update source_book  set source_system_id=b.source_system_id,source_system_book_type_value_id=b.source_system_book_type_value_id,source_book_name=b.source_book_name,
			source_book_desc=b.source_book_desc,source_parent_book_id=b.source_parent_book_id,source_parent_type=b.source_parent_type
			from source_book  inner join '+@temp_table_name+' b on
			source_book.source_system_book_id=b.source_system_book_id and 
			source_book.source_system_id=b.source_system_id inner join
			static_data_value c on b.source_system_book_type_value_id=c.value_id inner join 
			source_system_description d on b.source_system_id = d.source_system_id
			left join #import_status on b.temp_id=#import_status.temp_id where #import_status.temp_id is null'
		
		--insert into actual table from temp table
		SET @sql1='insert into source_book(source_system_id,source_system_book_id,source_system_book_type_value_id,source_book_name,
			source_book_desc,source_parent_book_id,source_parent_type)
 			select  a.source_system_id,a.source_system_book_id,
			a.source_system_book_type_value_id,
			a.source_book_name,a.source_book_desc,a.source_parent_book_id,a.source_parent_type from '+@temp_table_name+'
			a  inner join
			static_data_value c on a.source_system_book_type_value_id=c.value_id inner join 
			source_system_description d on a.source_system_id = d.source_system_id
			left join source_book e on
			e.source_system_book_id=a.source_system_book_id and 
			e.source_system_id=a.source_system_id 
			left join #import_status on a.temp_id=#import_status.temp_id where #import_status.temp_id is null
			and e.source_system_book_id is null '

	EXEC(@sql)
	EXEC(@sql1)
END
IF CHARINDEX('4001',@table_id,1)<>0 --	source_commodity
BEGIN
	EXEC('delete '+@field_compare_table)
	SET @tablename=(SELECT code FROM static_data_value WHERE value_id=4001)
--	if @schedule_run='n'
--	begin
		EXEC('insert into '+@field_compare_table+ ' values (''source_commodity'',''commodity_id'',''commodity_id'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_commodity'',''commodity_name'',''commodity_name'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_commodity'',''commodity_desc'',''commodity_desc'')')
		--Pre validataing Data Type
		SET @source_table=@temp_table_name
		EXEC('delete from '+@temp_table_name+' where source_commodity_id is null and source_system_id is null and commodity_id is null and
			commodity_name is null and commodity_desc is null')
		
		EXEC (' insert into #temp_tot_count select count(*) as totcount,'''+ @tablename+'''  from '+@temp_table_name)
		EXEC sp_validate_data_type @process_id,@field_compare_table,@source_table
--	end

--Data Import************************************************************************
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data error for commodity_id :''+ isnull(a.commodity_id,''NULL'')+'' (Data Repetition Error, No of times:''+ cast(b.notimes as varchar)+'' )'',''Please check your data'' 
			from '+@temp_table_name + ' a inner join (select commodity_id,count(*) notimes from '+ @temp_table_name+'
			 group by commodity_id having count(*)>1) b 
			on a.commodity_id=b.commodity_id')

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
		''Data error for source_commodity_id :''+ isnull(a.source_commodity_id,''NULL'')+'', source_system_id:''+isnull(a.source_system_id,''NULL'')+
			'', commodity_id :''+ isnull(a.commodity_id,''NULL'')+''.( Data format for source_system_id  ''+isnull(a.source_system_id,''NULL'')+'' 
			or commodity_id ''+isnull(a.commodity_id,''NULL'')+'' is invalid)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a where 
			isnumeric(a.source_system_id)=0 or a.commodity_id is null')
		
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id, '''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_commodity_id :''+ isnull(a.source_commodity_id,''NULL'')+'', source_system_id:''+isnull(a.source_system_id,''NULL'')+
			'', commodity_id :''+ isnull(a.commodity_id,''NULL'')+''. (Foreign Key source_system_id ''+ISNULL(a.source_system_id,''NULL'')+'' not found)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
			left join source_system_description b on 
			b.source_system_id=a.source_system_id where #import_status.temp_id is null  and b.source_system_id is null')
	
	EXEC('delete '+@temp_table_name + ' from #import_status inner join '+@temp_table_name + ' a on
		#import_status.temp_id=a.temp_id')

	SET @sql='update source_commodity  set source_system_id=b.source_system_id,
			commodity_name=b.commodity_name,commodity_desc=b.commodity_desc
			from source_commodity  inner join '+@temp_table_name+' b on
			source_commodity.commodity_id=b.commodity_id and 
			source_commodity.source_system_id=b.source_system_id inner join
			source_system_description d on b.source_system_id = d.source_system_id
			left join #import_status on b.temp_id=#import_status.temp_id where #import_status.temp_id is null '

	SET @sql1='insert into source_commodity(source_system_id,commodity_id,commodity_name,commodity_desc)
			 select a.source_system_id,a.commodity_id,a.commodity_name,a.commodity_desc from '+@temp_table_name+'
			a   inner join source_system_description d on a.source_system_id = d.source_system_id
			left join source_commodity e on
			e.commodity_id=a.commodity_id and 
			e.source_system_id=a.source_system_id left join #import_status on a.temp_id=#import_status.temp_id where #import_status.temp_id is null
			and e.commodity_id is null '
	EXEC(@sql)
	EXEC(@sql1)
END
IF CHARINDEX('4002',@table_id,1)<>0	 OR CHARINDEX('4053',@table_id,1)<>0 --source_counterparty OR source_broker
BEGIN
	DECLARE @id_name VARCHAR(200)
	SELECT @id_name = CASE WHEN @table_id = 4002 THEN ' counterparty_id :'
							WHEN @table_id = 4053 THEN ' broker_id :'
							END 
	EXEC('delete '+@field_compare_table)
	SET @tablename=(SELECT code FROM static_data_value WHERE value_id=4002)
--	if @schedule_run='n'
--	begin
		EXEC('insert into '+@field_compare_table+ ' values (''source_counterparty'',''counterparty_id'',''counterparty_id'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_counterparty'',''counterparty_name'',''counterparty_name'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_counterparty'',''counterparty_desc'',''counterparty_desc'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_counterparty'',''int_ext_flag'',''int_ext_flag'')')
		--Pre validataing Data Type
		SET @source_table=@temp_table_name
		EXEC('delete from '+@temp_table_name+' where source_counterparty_id is null and source_system_id is null and counterparty_id is null and
			counterparty_name is null and counterparty_desc is null and int_ext_flag is null and netting_parent_counterparty_id is null')
		EXEC (' insert into #temp_tot_count select count(*) as totcount,'''+ @tablename+'''  from '+@temp_table_name)
		EXEC sp_validate_data_type @process_id,@field_compare_table,@source_table
	--end
--Data Import****************************************************************************************

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data error for '+ @id_name + '''+ isnull(a.counterparty_id,''NULL'')+'' (Data Repetition Error, No of times:''+ cast(b.notimes as varchar)+'' )'',''Please check your data'' 
			from '+@temp_table_name + ' a inner join (select counterparty_id,count(*) notimes from '+ @temp_table_name+'
			 group by counterparty_id having count(*)>1) b 
			on a.counterparty_id=b.counterparty_id')

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_counterparty_id :''+ isnull(a.source_counterparty_id,''NULL'')+'', source_system_id:''+isnull(a.source_system_id,''NULL'')+
			'', counterparty_id :''+ isnull(a.counterparty_id,''NULL'')+''.( Data format for source_system_id  ''+isnull(a.source_system_id,''NULL'')+'' 
			or netting_parent_counterparty_id ''+isnull(a.netting_parent_counterparty_id,''NULL'')+'' or int_ext_flag ''+isnull(a.int_ext_flag,''NULL'')+'' or counterparty_name ''+isnull(a.counterparty_name,''NULL'')+'' is invalid)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a where 
			isnumeric(a.source_system_id)=0 or (isnumeric(a.netting_parent_counterparty_id)=0 and  a.netting_parent_counterparty_id is not null)
			or (len(a.int_ext_flag)<>1 and a.int_ext_flag is not null) or a.counterparty_id is  null or a.counterparty_name is  null')
	
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_counterparty_id :''+ isnull(a.source_counterparty_id,''NULL'')+'', source_system_id:''+isnull(a.source_system_id,''NULL'')+
			'', counterparty_id :''+ isnull(a.counterparty_id,''NULL'')+''. (Foreign Key netting_parent_counterparty_id ''+ISNULL(a.netting_parent_counterparty_id,''NULL'')+'' is not found)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
			left join source_counterparty b on 
			b.counterparty_id=a.netting_parent_counterparty_id and b.source_system_id=a.source_system_id
			where #import_status.temp_id is null and b.counterparty_id is null and a.netting_parent_counterparty_id is not null')
	
	IF @table_id = 4002
	BEGIN 
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_counterparty_id :''+ isnull(a.source_counterparty_id,''NULL'')+'', source_system_id:''+isnull(a.source_system_id,''NULL'')+
			'', '+ @id_name + '''+ isnull(a.counterparty_id,''NULL'')+''. (Data format error for int_ext_flag :''+a.int_ext_flag+''. Only i or e is allowed)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a where a.int_ext_flag<>''i'' and a.int_ext_flag<>''e'' ')
	END 
	ELSE IF  @table_id = 4053
	BEGIN 
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_broker_id :''+ isnull(a.source_counterparty_id,''NULL'')+'', source_system_id:''+isnull(a.source_system_id,''NULL'')+
			'','+ @id_name + '''+ isnull(a.counterparty_id,''NULL'')+''. (Data format error for int_ext_flag :''+a.int_ext_flag+''. Only i or e is allowed)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a where a.int_ext_flag<>''b'' ')
	END
	

	EXEC('delete '+@temp_table_name + ' from #import_status inner join '+@temp_table_name + ' a on
		#import_status.temp_id=a.temp_id')


	SET @sql='update b   set source_system_id=a.source_system_id,counterparty_name=a.counterparty_name,
			counterparty_desc=a.counterparty_desc,int_ext_flag=a.int_ext_flag,
			netting_parent_counterparty_id=
			case 
			when a.netting_parent_counterparty_id is NULL then NULL
			else d.source_counterparty_id
			end
			
			 from 
			source_counterparty b inner JOIN
			source_system_description c ON b.source_system_id = c.source_system_id INNER JOIN
			'+@temp_table_name+' a ON 
			b.counterparty_id = a.counterparty_id AND 
			b.source_system_id = a.source_system_id INNER JOIN
			source_counterparty d ON 
			
			a.source_system_id = d.source_system_id and
			d.counterparty_id = 
			case 	
				when a.netting_parent_counterparty_id is  NULL then d.counterparty_id
				else a.netting_parent_counterparty_id
			end left join #import_status on a.temp_id=#import_status.temp_id where #import_status.temp_id is null'
	
	SET @sql1='insert into source_counterparty(source_system_id,counterparty_id,counterparty_name,counterparty_desc,int_ext_flag,netting_parent_counterparty_id)
			select  distinct a.source_system_id,a.counterparty_id,a.counterparty_name,a.counterparty_desc,a.int_ext_flag,
				case 
				when a.netting_parent_counterparty_id is NULL then NULL
				else f.source_counterparty_id
				end
				
				 from 
				source_counterparty f right  join
				'+@temp_table_name+' a 
				on
				a.source_system_id = f.source_system_id and
				f.counterparty_id = 
				case 	
					when a.netting_parent_counterparty_id is  NULL then f.counterparty_id
					else a.netting_parent_counterparty_id
				end 
				
				inner join source_system_description d on a.source_system_id = d.source_system_id
				left join source_counterparty e on e.counterparty_id=a.counterparty_id
				and e.source_system_id=a.source_system_id 
				left join #import_status on a.temp_id=#import_status.temp_id where #import_status.temp_id is null and e.counterparty_id is null'
	EXEC(@sql)
	EXEC(@sql1)

END
IF CHARINDEX('4016',@table_id,1)<>0	--contract_group
BEGIN
	EXEC('delete '+@field_compare_table)
	SET @tablename=(SELECT code FROM static_data_value WHERE value_id=4016)
--	if @schedule_run='n'
--	begin
		EXEC('insert into '+@field_compare_table+ ' values (''contract_group'',''source_contract_id'',''contract_id'')')
		EXEC('insert into '+@field_compare_table+ ' values (''contract_group'',''contract_name'',''contract_name'')')
		EXEC('insert into '+@field_compare_table+ ' values (''contract_group'',''contract_desc'',''contract_desc'')')
		--Pre validataing Data Type
		SET @source_table=@temp_table_name
		EXEC('delete from '+@temp_table_name+' where source_contract_id is null and source_system_id is null and contract_id is null and
			contract_name is null and contract_desc is null')
		
		EXEC (' insert into #temp_tot_count select count(*) as totcount,'''+ @tablename+'''  from '+@temp_table_name)	
		EXEC sp_validate_data_type @process_id,@field_compare_table,@source_table
--	end
	
--Data Import *************************
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data error for contract_id :''+ isnull(a.contract_id,''NULL'')+'' (Data Repetition Error, No of times:''+ cast(b.notimes as varchar)+'' )'',''Please check your data'' 
			from '+@temp_table_name + ' a inner join (select contract_id,count(*) notimes from '+ @temp_table_name+'
			 group by contract_id having count(*)>1) b 
			on a.contract_id=b.contract_id')
	
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
		''Data error for source_contract_id :''+ isnull(a.source_contract_id,''NULL'')+'', source_system_id:''+isnull(a.source_system_id,''NULL'')+
			'', contract_id :''+ isnull(a.contract_id,''NULL'')+''.( Data format for source_system_id  ''+isnull(a.source_system_id,''NULL'')+'' 
			or contract_id ''+isnull(a.contract_id,''NULL'')+'' is invalid)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a where 
			isnumeric(a.source_system_id)=0 or a.contract_id is null')
		
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id, '''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_contract_id :''+ isnull(a.source_contract_id,''NULL'')+'', source_system_id:''+isnull(a.source_system_id,''NULL'')+
			'', contract_id :''+ isnull(a.contract_id,''NULL'')+''. (Foreign Key source_system_id ''+ISNULL(a.source_system_id,''NULL'')+'' is not found)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
			left join source_system_description b on 
			b.source_system_id=a.source_system_id where #import_status.temp_id is null  and b.source_system_id is null')
	
	EXEC('delete '+@temp_table_name + ' from #import_status inner join '+@temp_table_name + ' a on
		#import_status.temp_id=a.temp_id')

	SET @sql='update contract_group  set source_system_id=b.source_system_id,
			contract_name=b.contract_name,contract_desc=b.contract_desc
			from contract_group  inner join '+@temp_table_name+' b on
			contract_group.source_contract_id=b.source_contract_id and 
			contract_group.source_system_id=b.source_system_id inner join
			source_system_description d on b.source_system_id = d.source_system_id
			left join #import_status on b.temp_id=#import_status.temp_id 
			where #import_status.temp_id is null '

	SET @sql1='insert into contract_group(source_system_id,source_contract_id,contract_name,contract_desc)
			 select a.source_system_id,a.source_contract_id,a.contract_name,a.contract_desc 
			from '+@temp_table_name+'
			a   inner join source_system_description d on a.source_system_id = d.source_system_id
			left join contract_group e on
			e.source_contract_id=a.source_contract_id and 
			e.source_system_id=a.source_system_id left 
			join #import_status on a.temp_id=#import_status.temp_id where #import_status.temp_id is null
			and e.contract_id is null '

	EXEC(@sql)
	EXEC(@sql1)
	--DELETE FROM #import_list_table
END
IF CHARINDEX('4007',@table_id,1)<>0	--source_deal_type
BEGIN
	EXEC('delete '+@field_compare_table)
	SET @tablename=(SELECT code FROM static_data_value WHERE value_id=4007)
--	if @schedule_run='n'
--	begin
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_type'',''deal_type_id'',''deal_type_id'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_type'',''source_deal_type_name'',''source_deal_type_name'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_type'',''source_deal_desc'',''source_deal_desc'')')
	--	exec('insert into '+@field_compare_table+ ' values (''source_deal_type'',''sub_type'',''sub_type'')')

		--Pre validataing Data Type
		SET @source_table=@temp_table_name
		EXEC('delete from '+@temp_table_name+' where source_deal_type_id is null and source_system_id is null and deal_type_id is null and
		source_deal_type_name is null and source_deal_desc is null' )
		
		EXEC (' insert into #temp_tot_count select count(*) as totcount,'''+ @tablename+'''  from '+@temp_table_name)
		EXEC sp_validate_data_type @process_id,@field_compare_table,@source_table
--	end

---Data Import **************************************************************************8

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data error for deal_type_id :''+ isnull(a.deal_type_id,''NULL'')+'' (Data Repetition Error, No of times:''+ cast(b.notimes as varchar)+'' )'',''Please check your data'' 
			from '+@temp_table_name + ' a inner join (select deal_type_id,count(*) notimes from '+ @temp_table_name+'
			 group by deal_type_id having count(*)>1) b 
			on a.deal_type_id=b.deal_type_id')
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_deal_type_id :''+ isnull(a.source_deal_type_id,''NULL'') +'', source_system_id :''+ isnull(a.source_system_id,''NULL'') +'',
			deal_type_id :''+ isnull(a.deal_type_id,''NULL'') +'',source_deal_type_name:''+ isnull(a.source_deal_type_name,''NULL'')+''.( Data format for source_system_id or deal_type_id or source_deal_type_name is invalid)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a where isnumeric(a.source_system_id)=0
			or a.deal_type_id is  null or a.source_deal_type_name is  null')

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_deal_type_id :''+ isnull(a.source_deal_type_id,''NULL'')+'', Description:''+isnull(a.source_deal_desc,''NULL'')+
			''. Data format sub_type: ''+a.deal_sub_type_flag+'' is invalid'',
			''Please check your data'' 
			from '+@temp_table_name + ' a where (a.deal_sub_type_flag not in(''y'',''n'')) and a.deal_sub_type_flag is not null')

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_deal_type_id :''+ isnull(a.source_deal_type_id,''NULL'') +'', source_system_id :''+ isnull(a.source_system_id,''NULL'') +'',
			deal_type_id :''+ isnull(a.deal_type_id,''NULL'') +''.(Foreign Key source_system_id ''+ISNULL(a.source_system_id,''NULL'')+'' is not found)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
			left join source_system_description b on b.source_system_id=a.source_system_id
			where #import_status.temp_id is null and b.source_system_id is null')
	
	EXEC('delete '+@temp_table_name + ' from #import_status inner join '+@temp_table_name + ' a on
		#import_status.temp_id=a.temp_id')

	SET @sql='update source_deal_type  set source_system_id=b.source_system_id,source_deal_type_name=b.source_deal_type_name,
			source_deal_desc=b.source_deal_desc,sub_type=b.deal_sub_type_flag
			from source_deal_type  inner join '+@temp_table_name+' b on
			source_deal_type.deal_type_id=b.deal_type_id and source_deal_type.source_system_id=
			b.source_system_id inner join 
			source_system_description c on b.source_system_id =c.source_system_id 
			left join #import_status on b.temp_id=#import_status.temp_id where #import_status.temp_id is null'

	SET @sql1='insert into source_deal_type(source_system_id,deal_type_id,source_deal_type_name,source_deal_desc,sub_type,expiration_applies,disable_gui_groups)
 			select distinct a.source_system_id,a.deal_type_id,a.source_deal_type_name,a.source_deal_desc,a.deal_sub_type_flag,''n'',
			''y'' from '+@temp_table_name+' a
			inner join source_system_description b on a.source_system_id = b.source_system_id 
			left join source_deal_type h on h.deal_type_id=a.deal_type_id and
			 h.source_system_id=a.source_system_id left join #import_status on a.temp_id=#import_status.temp_id where #import_status.temp_id is null
			and h.deal_type_id is null'

	EXEC(@sql)
	EXEC(@sql1)
END
IF CHARINDEX('4009',@table_id,1)<>0	--source_price_curve_def
BEGIN
	EXEC('delete '+@field_compare_table)
	SET @tablename=(SELECT code FROM static_data_value WHERE value_id=4009)
--	if @schedule_run='n'
--	begin
		EXEC('insert into '+@field_compare_table+ ' values (''source_price_curve_def'',''curve_id'',''curve_id'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_price_curve_def'',''curve_name'',''curve_name'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_price_curve_def'',''curve_des'',''curve_des'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_price_curve_def'',''market_value_id'',''market_value_id'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_price_curve_def'',''market_value_desc'',''market_value_desc'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_price_curve_def'',''source_curve_type_value_id'',''source_curve_type_value_id'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_price_curve_def'',''proxy_source_curve_def_id'',''proxy_source_curve_def_id'')')
		--Pre validataing Data Type
		SET @source_table=@temp_table_name
		EXEC('delete from '+@temp_table_name+' where source_curve_def_id is null and source_system_id is null and curve_id is null and
		curve_name is null and curve_des is null and commodity_id is null and market_value_id is null and market_value_desc is null
		and source_currency_id is null and source_currency_to_id is null and source_curve_type_value_id is null and uom_id is null' )
		
		EXEC (' insert into #temp_tot_count select count(*) as totcount,'''+ @tablename+'''  from '+@temp_table_name)
		EXEC sp_validate_data_type @process_id,@field_compare_table,@source_table
--	end

--Data Import ****************************************************************************8
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data error for curve_id :''+ isnull(a.curve_id,''NULL'')+'' (Data Repetition Error, No of times:''+ cast(b.notimes as varchar)+'' )'',''Please check your data'' 
			from '+@temp_table_name + ' a inner join (select curve_id,count(*) notimes from '+ @temp_table_name+'
			 group by curve_id having count(*)>1) b 
			on a.curve_id=b.curve_id')

	
	EXEC( 'insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_curve_def_id :''+ isnull(a.source_curve_def_id,''NULL'') +'', source_system_id :''+ isnull(a.source_system_id,''NULL'') +'',
			 curve_id :''+ isnull(a.curve_id,''NULL'') + ''. (It is possible that the Data format may be incorrect)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a  where isnumeric(a.source_system_id)=0
		      	or isnumeric(a.source_curve_type_value_id)=0 and isnumeric(a.uom_id)=0 or (isnumeric(a.proxy_source_curve_def_id)=0 and a.proxy_source_curve_def_id is not null)
			or a.curve_id is null or a.curve_name is null or a.market_value_id is null')
	
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_curve_def_id :''+ isnull(a.source_curve_def_id,''NULL'') +'', source_system_id :''+ isnull(a.source_system_id,''NULL'') +'',
			 curve_id :''+ isnull(a.curve_id,''NULL'') +''.(Foreign Key commodity_id ''+ISNULL(a.commodity_id,''NULL'')+'' is not found)'' ,''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
			left join source_commodity b on b.commodity_id=a.commodity_id and b.source_system_id=a.source_system_id
			where #import_status.temp_id is null and b.commodity_id is null')

	
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_curve_def_id :''+ isnull(a.source_curve_def_id,''NULL'') +'', source_system_id :''+ isnull(a.source_system_id,''NULL'') +'',
			 curve_id :''+ isnull(a.curve_id,''NULL'') +''.(Foreign Key source_currency_id ''+ISNULL(a.source_currency_id,''NULL'')+'' is not found)'',''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
			left join source_currency b on b.currency_id=a.source_currency_id and b.source_system_id=a.source_system_id
			where #import_status.temp_id is null and b.currency_id is null')
		
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_curve_def_id :''+ isnull(a.source_curve_def_id,''NULL'') +'', source_system_id :''+ isnull(a.source_system_id,''NULL'') +'',
			 curve_id :''+ isnull(a.curve_id,''NULL'') +''.(Foreign Key source_currency_to_id ''+ISNULL(a.source_currency_to_id,''NULL'')+'' is not found)'',''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
			left join source_currency b on b.currency_id=a.source_currency_to_id and b.source_system_id=a.source_system_id
			where #import_status.temp_id is null and b.currency_id is null and a.source_currency_to_id is not null')
	--Granularity  defaulted to 'Monthly' whenever NULL (ISSUE: 2553)
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_curve_def_id :''+ isnull(a.source_curve_def_id,''NULL'') +'', source_system_id :''+ isnull(a.source_system_id,''NULL'') +'',
			 curve_id :''+ isnull(a.curve_id,''NULL'') +''.(Foreign Key Granularity ''+ISNULL(a.Granularity,''Monthly'')+'' is not found)'',''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
			left join static_data_value b on b.code=ISNULL(a.Granularity ,''Monthly'')
			AND b.TYPE_ID=978
			where #import_status.temp_id is null and b.value_id is null ')

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_curve_def_id :''+ isnull(a.source_curve_def_id,''NULL'') +'', source_system_id :''+ isnull(a.source_system_id,''NULL'') +'',
			 curve_id :''+ isnull(a.curve_id,''NULL'') +''.(Foreign Key exp_calendar_id ''+ISNULL(a.exp_calendar_id,''NULL'')+'' is not found)'',''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
			left join static_data_value b on b.code=a.exp_calendar_id  
			AND b.TYPE_ID=10017
			where #import_status.temp_id is null and b.value_id is null and a.exp_calendar_id is not null')

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_curve_def_id :''+ isnull(a.source_curve_def_id,''NULL'') +'', source_system_id :''+ isnull(a.source_system_id,''NULL'') +'',
			 curve_id :''+ isnull(a.curve_id,''NULL'') +''.(Foreign Key risk_bucket_id ''+ISNULL(a.risk_bucket_id,''NULL'')+'' is not found)'',''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
			left join source_price_curve_def b on b.curve_id=a.risk_bucket_id and b.source_system_id=a.source_system_id 
			where #import_status.temp_id is null and b.curve_id is null and a.risk_bucket_id is not null')


--	exec('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
--			''Data error for source_curve_def_id :''+ isnull(a.source_curve_def_id,''NULL'') +'', source_system_id :''+ isnull(a.source_system_id,''NULL'') +'',
--			 curve_id :''+ isnull(a.curve_id,''NULL'') +''.(Foreign Key reference_curve_id ''+ISNULL(a.reference_curve_id,''NULL'')+'' is not found)'',''Please check your data'' 
--			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
--			left join source_price_curve_def b on b.curve_id=a.reference_curve_id and b.source_system_id=a.source_system_id 
--			where #import_status.temp_id is null and b.curve_id is null and a.reference_curve_id is not null')

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_curve_def_id :''+ isnull(a.source_curve_def_id,''NULL'') +'', source_system_id :''+ isnull(a.source_system_id,''NULL'') +'',
			 curve_id :''+ isnull(a.curve_id,''NULL'') +''. (Invalid Data for source_curve_type_value_id: ''+a.source_curve_type_value_id+'')'',
			''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
			left join static_data_value b on b.value_id=a.source_curve_type_value_id and
			 b.type_id=575 where #import_status.temp_id is null and b.value_id is null
		and a.source_curve_type_value_id is not null
		')


	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_curve_def_id :''+ isnull(a.source_curve_def_id,''NULL'') +'', source_system_id :''+ isnull(a.source_system_id,''NULL'') +'',

			 curve_id :''+ isnull(a.curve_id,''NULL'') +''.(Foreign Key uom_id ''+ISNULL(a.uom_id,''NULL'')+'' is not found)'',''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
			left join source_uom b on b.uom_id=a.uom_id and b.source_system_id=a.source_system_id
			where #import_status.temp_id is null and b.uom_id is null')
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_curve_def_id :''+ isnull(a.source_curve_def_id,''NULL'') +'', source_system_id :''+ isnull(a.source_system_id,''NULL'') +'',

			 curve_id :''+ isnull(a.curve_id,''NULL'') +''.(Foreign Key uom_id ''+ISNULL(a.uom_id,''NULL'')+'' is not found)'',''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
			left join source_uom b on b.uom_id=a.uom_id and b.source_system_id=a.source_system_id
			where #import_status.temp_id is null and b.uom_id is null')
	EXEC('delete '+@temp_table_name + ' from #import_status inner join '+@temp_table_name + ' a on
		#import_status.temp_id=a.temp_id')
	
	CREATE TABLE #tmp_data_rb (curve_id VARCHAR(100) COLLATE DATABASE_DEFAULT,id INT)
	SET @sql='INSERT INTO #tmp_data_rb (curve_id,id) 
		SELECT  a.source_curve_def_id,b.source_curve_def_id 
		FROM  source_price_curve_def b 
		INNER JOIN '+@temp_table_name+' a 
		ON b.curve_id = a.risk_bucket_id AND b.source_system_id = a.source_system_id '
	EXEC(@sql)
	
--	CREATE TABLE #tmp_data_ref (source_curve_def_id int,id INT)
--	set @sql='INSERT INTO #tmp_data_ref (source_curve_def_id,id) 
--		SELECT  a.source_curve_def_id,b.source_curve_def_id 
--		FROM  source_price_curve_def b 
--		INNER JOIN '+@temp_table_name+' a 
--		ON b.curve_id = a.reference_curve_id AND b.source_system_id = a.source_system_id '
--	
--	exec(@sql)
	
	SET @sql='update  source_price_curve_def set   source_system_id=a.source_system_id,curve_name=a.curve_name,
			curve_des=a.curve_des,commodity_id=c.source_commodity_id,market_value_id=a.market_value_id,
			market_value_desc=a.market_value_desc,source_currency_id=d.source_currency_id,
			source_currency_to_id=
			case 
				when a.source_currency_to_id is null then null
				else g.source_currency_id
			end,
			source_curve_type_value_id=a.source_curve_type_value_id,
			uom_id=e.source_uom_id,proxy_source_curve_def_id=a.proxy_source_curve_def_id,
			Granularity=gra.value_id ,
			exp_calendar_id=ex.value_id,
			risk_bucket_id =rb.id
			--,reference_curve_id=ref.id
			FROM source_price_curve_def b INNER JOIN
                      '+@temp_table_name+' a ON b.curve_id = a.curve_id AND 
                      b.source_system_id = a.source_system_id INNER JOIN
                      source_uom e ON a.uom_id = e.uom_id AND a.source_system_id = e.source_system_id INNER JOIN
                      source_commodity c ON a.commodity_id = c.commodity_id AND a.source_system_id = c.source_system_id INNER JOIN
                      source_currency d ON a.source_currency_id = d.currency_id AND a.source_system_id = d.source_system_id INNER JOIN
                      source_system_description f ON a.source_system_id = f.source_system_id INNER JOIN
                      static_data_value h ON a.source_curve_type_value_id = h.value_id INNER JOIN
                      source_currency g ON 
		     g.currency_id = 
		     case 	
				when a.source_currency_to_id is  NULL then  g.currency_id
				else a.source_currency_to_id
		     end
			 AND a.source_system_id = g.source_system_id
			 inner join static_data_value gra on gra.code=ISNULL(a.Granularity,''Monthly'') AND gra.TYPE_ID=978
			 left join static_data_value ex on ex.code=a.exp_calendar_id AND ex.TYPE_ID=10017
			 left join #tmp_data_rb rb on rb.curve_id=a.source_curve_def_id  			
	--		 left join #tmp_data_ref ref on ref.source_curve_def_id=b.source_curve_def_id  
			left join #import_status on a.temp_id=#import_status.temp_id where #import_status.temp_id is null'

	SET @sql1='insert into source_price_curve_def(source_system_id,curve_id,curve_name,curve_des,commodity_id,
		market_value_id,market_value_desc,source_currency_id,source_currency_to_id,
		source_curve_type_value_id,uom_id,proxy_source_curve_def_id,
		Granularity ,
		exp_calendar_id,
		risk_bucket_id 
		--,reference_curve_id
		)
	 		select distinct a.source_system_id,a.curve_id,a.curve_name,a.curve_des,c.source_commodity_id,a.market_value_id,
			a.market_value_desc,d.source_currency_id,
			case 
				when a.source_currency_to_id is null then null
				else g.source_currency_id
			end
			,a.source_curve_type_value_id,e.source_uom_id,
			a.proxy_source_curve_def_id,
			gra.value_id ,
			ex.value_id,
			rb.source_curve_def_id
			--,ref1.source_curve_def_id		
			FROM   '+@temp_table_name+' a INNER JOIN
			source_uom e ON a.uom_id = e.uom_id AND a.source_system_id = e.source_system_id INNER JOIN
			source_commodity c ON a.commodity_id = c.commodity_id AND a.source_system_id = c.source_system_id INNER JOIN
			source_currency d ON a.source_currency_id = d.currency_id AND a.source_system_id = d.source_system_id INNER JOIN
			source_system_description f ON a.source_system_id = f.source_system_id INNER JOIN
			static_data_value h ON a.source_curve_type_value_id = h.value_id INNER JOIN
			source_currency g ON 
			g.currency_id = 
			case
				when a.source_currency_to_id is  NULL then  g.currency_id
				else a.source_currency_to_id
		     	end
			 AND a.source_system_id = g.source_system_id  
			 inner join static_data_value gra on gra.code=ISNULL(a.Granularity,''Monthly'') AND gra.TYPE_ID=978
			 left join static_data_value ex on ex.code=a.exp_calendar_id AND ex.TYPE_ID=10017
			 left join source_price_curve_def rb on rb.curve_id=a.risk_bucket_id and rb.source_system_id=a.source_system_id 			
		--	 left join source_price_curve_def ref1 on ref1.curve_id=a.reference_curve_id and ref1.source_system_id=a.source_system_id 
			left join source_price_curve_def i on i.curve_id=a.curve_id and i.source_system_id=a.source_system_id
			left join #import_status on a.temp_id=#import_status.temp_id where #import_status.temp_id is null
			and i.curve_id is null'	
			exec spa_print @sql
	EXEC(@sql)
	exec spa_print @sql1
	EXEC(@sql1)

END
IF CHARINDEX('4010',@table_id,1)<>0	--source_traders
BEGIN
	EXEC('delete '+@field_compare_table)
	SET @tablename=(SELECT code FROM static_data_value WHERE value_id=4010)
--	if @schedule_run='n'
--	begin
		EXEC('insert into '+@field_compare_table+ ' values (''source_traders'',''trader_id'',''trader_id'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_traders'',''trader_name'',''trader_name'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_traders'',''trader_desc'',''trader_desc'')')
		--Pre validataing Data Type
		SET @source_table=@temp_table_name
		EXEC('delete from '+@temp_table_name+' where source_trader_id is null and source_system_id is null and trader_id is null and
			trader_name is null and trader_desc is null')
		
		EXEC (' insert into #temp_tot_count select count(*) as totcount,'''+ @tablename+'''  from '+@temp_table_name)
		EXEC sp_validate_data_type @process_id,@field_compare_table,@source_table
--	end
	--exec('alter table '+ @temp_table_name+' add temp_id int identity')

--Data Import************************************************************************************8
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data error for trader_id :''+ isnull(a.trader_id,''NULL'')+'' (Data Repetition Error, No of times:''+ cast(b.notimes as varchar)+'' )'',''Please check your data'' 
			from '+@temp_table_name + ' a inner join (select trader_id,count(*) notimes from '+ @temp_table_name+'
			 group by trader_id having count(*)>1) b 
			on a.trader_id=b.trader_id')
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_trader_id :''+ isnull(a.source_trader_id,''NULL'')+'', source_system_id:''+isnull(a.source_system_id,''NULL'')+
			'', trader_id :''+ isnull(a.trader_id,''NULL'')+''.( Data format for source_system_id  ''+isnull(a.source_system_id,''NULL'')+'' 
			or trader_id ''+isnull(a.trader_id,''NULL'')+''  is invalid)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a where isnumeric(a.source_system_id)=0 or a.trader_id is  null')

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_trader_id :''+ isnull(a.source_trader_id,''NULL'')+'', source_system_id:''+isnull(a.source_system_id,''NULL'')+
			'', trader_id :''+ isnull(a.trader_id,''NULL'')+''. (Foreign Key source_system_id ''+ISNULL(a.source_system_id,''NULL'')+'' is not found)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
			left join source_system_description b on b.source_system_id=a.source_system_id
			where #import_status.temp_id is null and b.source_system_id is null')
	
	EXEC('delete '+@temp_table_name + ' from #import_status inner join '+@temp_table_name + ' a on
		#import_status.temp_id=a.temp_id')

	SET @sql='update source_traders  set source_system_id=b.source_system_id,trader_name=b.trader_name,
			trader_desc=b.trader_desc
			from source_traders  inner join '+@temp_table_name+' b on
			source_traders.trader_id=b.trader_id and source_traders.source_system_id=
			b.source_system_id inner join source_system_description d on
			 b.source_system_id = d.source_system_id 
			left join #import_status on b.temp_id=#import_status.temp_id where #import_status.temp_id is null'

	SET @sql1='insert into source_traders(source_system_id,trader_id,trader_name,trader_desc)
	 		select  a.source_system_id,a.trader_id,a.trader_name,a.trader_desc
			from '+@temp_table_name+' a
			inner join source_system_description d on a.source_system_id = d.source_system_id
			left join source_traders g on g.trader_id=a.trader_id
			and g.source_system_id=a.source_system_id left join #import_status on a.temp_id=#import_status.temp_id where #import_status.temp_id is null
			and   g.trader_id is null'
	EXEC(@sql)
	EXEC(@sql1)
END
--select * from static_data_value where type_id=4000
IF CHARINDEX('4014',@table_id,1)<>0	--source_brokers
BEGIN
	EXEC('delete '+@field_compare_table)
	SET @tablename=(SELECT code FROM static_data_value WHERE value_id=4014)
--	if @schedule_run='n'
--	begin
		EXEC('insert into '+@field_compare_table+ ' values (''source_brokers'',''broker_id'',''broker_id'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_brokers'',''broker_name'',''broker_name'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_brokers'',''broker_desc'',''broker_desc'')')
		--Pre validataing Data Type
		SET @source_table=@temp_table_name
		EXEC('delete from '+@temp_table_name+' where source_broker_id is null and source_system_id is null and broker_id is null and
			broker_name is null and broker_desc is null')
		
		EXEC (' insert into #temp_tot_count select count(*) as totcount,'''+ @tablename+'''  from '+@temp_table_name)
		EXEC sp_validate_data_type @process_id,@field_compare_table,@source_table
--	end
	--exec('alter table '+ @temp_table_name+' add temp_id int identity')

--Data Import************************************************************************************8
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data error for broker_id :''+ isnull(a.broker_id,''NULL'')+'' (Data Repetition Error, No of times:''+ cast(b.notimes as varchar)+'' )'',''Please check your data'' 
			from '+@temp_table_name + ' a inner join (select broker_id,count(*) notimes from '+ @temp_table_name+'
			 group by broker_id having count(*)>1) b 
			on a.broker_id=b.broker_id')
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_broker_id :''+ isnull(a.source_broker_id,''NULL'')+'', source_system_id:''+isnull(a.source_system_id,''NULL'')+
			'', broker_id :''+ isnull(a.broker_id,''NULL'')+''.( Data format for source_system_id  ''+isnull(a.source_system_id,''NULL'')+'' 
			or broker_id ''+isnull(a.broker_id,''NULL'')+''  is invalid)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a where isnumeric(a.source_system_id)=0 or a.broker_id is  null')

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_broker_id :''+ isnull(a.source_broker_id,''NULL'')+'', source_system_id:''+isnull(a.source_system_id,''NULL'')+
			'', broker_id :''+ isnull(a.broker_id,''NULL'')+''. (Foreign Key source_system_id ''+ISNULL(a.source_system_id,''NULL'')+'' is not found)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
			left join source_system_description b on b.source_system_id=a.source_system_id
			where #import_status.temp_id is null and b.source_system_id is null')
	
	EXEC('delete '+@temp_table_name + ' from #import_status inner join '+@temp_table_name + ' a on
		#import_status.temp_id=a.temp_id')

	SET @sql='update source_brokers  set source_system_id=b.source_system_id,broker_name=b.broker_name,
			broker_desc=b.broker_desc,UPDATE_TS=GETDATE(),UPDATE_USER=dbo.fnadbuser()
			from source_brokers  inner join '+@temp_table_name+' b on
			source_brokers.broker_id=b.broker_id and source_brokers.source_system_id=
			b.source_system_id inner join source_system_description d on
			 b.source_system_id = d.source_system_id 
			left join #import_status on b.temp_id=#import_status.temp_id where #import_status.temp_id is null'

	SET @sql1='insert into source_brokers(source_system_id,broker_id,broker_name,broker_desc,[create_user],[create_ts] ,[update_user],[update_ts])
	 		select  a.source_system_id,a.broker_id,a.broker_name,a.broker_desc,dbo.fnadbuser(),getdate(),dbo.fnadbuser(),getdate()
			from '+@temp_table_name+' a
			inner join source_system_description d on a.source_system_id = d.source_system_id
			left join source_brokers g on g.broker_id=a.broker_id
			and g.source_system_id=a.source_system_id left join #import_status on a.temp_id=#import_status.temp_id where #import_status.temp_id is null
			and   g.broker_id is null'
	EXEC(@sql)
	EXEC(@sql1)
END
IF CHARINDEX('4017',@table_id,1)<>0	--legal_entity
BEGIN
	EXEC('delete '+@field_compare_table)
	SET @tablename=(SELECT code FROM static_data_value WHERE value_id=4017)
--	if @schedule_run='n'
--	begin
		EXEC('insert into '+@field_compare_table+ ' values (''source_legal_entity'',''legal_entity_id'',''legal_entity_id'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_legal_entity'',''legal_entity_name'',''legal_entity_name'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_legal_entity'',''legal_entity_desc'',''legal_entity_desc'')')
		--Pre validataing Data Type
		SET @source_table=@temp_table_name
		EXEC('delete from '+@temp_table_name+' where source_legal_entity_id is null and source_system_id is null and legal_entity_id is null and
			legal_entity_name is null and legal_entity_desc is null')
		
		EXEC (' insert into #temp_tot_count select count(*) as totcount,'''+ @tablename+'''  from '+@temp_table_name)
		EXEC sp_validate_data_type @process_id,@field_compare_table,@source_table
--	end
	--exec('alter table '+ @temp_table_name+' add temp_id int identity')

--Data Import************************************************************************************8
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data error for legal_entity_id :''+ isnull(a.legal_entity_id,''NULL'')+'' (Data Repetition Error, No of times:''+ cast(b.notimes as varchar)+'' )'',''Please check your data'' 
			from '+@temp_table_name + ' a inner join (select legal_entity_id,count(*) notimes from '+ @temp_table_name+'
			 group by legal_entity_id having count(*)>1) b 
			on a.legal_entity_id=b.legal_entity_id')
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_legal_entity_id :''+ isnull(a.source_legal_entity_id,''NULL'')+'', source_system_id:''+isnull(a.source_system_id,''NULL'')+
			'', legal_entity_id :''+ isnull(a.legal_entity_id,''NULL'')+''.( Data format for source_system_id  ''+isnull(a.source_system_id,''NULL'')+'' 
			or legal_entity_id ''+isnull(a.legal_entity_id,''NULL'')+''  is invalid)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a where isnumeric(a.source_system_id)=0 or a.legal_entity_id is  null')

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_legal_entity_id :''+ isnull(a.source_legal_entity_id,''NULL'')+'', source_system_id:''+isnull(a.source_system_id,''NULL'')+
			'', legal_entity_id :''+ isnull(a.legal_entity_id,''NULL'')+''. (Foreign Key source_system_id ''+ISNULL(a.source_system_id,''NULL'')+'' is not found)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
			left join source_system_description b on b.source_system_id=a.source_system_id
			where #import_status.temp_id is null and b.source_system_id is null')
	
	EXEC('delete '+@temp_table_name + ' from #import_status inner join '+@temp_table_name + ' a on
		#import_status.temp_id=a.temp_id')

	SET @sql='update source_legal_entity  set source_system_id=b.source_system_id,legal_entity_name=b.legal_entity_name,
			legal_entity_desc=b.legal_entity_desc,UPDATE_TS=GETDATE(),UPDATE_USER=dbo.fnadbuser()
			from source_legal_entity  inner join '+@temp_table_name+' b on
			source_legal_entity.legal_entity_id=b.legal_entity_id and source_legal_entity.source_system_id=
			b.source_system_id inner join source_system_description d on
			 b.source_system_id = d.source_system_id 
			left join #import_status on b.temp_id=#import_status.temp_id where #import_status.temp_id is null'

	SET @sql1='insert into source_legal_entity(source_system_id,legal_entity_id,legal_entity_name,legal_entity_desc,[create_user],[create_ts] ,[update_user],[update_ts])
	 		select  a.source_system_id,a.legal_entity_id,a.legal_entity_name,a.legal_entity_desc,dbo.fnadbuser(),getdate(),dbo.fnadbuser(),getdate()
			from '+@temp_table_name+' a
			inner join source_system_description d on a.source_system_id = d.source_system_id
			left join source_legal_entity g on g.legal_entity_id=a.legal_entity_id
			and g.source_system_id=a.source_system_id left join #import_status on a.temp_id=#import_status.temp_id where #import_status.temp_id is null
			and   g.legal_entity_id is null'
	EXEC(@sql)
	EXEC(@sql1)
END


/****** *******    credit rating   ********************************/
IF CHARINDEX('4024',@table_id,1)<>0	--	Default Probabilty
BEGIN
	EXEC('delete '+@field_compare_table)
	SET @tablename=(SELECT code FROM static_data_value WHERE value_id=4024)
--	if @schedule_run='n'
--	begin
		EXEC('insert into '+@field_compare_table+ ' values (''default_probability'',''effective_date'',''effective_date'')')
--		exec('insert into '+@field_compare_table+ ' values (''default_probability'',''debt_rating'',''debt_rating'')')
		EXEC('insert into '+@field_compare_table+ ' values (''default_probability'',''recovery'',''recovery'')')
		EXEC('insert into '+@field_compare_table+ ' values (''default_probability'',''months'',''months'')')
		EXEC('insert into '+@field_compare_table+ ' values (''default_probability'',''probability'',''probability'')')
		SET @source_table=@temp_table_name
		EXEC('delete from '+@temp_table_name+' where effective_date is null and debt_rating is null and recovery is null and
		months is null and probability is null ')

		-- insert into #temp_tot_count tot count from temp table
		EXEC (' insert into #temp_tot_count select count(*) as totcount,'''+ @tablename+'''  from '+@temp_table_name)
--exec('select * from '+@temp_table_name)
		EXEC sp_validate_data_type @process_id,@field_compare_table,@source_table
--	end
--exec('select * from '+@temp_table_name)

---Data Import********************************************************************
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data error for Debt_rating:''+ isnull(a.Debt_rating,''NULL'')+'' Effective_date:''+ isnull(a.Effective_date,''NULL'')+'' Months:''+ isnull(a.Months,''NULL'')+'' (Data Repetition Error, No of times:''+ cast(b.notimes as varchar)+'' )''
			,''Please check your data'' 
			from '+@temp_table_name + ' a inner join (select debt_rating,effective_date,months,count(*) notimes from '+ @temp_table_name+'
			 group by debt_rating,effective_date,months having count(*)>1) b 
			on a.debt_rating=b.debt_rating and a.effective_date=b.effective_date and a.months=b.months')
		exec spa_print 'kk'		
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for Debt_rating:''+ isnull(a.Debt_rating,''NULL'')+'' Effective_date:''+ isnull(a.Effective_date,''NULL'')+'' Months:''+ isnull(a.Months,''NULL'')
			+''.( Data format for effective_date  ''+isnull(a.effective_date,''NULL'')+'' 
			or probability ''+isnull(a.probability,''NULL'')+'' is invalid)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a where isdate(a.effective_date)=0 or
			 isnumeric(a.probability)=0 or a.probability is null or effective_date is null')
		
		exec spa_print 'kk1'	
		--Check for Foreign key validation and insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) table if any invalid data found
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			
			''Data error for Debt_rating:''+ isnull(a.Debt_rating,''NULL'')+'' Effective_date:''+ isnull(a.Effective_date,''NULL'')+'' Months:''+ isnull(a.Months,''NULL'')
			+''. (Foreign Key Debt_rating ''+ISNULL(a.Debt_rating,''NULL'')+'' not found)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
			left join static_data_value b on 
			b.CODE=a.Debt_rating where #import_status.temp_id is null and b.value_id is null')
			
	exec spa_print 'kk2'	
		-- delete from temp table all the invalid data
		EXEC('delete '+@temp_table_name + ' from #import_status inner join '+@temp_table_name + ' a on
		#import_status.temp_id=a.temp_id')

		-- Update  actual table from temp table
		SET @sql='update default_probability  set effective_date=b.effective_date,debt_rating=C.VALUE_ID,recovery=b.recovery,
			months=b.months,probability=b.probability,UPDATE_TS=GETDATE(),UPDATE_USER=dbo.fnadbuser()
			from  '+@temp_table_name+' b INNER JOIN STATIC_DATA_VALUE C ON C.CODE=B.debt_rating
			inner join default_probability a 
			on a.debt_rating=C.VALUE_ID and a.effective_date=b.effective_date and a.months=b.months
			left join #import_status on b.temp_id=#import_status.temp_id where #import_status.temp_id is null'
		exec spa_print @sql
		--insert into actual table from temp table
		SET @sql1='
		INSERT INTO [dbo].[default_probability]
				   ([effective_date]
				   ,[debt_rating]
				   ,[recovery]
				   ,[months]
				   ,[probability]
				   ,[create_user]
				   ,[create_ts]
				   ,[update_user]
				   ,[update_ts])
			 select
				   A.[effective_date]
				   ,c.VALUE_ID
				   ,A.[recovery]
				   ,A.[months]
				   ,A.[probability]
					,dbo.fnadbuser()
					,getdate()
					,dbo.fnadbuser()
					,getdate()
					from '+@temp_table_name+'
					a  inner join
					static_data_value c on a.[debt_rating]=c.CODE 
					left join [default_probability] e on
					e.[debt_rating]=C.VALUE_ID and 
					e.[effective_date]=a.[effective_date] and  e.[months]=a.[months]
					left join #import_status on a.temp_id=#import_status.temp_id where #import_status.temp_id is null
					and e.[effective_date] is null '


	EXEC(@sql)
		exec spa_print @sql1
	EXEC(@sql1)
END
/********************** End of credit trading  ********************/

/****** *******    Recovery rate    ********************************/
IF CHARINDEX('4025',@table_id,1)<>0	--	Recovery rate 
BEGIN
	EXEC('delete '+@field_compare_table)
	SET @tablename=(SELECT code FROM static_data_value WHERE value_id=4025)
--	if @schedule_run='n'
--	begin
		EXEC('insert into '+@field_compare_table+ ' values (''default_recovery_rate'',''effective_date'',''effective_date'')')
--		exec('insert into '+@field_compare_table+ ' values (''default_recovery_rate'',''debt_rating'',''debt_rating'')')
		EXEC('insert into '+@field_compare_table+ ' values (''default_recovery_rate'',''recovery'',''recovery'')')
		EXEC('insert into '+@field_compare_table+ ' values (''default_recovery_rate'',''months'',''months'')')
		EXEC('insert into '+@field_compare_table+ ' values (''default_recovery_rate'',''rate'',''rate'')')
		SET @source_table=@temp_table_name
		EXEC('delete from '+@temp_table_name+' where effective_date is null and debt_rating is null and recovery is null and
		months is null and rate is null ')

		-- insert into #temp_tot_count tot count from temp table
		EXEC (' insert into #temp_tot_count select count(*) as totcount,'''+ @tablename+'''  from '+@temp_table_name)
--exec('select * from '+@temp_table_name)
		EXEC sp_validate_data_type @process_id,@field_compare_table,@source_table
--	end
--exec('select * from '+@temp_table_name)

---Data Import********************************************************************
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data error for Debt_rating:''+ isnull(a.Debt_rating,''NULL'')+'' Effective_date:''+ isnull(a.Effective_date,''NULL'')+'' Months:''+ isnull(a.Months,''NULL'')+'' (Data Repetition Error, No of times:''+ cast(b.notimes as varchar)+'' )''
			,''Please check your data'' 
			from '+@temp_table_name + ' a inner join (select debt_rating,effective_date,months,count(*) notimes from '+ @temp_table_name+'
			 group by debt_rating,effective_date,months having count(*)>1) b 
			on a.debt_rating=b.debt_rating and a.effective_date=b.effective_date and a.months=b.months')
		exec spa_print 'kk'		
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for Debt_rating:''+ isnull(a.Debt_rating,''NULL'')+'' Effective_date:''+ isnull(a.Effective_date,''NULL'')+'' Months:''+ isnull(a.Months,''NULL'')
			+''.( Data format for effective_date  ''+isnull(a.effective_date,''NULL'')+'' 
			or rate ''+isnull(a.rate,''NULL'')+'' is invalid)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a where isdate(a.effective_date)=0 or
			 isnumeric(a.rate)=0 or a.rate is null or effective_date is null')
		
		exec spa_print 'kk1'	
		--Check for Foreign key validation and insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) table if any invalid data found
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			
			''Data error for Debt_rating:''+ isnull(a.Debt_rating,''NULL'')+'' Effective_date:''+ isnull(a.Effective_date,''NULL'')+'' Months:''+ isnull(a.Months,''NULL'')
			+''. (Foreign Key Debt_rating ''+ISNULL(a.Debt_rating,''NULL'')+'' not found)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
			left join static_data_value b on 
			b.CODE=a.Debt_rating where #import_status.temp_id is null and b.value_id is null')
			
	exec spa_print 'kk2'	
		-- delete from temp table all the invalid data
		EXEC('delete '+@temp_table_name + ' from #import_status inner join '+@temp_table_name + ' a on
		#import_status.temp_id=a.temp_id')

		-- Update  actual table from temp table
		SET @sql='update default_recovery_rate  set effective_date=b.effective_date,debt_rating=C.VALUE_ID,recovery=b.recovery,
			months=b.months,rate=b.rate,UPDATE_TS=GETDATE(),UPDATE_USER=dbo.fnadbuser()
			from  '+@temp_table_name+' b INNER JOIN STATIC_DATA_VALUE C ON C.CODE=B.debt_rating
			inner join default_recovery_rate a 
			on a.debt_rating=C.VALUE_ID and a.effective_date=b.effective_date and a.months=b.months
			left join #import_status on b.temp_id=#import_status.temp_id where #import_status.temp_id is null'
		exec spa_print @sql
		--insert into actual table from temp table
		SET @sql1='
		INSERT INTO [dbo].[default_recovery_rate]
				   ([effective_date]
				   ,[debt_rating]
				   ,[recovery]
				   ,[months]
				   ,rate
				   ,[create_user]
				   ,[create_ts]
				   ,[update_user]
				   ,[update_ts])
			 select
				   A.[effective_date]
				   ,c.VALUE_ID
				   ,A.[recovery]
				   ,A.[months]
				   ,A.[rate]
					,dbo.fnadbuser()
					,getdate()
					,dbo.fnadbuser()
					,getdate()
					from '+@temp_table_name+'
					a  inner join
					static_data_value c on a.[debt_rating]=c.CODE 
					left join [default_recovery_rate] e on
					e.[debt_rating]=C.VALUE_ID and 
					e.[effective_date]=a.[effective_date] and  e.[months]=a.[months]
					left join #import_status on a.temp_id=#import_status.temp_id where #import_status.temp_id is null
					and e.[effective_date] is null '


	EXEC(@sql)
		exec spa_print @sql1
	EXEC(@sql1)
END
/********************** End of Recovery rate   ********************/

/****** *******    Source Schedule    ********************************/
IF CHARINDEX('5473',@table_id,1)<>0	--	Source Schedule
BEGIN
	EXEC('delete '+@field_compare_table)
	SET @tablename=(SELECT code FROM static_data_value WHERE value_id=292343)

		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_detail'',''term_start'',''term_start'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_detail'',''deal_volume'',''volume'')')

		SET @source_table=@temp_table_name
		EXEC('delete from '+@temp_table_name+' where (source_deal_header_id is null and reference_id is null) or term_start is null or volume is null 
		 ')

		-- insert into #temp_tot_count tot count from temp table
		EXEC (' insert into #temp_tot_count select count(*) as totcount,'''+ @tablename+'''  from '+@temp_table_name)
--exec('select * from '+@temp_table_name)
		EXEC sp_validate_data_type @process_id,@field_compare_table,@source_table
--	end
--exec('select * from '+@temp_table_name)

DECLARE @Internal_Storage_Scheduled_id VARCHAR(5)
SET @Internal_Storage_Scheduled_id=21

---Data Import********************************************************************
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) 
			select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Error - ID:''+ isnull(a.source_deal_header_id,''NULL'')+'' Term Start:''+ isnull(a.term_start,''NULL'')+'' Volume:''+ isnull(a.volume,''NULL'')+'' is not Storage Deal''
			,''Please check your data'' 
			from '+@temp_table_name + ' a left outer join source_deal_header sdh 
			on a.source_deal_header_id=sdh.source_deal_header_id and sdh.internal_deal_type_value_id='+@Internal_Storage_Scheduled_id+ ' 
			where sdh.source_deal_header_id is null and a.source_deal_header_id is not null 
			')
		exec spa_print '1'		
		
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) 
			select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Error - Reference ID:''+ isnull(a.reference_id,''NULL'')+'' Term Start:''+ isnull(a.term_start,''NULL'')+'' Volume:''+ isnull(a.volume,''NULL'')+'' is not Storage Deal''
			,''Please check your data'' 
			from '+@temp_table_name + ' a left outer join source_deal_header sdh 
			on a.reference_id=sdh.deal_id and sdh.internal_deal_type_value_id='+@Internal_Storage_Scheduled_id+ ' 
			where sdh.source_deal_header_id is null and a.reference_id is not null 
			')
		exec spa_print '2'	
		
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) 
			select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data format error for ID :''+ isnull(a.source_deal_header_id,''NULL'')+'' Reference ID:''+ isnull(a.reference_id,''NULL'') +'' Term Start:''+ isnull(a.term_start,''NULL'')+'' Volume:''+ isnull(a.volume,''NULL'')+''.''
			,''Please check your data'' 
			from '+@temp_table_name + ' a 
			where isDate(a.term_start)=0 or isNumeric(a.volume)=0
		')
		
		exec spa_print '3'	
			
	exec spa_print 'kk2'	
		-- delete from temp table all the invalid data
		EXEC('delete '+@temp_table_name + ' from #import_status inner join '+@temp_table_name + ' a on
		#import_status.temp_id=a.temp_id')
		
		
		SET @sql='
		update '+@temp_table_name+' 
		SET source_deal_header_id=sdh.source_deal_header_id 
		FROM '+@temp_table_name+' b JOIN source_deal_header sdh 
		ON b.reference_id=sdh.deal_id  AND sdh.internal_deal_type_value_id='+@Internal_Storage_Scheduled_id
		exec spa_print @sql
		EXEC(@sql)

		-- Update  actual table from temp table
		SET @sql='update source_deal_detail  set deal_volume=b.volume
			from  '+@temp_table_name+' b 
			inner join source_deal_detail sdd
			on b.source_deal_header_id=sdd.source_deal_header_id AND CAST(b.term_start  AS DATETIME)=sdd.term_start AND sdd.leg=1'
		exec spa_print @sql
		EXEC(@sql)
		
		--insert into if not exist 
		SET @sql='
		 INSERT INTO source_deal_detail
	      (
	        source_deal_header_id,
	        Leg,
	        contract_expiration_date,
	        fixed_float_leg,
	        buy_sell_flag,
	        curve_id,
	        fixed_price,
	        fixed_price_currency_id,
	        option_strike_price,
	        deal_volume_frequency,
	        deal_volume_uom_id,
	        block_description,
	        deal_detail_description,
	        volume_left,
	        settlement_volume,
	        settlement_uom,
	        price_adder,
	        price_multiplier,
	        settlement_date,
	        day_count_id,
	        location_id,
	        meter_id,
	        physical_financial_flag,
	        Booked,
	        process_deal_status,
	        fixed_cost,
	        multiplier,
	        adder_currency_id,
	        fixed_cost_currency_id,
	        formula_currency_id,
	        price_adder2,
	        price_adder_currency2,
	        volume_multiplier2,
	        pay_opposite,
	        capacity,
	        settlement_currency,
	        standard_yearly_volume,
	        formula_curve_id,
	        price_uom_id,
	        category,
	        profile_code,
	        pv_party,
	        term_start,
	        term_end,
	        deal_volume
	      )
	      (
	           SELECT sdd.source_deal_header_id,
	                  sdd.Leg,
	                  sdd.contract_expiration_date,
	                  sdd.fixed_float_leg,
	                  sdd.buy_sell_flag,
	                  sdd.curve_id,
	                  sdd.fixed_price,
	                  sdd.fixed_price_currency_id,
	                  sdd.option_strike_price,
	                  sdd.deal_volume_frequency,
	                  sdd.deal_volume_uom_id,
	                  sdd.block_description,
	                  sdd.deal_detail_description,
	                  sdd.volume_left,
	                  sdd.settlement_volume,
	                  sdd.settlement_uom,
	                  sdd.price_adder,
	                  sdd.price_multiplier,
	                  sdd.settlement_date,
	                  sdd.day_count_id,
	                  sdd.location_id,
	                  sdd.meter_id,
	                  sdd.physical_financial_flag,
	                  sdd.Booked,
	                  sdd.process_deal_status,
	                  sdd.fixed_cost,
	                  sdd.multiplier,
	                  sdd.adder_currency_id,
	                  sdd.fixed_cost_currency_id,
	                  sdd.formula_currency_id,
	                  sdd.price_adder2,
	                  sdd.price_adder_currency2,
	                  sdd.volume_multiplier2,
	                  sdd.pay_opposite,
	                  sdd.capacity,
	                  sdd.settlement_currency,
	                  sdd.standard_yearly_volume,
	                  sdd.formula_curve_id,
	                  sdd.price_uom_id,
	                  sdd.category,
	                  sdd.profile_code,
	                  sdd.pv_party,
	                  td.term_start [term_start],
	                  td.term_start [term_end],
	                  td.volume
      FROM   '+@temp_table_name+' td
					  CROSS APPLY
						(SELECT sdd1.source_deal_header_id,MAX(sdd1.Leg)Leg,MAX(sdd1.contract_expiration_date)contract_expiration_date,MAX(sdd1.fixed_float_leg)fixed_float_leg,
								MAX(sdd1.buy_sell_flag)buy_sell_flag,MAX(sdd1.curve_id)curve_id,MAX(sdd1.fixed_price)fixed_price,MAX(sdd1.fixed_price_currency_id)fixed_price_currency_id,
								MAX(sdd1.option_strike_price)option_strike_price,MAX(sdd1.deal_volume_frequency)deal_volume_frequency,MAX(sdd1.deal_volume_uom_id)deal_volume_uom_id,
								MAX(sdd1.block_description)block_description,MAX(sdd1.deal_detail_description)deal_detail_description,MAX(sdd1.formula_id)formula_id,MAX(sdd1.volume_left)volume_left,
								MAX(sdd1.settlement_volume)settlement_volume,MAX(sdd1.settlement_uom)settlement_uom,MAX(sdd1.price_adder)price_adder,MAX(sdd1.price_multiplier)price_multiplier,
								MAX(sdd1.settlement_date)settlement_date,MAX(sdd1.day_count_id)day_count_id,MAX(sdd1.location_id)location_id,MAX(sdd1.meter_id)meter_id,MAX(sdd1.physical_financial_flag)physical_financial_flag,
								MAX(sdd1.Booked)Booked,MAX(sdd1.process_deal_status)process_deal_status,MAX(sdd1.fixed_cost)fixed_cost,MAX(sdd1.multiplier)multiplier,MAX(sdd1.adder_currency_id)adder_currency_id,
								MAX(sdd1.fixed_cost_currency_id)fixed_cost_currency_id,MAX(sdd1.formula_currency_id)formula_currency_id,MAX(sdd1.price_adder2)price_adder2,MAX(sdd1.price_adder_currency2)price_adder_currency2,
								MAX(sdd1.volume_multiplier2)volume_multiplier2,MAX(sdd1.total_volume)total_volume,MAX(sdd1.pay_opposite)pay_opposite,MAX(sdd1.capacity)capacity,MAX(sdd1.settlement_currency)settlement_currency,
								MAX(sdd1.standard_yearly_volume)standard_yearly_volume,MAX(sdd1.formula_curve_id)formula_curve_id,MAX(sdd1.price_uom_id)price_uom_id,MAX(sdd1.category)category,MAX(sdd1.profile_code)profile_code,MAX(sdd1.pv_party)pv_party 
							FROM source_deal_detail sdd1 
							WHERE 1=1
								AND sdd1.source_deal_header_id = td.source_deal_header_id  
								AND sdd1.Leg =1 								
							GROUP BY sdd1.source_deal_header_id
						) sdd
					   LEFT JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = td.source_deal_header_id
						 AND sdd2.Leg = 1
						 AND sdd2.term_start = td.term_start 							   	
	           WHERE  sdd2.source_deal_header_id IS NULL
	           ) 
	           '
		exec spa_print @sql
		EXEC(@sql)
		
		DECLARE @position_deals VARCHAR(100),@pos_job_name VARCHAR(500)
		-- Call Position Breakdown
		SET @position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@process_id)
		EXEC ('CREATE TABLE ' + @position_deals + '( source_deal_header_id INT, action CHAR(1))')
		
		SET @sql = 'INSERT INTO ' + @position_deals + '(source_deal_header_id, action)
					SELECT DISTINCT source_deal_header_id,''u'' FROM '+@temp_table_name+' a'
		EXEC(@sql)
							
		SET @pos_job_name= 'calc_position_breakdown_' + @process_id
		SET @sql = 'spa_update_deal_total_volume NULL,'''+@process_id+''',0,1,''' + @user_login_id + ''''
		EXEC spa_run_sp_as_job @pos_job_name,  @sql, 'generating_report_table', @user_login_id
		
	
END
/********************** End of Source Schedule   ********************/


/****** *******    curve correlation   ********************************/
IF CHARINDEX('4026',@table_id,1)<>0	--	curve_correlation 

BEGIN
	EXEC('delete '+@field_compare_table)
	SET @tablename=(SELECT code FROM static_data_value WHERE value_id=4026)
--	if @schedule_run='n'
--	begin
	--	exec('insert into '+@field_compare_table+ ' values (''curve_correlation'',''vol_cor_header_id'',''vol_cor_header_id'')')
		EXEC('insert into '+@field_compare_table+ ' values (''curve_correlation'',''as_of_date'',''as_of_date'')')
--		exec('insert into '+@field_compare_table+ ' values (''curve_correlation'',''curve_id_from'',''curve_id_from'')')
--		exec('insert into '+@field_compare_table+ ' values (''curve_correlation'',''curve_id_to'',''curve_id_to'')')
		EXEC('insert into '+@field_compare_table+ ' values (''curve_correlation'',''term1'',''term1'')')
		EXEC('insert into '+@field_compare_table+ ' values (''curve_correlation'',''term2'',''term2'')')
	--	exec('insert into '+@field_compare_table+ ' values (''curve_correlation'',''curve_source_value_id'',''curve_source_value_id'')')
		EXEC('insert into '+@field_compare_table+ ' values (''curve_correlation'',''value'',''value'')')
		SET @source_table=@temp_table_name
		EXEC('delete from '+@temp_table_name+' where  as_of_date is null and curve_id_from is null and curve_id_to is null and
		term1 is null and term2 is null and curve_source_value_id is null')

		-- insert into #temp_tot_count tot count from temp table
		EXEC (' insert into #temp_tot_count select count(*) as totcount,'''+ @tablename+'''  from '+@temp_table_name)
--exec('select * from '+@temp_table_name)
		EXEC sp_validate_data_type @process_id,@field_compare_table,@source_table
--	end
--exec('select * from '+@temp_table_name)

---Data Import********************************************************************
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data error for  As of Date:''+ isnull(a.as_of_date,''NULL'')+'' CurveId From:''+ isnull(a.curve_id_from,''NULL'')+'' 
			CurveId To:''+ isnull(a.curve_id_to,''NULL'')+'' Term1:''+isnull(a.Term1,''NULL'')+'' Term2:''+isnull(a.Term2,''NULL'')+''
			 Curve Source ValueId:''+isnull(a.curve_source_value_id,''NULL'')+''(Data Repetition Error, No of times:''+ cast(b.notimes as varchar)+'' )''
			,''Please check your data'' 
			from '+@temp_table_name + ' a inner join (select as_of_date,curve_id_from,curve_id_to,term1,term2,curve_source_value_id,count(*) notimes from '+ @temp_table_name+'
			 group by as_of_date,curve_id_from,curve_id_to,term1,term2,curve_source_value_id having count(*)>1) b 
			on a.as_of_date=b.as_of_date and a.curve_id_from=b.curve_id_from and a.curve_id_to=b.curve_id_to and a.term1=b.term1 and a.term2=b.term2 and a.curve_source_value_id=b.curve_source_value_id')
--		exec spa_print 'kk'		
--		exec('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
--			''Data error for Debt_rating:''+ isnull(a.Debt_rating,''NULL'')+'' Effective_date:''+ isnull(a.Effective_date,''NULL'')+'' Months:''+ isnull(a.Months,''NULL'')
--			+''.( Data format for effective_date  ''+isnull(a.effective_date,''NULL'')+'' 
--			or rate ''+isnull(a.rate,''NULL'')+'' is invalid)'',
--			''Please check your data'' 
--			from '+@temp_table_name + ' a where isdate(a.effective_date)=0 or
--			 isnumeric(a.rate)=0 or a.rate is null or effective_date is null')
		
		exec spa_print 'kk1'	
		--Check for Foreign key validation and insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) table if any invalid data found
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			
			''Data error for As of Date:''+ isnull(a.as_of_date,''NULL'')+'' CurveId From:''+ isnull(a.curve_id_from,''NULL'')+'' 
			CurveId To:''+ isnull(a.curve_id_to,''NULL'')+'' Term1:''+isnull(a.Term1,''NULL'')+'' Term2:''+isnull(a.Term2,''NULL'')+''
			 Curve Source ValueId:''+isnull(a.curve_source_value_id,''NULL'')+''. (Foreign Key CurveId From ''+ISNULL(a.curve_id_from,''NULL'')+'' not found)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a 
			left join #import_status on a.temp_id=#import_status.temp_id
			left join source_price_curve_def spcd on a.curve_id_from =spcd.curve_id
			---left join source_price_curve_def spcd1 on a.curve_id_to =spcd1.curve_id
			where #import_status.temp_id is null and spcd.source_curve_def_id is null')

			EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			
			''Data error for As of Date:''+ isnull(a.as_of_date,''NULL'')+'' CurveId From:''+ isnull(a.curve_id_from,''NULL'')+'' 
			CurveId To:''+ isnull(a.curve_id_to,''NULL'')+'' Term1:''+isnull(a.Term1,''NULL'')+'' Term2:''+isnull(a.Term2,''NULL'')+''
			 Curve Source ValueId:''+isnull(a.curve_source_value_id,''NULL'')+''. (Foreign Key CurveId To ''+ISNULL(a.curve_id_to,''NULL'')+'' not found)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a 
			left join #import_status on a.temp_id=#import_status.temp_id
			--left join source_price_curve_def spcd on a.curve_id_from =spcd.curve_id
			left join source_price_curve_def spcd1 on a.curve_id_to =spcd1.curve_id
			where #import_status.temp_id is null and spcd1.source_curve_def_id is null')

			EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for As of Date:''+ isnull(a.as_of_date,''NULL'')+'' CurveId From:''+ isnull(a.curve_id_from,''NULL'')+'' 
			CurveId To:''+ isnull(a.curve_id_to,''NULL'')+'' Term1:''+isnull(a.Term1,''NULL'')+'' Term2:''+isnull(a.Term2,''NULL'')+''
			 Curve Source ValueId:''+isnull(a.curve_source_value_id,''NULL'')+''. (Foreign Key Curve Source ValueId ''+ISNULL(a.curve_source_value_id,''NULL'')+'' not found)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a 
			left join #import_status on a.temp_id=#import_status.temp_id
	--		left join source_price_curve_def spcd on a.curve_id_from =spcd.curve_id
	--		left join source_price_curve_def spcd1 on a.curve_id_to =spcd1.curve_id
			left join static_data_value c on c.code=a.curve_source_value_id
			
			where #import_status.temp_id is null and c.value_id is null')
			
	exec spa_print 'kk2'	
		-- delete from temp table all the invalid data
		EXEC('delete '+@temp_table_name + ' from #import_status inner join '+@temp_table_name + ' a on
		#import_status.temp_id=a.temp_id')

		 ---Update  actual table from temp table
		SET @sql='update curve_correlation  set as_of_date=b.as_of_date,curve_id_from=spcd.source_curve_def_id,
			curve_id_to=spcd1.source_curve_def_id,term1=b.term1,term2=b.term2,curve_source_value_id=c.value_id,value=b.value,
			UPDATE_TS=GETDATE(),UPDATE_USER=dbo.fnadbuser()
			from  '+@temp_table_name+' b INNER JOIN STATIC_DATA_VALUE C ON C.CODE=B.curve_source_value_id
			inner join source_price_curve_def spcd on b.curve_id_from =spcd.curve_id
			inner join source_price_curve_def spcd1 on b.curve_id_to=spcd1.curve_id
			inner join curve_correlation a on a.curve_source_value_id=C.VALUE_ID and a.as_of_date=b.as_of_date and a.curve_id_from=spcd.source_curve_def_id
			and a.curve_id_to=spcd1.source_curve_def_id and a.term1=b.term1 and a.term2=b.term2 and a.curve_source_value_id=c.value_id
			left join #import_status on b.temp_id=#import_status.temp_id where #import_status.temp_id is null'
		exec spa_print @sql
		--insert into actual table from temp table
		SET @sql1='
		INSERT INTO [dbo].[curve_correlation]
				   (
					[as_of_date] ,
					[curve_id_from],
					[curve_id_to],
					[term1],
					[term2],
					[curve_source_value_id],
					[value],
					[create_user],
				    [create_ts],
				    [update_user],
				    [update_ts]
			)
			 select
					a.[as_of_date]
					,spcd.source_curve_def_id
					,spcd1.source_curve_def_id
					,a.[term1]
					,a.[term2]
					,c.value_id
					,a.[value]
					,dbo.fnadbuser()
					,getdate()
					,dbo.fnadbuser()
					,getdate()
					from '+ @temp_table_name +' a 
					inner join static_data_value c on a.[curve_source_value_id]=c.code 
					inner join source_price_curve_def spcd on a.curve_id_from =spcd.curve_id
					inner join source_price_curve_def spcd1 on a.curve_id_to=spcd1.curve_id
					left join [curve_correlation] e on e.[curve_source_value_id]=C.VALUE_ID and e.[term1]=a.[term1] and  e.[term2]=a.[term2]
					and a.as_of_date=e.as_of_date and e.curve_id_from=spcd.source_curve_def_id
					and e.curve_id_to=spcd1.source_curve_def_id 
					left join #import_status on a.temp_id=#import_status.temp_id where #import_status.temp_id is null and e.curve_id_to is null'


	EXEC(@sql)
		exec spa_print @sql1
	EXEC(@sql1)
END
/********************** End of curve correlation   ********************/

/****** *******    curve volatility   ********************************/
IF CHARINDEX('4027',@table_id,1)<>0	--	curve_volatility 

BEGIN
	EXEC('delete '+@field_compare_table)
	SET @tablename=(SELECT code FROM static_data_value WHERE value_id=4027)
--	if @schedule_run='n'
--	begin
	
		EXEC('insert into '+@field_compare_table+ ' values (''curve_volatility'',''as_of_date'',''as_of_date'')')
		EXEC('insert into '+@field_compare_table+ ' values (''curve_volatility'',''term'',''term'')')
		EXEC('insert into '+@field_compare_table+ ' values (''curve_volatility'',''value'',''value'')')
		SET @source_table=@temp_table_name
		EXEC('delete from '+@temp_table_name+' where  as_of_date is null and curve_id is null and
		term is null and curve_source_value_id is null')

		-- insert into #temp_tot_count tot count from temp table
		EXEC (' insert into #temp_tot_count select count(*) as totcount,'''+ @tablename+'''  from '+@temp_table_name)
--exec('select * from '+@temp_table_name)
		EXEC sp_validate_data_type @process_id,@field_compare_table,@source_table
--	end
--exec('select * from '+@temp_table_name)

---Data Import********************************************************************
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data error for  As of Date:''+ isnull(a.as_of_date,''NULL'')+'' CurveId :''+ isnull(a.curve_id,''NULL'')+'' 
			 Term: ''+isnull(a.Term,''NULL'')+'' Curve Source ValueId:''+isnull(a.curve_source_value_id,''NULL'')+''(Data Repetition Error, No of times:''+ cast(b.notimes as varchar)+'' )''
			,''Please check your data'' 
			from '+@temp_table_name + ' a inner join (select as_of_date,curve_id,term,curve_source_value_id,count(*) notimes from '+ @temp_table_name+'
			 group by as_of_date,curve_id,term,curve_source_value_id having count(*)>1) b 
			on a.as_of_date=b.as_of_date and a.curve_id=b.curve_id and a.term=b.term and a.curve_source_value_id=b.curve_source_value_id')
--		exec spa_print 'kk'		
--		exec('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
--			''Data error for Debt_rating:''+ isnull(a.Debt_rating,''NULL'')+'' Effective_date:''+ isnull(a.Effective_date,''NULL'')+'' Months:''+ isnull(a.Months,''NULL'')
--			+''.( Data format for effective_date  ''+isnull(a.effective_date,''NULL'')+'' 
--			or rate ''+isnull(a.rate,''NULL'')+'' is invalid)'',
--			''Please check your data'' 
--			from '+@temp_table_name + ' a where isdate(a.effective_date)=0 or
--			 isnumeric(a.rate)=0 or a.rate is null or effective_date is null')
		
		exec spa_print 'kk1'	
		--Check for Foreign key validation and insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) table if any invalid data found
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for As of Date:''+ isnull(a.as_of_date,''NULL'')+'' CurveId :''+ isnull(a.curve_id,''NULL'')+'' Term:''+isnull(a.Term,''NULL'')+'' 
			Curve Source ValueId:''+isnull(a.curve_source_value_id,''NULL'')+''.(Foreign Key CurveId ''+ISNULL(a.curve_id,''NULL'')+'' not found)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a 
			left join #import_status on a.temp_id=#import_status.temp_id
			left join source_price_curve_def spcd on a.curve_id =spcd.curve_id
			where #import_status.temp_id is null and spcd.source_curve_def_id is null')

			EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for As of Date:''+ isnull(a.as_of_date,''NULL'')+'' CurveId:''+ isnull(a.curve_id,''NULL'')+'' 
			Term:''+isnull(a.Term,''NULL'')+'' Curve Source ValueId:''+isnull(a.curve_source_value_id,''NULL'')+''. (Foreign Key Curve Source ValueId: ''+ISNULL(a.curve_source_value_id,''NULL'')+'' not found)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a 
			left join #import_status on a.temp_id=#import_status.temp_id
			left join source_price_curve_def spcd on a.curve_id =spcd.curve_id
			where #import_status.temp_id is null and spcd.source_curve_def_id is null')

		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			
			''Data error for As of Date:''+ isnull(a.as_of_date,''NULL'')+'' CurveId:''+ isnull(a.curve_id,''NULL'')+'' 
			Term:''+isnull(a.Term,''NULL'')+'' Curve Source ValueId:''+isnull(a.curve_source_value_id,''NULL'')+''. (Foreign Key Curve Source ValueId: ''+ISNULL(a.curve_source_value_id,''NULL'')+'' not found)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
			left join static_data_value b on 
			b.CODE=a.granularity and b.type_id=700 where #import_status.temp_id is null and b.value_id is null')
			
	
	exec spa_print 'kk2'	
		-- delete from temp table all the invalid data
		EXEC('delete '+@temp_table_name + ' from #import_status inner join '+@temp_table_name + ' a on
		#import_status.temp_id=a.temp_id')

		 ---Update  actual table from temp table
		SET @sql='update curve_volatility  set as_of_date=b.as_of_date,curve_id=spcd.source_curve_def_id,
			term=b.term,curve_source_value_id=c.value_id,value=b.value,granularity=sdv.value_id,
			UPDATE_TS=GETDATE(),UPDATE_USER=dbo.fnadbuser()
			from  '+@temp_table_name+' b INNER JOIN STATIC_DATA_VALUE C ON C.CODE=B.curve_source_value_id
			inner join source_price_curve_def spcd on b.curve_id=spcd.curve_id
			INNER JOIN STATIC_DATA_VALUE sdv ON sdv.CODE=B.granularity and sdv.type_id=700
			inner join curve_volatility a on a.curve_source_value_id=C.VALUE_ID and a.as_of_date=b.as_of_date and a.curve_id=spcd.source_curve_def_id
			and  a.term=b.term and a.curve_source_value_id=c.value_id
			left join #import_status on b.temp_id=#import_status.temp_id where #import_status.temp_id is null'
		exec spa_print @sql
		--insert into actual table from temp table
		SET @sql1='
		INSERT INTO [dbo].[curve_volatility]
				   (
					[as_of_date] ,
					[curve_id],
					[term],
					[curve_source_value_id],
					[value],
					[granularity],
					[create_user],
				    [create_ts],
				    [update_user],
				    [update_ts]
			)
			 select
					a.[as_of_date]
					,spcd.source_curve_def_id
					,a.[term]
					,c.value_id
					,a.[value]
					,sdv.value_id
					,dbo.fnadbuser()
					,getdate()
					,dbo.fnadbuser()
					,getdate()
					from '+ @temp_table_name +' a 
					inner join static_data_value c on a.[curve_source_value_id]=c.code 
					inner join static_data_value sdv on a.[granularity]=sdv.code and sdv.type_id=700
					inner join source_price_curve_def spcd on a.curve_id =spcd.curve_id
					left join [curve_volatility] e on e.[curve_source_value_id]=C.VALUE_ID and e.[term]=a.[term] and a.as_of_date=e.as_of_date 
					and e.curve_id=spcd.source_curve_def_id and e.[granularity]=sdv.VALUE_ID
					left join #import_status on a.temp_id=#import_status.temp_id where #import_status.temp_id is null and e.curve_id is null'


	EXEC(@sql)
		exec spa_print @sql1
	EXEC(@sql1)
END
/********************** End of curve volatility    ********************/

/*			
		Added by: Bikash Subba
		Added on: 18th May, 2009
		Object  : To import Expected Return
		
*/
IF CHARINDEX('4032',@table_id,1)<>0	--	expected_return 

BEGIN
	EXEC('delete '+@field_compare_table)
	SET @tablename=(SELECT code FROM static_data_value WHERE value_id=4032)
--	if @schedule_run='n'
--	begin
	
		EXEC('insert into '+@field_compare_table+ ' values (''expected_return'',''as_of_date'',''as_of_date'')')
		EXEC('insert into '+@field_compare_table+ ' values (''expected_return'',''term'',''term'')')
		EXEC('insert into '+@field_compare_table+ ' values (''expected_return'',''value'',''value'')')
		SET @source_table=@temp_table_name
		EXEC('delete from '+@temp_table_name+' where  as_of_date is null and curve_id is null and
		term is null and curve_source_value_id is null')

		-- insert into #temp_tot_count tot count from temp table
		EXEC (' insert into #temp_tot_count select count(*) as totcount,'''+ @tablename+'''  from '+@temp_table_name)
--exec('select * from '+@temp_table_name)
		EXEC sp_validate_data_type @process_id,@field_compare_table,@source_table
--	end
--exec('select * from '+@temp_table_name)

---Data Import********************************************************************
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data error for  As of Date:''+ isnull(a.as_of_date,''NULL'')+'' CurveId :''+ isnull(a.curve_id,''NULL'')+'' 
			 Term: ''+isnull(a.Term,''NULL'')+'' Curve Source ValueId:''+isnull(a.curve_source_value_id,''NULL'')+''(Data Repetition Error, No of times:''+ cast(b.notimes as varchar)+'' )''
			,''Please check your data'' 
			from '+@temp_table_name + ' a inner join (select as_of_date,curve_id,term,curve_source_value_id,count(*) notimes from '+ @temp_table_name+'
			 group by as_of_date,curve_id,term,curve_source_value_id having count(*)>1) b 
			on a.as_of_date=b.as_of_date and a.curve_id=b.curve_id and a.term=b.term and a.curve_source_value_id=b.curve_source_value_id')
--		exec spa_print 'kk'		
--		exec('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
--			''Data error for Debt_rating:''+ isnull(a.Debt_rating,''NULL'')+'' Effective_date:''+ isnull(a.Effective_date,''NULL'')+'' Months:''+ isnull(a.Months,''NULL'')
--			+''.( Data format for effective_date  ''+isnull(a.effective_date,''NULL'')+'' 
--			or rate ''+isnull(a.rate,''NULL'')+'' is invalid)'',
--			''Please check your data'' 
--			from '+@temp_table_name + ' a where isdate(a.effective_date)=0 or
--			 isnumeric(a.rate)=0 or a.rate is null or effective_date is null')
		
		exec spa_print 'kk1'	
		--Check for Foreign key validation and insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) table if any invalid data found
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for As of Date:''+ isnull(a.as_of_date,''NULL'')+'' CurveId :''+ isnull(a.curve_id,''NULL'')+'' Term:''+isnull(a.Term,''NULL'')+'' 
			Curve Source ValueId:''+isnull(a.curve_source_value_id,''NULL'')+''.(Foreign Key CurveId ''+ISNULL(a.curve_id,''NULL'')+'' not found)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a 
			left join #import_status on a.temp_id=#import_status.temp_id
			left join source_price_curve_def spcd on a.curve_id =spcd.curve_id
			where #import_status.temp_id is null and spcd.source_curve_def_id is null')

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for As of Date:''+ isnull(a.as_of_date,''NULL'')+'' CurveId:''+ isnull(a.curve_id,''NULL'')+'' 
			Term:''+isnull(a.Term,''NULL'')+'' Curve Source ValueId:''+isnull(a.curve_source_value_id,''NULL'')+''. (Foreign Key Curve Source ValueId: ''+ISNULL(a.curve_source_value_id,''NULL'')+'' not found)'',
			''Please check your data'' 
			from '+@temp_table_name + ' a 
			left join #import_status on a.temp_id=#import_status.temp_id
			left join source_price_curve_def spcd on a.curve_id =spcd.curve_id
			where #import_status.temp_id is null and spcd.source_curve_def_id is null')
	
				
	exec spa_print 'kk2'	
		-- delete from temp table all the invalid data
	EXEC('delete '+@temp_table_name + ' from #import_status inner join '+@temp_table_name + ' a on
		#import_status.temp_id=a.temp_id')

		 ---Update  actual table from temp table
		SET @sql='update expected_return  set as_of_date=b.as_of_date,curve_id=spcd.source_curve_def_id,
			term=b.term,curve_source_value_id=c.value_id,value=b.value,
			UPDATE_TS=GETDATE(),UPDATE_USER=dbo.fnadbuser()
			from  '+@temp_table_name+' b INNER JOIN STATIC_DATA_VALUE C ON C.CODE=B.curve_source_value_id
			inner join source_price_curve_def spcd on b.curve_id=spcd.curve_id
			inner join expected_return a on a.curve_source_value_id=C.VALUE_ID and a.as_of_date=b.as_of_date and a.curve_id=spcd.source_curve_def_id
			and  a.term=b.term and a.curve_source_value_id=c.value_id
			left join #import_status on b.temp_id=#import_status.temp_id where #import_status.temp_id is null'
		exec spa_print @sql
		--insert into actual table from temp table
		SET @sql1='
		INSERT INTO [dbo].[expected_return]
				   (
					[as_of_date] ,
					[curve_id],
					[term],
					[curve_source_value_id],
					[value],
					[create_user],
				    [create_ts],
				    [update_user],
				    [update_ts]
			)
			 select
					a.[as_of_date]
					,spcd.source_curve_def_id
					,a.[term]
					,c.value_id
					,a.[value]
					,dbo.fnadbuser()
					,getdate()
					,dbo.fnadbuser()
					,getdate()
					from '+ @temp_table_name +' a 
					inner join static_data_value c on a.[curve_source_value_id]=c.code 
					inner join source_price_curve_def spcd on a.curve_id =spcd.curve_id
					left join [expected_return] e on e.[curve_source_value_id]=C.VALUE_ID and e.[term]=a.[term] and a.as_of_date=e.as_of_date 
					and e.curve_id=spcd.source_curve_def_id
					left join #import_status on a.temp_id=#import_status.temp_id where #import_status.temp_id is null and e.curve_id is null'
/*

	set @sql1='insert into source_traders(source_system_id,trader_id,trader_name,trader_desc)
	 		select  a.source_system_id,a.trader_id,a.trader_name,a.trader_desc
			from '+@temp_table_name+' a
			inner join source_system_description d on a.source_system_id = d.source_system_id
			left join source_traders g on g.trader_id=a.trader_id
			and g.source_system_id=a.source_system_id left join #import_status on a.temp_id=#import_status.temp_id where #import_status.temp_id is null
			and   g.trader_id is null'
*/
	EXEC(@sql)
		exec spa_print @sql1
	EXEC(@sql1)
END
/********************** End of Expected Return   ********************/
IF CHARINDEX('4008',@table_id,1)<>0 --source_price_curve
BEGIN
 EXEC('delete '+@field_compare_table)
 SET @tablename=(SELECT code FROM static_data_value WHERE value_id=4008)
-- if @schedule_run='n'
-- begin

  EXEC('insert into #total_curve_price_proceed(Curve_id ,as_of_date,tot_record )
   select source_curve_def_id,as_of_date,count(*) curve_record from '+@temp_table_name + ' a group by source_curve_def_id,as_of_date')


		EXEC('INSERT INTO #vol_check
				select sum(case when isnull(source.curve_value,'''')='''' then 0 else cast(source.curve_value as numeric(18,2)) end)
							,0
							,0
				from ' + @temp_table_name +' source ')

  EXEC('insert into '+@field_compare_table+ ' values (''source_price_curve_def'',''curve_id'',''source_curve_def_id'')')
  EXEC('insert into '+@field_compare_table+ ' values (''source_price_curve'',''as_of_date'',''as_of_date'')')
  EXEC('insert into '+@field_compare_table+ ' values (''source_price_curve'',''Assessment_curve_type_value_id'',''Assessment_curve_type_value_id'')')
  EXEC('insert into '+@field_compare_table+ ' values (''source_price_curve'',''curve_source_value_id'',''curve_source_value_id'')')
  EXEC('insert into '+@field_compare_table+ ' values (''source_price_curve'',''maturity_date'',''maturity_date'')')
  EXEC('insert into '+@field_compare_table+ ' values (''source_price_curve'',''curve_value'',''curve_value'')')
--  exec('insert into '+@field_compare_table+ ' values (''source_price_curve'',''bid_value'',''bid_value'')')
--  exec('insert into '+@field_compare_table+ ' values (''source_price_curve'',''ask_value'',''ask_value'')')
--  exec('insert into '+@field_compare_table+ ' values (''source_price_curve'',''is_dst'',''is_dst'')')
--Pre validataing Data Type
  SET @source_table=@temp_table_name
  EXEC('delete from '+@temp_table_name+' where source_curve_def_id is null and as_of_date is null and Assessment_curve_type_value_id is null and
		curve_source_value_id is null and maturity_date is null and curve_value is null')

  EXEC (' insert into #temp_tot_count select count(*) as totcount,'''+ @tablename+'''  from '+@temp_table_name)
  EXEC sp_validate_data_type @process_id,@field_compare_table,@source_table,@tablename


 --end
	
DECLARE @import_status_type VARCHAR(256)
DECLARE @import_status_source VARCHAR(256)
DECLARE @import_status_module VARCHAR(256)

--IF @exec_mode = 2	--CMA import in Essent is working this way, which shud be fixed as it is cofusing to store Data Error in import source instead of import type
--BEGIN
--	IF COL_LENGTH(@temp_table_name, 'file_name') IS NOT NULL
--		SET @import_status_source = 'a.file_name'    	
--	ELSE
--		SET @import_status_source = '''Data Error'''

--	SET @import_status_type = ISNULL(@import_from, @tablename)
--END
--ELSE
BEGIN
	IF COL_LENGTH(@temp_table_name, 'file_name') IS NOT NULL
		SET @import_status_source = 'a.file_name'    	
	ELSE
		SET @import_status_source = '''' + @tablename + ''''
		
	SET @import_status_module = ISNULL(@import_from, 'Import Data')

	SET @import_status_type = 'Data Error'
	
END
--Data Import********************************************************************************************
 
 EXEC spa_print '1'
 
  exec spa_print 'insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep select a.temp_id,''', @process_id,''',''Error'',''Import Data'',', @import_status_source, ',''', @import_status_type, ''',
   ''Data error for source_curve_def_id :''+ isnull(a.source_curve_def_id,''NULL'')+'', as_of_date:''+isnull(a.as_of_date,''NULL'')+
   '', Assessment_curve_type_value_id :''+ isnull(a.Assessment_curve_type_value_id,''NULL'')+'', curve_source_value_id:''+isnull(a.curve_source_value_id,''NULL'')+
   '', maturity_date :''+isnull(a.maturity_date,''NULL'')+''. (It is possible that the data format may be incorrect)'',
   ''Please check your data'' 
   from ', @temp_table_name, ' a where --isnumeric(a.source_curve_def_id)=0 or 
   isnumeric(a.source_system_id)=0 or
   isnumeric(a.Assessment_curve_type_value_id)=0 or isnumeric(a.curve_source_value_id)=0 or
   isnumeric(a.source_system_id)=0 
   --or isnumeric(a.curve_value)=0 
   or isdate(a.as_of_date)=0 
or isdate(a.maturity_date)=0'
   
 EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'',' + @import_status_source + ','''+@import_status_type+''',
   ''Data error for source_curve_def_id :''+ isnull(a.source_curve_def_id,''NULL'')+'', as_of_date:''+isnull(a.as_of_date,''NULL'')+
   '', Assessment_curve_type_value_id :''+ isnull(a.Assessment_curve_type_value_id,''NULL'')+'', curve_source_value_id:''+isnull(a.curve_source_value_id,''NULL'')+
   '', maturity_date :''+isnull(a.maturity_date,''NULL'')+''. (It is possible that the data format may be incorrect)'',
   ''Please check your data'' 
   from '+@temp_table_name + ' a where --isnumeric(a.source_curve_def_id)=0 or 
   isnumeric(a.source_system_id)=0 or
   isnumeric(a.Assessment_curve_type_value_id)=0 or isnumeric(a.curve_source_value_id)=0 or
   isnumeric(a.source_system_id)=0 
   --or isnumeric(a.curve_value)=0 
   or isdate(a.as_of_date)=0 or isdate(a.maturity_date)=0')
--ashish is_dst column validation
 EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'',' + @import_status_source + ','''+@import_status_type+''',
   ''Data error for source_curve_def_id :''+ isnull(a.source_curve_def_id,''NULL'')+'', as_of_date:''+isnull(a.as_of_date,''NULL'')+
   '', Assessment_curve_type_value_id :''+ isnull(a.Assessment_curve_type_value_id,''NULL'')+'', curve_source_value_id:''+isnull(a.curve_source_value_id,''NULL'')+
   '', maturity_date :''+isnull(a.maturity_date,''NULL'')+'', is_dst:''+ISNULL(a.is_dst,''0'')+ ''. (DST value should be either 1 or 0)'',
   ''Please check your data'' 
   from '+@temp_table_name + ' a where
   a.is_dst NOT IN(1,0) ')
 
 EXEC spa_print '2'
 EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'',' + @import_status_source + ','''+@import_status_type+''',
   ''Data error for source_curve_def_id :''+ isnull(a.source_curve_def_id,''NULL'')+'', as_of_date:''+isnull(a.as_of_date,''NULL'')+
   '', Assessment_curve_type_value_id :''+ isnull(a.Assessment_curve_type_value_id,''NULL'')+'', curve_source_value_id:''+isnull(a.curve_source_value_id,''NULL'')+
   '', maturity_date :''+isnull(a.maturity_date,''NULL'')+'', is_dst:''+ISNULL(a.is_dst,''0'')+ ''. (Foreign Key Assessment_curve_type_value_id ''+ISNULL(a.Assessment_curve_type_value_id,''NULL'')+'' is not found)'',
   ''Please check your data'' 
   from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
   where #import_status.temp_id is null and a.Assessment_curve_type_value_id not in(75,76,77,78,83)')
  EXEC spa_print '3'

 EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'',' + @import_status_source + ','''+@import_status_type+''',
   ''Data error for source_curve_def_id :''+ isnull(a.source_curve_def_id,''NULL'')+'', as_of_date:''+isnull(a.as_of_date,''NULL'')+
   '', Assessment_curve_type_value_id :''+ isnull(a.Assessment_curve_type_value_id,''NULL'')+'', curve_source_value_id:''+isnull(a.curve_source_value_id,''NULL'')+
   '', maturity_date :''+isnull(a.maturity_date,''NULL'')+'', is_dst:''+ISNULL(a.is_dst,''0'')+ '' (Foreign Key curve_source_value_id ''+ISNULL(a.curve_source_value_id,''NULL'')+'' is not found)'',''Please check your data'' 
   from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id 
   left join static_data_value b on b.value_id=a.curve_source_value_id
   and b.type_id = 10007 where #import_status.temp_id is null and b.value_id is null')
 EXEC spa_print '4'

 EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'',' + @import_status_source + ','''+@import_status_type+''',
   ''Data error for source_curve_def_id :''+ isnull(a.source_curve_def_id,''NULL'')+'', as_of_date:''+isnull(a.as_of_date,''NULL'')+
   '', Assessment_curve_type_value_id :''+ isnull(a.Assessment_curve_type_value_id,''NULL'')+'', curve_source_value_id:''+isnull(a.curve_source_value_id,''NULL'')+
   '', maturity_date :''+isnull(a.maturity_date,''NULL'')+'', is_dst:''+ISNULL(a.is_dst,''0'')+ '' (Foreign Key source_price_curve_def ''+ISNULL(a.source_curve_def_id,''NULL'')+'' is not found)'',''Please check your data'' 
   from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id 
   left join source_price_curve_def b on b.curve_id=a.source_curve_def_id
   and b.source_system_id=a.source_system_id  
   where #import_status.temp_id is null and b.curve_id is null')

 -- validate for bid_value

 EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'',' + @import_status_source + ','''+@import_status_type+''',
   ''Data error for source_curve_def_id :''+ isnull(a.source_curve_def_id,''NULL'')+'', as_of_date:''+isnull(a.as_of_date,''NULL'')+
   '', Assessment_curve_type_value_id :''+ isnull(a.Assessment_curve_type_value_id,''NULL'')+'', curve_source_value_id:''+isnull(a.curve_source_value_id,''NULL'')+
   '', maturity_date :''+isnull(a.maturity_date,''NULL'')+'', is_dst:''+ISNULL(a.is_dst,''0'')
   +'', bid_value:'' + ISNULL(a.bid_value, ''NULL'') + ''(bid_value is '' + ISNULL(a.bid_value, ''NULL'') + ''.)'',''Please check your data'' 
   from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id 
   left join source_price_curve_def b on b.curve_id=a.source_curve_def_id
   and b.source_system_id=a.source_system_id  
   where #import_status.temp_id is null and a.bid_value is null and a.ask_value is not null')
   
 -- validate for ask_value
 EXEC spa_print 'validate for ask_value'
 EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'',' + @import_status_source + ','''+@import_status_type+''',
   ''Data error for source_curve_def_id :''+ isnull(a.source_curve_def_id,''NULL'')+'', as_of_date:''+isnull(a.as_of_date,''NULL'')+
   '', Assessment_curve_type_value_id :''+ isnull(a.Assessment_curve_type_value_id,''NULL'')+'', curve_source_value_id:''+isnull(a.curve_source_value_id,''NULL'')+
   '', maturity_date :''+isnull(a.maturity_date,''NULL'')+'', is_dst:''+ISNULL(a.is_dst,''0'')
   +'', ask_value:'' + ISNULL(a.ask_value, ''NULL'') + ''(ask_value is '' + ISNULL(a.ask_value, ''NULL'') + ''.)'',''Please check your data'' 
   from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id 
   left join source_price_curve_def b on b.curve_id=a.source_curve_def_id
   and b.source_system_id=a.source_system_id  
   where #import_status.temp_id is null and a.ask_value is null and a.bid_value is not null')  
 
 -- validate for curve_value
 EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'',' + @import_status_source + ','''+@import_status_type+''',
   ''Data error for source_curve_def_id :''+ isnull(a.source_curve_def_id,''NULL'')+'', as_of_date:''+isnull(a.as_of_date,''NULL'')+
   '', Assessment_curve_type_value_id :''+ isnull(a.Assessment_curve_type_value_id,''NULL'')+'', curve_source_value_id:''+isnull(a.curve_source_value_id,''NULL'')+
   '', maturity_date :''+isnull(a.maturity_date,''NULL'')+'', is_dst:''+ISNULL(a.is_dst,''0'')
   +'', curve_value:'' + ISNULL(a.curve_value, ''NULL'') + ''(curve_value is '' + ISNULL(a.curve_value, ''NULL'') + ''.)'',''Please check your data'' 
   from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id 
   left join source_price_curve_def b on b.curve_id=a.source_curve_def_id
   and b.source_system_id=a.source_system_id  
   where #import_status.temp_id is null and a.curve_value is null')
   
 EXEC spa_print '5'

 EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'',' + @import_status_source + ','''+@import_status_type+''',
   ''Data error for source_curve_def_id :''+ isnull(a.source_curve_def_id,''NULL'')+'', as_of_date:''+isnull(a.as_of_date,''NULL'')+
   '', Assessment_curve_type_value_id :''+ isnull(a.Assessment_curve_type_value_id,''NULL'')+'', curve_source_value_id:''+isnull(a.curve_source_value_id,''NULL'')+'', is_dst:''+ISNULL(a.is_dst,''0'')+
   '', maturity_date :''+isnull(a.maturity_date,''NULL'')+'', maturity_hour:''+isnull(a.maturity_hour,''NULL'')+'' (Data Repetition Error, No of times:''+ cast(b.notimes as varchar)+'')'',''Please check your data'' 
   from '+@temp_table_name + ' a inner join (select source_curve_def_id,as_of_date,Assessment_curve_type_value_id,curve_source_value_id,maturity_date+'' ''+ isNull(maturity_hour,''00:00'') +'':00'' AS maturity_date,is_dst, count(*) notimes from '+ @temp_table_name+'
    group by source_curve_def_id,as_of_date,Assessment_curve_type_value_id,curve_source_value_id,maturity_date+'' ''+ isNull(maturity_hour ,''00:00'') +'':00'',is_dst having count(*)>1) b 
   on a.source_curve_def_id=b.source_curve_def_id and a.as_of_date=b.as_of_date and a.Assessment_curve_type_value_id=b.Assessment_curve_type_value_id 
   and a.curve_source_value_id=b.curve_source_value_id and a.maturity_date+'' ''+ isNull(a.maturity_hour,''00:00'') +'':00''=b.maturity_date and a.is_dst=b.is_dst')

--ashish --checks if the date corrosponds to respective rows as of mv90_dst table
--EXEC('select maturity_hour from '+@temp_table_name)
 EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) 
 select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'',' + @import_status_source + ','''+@import_status_type+''',
   ''Data error for source_curve_def_id :''+ isnull(a.source_curve_def_id,''NULL'')+'', as_of_date:''+isnull(a.as_of_date,''NULL'')+
   '', Assessment_curve_type_value_id :''+ isnull(a.Assessment_curve_type_value_id,''NULL'')+'', curve_source_value_id:''+isnull(a.curve_source_value_id,''NULL'')+
   '', maturity_date :''+isnull(a.maturity_date,''NULL'')+'', is_dst:''+ISNULL(a.is_dst,''0'')+ ''. (DST value 1 is not valid for hour ''+ isnull(a.maturity_hour,''NULL'')+'')'',
   ''Please check your data'' 
   from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
   LEFT JOIN mv90_dst m ON convert(datetime,a.maturity_date,121)=m.date and CAST(LEFT(a.[maturity_hour], case when charindex('':'',a.[maturity_hour]) > 2 then 2 else 1 end ) AS INT)+1 = m.hour and m.insert_delete=''i''
   where m.[date] IS NULL AND a.is_dst=1 AND  #import_status.temp_id is null')
 
 
 EXEC spa_print '5.1 - Locked as of date check' 
 EXEC('INSERT INTO #import_status(temp_id, process_id, ErrorCode, Module, Source, type, [description], nextstep) 
 SELECT a.temp_id, ''' + @process_id + ''', ''Error'', ''Import Data'', ' + @import_status_source + ', ''' + @import_status_type + ''',
   ''As of date '' + ISNULL(a.as_of_date, ''NULL'') + '' is locked. Please unlock first to import. '',
   ''Please check your data''
   FROM ' + @temp_table_name + ' a 
   INNER JOIN lock_as_of_date lad ON lad.close_date = CONVERT(DATETIME, a.as_of_date, 101)
   LEFT JOIN #import_status ON a.temp_id = #import_status.temp_id
   WHERE #import_status.temp_id IS NULL'
 )
 
  EXEC spa_print '6'
 EXEC('delete '+@temp_table_name + ' from #import_status inner join '+@temp_table_name + ' a on
  #import_status.temp_id=a.temp_id')
  

 EXEC spa_print '7'

 SET @sql=' delete source_price_curve from  source_price_curve_def c inner join
   source_price_curve a on c.source_curve_def_id=a.source_curve_def_id 
   inner join '+@temp_table_name+' b on
   c.curve_id = b.source_curve_def_id AND 
   c.source_system_id = b.source_system_id and
   cast(a.as_of_date as datetime)=cast(b.as_of_date as datetime) and
   a.Assessment_curve_type_value_id=b.Assessment_curve_type_value_id and
   a.curve_source_value_id=b.curve_source_value_id and cast(a.maturity_date as datetime)=
   cast(dbo.FNAGetSQLStandardDate(cast(b.maturity_date as datetime))+'' ''+ isNull(b.maturity_hour,''00:00'') +'':00'' as datetime) 
   inner join static_data_value d on b.Assessment_curve_type_value_id=d.value_id inner join
   static_data_value e on b.curve_source_value_id=e.value_id
   left join #import_status on b.temp_id=#import_status.temp_id where #import_status.temp_id is null '
 exec spa_print @sql
 EXEC(@sql)
 
 --EXEC('INSERT INTO #vol_check
 --   select sum(case when isnull(source.curve_value,'''')='''' then 0 else cast(source.curve_value as numeric(18,2)) end)
 --      ,0
 --      ,0
 --   from ' + @temp_table_name +' source ')
 
 SET @sql1='insert into source_price_curve(source_curve_def_id,as_of_date,Assessment_curve_type_value_id,curve_source_value_id,maturity_date,curve_value, bid_value, ask_value, is_dst
 ,create_user, create_ts,update_user,update_ts)
    select distinct b.source_curve_def_id,a.as_of_date,a.Assessment_curve_type_value_id,
   a.curve_source_value_id,
   dbo.FNAGetSQLStandardDate(cast(a.maturity_date as datetime)) +'' ''+ isNull(a.maturity_hour,''00:00'') +'':00'',
   a.curve_value, a.bid_value, a.ask_value, ISNULL(a.is_dst, 0), dbo.FNAdbuser(), getdate(), dbo.FNAdbuser(), getdate()
   FROM  '+@temp_table_name+' a INNER JOIN
    source_price_curve_def b ON 
   a.source_curve_def_id = b.curve_id AND 
   a.source_system_id = b.source_system_id INNER
   JOIN
   static_data_value c ON 
   a.Assessment_curve_type_value_id = c.value_id INNER
   JOIN
   static_data_value d ON 
   a.curve_source_value_id = d.value_id 
	left join source_price_curve e on e.source_curve_def_id=b.source_curve_def_id and 
	b.curve_id=a.source_curve_def_id and b.source_system_id=a.source_system_id and 
	e.as_of_date=cast(a.as_of_date as datetime) and
	e.Assessment_curve_type_value_id=a.Assessment_curve_type_value_id and
	e.curve_source_value_id=a.curve_source_value_id and
		e.maturity_date=
	cast(a.maturity_date as datetime) left join #import_status on a.temp_id=#import_status.temp_id where #import_status.temp_id is null
	and e.source_curve_def_id is null'

 exec spa_print @sql1
  
 EXEC(@sql1)



END
IF CHARINDEX('4005',@table_id,1)<>0	--source_deal_detail
BEGIN

	SET @tablename = (SELECT code FROM static_data_value WHERE value_id = 4005)
	--index creation of optimization
	DECLARE @pos_index_name		VARCHAR(128)
	SET @pos_index_name = 'IX_AP_sourceDealDetailEssent'+ @process_id 
	
	EXEC('IF EXISTS (SELECT * FROM adiha_process.sys.indexes i WITH(NOLOCK)
			INNER JOIN adiha_process.sys.objects o WITH(NOLOCK) ON i.object_id = o.object_id
			WHERE o.type = ''U'' AND ''adiha_process.dbo.'' + o.name = ''' + @temp_table_name + '''
			AND i.name = N''' + @pos_index_name + ''')
			DROP INDEX ' + @pos_index_name + ' ON ' + @temp_table_name)
	EXEC('CREATE INDEX ' + @pos_index_name + ' ON ' + @temp_table_name + '(deal_id, term_start, term_end, leg)') 

	EXEC('delete '+@field_compare_table)

	EXEC('UPDATE ' + @temp_table_name + ' SET term_end = CONVERT(VARCHAR(10),CONVERT(datetime,term_end,103),120) ') -- This line may show error while running 2nd time with same process ID because the date has already been updated
	
--	if @schedule_run='n'
--	begin
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_header'',''deal_id'',''deal_id'')') 
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_detail'',''term_start'',''term_start'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_detail'',''term_end'',''term_end'')') 
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_detail'',''Leg'',''Leg'')') 
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_detail'',''contract_expiration_date'',''contract_expiration_date'')') 
 		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_detail'',''fixed_float_leg'',''fixed_float_leg'')') 
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_detail'',''buy_sell_flag'',''buy_sell_flag'')') 
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_detail'',''fixed_price'',''fixed_price'')') 
		--exec('insert into '+@field_compare_table+ ' values (''source_deal_detail'',''fixed_price_currency_id'',''fixed_price_currency_id'')') 	
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_detail'',''option_strike_price'',''option_strike_price'')') 
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_detail'',''deal_volume'',''deal_volume'')') 
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_detail'',''deal_volume_frequency'',''deal_volume_frequency'')') 
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_detail'',''block_description'',''block_description'')') 
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_detail'',''deal_detail_description'',''deal_detail_description'')') 
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_header'',''deal_date'',''deal_date'')') 
		--exec('insert into '+@field_compare_table+ ' values (''source_deal_header'',''deal_id'',''ext_deal_id'')') 
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_header'',''physical_financial_flag'',''physical_financial_flag'')') 
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_header'',''option_flag'',''option_flag'')')  
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_header'',''option_type'',''option_type'')') 
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_header'',''option_excercise_type'',''option_excercise_type'')')  
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_header'',''description1'',''description1'')') 
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_header'',''description2'',''description2'')') 
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_header'',''description3'',''description3'')') 
		IF @exec_mode = 6
			EXEC('INSERT INTO ' + @field_compare_table + ' VALUES (''source_deal_header'', ''description4'', ''description4'')') 
	--	exec('insert into '+@field_compare_table+ ' values (''source_deal_header'',''deal_category_value_id'',''deal_category_value_id'')') 
		--exec('insert into '+@field_compare_table+ ' values (''source_deal_header'',''trader_id'',''trader_id'')') 
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_header'',''header_buy_sell_flag'',''header_buy_sell_flag'')') 
	--	exec('insert into '+@field_compare_table+ ' values (''source_deal_header'',''legal_entity'',''legal_entity'')') 

		CREATE TABLE #tmp_erroneous_deals 
		(
			deal_id				VARCHAR(200) COLLATE DATABASE_DEFAULT NOT NULL,
			error_type_code		VARCHAR(100) COLLATE DATABASE_DEFAULT NOT NULL,
			error_description	VARCHAR(500) COLLATE DATABASE_DEFAULT
		)

		--Pre validataing Data Type
		SET @source_table=@temp_table_name
		EXEC('delete from ' + @temp_table_name + 
		'  OUTPUT DELETED.deal_id, ''INVALID_DATA_FORMAT'', ''Null values'' INTO #tmp_erroneous_deals
		where deal_id is null and term_start is null and term_end is null and
		Leg is null and contract_expiration_date is null and fixed_float_leg is null and buy_sell_flag is null 
		and curve_id is null and fixed_price is null and fixed_price_currency_id is null 
		and option_strike_price is null and deal_volume is null
		and deal_volume_frequency is null and deal_volume_uom_id is null and physical_financial_flag is null
		and source_deal_type_id is null and source_deal_sub_type_id is null and option_flag is null 
		and source_system_book_id1 is null
		and source_system_book_id2 is null and source_system_book_id3 is null and source_system_book_id4 is null
		and deal_category_value_id is null
	' )

		--delete those deals that can produce Data Repetition Error but make sure they are not embedded
		SET @sql = 'DELETE ' + @temp_table_name + ' 
					--SELECT * 
					FROM ' + @temp_table_name + ' t
					LEFT JOIN source_deal_header sdh ON t.deal_id = sdh.deal_id and t.source_system_id=sdh.source_system_id
					LEFT JOIN embedded_deal e ON e.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN (
						--get deal deals that will product Data Repetition Error
						SELECT MAX(temp_id) temp_id, deal_id, term_start, term_end, leg
						FROM ' + @temp_table_name + '
						GROUP BY deal_id, term_start, term_end, leg 
						HAVING COUNT(*) > 1 
					) d ON t.deal_id = d.deal_id 
						AND t.term_start = d.term_start 
						AND t.term_end = d.term_end AND t.leg = d.leg
						AND t.temp_id <> d.temp_id  --delete all duplicate rows except one [MAX(temp_id)]
					WHERE e.embedded_deal_id IS NULL'
		exec spa_print 'Delete deal details that can produce Data Repetition Error', @sql
		EXEC(@sql)

	  EXEC (' insert into #temp_tot_count select count(*) as totcount,'''+ @tablename+'''  from '+@temp_table_name)
	
	
    EXEC('INSERT INTO #total_deals_proceed (tot_deals) 
		select count(*) from ( SELECT count(*) tot FROM '+@temp_table_name +' group by deal_id ) t ')
	

		
	IF ISNULL(@exec_mode,0)<> 1
	EXEC sp_validate_data_type @process_id,@field_compare_table,@source_table
--	end

-- Data Import *****************************************************************************
	


	EXEC spa_print '0 Data Repetition Error'

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id) 
		  OUTPUT INSERTED.external_type_id, ''DATA_REPETITION'', INSERTED.type_error INTO #tmp_erroneous_deals
		select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data error for Deal ID :''+ isnull(a.deal_id,''NULL'')+'', term_start:''+isnull(a.term_start,''NULL'')+
			'', term_end :''+ isnull(a.term_end,''NULL'')+'', leg:''+isnull(a.leg,''NULL'')+'' 
			(Data Repetition Error, No of times:''+ cast(b.notimes as varchar)+'' )'',
			''Please check your data'' ,''Data Repetition Error'',a.deal_id
			from '+@temp_table_name + ' a inner join (select deal_id,term_start,term_end,leg,count(*) notimes from '+ @temp_table_name+'
			 group by deal_id,term_start,term_end,leg having count(*)>1) b 
			on a.deal_id=b.deal_id and a.term_start=b.term_start and a.term_end=b.term_end and a.leg=b.leg')
	
	EXEC spa_print '1 Data format may be incorrect'
	
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id) 
		OUTPUT INSERTED.external_type_id, ''INVALID_DATA_FORMAT'', INSERTED.type_error INTO #tmp_erroneous_deals
		select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_deal_header_id :''+ isnull(a.deal_id,''NULL'')+'', term_start:''+isnull(a.term_start,''NULL'')+
			'', term_end :''+ isnull(a.term_end,''NULL'')+'', Leg:''+isnull(a.Leg,''NULL'')+
			''. It is possible that the Data format may be incorrect'',	
				''Please check your data'',''Data Format Error'',a.deal_id 
			from '+@temp_table_name + ' a where isdate(a.term_start)=0 
			or isdate(a.term_end)=0  or isdate(a.deal_date)=0 
			or isnumeric(a.Leg)=0	or isdate(a.contract_expiration_date)=0 or len(a.fixed_float_leg)<>1
			or len(a.buy_sell_flag)<>1  or (isnumeric(a.fixed_price)=0 and a.fixed_price is not null)
			or (isnumeric(a.option_strike_price)=0 and a.option_strike_price is not null) 
		or isnumeric(a.deal_volume)=0 or len(a.deal_volume_frequency)<>1 or isnumeric(a.deal_category_value_id)=0 
		or len(a.option_flag)<>1
		')
		--	or isnumeric(a.deal_volume_uom_id)=0 or isnumeric(a.deal_volume_uom_id)=0 or isnumeric(a.deal_volume_uom_id)=0 or isnumeric(a.source_system_id)=0')

	EXEC spa_print '2 Source System'

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id) 
		OUTPUT INSERTED.external_type_id, ''INVALID_DATA_FORMAT'', INSERTED.type_error INTO #tmp_erroneous_deals
		select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for id :''+a.deal_id +''. (Foreign Key source_system_id ''+ISNULL(a.source_system_id,''NULL'')+'' is not found)'',
			''Please check your data'' ,''Source System  ''+ a.source_system_id + '' not defined'',a.deal_id
			from '+@temp_table_name + ' a left join source_system_description b on 
			b.source_system_id=a.source_system_id 
			where  b.source_system_id is null')

	EXEC spa_print '3 curve_id'

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id) 
		OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deals
		select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_deal_header_id :''+ isnull(a.deal_id,''NULL'')+'', term_start:''+isnull(a.term_start,''NULL'')+
			'', term_end :''+ isnull(a.term_end,''NULL'')+'', Leg:''+isnull(a.Leg,''NULL'')+
			''. Foreign Key curve_id ''+isnull(a.curve_id,''NULL'')+'' is not found'',
			''Please check your data'',''Curve ID  ''+ isnull(a.curve_id,''NULL'') + '' not found'',a.deal_id
			from '+@temp_table_name + ' a left join source_price_curve_def b on b.curve_id=a.curve_id and
			b.source_system_id=a.source_system_id where b.curve_id is null and a.curve_id is not null' )

	EXEC spa_print '4 fixed_price_currency_id'
	
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id) 
		OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deals
		select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_deal_header_id :''+ isnull(a.deal_id,''NULL'')+'', term_start:''+isnull(a.term_start,''NULL'')+
			'', term_end :''+ isnull(a.term_end,''NULL'')+'', Leg:''+isnull(a.Leg,''NULL'')+
			''. Foreign Key fixed_price_currency_id ''+ISNULL(a.fixed_price_currency_id,''NULL'')+'' is not found'',
			''Please check your data'' ,''Currency ID  ''+ isnull(a.fixed_price_currency_id,''NULL'') + '' not found'',a.deal_id
			from '+@temp_table_name + ' a left join source_currency b on b.currency_id=a.fixed_price_currency_id and
			b.source_system_id=a.source_system_id 
		where b.currency_id is null 
			and a.fixed_price_currency_id is not null')

	EXEC spa_print '5 uom_id'
	
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id) 
		OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deals
		select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_deal_header_id :''+ isnull(a.deal_id,''NULL'')+'', term_start:''+isnull(a.term_start,''NULL'')+
			'', term_end :''+ isnull(a.term_end,''NULL'')+'', Leg:''+isnull(a.Leg,''NULL'')+
			''. Foreign Key deal_volume_uom_id ''+ISNULL(a.deal_volume_uom_id,''NULL'')+'' is not found'',
			''Please check your data'' ,''UOM ID  ''+ isnull(a.deal_volume_uom_id,''NULL'') + '' not found'',a.deal_id
			from '+@temp_table_name + ' a left join source_uom b on b.uom_id=a.deal_volume_uom_id and
			b.source_system_id=a.source_system_id where b.uom_id is null')

	EXEC spa_print '6'				
	
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
		OUTPUT INSERTED.external_type_id, ''INVALID_DATA_FORMAT'', INSERTED.type_error INTO #tmp_erroneous_deals
		select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_deal_header_id :''+ isnull(a.deal_id,''NULL'')+'', term_start:''+isnull(a.term_start,''NULL'')+
			'', term_end :''+ isnull(a.term_end,''NULL'')+'', Leg:''+isnull(a.Leg,''NULL'')+
			''. Data format fixed_float_leg: ''+a.fixed_float_leg+'' is invalid'',
			''Please check your data''  ,''Fixed-Float  ''+ isnull(a.fixed_float_leg,''NULL'') + '' is invalid'',a.deal_id
			from '+@temp_table_name + ' a where a.fixed_float_leg not in(''f'',''t'')')

	EXEC spa_print '7'

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
	 OUTPUT INSERTED.external_type_id, ''INVALID_DATA_FORMAT'', INSERTED.type_error INTO #tmp_erroneous_deals
	 select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_deal_header_id :''+ isnull(a.deal_id,''NULL'')+'', term_start:''+isnull(a.term_start,''NULL'')+
			'', term_end :''+ isnull(a.term_end,''NULL'')+'', Leg:''+isnull(a.Leg,''NULL'')+
			''. Data format buy_sell_flag: ''+a.buy_sell_flag+'' is invalid'',
			''Please check your data'' ,''Buy-Sell ''+ isnull(a.buy_sell_flag,''NULL'') + '' is invalid'',a.deal_id
			from '+@temp_table_name + ' a where a.buy_sell_flag not in(''b'',''s'')')

	EXEC spa_print '8'
	
	IF ISNULL(@exec_mode,0) <> 1
	BEGIN
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
			OUTPUT INSERTED.external_type_id, ''INVALID_DATA_FORMAT'', INSERTED.type_error INTO #tmp_erroneous_deals
			select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
				''Data error for source_deal_header_id :''+ isnull(a.deal_id,''NULL'')+'', term_start:''+isnull(a.term_start,''NULL'')+
				'', term_end :''+ isnull(a.term_end,''NULL'')+'', Leg:''+isnull(a.Leg,''NULL'')+
				''. Data format deal_volume_frequency: ''+a.deal_volume_frequency+'' is invalid'',
				''Please check your data'', ''Volume Frequency ''+ isnull(a.deal_volume_frequency,''NULL'') + '' is invalid'',a.deal_id
				from '+@temp_table_name + ' a where a.deal_volume_frequency not in(''m'',''d'',''h'',''t'', ''a'')')

		IF @exec_mode = 12 --Used for TRM
		BEGIN
			
			EXEC spa_print '8-12'
			EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
					OUTPUT INSERTED.external_type_id, ''INVALID_DATA_FORMAT'', INSERTED.type_error INTO #tmp_erroneous_deals
					select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
						''Data error for source_deal_header_id :''+ isnull(a.deal_id,''NULL'')+'', term_start:''+isnull(a.term_start,''NULL'')+
						'', term_end :''+ isnull(a.term_end,''NULL'')+'', Leg:''+isnull(a.Leg,''NULL'')+
						''. Data format term_frequency: ''+a.deal_volume_frequency+'' is invalid'',
						''Please check your data'', ''Term Frequency ''+ isnull(a.deal_volume_frequency,''NULL'') + '' is invalid'',a.deal_id
						from '+@temp_table_name + ' a where a.term_frequency not in (''m'',''d'',''h'',''a'',''q'',''w'',''s'')')
		END
	END

	EXEC spa_print '8a Countryparty'	

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
			OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deals
			 select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
				''Data error for id :''+a.deal_id +''. (Foreign Key counterparty_id ''+isnull(a.counterparty_id,''NULL'')+'' is not found)'',
				''Please check your data'', ''Countryparty ''+ isnull(a.counterparty_id,''NULL'') + '' not found'',a.deal_id 
				from '+@temp_table_name + ' a 
				left join source_counterparty b on b.counterparty_id=a.counterparty_id and
				b.source_system_id=a.source_system_id where 
		 b.counterparty_id is null')

	EXEC spa_print '8a Legal_Entity'	

	IF @exec_mode = 1
	BEGIN
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
			OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deals
			 select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
				''Data error for id :''+a.deal_id +''. (Foreign Key Legal Entity ''+isnull(a.legal_entity,''NULL'')+'' is not found)'',
				''Please check your data'', ''Legal Entity ''+ isnull(a.legal_entity,''NULL'') + '' not found'',a.deal_id 
				from '+@temp_table_name + ' a 
				left join source_legal_entity le on le.legal_entity_id=a.legal_entity and
				le.source_system_id=a.source_system_id where 
		 le.legal_entity_id is null')
	END 

	EXEC spa_print '8b'	

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
	 OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deals
	 select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for id :''+a.deal_id +''. (Foreign Key source_deal_type_id ''+isnull(a.source_deal_type_id,''NULL'')+'' is not found)'',
			''Please check your data'',''Deal type ''+ isnull(a.source_deal_type_id,''NULL'') + '' not found'',a.deal_id
			from '+@temp_table_name + ' a 
			left join source_deal_type b on b.deal_type_id=a.source_deal_type_id and
			b.source_system_id=a.source_system_id where  b.deal_type_id is null')

	--SELECT * FROM #tmp_erroneous_deals
	EXEC spa_print '8c'	
	IF ISNULL(@exec_mode,0) <> 1
	BEGIN
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
		OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deals
		 select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for id :''+a.deal_id +''. (Foreign Key source_deal_sub_type_id ''+ISNULL(a.source_deal_sub_type_id,''NUUL'')+'' is not found)'',
			''Please check your data'',''Deal Sub type ''+ isnull(a.source_deal_sub_type_id,''NULL'') + '' not found'',a.deal_id
			from '+@temp_table_name + ' a 
			left join source_deal_type b on b.deal_type_id=a.source_deal_sub_type_id and
			b.source_system_id=a.source_system_id where b.deal_type_id is null and a.source_deal_sub_type_id is not null')
	END

	EXEC spa_print '8d'

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
		 OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deals
		 select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for id :''+a.deal_id +''. (Foreign Key source_system_book_id1 ''+ISNULL(a.source_system_book_id1,''NULL'')+'' is not found)'',
			''Please check your data'',''Book1 ''+ isnull(a.source_system_book_id1,''NULL'') + '' not found'',a.deal_id 
			from '+@temp_table_name + ' a 
			left join source_book b on b.source_system_book_id=a.source_system_book_id1 and
			b.source_system_id=a.source_system_id and b.source_system_book_type_value_id=50 where b.source_system_book_id is null')

	EXEC spa_print '8e'	

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
		OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deals
		select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for id :''+a.deal_id +''. (Foreign Key source_system_book_id2 ''+ISNULL(a.source_system_book_id2,''NULL'')+'' is not found)'',
			''Please check your data'' ,''Book2 ''+ isnull(a.source_system_book_id2,''NULL'') + '' not found'',a.deal_id
			from '+@temp_table_name + ' a 
			left join source_book b on b.source_system_book_id=a.source_system_book_id2 and
			b.source_system_id=a.source_system_id and b.source_system_book_type_value_id=51 where b.source_system_book_id is null and a.source_system_book_id2 is not null')
	
	EXEC spa_print '8f'	

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
		 OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deals
		 select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for id :''+a.deal_id +''. (Foreign Key source_system_book_id3 ''+ISNULL(a.source_system_book_id3,''NULL'')+'' is not found)'',
			''Please check your data'' ,''Book3 ''+ isnull(a.source_system_book_id3,''NULL'') + '' not found'',a.deal_id
			from '+@temp_table_name + ' a left join source_book b on b.source_system_book_id=a.source_system_book_id3 and
			b.source_system_id=a.source_system_id and b.source_system_book_type_value_id=52 where b.source_system_book_id is null and a.source_system_book_id3 is not null')

	EXEC spa_print '8g'	

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
		OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deals 
		select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for id :''+a.deal_id +''. (Foreign Key source_system_book_id4 ''+ISNULL(a.source_system_book_id4,''NULL'')+'' is not found)'',
			''Please check your data'' ,''Book4 ''+ isnull(a.source_system_book_id4,''NULL'') + '' not found'',a.deal_id
			from '+@temp_table_name + ' a left join source_book b on b.source_system_book_id=a.source_system_book_id4 and
			b.source_system_id=a.source_system_id and b.source_system_book_type_value_id=53 where b.source_system_book_id is null and a.source_system_book_id4 is not null')

	EXEC spa_print '8h'	
	IF ISNULL(@exec_mode,0) <> 1
	BEGIN
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
				OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deals 
				select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
				''Data error for id :''+a.deal_id +''. (Foreign Key trader_id ''+ISNULL(a.trader_id,''NULL'')+'' is not found)'',
				''Please check your data'' ,''Trader ''+ isnull(a.trader_id,''NULL'') + '' not found'',a.deal_id
				from '+@temp_table_name + ' a 
				left join source_traders b on b.trader_id=a.trader_id and
				b.source_system_id=a.source_system_id where b.trader_id is null
				--and a.trader_id is not null
			')
	END
	
	IF ISNULL(@exec_mode,0) <> 1
	BEGIN
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
			OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deals 
			select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
				''Data error for id :''+a.deal_id +''. (Invalid Data for deal_category_value_id: ''+a.deal_category_value_id+'')'',
				''Please check your data'' ,''Deal Category ''+ isnull(a.deal_category_value_id,''NULL'') + '' not found'',a.deal_id
				from '+@temp_table_name + ' a 
				left join static_data_value b on b.value_id=a.deal_category_value_id
				  and b.type_id=475 where  b.value_id is null
			and a.deal_category_value_id is not null
		')
	END

	IF ISNULL(@exec_mode,0) <> 1
	BEGIN
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
			 OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deals 
			 select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
					''Data error for id :''+a.deal_id +''. (Foreign Key Contract ID ''+ISNULL(a.contract_id,''NULL'')+'' is not found)'',
					''Please check your data'',''Contract id ''+ isnull(a.contract_id,''NULL'') + '' not found'',a.deal_id
					from '+@temp_table_name + ' a 
					left join contract_group b on b.source_contract_id=a.contract_id and
					b.source_system_id=a.source_system_id 
				where  b.contract_id is null and a.contract_id is not null')
	END

EXEC spa_print 'kkkkkkkkkkk'
	IF @exec_mode = 12 
	BEGIN
		EXEC spa_print '@exec_mode = 12'
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
			 OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deals 
			 select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
					''Data error for id :''+a.deal_id +''. (Foreign Key Template ''+ISNULL(a.[template],''NULL'')+'' is not found)'',
					''Please check your data'',''Template ''+ isnull(a.[template],''NULL'') + '' not found'',a.deal_id
					from '+@temp_table_name + ' a 
					left join source_deal_header_template b on b.template_name=a.[template]
				where  b.template_name is null and a.[template] is not null')


		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
			 OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deals 
			 select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
					''Data error for id :''+a.deal_id +''. (Foreign Key Broker Currency ID ''+ISNULL(a.[broker_currency_id],''NULL'')+'' is not found)'',
					''Please check your data'',''Broker Currency ID ''+ isnull(a.[broker_currency_id],''NULL'') + '' not found'',a.deal_id
					from '+@temp_table_name + ' a 
					left join source_currency b on b.currency_id=a.[broker_currency_id] and
					b.source_system_id=a.source_system_id 
				where  b.currency_id is null and a.[broker_currency_id] is not null')

		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
			OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deals 
			select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
				''Data error for id :''+a.deal_id +''. (Invalid Data for block_type: ''+a.[block_type]+'')'',
				''Please check your data'' ,''Block Type ''+ isnull(a.[block_type],''NULL'') + '' not found'',a.deal_id
				from '+@temp_table_name + ' a 
				left join static_data_value b on b.code=a.[block_type] where  b.value_id is null
					and a.[block_type] is not null
		')
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
			OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deals 
			select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
				''Data error for id :''+a.deal_id +''. (Invalid Data for block_define_id: ''+a.[block_define_id]+'')'',
				''Please check your data'' ,''Block Defination ''+ isnull(a.[block_define_id],''NULL'') + '' not found'',a.deal_id
				from '+@temp_table_name + ' a 
				left join static_data_value b on b.code=a.[block_define_id]
				   where  b.value_id is null
			and a.[block_define_id] is not null
		')
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
			OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deals 
			select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
				''Data error for id :''+a.deal_id +''. (Invalid Data for granularity_id: ''+a.[granularity_id]+'')'',
				''Please check your data'' ,''Granularity ''+ isnull(a.[granularity_id],''NULL'') + '' not found'',a.deal_id
				from '+@temp_table_name + ' a 
				left join static_data_value b on b.code=a.[granularity_id]
				  where  b.value_id is null
			and a.[granularity_id] is not null
		')
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
			OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deals 
			select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
				''Data error for id :''+a.deal_id +''. (Invalid Data for Pricing: ''+a.[Pricing]+'')'',
				''Please check your data'' ,''Pricing ''+ isnull(a.[Pricing],''NULL'') + '' not found'',a.deal_id
				from '+@temp_table_name + ' a 
				left join static_data_value b on b.code=a.[Pricing]
				  where  b.value_id is null
			and a.[Pricing] is not null
		')

	END

	IF ISNULL(@exec_mode,0)<> 6 
	BEGIN
exec spa_print 'INSERT INTO #import_status (temp_id, process_id, ErrorCode, Module, Source, TYPE, [description], nextstep, type_error, external_type_id
		  OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deals
			  SELECT a.temp_id,
				 ''', @process_id, ''',
					 ''ERROR'',
					 ''Import DATA'',
				 ''', @tablename, ''',
					 ''DATA ERROR'',
					 ''DATA ERROR FOR id :'' + a.deal_id + ''. (Invalid DATA FOR Pricing: '' + a.[Pricing] + '')
					 '',
					 ''Please insert source book map first.'',
					 ''Source Book Mapping for combination Book1:'' + ISNULL(a.source_system_book_id1, ''NULL'') + '', Book2: '' + ISNULL(a.source_system_book_id2, ''NULL'') + '', Book3: '' + ISNULL(a.source_system_book_id3, ''NULL'') + '', Book4: '' + ISNULL(a.source_system_book_id4, ''NULL'') + '' is not found.'',
					 a.deal_id
		  FROM   ', @temp_table_name, ' a
			  LEFT JOIN source_book sb1 ON  sb1.source_book_name = a.source_system_book_id1 AND sb1.source_system_id = a.source_system_id
			  LEFT JOIN source_book sb2 ON  sb2.source_book_name = a.source_system_book_id2 AND sb2.source_system_id = a.source_system_id 
			  LEFT JOIN source_book sb3 ON  sb3.source_book_name = a.source_system_book_id3 AND sb3.source_system_id = a.source_system_id 
			  LEFT JOIN source_book sb4 ON  sb4.source_book_name = a.source_system_book_id4 AND sb4.source_system_id = a.source_system_id 
			  LEFT JOIN source_system_book_map ssbm 
					ON ssbm.source_system_book_id1 = ISNULL(sb1.source_book_id, -4) 
					AND ssbm.source_system_book_id2 = ISNULL(sb2.source_book_id, -4) 
					AND ssbm.source_system_book_id3 = ISNULL(sb3.source_book_id, -4)
					AND ssbm.source_system_book_id4 = ISNULL(sb4.source_book_id, -4)
			  WHERE  ssbm.book_deal_type_map_id IS NULL
			'
		EXEC('INSERT INTO #import_status (temp_id, process_id, ErrorCode, Module, Source, TYPE, [description], nextstep, type_error, external_type_id)
			 OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deals
			  SELECT a.temp_id,
					 '''+ @process_id+''',
					 ''ERROR'',
					 ''Import DATA'',
					 '''+@tablename+''',
					 ''DATA ERROR'',
					 ''Source Book Mapping for combination Book1:'' + ISNULL(a.source_system_book_id1, ''NULL'') + '', Book2: '' + ISNULL(a.source_system_book_id2, ''NULL'') + '', Book3: '' + ISNULL(a.source_system_book_id3, ''NULL'') + '', Book4: '' + ISNULL(a.source_system_book_id4, ''NULL'') + '' is not found.'',
					 ''Please insert source book map first.'',
					 ''DATA ERROR FOR id :'' + a.deal_id + ''. '',
					 a.deal_id
			  FROM   '+@temp_table_name + ' a
			  LEFT JOIN source_book sb1 ON  sb1.source_book_name = a.source_system_book_id1 AND sb1.source_system_id = a.source_system_id
			  LEFT JOIN source_book sb2 ON  sb2.source_book_name = a.source_system_book_id2 AND sb2.source_system_id = a.source_system_id 
			  LEFT JOIN source_book sb3 ON  sb3.source_book_name = a.source_system_book_id3 AND sb3.source_system_id = a.source_system_id 
			  LEFT JOIN source_book sb4 ON  sb4.source_book_name = a.source_system_book_id4 AND sb4.source_system_id = a.source_system_id 
			  LEFT JOIN source_system_book_map ssbm 
					ON ssbm.source_system_book_id1 = sb1.source_book_id
					AND ssbm.source_system_book_id2 = ISNULL(sb2.source_book_id, -2) 
					AND ssbm.source_system_book_id3 = ISNULL(sb3.source_book_id, -3)
					AND ssbm.source_system_book_id4 = ISNULL(sb4.source_book_id, -4)
			  WHERE  ssbm.book_deal_type_map_id IS NULL
		') 
	END

--	if isnull(@exec_mode,0)<> 12 
--	begin
		--save all erroneous deals
		exec spa_print 'Saving erroneous deals (4005) to table for process_id:', @process_id, ' STARTED.'
		DECLARE @default_error_type_id	INT

		SET @start_ts = GETDATE()
		SET @source = 'DEAL'
		
		SELECT @default_error_type_id = error_type_id FROM source_deal_error_types WHERE error_type_code = 'MISC'
		INSERT INTO source_deal_error_log(as_of_date, deal_id, source, error_type_id, error_description)
		SELECT ISNULL(@import_as_of_date,GETDATE()), deal_id, @source, COALESCE(e.error_type_id, @default_error_type_id), MAX(error_description)
		FROM #tmp_erroneous_deals d
		LEFT JOIN source_deal_error_types e ON d.error_type_code = e.error_type_code
		GROUP BY deal_id, e.error_type_id

		--SELECT * FROM source_deal_error_log
		exec spa_print 'Saving erroneous deals (4005) to table for process_id:', @process_id, ' FINISHED. Process took ' --+ dbo.FNACalculateTimestamp(@start_ts)
--	end
	CREATE TABLE #temp_source_data(source_system_id VARCHAR(20) COLLATE DATABASE_DEFAULT)


	EXEC('insert #temp_source_data(source_system_id) 
	select max(source_system_id) from '+@temp_table_name)

	SELECT @source_system_desc_id=source_system_id FROM #temp_source_data
	EXEC spa_print '######## source_system_desc_id ####:', @source_system_desc_id

	/*************************************SAVE DEAL DETAILS FOR SOME ERRORS FOR DEBUGGING STARTED******************************/
	IF EXISTS(SELECT temp_id FROM #import_status WHERE type_error IN ('Data Repetition Error', 'Data Format Error'))
	BEGIN
		DECLARE @deal_debug_table_name			VARCHAR(200)
		DECLARE @deal_debug_table_name_suffix	VARCHAR(100)
		SET @deal_debug_table_name_suffix = 'source_deal_detail_debug'
		SET @deal_debug_table_name = dbo.FNAProcessTableName(@deal_debug_table_name_suffix, 'farrms', @process_id)
	
		exec spa_print 'Saving Deals having Data Repetition Error'
		--EXEC('SELECT * FROM ' + @temp_table_name)

		EXEC('SELECT DISTINCT t.*
				INTO ' + @deal_debug_table_name + '
				FROM ' + @temp_table_name + ' t 
				INNER JOIN #import_status s ON t.deal_id = s.external_type_id
				WHERE type_error IN (''Data Repetition Error'', ''Data Format Error'')
		')
	END
	/*************************************SAVE DEAL DETAILS FOR SOME ERRORS FOR DEBUGGING FINISHED******************************/
	
	EXEC('delete '+@temp_table_name + ' from #import_status inner join '+@temp_table_name + ' a on
		#import_status.temp_id=a.temp_id')	
	EXEC('DELETE ' + @temp_table_name + ' FROM ' + @temp_table_name + ' tmp 
			INNER JOIN #import_status st ON tmp.deal_id = st.external_type_id')
	--exec('delete '+@temp_table_name + ' where deal_id in (select external_type_id from #import_status)')
	DROP TABLE #temp_source_data

IF @exec_mode = 1 --Used for Essent ONLY
BEGIN
	IF @error_log_table_name='formate2' 
	BEGIN
		/*
			load erroneous deals in ssis_mtm_formate2_error_log only when loading from RDB
			because when loading from stating table, we already have alll erroroneous deals
			in ssis_mtm_formate2_error_log, so no need to insert them again
		*/
		IF @schedule_run <> 'n' 
		BEGIN

			EXEC spa_print 'Delete the Existing Error '--+CONVERT(VARCHAR,GETDATE(),109)	
	--		if @schedule_run='y'
	--			delete [ssis_mtm_formate2_error_log] where deal_num in (select external_type_id from #import_status)

			EXEC spa_print 'Insert If Error Found ' --+CONVERT(VARCHAR,GETDATE(),109)
		
			CREATE INDEX IX_import_status_external_deal_id ON #import_status(external_type_id)

			--we need to insert only those deals which are present in #import_status but not in ssis_mtm_formate2_error_log
			--insert only those deals which have missing static data as they are the only deals which can be corrected 
			--from staging TABLE

			SET @start_ts = GETDATE()
			CREATE TABLE #tmp_deleted_deals ( deal_id	VARCHAR(250) COLLATE DATABASE_DEFAULT)
			
			--pick out missing static data deals
			INSERT INTO #tmp_deleted_deals (deal_id)
			SELECT DISTINCT external_type_id --distinct is mandatory here, to avoid insertion of muliple deals later
			FROM #import_status s
			INNER JOIN source_deal_error_log e ON e.deal_id = s.external_type_id
			INNER JOIN source_deal_error_types t ON e.error_type_id = t.error_type_id
			WHERE e.as_of_date = @import_as_of_date
				AND e.source IN ('DEAL') AND t.error_type_code = 'MISSING_STATIC_DATA'
			exec spa_print 'Inserted 4005 error deals in #tmp_deleted_deals. Process took ' --+ dbo.FNACalculateTimestamp(@start_ts)

			SET @start_ts = GETDATE()
			DELETE ssis_mtm_formate2_error_log 
			FROM ssis_mtm_formate2_error_log err
			INNER JOIN #tmp_deleted_deals st ON err.deal_num = st.deal_id	
			exec spa_print 'Deleted 4005 errors from ssis_mtm_formate2_error_log. Process took ' --+ dbo.FNACalculateTimestamp(@start_ts)

			SET @start_ts = GETDATE()
			INSERT INTO [ssis_mtm_formate2_error_log]
			   ([tran_num], [deal_num], [reference], [ins_type], [input_date]
			   , [toolset], [portfolio], [internal_desk], [counterparty]
			   , [buy_sell], [trader], [trade_date], [deal_side]
			   , [price_region], [profile_leg], [unit_of_measure], [commodity]
			   , [side_currency], [settlement_type], [ZONE], [location]
			   , [region], [product], [settlement_currency]
			   , [mtm_undisc], [mtm_undisc_eur], [mtm_disc], [mtm_disc_eur], [value_type]
			   , [period_end_date], [location1]
			   , [zone1], [time_bucket], [location_pair]
			   , [deal_start_date], [deal_end_date], [settlement_date], [ias39_scope]
			   , [ias39_book], [hedging_strategy], [hedging_side], [contract_value]
			   , [period_start_date], [commodity_balance], [external_commodity_balance]
			   , [ins_sub_type], [fx_flt], [country], [pipeline]
			   , [legal_entity], [TaggingYear], [source_system_id]
			   , [process_id], [as_of_date], [create_ts])
			SELECT mtm.[tran_num], mtm.[deal_num], mtm.[reference], mtm.[ins_type], mtm.[input_date]
			   , mtm.[toolset], mtm.[portfolio], mtm.[internal_desk], mtm.[counterparty]
			   , mtm.[buy_sell], mtm.[trader], mtm.[trade_date], mtm.[deal_side]
			   , mtm.[price_region], mtm.[profile_leg], mtm.[unit_of_measure], mtm.[commodity]
			   , mtm.[side_currency], mtm.[settlement_type], mtm.[zone], mtm.[location]
			   , mtm.[region], mtm.[product], mtm.[settlement_currency]
			   , mtm.[mtm_undisc], mtm.[mtm_undisc_eur], mtm.[mtm_disc], mtm.[mtm_disc_eur], mtm.[value_type]
			   , mtm.[period_end_date], mtm.[location1]
			   , mtm.[zone1], mtm.[time_bucket], mtm.[location_pair]
			   , mtm.[deal_start_date], mtm.[deal_end_date], mtm.[settlement_date], mtm.[ias39_scope]
			   , mtm.[ias39_book], mtm.[hedging_strategy], mtm.[hedging_side], mtm.[contract_value]
			   , mtm.[period_start_date], mtm.[commodity_balance], mtm.[external_commodity_balance]
			   , mtm.[ins_sub_type], mtm.[fx_flt], mtm.[country], mtm.[pipeline]
			   , mtm.[legal_entity], mtm.[TaggingYear], @source_system_desc_id, @process_id
			   , @import_as_of_date, GETDATE()
			FROM ssis_mtm_formate2 mtm
			INNER JOIN #tmp_deleted_deals d ON mtm.deal_num = d.deal_id
			
			
--			DELETE ssis_mtm_formate2_error_log 
--			FROM ssis_mtm_formate2_error_log err
--			INNER JOIN (SELECT DISTINCT external_type_id FROM #import_status) st ON err.deal_num = st.external_type_id	
--			exec spa_print 'Deleted 4005 errors from ssis_mtm_formate2_error_log. Process took ' + dbo.FNACalculateTimestamp(@start_ts)
--	
--			SET @start_ts = GETDATE()
--			INSERT INTO [ssis_mtm_formate2_error_log]
--			   ([tran_num], [deal_num], [reference], [ins_type], [input_date]
--			   , [toolset], [portfolio], [internal_desk], [counterparty]
--			   , [buy_sell], [trader], [trade_date], [deal_side]
--			   , [price_region], [profile_leg], [unit_of_measure], [commodity]
--			   , [side_currency], [settlement_type], [zone], [location]
--			   , [region], [product], [settlement_currency]
--			   , [mtm_undisc], [mtm_undisc_eur], [mtm_disc], [mtm_disc_eur], [value_type]
--			   , [period_end_date], [location1]
--			   , [zone1], [time_bucket], [location_pair]
--			   , [deal_start_date], [deal_end_date], [settlement_date], [ias39_scope]
--			   , [ias39_book], [hedging_strategy], [hedging_side], [contract_value]
--			   , [period_start_date], [commodity_balance], [external_commodity_balance]
--			   , [ins_sub_type], [fx_flt], [country], [pipeline]
--			   , [legal_entity], [TaggingYear], [source_system_id]
--			   , [process_id], [as_of_date], [create_ts])
--			SELECT mtm.[tran_num], mtm.[deal_num], mtm.[reference], mtm.[ins_type], mtm.[input_date]
--			   , mtm.[toolset], mtm.[portfolio], mtm.[internal_desk], mtm.[counterparty]
--			   , mtm.[buy_sell], mtm.[trader], mtm.[trade_date], mtm.[deal_side]
--			   , mtm.[price_region], mtm.[profile_leg], mtm.[unit_of_measure], mtm.[commodity]
--			   , mtm.[side_currency], mtm.[settlement_type], mtm.[zone], mtm.[location]
--			   , mtm.[region], mtm.[product], mtm.[settlement_currency]
--			   , mtm.[mtm_undisc], mtm.[mtm_undisc_eur], mtm.[mtm_disc], mtm.[mtm_disc_eur], mtm.[value_type]
--			   , mtm.[period_end_date], mtm.[location1]
--			   , mtm.[zone1], mtm.[time_bucket], mtm.[location_pair]
--			   , mtm.[deal_start_date], mtm.[deal_end_date], mtm.[settlement_date], mtm.[ias39_scope]
--			   , mtm.[ias39_book], mtm.[hedging_strategy], mtm.[hedging_side], mtm.[contract_value]
--			   , mtm.[period_start_date], mtm.[commodity_balance], mtm.[external_commodity_balance]
--			   , mtm.[ins_sub_type], mtm.[fx_flt], mtm.[country], mtm.[pipeline]
--			   , mtm.[legal_entity], mtm.[TaggingYear], @source_system_desc_id, @process_id
--			   , @import_as_of_date, GETDATE()
--			FROM ssis_mtm_formate2 mtm
--			-- DISTINCT is necessary here to avoid insertion of duplicate rows as #import_status may CONTAIN
--			--same deal_num multiple times
--			INNER JOIN (SELECT DISTINCT external_type_id FROM #import_status) st ON mtm.deal_num = st.external_type_id

			exec spa_print 'Inserted 4005 errors to ssis_mtm_formate2_error_log from ssis_mtm_formate2. Process took ' --+ dbo.FNACalculateTimestamp(@start_ts)
		
--	Previous logic before optimization			
--			INSERT INTO [ssis_mtm_formate2_error_log]
--			   ([tran_num], [deal_num], [reference], [ins_type], [input_date]
--			   , [toolset], [portfolio], [internal_desk], [counterparty]
--			   , [buy_sell], [trader], [trade_date], [deal_side]
--			   , [price_region], [profile_leg], [unit_of_measure], [commodity]
--			   , [side_currency], [settlement_type], [zone], [location]
--			   , [region], [product], [settlement_currency]
--			   , [mtm_undisc], [mtm_undisc_eur], [mtm_disc], [mtm_disc_eur], [value_type]
--			   , [period_end_date], [location1]
--			   , [zone1], [time_bucket], [location_pair]
--			   , [deal_start_date], [deal_end_date], [settlement_date], [ias39_scope]
--			   , [ias39_book], [hedging_strategy], [hedging_side], [contract_value]
--			   , [period_start_date], [commodity_balance], [external_commodity_balance]
--			   , [ins_sub_type], [fx_flt], [country], [pipeline]
--			   , [legal_entity], [TaggingYear], [source_system_id]
--			   , [process_id], [as_of_date], [create_ts])
--			SELECT mtm.[tran_num], mtm.[deal_num], mtm.[reference], mtm.[ins_type], mtm.[input_date]
--			   , mtm.[toolset], mtm.[portfolio], mtm.[internal_desk], mtm.[counterparty]
--			   , mtm.[buy_sell], mtm.[trader], mtm.[trade_date], mtm.[deal_side]
--			   , mtm.[price_region], mtm.[profile_leg], mtm.[unit_of_measure], mtm.[commodity]
--			   , mtm.[side_currency], mtm.[settlement_type], mtm.[zone], mtm.[location]
--			   , mtm.[region], mtm.[product], mtm.[settlement_currency]
--			   , mtm.[mtm_undisc], mtm.[mtm_undisc_eur], mtm.[mtm_disc], mtm.[mtm_disc_eur], mtm.[value_type]
--			   , mtm.[period_end_date], mtm.[location1]
--			   , mtm.[zone1], mtm.[time_bucket], mtm.[location_pair]
--			   , mtm.[deal_start_date], mtm.[deal_end_date], mtm.[settlement_date], mtm.[ias39_scope]
--			   , mtm.[ias39_book], mtm.[hedging_strategy], mtm.[hedging_side], mtm.[contract_value]
--			   , mtm.[period_start_date], mtm.[commodity_balance], mtm.[external_commodity_balance]
--			   , mtm.[ins_sub_type], mtm.[fx_flt], mtm.[country], mtm.[pipeline]
--			   , mtm.[legal_entity], mtm.[TaggingYear], @source_system_desc_id, @process_id
--			   , @import_as_of_date, GETDATE()
--			FROM ssis_mtm_formate2 mtm
--			INNER JOIN #import_status st ON mtm.deal_num = st.external_type_id
--			LEFT JOIN ssis_mtm_formate2_error_log err ON mtm.deal_num = err.deal_num
--			WHERE err.deal_num IS NULL
--			--from ssis_mtm_formate2 where deal_num in (select external_type_id from #import_status)
--			--and deal_num not in (select deal_num from ssis_mtm_formate2_error_log)

			EXEC spa_print 'Insert If Error Found DONE '-- +CONVERT(VARCHAR,GETDATE(),109)
		END
	END
	ELSE IF @error_log_table_name='formate1' 
	BEGIN
--		if @schedule_run='y'
--			delete [ssis_mtm_formate1_error_log] where 
--				deal_num in (select external_type_id from #import_status)

		DELETE ssis_mtm_formate1_error_log
		FROM ssis_mtm_formate1_error_log err
		INNER JOIN (SELECT DISTINCT external_type_id FROM #import_status) st ON err.deal_num = st.external_type_id	

		INSERT INTO [ssis_mtm_formate1_error_log]
           ([DATE], [trade_date], [trade_time]
           , [deal_num], [TYPE], [MTM_undisc]
           , [MTM_disc], [currency_A], [currency_B]
           , [Internal_Portfolio], [Desk], [Commodity]
           , [Trader], [CounterParty], [reference]
           , [price_region], [buy_sell], [ias39_scope]
           , [ias39_book], [hedging_strategy], [hedging_side]
           , [contract_value], [legal_entity], [source_system_id]
           , [process_id], [create_ts], [as_of_date])
		SELECT mtm.[date], mtm.[trade_date], mtm.[trade_time]
		   , mtm.[deal_num], mtm.[type], mtm.[MTM_undisc]
		   , mtm.[MTM_disc], mtm.[currency_A], mtm.[currency_B]
		   , mtm.[Internal_Portfolio], mtm.[Desk], mtm.[Commodity]
		   , mtm.[Trader], mtm.[CounterParty], mtm.[reference]
		   , mtm.[price_region], mtm.[buy_sell], mtm.[ias39_scope]
		   , mtm.[ias39_book], mtm.[hedging_strategy], mtm.[hedging_side]
		   , mtm.[contract_value], mtm.[legal_entity], 	@source_system_desc_id 
		   , @process_id, GETDATE(), @import_as_of_date
		 FROM [ssis_mtm_formate1] mtm
		 INNER JOIN (SELECT DISTINCT external_type_id FROM #import_status) st ON mtm.deal_num = st.external_type_id
		 --LEFT JOIN ssis_mtm_formate1_error_log err ON mtm.deal_num = err.deal_num
		 --WHERE err.deal_num IS NULL
		--from [ssis_mtm_formate1] where deal_num in (select external_type_id from #import_status)
		--and deal_num not in (select deal_num from ssis_mtm_formate1_error_log)

	END
END

CREATE TABLE #temp_deal_header(
	[deal_id] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
	[source_system_id] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
	[term_start] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
	[term_end] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
	[header_buy_sell_flag] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
	[option_flag] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
	[structured_deal_id] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
	[counterparty_id] [INT] NULL,
	[source_deal_type_id] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
	[source_deal_sub_type_id] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
	[option_type] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
	[option_excercise_type] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
	[source_system_book_id1] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
	[source_system_book_id2] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
	[source_system_book_id3] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
	[source_system_book_id4] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
	[description1] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
	[description2] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
	[description3] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
	[description4] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL, -- new column as of RWE-DE
	[deal_category_value_id] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
	[trader_id] [INT] NULL,
	[contract_id] [INT] NULL,
	[physical_financial_flag] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
	[ext_deal_id] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
	[deal_date] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
	[broker_id] [INT] NULL,
	legal_entity INT,
	internal_desk_id INT, 
	product_id INT,
	internal_portfolio_id INT,
	commodity_id INT, 
	reference VARCHAR(250) COLLATE DATABASE_DEFAULT,
	
	[block_type] INT, --sdv
	[block_define_id] INT, --sdv
	[granularity_id] INT, --sdv
	[Pricing] INT, --sdv
	[unit_fixed_flag] [CHAR](1) COLLATE DATABASE_DEFAULT,
	[broker_unit_fees] [FLOAT] NULL,
	[broker_fixed_cost] [FLOAT] NULL,
	[broker_currency_id] VARCHAR(250) COLLATE DATABASE_DEFAULT NULL, --scur
	--[deal_status] INT NULL,
	[term_frequency] [CHAR](1) COLLATE DATABASE_DEFAULT,
	[option_settlement_date] [VARCHAR](50) COLLATE DATABASE_DEFAULT,
	[template_id] INT,
	[close_reference_id] VARCHAR(50) COLLATE DATABASE_DEFAULT,
	[deal_seperator_id] INT ,
	[deal_status] VARCHAR (100) COLLATE DATABASE_DEFAULT,
	[Intrabook_deal_flag] CHAR(2) COLLATE DATABASE_DEFAULT,
	[internal_deal_type_value_id] INT ,
	[internal_deal_subtype_value_id] INT ,
	sort_id INT
) ON [PRIMARY]
DECLARE @sql_header VARCHAR(MAX)

DECLARE @deal_template_id INT, @internal_desk_id INT
SELECT @deal_template_id = template_id  FROM source_deal_header_template WHERE template_name = 'Hedge Accounting' -- FOR FASTRACKER RWE DE

SELECT @internal_desk_id = value_id FROM static_data_value WHERE code = 'Deal Volume'

SET @sql_header='INSERT INTO #temp_deal_header
                 SELECT MAX(a.deal_id) deal_id,
                        MAX(a.source_system_id) source_system_id,
                        MIN(CAST(a.term_start AS DATETIME)) term_start,
                        MAX(CAST(a.term_end AS DATETIME)) term_end,
                        ISNULL(MAX(a.header_buy_sell_flag), MAX(sdht.header_buy_sell_flag)) header_buy_sell_flag,
                        MAX(a.option_flag) option_flag,
                        MAX(a.structured_deal_id) structured_deal_id,
                        MAX(cp.source_counterparty_id) counterparty_id,
                        ISNULL(MAX(sdt.source_deal_type_id), MAX(sdht.source_deal_type_id)) source_deal_type_id,
                        ISNULL(MAX(sdst.source_deal_type_id), MAX(sdht.deal_sub_type_type_id)) source_deal_sub_type_id,
                        MAX(a.option_type) option_type,
                        MAX(a.option_excercise_type) option_excercise_type,
                        MAX(bb1.source_book_id) source_system_book_id1,
                        MAX(bb2.source_book_id) source_system_book_id2,
                        MAX(bb3.source_book_id) source_system_book_id3,
                        MAX(bb4.source_book_id) source_system_book_id4,
                        MAX(a.description1) description1,
                        MAX(a.description2) description2,
                        MAX(a.description3) description3
                        '

IF @exec_mode = 6 
BEGIN
	SET @sql_header = @sql_header + ',MAX(a.description4) description4'                  	
END
ELSE
BEGIN
	SET @sql_header = @sql_header + ',NULL description4' 
END

SET @sql_header = @sql_header + ',
                        ISNULL(MAX(a.deal_category_value_id), MAX(sdht.deal_category_value_id)) deal_category_value_id,
                        MAX(st.source_trader_id) trader_id,
                        ISNULL(MAX(cg.contract_id),MAX(sdht.contract_id)) contract_id,
                        ISNULL(MAX(a.physical_financial_flag),MAX(sdht.physical_financial_flag)) physical_financial_flag,
                        MAX(a.ext_deal_id) ext_deal_id,
                        MIN(a.deal_date) deal_date,
                        MAX(sb.source_counterparty_id) broker_id,
                        MAX(le.source_legal_entity_id) legal_entity'
IF @exec_mode = 1
BEGIN
	SET @sql_header=@sql_header+'
						,ISNULL(MAX(SID.source_internal_desk_id), MAX(sdht.internal_desk_id)) internal_desk_id 
						,ISNULL(MAX(sprod.source_product_id),MAX(sdht.product_id)) product_id
						,ISNULL(MAX(sip.source_internal_portfolio_id), MAX(sdht.internal_portfolio_id)) internal_portfolio_id
						,ISNULL(MAX(scom.source_commodity_id), MAX(sdht.commodity_id)) commodity_id 
						,MAX(a.reference) reference 
						,NULL [block_type] , --sdv
						NULL [block_define_id] , --sdv
						NULL [granularity_id] , --sdv
						NULL [Pricing] , --sdv
						NULL [unit_fixed_flag] ,
						NULL [broker_unit_fees],
						NULL [broker_fixed_cost],
						NULL [broker_currency_id], --scur
						NULL [term_frequency]  ,
						NULL [option_settlement_date] ,
						NULL [template_id]
		'
END
ELSE IF @exec_mode = 12 --Used for TRM
BEGIN
	--for TRM values of internal_desk_id and product_id are taken from static data value
	SET @sql_header=@sql_header+'
						,ISNULL(MAX(sdv_internal_desk_id.value_id), MAX(sdht.internal_desk_id)) internal_desk_id 
						,ISNULL(MAX(sdv_product_id.value_id),MAX(sdht.product_id)) product_id
						--,max(sid.source_internal_desk_id) internal_desk_id
						--,max(sprod.source_product_id) product_id
						,ISNULL(MAX(sip.source_internal_portfolio_id), MAX(sdht.internal_portfolio_id)) internal_portfolio_id
						,ISNULL(MAX(scom.source_commodity_id), MAX(sdht.commodity_id)) commodity_id 
						,MAX(a.reference) reference 
						,MAX(sdv_blo.value_id) [block_type] , --sdv
						ISNULL(MAX(sdv_blo1.value_id), MAX(sdht.block_define_id)) [block_define_id] , --sdv
						ISNULL(MAX(sdv_gra.value_id), MAX(sdht.granularity_id)) [granularity_id] , --sdv
						MAX(sdv_pri.value_id) [Pricing] , --sdv
						MAX(a.[unit_fixed_flag]) [unit_fixed_flag] ,
						MAX(a.[broker_unit_fees]) [broker_unit_fees],
						MAX(a.[broker_fixed_cost]) [broker_fixed_cost],
						MAX(scur_bro.source_currency_id) [broker_currency_id], --scur
						ISNULL(MAX(a.[term_frequency]), MAX(sdht.[term_frequency])) [term_frequency]  ,
						MAX(a.[option_settlement_date]) [option_settlement_date] ,
						MAX(sdht.[template_id]) [template_id],
						MAX(a.close_reference_id) [close_reference_id],
						MAX(deal_seperator_id) [deal_seperator_id],
						ISNULL(MAX(a.deal_status), MAX(sdht.deal_status)) [deal_status],
						MAX(a.Intrabook_deal_flag) [Intrabook_deal_flag],
						MAX(sdht.internal_deal_type_value_id) [internal_deal_type_value_id],
						MAX(sdht.internal_deal_subtype_value_id) [internal_deal_subtype_value_id]
						'

END
ELSE IF @exec_mode = 6 --RWE DE
BEGIN
	SET @sql_header=@sql_header+'
		, ' + CAST(@internal_desk_id AS VARCHAR(100)) +' internal_desk_id
		,MAX(sprod.source_product_id) product_id
		,MAX(sip.source_internal_portfolio_id) internal_portfolio_id
		,null commodity_id 
		,MAX(a.reference) reference

		,null [block_type] , --sdv
		null [block_define_id] , --sdv
		null [granularity_id] , --sdv
		null [Pricing] , --sdv
		null [unit_fixed_flag] ,
		null [broker_unit_fees],
		null [broker_fixed_cost],
		null [broker_currency_id], --scur
		null [term_frequency]  ,
		MAX(a.[option_settlement_date]) [option_settlement_date],
		' + CAST(@deal_template_id AS VARCHAR(100)) + ' [template_id],
		NULL [close_reference_id] ,
		NULL [deal_seperator_id],
		sdv_ds.[value_id] [deal_status],
		NULL [Intrabook_deal_flag] ,
		NULL [internal_deal_type_value_id] ,
		NULL [internal_deal_subtype_value_id]
		'
END
ELSE --- old fastracker
BEGIN
	SET @sql_header=@sql_header+'
						,NULL internal_desk_id 
						,NULL product_id
						,NULL internal_portfolio_id
						,NULL commodity_id 
						,NULL reference 

						,NULL [block_type] , --sdv
						NULL [block_define_id] , --sdv
						NULL [granularity_id] , --sdv
						NULL [Pricing] , --sdv
						NULL [unit_fixed_flag] ,
						NULL [broker_unit_fees],
						NULL [broker_fixed_cost],
						NULL [broker_currency_id], --scur
						NULL [term_frequency]  ,
						NULL [option_settlement_date] ,
						NULL [template_id]
						'

END
SET @sql_header=@sql_header+',min(temp_id) sort_id 
	FROM '+@temp_table_name+' a 
	left outer join source_counterparty cp on cp.counterparty_id=a.counterparty_id
	and cp.source_system_id=a.source_system_id
	left outer join source_traders st on st.trader_id=a.trader_id 
		and st.source_system_id=a.source_system_id
	left outer join source_counterparty sb on sb.counterparty_id=a.broker_id
			and sb.source_system_id=a.source_system_id and sb.int_ext_flag=''b''
	left outer join contract_group cg on cg.source_contract_id=a.contract_id
			and cg.source_system_id=a.source_system_id
	left join source_deal_type sdt on sdt.deal_type_id=a.source_deal_type_id
			and sdt.source_system_id=a.source_system_id
	left join source_deal_type sdst on sdst.deal_type_id=a.source_deal_sub_type_id
				and sdst.source_system_id=a.source_system_id
	left join source_book bb1 on bb1.source_system_book_id=a.source_system_book_id1
		and bb1.source_system_id=a.source_system_id and bb1.source_system_book_type_value_id=50
	left join source_book bb2 on bb2.source_system_book_id=a.source_system_book_id2
			and bb2.source_system_id=a.source_system_id and bb2.source_system_book_type_value_id=51
	left join source_book bb3 on bb3.source_system_book_id=a.source_system_book_id3
			and bb3.source_system_id=a.source_system_id and bb3.source_system_book_type_value_id=52
	left join source_book bb4 on bb4.source_system_book_id=a.source_system_book_id4
			and bb4.source_system_id=a.source_system_id and bb4.source_system_book_type_value_id=53
	left outer join source_legal_entity le on le.legal_entity_id=a.legal_entity and 
		le.source_system_id=a.source_system_id'
IF @exec_mode = 1
BEGIN
	SET @sql_header=@sql_header+'
		left outer join source_internal_desk sid on sid.internal_desk_id=a.internal_desk_id and 
		sid.source_system_id=a.source_system_id
		left outer join source_product sprod on sprod.product_id=a.product_id and 
		sprod.source_system_id=a.source_system_id
		left outer join source_internal_portfolio sip on sip.internal_portfolio_id=a.internal_portfolio_id and 
		sip.source_system_id=a.source_system_id
		left outer join source_commodity scom on scom.commodity_id=a.commodity_id and 
		scom.source_system_id=a.source_system_id'
END
ELSE IF @exec_mode = 6
BEGIN
	SET @sql_header = @sql_header + '
		LEFT JOIN source_product sprod ON sprod.product_id = a.product_id AND sprod.source_system_id=a.source_system_id
		LEFT JOIN source_internal_portfolio sip ON sip.internal_portfolio_id = a.internal_portfolio_id AND sip.source_system_id = a.source_system_id
		LEFT JOIN static_data_value sdv_ds ON CASE sdv_ds.code WHEN ''Validated'' THEN ''O'' WHEN ''Matured'' THEN ''S'' WHEN ''Cancelled'' THEN ''V'' END = a.trade_status
		left join source_deal_header_template sdht on sdht.template_name=a.[template]'
		
	SET @sql_header = @sql_header + ' WHERE sdv_ds.type_id = 5600 '	

END
ELSE IF @exec_mode = 12
BEGIN
	SET @sql_header=@sql_header+'
		LEFT OUTER JOIN  static_data_value sdv_internal_desk_id ON sdv_internal_desk_id.code = a.internal_desk_id
		LEFT OUTER JOIN  static_data_value sdv_product_id ON sdv_product_id.code = a.product_id
		--left outer join source_internal_desk sid on sid.internal_desk_id=a.internal_desk_id and 
		--sid.source_system_id=a.source_system_id
		--left outer join source_product sprod on sprod.product_id=a.product_id and 
		--sprod.source_system_id=a.source_system_id
		left outer join source_internal_portfolio sip on sip.internal_portfolio_id=a.internal_portfolio_id and 
		sip.source_system_id=a.source_system_id
		left outer join source_commodity scom on scom.commodity_id=a.commodity_id and 
		scom.source_system_id=a.source_system_id
		
		left outer join source_currency scur_bro on scur_bro.currency_id=a.[broker_currency_id] and 
			scur_bro.source_system_id=a.source_system_id
		left outer join static_data_value sdv_blo on sdv_blo.[code]=a.[block_type] 
		left outer join static_data_value sdv_blo1 on sdv_blo1.[code]=a.[block_define_id] 
		left outer join static_data_value sdv_gra on sdv_gra.[code]=a.[granularity_id] 
		left outer join static_data_value sdv_pri on sdv_pri.[code]=a.[Pricing] 
		left join source_deal_header_template sdht on sdht.template_name=a.[template]
		'		
END
SET @sql_header=@sql_header+' group by a.deal_id ' + CASE WHEN @exec_mode = 6 THEN ', sdv_ds.[value_id]' ELSE '' END + ' order by sort_id'

exec spa_print @sql_header
EXEC(@sql_header)

DECLARE @confirm_status INT
SELECT @confirm_status = value_id FROM static_data_value WHERE code = 'Not Confirmed' AND type_id = 17200

EXEC spa_print 'Deal header Update'
SET @sql_header = 'UPDATE [source_deal_header]
   SET [source_system_id] = a.source_system_id
      ,[deal_date] =  a.deal_date
      ,[ext_deal_id] =  a.ext_deal_id
      ,[physical_financial_flag] =  a.physical_financial_flag
      ,[counterparty_id] =  a.counterparty_id '
IF @exec_mode = 1
BEGIN
	SET @sql_header=@sql_header + '
			,internal_desk_id=a.internal_desk_id 
			,product_id=a.product_id
			,internal_portfolio_id=a.internal_portfolio_id
			,commodity_id=a.commodity_id 
			,reference=a.reference
			,[entire_term_end] = case when a.term_end > b.entire_term_end then a.term_end  else b.entire_term_end end '
END
ELSE IF @exec_mode = 12
BEGIN
	SET @sql_header=@sql_header + '
		,[entire_term_start] =  a.term_start
		 ,[entire_term_end] =  a.term_end 
		,[source_system_book_id1] =  ISNULL(a.source_system_book_id1,-1)
		,[source_system_book_id4] =  ISNULL(a.source_system_book_id4,-4)
		,[contract_id] =  a.contract_id
		,[structured_deal_id] =  a.structured_deal_id
		,internal_desk_id=a.internal_desk_id 
		,product_id=a.product_id
		,internal_portfolio_id=a.internal_portfolio_id
		,commodity_id=a.commodity_id 
		,reference=a.reference

		,[block_type] =a.[block_type] , --sdv
		[block_define_id]= a.[block_define_id] , --sdv
		[granularity_id] =a.[granularity_id] , --sdv
		[Pricing]= a.[Pricing] , --sdv
		[unit_fixed_flag] =a.[unit_fixed_flag] ,
		[broker_unit_fees] = NULL, --a.[broker_unit_fees],
		[broker_fixed_cost] = NULL,--a.[broker_fixed_cost],
		[broker_currency_id]= a.[broker_currency_id], --scur
		[term_frequency] =a.[term_frequency]  ,
		[option_settlement_date] =a.[option_settlement_date] ,
		[template_id]=a.[template_id],
		[close_reference_id] = a.[close_reference_id],
		[deal_reference_type_id] = CASE WHEN a.Intrabook_deal_flag = ''T'' THEN 12503
										WHEN a.Intrabook_deal_flag = ''O'' THEN 12500
										ELSE NULL
								END 
	    ,[deal_status] = a.deal_status,
	    [internal_deal_type_value_id] = a.internal_deal_type_value_id,
	    [internal_deal_subtype_value_id] = a.internal_deal_subtype_value_id
		'
END


ELSE
BEGIN
	SET @sql_header=@sql_header + '
		 ,[entire_term_start] =  a.term_start
		 ,[entire_term_end] =  a.term_end 
		,[source_system_book_id1] =  ISNULL(a.source_system_book_id1,-1)
		,[source_system_book_id4] =  ISNULL(a.source_system_book_id4,-4)
		,[contract_id] =  a.contract_id
		,[structured_deal_id] =  a.structured_deal_id
	'
END
SET @sql_header=@sql_header + '
      ,[source_deal_type_id] =  a.source_deal_type_id
      ,[deal_sub_type_type_id] =  a.source_deal_sub_type_id
      ,[option_flag] =  a.option_flag
      ,[option_type] =  a.option_type
      ,[option_excercise_type] =  a.option_excercise_type
      ,[source_system_book_id2] =  ISNULL(a.source_system_book_id2,-2)
      ,[source_system_book_id3] =  ISNULL(a.source_system_book_id3,-3)
      ,[description1] =  a.description1
      ,[description2] =  a.description2
      ,[description3] =  a.description3'
      
IF @exec_mode = 6
BEGIN
	SET @sql_header = @sql_header + ',[description4] =  a.description4, [deal_status] = a.deal_status 
			, internal_desk_id = a.internal_desk_id, product_id = a.product_id, internal_portfolio_id = a.internal_portfolio_id, reference = a.reference '
END

SET @sql_header = @sql_header + ',[deal_category_value_id] =  a.deal_category_value_id
      ,[trader_id] =  a.trader_id
      ,[header_buy_sell_flag] =  LOWER(a.header_buy_sell_flag)
      ,[broker_id] =  a.broker_id
	  ,legal_entity=a.legal_entity
	,update_user='''+@user_login_id+''',
	update_ts=getdate(),
	confirm_status_type = '+ CAST(@confirm_status AS VARCHAR(100)) + '
   FROM #temp_deal_header a 
INNER JOIN 	source_deal_header b 
ON  a.deal_id = b.deal_id AND b.source_system_id=a.source_system_id
'

exec spa_print @sql_header

EXEC(@sql_header)

EXEC spa_print 'Deal header Insert'
SET @sql_header='INSERT INTO [source_deal_header]
           ([source_system_id]
           ,[deal_id]
           ,[deal_date]
           ,[ext_deal_id]
           ,[physical_financial_flag]
           ,[structured_deal_id]
           ,[counterparty_id]
           ,[entire_term_start]
           ,[entire_term_end]
           ,[source_deal_type_id]
           ,[deal_sub_type_type_id]
           ,[option_flag]
           ,[option_type]
           ,[option_excercise_type]
           ,[source_system_book_id1]
           ,[source_system_book_id2]
           ,[source_system_book_id3]
           ,[source_system_book_id4]
           ,[description1]
           ,[description2]
           ,[description3]
           ,[description4]
           ,[deal_category_value_id]
           ,[trader_id]
           ,[header_buy_sell_flag]
           ,[broker_id]
           ,[contract_id]
		   ,legal_entity'
IF @exec_mode = 1 
BEGIN
	SET @sql_header=@sql_header+'
			,internal_desk_id 
			,product_id
			,internal_portfolio_id
			,commodity_id 
			,reference'
END	
ELSE IF @exec_mode = 6
BEGIN
	SET @sql_header=@sql_header+'
			,internal_desk_id 
			,product_id
			,internal_portfolio_id
			,reference
			, [block_type] , --sdv
			 [block_define_id] , --sdv
			 [granularity_id] , --sdv
			 [Pricing] , --sdv
			 [unit_fixed_flag] ,
			 [broker_unit_fees],
			 [broker_fixed_cost],
			 [broker_currency_id], --scur
			 [term_frequency]  ,
			 [option_settlement_date] ,
			 [template_id],
			 [close_reference_id],
			 [deal_reference_type_id],
			 [deal_status],
			 [internal_deal_type_value_id] ,
			 [internal_deal_subtype_value_id]'	
END
ELSE IF @exec_mode = 12 
BEGIN
	SET @sql_header=@sql_header+'
			,internal_desk_id 
			,product_id
			,internal_portfolio_id
			,commodity_id 
			,reference
		, [block_type] , --sdv
		 [block_define_id] , --sdv
		 [granularity_id] , --sdv
		 [Pricing] , --sdv
		 [unit_fixed_flag] ,
		 [broker_unit_fees],
		 [broker_fixed_cost],
		 [broker_currency_id], --scur
		 [term_frequency]  ,
		 [option_settlement_date] ,
		 [template_id],
		 [close_reference_id],
		 [deal_reference_type_id],
		 [deal_status],
		 [internal_deal_type_value_id] ,
	     [internal_deal_subtype_value_id]
		'
END	
	
SET @sql_header=@sql_header+'
,create_user
,create_ts,confirm_status_type 
,update_user,update_ts)
 select 
	a.[source_system_id] 
	,a.deal_id
	,a.deal_date
	,a.ext_deal_id
	,a.physical_financial_flag
	,a.structured_deal_id
	,a.counterparty_id
	,a.term_start
	,a.term_end
	,a.source_deal_type_id
	,a.source_deal_sub_type_id
	,a.option_flag
	,a.option_type
	,a.option_excercise_type
	,ISNULL(a.source_system_book_id1,-1)
	,ISNULL(a.source_system_book_id2,-2)
	,ISNULL(a.source_system_book_id3,-3)
	,ISNULL(a.source_system_book_id4,-4)
	,a.description1
	,a.description2
	,a.description3'

IF @exec_mode = 6
BEGIN
	SET @sql_header = @sql_header + ',a.[description4]'
END	
ELSE
BEGIN
	SET @sql_header = @sql_header + ', NULL [description4]'
END
	
SET @sql_header = @sql_header + ',a.deal_category_value_id
	,a.trader_id
	,LOWER(a.header_buy_sell_flag)
	,a.broker_id
	,a.contract_id
	,a.legal_entity'
IF @exec_mode = 1 
BEGIN
	SET @sql_header=@sql_header+'
	,a.internal_desk_id 
	,a.product_id
	,a.internal_portfolio_id
	,a.commodity_id 
	,a.reference'
END
ELSE IF @exec_mode = 6
BEGIN
	SET @sql_header = @sql_header + '
		,a.internal_desk_id 
		,a.product_id
		,a.internal_portfolio_id
		,a.reference
		, a.[block_type] , --sdv
		 a.[block_define_id] , --sdv
		 a.[granularity_id] , --sdv
		 a.[Pricing] , --sdv
		 a.[unit_fixed_flag] ,
		 a.[broker_unit_fees],
		 a.[broker_fixed_cost],
		 a.[broker_currency_id], --scur
		 a.[term_frequency]  ,
		 CONVERT(DATETIME, a.[option_settlement_date], 103),
		 a.[template_id],
		 a.[close_reference_id],
		 CASE WHEN a.Intrabook_deal_flag = ''T'' THEN 12503
			WHEN a.Intrabook_deal_flag = ''O'' THEN 12500
			ELSE NULL
			END 
		,a.deal_status,
		a.internal_deal_type_value_id,
	      a.internal_deal_subtype_value_id'
	
END
ELSE IF @exec_mode = 12 
BEGIN
	SET @sql_header=@sql_header+'
		,a.internal_desk_id 
		,a.product_id
		,a.internal_portfolio_id
		,a.commodity_id 
		,a.reference
		, a.[block_type] , --sdv
		 a.[block_define_id] , --sdv
		 a.[granularity_id] , --sdv
		 a.[Pricing] , --sdv
		 a.[unit_fixed_flag] ,
		 a.[broker_unit_fees],
		 a.[broker_fixed_cost],
		 a.[broker_currency_id], --scur
		 a.[term_frequency]  ,
		 a.[option_settlement_date],
		 a.[template_id],
		 a.[close_reference_id],
			CASE WHEN a.Intrabook_deal_flag = ''T'' THEN 12503
			WHEN a.Intrabook_deal_flag = ''O'' THEN 12500
			ELSE NULL
			END  
		 ,a.deal_status,
		  a.internal_deal_type_value_id,
	      a.internal_deal_subtype_value_id
		'
END	

SET @sql_header=@sql_header+',
	'''+@user_login_id+''',
	getdate(), ' + CAST(@confirm_status AS VARCHAR(100)) + ',''' + @user_login_id + '''
	, getdate()
from #temp_deal_header a left join source_deal_header b on a.deal_id=b.deal_id AND b.source_system_id=a.source_system_id
where b.deal_id is null'
exec spa_print @sql_header

EXEC(@sql_header)

IF @exec_mode = 6
BEGIN
	DECLARE @today DATETIME
	SET @today = GETDATE()
	
	IF EXISTS (SELECT 1 FROM #temp_deal_header WHERE deal_id = 'Expected to occur')
	BEGIN
		INSERT INTO #temp_process_table_name([name]) VALUES('ALL')
		--EXEC spa_calc_dynamic_limit @today, 'c'
	END
	ELSE
	BEGIN
		DECLARE @COUNTERPARTY_ID NVARCHAR(1000)
		CREATE TABLE #temp(counterparty_id VARCHAR(MAX) COLLATE DATABASE_DEFAULT)
	    INSERT INTO #temp(counterparty_id) 
	    SELECT STUFF((
				SELECT ',' + sdv.code 
				FROM static_data_type sdt
				INNER JOIN static_data_value sdv ON sdv.[type_id] = sdt.[type_id]
					AND sdt.[type_id] = 19100
				FOR XML PATH('')
			), 1, 1, '') AS counterparty_id
	    
	    SELECT @COUNTERPARTY_ID = counterparty_id FROM #temp
		
		IF EXISTS (
					SELECT 1 
					FROM source_deal_header sdh 
					INNER JOIN #temp_deal_header tdh ON tdh.deal_id = sdh.deal_id
					INNER JOIN source_counterparty sc ON  sc.source_counterparty_id = tdh.counterparty_id
					INNER JOIN dbo.SplitCommaSeperatedValues(@COUNTERPARTY_ID) scsv ON scsv.Item = sc.counterparty_id
					)
		BEGIN
			DECLARE @source_updated_deal_table VARCHAR(500)
			SET @source_updated_deal_table = dbo.FNAProcessTableName('deal_header_id', @user_login_id, @process_id)
			INSERT INTO #temp_process_table_name([name]) VALUES(@source_updated_deal_table)
			
			SET @sql = 'IF OBJECT_ID(''' + @source_updated_deal_table + ''') IS NULL
							CREATE TABLE ' + @source_updated_deal_table + ' (source_deal_header_id INT, term_start DATETIME, term_end DATETIME)'
			EXEC(@sql)

			SET @sql = '
						INSERT INTO ' + @source_updated_deal_table	 + ' (source_deal_header_id, term_start, term_end) 
						SELECT sdh.source_deal_header_id, CONVERT(DATETIME, tdh.term_start, 120), CONVERT(DATETIME, tdh.term_end, 120) FROM #temp_deal_header tdh
						INNER JOIN source_deal_header sdh ON sdh.deal_id = tdh.deal_id
						INNER JOIN  source_counterparty sc ON  sc.source_counterparty_id = tdh.counterparty_id
						INNER JOIN dbo.SplitCommaSeperatedValues(''' + @COUNTERPARTY_ID + ''') scsv ON scsv.Item = sc.counterparty_id
						--INNER JOIN source_system_book_map ssbm 
						--ON ssbm.source_system_book_id1 = tdh.source_system_book_id1
						--	AND ssbm.source_system_book_id2 = tdh.source_system_book_id2
						--	AND ssbm.source_system_book_id3 = tdh.source_system_book_id3
						--	AND ssbm.source_system_book_id4 = tdh.source_system_book_id4
						--	AND ssbm.fas_deal_type_value_id = 410
						'
			EXEC(@sql)
				
			
		END
	END
	
	SET @sql_header = '
	UPDATE user_defined_deal_fields 
	SET udf_value = sp.source_product_id
	FROM ' + @temp_table_name + ' a
	INNER JOIN source_deal_header sdh ON sdh.deal_id = a.deal_id
	INNER JOIN user_defined_deal_fields uddf ON sdh.source_deal_header_id = uddf.source_deal_header_id
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = uddf.udf_template_id AND uddft.field_name = -5720
	LEFT JOIN source_product sp ON sp.product_name = a.product_id
	'
	EXEC(@sql_header)

	SET @sql_header = '
	UPDATE user_defined_deal_fields 
	SET udf_value = sid.source_internal_desk_id
	FROM ' + @temp_table_name + ' a
	INNER JOIN source_deal_header sdh ON sdh.deal_id = a.deal_id
	INNER JOIN user_defined_deal_fields uddf ON sdh.source_deal_header_id = uddf.source_deal_header_id
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = uddf.udf_template_id AND uddft.field_name = -5716
	LEFT JOIN source_internal_desk sid ON sid.internal_desk_id = a.internal_desk_id AND sid.source_system_id = a.source_system_id
	'
	EXEC(@sql_header)

	SET @sql_header = '
	INSERT INTO user_defined_deal_fields (source_deal_header_id, udf_template_id, udf_value)
	SELECT DISTINCT sdh.source_deal_header_id, uddft.udf_template_id, sid.source_internal_desk_id
	FROM ' + @temp_table_name + ' a
	INNER JOIN source_deal_header sdh ON sdh.deal_id = a.deal_id
	LEFT JOIN user_defined_deal_fields_template uddft ON uddft.template_id = ' + CAST(@deal_template_id AS VARCHAR(100)) + ' AND uddft.field_name = -5716
	LEFT JOIN source_internal_desk sid ON sid.internal_desk_id = a.internal_desk_id AND sid.source_system_id = a.source_system_id
	LEFT JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = sdh.source_deal_header_id 
	WHERE uddf.udf_deal_id IS NULL
	UNION ALL
	SELECT DISTINCT sdh.source_deal_header_id, uddft.udf_template_id, sp.source_product_id
	FROM ' + @temp_table_name + ' a
	INNER JOIN source_deal_header sdh ON sdh.deal_id = a.deal_id
	LEFT JOIN user_defined_deal_fields_template uddft ON uddft.template_id = ' + CAST(@deal_template_id AS VARCHAR(100)) + ' AND uddft.field_name = -5720
	LEFT JOIN source_product sp ON sp.product_name = a.product_id
	LEFT JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = sdh.source_deal_header_id 
	WHERE uddf.udf_deal_id IS NULL
	'
	EXEC(@sql_header)

	/* UK Limit*/
	/*
	DECLARE @POWER_LIMIT_ID INT
	DECLARE @NATURAL_GAS_LIMIT_ID INT
	DECLARE @COAL_LIMIT_ID INT

	SELECT @POWER_LIMIT_ID = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'UK Power Dynamic Limit'
	SELECT @NATURAL_GAS_LIMIT_ID = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'UK Gas Dynamic Limit'
	SELECT @COAL_LIMIT_ID = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'UK Coal Dynamic Limit'
	
	IF OBJECT_ID('tempdb..#temp_process_table_name_UK') IS NULL
	BEGIN
		CREATE TABLE #temp_process_table_name_UK([name] VARCHAR(MAX) COLLATE DATABASE_DEFAULT)
	END

	IF EXISTS(SELECT 1	 
	FROM generic_mapping_values gmv
	INNER JOIN #temp_deal_header sdh ON sdh.source_system_book_id1 = gmv.[clm1_value]
		AND sdh.source_system_book_id2 = gmv.[clm2_value]
		AND sdh.source_system_book_id3 = gmv.[clm3_value]
		AND sdh.source_system_book_id4 = gmv.[clm4_value]
	WHERE mapping_table_id IN (@POWER_LIMIT_ID, @NATURAL_GAS_LIMIT_ID, @COAL_LIMIT_ID))
	BEGIN
		INSERT INTO #temp_process_table_name_UK([name]) VALUES('yes')
	END
	ELSE 
	BEGIN
		INSERT INTO #temp_process_table_name_UK([name]) VALUES('no')
	END
	*/
END

-- to update the close_reference_id of IntraBook Deals
IF @exec_mode = 12 
BEGIN 
	UPDATE sdh
	SET sdh.close_reference_id = b.deal_header_id
		   --SELECT a.sdh AS a ,b.sdh AS b ,sdh.source_deal_header_id,*
	FROM   (
			   SELECT sdh.source_deal_header_id AS deal_header_id,
					  t.deal_seperator_id,
					  sdh.close_reference_id AS deal_close_reference_id
			   FROM   #temp_deal_header t
			   INNER JOIN source_deal_header sdh
						   ON  t.deal_id = sdh.deal_id
		   ) a
		   INNER JOIN (
					SELECT sdh.source_deal_header_id AS deal_header_id,
						   t.deal_seperator_id,
						   sdh.close_reference_id AS deal_close_reference_id
					FROM   #temp_deal_header t
						   INNER JOIN source_deal_header sdh
								ON  t.deal_id = sdh.deal_id
				) b
				ON  a.deal_seperator_id = b.deal_close_reference_id
		   INNER JOIN source_deal_header sdh
				ON  a.deal_header_id = sdh.source_deal_header_id
END	



EXEC spa_print 'Start Delete: '--+CONVERT(VARCHAR,GETDATE(),109)	
EXEC spa_print 'SOURCE DEAL DETAIL UPDATE'


DECLARE @deal_detail_audit_log INT



IF EXISTS(SELECT 1 FROM #temp_deal_header WHERE source_system_id IN ('3', '2')) --apply only for RWE & RWE-DE
	SELECT  @deal_detail_audit_log = var_value 	FROM    adiha_default_codes_values
		WHERE   (instance_no = '1') AND (default_code_id = 32) AND (seq_no = 1)
ELSE 
	SET @deal_detail_audit_log=1
	
IF ISNULL(@deal_detail_audit_log,1)=2
BEGIN
	
	CREATE TABLE #updated_deals_confirm (deal_header_id INT,deal_id VARCHAR(250) COLLATE DATABASE_DEFAULT,curve_id VARCHAR(250) COLLATE DATABASE_DEFAULT,curve_id_p VARCHAR(250) COLLATE DATABASE_DEFAULT 
		,term_start DATETIME,term_end DATETIME, buy_sell VARCHAR(1) COLLATE DATABASE_DEFAULT, buy_sell_p VARCHAR(1) COLLATE DATABASE_DEFAULT
		, volume NUMERIC(38,20),volume_p NUMERIC(38,20), price NUMERIC(38,20), price_p NUMERIC(38,20))

	SET @sql='
		INSERT #updated_deals_confirm (deal_header_id ,deal_id ,curve_id ,curve_id_p,term_start,term_end, buy_sell ,buy_sell_p, volume,volume_p , price ,price_p)
		select d.source_deal_header_id,h.deal_id,a.curve_id,c.curve_id,a.term_start,a.term_end, a.buy_sell_flag,d.buy_sell_flag ,a.deal_volume,d.deal_volume,round(a.fixed_price,2) ,round(d.fixed_price,2)
		from source_deal_detail d inner join source_deal_header h on
					h.source_deal_header_id=d.source_deal_header_id inner join
				'+@temp_table_name+' a on a.deal_id=h.deal_id AND h.source_system_id=a.source_system_id 
				and cast(a.term_start as datetime)=d.term_start 
				and cast(a.term_end as datetime)=d.term_end 
				and a.leg=d.leg
		 left join source_price_curve_def c ON c.source_curve_def_id = d.curve_id AND h.source_system_id=c.source_system_id
		where a.curve_id<>c.curve_id or a.buy_sell_flag<>d.buy_sell_flag or round(cast(a.deal_volume as numeric(38,20)),0)<>round(d.deal_volume,0)
		or round(cast(a.fixed_price as numeric(38,20)),0)<>round(d.fixed_price,0)	 '
	exec spa_print @sql
	EXEC(@sql)
END

IF ISNULL(@exec_mode,0) = 0  	
	SET @sql='DELETE source_deal_detail
	          FROM   source_deal_detail d
	          INNER JOIN source_deal_header h ON  h.source_deal_header_id = d.source_deal_header_id
	          INNER JOIN '+@temp_table_name+' a
                  ON  a.deal_id = h.deal_id
                  AND h.source_system_id = a.source_system_id'
ELSE
	SET @sql='DELETE source_deal_detail
	          FROM   source_deal_detail d
	          INNER JOIN source_deal_header h ON  h.source_deal_header_id = d.source_deal_header_id
			  INNER JOIN '+@temp_table_name+' a
				  ON  a.deal_id = h.deal_id
				  AND a.source_system_id = h.source_system_id
				  AND CAST(a.term_start AS DATETIME) = d.term_start
				  AND CAST(a.term_end AS DATETIME) = d.term_end '
	
	EXEC spa_print @sql
	EXEC(@sql)
	EXEC spa_print 'End: '--+CONVERT(VARCHAR,GETDATE(),109)	
--SOURCE DEAL DETAIL INSERT
	exec spa_print 'Source Deal Detail INSERT STARTED'
	DECLARE @deal_detail_insert_batch_ts	DATETIME
	DECLARE @deal_detail_insert_ts			DATETIME
	SET @deal_detail_insert_ts = GETDATE()
	SET @deal_detail_insert_batch_ts = GETDATE()

--	--previous logic
--	SET @sql1 = 
--			'INSERT INTO source_deal_detail(source_deal_header_id, term_start, term_end, Leg, contract_expiration_date
--					, fixed_float_leg, buy_sell_flag, curve_id, fixed_price, fixed_price_currency_id, option_strike_price
--					, deal_volume, deal_volume_frequency, deal_volume_uom_id, block_description, deal_detail_description
--					, create_user, create_ts)
--			SELECT DISTINCT b.source_deal_header_id, a.term_start, a.term_end, a.Leg, a.contract_expiration_date
--			, a.fixed_float_leg, a.buy_sell_flag, c.source_curve_def_id, a.fixed_price
--			, CASE 
--				WHEN a.fixed_price_currency_id IS NULL THEN NULL
--				ELSE e.source_currency_id 
--			  END, a.option_strike_price, a.deal_volume, a.deal_volume_frequency, d.source_uom_id
--			, a.block_description
--			, a.deal_detail_description, ''' + @user_login_id + ''', GETDATE()
--			FROM source_currency e 
--			INNER JOIN ' + @temp_table_name + ' a ON e.source_system_id = a.source_system_id 
--				AND e.currency_id = ISNULL(a.fixed_price_currency_id, e.currency_id) 
--			INNER JOIN source_deal_header b ON a.deal_id = b.deal_id AND a.source_system_id = b.source_system_id 
--			INNER JOIN source_uom d ON a.source_system_id = d.source_system_id AND a.deal_volume_uom_id = d.uom_id 
--			LEFT JOIN source_price_curve_def c ON a.source_system_id = c.source_system_id 
--				AND c.curve_id = a.curve_id
--			LEFT JOIN #import_status ON a.temp_id = #import_status.temp_id 
--			WHERE #import_status.temp_id IS NULL
--			'

	CREATE TABLE #temp_inserting_deal (
		temp_id INT,
		source_uom_id INT,
		source_curve_def_id INT
	)

	--get temp_id of only those deals which are needed to be inserted
--INSERT INTO #temp_inserting_deal(temp_id)
--			SELECT a.temp_id FROM ' + @temp_table_name + ' a
--			LEFT JOIN #import_status s ON a.temp_id = s.temp_id 
--			WHERE s.temp_id IS NULL
	SET @sql1 = 
			'
			INSERT INTO #temp_inserting_deal(temp_id,source_uom_id,source_curve_def_id)
			SELECT a.temp_id,d.source_uom_id,c.source_curve_def_id 
			FROM ' + @temp_table_name + ' a
			LEFT JOIN #import_status s ON a.temp_id = s.temp_id
			INNER JOIN source_uom d ON a.source_system_id = d.source_system_id 
				AND a.deal_volume_uom_id = d.uom_id
			LEFT JOIN source_price_curve_def c ON a.source_system_id = c.source_system_id 
				AND c.curve_id = a.curve_id
			WHERE s.temp_id IS NULL
			'
	EXEC spa_print @sql1
	EXEC(@sql1)
	
	EXEC('IF EXISTS (SELECT * FROM adiha_process.sys.indexes i WITH(NOLOCK)
		INNER JOIN adiha_process.sys.objects o WITH(NOLOCK) ON i.object_id = o.object_id
		WHERE o.type = ''U'' AND ''adiha_process.dbo.'' + o.name = ''' + @temp_table_name + '''
		AND i.name = N''idx_2' + @process_id + ''')
		DROP INDEX idx_2' + @process_id + ' ON ' + @temp_table_name)

	EXEC('CREATE INDEX idx_2'+@process_id+' ON ' + @temp_table_name +' (temp_id)')

	EXEC('IF EXISTS (SELECT * FROM adiha_process.sys.indexes i WITH(NOLOCK)
	INNER JOIN adiha_process.sys.objects o WITH(NOLOCK) ON i.object_id = o.object_id
	WHERE o.type = ''U'' AND ''adiha_process.dbo.'' + o.name = ''' + @temp_table_name + '''
	AND i.name = N''idx_3' + @process_id + ''')
	DROP INDEX idx_3' + @process_id + ' ON ' + @temp_table_name)

	EXEC('CREATE INDEX idx_3'+@process_id+' ON ' + @temp_table_name +' (curve_id)')

	CREATE INDEX idx_1 ON #temp_inserting_deal(temp_id)
	
	exec spa_print 'Saved error free deals to be inserted in temp table. Process took ' --+ dbo.FNACalculateTimestamp(@deal_detail_insert_ts)


	SET @sql='DELETE sdg
			FROM source_deal_groups sdg
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdg.source_deal_header_id
			INNER JOIN ' + @temp_table_name + ' a
                  ON  a.deal_id = sdh.deal_id
                  AND sdh.source_system_id = a.source_system_id'

	EXEC spa_print @sql 
	EXEC(@sql)

	SET @sql = 'INSERT INTO source_deal_groups(
				source_deal_header_id
				, term_from
				, term_to
				, location_id
				, curve_id
				, detail_flag
				, leg
				)

			SELECT DISTINCT b.source_deal_header_id, 
					MIN(a.term_start)
					, MAX(a.term_end)
					' + CASE WHEN @exec_mode = 12 OR @exec_mode = 6 THEN
						', CASE WHEN MAX(a.[physical_financial_flag]) = ''f'' THEN NULL ELSE MAX(sml.source_minor_location_id) END  [location_id]'
					  ELSE ', NULL' 
					  END + '
					, MAX(out_app.source_curve_def_id)  source_curve_def_id
					,0
					, out_app.leg leg
			FROM #temp_inserting_deal t
			INNER JOIN ' + @temp_table_name + ' a ON a.temp_id = t.temp_id
			INNER JOIN source_deal_header b ON a.deal_id = b.deal_id AND b.source_system_id=a.source_system_id
			OUTER APPLY  (
				SELECT ISNULL(a.Leg, sddt.leg) leg , ISNULL(t.source_curve_def_id, sddt.curve_id) source_curve_def_id 
				FROM source_deal_header_template sdht
					LEFT JOIN source_deal_detail_template sddt ON sdht.template_id = sddt.template_id
					WHERE sdht.template_id = b.template_id
			
			) out_app 
			' + CASE WHEN @exec_mode = 12 THEN
			' LEFT JOIN source_minor_location sml ON sml.source_system_id = a.source_system_id 
						AND  sml.Location_Name = a.[location_id]
		   '  WHEN @exec_mode = 6 THEN
			' LEFT JOIN source_price_curve_def spcd ON spcd.curve_id = a.curve_id AND spcd.source_system_id = a.source_system_id
			  LEFT JOIN source_minor_location sml ON sml.source_system_id = a.source_system_id AND sml.Location_Name = spcd.[curve_name]
			'
			 ELSE '' END + ' GROUP BY b.source_deal_header_id,out_app.leg '
	
	--select @sql
	EXEC(@sql)

	SET @deal_detail_insert_ts = GETDATE()
	SET @sql1 = 
			'INSERT INTO source_deal_detail(source_deal_header_id, term_start, term_end, Leg, contract_expiration_date
					, fixed_float_leg, buy_sell_flag, fixed_price, fixed_price_currency_id, option_strike_price
					, deal_volume, deal_volume_frequency, deal_volume_uom_id, block_description, deal_detail_description
					, create_user, create_ts, source_deal_group_id, ' 
					+ CASE WHEN @exec_mode = 12 THEN
						'curve_id, 
						[settlement_volume],
						[settlement_uom] , --suom_set
						[price_adder],
						[price_multiplier],
						[settlement_date],
						[day_count_id],  --sdv_day
						[location_id], --select * from source_minor_location
						[meter_id],   -- select * from source_minor_location_meter
						[physical_financial_flag],
						[fixed_cost],
						[multiplier],
						[adder_currency_id],
						[fixed_cost_currency_id],
						[formula_currency_id],
						[price_adder2],
						[price_adder_currency2],
						[volume_multiplier2],
						[pay_opposite],
						[capacity],
						[settlement_currency],
						[standard_yearly_volume],
						[price_uom_id],
						[category],
						[profile_code],
						[pv_party],
						[formula_id]
						'	
				WHEN @exec_mode = 6 THEN
						'curve_id, 
						[settlement_date],
						[location_id],
						[physical_financial_flag]
						'		
						
					ELSE ''
					END +'	
			)
			SELECT DISTINCT b.source_deal_header_id, 
					a.term_start
					, a.term_end
					, ISNULL(a.Leg, sddt.leg) leg
					, a.contract_expiration_date
				    , ISNULL(a.fixed_float_leg, sddt.fixed_float_leg) fixed_float_leg
			        , ISNULL(a.buy_sell_flag, sddt.buy_sell_flag) buy_sell_flag
			       
					, a.fixed_price
					, CASE 
						WHEN a.fixed_price_currency_id IS NULL THEN NULL
						ELSE e.source_currency_id 
					  END
					, a.option_strike_price
					, abs(CAST(a.deal_volume AS NUMERIC(38,20)))
					, ISNULL(a.deal_volume_frequency, sddt.deal_volume_frequency) deal_volume_frequency
			                , ISNULL(t.source_uom_id, sddt.deal_volume_uom_id) source_uom_id
					, a.block_description
					, a.deal_detail_description
					, ''' + @user_login_id + '''
					, GETDATE(), sdg.source_deal_groups_id, 
					'	
				+ CASE WHEN @exec_mode = 12 THEN
						' ISNULL(t.source_curve_def_id, sddt.curve_id) source_curve_def_id
						,abs(a.[settlement_volume]),
						suom_set.source_uom_id [settlement_uom] , --suom_set
						a.[price_adder],
						ISNULL(a.[price_multiplier], 1) price_multiplier,
						a.[settlement_date],
						sdv_day.value_id [day_count_id],  --sdv_day
						ISNULL(sml.source_minor_location_id, sddt.location_id) [location_id], --select * from source_minor_location
					    mi.[meter_id] [meter_id],   -- select * from source_minor_location_meter
						ISNULL(a.[physical_financial_flag_detail], sddt.physical_financial_flag) physical_financial_flag_detail,
						a.[fixed_cost],
						a.[multiplier],
						sc_adder_currency_id.[source_currency_id],
						sc_fixed_cost_currency_id.[source_currency_id],
						sc_formula_currency_id.[source_currency_id],
						a.[price_adder2],
						sc_price_adder_currency2.[source_currency_id],
						a.[volume_multiplier2],
						ISNULL(a.[pay_opposite], sddt.pay_opposite) pay_opposite,
						a.[capacity],
						a.settlement_currency,		--	sc_settlement_currency.[source_currency_id],
						a.[standard_yearly_volume],
						a.price_uom_id,				--	su.[source_uom_id],
						a.category,					--	sdv_category.[value_id],
						a.profile_code,				--	sdv_profile_code.[value_id],
						a.pv_party,					--	sdv_pv_party.[value_id],
						fe.formula_id
						'
						WHEN @exec_mode = 6 THEN
						'CASE WHEN ISNULL(a.fixed_float_leg, sddt.fixed_float_leg) = ''T'' THEN NULL ELSE ISNULL(t.source_curve_def_id, sddt.curve_id) END source_curve_def_id ,
						CONVERT(DATETIME, a.[settlement_date], 103),
						CASE WHEN a.[physical_financial_flag] = ''f'' THEN NULL ELSE sml.source_minor_location_id END  [location_id],
						a.[physical_financial_flag]
						'
ELSE ''
					END +
					'
			FROM #temp_inserting_deal t
			INNER JOIN ' + @temp_table_name + ' a ON a.temp_id = t.temp_id
			INNER JOIN source_currency e ON e.source_system_id = a.source_system_id 
				AND e.currency_id = ISNULL(a.fixed_price_currency_id, e.currency_id) 
			INNER JOIN source_deal_header b ON a.deal_id = b.deal_id AND b.source_system_id=a.source_system_id 
			' 
			+ CASE WHEN @exec_mode = 12 THEN
					' LEFT JOIN static_data_value sdv_day on sdv_day.code=a.[day_count_id]
					LEFT JOIN source_uom suom_set ON suom_set.source_system_id = a.source_system_id 
						AND suom_set.uom_id = a.[settlement_uom]
					LEFT JOIN source_minor_location sml ON sml.source_system_id = a.source_system_id 
						AND  sml.Location_Name = a.[location_id]
					LEFT JOIN meter_id mi ON mi.recorderid= a.[meter_id]
					--LEFT JOIN source_uom su ON a.source_system_id = su.source_system_id
					--	AND a.[price_uom_id] = su.uom_id
					LEFT JOIN source_currency sc_adder_currency_id ON a.source_system_id = sc_adder_currency_id.source_system_id
						AND a.[adder_currency_id] = sc_adder_currency_id.currency_id	
					LEFT JOIN source_currency sc_fixed_cost_currency_id ON a.source_system_id = sc_fixed_cost_currency_id.source_system_id
						AND a.[fixed_cost_currency_id] = sc_fixed_cost_currency_id.currency_id
					LEFT JOIN source_currency sc_formula_currency_id ON a.source_system_id = sc_formula_currency_id.source_system_id
						AND a.[formula_currency_id] = sc_formula_currency_id.currency_id		
					LEFT JOIN source_currency sc_price_adder_currency2 ON a.source_system_id = sc_price_adder_currency2.source_system_id
						AND a.[price_adder_currency2] = sc_price_adder_currency2.currency_id	
					--LEFT JOIN source_currency sc_settlement_currency ON a.source_system_id = sc_settlement_currency .source_system_id
					--	AND a.[settlement_currency] = sc_settlement_currency.currency_id
					--LEFT JOIN static_data_value  sdv_category ON a.[category] = sdv_category.code
					--LEFT JOIN static_data_value  sdv_profile_code ON a.[profile_code] = sdv_profile_code.code
					--LEFT JOIN static_data_value  sdv_pv_party ON a.[pv_party] = sdv_pv_party.code
					LEFT JOIN  formula_editor fe ON fe.formula_id = a.formula_id 	
					left join source_deal_header_template sdht on sdht.template_id = b.template_id
					LEFT JOIN source_deal_detail_template sddt ON sdht.template_id = sddt.template_id
										'	
				   WHEN @exec_mode = 6 THEN
					' LEFT JOIN source_price_curve_def spcd ON spcd.curve_id = a.curve_id AND spcd.source_system_id = a.source_system_id
					  LEFT JOIN source_minor_location sml ON sml.source_system_id = a.source_system_id AND sml.Location_Name = spcd.[curve_name]
					  LEFT JOIN source_deal_header_template sdht on sdht.template_id = b.template_id
					  LEFT JOIN source_deal_detail_template sddt ON sdht.template_id = sddt.template_id'

ELSE ''
				END
				+ ' INNER JOIN source_deal_groups sdg ON sdg.source_deal_header_id = b.source_deal_header_id AND sdg.leg = ISNULL(a.Leg, sddt.leg)'
			  
--INNER JOIN source_uom d ON a.source_system_id = d.source_system_id AND a.deal_volume_uom_id = d.uom_id 
--			LEFT JOIN source_price_curve_def c ON a.source_system_id = c.source_system_id 
--				AND c.curve_id = a.curve_id
	
	EXEC spa_print @sql1
	EXEC(@sql1)
				
	exec spa_print 'Inserting error free deal details. Process took ' --+ dbo.FNACalculateTimestamp(@deal_detail_insert_ts)
	--DROP temp table
	IF OBJECT_ID('tempdb..#temp_inserting_deal') IS NOT NULL
		DROP TABLE #temp_inserting_deal		
	
	exec spa_print 'Source Deal Detail INSERT COMPLETED. Process took ' --+ dbo.FNACalculateTimestamp(@deal_detail_insert_batch_ts)
	
	DECLARE @after_insert_process_table VARCHAR(300), @user_name VARCHAR(100) = dbo.FNADBUser(), @job_process_id VARCHAR(200) = dbo.FNAGETNEWID()
	SET @after_insert_process_table = dbo.FNAProcessTableName('after_insert_process_table', @user_name, @job_process_id)
			
	--PRINT @after_insert_process_table
	IF OBJECT_ID(@after_insert_process_table) IS NOT NULL
	BEGIN
		EXEC('DROP TABLE ' + @after_insert_process_table)
	END
				
	EXEC ('CREATE TABLE ' + @after_insert_process_table + '(source_deal_header_id INT)')

	SET @sql = 'INSERT INTO ' + @after_insert_process_table + '(source_deal_header_id) 
				SELECT source_deal_header_id FROM ' + @temp_table_name + ' a
				INNER JOIN source_deal_header sdh ON sdh.deal_id = a.deal_id'
	EXEC(@sql)
			
	SET @sql = 'spa_deal_insert_update_jobs ''i'', ''' + @after_insert_process_table + ''''
	SET @job_name = 'spa_deal_insert_update_jobs_' + @job_process_id
 		
	EXEC spa_run_sp_as_job @job_name, @sql, 'spa_deal_insert_update_jobs', @user_name

	--drop table #temp_deal_header


END
IF CHARINDEX('4018',@table_id,1)<>0	--tagging update
BEGIN
EXEC('delete '+@field_compare_table)
	SET @tablename=(SELECT code FROM static_data_value WHERE value_id=4018)

		SET @source_table=@temp_table_name
		EXEC('delete from '+@temp_table_name+' where deal_id is null')
		EXEC (' insert into #temp_tot_count select count(*) as totcount,'''+ @tablename+'''  from '+@temp_table_name)
		
--Data Import************************************************************************************8
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for Deal Id :''+ isnull(a.deal_id,''NULL'')+'', Tag1:''+isnull(a.source_system_book_id1,''NULL'')+
			'', Tag2 :''+ isnull(a.source_system_book_id2,''NULL'')+'', Tag3: ''+isnull(a.source_system_book_id3,''NULL'')+'', 
			 Tag4: ''+isnull(a.source_system_book_id4,''NULL'')+'' not found'',
			''Please check your data'',''Deal Id not found'',a.deal_id 
			from '+@temp_table_name + ' a left outer join source_deal_header sdh 
			on a.deal_id=sdh.deal_id	and a.source_system_id = sdh.source_system_id		
			where sdh.deal_id is  null')

EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Must define the comments to update Tagging, Deal Id :''+ isnull(a.deal_id,''NULL'')+'', Tag1:''+isnull(a.source_system_book_id1,''NULL'')+
			'', Tag2 :''+ isnull(a.source_system_book_id2,''NULL'')+'', Tag3: ''+isnull(a.source_system_book_id3,''NULL'')+'', 
			 Tag4: ''+isnull(a.source_system_book_id4,''NULL'')+'''',
			''Please check your data'',''Comment Empty'',a.deal_id 
			from '+@temp_table_name + ' a where user_comment is  null')
	
EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
		 select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for id :''+a.deal_id +''. (Foreign Key Tag1 ''+ISNULL(a.source_system_book_id1,''NULL'')+'' is not found)'',
			''Please check your data'',''Tag1 ''+ isnull(a.source_system_book_id1,''NULL'') + '' not found'',a.deal_id 
			from '+@temp_table_name + ' a 
			left join source_book b on b.source_system_book_id=a.source_system_book_id1 and
			b.source_system_id=a.source_system_id and b.source_system_book_type_value_id=50  where b.source_system_book_id is null')
	EXEC spa_print '8e'	

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
			 select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for id :''+a.deal_id +''. (Foreign Key Tag2 ''+ISNULL(a.source_system_book_id2,''NULL'')+'' is not found)'',
			''Please check your data'' ,''Tag2 ''+ isnull(a.source_system_book_id2,''NULL'') + '' not found'',a.deal_id
			from '+@temp_table_name + ' a 
			left join source_book b on b.source_system_book_id=a.source_system_book_id2 and
			b.source_system_id=a.source_system_id and b.source_system_book_type_value_id=51 where b.source_system_book_id is null and a.source_system_book_id2 is not null')
	
	EXEC spa_print '8f'	

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
		 select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for id :''+a.deal_id +''. (Foreign Key Tag3 ''+ISNULL(a.source_system_book_id3,''NULL'')+'' is not found)'',
			''Please check your data'' ,''Tag3 ''+ isnull(a.source_system_book_id3,''NULL'') + '' not found'',a.deal_id
			from '+@temp_table_name + ' a left join source_book b on b.source_system_book_id=a.source_system_book_id3 and
			b.source_system_id=a.source_system_id and b.source_system_book_type_value_id=52 where b.source_system_book_id is null and a.source_system_book_id3 is not null')
	EXEC spa_print '8g'	

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
		 select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for id :''+a.deal_id +''. (Foreign Key Tag4 ''+ISNULL(a.source_system_book_id4,''NULL'')+'' is not found)'',
			''Please check your data'' ,''Tag4 ''+ isnull(a.source_system_book_id4,''NULL'') + '' not found'',a.deal_id
			from '+@temp_table_name + ' a left join source_book b on b.source_system_book_id=a.source_system_book_id4 and
			b.source_system_id=a.source_system_id and b.source_system_book_type_value_id=53  where b.source_system_book_id is null and a.source_system_book_id4 is not null')
	EXEC spa_print '8h'	
	
	EXEC('delete '+@temp_table_name + ' from #import_status inner join '+@temp_table_name + ' a on
		#import_status.temp_id=a.temp_id')


SET @sql=' insert deal_tagging_audit(source_deal_header_id,source_system_book_id1,source_system_book_id2,
source_system_book_id3,source_system_book_id4,change_reason)
select sdh.source_deal_header_id, sdh.source_system_book_id1,
                    sdh.source_system_book_id2,
                    sdh.source_system_book_id3,
                    sdh.source_system_book_id4,t.user_comment
from source_deal_header sdh 
join '+@temp_table_name+' t on sdh.deal_id=t.deal_id and sdh.source_system_id=t.source_system_id'

EXEC spa_print @sql
EXEC(@sql)

	SET @sql=' update source_deal_header
set source_system_book_id1=p.book1,
source_system_book_id2=p.book2,
source_system_book_id3=p.book3,
source_system_book_id4=p.book4
from source_deal_header h, (
select b1.source_book_id book1,b2.source_book_id book2,b3.source_book_id book3,b4.source_book_id book4,t.deal_id ,t.source_system_id
from '+@temp_table_name+' t 
join source_book b1 on t.source_system_book_id1=b1.source_system_book_id and b1.source_system_id=t.source_system_id 
and b1.source_system_book_type_value_id=50
join source_book b2 on t.source_system_book_id2=b2.source_system_book_id and b2.source_system_id=t.source_system_id  
and b2.source_system_book_type_value_id=51
join source_book b3 on t.source_system_book_id3=b3.source_system_book_id and b3.source_system_id=t.source_system_id  
and b3.source_system_book_type_value_id=52
join source_book b4 on t.source_system_book_id4=b4.source_system_book_id and b4.source_system_id=t.source_system_id 
and b4.source_system_book_type_value_id=53) p 
where h.deal_id=p.deal_id and p.source_system_id = h.source_system_id'
EXEC spa_print @sql
EXEC(@sql)

--set @sql=' insert deal_tagging_audit(source_deal_header_id,source_system_book_id1,source_system_book_id2,
--source_system_book_id3,source_system_book_id4,change_reason)
--select sdh.source_deal_header_id,book1,book2,book3,book4,user_comment
--from source_deal_header sdh join
--(select b1.source_book_id book1,b2.source_book_id book2,b3.source_book_id book3,
--b4.source_book_id book4,t.deal_id,t.user_comment 
--from '+@temp_table_name+' t 
--join source_book b1 on t.source_system_book_id1=b1.source_system_book_id and b1.source_system_id=t.source_system_id 
--and b1.source_system_book_type_value_id=50
--join source_book b2 on t.source_system_book_id2=b2.source_system_book_id and b2.source_system_id=t.source_system_id  
--and b2.source_system_book_type_value_id=51
--join source_book b3 on t.source_system_book_id3=b3.source_system_book_id and b3.source_system_id=t.source_system_id  
--and b3.source_system_book_type_value_id=52
--join source_book b4 on t.source_system_book_id4=b4.source_system_book_id and b4.source_system_id=t.source_system_id 
--and b4.source_system_book_type_value_id=53) p 
--on  sdh.deal_id=p.deal_id '


END


IF CHARINDEX('4034',@table_id,1)<>0	--cum_pnl_series
BEGIN
	EXEC('delete '+@field_compare_table)
	SET @tablename=(SELECT code FROM static_data_value WHERE value_id=4034)
--	if @schedule_run='n'
--	begin
		EXEC('insert into '+@field_compare_table+ ' values (''cum_pnl_series'',''as_of_date'',''as_of_date'')')
		EXEC('insert into '+@field_compare_table+ ' values (''cum_pnl_series'',''link_id'',''link_id'')')
		EXEC('insert into '+@field_compare_table+ ' values (''cum_pnl_series'',''u_h_mtm'',''u_h_mtm'')')
		EXEC('insert into '+@field_compare_table+ ' values (''cum_pnl_series'',''u_i_mtm'',''u_i_mtm'')')
--		exec('insert into '+@field_compare_table+ ' values (''cum_pnl_series'',''d_h_mtm'',''d_h_mtm'')')
--		exec('insert into '+@field_compare_table+ ' values (''cum_pnl_series'',''d_i_mtm'',''d_i_mtm'')')
--		exec('insert into '+@field_compare_table+ ' values (''cum_pnl_series'',''cum_pnl_series_id'',''cum_pnl_series_id'')')
		EXEC('insert into '+@field_compare_table+ ' values (''cum_pnl_series'',''comments'',''comments'')')
	--	exec('insert into '+@field_compare_table+ ' values (''source_deal_type'',''sub_type'',''sub_type'')')

		--Pre validataing Data Type
		SET @source_table=@temp_table_name
		EXEC('delete from '+@temp_table_name+' where as_of_date is null and link_id is null and u_h_mtm is null and
		u_i_mtm is null and d_h_mtm is null and d_i_mtm is null and comments is null' )
		
		EXEC (' insert into #temp_tot_count select count(*) as totcount,'''+ @tablename+'''  from '+@temp_table_name)
		EXEC sp_validate_data_type @process_id,@field_compare_table,@source_table
--	end

---Data Import **************************************************************************8

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data error for link_id :''+ isnull(cast(a.link_id as varchar),''NULL'')+''; as_of_date: ''+ dbo.fnadateformat(a.as_of_date) + '' (Data Repetition Error, No of times:''+ cast(b.notimes as varchar)+'' )'',''Please check your data'' 
			from '+@temp_table_name + ' a inner join (select link_id,as_of_date,count(*) notimes from '+ @temp_table_name+'
			 group by link_id,as_of_date having count(*)>1) b 
			on a.link_id=b.link_id and a.as_of_date = b.as_of_date')
			
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data error for u_h_mtm :''+ isnull(cast(a.u_h_mtm as varchar),''NULL'')+''; as_of_date: ''+ dbo.fnadateformat(a.as_of_date) + '' (Data Repetition Error, No of times:''+ cast(b.notimes as varchar)+'' )'',''Please check your data'' 
			from '+@temp_table_name + ' a inner join (select link_id,as_of_date,count(*) notimes from '+ @temp_table_name+'
			 group by link_id,as_of_date having count(*)>1) b 
			on a.link_id=b.link_id and a.as_of_date = b.as_of_date')

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
		 select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
				''Data error for link_id :''+ cast(a.link_id as varchar) +''. (Foreign Key Link ID ''+ISNULL(cast(a.link_id as varchar),''NULL'')+'' and as_of_date:'' + dbo.fnadateformat(a.as_of_date)+ '' is not found)'',
				''Please check your data'',''Link ID ''+ isnull(Cast(a.link_id as varchar),''NULL'') + '' not found'',a.link_id
		from '+@temp_table_name + ' a 
		left join #import_status on a.temp_id=#import_status.temp_id
		left join fas_link_header b on b.link_id=a.link_id 
		where  b.link_id is null')

	EXEC('delete '+@temp_table_name + ' from #import_status inner join '+@temp_table_name + ' a on
		#import_status.temp_id=a.temp_id')

	SET @sql = 
	    'DELETE cum_pnl_series
				FROM   cum_pnl_series cps
				INNER JOIN ' + @temp_table_name + 
	    ' a ON cps.link_id = a.link_id AND cps.as_of_date = a.as_of_date
	      '    

	SET @sql1 = 
	    'INSERT INTO cum_pnl_series
	             (
	               as_of_date,
	               link_id,
	               u_h_mtm,
	               u_i_mtm,
	               d_h_mtm,
	               d_i_mtm,
	               create_user,
	               create_ts,
	               comments
	             )
 			SELECT as_of_date,
 			       link_id,
 			       u_h_mtm,
 			       u_i_mtm,
 			       ISNULL(d_h_mtm, u_h_mtm),
 			       ISNULL(d_i_mtm, u_i_mtm),
 			       '''+@user_login_id+''',
 			       GETDATE(),
 			       comments
 			FROM   ' + @temp_table_name
	
	exec spa_print @sql
	EXEC(@sql)
	exec spa_print @sql1
	EXEC(@sql1)
END


IF CHARINDEX('4006',@table_id,1)<>0	--source_deal_pnl
BEGIN
	EXEC spa_print 'Start MTM: --'--+CONVERT(VARCHAR,GETDATE(),109)

	--index creation of optimization
	DECLARE @pnl_index_name		VARCHAR(128)
	SET @pnl_index_name = '[IX_AP_sourceDealPnl_'+@process_id +']'
	
--	EXEC('IF EXISTS (SELECT * FROM adiha_process.sys.indexes i
--			INNER JOIN adiha_process.sys.objects o ON i.object_id = o.object_id
--			WHERE o.type = ''U'' AND ''adiha_process.dbo.'' + o.name = ''' + @temp_table_name + '''
--			AND i.name = N''' + @pnl_index_name + ''')
--			DROP INDEX ' + @pnl_index_name + ' ON ' + @temp_table_name)
		EXEC('CREATE INDEX ' + @pnl_index_name + ' ON ' + @temp_table_name + '(source_deal_header_id, term_start, term_end, leg, pnl_as_of_date)') 
	
	IF @exec_mode = 6 
	BEGIN
		EXEC(' INSERT INTO #temp_tot_count SELECT COUNT(*) AS totcount, '''+ @tablename+'''  FROM ' + @temp_table_name )
  
		EXEC('INSERT INTO #total_deals_proceed (tot_deals) 
		SELECT COUNT(*) FROM ( SELECT COUNT(*) tot FROM '+@temp_table_name +' GROUP BY source_deal_header_id ) t ')

		EXEC('INSERT INTO #vol_check1
		SELECT SUM(CASE WHEN ISNULL(source.[und_pnl],'''')='''' THEN 0 ELSE CAST(source.[und_pnl] AS FLOAT) END) 
					,0
					,0
		FROM ' + @temp_table_name +' source ')

		-- settle data is not imported
		EXEC('DELETE t FROM ' + @temp_table_name + ' t WHERE CONVERT(DATETIME, t.[term_end], 120) <= CONVERT(DATETIME, '''+ @import_as_of_date  +''', 120)')
	END
	

	--exec('delete '+@field_compare_table)
	SET @tablename=(SELECT code FROM static_data_value WHERE value_id=4006)
	
--	if @schedule_run='n'
--	begin
		IF @exec_mode <> 6
			EXEC('INSERT INTO #vol_check1
			select sum(case when isnull(source.[und_pnl],'''')='''' then 0 else cast(source.[und_pnl] as float) end) 
						,0
						,0
			from ' + @temp_table_name +' source ')


		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_header'',''deal_id'',''source_deal_header_id'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_pnl'',''term_start'',''term_start'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_pnl'',''term_end'',''term_end'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_pnl'',''Leg'',''Leg'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_pnl'',''pnl_as_of_date'',''pnl_as_of_date'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_pnl'',''und_pnl'',''und_pnl'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_pnl'',''und_intrinsic_pnl'',''und_intrinsic_pnl'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_pnl'',''und_extrinsic_pnl'',''und_extrinsic_pnl'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_pnl'',''pnl_source_value_id'',''pnl_source_value_id'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_pnl'',''pnl_conversion_factor'',''pnl_conversion_factor'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_pnl'',''deal_volume'',''deal_volume'')')
--		exec('insert into '+@field_compare_table+ ' values (''source_deal_pnl'',''contract_value'',''contract_value'')')

		CREATE TABLE #tmp_erroneous_deal_pnl 
		(
			deal_id				VARCHAR(200) COLLATE DATABASE_DEFAULT NOT NULL,
			error_type_code		VARCHAR(100) COLLATE DATABASE_DEFAULT NOT NULL,
			error_description	VARCHAR(500) COLLATE DATABASE_DEFAULT
		)

		--Pre validataing Data Type
		SET @source_table=@temp_table_name
		EXEC('delete from ' + @temp_table_name + 
		' OUTPUT DELETED.source_deal_header_id, ''INVALID_DATA_FORMAT'', ''Null values'' INTO #tmp_erroneous_deal_pnl 
		where source_deal_header_id is null and term_start is null and term_end is null and
		Leg is null and pnl_as_of_date is null and und_pnl is null and und_intrinsic_pnl is null and und_extrinsic_pnl is null
		and dis_pnl is null and dis_intrinsic_pnl is null and dis_extrinisic_pnl is null and pnl_source_value_id is null
		and pnl_currency_id is null and pnl_conversion_factor is null and deal_volume is null' )


		IF @exec_mode <> 6 
		BEGIN
		--delete those deals that can produce Data Repetition Error but make sure they are not embedded
			-- deletion from temp table is ignored for RWE DE due to performance issue
		SET @sql = 'DELETE ' + @temp_table_name + ' 
					--SELECT * 
					FROM ' + @temp_table_name + ' t
					LEFT JOIN source_deal_header sdh ON t.source_deal_header_id = sdh.deal_id and t.source_system_id = sdh.source_system_id
					LEFT JOIN embedded_deal e ON e.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN (
						--get deal deals that will product Data Repetition Error
						SELECT MAX(temp_id) temp_id, source_deal_header_id, term_start, term_end, leg, pnl_as_of_date
						FROM ' + @temp_table_name + '
						GROUP BY source_deal_header_id, term_start, term_end, leg, pnl_as_of_date 
						HAVING COUNT(*) > 1 
					) d ON t.source_deal_header_id = d.source_deal_header_id 
						AND CAST(CAST(t.pnl_as_of_date AS datetime) AS int) = CAST(CAST(d.pnl_as_of_date AS datetime) AS int)
						AND CAST(CAST(t.term_start AS datetime) AS int) = CAST(CAST(d.term_start AS datetime) AS int)
						AND CAST(CAST(t.term_end AS datetime) as int) = CAST(CAST(d.term_end AS datetime) AS int) AND t.leg = d.leg
						AND t.temp_id <> d.temp_id  --delete all duplicate rows except one [MAX(temp_id)]
					WHERE e.embedded_deal_id IS NULL'
		exec spa_print 'Delete deal detail pnl that can produce Data Repetition Error ', @sql
		EXEC(@sql)
		
		EXEC (' insert into #temp_tot_count select count(*) as totcount,'''+ @tablename+'''  from '+@temp_table_name)
  
		 EXEC('INSERT INTO #total_deals_proceed (tot_deals) 
		select count(*) from ( SELECT count(*) tot FROM '+@temp_table_name +' group by source_deal_header_id ) t ')
		END
	--TODO: Refactoring, instead of creating temp table, use EXISTS(..... HAVING COUNT(*) > 1)
	CREATE TABLE #check_pnl(pnl_as_of_date DATETIME)
	EXEC('insert into #check_pnl(pnl_as_of_date)
		 select  cast(pnl_as_of_date as datetime)  from ' + @temp_table_name + ' a group by cast(pnl_as_of_date as datetime)')
	DECLARE @count_pnl INT
	SELECT @count_pnl=COUNT(*) FROM #check_pnl

	IF @count_pnl>1 
	BEGIN
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error)
		 select 1,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			'' PNL As of Date :''+isnull(a.pnl_as_of_date,''NULL'')+'''',
			''Multiple PNL Date not allowed'' ,''Multiple PNL Date not allowed''
			from '+@temp_table_name + ' a group by a.pnl_as_of_date')
		EXEC('delete '+ @temp_table_name)
		GOTO FinalStep
	END
	DROP TABLE #check_pnl
	EXEC spa_print '#############Anoop########'	

	EXEC spa_print '#######Check Validation MTM: '--+CONVERT(VARCHAR,GETDATE(),109)	
	IF ISNULL(@exec_mode,0)<> 1
		EXEC sp_validate_data_type @process_id,@field_compare_table,@source_table
	
	EXEC spa_print '#######End Validation MTM: '--+CONVERT(VARCHAR,GETDATE(),109)	
	--Data Import ***************************************************************************************
	--source_deal_header_id,term_start,term_end,Leg,pnl_as_of_date''
	EXEC spa_print '1'
	
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
			OUTPUT INSERTED.external_type_id, ''DATA_REPETITION'', INSERTED.type_error INTO #tmp_erroneous_deal_pnl
			select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data error for source_deal_header_id :''+ isnull(a.source_deal_header_id,''NULL'')+'', term_start:''+isnull(a.term_start,''NULL'')+
			'', term_end :''+ isnull(a.term_end,''NULL'')+'', Leg:''+isnull(a.Leg,''NULL'')+
			'', pnl_as_of_date :''+isnull(a.pnl_as_of_date,''NULL'')+'' (Data Repetition Error, No of times:''+ cast(b.notimes as varchar)+'' )'',
			''Please check your data'' ,''Data Repetition Error'',a.source_deal_header_id
			from '+@temp_table_name + ' a inner join (select source_deal_header_id,term_start,term_end,Leg,pnl_as_of_date,count(*) notimes from '+ @temp_table_name+'
			 group by source_deal_header_id,term_start,term_end,Leg,pnl_as_of_date having count(*)>1) b 
			on a.source_deal_header_id=b.source_deal_header_id and cast(CAST(a.pnl_as_of_date as datetime) as int)=cast(CAST(b.pnl_as_of_date as datetime) as int)
			 and cast(CAST(a.term_start as datetime) as int)=cast(CAST(b.term_start as datetime) as int)
			and cast(CAST(a.term_end as datetime) as int)=cast(CAST(b.term_end as datetime) as int) and a.Leg=b.Leg')

	EXEC spa_print '#######End Replitation MTM: '--+CONVERT(VARCHAR,GETDATE(),109)

	EXEC spa_print '2'

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
			OUTPUT INSERTED.external_type_id, ''INVALID_DATA_FORMAT'', INSERTED.type_error INTO #tmp_erroneous_deal_pnl
			select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_deal_header_id :''+ isnull(a.source_deal_header_id,''NULL'')+'', term_start:''+isnull(a.term_start,''NULL'')+
			'', term_end :''+ isnull(a.term_end,''NULL'')+'', Leg:''+isnull(a.Leg,''NULL'')+
			'', pnl_as_of_date :''+isnull(a.pnl_as_of_date,''NULL'')+'',deal_volume:''+isnull(a.deal_volume,''NULL'')+''. It is possible that the data format may be incorrect'',
			''Please check your data'' ,''Invalid Format'',a.source_deal_header_id
			from '+@temp_table_name + ' a where isdate(a.term_start)=0 or isdate(a.term_end)=0 
			or isdate(a.pnl_as_of_date)=0 or isnumeric(a.und_pnl)=0 or isnumeric(a.und_intrinsic_pnl)=0		
			or isnumeric(a.und_extrinsic_pnl)=0 or isnumeric(a.dis_pnl)=0 or isnumeric(a.dis_intrinsic_pnl)=0
			or isnumeric(a.dis_extrinisic_pnl)=0 or isnumeric(a.pnl_source_value_id)=0
			or isnumeric(a.pnl_conversion_factor)=0 or isnumeric(a.deal_volume)=0')
	
	EXEC spa_print '3'
	--checking deal existing in source_deal_header

	IF @exec_mode = 1
	BEGIN
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
				OUTPUT INSERTED.external_type_id, ''MISSING_DEAL'', INSERTED.type_error INTO #tmp_erroneous_deal_pnl
			select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
				''Data error for source_deal_header_id :''+ isnull(a.source_deal_header_id,''NULL'')+'', 
				term_start:''+isnull(dbo.FNADateFormat(a.term_start),''NULL'')+
				'', term_end :''+ isnull(dbo.FNADateFormat(a.term_end),''NULL'')+'', Leg:''+isnull(a.Leg,''NULL'')+
				'', pnl_as_of_date :''+isnull(dbo.FNADateFormat(a.pnl_as_of_date),''NULL'')+'',deal_volume:''+isnull(a.deal_volume,''NULL'')+''. (Foreign Key source_deal_header_id ''+ISNULL(a.source_deal_header_id,''NULL'')+'' is not found)'',
				''Please check your data'' ,''Deal Id not found'',a.source_deal_header_id
				from '+@temp_table_name + ' a 
				left join source_deal_header b
				on b.deal_id=a.source_deal_header_id and b.source_system_id=a.source_system_id where b.deal_id is null')

		exec spa_print 'insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id
			 select a.temp_id,''', @process_id,''',''Error'',''Import Data'',''',@tablename,''',''Data Error'',
				''Data error for source_deal_header_id :''+ isnull(a.source_deal_header_id,''NULL'')+'', 
				term_start:''+isnull(dbo.FNADateFormat(a.term_start),''NULL'')+
				'', term_end :''+ isnull(dbo.FNADateFormat(a.term_end),''NULL'')+'', Leg:''+isnull(a.Leg,''NULL'')+
				'', pnl_as_of_date :''+isnull(dbo.FNADateFormat(a.pnl_as_of_date),''NULL'')+'',deal_volume:''+isnull(a.deal_volume,''NULL'')+''. (Foreign Key source_deal_header_id ''+ISNULL(a.source_deal_header_id,''NULL'')+'' is not found)'',
				''Please check your data'' ,''Deal Id not found'',a.source_deal_header_id
				from ', @temp_table_name, ' a 
				left join source_deal_header b
				on b.deal_id=a.source_deal_header_id  and b.source_system_id=a.source_system_id where b.deal_id is null'
	END
	ELSE
	BEGIN  
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
			 OUTPUT INSERTED.external_type_id, ''MISSING_DEAL'', INSERTED.type_error INTO #tmp_erroneous_deal_pnl
			 select a.temp_id,'''+ @process_id+''',''Warning'',''Import Data'','''+@tablename+''',''Data Warning'',
				''Data Warning for source_deal_header_id :''+ isnull(a.source_deal_header_id,''NULL'')+'', term_start:''+isnull(a.term_start,''NULL'')+
				'', term_end :''+ isnull(a.term_end,''NULL'')+'', Leg:''+isnull(a.Leg,''NULL'')+
				'', pnl_as_of_date :''+isnull(a.pnl_as_of_date,''NULL'')+'',deal_volume:''+isnull(a.deal_volume,''NULL'')+''. (Foreign Key source_deal_header_id ''+ISNULL(a.source_deal_header_id,''NULL'')+'' is not found)'',
				''Please check your data'' ,''Deal Id not found'',a.source_deal_header_id
				from '+@temp_table_name + ' a 
				left join source_deal_header b
				on b.deal_id=a.source_deal_header_id and b.source_system_id=a.source_system_id where b.deal_id is null')
	END
	EXEC spa_print '#######End existing in source_deal_header MTM: '--+CONVERT(VARCHAR,GETDATE(),109)	

--checking with source_deal_detail
--	exec('insert into #import_status select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
--			''Data error for source_deal_header_id :''+ isnull(a.source_deal_header_id,''NULL'')+'', term_start:''+isnull(a.term_start,''NULL'')+
--			'', term_end :''+ isnull(a.term_end,''NULL'')+'', Leg:''+isnull(a.Leg,''NULL'')+
--			'', pnl_as_of_date :''+isnull(a.pnl_as_of_date,''NULL'')+'',deal_volume:''+isnull(a.deal_volume,''NULL'')+''. (Foreign Key source_deal_header_id ''+a.source_deal_header_id+'' is not found)'',
--			''Please check your data'' 
--			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
--			left join (
--				select sdh.source_system_id,sdh.deal_id,sdd.term_start,sdd.term_end,sdd.leg from source_deal_header sdh inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
--				) b
--			 on b.deal_id=a.source_deal_header_id and cast(CAST(a.term_start as datetime) as int)=cast(CAST(b.term_start as datetime) as int) and cast(CAST(a.term_end as datetime) as int)=cast(CAST(b.term_end as datetime) as int) and a.leg=b.leg and 
--			b.source_system_id=a.source_system_id where #import_status.temp_id is null
--		 and b.deal_id is null')

	EXEC spa_print '4'

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
		OUTPUT INSERTED.external_type_id, ''MISSING_STATIC_DATA'', INSERTED.type_error INTO #tmp_erroneous_deal_pnl
		 select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for source_deal_header_id :''+ isnull(a.source_deal_header_id,''NULL'')+'', term_start:''+isnull(a.term_start,''NULL'')+
			'', term_end :''+ isnull(a.term_end,''NULL'')+'', Leg:''+isnull(a.Leg,''NULL'')+
			'', pnl_as_of_date :''+isnull(a.pnl_as_of_date,''NULL'')+'',deal_volume:''+isnull(a.deal_volume,''NULL'')+''. (Foreign Key pnl_currency_id ''+ISNULL(a.pnl_currency_id,''NULL'')+'' is not found)'',
			''Please check your data'',''Currency ID ''+ ISNULL(a.pnl_currency_id,''NULL'')+'' is not found '',a.source_deal_header_id
			from '+@temp_table_name + ' a left join source_currency b on b.currency_id=a.pnl_currency_id and
			b.source_system_id=a.source_system_id where b.currency_id is null')
	
	EXEC spa_print '5'
	IF ISNULL(@exec_mode,0) <> 1
	BEGIN
		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep,type_error,external_type_id)
				OUTPUT INSERTED.external_type_id, ''INVALID_DATA_FORMAT'', INSERTED.type_error INTO #tmp_erroneous_deal_pnl
			 select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
				''Data error for source_deal_header_id :''+ isnull(a.source_deal_header_id,''NULL'')+'', term_start:''+isnull(a.term_start,''NULL'')+
				'', term_end :''+ isnull(a.term_end,''NULL'')+'', Leg:''+isnull(a.Leg,''NULL'')+
				'', pnl_as_of_date :''+isnull(a.pnl_as_of_date,''NULL'')+'',deal_volume:''+isnull(a.deal_volume,''NULL'')+''.( Invalid data for pnl_source_value_id: ''+a.pnl_source_value_id+'' or source_system_id ''+a.source_system_id+'').'',
				''Please check your data'' ,''PNL Source value id ''+ a.pnl_source_value_id +'' invalid'',a.source_deal_header_id
				from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
				left join static_data_value b on b.value_id=a.pnl_source_value_id and
				b.type_id=775 where #import_status.temp_id is null and b.value_id is null')
	END

	--save all erroneous deals	
	exec spa_print 'Saving erroneous deals (4006) to table for process_id:', @process_id, ' STARTED.'
	DECLARE @pnl_default_error_type_id	INT

	SET @source = 'PNL'
	SET @start_ts = GETDATE()

	SELECT @pnl_default_error_type_id = error_type_id FROM source_deal_error_types WHERE error_type_code = 'MISC'
		
	INSERT INTO source_deal_error_log(as_of_date, deal_id, source, error_type_id, error_description)
	SELECT @import_as_of_date, deal_id, @source, ISNULL(e.error_type_id, @pnl_default_error_type_id), MAX(error_description)
	FROM #tmp_erroneous_deal_pnl d
	LEFT JOIN source_deal_error_types e ON d.error_type_code = e.error_type_code
	GROUP BY deal_id, e.error_type_id

	--SELECT * FROM source_deal_error_log
	exec spa_print 'Saving erroneous deals (4006) to table for process_id:', @process_id, ' FINISHED. Process took '-- + dbo.FNACalculateTimestamp(@start_ts)
	
	DECLARE @pnl_as_of_date_mtm VARCHAR(20)
	CREATE TABLE #temp_source_data_mtm(source_system_id VARCHAR(20) COLLATE DATABASE_DEFAULT, as_of_date VARCHAR(20) COLLATE DATABASE_DEFAULT)
	EXEC('insert #temp_source_data_mtm(source_system_id,as_of_date) 
	select max(source_system_id),max(pnl_as_of_date) from '+@temp_table_name)

	SELECT @source_system_desc_id=source_system_id,@pnl_as_of_date_mtm=as_of_date FROM #temp_source_data_mtm
	EXEC spa_print '######## source_system_desc_id ####:', @source_system_desc_id
	DROP TABLE #temp_source_data_mtm

	EXEC spa_print 'delete'
	EXEC('delete '+@temp_table_name + ' from #import_status inner join '+@temp_table_name + ' a on
		#import_status.temp_id=a.temp_id')
	EXEC('DELETE ' + @temp_table_name + ' FROM ' + @temp_table_name + ' tmp 
			INNER JOIN #import_status st ON tmp.source_deal_header_id =  st.external_type_id')
	--exec('delete '+@temp_table_name + ' where source_deal_header_id in (select external_type_id from #import_status)')
	
	--EXEC('INSERT INTO #vol_check1
	--	select sum(case when isnull(source.[und_pnl],'''')='''' then 0 else cast(source.[und_pnl] as float) end) 
	--				,0
	--				,0
	--	from ' + @temp_table_name +' source ')
	
IF @exec_mode = 1 --Used for Essent ONLY
BEGIN
	IF @error_log_table_name='formate2' 
	BEGIN	
		EXEC spa_print 'Delete the Existing Error '--+CONVERT(VARCHAR,GETDATE(),109)	
--		if @schedule_run='y'
--		delete [ssis_mtm_formate2_error_log] where deal_num in (select external_type_id from #import_status)

		EXEC spa_print  'Delete the Solved Error from Log' --+ CONVERT(VARCHAR,GETDATE(),109)
		--this is wrong as it deletes errors catched on 4005 case too
		--previous 1
		--exec('DELETE [ssis_mtm_formate2_error_log] FROM [ssis_mtm_formate2_error_log] err
		--		INNER JOIN ' + @temp_table_name + ' tmp ON err.deal_num = tmp.source_deal_header_id')
		--exec('delete [ssis_mtm_formate2_error_log] where deal_num in (select source_deal_header_id from '+@temp_table_name + ')')
			
		--delete only deal related (4005, 4006) error-free deals
		SET @start_ts = GETDATE()
		DELETE ssis_mtm_formate2_error_log 
		FROM ssis_mtm_formate2_error_log m
		LEFT JOIN source_deal_error_log e ON e.deal_id = m.deal_num 
			AND e.as_of_date = @pnl_as_of_date_mtm
			AND e.source NOT IN ('Position', 'Agreement')
		WHERE e.id IS NULL
		exec spa_print 'Deleted error-free deals from ssis_mtm_formate2_error_log. Process took '-- + dbo.FNACalculateTimestamp(@start_ts)
		
		/*
			load erroneous deals in ssis_mtm_formate2_error_log only when loading from RDB
			because when loading from stating table, we already have alll erroroneous deals
			in ssis_mtm_formate2_error_log, so no need to insert them again
		*/
		IF @schedule_run <> 'n'
		BEGIN		
			--inserts erroroneous deals from 4006
			--we need to insert only those deals having missing static data which are present in #import_status but not in ssis_mtm_formate2_error_log
			--pick out missing static data deals
			SET @start_ts = GETDATE()
			CREATE TABLE #tmp_deleted_pnl_deals ( deal_id	VARCHAR(250) COLLATE DATABASE_DEFAULT)

			INSERT INTO #tmp_deleted_pnl_deals (deal_id)
			SELECT DISTINCT external_type_id --distinct is mandatory here, to avoid insertion of muliple deals later
			FROM #import_status s
			INNER JOIN source_deal_error_log e ON e.deal_id = s.external_type_id
			INNER JOIN source_deal_error_types t ON e.error_type_id = t.error_type_id
			WHERE e.as_of_date = @pnl_as_of_date_mtm
				AND e.source IN ('PNL') AND t.error_type_code = 'MISSING_STATIC_DATA'
			exec spa_print 'Inserted 4006 error deals in #tmp_deleted_deals. Process took ' --+ dbo.FNACalculateTimestamp(@start_ts)

			SET @start_ts = GETDATE()
			DELETE ssis_mtm_formate2_error_log 
			FROM ssis_mtm_formate2_error_log err
			INNER JOIN #tmp_deleted_pnl_deals st ON err.deal_num = st.deal_id	
			exec spa_print 'Deleted 4006 errors from ssis_mtm_formate2_error_log. Process took ' --+ dbo.FNACalculateTimestamp(@start_ts)

			SET @start_ts = GETDATE()
			INSERT INTO [ssis_mtm_formate2_error_log]
			   ([tran_num], [deal_num], [reference], [ins_type], [input_date]
			   , [toolset], [portfolio], [internal_desk], [counterparty]
			   , [buy_sell], [trader], [trade_date], [deal_side]
			   , [price_region], [profile_leg], [unit_of_measure], [commodity]
			   , [side_currency], [settlement_type], [ZONE], [location]
			   , [region], [product], [settlement_currency]
			   , [mtm_undisc], [mtm_undisc_eur], [mtm_disc], [mtm_disc_eur], [value_type]
			   , [period_end_date], [location1]
			   , [zone1], [time_bucket], [location_pair]
			   , [deal_start_date], [deal_end_date], [settlement_date], [ias39_scope]
			   , [ias39_book], [hedging_strategy], [hedging_side], [contract_value]
			   , [period_start_date], [commodity_balance], [external_commodity_balance]
			   , [ins_sub_type], [fx_flt], [country], [pipeline]
			   , [legal_entity], [TaggingYear], [source_system_id]
			   , [process_id], [as_of_date], [create_ts])
			SELECT mtm.[tran_num], mtm.[deal_num], mtm.[reference], mtm.[ins_type], mtm.[input_date]
			   , mtm.[toolset], mtm.[portfolio], mtm.[internal_desk], mtm.[counterparty]
			   , mtm.[buy_sell], mtm.[trader], mtm.[trade_date], mtm.[deal_side]
			   , mtm.[price_region], mtm.[profile_leg], mtm.[unit_of_measure], mtm.[commodity]
			   , mtm.[side_currency], mtm.[settlement_type], mtm.[zone], mtm.[location]
			   , mtm.[region], mtm.[product], mtm.[settlement_currency]
			   , mtm.[mtm_undisc], mtm.[mtm_undisc_eur], mtm.[mtm_disc], mtm.[mtm_disc_eur], mtm.[value_type]
			   , mtm.[period_end_date], mtm.[location1]
			   , mtm.[zone1], mtm.[time_bucket], mtm.[location_pair]
			   , mtm.[deal_start_date], mtm.[deal_end_date], mtm.[settlement_date], mtm.[ias39_scope]
			   , mtm.[ias39_book], mtm.[hedging_strategy], mtm.[hedging_side], mtm.[contract_value]
			   , mtm.[period_start_date], mtm.[commodity_balance], mtm.[external_commodity_balance]
			   , mtm.[ins_sub_type], mtm.[fx_flt], mtm.[country], mtm.[pipeline]
			   , mtm.[legal_entity], mtm.[TaggingYear], @source_system_desc_id, @process_id
			   , @pnl_as_of_date_mtm, GETDATE()
			FROM ssis_mtm_formate2 mtm
			INNER JOIN #tmp_deleted_pnl_deals d ON mtm.deal_num = d.deal_id

--			DELETE ssis_mtm_formate2_error_log 
--			FROM ssis_mtm_formate2_error_log err
--			INNER JOIN (SELECT DISTINCT external_type_id FROM #import_status) st ON err.deal_num = st.external_type_id
--			exec spa_print 'Deleted 4006 errors from ssis_mtm_formate2_error_log. Process took ' + dbo.FNACalculateTimestamp(@start_ts)
--
--			SET @start_ts = GETDATE()
--			INSERT INTO [ssis_mtm_formate2_error_log]
--			   ([tran_num], [deal_num], [reference], [ins_type], [input_date]
--			   , [toolset], [portfolio], [internal_desk], [counterparty]
--			   , [buy_sell], [trader], [trade_date], [deal_side]
--			   , [price_region], [profile_leg], [unit_of_measure], [commodity]
--			   , [side_currency], [settlement_type], [zone], [location]
--			   , [region], [product], [settlement_currency]
--			   , [mtm_undisc], [mtm_undisc_eur], [mtm_disc], [mtm_disc_eur], [value_type]
--			   , [period_end_date], [location1]
--			   , [zone1], [time_bucket], [location_pair]
--			   , [deal_start_date], [deal_end_date], [settlement_date], [ias39_scope]
--			   , [ias39_book], [hedging_strategy], [hedging_side], [contract_value]
--			   , [period_start_date], [commodity_balance], [external_commodity_balance]
--			   , [ins_sub_type], [fx_flt], [country], [pipeline]
--			   , [legal_entity], [TaggingYear], [source_system_id]
--			   , [process_id], [as_of_date], [create_ts])
--			SELECT mtm.[tran_num], mtm.[deal_num], mtm.[reference], mtm.[ins_type], mtm.[input_date]
--			   , mtm.[toolset], mtm.[portfolio], mtm.[internal_desk], mtm.[counterparty]
--			   , mtm.[buy_sell], mtm.[trader], mtm.[trade_date], mtm.[deal_side]
--			   , mtm.[price_region], mtm.[profile_leg], mtm.[unit_of_measure], mtm.[commodity]
--			   , mtm.[side_currency], mtm.[settlement_type], mtm.[zone], mtm.[location]
--			   , mtm.[region], mtm.[product], mtm.[settlement_currency]
--			   , mtm.[mtm_undisc], mtm.[mtm_undisc_eur], mtm.[mtm_disc], mtm.[mtm_disc_eur], mtm.[value_type]
--			   , mtm.[period_end_date], mtm.[location1]
--			   , mtm.[zone1], mtm.[time_bucket], mtm.[location_pair]
--			   , mtm.[deal_start_date], mtm.[deal_end_date], mtm.[settlement_date], mtm.[ias39_scope]
--			   , mtm.[ias39_book], mtm.[hedging_strategy], mtm.[hedging_side], mtm.[contract_value]
--			   , mtm.[period_start_date], mtm.[commodity_balance], mtm.[external_commodity_balance]
--			   , mtm.[ins_sub_type], mtm.[fx_flt], mtm.[country], mtm.[pipeline]
--			   , mtm.[legal_entity], mtm.[TaggingYear], @source_system_desc_id, @process_id
--			   , @pnl_as_of_date_mtm, GETDATE()
--			FROM ssis_mtm_formate2 mtm
--			-- DISTINCT is necessary here to avoid insertion of duplicate rows as #import_status may CONTAIN
--			--same deal_num multiple times
--			INNER JOIN (SELECT DISTINCT external_type_id FROM #import_status) st ON mtm.deal_num = st.external_type_id

			exec spa_print 'Inserted 4006 errors to ssis_mtm_formate2_error_log from ssis_mtm_formate2. Process took ' --+ dbo.FNACalculateTimestamp(@start_ts)
		END
		
--		print 'Insert If Error Found ' +convert(varchar,getdate(),109)	
--		INSERT INTO [ssis_mtm_formate2_error_log]
--           ([tran_num]  ,[deal_num]  ,[reference]    ,[ins_type] ,[input_date]
--           ,[toolset]   ,[portfolio],[internal_desk] ,[counterparty]
--           ,[buy_sell]  ,[trader]  ,[trade_date]     ,[deal_side]
--           ,[price_region]   ,[profile_leg]  ,[unit_of_measure]  ,[commodity]
--           ,[side_currency]  ,[settlement_type]   ,[zone]  ,[location]
--           ,[region]    ,[product]    ,[settlement_currency]
--           ,[mtm_undisc] ,[mtm_undisc_eur] ,[mtm_disc] ,[mtm_disc_eur],[value_type]
--           ,[period_end_date]       ,[location1]
--           ,[zone1]        ,[time_bucket]           ,[location_pair]
--           ,[deal_start_date]           ,[deal_end_date]           ,[settlement_date]           ,[ias39_scope]
--           ,[ias39_book]           ,[hedging_strategy]           ,[hedging_side]           ,[contract_value]
--           ,[period_start_date]           ,[commodity_balance]           ,[external_commodity_balance]
--           ,[ins_sub_type]           ,[fx_flt]           ,[country]           ,[pipeline]
--           ,[legal_entity]           ,[TaggingYear]           ,[source_system_id]
--           ,[process_id]      ,[as_of_date]   ,[create_ts])
--		select [tran_num]  ,[deal_num]  ,[reference]    ,[ins_type] ,[input_date]
--           ,[toolset]   ,[portfolio],[internal_desk] ,[counterparty]
--           ,[buy_sell]  ,[trader]  ,[trade_date]     ,[deal_side]
--           ,[price_region]   ,[profile_leg]  ,[unit_of_measure]  ,[commodity]
--           ,[side_currency]  ,[settlement_type]   ,[zone]  ,[location]
--           ,[region]    ,[product]    ,[settlement_currency]
--           ,[mtm_undisc] ,[mtm_undisc_eur] ,[mtm_disc] ,[mtm_disc_eur],[value_type]
--           ,[period_end_date]       ,[location1]
--           ,[zone1]        ,[time_bucket]           ,[location_pair]
--           ,[deal_start_date]           ,[deal_end_date]           ,[settlement_date]           ,[ias39_scope]
--           ,[ias39_book]           ,[hedging_strategy]           ,[hedging_side]           ,[contract_value]
--           ,[period_start_date]           ,[commodity_balance]           ,[external_commodity_balance]
--           ,[ins_sub_type]           ,[fx_flt]           ,[country]           ,[pipeline]
--           ,[legal_entity]           ,[TaggingYear] ,@source_system_desc_id  ,@process_id,
--			@pnl_as_of_date_mtm, getdate()
--		from ssis_mtm_formate2 where deal_num in (select external_type_id from #import_status)
--
--
--		EXEC spa_print 'Insert If Error Found DONE ' +convert(varchar,getdate(),109)
	END
	ELSE IF @error_log_table_name='formate1' 
	BEGIN
		EXEC spa_print ' ok ' 
--		if @schedule_run='y'
--			delete [ssis_mtm_formate1_error_log] where 
--				deal_num in (select external_type_id from #import_status)
--
		IF @schedule_run='n'
			EXEC('DELETE [ssis_mtm_formate1_error_log] FROM [ssis_mtm_formate1_error_log] err
				INNER JOIN ' + @temp_table_name + ' tmp ON err.deal_num = err.source_deal_header_id')
		--exec('delete [ssis_mtm_formate1_error_log] where deal_num in 
			--(select source_deal_header_id from '+@temp_table_name + ')')
--
--		INSERT INTO [ssis_mtm_formate1_error_log]
--           ([date] ,[trade_date] ,[trade_time]
--           ,[deal_num] ,[type]     ,[MTM_undisc]
--           ,[MTM_disc]        ,[currency_A]          ,[currency_B]
--           ,[Internal_Portfolio]           ,[Desk]           ,[Commodity]
--           ,[Trader]           ,[CounterParty]           ,[reference]
--           ,[price_region]           ,[buy_sell]           ,[ias39_scope]
--           ,[ias39_book]           ,[hedging_strategy]           ,[hedging_side]
--           ,[contract_value]           ,[legal_entity]           ,[source_system_id]
--           ,[process_id]           ,[create_ts]           ,[as_of_date])
--		select [date] ,[trade_date] ,[trade_time]
--           ,[deal_num] ,[type]     ,[MTM_undisc]
--           ,[MTM_disc]        ,[currency_A]          ,[currency_B]
--           ,[Internal_Portfolio]           ,[Desk]           ,[Commodity]
--           ,[Trader]           ,[CounterParty]           ,[reference]
--           ,[price_region]           ,[buy_sell]           ,[ias39_scope]
--           ,[ias39_book]           ,[hedging_strategy]           ,[hedging_side]
--           ,[contract_value]           ,[legal_entity]  ,	@source_system_desc_id  ,
--			@process_id, getdate(),@pnl_as_of_date_mtm
--		from [ssis_mtm_formate1] where deal_num in (select external_type_id from #import_status)
	END
END
EXEC spa_print '########after this ttttttt#######'
/* Change by Gyan*/
SET @temp_for_delete= dbo.FNAProcessTableName('tmp_tbl_tt', @user_login_id, @process_id)
EXEC('create table '+@temp_for_delete+'(
		[source_deal_header_id] [varchar] (100) ,
		[source_system_id] [varchar] (100) ,
		[term_start] [varchar] (100) ,
		[term_end] [varchar] (100) ,
		[Leg] [varchar] (100) ,
		[pnl_as_of_date] [varchar] (100) ,
		[und_pnl] float ,
		[und_intrinsic_pnl] float ,
		[und_extrinsic_pnl] float ,
		[dis_pnl] float ,
		[dis_intrinsic_pnl] float ,
		[dis_extrinisic_pnl] float ,
		[pnl_source_value_id] [varchar] (100) ,
		[pnl_currency_id] [varchar] (100) ,
		[pnl_conversion_factor] float ,
		[pnl_adjustment_value] float,
		[deal_volume] varchar(100) ,
		[table_code] [varchar] (100),
		temp_id int,source_pos_id int)')

-- To Optimized Delete Perfermance
--		delete #temp_table1
-- exec  [dbo].[spa_interface_Adaptor_2] '4006',null,null,'farrms_admin','2','n',null,null,null,'n'
--		exec('insert #temp_table1 exec spa_import_temp_table ''4006''')
--		select @temp_for_delete=table_name from #temp_table1
--		exec('alter table '+ @temp_for_delete+' add temp_id int,source_pos_id int')
-- END  Perfermance
/*End change by Gyan */
	DECLARE @no_month_pnl INT
	DECLARE @closing_month_pnl DATETIME

	CREATE TABLE #pnl_as_of_date (yr INT, mnth INT)
	DECLARE @yr INT, @mnth INT
	DECLARE @previous_month DATETIME
	DECLARE @prefix_name VARCHAR(50),@dbase_name VARCHAR(50),@as_of_date DATETIME
	SET @sql='insert into #pnl_as_of_date select year(cast(pnl_as_of_date as datetime)) Yr,month(cast(pnl_as_of_date as datetime)) mnth  from '+ @temp_table_name+' group by year(cast(pnl_as_of_date as datetime)),month(cast(pnl_as_of_date as datetime))'
	EXEC spa_print '#######PNL As of Date : '--+CONVERT(VARCHAR,GETDATE(),109)	
	EXEC spa_print @sql
	EXEC(@sql)
	EXEC spa_print '#######End PNL As of Date : '--+CONVERT(VARCHAR,GETDATE(),109)	
	DECLARE tblCursor CURSOR FOR
	SELECT yr, mnth  FROM #pnl_as_of_date  FOR  READ ONLY
	OPEN tblCursor
	FETCH NEXT FROM tblCursor INTO @yr, @mnth
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @closing_month_pnl=CONVERT(DATETIME,CAST(@yr AS VARCHAR)+'-'+CAST(@mnth AS VARCHAR)+'-01' ,120)
		SELECT @dbase_name=dbo.FNAGetProcessTableName(@closing_month_pnl, 'source_deal_pnl')
/*	--changed for making compatibe to _arch2

		set @dbase_name=''
		set @prefix_name=''
		if exists (select * from process_table_location where [tbl_name]='source_deal_pnl' and as_of_date=cast(cast(@yr as varchar)+'-'+cast(@mnth as varchar)+'-01' as datetime))
		begin
			EXEC spa_print 'a1'
			select @dbase_name=dbase_name,@prefix_name=[prefix_location_table] from process_table_location where [tbl_name]='source_deal_pnl' and as_of_date=cast(cast(@yr as varchar)+'-'+cast(@mnth as varchar)+'-01' as datetime)
		end
		else
		begin
			select @no_month_pnl=no_month_pnl from run_measurement_param
			--month for data transfer
			EXEC spa_print 'a2'
			EXEC spa_print @closing_month_pnl
			set @closing_month_pnl=dateadd(m,isnull(@no_month_pnl,0),cast(cast(@yr as varchar)+'-'+cast(@mnth as varchar)+'-01' as datetime))
			EXEC spa_print @no_month_pnl
			EXEC spa_print @closing_month_pnl
			if exists(select * from close_measurement_books where as_of_date>=@closing_month_pnl)
			begin
				EXEC spa_print 'a3'
				set @prefix_name='_arch1'
				select @dbase_name=max(dbase_name) from process_table_location where [tbl_name]='source_deal_pnl' and [prefix_location_table]=@prefix_name
				insert into process_table_location (as_of_date, prefix_location_table,dbase_name,tbl_name)
					values (cast(cast(@yr as varchar)+'-'+cast(@mnth as varchar)+'-01' as datetime),@prefix_name,@dbase_name,'source_deal_pnl')
			end
			else
			begin
				EXEC spa_print 'a4'
				select @prefix_name=null
				select @dbase_name=dbase_name from process_table_location where [tbl_name]='source_deal_pnl' and isnull([prefix_location_table],'')=''
			end
		end
		if isnull(@dbase_name,'')='' or @dbase_name='dbo'
			set @dbase_name='dbo'
		else
			set @dbase_name=@dbase_name+'.dbo'

		set @dbase_name=@dbase_name+'.source_deal_pnl'+isnull(@prefix_name,'')
	*/
-------------------------------------------------------------------------------------------------------------------------------------------------
--		set @dbase_name=''
--		if exists (select * from process_table_location where [tbl_name]='source_deal_pnl' and as_of_date<=cast(@yr as varchar)+'-'+cast(@mnth as varchar)+'-01')
--		begin
--			select @dbase_name=dbase_name,@prefix_name=[prefix_location_table] from process_table_location where [tbl_name]='source_deal_pnl' and as_of_date=cast(@yr as varchar)+'-'+cast(@mnth as varchar)+'-01'
--			if isnull(@prefix_name,'')=''
--			begin
--				select @prefix_name=max([prefix_location_table]) from process_table_location where [tbl_name]='source_deal_pnl' and as_of_date<=cast(@yr as varchar)+'-'+cast(@mnth as varchar)+'-01'
--				select @dbase_name=dbase_name from process_table_location where [tbl_name]='source_deal_pnl' and [prefix_location_table]=@prefix_name
--			end
--		end
--		else
--		begin
--
--			select @no_month_pnl=no_month_pnl from run_measurement_param
--			--month for data transfer
--			set @closing_month_pnl=dateadd(m,-1*isnull(@no_month_pnl,0),cast(cast(@yr as varchar)+'-'+cast(@mnth as varchar)+'-01' as datetime))
--			if exists(select * from close_measurement_books where as_of_date>=@closing_month_pnl)
--			begin
--				set @prefix_name='_arch1'
--				select @dbase_name=max(dbase_name) from process_table_location where [tbl_name]='source_deal_pnl' and [prefix_location_table]=@prefix_name
--			end
--			else
--			begin
--				select @prefix_name=null
--				select @dbase_name=dbase_name from process_table_location where [tbl_name]='source_deal_pnl' and isnull([prefix_location_table],'')=''
--			end
--		end
--		if isnull(@dbase_name,'')=''
--			set @dbase_name='dbo'
--		else
--			set @dbase_name=@dbase_name+'.dbo'
--		set @dbase_name=@dbase_name+'.source_deal_pnl'+isnull(@prefix_name,'')
		
--------------------------------------------------------------------------------------------------------------



--		set @sql='Delete '+@dbase_name+' from  '+@temp_table_name+' a 
--				INNER JOIN
--				source_deal_header c ON a.source_deal_header_id = c.deal_id INNER JOIN
--				'+@dbase_name+' b ON c.source_deal_header_id = b.source_deal_header_id AND
--				cast(a.term_start as datetime) = b.term_start AND 
--				cast(a.term_end as datetime) = b.term_end AND 
--				a.Leg = b.Leg 
--				 AND cast(a.pnl_as_of_date as datetime) = b.pnl_as_of_date 
--				and year(b.pnl_as_of_date)='+cast(@yr as varchar)+' and month(b.pnl_as_of_date)='+cast(@mnth as varchar)
--		EXEC spa_print @sql

		EXEC spa_print 'Inside Cursor  3 Delete PNL (Start) if exist Done: '--+CONVERT(VARCHAR,GETDATE(),109)	
		EXEC spa_print @temp_for_delete

		IF OBJECT_ID(@temp_for_delete) IS NOT NULL
			EXEC('drop table '+@temp_for_delete)
		
		set @sql='select distinct a.*,c.source_deal_header_id source_pos_id
					into '+@temp_for_delete+' from  '+ @temp_table_name +'  a 
					INNER JOIN
					source_deal_header c ON a.source_deal_header_id = c.deal_id 
					and c.source_system_id=a.source_system_id
 					WHERE year(cast(a.pnl_as_of_date as datetime))='+cast(@yr as varchar)+' and month(cast(a.pnl_as_of_date as datetime))='+cast(@mnth as varchar)
		EXEC spa_print @sql
		exec(@sql)
/*
		exec('insert into '+ @temp_for_delete +'
		select a.*,c.source_deal_header_id
		from  '+ @temp_table_name +'  a 
					INNER JOIN
					source_deal_header c ON a.source_deal_header_id = c.deal_id INNER JOIN
					source_deal_pnl b ON c.source_deal_header_id = b.source_deal_header_id 
					--AND
					--cast(a.term_start as datetime) = b.term_start AND 
					--cast(a.term_end as datetime) = b.term_end 
					--AND a.Leg = b.Leg 
					--AND cast(a.pnl_as_of_date as datetime) = b.pnl_as_of_date 
					')
	*/
	
		EXEC('create index indx_'+@process_id+' on '+@temp_for_delete+'(source_pos_id,pnl_as_of_date)')
		
		EXEC spa_print 'Inside Cursor  3 Delete PNL (Insert to temp ) if exist Done: '--+CONVERT(VARCHAR,GETDATE(),109)	

			SET @sql='Delete '+ @dbase_name +' from  '+@temp_for_delete+' a 
					INNER JOIN '+@dbase_name+' b ON a.source_pos_id = b.source_deal_header_id
				and	cast(a.pnl_as_of_date as datetime) = b.pnl_as_of_date 
				where year(cast(a.pnl_as_of_date as datetime))='+CAST(@yr AS VARCHAR)+' and month(cast(a.pnl_as_of_date as datetime))='+CAST(@mnth AS VARCHAR)
			
/*
			set @sql='Delete '+ @dbase_name +' from  '+@temp_for_delete+' a 
					JOIN
					source_deal_pnl b ON a.source_pos_id = b.source_deal_header_id
				-- AND
				--	cast(a.term_start as datetime) = b.term_start AND 
				--	cast(a.term_end as datetime) = b.term_end AND 
				--a.Leg = b.Leg AND 
				and	cast(a.pnl_as_of_date as datetime) = b.pnl_as_of_date 
			'



*/

		EXEC(@sql)
		EXEC spa_print 'Inside Cursor 3 Delete PNL (End) if exist Done: '--+CONVERT(VARCHAR,GETDATE(),109)	

		SET @sql1='insert into '+@dbase_name+' (source_deal_header_id,term_start,term_end,Leg,pnl_as_of_date,und_pnl,und_intrinsic_pnl,und_extrinsic_pnl,dis_pnl,dis_intrinsic_pnl
				,dis_extrinisic_pnl,pnl_source_value_id,pnl_currency_id,pnl_conversion_factor,deal_volume,create_ts,create_user,update_ts,update_user)
				 select b.source_deal_header_id,cast(a.term_start as datetime),cast(a.term_end as datetime),a.Leg,cast(a.pnl_as_of_date as datetime),a.und_pnl,a.und_intrinsic_pnl,a.und_extrinsic_pnl,a.dis_pnl,
				a.dis_intrinsic_pnl,a.dis_extrinisic_pnl,a.pnl_source_value_id,d.source_currency_id,a.pnl_conversion_factor,a.deal_volume
				,getdate() create_ts,'''+@user_login_id+''' create_user,getdate() update_ts,  '''+@user_login_id+''' update_user
	 		FROM  '+@temp_table_name+' a INNER JOIN	source_deal_header b ON a.source_deal_header_id = b.deal_id AND a.source_system_id = b.source_system_id 
			INNER	JOIN source_currency d ON a.pnl_currency_id = d.currency_id and a.source_system_id=d.source_system_id
				and year(cast(a.pnl_as_of_date as datetime))='+cast(@yr as varchar)+' and month(cast(a.pnl_as_of_date as datetime))='+cast(@mnth as varchar)

		EXEC spa_print @sql1
		EXEC(@sql1)
		FETCH NEXT FROM tblCursor INTO  @yr, @mnth
	END
	CLOSE tblCursor
	DEALLOCATE tblCursor
--privious month update

/* Remove Previous month data logic
		select @previous_month=max(as_of_date) from process_table_location where [tbl_name]='source_deal_pnl' 
		and [prefix_location_table]='_arch1'
		create table #tmp (source_deal_header_id varchar(50) COLLATE DATABASE_DEFAULT,pnl_as_of_date datetime)
		set @sql1='insert into #tmp select source_deal_header_id,max(cast(pnl_as_of_date as datetime)) pnl_as_of_date
				FROM  '+@temp_table_name+'  where cast(pnl_as_of_date as datetime)>= '''+cast(@Previous_month as varchar)+''' 
		and cast(pnl_as_of_date as datetime)<'''+cast(dateadd(m,1,@Previous_month) as varchar)+''' group by source_deal_header_id'
		exec(@sql1)
exec spa_print 'ggggg'
		
--	Delete  source_deal_pnl from source_deal_pnl b INNER JOIN source_deal_header c 
--			ON c.source_deal_header_id = b.source_deal_header_id 
--		inner join #tmp a ON a.source_deal_header_id = c.deal_id 
--			and b.pnl_as_of_date =a.pnl_as_of_date
EXEC spa_print 'previous_month 3 Start Delete PNL (Insert to temp ) if exist Done: '+convert(varchar,getdate(),109)	
	exec('delete '+ @temp_for_delete)
	exec spa_print 'insert into '+ @temp_for_delete +'(source_deal_header_id,pnl_as_of_date,source_pos_id
	select a.*,c.source_deal_header_id
			from  #tmp  a 
			INNER JOIN
			source_deal_header c ON a.source_deal_header_id = c.deal_id INNER JOIN
			source_deal_pnl b ON c.source_deal_header_id = b.source_deal_header_id 
			AND cast(a.pnl_as_of_date as datetime) = b.pnl_as_of_date ')

	EXEC spa_print 'previous_month 3 Delete PNL (Insert to temp ) if exist Done: '+convert(varchar,getdate(),109)	

	set @sql='Delete source_deal_pnl from  '+@temp_for_delete+' a 
			JOIN source_deal_pnl b ON a.source_pos_id = b.source_deal_header_id 
			AND cast(a.pnl_as_of_date as datetime) = b.pnl_as_of_date 
	'
exec(@sql)
EXEC spa_print 'previous_month 3 Delete PNL if exist Done: '+convert(varchar,getdate(),109)	

		set @sql1='insert into source_deal_pnl (source_deal_header_id,term_start,term_end,Leg,pnl_as_of_date,und_pnl,und_intrinsic_pnl,und_extrinsic_pnl,dis_pnl,dis_intrinsic_pnl,dis_extrinisic_pnl,pnl_source_value_id,pnl_currency_id,pnl_conversion_factor,deal_volume)
				 select distinct b.source_deal_header_id,cast(a.term_start as datetime),cast(a.term_end as datetime),a.Leg,cast(a.pnl_as_of_date as datetime),a.und_pnl,a.und_intrinsic_pnl,a.und_extrinsic_pnl,a.dis_pnl,
				a.dis_intrinsic_pnl,a.dis_extrinisic_pnl,a.pnl_source_value_id,d.source_currency_id,a.pnl_conversion_factor,a.deal_volume
				FROM  '+@temp_table_name+' a INNER JOIN
				source_deal_header b ON 
				a.source_deal_header_id = b.deal_id AND 
				a.source_system_id = b.source_system_id INNER
				JOIN source_currency d ON 
				a.pnl_currency_id = d.currency_id and a.source_system_id=d.source_system_id
				inner join #tmp f on a.source_deal_header_id=f.source_deal_header_id and a.pnl_as_of_date=f.pnl_as_of_date
				'
		EXEC spa_print @sql1
		Exec(@sql1)
--		drop table #tmp
*/
--settlement updates
--		set @sql='Delete source_deal_pnl_settlement from  '+@temp_table_name+' a 
--				INNER JOIN
--				source_deal_header c ON a.source_deal_header_id = c.deal_id INNER JOIN
--				source_deal_pnl_settlement b ON c.source_deal_header_id = b.source_deal_header_id AND
--				cast(a.term_start as datetime) = b.term_start AND 
--				cast(a.term_end as datetime) = b.term_end AND 
--				a.Leg = b.Leg
--				AND b.pnl_as_of_date <= cast(a.pnl_as_of_date as datetime) '
	
--			create table #tmp_max_as_of_date ( source_deal_header_id varchar(100) COLLATE DATABASE_DEFAULT,term_start datetime,term_end datetime, pnl_as_of_date datetime)
--			exec('insert into #tmp_max_as_of_date select source_deal_header_id,term_start,term_end,max(cast(pnl_as_of_date as datetime)) pnl_as_of_date 
--					 from '+@temp_table_name+ ' group by source_deal_header_id,term_start,term_end')
--			exec spa_print 'insert into #tmp_max_as_of_date select source_deal_header_id,term_start,term_end,max(cast(pnl_as_of_date as datetime) pnl_as_of_date 
--					 from '+@temp_table_name+ ' group by source_deal_header_id,term_start,term_end')


			EXEC spa_print '3 Start Delete Settlement PNL (Insert to temp ) if exist Done: '--+CONVERT(VARCHAR,GETDATE(),109)	

			IF OBJECT_ID(@temp_for_delete) is not null
				EXEC('drop table '+@temp_for_delete)

			EXEC('select a.*,c.source_deal_header_id source_pos_id into '+@temp_for_delete+'
				from  '+@temp_table_name+'  a 
						inner join 
						source_deal_header c ON a.source_deal_header_id = c.deal_id and c.source_system_id=a.source_system_id INNER JOIN
						source_deal_pnl_settlement b ON c.source_deal_header_id = b.source_deal_header_id AND	
						cast(a.term_start as datetime) = b.term_start AND 
						cast(a.term_end as datetime) = b.term_end 
						AND b.pnl_as_of_date <= cast(a.pnl_as_of_date as datetime)  ')
	
			EXEC('create index indx_'+@process_id+' on '+@temp_for_delete+'(source_pos_id,pnl_as_of_date)')

			EXEC spa_print '3 Delete PNL (Insert to temp ) if exist Done: '--+CONVERT(VARCHAR,GETDATE(),109)	
			
				SET @sql='Delete source_deal_pnl_settlement from  '+@temp_for_delete+' a 
						JOIN source_deal_pnl_settlement b ON a.source_pos_id = b.source_deal_header_id AND
						cast(a.term_start as datetime) = b.term_start AND 
						cast(a.term_end as datetime) = b.term_end 
						AND b.pnl_as_of_date <= cast(a.pnl_as_of_date as datetime) 
				'
			exec spa_print @sql
			EXEC(@sql)
			EXEC spa_print '3 Delete Settlement PNL if exist Done: '--+CONVERT(VARCHAR,GETDATE(),109)	
					
		/* -- is null condition took too much time, breking this statement into 2
		set @sql1='insert into source_deal_pnl_settlement (source_deal_header_id,term_start,term_end,Leg,pnl_as_of_date,und_pnl,und_intrinsic_pnl,und_extrinsic_pnl,dis_pnl,dis_intrinsic_pnl,dis_extrinisic_pnl,pnl_source_value_id,pnl_currency_id,pnl_conversion_factor,deal_volume)
				 select b.source_deal_header_id,cast(a.term_start as datetime),cast(a.term_end as datetime),a.Leg,cast(a.pnl_as_of_date as datetime),a.und_pnl,a.und_intrinsic_pnl,a.und_extrinsic_pnl,a.dis_pnl,
				a.dis_intrinsic_pnl,a.dis_extrinisic_pnl,a.pnl_source_value_id,d.source_currency_id,a.pnl_conversion_factor,a.deal_volume
	 			FROM  '+@temp_table_name+' a 
				INNER JOIN
				source_deal_header b ON 
				a.source_deal_header_id = b.deal_id AND 
				a.source_system_id = b.source_system_id INNER
				JOIN
				source_currency d ON 
				a.pnl_currency_id = d.currency_id and a.source_system_id=d.source_system_id
				left join source_deal_pnl_settlement e on   
				e.source_deal_header_id=b.source_deal_header_id and
				e.term_start=cast(a.term_start as datetime) and
				e.term_end=cast(a.term_end as datetime) and
				e.leg=a.leg 
				where cast(a.pnl_as_of_date as datetime) >= e.pnl_as_of_date or e.source_deal_header_id is null
				'
		*/


		SET @sql1 = 'SELECT a.temp_id into #pnl_temp	FROM ' + @temp_table_name + ' a
					INNER JOIN source_deal_header sdh ON a.source_deal_header_id = sdh.deal_id and sdh.source_system_id=a.source_system_id
					LEFT JOIN source_deal_pnl_settlement e ON sdh.source_deal_header_id = e.source_deal_header_id
						AND e.term_start = CAST(a.term_start AS datetime) AND	e.term_end = CAST(a.term_end AS datetime)	AND e.leg = a.leg
					WHERE CAST(a.pnl_as_of_date AS datetime) >= e.pnl_as_of_date OR e.source_deal_header_id IS NULL;
					
create index indx_pnl_temp on #pnl_temp (temp_id);

		INSERT INTO source_deal_pnl_settlement (source_deal_header_id, term_start, term_end, Leg, pnl_as_of_date, und_pnl,und_intrinsic_pnl, 
			und_extrinsic_pnl, dis_pnl, dis_intrinsic_pnl, dis_extrinisic_pnl, pnl_source_value_id,	pnl_currency_id,pnl_conversion_factor,deal_volume)
		SELECT b.source_deal_header_id, CAST(a.term_start AS datetime), CAST(a.term_end AS datetime), a.Leg, CAST(a.pnl_as_of_date as datetime)
			, a.und_pnl,a.und_intrinsic_pnl, a.und_extrinsic_pnl,a.dis_pnl, a.dis_intrinsic_pnl, a.dis_extrinisic_pnl, a.pnl_source_value_id
			, d.source_currency_id, a.pnl_conversion_factor, a.deal_volume
		FROM ' + @temp_table_name + ' a inner JOIN #pnl_temp t ON a.temp_id = t.temp_id
				inner JOIN source_deal_header b ON a.source_deal_header_id = b.deal_id and b.source_system_id=a.source_system_id
 				inner JOIN source_currency d ON a.pnl_currency_id = d.currency_id AND a.source_system_id = d.source_system_id;

		drop table #pnl_temp;		
					'

		/*
		--insert those whose pnl_as_of_date are greater than existing pnl_as_of_date
		set @sql1 = 'INSERT INTO source_deal_pnl_settlement (source_deal_header_id, term_start, term_end, Leg, pnl_as_of_date, und_pnl, und_intrinsic_pnl, und_extrinsic_pnl, dis_pnl, dis_intrinsic_pnl, dis_extrinisic_pnl, pnl_source_value_id, pnl_currency_id, pnl_conversion_factor, deal_volume)
					 SELECT b.source_deal_header_id, CAST(a.term_start AS datetime), CAST(a.term_end AS datetime), a.Leg, CAST(a.pnl_as_of_date AS datetime), a.und_pnl, a.und_intrinsic_pnl, a.und_extrinsic_pnl, a.dis_pnl
					, a.dis_intrinsic_pnl, a.dis_extrinisic_pnl, a.pnl_source_value_id, d.source_currency_id, a.pnl_conversion_factor, a.deal_volume
 					FROM ' + @temp_table_name + ' a 
					INNER JOIN source_deal_header b ON a.source_deal_header_id = b.deal_id
						AND a.source_system_id = b.source_system_id 
					INNER JOIN source_currency d ON a.pnl_currency_id = d.currency_id and a.source_system_id = d.source_system_id
					INNER JOIN source_deal_pnl_settlement e ON e.source_deal_header_id = b.source_deal_header_id 
						AND	e.term_start = CAST(a.term_start AS datetime) 
						AND	e.term_end = CAST(a.term_end AS datetime) 
						AND e.leg = a.leg 
					WHERE CAST(a.pnl_as_of_date AS datetime) >= e.pnl_as_of_date
					'
		EXEC spa_print @sql1
		Exec(@sql1)

		--insert new only which are not present in source_deal_pnl_settlement already
		set @sql1 = 'INSERT INTO source_deal_pnl_settlement (source_deal_header_id, term_start, term_end, Leg, pnl_as_of_date, und_pnl, und_intrinsic_pnl, und_extrinsic_pnl, dis_pnl, dis_intrinsic_pnl, dis_extrinisic_pnl, pnl_source_value_id, pnl_currency_id, pnl_conversion_factor, deal_volume)
					SELECT new_pnl.source_deal_header_id, CAST(tmp.term_start AS datetime), CAST(tmp.term_end AS datetime), tmp.Leg, CAST(tmp.pnl_as_of_date AS datetime), tmp.und_pnl, tmp.und_intrinsic_pnl, tmp.und_extrinsic_pnl, tmp.dis_pnl
					, tmp.dis_intrinsic_pnl, tmp.dis_extrinisic_pnl, tmp.pnl_source_value_id, d.source_currency_id, tmp.pnl_conversion_factor, tmp.deal_volume
					FROM ' + @temp_table_name + ' tmp
					INNER JOIN source_deal_header h ON tmp.source_deal_header_id = h.deal_id
						AND tmp.source_system_id = h.source_system_id 
					INNER JOIN
					(
						SELECT b.source_deal_header_id, CAST(a.term_start AS datetime) term_start, CAST(a.term_end AS datetime) term_end, a.Leg 
						FROM ' + @temp_table_name + ' a
						INNER JOIN source_deal_header b ON a.source_deal_header_id = b.deal_id
							AND a.source_system_id = b.source_system_id
						EXCEPT
						SELECT source_deal_header_id, term_start, term_end, Leg
						FROM source_deal_pnl_settlement e
					) new_pnl ON h.source_deal_header_id = new_pnl.source_deal_header_id
							AND tmp.term_start = new_pnl.term_start
							AND tmp.term_end = new_pnl.term_end
							AND	tmp.leg = new_pnl.leg
					INNER JOIN source_currency d ON tmp.pnl_currency_id = d.currency_id 
						AND tmp.source_system_id = d.source_system_id
					'
		*/
		EXEC spa_print @sql1
		EXEC(@sql1)
		DROP TABLE #pnl_as_of_date

	EXEC spa_print 'Insert PNL Settlement Done: '--+CONVERT(VARCHAR,GETDATE(),109)	


END

--add new import option
IF CHARINDEX('4023',@table_id,1)<>0	--source_deal_cash_settlement
BEGIN
	EXEC('delete '+@field_compare_table)
	SET @tablename=(SELECT code FROM static_data_value WHERE value_id=4023)
	--	exec('insert into '+@field_compare_table+ ' values (''source_deal_cash_settlement'',''source_deal_header_id'',''source_deal_header_id'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_cash_settlement'',''term_start'',''term_start'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_cash_settlement'',''cash_received'',''cash_received'')')
		EXEC('insert into '+@field_compare_table+ ' values (''source_deal_cash_settlement'',''as_of_date'',''as_of_date'')')
		--Pre validataing Data Type
		SET @source_table=@temp_table_name
		EXEC('delete from '+@temp_table_name+' where source_deal_header_id is null and term_start is null and cash_received is null and
		as_of_date is null' )
		
		EXEC (' insert into #temp_tot_count select count(*) as totcount,'''+ @tablename+'''  from '+@temp_table_name)
		EXEC sp_validate_data_type @process_id,@field_compare_table,@source_table

--Data Import ****************************************************************************8
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data error for Deal_id :''+ isnull(a.source_deal_header_id,''NULL'')+'', Term_start:''+ isnull(a.term_start,''NULL'')+ ''(Data Repetition Error, No of times:''+ cast(b.notimes as varchar)+'' )'',''Please check your data'' 
			from '+@temp_table_name + ' a inner join (select source_deal_header_id,term_start,count(*) notimes from '+ @temp_table_name+'
			 group by source_deal_header_id,term_start having count(*)>1) b 
			on a.source_deal_header_id=b.source_deal_header_id and a.term_start=b.term_start')

		
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for Deal_id :''+ isnull(a.source_deal_header_id,''NULL'') +'', Term_start :''+ isnull(a.term_start,''NULL'') +''.(Foreign Key deal_id ''+ISNULL(a.source_deal_header_id,''NULL'')+'' is not found)'' ,''Please check your data'' 
			from '+@temp_table_name + ' a left join #import_status on a.temp_id=#import_status.temp_id
			left join source_deal_header b on b.deal_id=a.source_deal_header_id and b.source_system_id=a.source_system_id
			where #import_status.temp_id is null and b.source_deal_header_id is null')
	
	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
			''Data error for Deal_id :''+ isnull(a.source_deal_header_id,''NULL'') +'', Term_start :''+ isnull(a.term_start,''NULL'') +''.(The deal_id: ''+ISNULL(a.source_deal_header_id,''NULL'')+'' and Term_start:'' + isnull(a.term_start,''NULL'') + '' is not found)'' ,''Please check your data'' 
			from '+@temp_table_name + ' a inner join source_deal_header b on b.deal_id=a.source_deal_header_id and b.source_system_id=a.source_system_id
			left join #import_status on a.temp_id=#import_status.temp_id
			left join source_deal_pnl_settlement c on b.source_deal_header_id=c.source_deal_header_id and c.term_start=a.term_start
			where #import_status.temp_id is null and c.source_deal_header_id is null')

		EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data error for Deal_id :''+ isnull(a.source_deal_header_id,''NULL'')+'', Term_start:''+ isnull(a.term_start,''NULL'')+ ''(Deal_id can not be null.)'',''Please check your data'' 
			from '+@temp_table_name + ' a where isnull(source_deal_header_id,'''')=''''')

	EXEC('insert into #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) select a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+ @tablename+''',''Data Error'',
			''Data error for Deal_id :''+ isnull(a.source_deal_header_id,''NULL'')+'', Term_start:''+ isnull(a.term_start,''NULL'')+ ''(Term Start Date must be first day of the month.)'',''Please check your data'' 
			from '+@temp_table_name + ' a where day(a.term_start)<>1')

	EXEC('delete '+@temp_table_name + ' from #import_status inner join '+@temp_table_name + ' a on
		#import_status.temp_id=a.temp_id')
	
	EXEC('ALTER TABLE '+@temp_table_name+' ADD [term_end] datetime,[cash_settlement] float
		  ,[cash_variance] float
		  ,[source_currency_id] int
		  ')
	SET @sql= '
	UPDATE ' + @temp_table_name + ' SET 
	[term_end]=case WHEN s.term_end IS NULL THEN dateadd(d,-1,dateadd(m,1,a.term_start)) ELSE s.term_end END
				,[cash_settlement]=isnull(s.und_pnl, 0)
			  ,[cash_variance]=round(isnull(a.cash_received,0),2)- isnull(s.und_pnl, 0)
			  ,[source_currency_id]=s.pnl_currency_id 

	FROM ' + @temp_table_name + ' a left JOIN 
		(
			SELECT SDH.deal_id,SDH.source_system_id,sdps.term_start,sdps.term_end,round(sum(isnull(sdps.und_pnl, 0)), 2) und_pnl,max(sdps.pnl_currency_id) pnl_currency_id
			FROM source_deal_pnl_settlement sdps 
				INNER JOIN
				 source_deal_header sdh on sdps.source_deal_header_id = sdh.source_deal_header_id 
			INNER JOIN ' + @temp_table_name + ' a on sdh.deal_id = a.source_deal_header_id  and sdh.source_system_id=a.source_system_id
				and sdps.term_start=CAST(a.term_start AS DATETIME) 
				--AND sdps.pnl_as_of_date<=CAST(a.as_of_date AS DATETIME)
			GROUP BY sdh.source_system_id,SDH.deal_id,sdps.term_start,sdps.term_end
		) s ON s.deal_id = a.source_deal_header_id and s.source_system_id=a.source_system_id
			and s.term_start=CAST(a.term_start AS DATETIME)
	'
	EXEC spa_print @sql
	EXEC(@sql)

EXEC spa_print 'UPDATE1'
	SET @sql='update  source_deal_cash_settlement set  
			[cash_received]=a.[cash_received],
			[as_of_date]=a.[as_of_date],
			term_end=a.term_end,
			[cash_settlement]=a.[cash_settlement],
			[cash_variance]=a.[cash_variance],
			[source_currency_id]=isnull(a.[source_currency_id],b.[source_currency_id]),
			[description]=isnull(a.[description],b.[description]),
			update_user=dbo.fnadbuser(),
			update_ts=getdate()
			FROM source_deal_cash_settlement b
			inner join source_deal_header sdh on sdh.source_deal_header_id=b.source_deal_header_id
			inner join '+@temp_table_name+' a ON sdh.deal_id = a.source_deal_header_id and sdh.source_system_id=a.source_system_id AND 
                      b.term_start = a.term_start 
			left join #import_status on a.temp_id=#import_status.temp_id where #import_status.temp_id is null'
	EXEC spa_print @sql

	SET @sql1='insert into source_deal_cash_settlement
			([source_deal_header_id]
           ,[term_start]
           ,[term_end]
           ,[cash_settlement]
           ,[cash_received]
           ,[cash_variance]
           ,[source_currency_id]
           ,[description]
           ,[as_of_date]
           ,[create_user]
           ,[create_ts]
           ,[update_user]
           ,[update_ts])
		select 
			sdh.[source_deal_header_id]
           ,a.[term_start]
           ,a.[term_end]
           ,a.[cash_settlement]
           ,a.[cash_received]
           ,a.[cash_variance]
           ,a.[source_currency_id]
           ,a.[description]
           ,a.[as_of_date]
           ,dbo.fnadbuser()
           ,getdate()
           ,dbo.fnadbuser()
           ,getdate()
			FROM   '+@temp_table_name+' a INNER JOIN
			source_deal_header sdh ON sdh.[deal_id]=a.[source_deal_header_id]
			 AND a.source_system_id = sdh.source_system_id 
			left join source_deal_cash_settlement e on sdh.[source_deal_header_id]=e.[source_deal_header_id] and a.term_start=e.term_start 
			left join #import_status on a.temp_id=#import_status.temp_id where #import_status.temp_id is null 
			and e.[source_deal_header_id] is null
			'	
	EXEC(@sql)
	EXEC spa_print @sql1

	EXEC(@sql1)

END


IF CHARINDEX('5475',@table_id,1)<>0 --	Finance_Categories
BEGIN
	SET @tablename = (SELECT code FROM static_data_value WHERE value_id = 5475)

	EXEC(' INSERT INTO #temp_tot_count SELECT COUNT(*) AS totcount,'''+ @tablename+'''  FROM '+@temp_table_name)
	
	EXEC('INSERT INTO #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) 
	SELECT a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
		''Data error for counterparty_id :'' + ISNULL(a.counterparty_id,''NULL'') + '' not found '',
		''Please check your data''
	FROM '+@temp_table_name + ' a LEFT JOIN source_counterparty sc ON sc.counterparty_id = a.counterparty_id	
	WHERE sc.source_counterparty_id IS NULL')

	EXEC('INSERT INTO #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) 
	SELECT a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
		''Data error for contract_id :'' + ISNULL(a.contract_id,''NULL'') + '' not found '',
		''Please check your data''
	FROM '+@temp_table_name + ' a LEFT JOIN contract_group cg ON cg.contract_name = a.contract_id	
	WHERE cg.contract_id IS NULL')

	EXEC('INSERT INTO #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) 
	SELECT a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
		''Data error for sub_id :'' + ISNULL(a.sub_id,''NULL'') + '' not found '',
		''Please check your data''
	FROM '+@temp_table_name + ' a LEFT JOIN portfolio_hierarchy ph ON ph.entity_name = a.sub_id	
	WHERE ph.entity_id IS NULL AND ph.hierarchy_level = 2')
		
	EXEC('INSERT INTO #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) 
	SELECT a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
		''Data error for charge_type_id :'' + ISNULL(a.charge_type_id,''NULL'') + '' not found '',
		''Please check your data''
	FROM '+@temp_table_name + ' a LEFT JOIN static_data_value sdv ON sdv.description = a.charge_type_id  AND sdv.type_id = 5500	
	WHERE sdv.value_id IS NULL AND a.source_deal_type_id IS NULL ')


	EXEC('INSERT INTO #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) 
	SELECT a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
		''Data error for charge_type_id :'' + ISNULL(a.charge_type_id,''NULL'') + '' not found '',
		''Please check your data''
	FROM '+@temp_table_name + ' a LEFT JOIN static_data_value sdv1 ON sdv1.code =  a.charge_type_id  AND sdv1.type_id = 10019	
	WHERE sdv1.value_id IS NULL AND a.charge_type_id <> ''Commodity'' AND a.source_deal_type_id IS NOT NULL ')

	EXEC('INSERT INTO #import_status(temp_id,process_id,ErrorCode,Module,Source,type,[description],nextstep) 
	SELECT a.temp_id,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',
		''Data error for buy sell flag :'' + ISNULL(a.buy_sell_flag,''NULL'') + '' is Invalid '',
		''Please check your data''
	FROM '+@temp_table_name + ' a 	
	WHERE (a.buy_sell_flag IS NULL OR a.buy_sell_flag NOT IN (''Buy'',''Sell'') )')


	EXEC('DELETE '+@temp_table_name + ' FROM #import_status INNER JOIN '+@temp_table_name + ' a ON
		#import_status.temp_id = a.temp_id')
		

	SELECT counterparty_id
,contract_id
,buy_sell_flag
,source_deal_type_id
,charge_type_id
,gl_code
,cat1
,cat2
,cat3
,sub_id
,deferral
INTO #temp_pnl_cat_map FROM pnl_categories_mapping WHERE 1 = 2
	
	SET @sql = '
		INSERT INTO #temp_pnl_cat_map(counterparty_id, contract_id, buy_sell_flag, source_deal_type_id, charge_type_id, gl_code, 
										   cat1, cat2, cat3, sub_id, deferral)
		SELECT sc.source_counterparty_id counterparty_id, 
		   cg.contract_id contract_id,
		   CASE WHEN t.buy_sell_flag = ''Buy'' THEN ''b'' WHEN t.buy_sell_flag = ''Sell'' THEN ''s'' ELSE NULL END buy_sell_flag,
		   sdt.source_deal_type_id source_deal_type_id,
		   CASE WHEN t.deferral = ''Deferred'' THEN 3 
				WHEN t.deferral = ''Released'' THEN 1 
				ELSE 
				CASE WHEN t.source_deal_type_id IS NULL THEN sdv.value_id 
					ELSE 
						CASE WHEN t.charge_type_id = ''Commodity'' THEN 2 
						ELSE sdv1.value_id END
				END
			END charge_type_id,
		   t.gl_code gl_code,
		   t.cat1 cat1,
		   t.cat2 cat2,
		   t.cat3 cat3,
		   ph.entity_id sub_id,
		   t.deferral deferral
		FROM ' + @temp_table_name + ' t
		LEFT JOIN source_counterparty sc ON sc.counterparty_id = t.counterparty_id
		LEFT JOIN contract_group cg ON cg.contract_name = t.contract_id
		LEFT JOIN source_deal_type sdt ON sdt.deal_type_id = ISNULL(t.source_deal_type_id, ''Physical'')
		LEFT JOIN portfolio_hierarchy ph ON ph.entity_name = t.sub_id
		LEFT JOIN static_data_value sdv ON sdv.description = t.charge_type_id AND t.source_deal_type_id IS NULL  AND sdv.type_id = 5500 
		LEFT JOIN static_data_value sdv1 ON sdv1.code =  t.charge_type_id AND t.source_deal_type_id IS NOT NULL AND sdv1.type_id = 10019
		WHERE ph.hierarchy_level = 2
		'
	EXEC (@sql)

	BEGIN TRAN
		SET @sql = '
		DELETE pcm FROM pnl_categories_mapping pcm
		INNER JOIN #temp_pnl_cat_map tp ON 
			pcm.counterparty_id = tp.counterparty_id AND
			pcm.contract_id = tp.contract_id AND
			pcm.buy_sell_flag = tp.buy_sell_flag AND 
			ISNULL(pcm.source_deal_type_id, -1) = ISNULL(tp.source_deal_type_id, -1) AND 
			--pcm.source_deal_type_id = tp.source_deal_type_id AND 
			pcm.charge_type_id = tp.charge_type_id AND 
			pcm.sub_id = tp.sub_id AND
			ISNULL(pcm.deferral, -1) = ISNULL(tp.deferral, -1)
		'

		EXEC(@sql)
		
		SET @sql = '
			INSERT INTO pnl_categories_mapping(counterparty_id, contract_id, buy_sell_flag, source_deal_type_id, charge_type_id, gl_code, 
											   cat1, cat2, cat3, sub_id, deferral)
			SELECT tp.counterparty_id, tp.contract_id, tp.buy_sell_flag, tp.source_deal_type_id, tp.charge_type_id, tp.gl_code, tp.cat1, tp.cat2, tp.cat3, tp.sub_id, tp.deferral
			FROM #temp_pnl_cat_map tp 
			'
		EXEC(@sql)
	COMMIT

END

--end try --loop level ******************************************************************************************************************************************************
--begin catch
--	EXEC spa_print 'lllll'
--		insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
--		select @process_id,'Error','Import Data','Data Import Job','Data Error','Error in TABLE :'+@tablename+'('+ERROR_MESSAGE()+')','Please varify data in each source fields.'
--		insert into source_system_data_import_status_detail(process_id,source,
--		type,[description]) 
--		select @process_id,'Import Data','Data Error','Error in TABLE :'+@tablename+'('+ERROR_MESSAGE()+')'
--
--end catch

FinalStep:
DECLARE @count_source INT
UPDATE source_system_data_import_status_detail 
SET source='Position' WHERE 
(source='source_deal_header' OR source='source_deal_detail') AND process_id=@process_id

SELECT @count_source=MAX(totcount) FROM #temp_tot_count
CREATE TABLE #IMPORT_NO(NO_REC INT)
EXEC('INSERT INTO #IMPORT_NO (NO_REC) SELECT COUNT(*) FROM '+@temp_table_name)
SELECT @count=NO_REC FROM #IMPORT_NO
DROP TABLE #IMPORT_NO

IF @count_source-ISNULL(@count,0) >0
	SET @errorcode='e'
ELSE
BEGIN
	SET @errorcode='s'
END
DECLARE @total_deals_proceed INT
IF @count_source<>0
BEGIN 

	INSERT INTO source_system_data_import_status_detail(process_id,source,TYPE,[description],type_error)
	SELECT @process_id,source,TYPE,[description],type_error  FROM #import_status

	DECLARE @total_mtm FLOAT,@total_deal_found INT
	CREATE TABLE #MTM_detail(total_mtm FLOAT)
	IF @table_id='4005'
	BEGIN
		
		IF ISNULL(@deal_detail_audit_log,1)=2
		BEGIN
			IF EXISTS(SELECT 1 FROM #updated_deals_confirm)
			BEGIN
				INSERT INTO source_system_data_import_status(process_id,code,MODULE,source,TYPE,[description],recommendation) 
				SELECT @process_id,'Warning','Import Data','deal_update_confirmation',
					'Data warning',CAST(COUNT(*) AS VARCHAR)
				+' records are found updated in either of the following deal columns: Index, Buy/Sell, Volume, Price.'  [description],'n/a'  FROM #updated_deals_confirm

				INSERT INTO source_system_data_import_status_detail(process_id,source,TYPE,[description],type_error)
				SELECT @process_id,'deal_update_confirmation','Data Warning'
					,CASE WHEN fld.link_id IS NULL THEN '' ELSE  
							dbo.FNAHyperLinkText(10233710,'Link ID:' + CAST(fld.link_id AS VARCHAR) +'; ',fld.link_id) + 
							CASE WHEN hedge_or_item='i' THEN ' Item; ' ELSE ' Hedge; ' END 
					END 
					+ dbo.FNATRMHyperLink('a', 10131010,'Deal ID:' +CAST(tmp.deal_id AS VARCHAR) +'; ',tmp.deal_header_id,'n', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
					+ 'Tenor:' +dbo.fnadateformat(tmp.term_start) + ' ~ '+ dbo.fnadateformat(tmp.term_end)+ '; '
					+ 'Buy_sell:'+CASE WHEN tmp.buy_sell='b' THEN 'Buy; ' ELSE  'Sell; ' END
					+ CASE WHEN tmp.buy_sell_p<>tmp.buy_sell THEN '(Prior Buy_sell:'+CASE WHEN tmp.buy_sell_p='b' THEN 'Buy); ' ELSE  'Sell); ' END ELSE '' END
					+ 'Index:'+tmp.curve_id + '; '
					+ CASE WHEN ISNULL(tmp.curve_id_p,-1)<>ISNULL(tmp.curve_id,-2) THEN '(Prior Index:'+ tmp.curve_id_p +'); ' ELSE '' END
					+ 'Volume:'+STR(tmp.volume,12,2) + '; '
					+ CASE WHEN ROUND(ISNULL(tmp.volume_p,-1),2)<>ROUND(ISNULL(tmp.volume,-2),2) THEN '(Prior Volume:'+ STR(tmp.volume_p,12,2) +'); ' ELSE '' END
					+ 'Price:'+STR(tmp.price,12,2) + '; '
					+ CASE WHEN ROUND(ISNULL(tmp.price_p,-1),0)<>ROUND(ISNULL(tmp.price,-2),0) THEN '(Prior Price:'+ STR(tmp.price_p,12,2) +'); ' ELSE '' END
					,	'deal_update_confirmation' 
				FROM #updated_deals_confirm tmp LEFT JOIN fas_link_detail fld ON fld.source_deal_header_id=tmp.deal_header_id
			END
		END
		EXEC spa_print 'insert into #vol_check select sum(case when isnull(source.deal_volume,'''')='''' then 0 else cast(source.deal_volume as float) end)
					,sum(isnull(dest.deal_volume,0)),count(*)
					from ', @temp_table_name, ' source left join
					source_deal_header sdh on source.deal_id=sdh.deal_id and sdh.source_system_id=source.source_system_id
					left join source_deal_detail dest on sdh.source_deal_header_id=dest.source_deal_header_id 
				and source.term_start=dest.term_start and source.term_end=dest.term_end and source.leg=dest.leg
			'

		EXEC('insert into #vol_check select sum(case when isnull(source.deal_volume,'''')='''' then 0 else cast(source.deal_volume as float) end)
					,sum(isnull(dest.deal_volume,0)),count(*)
					from ' + @temp_table_name + ' source left join
					source_deal_header sdh on source.deal_id=sdh.deal_id  and sdh.source_system_id=source.source_system_id
					left join source_deal_detail dest on sdh.source_deal_header_id=dest.source_deal_header_id 
				and source.term_start=dest.term_start and source.term_end=dest.term_end and source.leg=dest.leg')
		
		
		IF ISNULL(@exec_mode,0)<> 1  AND ISNULL(@exec_mode,0)<> 12-- If not Essent Interface
		BEGIN
			IF EXISTS( SELECT * FROM #vol_check WHERE ROUND(s_tot,2)<>ROUND(d_tot,2))
			BEGIN
				INSERT INTO [source_system_data_import_status_vol]
						   ([Process_id]
						   ,[code]
						   ,[MODULE]
						   ,[source]
						   ,[TYPE]
						   ,[description]
						   ,[recommendation]
						   ,[Volumn_from]
						   ,[Volumn_to],create_ts)
				SELECT @process_id,'Warrning','ImportData','source_deal_detail','Data Error',
					STR(d_tot,18,2) +' Volume imported Successfully out of volume '+ STR(s_tot,18,2) +'(No of Records:'+ CAST(norec AS VARCHAR)+')','Please Check your data'
					,s_tot,d_tot,GETDATE() FROM #vol_check

				EXEC spa_print'
				INSERT INTO [source_system_data_import_status_vol_detail]
						   ([Process_id]
						   ,[source]
						   ,[type]
						   ,[description]
							,book_id
						   ,commodity
						   ,no_recs
						   ,[Volumn_from]
						   ,[Volumn_to],create_ts
							)
						select max(''', @process_id, '''),max(''source_deal_detail''),max(''Data Error''),
						cast(sum(case when isnull(source.deal_volume,'''')='''' then 0 else cast(source.deal_volume as float) end) as varchar(500))+'' Volume imported Successfully out of volume ''+cast(sum(isnull(dest.deal_volume,0)) as varchar(500))+''(No of Deals:''+ cast(count(*) as varchar(500))+'')''
						,ssbm.fas_book_id,f.source_commodity_id,count(*) norec,sum(case when isnull(source.deal_volume,'''')='''' then 0 else cast(source.deal_volume as float) end)
						,sum(isnull(dest.deal_volume,0)),getdate()
						from ', @temp_table_name, ' source left join
						source_deal_header sdh on source.deal_id=sdh.deal_id  and sdh.source_system_id=source.source_system_id
						 inner join
						source_system_book_map ssbm ON 	ssbm.source_system_book_id1 = sdh.source_system_book_id1 AND 
						ssbm.source_system_book_id2 = sdh.source_system_book_id2 AND 
						ssbm.source_system_book_id3 = sdh.source_system_book_id3 AND 
						ssbm.source_system_book_id4 = sdh.source_system_book_id4
						left join source_deal_detail dest on sdh.source_deal_header_id=dest.source_deal_header_id 
						inner join source_price_curve_def on source.[curve_id]=source_price_curve_def.[curve_id] and 
						source.source_system_id=source_price_curve_def.source_system_id 
						left join source_commodity f on
						f.source_commodity_id=source_price_curve_def.commodity_id
						group by ssbm.fas_book_id,source_price_curve_def.source_system_id,f.source_commodity_id
						having sum(case when isnull(source.deal_volume,'''')='''' then 0 else cast(source.deal_volume as float) end)<>sum(isnull(dest.deal_volume,0))

				'
				EXEC('
				INSERT INTO [source_system_data_import_status_vol_detail]
						   ([Process_id]
						   ,[source]
						   ,[type]
						   ,[description]
							,book_id
						   ,commodity
						   ,no_recs
						   ,[Volumn_from]
						   ,[Volumn_to]
							)
						select max('''+@process_id+'''),max(''source_deal_detail''),max(''Data Error''),
						cast(sum(case when isnull(source.deal_volume,'''')='''' then 0 else cast(source.deal_volume as float) end) as varchar(500))+'' Volume imported Successfully out of volume ''+cast(sum(isnull(dest.deal_volume,0)) as varchar(500))+''(No of Records:''+ cast(count(*) as varchar(500))+'')''
						,ssbm.fas_book_id,f.source_commodity_id,count(*) norec,sum(case when isnull(source.deal_volume,'''')='''' then 0 else cast(source.deal_volume as float) end)
						,sum(isnull(dest.deal_volume,0))
						from ' + @temp_table_name + ' source left join
						source_deal_header sdh on source.deal_id=sdh.deal_id and sdh.source_system_id=source.source_system_id
						 inner join
						source_system_book_map ssbm ON 	ssbm.source_system_book_id1 = sdh.source_system_book_id1 AND 
						ssbm.source_system_book_id2 = sdh.source_system_book_id2 AND 
						ssbm.source_system_book_id3 = sdh.source_system_book_id3 AND 
						ssbm.source_system_book_id4 = sdh.source_system_book_id4
						left join source_deal_detail dest on sdh.source_deal_header_id=dest.source_deal_header_id 
						inner join source_price_curve_def on source.[curve_id]=source_price_curve_def.[curve_id] and 
						source.source_system_id=source_price_curve_def.source_system_id 
						left join source_commodity f on
						f.source_commodity_id=source_price_curve_def.commodity_id
						group by ssbm.fas_book_id,source_price_curve_def.source_system_id,f.source_commodity_id
						having sum(case when isnull(source.deal_volume,'''')='''' then 0 else cast(source.deal_volume as float) end)<>sum(isnull(dest.deal_volume,0))
							')
			END
	END -- @exec_mode END

		SELECT @s_tot =ISNULL(ROUND(s_tot,2),0),@d_tot=ISNULL(ROUND(d_tot,2),0) FROM #vol_check
		DROP TABLE #vol_check

		EXEC('INSERT INTO #MTM_detail (total_mtm) 
		select count(*) from ( SELECT count(*) tot FROM '+@temp_table_name +' group by deal_id ) t ')
		SELECT @total_deal_found=ISNULL(total_mtm,0) FROM #MTM_detail
		IF @total_deal_found IS NULL
			SET @total_deal_found=0

		SELECT @total_deals_proceed=ISNULL(tot_deals,0) FROM #total_deals_proceed
		IF @total_deals_proceed IS NULL
			SET @total_deals_proceed=0

		INSERT INTO source_system_data_import_status(process_id,code,MODULE,source,TYPE,[description],recommendation) 
		SELECT @process_id,CASE WHEN @errorcode='e' THEN 'Error' ELSE 'Success' END,
		'Import Data','Position',
		'Import',
		CAST(@count AS VARCHAR)+ ' deal detail records imported successfully out of '+
		CAST(@count_source AS VARCHAR)+' deal detail records
		(Deals '+ CAST(@total_deal_found AS VARCHAR) +' out of '+ CAST(@total_deals_proceed AS VARCHAR) +' successfully updated).'
		--+' Total volume imported is '+STR(@d_tot,18,2)+' out of total volume '+STR(@s_tot,18,2)+'.',
		,CASE WHEN @errorcode='e' THEN 'Please Check your data' ELSE 'N/A' END
	END
	ELSE IF @table_id='4006'
	BEGIN
		
		IF ISNULL(@dbase_name,'')<>''
		BEGIN

		EXEC spa_print 'insert into	#vol_check1
				select sum(case when isnull(source.[und_pnl],'''')='''' then 0 else cast(source.[und_pnl] as float) end) 
				,sum(isnull(dest.[und_pnl],0))
				, count(*)
				from ', @temp_table_name, ' source left join
				source_deal_header sdh on source.source_deal_header_id=sdh.deal_id and sdh.source_system_id=source.source_system_id
				LEFT join ', @dbase_name, ' dest on sdh.source_deal_header_id=dest.source_deal_header_id 
				and source.term_start=dest.term_start and source.term_end=dest.term_end
				--and source.leg=dest.leg 
				and source.pnl_as_of_date=dest.pnl_as_of_date 
			'
		EXEC('UPDATE #vol_check1 SET d_tot=a.d_tot,norec=a.norec						
				FROM(
					select sum(case when isnull(source.[und_pnl],'''')='''' then 0 else cast(source.[und_pnl] as float) end) d_tot 
					, count(*) norec
					from ' + @temp_table_name + ' source LEFT join
				source_deal_header sdh on source.source_deal_header_id=sdh.deal_id and sdh.source_system_id=source.source_system_id
				left join '+@dbase_name+' dest on sdh.source_deal_header_id=dest.source_deal_header_id 
				and source.term_start=dest.term_start and source.term_end=dest.term_end
					--and source.leg=dest.leg 
				and source.pnl_as_of_date=dest.pnl_as_of_date 
				) a
			')
		
		IF ISNULL(@exec_mode,0)<> 1 -- If not essent
		BEGIN
			IF EXISTS( SELECT * FROM #vol_check1 WHERE ROUND(s_tot,2)<>ROUND(d_tot,2))
			BEGIN
--				INSERT INTO [source_system_data_import_status_vol]
--						   ([Process_id]
--						   ,[code]
--						   ,[module]
--						   ,[source]
--						   ,[type]
--						   ,[description]
--						   ,[recommendation]
--						   ,[Volumn_from]
--						   ,[Volumn_to],create_ts)
--					select @process_id,'Error','ImportData','source_deal_pnl','Data Error',
--					cast(CAST(d_tot AS MONEY) as varchar(100))+' PNL value imported Successfully out of PNL value '+cast(CAST(s_tot AS MONEY) as varchar(100))+'(No of Deals:'+ cast(norec as varchar(100))+')','Please Check your data'
--				,s_tot,d_tot,GETDATE() from #vol_check1
				EXEC spa_print'
				INSERT INTO [source_system_data_import_status_vol_detail]
						   ([Process_id]
						   ,[source]
						   ,[type]
						   ,[description]
							,book_id
							,no_recs
						   ,[Volumn_from]
						   ,[Volumn_to],create_ts
						)
						select max(''', @process_id, '''),max(''source_deal_detail''),max(''Data Error'')
						,cast(sum(case when isnull(source.deal_volume,'''')='''' then 0 else cast(source.deal_volume as float) end) as varchar)+'' Volume imported Successfully out of volume ''+cast(sum(isnull(dest.deal_volume,0)) as varchar)+''(No of Deals:''+ cast(count(*) as varchar)+'')''
						,ssbm.fas_book_id,count(*) norec
						sum(case when isnull(source.[und_pnl],'''')='''' then 0 else cast(source.[und_pnl] as float) end) 
						+sum(case when isnull(source.[und_extrinsic_pnl],'''')='''' then 0 else cast(source.[und_extrinsic_pnl] as float) end)
						+sum(case when isnull(source.und_intrinsic_pnl,'''')='''' then 0 else cast(source.und_intrinsic_pnl as float) end)
						,sum(isnull(dest.[und_pnl],0)) +sum(isnull(dest.[und_extrinsic_pnl],0))+sum(isnull(dest.und_intrinsic_pnl,0)),getdate()
						from ', @temp_table_name, ' source left join
						source_deal_header sdh on source.source_deal_header_id=sdh.deal_id and  source.source_system_id = sdh.source_system_id inner join
						source_system_book_map ssbm ON 	ssbm.source_system_book_id1 = sdh.source_system_book_id1 AND 
						ssbm.source_system_book_id2 = sdh.source_system_book_id2 AND 
						ssbm.source_system_book_id3 = sdh.source_system_book_id3 AND 
						ssbm.source_system_book_id4 = sdh.source_system_book_id4
						left join ', @dbase_name, ' dest on sdh.source_deal_header_id=dest.source_deal_header_id 
						and source.term_start=dest.term_start and source.term_end=dest.term_end
						and source.leg=dest.leg 
						and source.pnl_as_of_date=dest.pnl_as_of_date 
						group by ssbm.fas_book_id
						having 	(sum(case when isnull(source.[und_pnl],'''')='''' then 0 else cast(source.[und_pnl] as float)end) 
						+sum(case when isnull(source.[und_extrinsic_pnl],'''')='''' then 0 else cast(source.[und_extrinsic_pnl] as float) end)
						+sum(case when isnull(source.und_intrinsic_pnl,'''')='''' then 0 else cast(source.und_intrinsic_pnl as float) end)
						)<>(sum(isnull(dest.[und_pnl],0)) +sum(isnull(dest.[und_extrinsic_pnl],0))+sum(isnull(dest.und_intrinsic_pnl,0)))

				'

				EXEC('
				INSERT INTO [source_system_data_import_status_vol_detail]
						   ([Process_id]
						   ,[source]
						   ,[type]
						   ,[description]
							,book_id
						   ,[Volumn_from]
						   ,[Volumn_to]
						)
						select max('''+@process_id+'''),max(''source_deal_detail''),max(''Data Error'')
						,cast(sum(case when isnull(source.deal_volume,'''')='''' then 0 else cast(source.deal_volume as float) end) as varchar)+'' Volume imported Successfully out of volume ''+cast(sum(isnull(dest.deal_volume,0)) as varchar)+''(No of Records:''+ cast(count(*) as varchar)+'')''
						,ssbm.fas_book_id,
						sum(case when isnull(source.[und_pnl],'''')='''' then 0 else cast(source.[und_pnl] as float) end) 
						+sum(case when isnull(source.[und_extrinsic_pnl],'''')='''' then 0 else cast(source.[und_extrinsic_pnl] as float) end)
						+sum(case when isnull(source.und_intrinsic_pnl,'''')='''' then 0 else cast(source.und_intrinsic_pnl as float) end)
						,sum(isnull(dest.[und_pnl],0)) +sum(isnull(dest.[und_extrinsic_pnl],0))+sum(isnull(dest.und_intrinsic_pnl,0))
						from '+@temp_table_name+' source left join
						source_deal_header sdh on source.source_deal_header_id=sdh.deal_id  and source.source_system_id = sdh.source_system_id inner join
						source_system_book_map ssbm ON 	ssbm.source_system_book_id1 = sdh.source_system_book_id1 AND 
						ssbm.source_system_book_id2 = sdh.source_system_book_id2 AND 
						ssbm.source_system_book_id3 = sdh.source_system_book_id3 AND 
						ssbm.source_system_book_id4 = sdh.source_system_book_id4
						left join '+@dbase_name+' dest on sdh.source_deal_header_id=dest.source_deal_header_id 
						and source.term_start=dest.term_start and source.term_end=dest.term_end
						and source.leg=dest.leg 
						and source.pnl_as_of_date=dest.pnl_as_of_date 
						group by ssbm.fas_book_id
						having 	(sum(case when isnull(source.[und_pnl],'''')='''' then 0 else cast(source.[und_pnl] as float)end) 
						+sum(case when isnull(source.[und_extrinsic_pnl],'''')='''' then 0 else cast(source.[und_extrinsic_pnl] as float) end)
						+sum(case when isnull(source.und_intrinsic_pnl,'''')='''' then 0 else cast(source.und_intrinsic_pnl as float) end)
						)<>(sum(isnull(dest.[und_pnl],0)) +sum(isnull(dest.[und_extrinsic_pnl],0))+sum(isnull(dest.und_intrinsic_pnl,0)))
				')

			END
		END -- @exec_mode END		
		END
		ELSE
			EXEC('insert into	#vol_check1
					select sum(case when isnull(source.[und_pnl],'''')='''' then 0 else cast(source.[und_pnl] as float) end) 
					,0
					, count(*)
					from ' + @temp_table_name + ' source inner join
					source_deal_header sdh on source.source_deal_header_id=sdh.deal_id and sdh.source_system_id=source.source_system_id 
				')

		SELECT @s_tot =ISNULL(ROUND(s_tot,2),0),@d_tot=ISNULL(ROUND(d_tot,2),0) FROM #vol_check1
		DROP TABLE #vol_check1

		EXEC('INSERT INTO #MTM_detail (total_mtm) SELECT sum(und_pnl) FROM '+@temp_table_name)
		SELECT @total_mtm=ISNULL(total_mtm,0) FROM #MTM_detail
		IF @total_mtm IS NULL
			SET @total_mtm=0

		DELETE #MTM_detail
		EXEC('INSERT INTO #MTM_detail (total_mtm) 
		select count(*) from ( SELECT count(*) tot FROM '+@temp_table_name +' group by source_deal_header_id ) t ')
		SELECT @total_deal_found=ISNULL(total_mtm,0) FROM #MTM_detail
		IF @total_deal_found IS NULL
			SET @total_deal_found=0

		SELECT @total_deals_proceed=ISNULL(tot_deals,0) FROM #total_deals_proceed
		IF @total_deals_proceed IS NULL
			SET @total_deals_proceed=0

		DROP TABLE #MTM_detail

		INSERT INTO source_system_data_import_status(process_id,code,MODULE,source,TYPE,[description],recommendation) 
		SELECT @process_id,CASE WHEN @errorcode='e' THEN 'Status' ELSE 'Success' END,
		'Import Data','MTM',
		'Import',
		CAST(@count AS VARCHAR)+ CASE WHEN @exec_mode = 6 THEN ' forward' ELSE '' END + ' MTM records imported successfully out of '+
		CAST(@count_source AS VARCHAR)+' records.(Deals '+ CAST(@total_deal_found AS VARCHAR) + CASE WHEN @exec_mode = 6 THEN ' with forward data' ELSE '' END  + ' out of '+ CAST(@total_deals_proceed AS VARCHAR) +' with MTM value '+ 
		LTRIM(STR(@total_mtm, 100, 2))   +' imported)'
		+ CASE WHEN ISNULL(@exec_mode,0)= 1 THEN '' ELSE ' Total MTM imported is '+STR(@d_tot,18,2)+' out of total MTM '+STR(@s_tot,18,2)+'.' END,
		CASE WHEN @errorcode='e' THEN 'Please Check your data' ELSE 'N/A' END
	END
	ELSE IF @table_id='4008'
	BEGIN
		EXEC spa_print'
		insert into	#vol_check select sum(case when isnull(source.curve_value,'''')='''' then 0 else cast(source.curve_value as numeric(18,2)) end)
					,sum(isnull(cast(e.curve_value as numeric(18,2)),0)),count(*)
					from ', @temp_table_name, ' source 
					left join	source_price_curve_def b ON 
						source.source_curve_def_id = b.curve_id AND 
						source.source_system_id = b.source_system_id 
					left JOIN static_data_value d ON 
						source.curve_source_value_id = d.value_id 
					left join source_price_curve e on 
						e.source_curve_def_id=b.source_curve_def_id and 
						b.curve_id=source.source_curve_def_id and 
						b.source_system_id=source.source_system_id and 
						e.as_of_date=cast(source.as_of_date as datetime) and
						e.curve_source_value_id=source.curve_source_value_id and
      					e.maturity_date=CAST(dbo.FNAGetSQLStandardDate(CAST(source.maturity_date AS DATETIME)) + '' '' + ISNULL(source.maturity_hour, ''00:00'') + '':00'' AS DATETIME)'         
		
	
		
		EXEC('
		UPDATE #vol_check SET d_tot = a.d_tot, norec = a.norec 
		FROM (
			--INSERT INTO #vol_check SELECT SUM(CASE WHEN ISNULL(source.curve_value, '''') = '''' THEN 0 ELSE CAST(source.curve_value AS numeric(18,2)) END)
			SELECT 		
			SUM(ISNULL(CAST(e.curve_value AS NUMERIC(18, 2)), 0)) d_tot, COUNT(*) norec
					FROM ' + @temp_table_name + ' source 
					LEFT JOIN source_price_curve_def b ON 
						source.source_curve_def_id = b.curve_id AND 
						source.source_system_id = b.source_system_id 
					LEFT JOIN source_price_curve e ON e.source_curve_def_id = b.source_curve_def_id 
						AND b.curve_id = source.source_curve_def_id 
						AND b.source_system_id = source.source_system_id 
						AND e.as_of_date = CAST(source.as_of_date AS datetime)
						AND e.curve_source_value_id = source.curve_source_value_id 
						AND e.is_dst = ISNULL(source.is_dst,0)
					    AND e.maturity_date = CAST(dbo.FNAGetSQLStandardDate(CAST(source.maturity_date AS DATETIME)) + '' '' + ISNULL(source.maturity_hour, ''00:00'') + '':00'' AS DATETIME)
			) a'
		)
		
		IF ISNULL(@exec_mode,0)<> 1 -- If not Essent Interface
		BEGIN
			IF EXISTS( SELECT * FROM #vol_check WHERE (ROUND(s_tot,0)-ROUND(d_tot,0))>2)
			BEGIN
				INSERT INTO [source_system_data_import_status_vol]
						   ([Process_id]
						   ,[code]
						   ,[MODULE]
						   ,[source]
						   ,[TYPE]
						   ,[description]
						   ,[recommendation]
						   ,[Volumn_from]
						   ,[Volumn_to]
						   ,create_ts)
				SELECT @process_id,'Error','ImportData','source_price_curve','Data Error',
					STR(d_tot,18,0)+' price curve imported Successfully out of price '+STR(s_tot,18,0)+'(No of Records:'+ CAST(norec AS VARCHAR)+')','Please Check your data'
					,s_tot,d_tot,GETDATE() FROM #vol_check WHERE  ROUND(s_tot,0)<>ROUND(d_tot,0)

			
				EXEC('
				INSERT INTO [source_system_data_import_status_vol_detail]
						   ([Process_id]
						   ,[source]
						   ,[type]
						   ,[description]
						   ,commodity
						   ,no_recs
						   ,[Volumn_from]
						   ,[Volumn_to]
							)
						select max('''+@process_id+'''),max(''source_price_curve''),max(''Data Error''),
						cast(sum(case when isnull(source.curve_value,'''')='''' then 0 else cast(source.curve_value as float) end) as varchar)+'' price curve imported Successfully out of price ''+cast(sum(isnull(e.curve_value,0)) as varchar)+''.''
						,f.source_commodity_id,count(*) norec,sum(case when isnull(source.curve_value,'''')='''' then 0 else cast(source.curve_value as float) end)
						,sum(isnull(e.curve_value,0))
						from ' + @temp_table_name + ' source
					left join	source_price_curve_def b ON 
						source.source_curve_def_id = b.curve_id AND 
						source.source_system_id = b.source_system_id 
					left JOIN static_data_value d ON 
						source.curve_source_value_id = d.value_id 
					left join source_price_curve e on 
						e.source_curve_def_id=b.source_curve_def_id and 
						b.curve_id=source.source_curve_def_id and 
						b.source_system_id=source.source_system_id and 
						e.as_of_date=cast(source.as_of_date as datetime) and
						e.curve_source_value_id=source.curve_source_value_id and
						e.maturity_date=cast(source.maturity_date as datetime)	
					left join source_commodity f on
						f.source_commodity_id=b.commodity_id
						group by f.source_commodity_id
						having sum(case when isnull(source.curve_value,'''')='''' then 0 else cast(source.curve_value as float) end)<>sum(isnull(e.curve_value,0))
							')
			END
		END -- @exec_mode END
		SELECT @s_tot =ISNULL(ROUND(s_tot,0),0),@d_tot=ISNULL(ROUND(d_tot,0),0) FROM #vol_check
		DROP TABLE #vol_check


	
		-- source should be null for CMA Import		
		INSERT INTO source_system_data_import_status(process_id,code,MODULE,source,TYPE,[description],recommendation) 
		SELECT @process_id,CASE WHEN @errorcode='e' THEN 'Error' ELSE 'Success' END,
		@import_status_module, CASE WHEN COL_LENGTH(@temp_table_name, 'file_name') IS NULL THEN 'source_price_curve' ELSE NULL END,
		CASE WHEN @errorcode='e' THEN 'Data Error' ELSE 'Import Success' END,
		CAST(@count AS VARCHAR)+ ' price curve records imported successfully out of '+
		CAST(@count_source AS VARCHAR)+' price curve records.'
		+' Total price '+STR(@d_tot,18,2)+' imported of '+STR(@s_tot,18,2)+'.',
		CASE WHEN @errorcode='e' THEN 'Please Check your data' ELSE 'N/A' END
	END
	ELSE
	BEGIN
		INSERT INTO source_system_data_import_status(process_id,code,module,source,TYPE,[description],recommendation) 
		SELECT @process_id,CASE WHEN tot.totcount-@count>0 THEN 'Error' ELSE 'Success' END,'Import Data',tot.source,CASE WHEN tot.totcount-@count>0 THEN 'Data Error' ELSE 'Import Success' END,
		CAST(@count AS VARCHAR)+ ' Data imported Successfully out of '+ 
		CAST(tot.totcount AS VARCHAR)+' rows.',
		CASE WHEN tot.totcount-@count>0 THEN 'Please Check your data' ELSE 'N/A' END FROM #temp_tot_count tot
	END 
	IF @count_source-@count >0
	BEGIN
		INSERT INTO source_system_data_import_status(process_id,code,MODULE,source,TYPE,
		[description],recommendation) 
		SELECT @process_id,MAX(ErrorCode),'Import Data','Static_Data',MAX([TYPE]),
		type_error,
		'Please Check your data (' +CAST(COUNT(*) AS VARCHAR) +' row effected)' FROM #import_status 
		WHERE type_error IS NOT NULL GROUP BY type_error
	END 
END
EXEC spa_print @count
	
IF @schedule_run='n'
BEGIN
			
	IF @count_source=0
	BEGIN
		INSERT INTO source_system_data_import_status(process_id,code,MODULE,source,TYPE,[description],recommendation) 
		SELECT @process_id,'Warning','Import Data',@tablename,'Data Warning','No data found in staging table.','Please verify data.'
		INSERT INTO source_system_data_import_status_detail(process_id,source,TYPE,[description]) 
		SELECT @process_id,@tablename,'Data Warning','Staging Table is empty.'
		SET @errorcode='e'
	END

	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
		'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''

	SELECT @desc = '<a target="_blank" href="' + @url + '">' + 
				'Import process Completed for as of date:' + dbo.FNAUserDateFormat(GETDATE(), @user_login_id) + 
			CASE WHEN (@errorcode = 'e') THEN ' (ERRORS found)' ELSE '' END +
			'.</a>'
	IF ISNULL(@exec_mode,0)<> 1	
		EXEC  spa_message_board 'u', @user_login_id,NULL, 'Import Data',@desc, '', '', @errorcode, @job_name,NULL,@process_id, NULL, 'n'
		
	UPDATE import_data_files_audit
		SET	status=@errorcode,
			elapsed_time=DATEDIFF(ss,create_ts,GETDATE())
		WHERE process_id=@process_id
END
ELSE
BEGIN
	IF @count_source=0
	BEGIN

			INSERT INTO source_system_data_import_status(process_id,code,MODULE,source,TYPE,[description],recommendation) 
			SELECT @process_id,'Warning','Import Data',@tablename,'Data Warning','No data found.',
			'Possible causes: No Index found in the system'
			INSERT INTO source_system_data_import_status_detail(process_id,source,TYPE,[description]) 
			SELECT @process_id,@tablename,'Data Warning','Possible cause: No Index found in the system'

	END

	DELETE source_system_data_import_status_detail  FROM source_system_data_import_status_detail s INNER JOIN import_data_files_audit a
		ON s.process_id=a.process_id WHERE a.create_ts<  DATEADD(MONTH,-6,GETDATE())		
	DELETE source_system_data_import_status  FROM source_system_data_import_status s INNER JOIN import_data_files_audit a
		ON s.process_id=a.process_id WHERE a.create_ts<  DATEADD(MONTH,-6,GETDATE())	
	DELETE import_data_files_audit WHERE create_ts<  DATEADD(MONTH,-6,GETDATE())		
	
END

IF @import_from IS NOT NULL
BEGIN
	UPDATE source_system_data_import_status_detail SET [TYPE]=@import_from WHERE process_id=@process_id AND ([TYPE]='Data Error' OR [TYPE]='Data Warning')
	UPDATE source_system_data_import_status SET [MODULE]=@import_from WHERE process_id=@process_id AND [MODULE] LIKE 'Import%'
	
	UPDATE source_system_data_import_status_vol_detail SET [TYPE]=@import_from WHERE process_id=@process_id AND ([TYPE]='Data Error' OR [TYPE]='Data Warning')
	UPDATE source_system_data_import_status_vol SET [MODULE]=@import_from WHERE process_id=@process_id AND [MODULE] LIKE 'Import%'

END

IF @generic_mapping_flag IS NOT NULL AND @rules_id IS NOT NULL
BEGIN
	--SELECT 1
	--PRINT('after-trigger')
	DECLARE @after_trigger VARCHAR(MAX)	
	
	IF @generic_mapping_flag = 'a'
	BEGIN
		SELECT @after_trigger  = ir.after_insert_trigger FROM ixp_rules ir WHERE ir.ixp_rules_id = @rules_id	
	END
	ELSE
	BEGIN
		DECLARE @ixp_rules VARCHAR(300)
		DECLARE @trigger_output INT
		SET @ixp_rules = dbo.FNAProcessTableName('ixp_rules', @user_login_id, @process_id)
		
		CREATE TABLE #temp_rules (after_insert_trigger VARCHAR(MAX) COLLATE DATABASE_DEFAULT)
		SET @sql = 'INSERT INTO #temp_rules(after_insert_trigger) SELECT after_insert_trigger FROM ' + @ixp_rules + ' WHERE ixp_rules_id = ' + CAST(@rules_id AS VARCHAR(10))
		EXEC(@sql)
		
		SELECT @after_trigger = ir.after_insert_trigger
		FROM   #temp_rules ir
	END
	
	IF @after_trigger IS NOT NULL
	BEGIN
		--SELECT @after_trigger
		exec spa_print 'after-trigger'
		EXEC spa_import_trigger 'a', @after_trigger, @process_id, @trigger_output OUTPUT
	END
END


SET @sql=dbo.FNAProcessDeleteTableSql(@temp_table_name)
--exec(@sql)
SET @sql=dbo.FNAProcessDeleteTableSql(@field_compare_table)
EXEC(@sql)
SET @sql=dbo.FNAProcessDeleteTableSql(@temp_for_delete)
EXEC(@sql)
--drop table #import_status

DELETE [source_system_data_import_status_vol_detail] WHERE create_ts<  DATEADD(MONTH,-6,GETDATE())
DELETE [source_system_data_import_status_vol] WHERE create_ts<  DATEADD(MONTH,-6,GETDATE())

--end try
--begin catch
--	
--	set @desc='SQL Error found:  (' + ERROR_MESSAGE() + ')'
--	exec spa_print 'Error: ' + @desc
--
--	insert into source_system_data_import_status(process_id,code,module,source,type,
--	[description],recommendation) 
--	select @process_id,'Error','Import Data',@tablename,
--	'Data Error',
--	@desc,'Please check your data format.'
--	
--	EXEC  spa_message_board 'i', @user_login_id, NULL, 'ImportData',  @desc, '', '', 'e', @job_name,
--	null,@process_id	
--end catch
--
--
--SET ANSI_NULLS ON
--
--GO


GO


