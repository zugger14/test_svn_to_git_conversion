/****** Object:  StoredProcedure [dbo].[spa_getcertificate_detail]    Script Date: 04/20/2009 17:56:00 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_getcertificate_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_getcertificate_detail]
GO

CREATE PROCEDURE [dbo].[spa_getcertificate_detail]
@structured_deal_id varchar(100)=null,
@source_deal_header_id int=null
AS
-- declare @structured_deal_id varchar(100),@source_deal_header_id int
-- set @source_deal_header_id=1817

--drop table #temp11

-- 	select 
-- 	case when
-- 	certificate_number_from_int+(select sum(assigned_volume) from assignment_audit 
-- 	where assignment_id<=a.assignment_id and source_deal_header_id_from=a.source_deal_header_id_from)- a.assigned_volume=certificate_number_from_int 
-- 	then
-- 	dbo.FNACertificateRule(cert_rule,[id],
-- 	certificate_number_from_int+(select sum(assigned_volume) from assignment_audit 
-- 	where assignment_id<=a.assignment_id and source_deal_header_id_from=a.source_deal_header_id_from)- a.assigned_volume ,
-- 	c.gis_cert_date)	 
-- 	else
-- 	dbo.FNACertificateRule(cert_rule,[id],
-- 	 certificate_number_from_int+(select sum(assigned_volume) from assignment_audit 
-- 	where assignment_id<=a.assignment_id and source_deal_header_id_from=a.source_deal_header_id_from)- a.assigned_volume+1 ,
-- 	c.gis_cert_date) end  CertFrom,
-- 	 dbo.FNACertificateRule(cert_rule,[id],
-- 	(select sum(assigned_volume) from assignment_audit 
-- 	where assignment_id<=a.assignment_id and source_deal_header_id_from=a.source_deal_header_id_from)+ certificate_number_from_int-1,
-- 	c.gis_cert_date)  CertTo,
-- 	 dbo.FNADateFormat(c.gis_cert_date) CertDate,a.source_deal_header_id [DetailID],sdd1.source_deal_header_id [ID]
-- 	into #temp11
-- 	from assignment_audit a join gis_certificate c
-- 	on a.source_deal_header_id_from=c.source_deal_header_id 
-- 	join source_deal_detail ssd on ssd.source_deal_detail_id=a.source_deal_header_id_from
-- 	join source_deal_header s on ssd.source_deal_header_id=s.source_deal_header_id
-- 	join rec_generator rg on rg.generator_id=s.generator_id
-- 	join certificate_rule cr on cr.gis_id=rg.gis_value_id 
-- 	join source_deal_detail sdd1 on sdd1.source_deal_detail_id=a.source_deal_header_id
-- 	order by assignment_id

	select distinct * from (
		select 
		dbo.FNACertificateRule(cert_rule,[id],cert_from,c.gis_cert_date) CertFrom,
		dbo.FNACertificateRule(cert_rule,[id],cert_to,c.gis_cert_date) CertTo,
		dbo.FNADateFormat(c.gis_cert_date) CertDate ,
		a.source_deal_header_id [DetailID],sdd.source_deal_header_id [ID],
		certificate_number_from_int,
		certificate_number_to_int
		from assignment_audit a join source_deal_detail sdd 
		on a.source_deal_header_id=sdd.source_deal_detail_id
		join source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id
		join rec_generator rg on rg.generator_id=sdh.generator_id
		join certificate_rule cr on cr.gis_id=rg.gis_value_id 
		join gis_certificate c on a.source_deal_header_id_from=c.source_deal_header_id 
		where sdh.source_deal_header_id=@source_deal_header_id


--	select  CertFrom, CertTo,CertDate,DetailID,[ID]  from #temp11 where [id]=@source_deal_header_id
	union all
	select gis_certificate_number_from CertFrom,gis_certificate_number_to CertTo,  dbo.FNADateFormat(c.gis_cert_date) CertDate ,
	sdd.source_deal_detail_id, sdh.source_deal_header_id,certificate_number_from_int,certificate_number_to_int
	from source_deal_header sdh join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
	left JOIN Gis_certificate c  on sdd.source_deal_detail_id=c.source_deal_header_id 
	 
	where sdh.source_deal_header_id=@source_deal_header_id
	) l 

