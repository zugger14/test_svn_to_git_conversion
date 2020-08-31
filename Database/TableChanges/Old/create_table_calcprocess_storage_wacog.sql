--    drop table dbo.calcprocess_storage_wacog	

if object_id('dbo.calcprocess_storage_wacog') is null
begin
	create table dbo.calcprocess_storage_wacog
	(
		rowid bigint identity(1,1),
		location_id int,
		contract_id int,
		term datetime,
		prior_inventory_vol float,
		prior_inventory_amt float,
		current_inventory_vol float,
		current_inventory_amt float,
		total_inventory_vol float,
		total_inventory_amt float,
		wacog float,
		create_ts datetime ,
		create_user varchar(30)

	)

	create unique clustered   index idx_cl_unq_calcprocess_storage_wacog  on 	dbo.calcprocess_storage_wacog (location_id ,contract_id,term )
end