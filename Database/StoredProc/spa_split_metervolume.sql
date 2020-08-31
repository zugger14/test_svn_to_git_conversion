
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_split_metervolume]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_split_metervolume]
GO 

CREATE PROCEDURE [dbo].[spa_split_metervolume]   
@counterparty_id int=NULL,   
@prod_date datetime=null,   
@as_of_date datetime=NULN
  
AS   
  
BEGIN   
  
DECLARE @total_Volume money
DECLARE @rowcount int   
DECLARE @sqlstmt varchar(8000)   
DECLARE @count int   
Declare @conv_uom_id int   
Declare @contract_id int   
DECLARE @calc_id varchar(100)   
DECLARE @counterparty_name varchar(100)
DECLARE @granularity int
-- find the UOM to convert to   



select @conv_uom_id=cg.volume_uom,   
@contract_id=contract_id,
@granularity=volume_granularity   
from contract_group cg inner join rec_generator rg on rg.ppa_contract_id=cg.contract_id   
where rg.ppa_counterparty_id=@counterparty_id   

create table #temp_calc(   
	[id] int identity,   
	recorderid varchar(100) COLLATE DATABASE_DEFAULT,   
	counterparty_id int,   
	generator_id int,   
	contract_id int,   
	prod_date datetime,   
	metervolume float,   
	invoicevolume float,   
	allocationvolume float,   
	variance float,   
	onpeak_volume float,   
	offpeak_volume float,   
	UOM int,   
	ActualVolume varchar(1) COLLATE DATABASE_DEFAULT,   
	book_entries varchar(1) COLLATE DATABASE_DEFAULT,   
	Finalized varchar(1) COLLATE DATABASE_DEFAULT,   
	invoice_id int ,
	deal_id int,
	original_volume float 
)   
  

 
-- check if same recorderid is used by multiple generators   
select @total_Volume=sum(invoice_volume)  from invoice_header where counterparty_id in(   
select ppa_counterparty_id from rec_generator where generator_id in(   
select distinct generator_id from recorder_generator_map where recorderid in   
(   
	select rgm.recorderid from recorder_generator_map rgm inner join   
	rec_generator rg on rg.generator_id=rgm.generator_id where ppa_counterparty_id=@counterparty_id and   
	dbo.FNAgetContractMonth(production_month)=dbo.FNAgetContractMonth(@prod_date)   
)   
)   
)   
  

if @total_Volume is null   
set @total_Volume=1   
  

-- if many to many relation between recorder and counterparty,   
-- and not invoice volume provided then Estimate the volume equally from meter data   
  
-- first select number of counterparty using same recorder   
select @count=
count(distinct ppa_counterparty_id) from rec_generator where generator_id in(
select distinct generator_id from recorder_generator_map where recorderid in(   
select distinct recorderid from recorder_generator_map where recorderid in   
(   
select rgm.recorderid from recorder_generator_map rgm inner join   
rec_generator rg on rg.generator_id=rgm.generator_id where ppa_counterparty_id=@counterparty_id   
)   
)   
)  
 
if @count is null   
set @count=1   

--print 'beginnnnnnnn'
--print @contract_id
---##### first populate all the hourly data in a process table
DECLARE @user_login_id varchar(100)
DECLARE @process_id1 varchar(100)
DECLARE @tempTable varchar(128)

set @user_login_id=dbo.FNADBUser()
set @process_id1=REPLACE(newid(),'-','_')
set @tempTable=dbo.FNAProcessTableName('settlement_process', @user_login_id,@process_id1)

set @sqlstmt='
	select mv.recorderid,mv.channel,mv.prod_date,isnull(mvp.HR1,mv.HR1) HR1,isnull(mvp.HR2,mv.HR2) HR2,isnull(mvp.HR3,mv.HR3) HR3,isnull(mvp.HR4,mv.HR4) HR4,isnull(mvp.HR5,mv.HR5) HR5
	,isnull(mvp.HR6,mv.HR6) HR6,isnull(mvp.HR7,mv.HR7) HR7,isnull(mvp.HR8,mv.HR8) HR8,isnull(mvp.HR9,mv.HR9) HR9,isnull(mvp.HR10,mv.HR10) HR10,isnull(mvp.HR11,mv.HR11) HR11,isnull(mvp.HR12,mv.HR12) HR12
	,isnull(mvp.HR13,mv.HR13) HR13,isnull(mvp.HR14,mv.HR14) HR14,isnull(mvp.HR15,mv.HR15) HR15,isnull(mvp.HR16,mv.HR16) HR16,isnull(mvp.HR17,mv.HR17) HR17,isnull(mvp.HR18,mv.HR18) HR18,isnull(mvp.HR19,mv.HR19) HR19
	,isnull(mvp.HR20,mv.HR20) HR20,isnull(mvp.HR21,mv.HR21) HR21,isnull(mvp.HR22,mv.HR22) HR22,isnull(mvp.HR23,mv.HR23) HR23,isnull(mvp.HR24,mv.HR24) HR24,
	mv.data_missing
into '+@tempTable+'
from
	rec_generator rg inner join   
	recorder_generator_map map on rg.generator_id=map.generator_id   
	inner join mv90_data_hour mv on mv.recorderid=map.recorderid
	left join mv90_data_proxy mvp on mv.recorderid=mvp.recorderid and
	mv.channel=mvp.channel and mv.prod_date=mvp.prod_date and mv.data_missing=''y''
where
	rg.ppa_counterparty_id='+cast(@counterparty_id as varchar)+' and
	dbo.FNAContractMonthFormat(mv.prod_date)=dbo.FNAContractMonthFormat('''+CAST(@prod_date as varchar)+''')  
'

exec(@sqlstmt)



------
set @sqlstmt=   
	'   
	INSERT INTO #temp_calc   
	(   
	  
	recorderid,   
	counterparty_id,   
	generator_id,   
	contract_id,   
	prod_date,   
	metervolume,   
	invoicevolume,   
	allocationvolume,   
	variance,   
	UOM,   
	ActualVolume,   
	book_entries,   
	invoice_id,
	original_volume
)   
	select   
	map.recorderid,   
	sc.source_counterparty_id,   
	rg.generator_id,   
	--sc.counterparty_name as Counterparty,   
	--rg.name [Generator],   
	rg.ppa_contract_id,   
	dbo.FNAGETContractMonth('''+CAST(@prod_date as varchar)+'''),   
	cast(mv90.volume as decimal(10,2)) as MeterVolume,   
	case when inv.invoice_volume is null or inv.invoice_volume=0 then   
				case when isnull(map.allocation_per,1)<1 then ISNULL(map.allocation_per,1)*mv90.volume else mv90.volume/'+casT(@count as varchar)+' end 
			else inv.invoice_volume *conv.conversion_factor end 
	 as InvoiceVolume,   
	((case when inv.invoice_volume is null or inv.invoice_volume=0 then 
	   case when isnull(map.allocation_per,1)<1 then ISNULL(map.allocation_per,1)*mv90.volume else (mv90.volume/'+casT(@count as varchar)+') end 
		 else inv.invoice_volume *conv.conversion_factor end)
		 /('+cast(@total_Volume as varchar)+'))*
		case when inv.invoice_volume is null or inv.invoice_volume=0 then 1 
		else ISNULL(map.allocation_per,1)*mv90.volume end 
	as [AllocationVolume],   	  
	abs(cast((((case when inv.invoice_volume is null or inv.invoice_volume=0 then   
	case when isnull(map.allocation_per,1)<1 then ISNULL(map.allocation_per,1)*mv90.volume else (mv90.volume/'+casT(@count as varchar)+') end else inv.invoice_volume *conv.conversion_factor end)   
	-((case when inv.invoice_volume is null or inv.invoice_volume=0 then case when isnull(map.allocation_per,1)<1 then ISNULL(map.allocation_per,1)*mv90.volume else (mv90.volume/'+casT(@count as varchar)+') end else inv.invoice_volume *conv.conversion_factor end)   
	/('+casT(@total_Volume as varchar)+'))* case when inv.invoice_volume is null or inv.invoice_volume=0 then 1 else ISNULL(map.allocation_per,1)*(mv90.volume/'+casT(@count as varchar)+') end))/   
	(((case when inv.invoice_volume is null or inv.invoice_volume=0 then   
	case when isnull(map.allocation_per,1)<1 then ISNULL(map.allocation_per,1)*mv90.volume else (case when mv90.volume=0 then 1 else mv90.volume end /'+casT(@count as varchar)+') end else inv.invoice_volume *conv.conversion_factor end)   
	)) as varchar))   
	as Variance,   
	  
	su.source_uom_id as UOM,   
	case when inv.invoice_volume is null or inv.invoice_volume=0 then ''n'' else ''y'' end as ActualVolume,   
	case when inv.invoice_volume is null or inv.invoice_volume=0 then ''m'' else ''i'' end as book_entries,   
	inv.invoice_id,
	cast(mv90.original_volume as decimal(10,2)) as original_volume   
	from   
	rec_generator rg inner join   
	recorder_generator_map map on rg.generator_id=map.generator_id   
	left join invoice_header inv on rg.ppa_counterparty_id=inv.counterparty_id   
	and dbo.FNAGetContractMonth(inv.production_Month)=dbo.FNAGetContractMonth('''+CAST(@prod_date as varchar)+''')   
	--inner join invoice_detail invd on inv.invoice_id=invd.invoice_id   
	inner join source_counterparty sc on sc.source_counterparty_id=rg.ppa_counterparty_id   
	--inner join contract_group cg on cg.contract_id=rg.ppa_contract_id   
	inner join   
	(select recorderid as recorderid,
			--sum(volume*conv.conversion_factor) as volume,
			(sum(volume)-max(gre_volume)-(max(gre_per)*sum(volume)))*max(conv.conversion_factor) as volume,
			max(conv.to_source_uom_id) as uom_id,max(uom_id) as uom_id1,sum(volume)*max(conv.conversion_factor) as original_volume from   
		(select distinct
			mv.recorderid as recorderid,   
			--(mv.volume-COALESCE(meter.gre_volume,meter1.gre_volume,0)-(COALESCE(meter.gre_per,meter1.gre_per,0)*mv.volume)) * mult_factor as volume,   
			mv.volume * mult_factor as volume, 
			COALESCE(meter.gre_volume,meter1.gre_volume,0) gre_volume,
			COALESCE(meter.gre_per,meter1.gre_per,0) gre_per,
			mv.channel,   
			mult_factor,   
			md.uom_id			   
			from   
			(select recorderid,channel,dbo.fnagetcontractmonth(prod_date) from_date,sum(hb.HR1+hb.HR2+hb.HR3+hb.HR4+hb.HR5+hb.HR6+hb.HR7+hb.HR8+hb.HR9+hb.HR10+hb.HR11+hb.HR12+hb.HR13+hb.HR14+hb.HR15+hb.HR16+hb.HR17+
				hb.HR18+hb.HR19+hb.HR20+hb.HR21+hb.HR22+hb.HR23+hb.HR24) volume from '+@tempTable+' hb group by recorderid,channel,dbo.fnagetcontractmonth(prod_date)) mv inner join   
			recorder_properties md on mv.recorderid=md.recorderid and md.channel=mv.channel   
			left join meter_id_allocation meter on meter.recorderid=mv.recorderid and   
			--dbo.fnagetcontractmonth(meter.production_month)=dbo.fnagetcontractmonth(mv.from_date)   
			meter.production_month is null
			left join meter_id_allocation meter1 on meter1.recorderid=mv.recorderid   
			and dbo.fnagetcontractmonth(meter1.production_month)=dbo.FNAGEtContractMonth('''+CAST(@prod_date as varchar)+''') '+'  
			where dbo.FNAContractMonthFormat(mv.from_date)=dbo.FNAContractMonthFormat('''+CAST(@prod_date as varchar)+''') '+') a   
	inner join rec_volume_unit_conversion conv on   
	a.uom_id=conv.from_source_uom_id and conv.to_source_uom_id='+cast(@conv_uom_id as varchar)+'   
	and conv.state_value_id is null and conv.assignment_type_value_id is null and conv.curve_id is null   
	group by recorderid ) mv90   
	on mv90.recorderid=map.recorderid   
	inner join rec_volume_unit_conversion conv on   
	ISNULL(inv.uom_id,mv90.uom_id)=conv.from_source_uom_id and conv.to_source_uom_id='+cast(@conv_uom_id as varchar)+'   
	and conv.state_value_id is null and conv.assignment_type_value_id is null and conv.curve_id is null   	
	left join rec_volume_unit_conversion conv1 on   
	mv90.uom_id1=conv1.from_source_uom_id and conv1.to_source_uom_id='+cast(@conv_uom_id as varchar)+'   
	and conv1.state_value_id is null and conv1.assignment_type_value_id is null and conv1.curve_id is null   
	LEFT join source_uom su on   
	su.source_uom_id='+ cast(@conv_uom_id as varchar)+'   
	WHERE 1=1   
	-- and dbo.FNAContractMonthFormat(inv.production_month)=dbo.FNAContractMonthFormat('''+CAST(@prod_date as varchar)+''')   
	'   
	+case when @counterparty_id is not null then ' AND sc.source_counterparty_id='+cast(@counterparty_id as varchar)   
	else ''   
	end   

--print   @sqlstmt
exec(@sqlstmt)   
delete  from #temp_calc where metervolume=0


update a   
set   
a.metervolume=b.metervolume,   
a.invoicevolume=b.invoicevolume,   
a.allocationvolume=b.allocationvolume,   
a.variance=b.variance,   
a.UOM=b.UOM,   
a.actualvolume=b.actualvolume,   
a.book_entries=b.book_entries,   
a.invoice_id=b.invoice_id,
a.deal_id=b.deal_id,
a.original_volume=b.original_volume   
from   
calc_invoice_volume_recorder a,   
#temp_calc b   
where   
a.counterparty_id=b.counterparty_id and   
a.contract_id=b.contract_id and   
dbo.FNAgetContractMonth(a.prod_date)=dbo.FNAgetContractMonth(b.prod_date)
and dbo.FNAgetContractMonth(a.as_of_date)=dbo.FNAgetContractMonth(@as_of_date)  
and ISNULL(a.recorderid,'')=ISNULL(b.recorderid,'')   
  
  
update a   
set   
a.metervolume=b.metervolume,   
a.invoicevolume=b.invoicevolume,   
a.allocationvolume=b.allocationvolume,   
a.variance=b.variance,   
a.UOM=b.UOM,   
a.actualvolume=b.actualvolume,   
a.book_entries=b.book_entries,   
a.invoice_id=b.invoice_id,
a.deal_id=b.deal_id      
from   
calc_invoice_volume_variance a,   
(select counterparty_id,contract_id,prod_date,sum(metervolume) metervolume,max(invoicevolume)invoicevolume ,   
sum(allocationvolume) allocationvolume,   
abs((sum(allocationvolume)-sum(invoicevolume))/ CASE when sum(allocationvolume)=0 then 1 else sum(allocationvolume) end)   as Variance,   
max(UOM)UOM,max(actualvolume) actualvolume,max(book_entries) book_entries,max(invoice_id) invoice_id,max(deal_id) deal_id from #temp_calc   
group by counterparty_id,contract_id,prod_date) b   
where   
a.counterparty_id=b.counterparty_id and   
a.contract_id=b.contract_id and   
dbo.FNAgetContractMonth(a.prod_date)=dbo.FNAgetContractMonth(b.prod_date)   
and dbo.FNAgetContractMonth(a.as_of_date)=dbo.FNAgetContractMonth(@as_of_date)  
--and a.recorderid=b.recorderid   
---------------------------------------------------     
set @rowcount=@@ROWCOUNT   
----------------------------------------   
select @calc_id=calc_id from calc_invoice_volume_variance   
where   
counterparty_id=@counterparty_id and   
contract_id=@contract_id and   
dbo.FNAgetContractMonth(prod_date)=dbo.FNAgetContractMonth(@prod_date) and   
dbo.FNAgetContractMonth(as_of_date)=dbo.FNAgetContractMonth(@as_of_date)  
----------------------------------   
--print @calc_id   

select * from #temp_calc
  
if @rowcount <=0 -- insert if value does not exists   
BEGIN   
  
  
insert into calc_invoice_volume_recorder(   
as_of_date,recorderid,counterparty_id,generator_id,   
contract_id,prod_date,metervolume,invoicevolume,allocationvolume,   
variance,onpeak_volume,offpeak_volume,UOM,actualvolume,book_entries,   
finalized,invoice_id,deal_id,original_volume
)   
select dbo.FNAgetContractMonth(@as_of_date),recorderid,counterparty_id,generator_id,   
contract_id,prod_date,metervolume,invoicevolume,allocationvolume,   
variance,onpeak_volume,offpeak_volume,UOM,actualvolume,book_entries,   
finalized,invoice_id,deal_id,original_volume from #temp_calc   
  


----------------------------------------------------------------------   
insert into calc_invoice_volume_variance(   
as_of_date,counterparty_id,generator_id,   
contract_id,prod_date,metervolume,invoicevolume,allocationvolume,   
variance,onpeak_volume,offpeak_volume,UOM,actualvolume,book_entries,   
finalized,invoice_id,deal_id   
)   
select dbo.FNAgetContractMonth(@as_of_date),counterparty_id,max(generator_id),contract_id   
,dbo.FNAgetContractMonth(prod_date),sum(metervolume),sum(invoicevolume),sum(allocationvolume),   
abs((sum(allocationvolume)-sum(invoicevolume))/ case when sum(invoicevolume)=0 then 1 else sum(invoicevolume) end ),   
max(onpeak_volume),max(offpeak_volume),max(UOM),max(actualvolume),max(book_entries),max(finalized),   
max(invoice_id),max(deal_id) from #temp_calc   
group by counterparty_id,contract_id,prod_date  
set @calc_id=SCOPE_IDENTITY()   
END   




exec spa_finalize_invoice @as_of_date,@counterparty_id,@contract_id,@prod_date   

If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Invoice", 
		"spa_calc_invoice_detail", "DB Error", 
		"Error creating Invoice.", ''
	else
		Exec spa_ErrorHandler 0, 'Invoice', 
		'spa_recorder_properties', 'Success', 
		'Invoice created Successfully.',''

  
END   






