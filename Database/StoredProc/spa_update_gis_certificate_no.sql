
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_update_gis_certificate_no]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_update_gis_certificate_no]
GO 
CREATE PROC [dbo].[spa_update_gis_certificate_no]
	@source_deal_detail_id int
	
AS
BEGIN
Declare @gis_id int 
SET @gis_id=5164


create table #certrule(
	[id] int identity(1,1),
	generator_id int,
	term_start datetime,
	quarter int,
	cert_no_start int,
	cert_no_end int,
	exists_in_gis char(1) COLLATE DATABASE_DEFAULT	
)

insert into #certrule(generator_id,term_start,quarter,cert_no_start,cert_no_end,exists_in_gis)
select 
	sdh.generator_id,
	sdd.term_start,
	datepart(q,sdd.term_start),
	ISNULL(max(sdd.deal_volume),max(certificate_number_from_int)), 
	ISNULL(max(sdd.deal_volume),max(certificate_number_to_int)),
	case when max(certificate_number_from_int) is null then 'n' else 'y'  end  as exists_in_gis
 
from 
	source_deal_header sdh (NOLOCK)   
	inner join  source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
	inner join rec_generator rg on rg.generator_id=sdh.generator_id
	left join source_deal_header sdh1 on sdh1.generator_id=rg.generator_id
	left join source_deal_detail sdd1 on sdh1.source_deal_header_id=sdd1.source_deal_header_id
	left join gis_certificate gis on gis.source_deal_header_id=sdd.source_deal_detail_id
where 1=1
		and sdh.generator_id in(select distinct sdh.generator_id from 
							source_deal_header sdh inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id where sdd1.source_deal_detail_id=@source_deal_detail_id)
		and rg.generator_id in(select generator_id from rec_generator rg inner join certificate_rule cr on rg.gis_value_id=cr.gis_id where cert_rule like '%q#%')
		--and datepart(q,sdd.term_start)=datepart(q,sdd1.[term_start])
		and year(sdd.term_start)=year(sdd1.term_start)
group by 
	sdh.generator_id,sdd.term_start,datepart(q,sdd.term_start)


-- Now find the starting point of sertificate_number and 
--select max(cert_no_end) from #certrule  group by quarter
create table #cert_sequence(
	[ID] int,
	generator_id int,
	term_start datetime,
	quarter int,
	cert_no_start int
)

insert into #cert_sequence
select
	a.[ID],
	generator_id,
	term_start,
	quarter,
	(select case when max(exists_in_gis)='y' then sum(cert_no_end) else sum(cert_no_end) end from #certrule where [ID]<a.[ID] and quarter=a.quarter) as cert_no_start
from
	#certrule a
group by
	generator_id,term_start,quarter,a.[ID]
	order by term_start


------------------------------------------
update gis_certificate
	set gis_certificate_number_from= dbo.FNACertificateRule(cr.cert_rule,rg.[ID],ISNULL(ct.cert_no_start,0)+1,sdd.term_start),	
	gis_certificate_number_to= dbo.FNACertificateRule(cr.cert_rule,rg.[ID],ISNULL(ct.cert_no_start,0)+sdd.deal_volume,sdd.term_start),	
	certificate_number_from_int=ISNULL(ct.cert_no_start,0)+1,
	certificate_number_to_int=ISNULL(ct.cert_no_start,0)+cast(deal_volume as int),
	gis_cert_date= sdd.term_start
	from source_deal_header sdh inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
	inner join 	gis_certificate gc on gc.source_deal_header_id=sdd.source_deal_detail_id
	inner join rec_generator rg on sdh.generator_id = RG.generator_id 
	inner join #cert_sequence ct on ct.generator_id=rg.generator_id and ct.term_start=sdd.term_start
	left join certificate_rule cr on ISNULL(rg.gis_value_id,@gis_id)=cr.gis_id
-------------------------------------------------

UPDATE
	assignment_audit
SET
	assignment_audit.assigned_volume=FLOOR(sdd.[deal_volume] * ISNULL(gen_assign.auto_assignment_per,rg.auto_assignment_per)),
	cert_from=ISNULL(gis.certificate_number_from_int,1),
	cert_to=ISNULL(gis.certificate_number_from_int,1)+FLOOR(sdd.deal_volume* COALESCE(gen_assign.auto_assignment_per,rg.auto_assignment_per,1))-1,
	--cert_to=round(sdd.deal_volume* COALESCE(gen_assign.auto_assignment_per,rg.auto_assignment_per,1),0),
	assignment_type=ISNULL(gen_assign.auto_assignment_type,rg.auto_assignment_type),
	assignment_audit.compliance_year=YEAR(sdh.deal_date),
	assignment_audit.state_value_id=rg.state_value_id,
	assignment_audit.assigned_date=dbo.FNAGetSQLStandardDate(sdh.deal_date)
--select assign.* from 
FROM source_deal_detail sdd 
	inner join source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id
	inner join assignment_audit assign on assign.source_deal_header_id_from=sdd.source_deal_detail_id
	inner join rec_generator rg on rg.generator_id=sdh.generator_id
	inner join #cert_sequence ct on ct.generator_id=rg.generator_id and ct.term_start=sdd.term_start
	LEFT join rec_generator_assignment gen_assign
	 on rg.generator_id=gen_assign.generator_id and
	((sdd.term_start between gen_assign.term_start and gen_assign.term_end) OR
    (sdd.term_end between gen_assign.term_start and gen_assign.term_end))		
	left join  gis_certificate gis on gis.source_deal_header_id=assign.source_deal_header_id_from
where
	ISNULL(gen_assign.auto_assignment_type,rg.auto_assignment_type) is not null
	and sdd.source_deal_detail_id not in(select source_deal_header_id_from from assignment_audit where assigned_by<>'Auto Assigned')

END







