
IF NOT EXISTS(SELECT 1 FROM forecast_profile)
begin
	SET IDENTITY_INSERT forecast_profile ON
	INSERT INTO forecast_profile(profile_id,external_id,profile_type,create_user,create_ts,update_user,update_ts,available)
	SELECT source_minor_location_id,'EN'+CAST(source_minor_location_id AS VARCHAR) external_id,17500 profile_type,'farrms_admin' create_user,getdate() create_ts,'farrms_admin' update_user,getdate() update_ts,1 available FROM source_minor_location

	SET IDENTITY_INSERT forecast_profile OFF
	UPDATE source_minor_location SET profile_id = source_minor_location_id
END
IF  EXISTS(SELECT 1 FROM sys.columns WHERE [name]='location_id' AND [object_id]=object_id('deal_detail_hour'))
BEGIN
	exec('UPDATE deal_detail_hour SET profile_id=location_id')
	ALTER TABLE deal_detail_hour DROP COLUMN location_id
END
if exists(select 1 from sys.indexes where [name]='indx_deal_detail_hour_profile_id')
	drop index indx_deal_detail_hour_profile_id on deal_detail_hour
	
IF  EXISTS(SELECT 1 FROM sys.columns WHERE [name]='term_start' AND [object_id]=object_id('deal_detail_hour'))
	ALTER TABLE deal_detail_hour DROP COLUMN term_start
	
if not exists(select 1 from sys.indexes where [name]='indx_deal_detail_hour_profile_id')
	create  index indx_deal_detail_hour_profile_id on deal_detail_hour	(profile_id, term_date)
	

update source_deal_header set internal_desk_id=case when isnull(internal_desk_id,-6)=-6 then 17300 else 17300 end where isnull(internal_desk_id,-6)=-6 or isnull(internal_desk_id,-6)=-7