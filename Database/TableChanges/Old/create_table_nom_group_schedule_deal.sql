
if OBJECT_ID('dbo.nom_group_schedule_deal') is null
begin
	create table dbo.nom_group_schedule_deal ( 
		rowid int identity(1,1),
		location_id int,
		term_start datetime,
		schedule_deal_id int,
		create_ts datetime ,
		create_user varchar(45)
	)


	create unique clustered  index indx_nom_group_schedule_deal_111 on  dbo.nom_group_schedule_deal (location_id,term_start)

end
	--select * from  dbo.nom_group_schedule_deal
	-- drop table dbo.nom_group_schedule_deal
	--delete dbo.nom_group_schedule_deal