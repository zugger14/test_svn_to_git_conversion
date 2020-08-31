--written by tara.
--This updates source_curve_def_id of curve_id 'CO2e' to -1 if any. 

--update source_price_curve_def set source_curve_def_id=-1 where curve_id='CO2e'
declare @identityid int
select  @identityid=source_curve_def_id from source_price_curve_def where curve_id='CO2e'
print @identityid

if  @identityid is not NULL and @identityid!=-1
	begin

	SET IDENTITY_INSERT source_price_curve_def ON

	insert into source_price_curve_def(
		source_curve_def_id,
		source_system_id,
		curve_id,
		curve_name,
		curve_des,
		commodity_id,
		market_value_id,
		market_value_desc,
		source_currency_id,
		source_currency_to_id,
		source_curve_type_value_id,
		uom_id,
		proxy_source_curve_def_id,
		formula_id,
		obligation,
		sort_order,
		fv_level,
		create_user,
		create_ts,
		update_user,
		update_ts,
		Granularity,
		exp_calendar_id,
		risk_bucket_id,
		reference_curve_id,
		monthly_index
	)

	select 
	--source_curve_def_id,
	-1 as source_curve_def_id,
	source_system_id,
--	curve_id,
	'CO2ee',
	curve_name,
	curve_des,
	commodity_id,
	market_value_id,
	market_value_desc,
	source_currency_id,
	source_currency_to_id,
	source_curve_type_value_id,
	uom_id,
	proxy_source_curve_def_id,
	formula_id,
	obligation,
	sort_order,
	fv_level,
	create_user,
	create_ts,
	update_user,
	update_ts,
	Granularity,
	exp_calendar_id,
	risk_bucket_id,
	reference_curve_id,
	monthly_index
	 from source_price_curve_def where source_curve_def_id=@identityid

	SET IDENTITY_INSERT source_price_curve_def OFF
--source_price_curve_def table is unique on source_system_id and curve_id, so previously 'CO2e' was inserted as 'CO2ee'
--update this back to 'C02e' after deleting original one. 
	delete source_price_curve_def where source_curve_def_id=@identityid
    update source_price_curve_def set curve_id='CO2e' where source_curve_def_id=-1

	print 'source_curve_def_id of curve_id CO2e is updated to -1 from '+CAST(@identityid AS varchar)+ ' in table source_price_curve_def.'

	end
else
	begin
	print 'No update done.'
	end
