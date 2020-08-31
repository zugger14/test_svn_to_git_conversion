IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Reconcile_GIS_Transactions]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Reconcile_GIS_Transactions]
GO 

-- -- -- 
-- -- -- exec spa_Reconcile_GIS_Transactions 'farrms_admin', 'adiha_process.dbo.gis_rec_transaction_farrms_admin_F0A36B53_6140_4C3F_BAF6_C2099530D0EF', 
-- -- -- null, null, null, null, 'xfds2', '523432'
-- -- -- 
CREATE PROC [dbo].[spa_Reconcile_GIS_Transactions]  @user_id varchar(50),
						@table_name varchar(100) = null,
						@gen_date_from  varchar(20) = null,
						@gen_date_to  varchar(20) = null,
						@generator_id  int = null,
						@gis_value_id int = null,
						@process_id varchar(100),
						@job_name varchar(100)

AS

--spa_Reconcile_GIS_Transactions
--truncate table gis_reconcillation
--truncate table gis_inventory_prior_month_adjustements
--============TEST DATA===============
-- declare	@user_id varchar(50)
-- declare	@gen_date_from  varchar(20) 
-- declare	@gen_date_to  varchar(20) 
-- declare	@generator_id  int
-- declare	@gis_value_id int
-- declare @process_id varchar(100)
-- declare @job_name varchar(100)
-- declare @table_name varchar(200)
-- 
-- -- set @gen_date_from = '2006-01-01'
-- -- set @gen_date_to = '2006-01-31'
-- set @table_name ='adiha_process.dbo.gis_rec_transaction_farrms_admin_4434DA9B_7489_47B2_8E69_AFCD6699F1E1'
-- set @process_id ='tttt'
-- set @user_id = 'farrms_admin'
-- -- 
-- -- --drop table #gis
-- -- --drop table #deal
-- -- --drop table #missing_gen
--   drop table #GISTransactions
--  drop table #GIS_Reconcile
--============END OF TEST DATA===============
DECLARE @term_start varchar(20)
DECLARE @gen_id int
DECLARE @generator varchar(50)
--DECLARE @structured_deal_id varchar(50)
DECLARE @drop_table varchar(1)
DECLARE @counts int
DECLARE @url varchar(500)
DECLARE @urlP varchar(500)
DECLARE @url_desc varchar(8000)
DECLARE @user_name varchar(50)
DECLARE @desc varchar(8000)
DECLARE @error_count  int
DECLARE @type char


set @drop_table = 'n'

SET @user_name = @user_id
-- SET @url = './dev/spa_html.php?__user_name__=' + @user_name + 
-- 	'&spa=exec spa_gis_reconcillation_log ''' + @process_id + ''''

-----------=====================================INSERT DATA TO PROCESSS-----------------------
----------------------------------------------------------------------------------------------

--create  temp table


--FIRST, INSERT DETAILED AVIALBLE RECORDS

CREATE TABLE #GISTransactions (
	[Type] [varchar] (255),
	[Feeder System ID] int,
	[Gen Date From] [varchar] (255) COLLATE DATABASE_DEFAULT,
	[Gen Date To] [varchar] (255) COLLATE DATABASE_DEFAULT,
	[Volume] [varchar] (255) COLLATE DATABASE_DEFAULT,
	[UOM] [varchar] (255) COLLATE DATABASE_DEFAULT,
	[Generator_id] int,
	[GIS] [varchar] (255) COLLATE DATABASE_DEFAULT,
	[GIS Certificate Number] [varchar] (255) COLLATE DATABASE_DEFAULT,
	[GIS Certificate Number To] [varchar] (255) COLLATE DATABASE_DEFAULT,
	[GIS Certificate Date] [varchar] (255) COLLATE DATABASE_DEFAULT,
	Certificate_From int,
	Certificate_To int,
	Certificate_Format varchar(200) COLLATE DATABASE_DEFAULT,
	Facility_id varchar(50) COLLATE DATABASE_DEFAULT
) 

IF @table_name IS NULL
BEGIN 
	return
-- 	INSERT INTO #GISTransactions
-- 	SELECT  Type, cast([Feeder System ID] as int) AS [Feeder System ID], [Gen Date From], [Gen Date To], Volume, UOM, Generator, GIS, 
-- 		[GIS Certificate Number], [GIS Certificate Number To], [GIS Certificate Date]
-- 	--INTO #GISTransactions
-- 	FROM GISTransactions
--	WHERE ISNULL([Type], 'DETAIL') = 'DETAIL' 

END
ELSE
BEGIN
	exec(' insert into gis_reconcillation_log
	select '''+ @process_id +''', ''Error'', ''GIS Recon'', ''spa_Reconcile_GIS_Transactions'', 
		''REC'', ''Generator code: <b> ''+ t.generator +''</b> not found in our system'',
	''Please fix the data issue.'', null,null,null, null 
	from ' + @table_name +' t left outer join rec_generator rg on rg.code=t.generator
	where rg.generator_id is null')

	exec(' insert into gis_reconcillation_log
	select '''+ @process_id +''', ''Error'', ''GIS Recon'', ''spa_Reconcile_GIS_Transactions'', 
		''REC'', ''GIS System: <b>''+ t.GIS +''</b> not found  in our system'',
	''Please fix the data issue.'', null,null,null, null 
	from ' + @table_name +' t left outer join static_data_value sdv on sdv.type_id=10011 and sdv.code=t.gis
	where sdv.value_id is null')


	exec('INSERT INTO #GISTransactions
	SELECT  Type, [Feeder_System_ID] , [Gen_Date_From], [Gen_Date_To], Volume, UOM, rg.generator_id,sdv.value_id GIS, 
		[GIS_Certificate_Number], [GIS_Certificate_Number_To], [GIS_Certificate_Date],
		dbo.FNACertificateRuleParse(c.cert_rule,[GIS_Certificate_Number]),
		dbo.FNACertificateRuleParse(c.cert_rule,[GIS_Certificate_Number_To]),
		c.cert_rule,rg.id
	FROM ' + @table_name +' t join rec_generator rg on rg.code=t.generator
	join static_data_value sdv on sdv.type_id=10011 and sdv.code=t.gis
	join certificate_rule c on sdv.value_id = c.gis_id
	')

END


DECLARE @p_type varchar(255)
DECLARE @date_from varchar(255)
DECLARE @date_to varchar(255)
DECLARE @tot_volume varchar(255)
DECLARE @volume_uom varchar(255)
DECLARE @gen_code varchar(255)
DECLARE @gis_code varchar(255)
DECLARE @cert_from int
DECLARE @cert_to int
-- DECLARE @cert_from varchar(255)
-- DECLARE @cert_to varchar(255)
DECLARE @cert_date varchar(255)
-- select * from gis_inventory_prior_month_adjustements
-- select * from #GISTransactions

-- Need to join 	
-- delete from gis_inventory_prior_month_adjustements
-- where contract_month between cast(@gen_date_from as datetime) and cast(@gen_date_to as datetime)
delete gis_inventory_prior_month_adjustements
from gis_inventory_prior_month_adjustements g join #GISTransactions t
on g.generator_id=t.[Generator_id] and g.gen_date_from between t.[gen date from] and t.[gen date to]

-- Same as  above
-- SELECT * from gis_reconcillation
-- where isnull(term_start, gis_gen_date) between cast(@gen_date_from as datetime) and cast(@gen_date_to as datetime)
delete gis_reconcillation
from gis_reconcillation g join #GISTransactions t
on g.generator_id=t.[Generator_id] and g.term_start between t.[gen date from] and t.[gen date to]


CREATE TABLE [#GIS_Reconcile] (
	temp_id int identity, 
	[Type] [varchar] (255)NULL ,
	[Feeder System ID] [int] NULL ,
	[Gen Date From] [datetime]  NULL ,
	[Gen Date To] [datetime]  NULL ,
	[Volume] [varchar] (255) NULL ,
	[UOM] [varchar] (255) NULL ,
	[Generator_id] [int] NULL ,
	[GIS] [varchar] (255) NULL ,
	[GIS Certificate Number] [varchar] (255) NULL ,
	[GIS Certificate Number To] [varchar] (255) NULL ,
	[GIS Certificate Date] [varchar] (255) NULL ,
	Certificate_From int NULL,
	Certificate_to int null,
	Certificate_format varchar(200),
	facility_id varchar(50),
	[source_deal_header_id] [int] NOT NULL ,
	[deal_volume] [float] NOT NULL ,
	[Reconcile_volume] [float] NULL
	
) ON [PRIMARY]
-- GO

--select * from #GIS_Reconcile

--print '11111111'
--Get the Reconcile Volume
 insert into #GIS_Reconcile(Type, [Feeder System ID] , [Gen Date From], [Gen Date To], Volume, UOM, rg.generator_id,GIS,
  [GIS Certificate Number], [GIS Certificate Number To], [GIS Certificate Date],Certificate_From,Certificate_to,Certificate_format,
 facility_id, source_deal_header_id,deal_volume,Reconcile_volume )
select g.*,sdd1.source_deal_detail_id,deal_volume,
case when 
	(select sum(deal_volume) from 
	#GISTransactions gis join source_deal_header d join source_deal_detail sdd on d.source_deal_header_id=sdd.source_deal_header_id
	on gis.generator_id=d.generator_id --and gis.[gen date from]=sdd.term_start and gis.[gen date to]=sdd.term_end 
		and sdd.term_start between cast(gis.[gen date from] as datetime) and cast(gis.[gen date to] as  datetime) and
		sdd.term_end between cast(gis.[gen date from] as datetime) and cast(gis.[gen date to] as  datetime)
	where sdd.source_deal_detail_id<=sdd1.source_deal_detail_id and (gis.[gen date from]=g.[gen date from]  
		and gis.[gen date to]=g.[gen date to]))-g.volume<=0 
	then
	deal_volume 
	else 
		deal_volume-((select sum(deal_volume) from 
		#GISTransactions gis join source_deal_header d join source_deal_detail sdd on d.source_deal_header_id=sdd.source_deal_header_id
		on gis.generator_id=d.generator_id --and gis.[gen date from]=sdd.term_start and gis.[gen date to]=sdd.term_end 
		and sdd.term_start between cast(gis.[gen date from] as datetime) and cast(gis.[gen date to] as  datetime) and
		sdd.term_end between cast(gis.[gen date from] as datetime) and cast(gis.[gen date to] as  datetime)
		where sdd.source_deal_detail_id<=sdd1.source_deal_detail_id
		and (gis.[gen date from]=g.[gen date from]  and gis.[gen date to]=g.[gen date to])
		)-g.volume) 
	end
	Reconcile_volume
from #GISTransactions g join source_deal_header dh 
join source_deal_detail sdd1 on dh.source_deal_header_id=sdd1.source_deal_header_id
on g.generator_id=dh.generator_id and sdd1.term_start between cast(g.[gen date from] as datetime) and cast(g.[gen date to] as  datetime) and
sdd1.term_end between cast(g.[gen date from] as datetime) and cast(g.[gen date to] as  datetime)
order by sdd1.term_start,sdd1.source_deal_detail_id

--select * from #GIS_Reconcile
--Insert Match GIS Certificate
insert into gis_reconcillation(process_id,source_deal_header_id,generator_id,term_start,term_end,
gis_value_id,gis_cert_date,gis_cert_number,gis_cert_number_to,Certificate_From,Certificate_To,match_volume)
select  @process_id,source_deal_header_id,generator_id,[gen date from],[gen date to],gis,[gis certificate date],
dbo.FNACertificateRule(certificate_format,facility_id,
(select sum(reconcile_volume) from #GIS_Reconcile where temp_id<=g.temp_id and [gen date from]=g.[gen date from] and [gen date to]=g.[gen date to])+[Certificate_From]-reconcile_volume
,[gen date from]),
dbo.FNACertificateRule(certificate_format,facility_id,
(select sum(reconcile_volume) from #GIS_Reconcile where temp_id<=g.temp_id and [gen date from]=g.[gen date from] and [gen date to]=g.[gen date to])+[Certificate_From]-1,[gen date from]) ,
(select sum(reconcile_volume) from #GIS_Reconcile where temp_id<=g.temp_id and [gen date from]=g.[gen date from] and [gen date to]=g.[gen date to])+[Certificate_From]-reconcile_volume,
(select sum(reconcile_volume) from #GIS_Reconcile where temp_id<=g.temp_id and [gen date from]=g.[gen date from] and [gen date to]=g.[gen date to])+[Certificate_From]-1, reconcile_volume 
from #GIS_Reconcile g
where reconcile_volume > 0
order by temp_id

--select * from gis_reconcillation
--return
--RETURN
-- UNMATCH GIS certificate Under

insert into gis_inventory_prior_month_adjustements(process_id,source_deal_header_id,generator_id,gen_date_from,gen_date_to,
gis_value_id,original_volume,change_volume_to,comment)
select @process_id,source_deal_header_id,generator_id,[gen date from],[gen date to],gis,deal_volume,
case when reconcile_volume < 0 then 0 else reconcile_volume end,'GIS Recon - Over' from #GIS_Reconcile
where reconcile_volume < deal_volume
order by [gen date from],source_deal_header_id

--select * from #GIS_Reconcile

-- UNMATCH GIS Certificate Over
-- select * from gis_inventory_prior_month_adjustements
-- select * from gis_reconcillation
-- return
--order by g.[gen date from],source_deal_header_id

declare @term_end varchar(20),  @volume int
declare @total_reconcile int,@max_deal int


DECLARE b_cursor CURSOR FOR
select 	DISTINCT dbo.FNAGetContractMonth([Gen Date From]),[Gen Date To], generator_id, Volume
from 	#GISTransactions
OPEN b_cursor
FETCH NEXT FROM b_cursor
INTO @term_start,@term_end, @gen_id, @volume
WHILE @@FETCH_STATUS = 0   
BEGIN 
	select @total_reconcile=sum(Reconcile_volume),@max_deal=max(temp_id) from #GIS_Reconcile
	where generator_id=@gen_id and [gen date from]=@term_start and [gen date to]=@term_end
--	select @volume,@total_reconcile
	if  @volume > @total_reconcile
	begin
		update #GIS_Reconcile
		set reconcile_volume=reconcile_volume+(@volume-@total_reconcile)
		where temp_id=@max_deal

-- 		insert into gis_inventory_prior_month_adjustements(process_id,source_deal_header_id,generator_id,gen_date_from,gen_date_to,
-- 		gis_value_id,original_volume,change_volume_to,comment)
-- 		select @process_id,source_deal_header_id,generator_id,[gen date from],[gen date to],gis,deal_volume,
-- 		reconcile_volume,'GIS Recon - Over' from #GIS_Reconcile
-- 		where temp_id=@max_deal
-- 		order by [gen date from],source_deal_header_id
	end
	FETCH NEXT FROM b_cursor
INTO @term_start,@term_end, @gen_id, @volume
END
CLOSE b_cursor
DEALLOCATE  b_cursor

insert into gis_inventory_prior_month_adjustements(process_id,source_deal_header_id,generator_id,gen_date_from,gen_date_to,
gis_value_id,original_volume,change_volume_to,comment)
select @process_id,source_deal_header_id,generator_id,[gen date from],[gen date to],gis,deal_volume,
reconcile_volume,'GIS Recon - Under' from #GIS_Reconcile
where reconcile_volume > deal_volume
order by [gen date from],source_deal_header_id

-- select * from #GIS_Reconcile
-- select * from gis_inventory_prior_month_adjustements

declare @counts_process int,@detail_errorMsg varchar(2000)
select @error_count=count(*) from gis_reconcillation_log where process_id=@process_id
SELECT @counts = count(*) from #GISTransactions
select @counts_process=count(*) from #GIS_Reconcile

set @detail_errorMsg=''
set @type='e'



if @error_count > 0 
begin
	if @counts_process= 0 
		set @detail_errorMsg='GIS Reconcillation process did not complete (ERRORS found)'
	else	
		set @detail_errorMsg=cast(@counts_process as varchar(100))+' Data imported Successfully out of 
		'+cast(@counts as varchar(100))+'. Some Error found while importing. Please review Errors'
END
else if @counts = 0 
begin
	set @detail_errorMsg='Empty GIS Certificate found. Process did not complete.'
end
else 
begin
	set @type='s'
	set @detail_errorMsg='GIS Reconcillation process completed.'
end

SET @url = './dev/spa_html.php?__user_name__=' + @user_id + 
	'&spa=exec spa_gis_reconcillation_log ''' + @process_id + ''''

if @type='s'
SET @desc = @detail_errorMsg
else
SET @desc = '<a target="_blank" href="' + @url + '">' + 
		@detail_errorMsg + '.</a>'

	EXEC  spa_message_board 'i', @user_id,
			NULL, 'GIS Recon',
			@desc, @url_desc, '', @type, @job_name
	--Return


--SET @sql = dbo.FNAProcessDeleteTableSql(@temptablename)

 








