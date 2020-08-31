

if object_id('dbo.fas_link_detail_dicing') is null
	create table dbo.fas_link_detail_dicing(
		link_id int, source_deal_header_id int, term_start datetime, percentage_used float, effective_date datetime
		,create_user varchar(50),create_ts	datetime,update_user varchar(50),update_ts	datetime
	)
