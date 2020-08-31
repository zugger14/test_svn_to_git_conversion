if OBJECT_ID('lag_view') is not null
drop view lag_view
go
create view dbo.lag_view as
SELECT distinct rowid,spcd.curve_name +'-'+cast(cc.strip_month_from as varchar(10))+cast(cc.lag_months as varchar(10))+cast(strip_month_to as varchar(10))
 + '-'+sc.currency_id [Descr]
	from (
		select max(ROWID) rowid,curve_id,strip_month_from,lag_months,strip_month_to,MAX(fx_curve_id) fx_curve_id from cached_curves 
		group by curve_id,strip_month_from,lag_months,strip_month_to
	) cc inner join cached_curves_value ccv on cc.ROWID=ccv.Master_ROWID
	 LEFT JOIN source_price_curve_def spcd ON cc.curve_id=spcd.source_curve_def_id
	 LEFT JOIN source_price_curve_def spcd1 ON cc.fx_curve_id=spcd1.source_curve_def_id
	 left join source_currency sc on sc.source_currency_id=isnull(spcd1.source_currency_id,spcd.source_currency_id)

