
IF OBJECT_ID(N'[dbo].[spa_adjust_gis_rec_deals_job]', N'P') IS NOT NULL
   DROP PROCEDURE [dbo].[spa_adjust_gis_rec_deals_job]
GO



--rollback
-- exec spa_adjust_gis_rec_deals_job '2006-06-01', '2006-06-30', 'urbaral', null, '2xx321', 'xffdsfds'


CREATE PROCEDURE [dbo].[spa_adjust_gis_rec_deals_job] (@gen_date_from varchar(20), 
						@gen_date_to varchar(20), 
						@user_id varchar(50), 
						@deal_id varchar(50) = null, -- not used now.. we might  need in  the  future
						@process_id varchar(50),
						@job_name varchar(100))
AS

---adjust for prior months
If @gen_date_to is null
	set @gen_date_to = @gen_date_from


-- SELECT source_deal_header_id, change_volume_to, gis_value_id  
-- into #temp_process_deals
-- from gis_inventory_prior_month_adjustements ipma
-- where   isnull(ipma.status, 'p') <> 'c' and  -- not processed so far
-- 	isnull(ipma.user_action, 'p') = 'a' and -- accepted
-- 	ipma.gen_date_from = @gen_date_from and ipma.gen_date_to=@gen_date_to

update source_deal_detail
set deal_volume=ipma.change_volume_to
from gis_inventory_prior_month_adjustements ipma, source_deal_detail sd
where sd.source_deal_detail_id=ipma.source_deal_header_id and  isnull(ipma.status, 'p') <> 'c' and  -- not processed so far
	isnull(ipma.user_action, 'p') = 'a' and -- accepted
	ipma.gen_date_from = @gen_date_from and ipma.gen_date_to=@gen_date_to
-- 
-- update gis_deal_adjustment
-- set original_volume=ipma.original_volume,
-- change_volume_to=ipma.change_volume_to,
-- status_value_id=5179, -- GIS INACTIVE
-- status_date=getdate()
-- from gis_inventory_prior_month_adjustements ipma join gis_deal_adjustment a
-- on ipma.source_deal_header_id=a.source_deal_header_id
-- where isnull(ipma.status, 'p') <> 'c' and  -- not processed so far
-- isnull(ipma.user_action, 'p') = 'a' and -- accepted
-- ipma.gen_date_from = @gen_date_from and ipma.gen_date_to=@gen_date_to

insert gis_deal_adjustment(source_deal_header_id,original_volume,change_volume_to,status_value_id,status_date)
select ipma.source_deal_header_id,ipma.original_volume,ipma.change_volume_to,5179,getdate() from gis_inventory_prior_month_adjustements ipma
--left outer join gis_deal_adjustment a on ipma.source_deal_header_id=a.source_deal_header_id
where isnull(ipma.status, 'p') <> 'c' and  -- not processed so far
isnull(ipma.user_action, 'p') = 'a' and -- accepted
ipma.gen_date_from = @gen_date_from and ipma.gen_date_to=@gen_date_to 


--########### Update certificate 
update gis_certificate
set gis_certificate_number_from=r.gis_cert_number,
gis_certificate_number_to=r.gis_cert_number_to,
certificate_number_from_int=r.certificate_from,
certificate_number_to_int=r.certificate_to,
gis_cert_date=r.gis_cert_date
from gis_certificate c,gis_reconcillation r
where c.source_deal_header_id=r.source_deal_header_id and
isnull(r.status, 'p') <> 'c' and 
isnull(r.user_action, 'p') = 'a' and
r.term_start=@gen_date_from and r.term_end= @gen_date_to

--########### Update Completed

insert gis_certificate(source_deal_header_id,gis_certificate_number_from,gis_certificate_number_to,certificate_number_from_int,
certificate_number_to_int,gis_cert_date)
select r.source_deal_header_id,r.gis_cert_number,r.gis_cert_number_to,r.certificate_from,r.certificate_to,r.gis_cert_date from
gis_reconcillation r  left outer join  gis_certificate c
on c.source_deal_header_id=r.source_deal_header_id
where c.source_deal_header_id is null and isnull(status, 'p') <> 'c' and 
isnull(user_action, 'p') = 'a' and
r.term_start=@gen_date_from  and r.term_end= @gen_date_to

 
UPDATE gis_inventory_prior_month_adjustements set status = 'c'
where   isnull(status, 'p') <> 'c' and 
	isnull(user_action, 'p') = 'a' and -- accepted	
	gen_date_from = @gen_date_from and gen_date_to=@gen_date_to

UPDATE gis_reconcillation set status = 'c'
where   isnull(status, 'p') <> 'c' and 
	isnull(user_action, 'p') = 'a' and -- accepted	
	term_start=@gen_date_from  and term_end= @gen_date_to


--------Ste 4 .. Return status.. MAKE ERRORS DESCRIPTIVE PLEASE
DECLARE @error_count int
DECLARE @desc varchar(5000)
DECLARE @type varchar(1)

If @@ERROR <> 0
BEGIN
	-- I think we should insert detail errors in msgboard which might be done by 
	-- dbo.spb_Process_Transactions already????
	
-- 	Exec spa_ErrorHandler @@ERROR, 'Adjust RECS', 
-- 			'spa_adjust_gis_rec_deals', 'Error', 
-- 			'Failed to  adjust REC deals due to GIS Reconcillation', ''
SET @type = 'e'

SET @desc = 'Failed to  adjust REC deals due to GIS Reconcillation, for gen date between ' + dbo.FNAUserDateFormat(@gen_date_from, @user_id) + 
		' and ' + dbo.FNAUserDateFormat(@gen_date_to, @user_id) + '. ' +
		case when (@type = 'e') then ' (ERRORS found) ' else '' end 
	

END
Else
BEGIN		

--	EXEC spa_print 'Update status on gis_reconcillation:' + dbo.FNAGetSQLStandardDateTime(getdate())



	SET @type = 's'


SET @desc = 'RECs Adjustments and Certificate Number Updates completed for gen date between ' + dbo.FNAUserDateFormat(@gen_date_from, @user_id) + 
		' and ' + dbo.FNAUserDateFormat(@gen_date_to, @user_id) + '. ' +
		case when (@type = 'e') then ' (ERRORS found) ' else '' end 
		

END

EXEC  spa_message_board 'i', @user_id,
			NULL, 'GISRecon',
			@desc, '', '', @type, @job_name













