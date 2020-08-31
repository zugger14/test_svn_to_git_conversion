IF object_id('spa_generation_report') is not null
	drop proc dbo.spa_generation_report

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_generation_report]
	@flag CHAR(1),
    @term_start datetime = null,
	@term_end datetime = null,
	@source_deal_header_id int = null,
	@hr_from int = null,
	@hr_to int = null,
	@process_id VARCHAR(250)= null

AS 
set nocount on
/*
--exec spa_generation_report @flag='g', @term_start='2015-11-01', @term_end='2015-11-01', @source_deal_header_id=35757, @hr_from=1, @hr_to=6
declare @flag CHAR(1) = 'g',
    @term_start datetime = '2016-01-01'
	,@term_end datetime = '2016-01-01'
	,@source_deal_header_id varchar(5000) = '36047'
	,@hr_from int --= 6
	,@hr_to int --= 6
	,@process_id varchar(250) = '74FA4A36_D339_4FF4_B30C_B22DC1EF5B3A'
--*/
declare @sql varchar(max)
begin try
	if @flag = 'g'
	begin
		DECLARE @power_dashboard_generation VARCHAR(250), @db_user VARCHAR(50)
		set @db_user=dbo.FNADBUser()
		if (@process_id <> null OR @process_id <> '')
			set @power_dashboard_generation=dbo.FNAProcessTableName('power_dashboard_generation', @db_user, @process_id)
		
		--EXEC('SELECT * FROM ' + @power_dashboard_generation)
		--STORE DEAL UDF FIELD VALUES
		IF OBJECT_ID('tempdb..#deal_header_udf') IS NOT NULL 
			DROP TABLE #deal_header_udf
		select uddft.template_id, uddf.source_deal_header_id, uddft.udf_template_id, uddft.Field_label, uddf.udf_value
		into #deal_header_udf --select * from #deal_header_udf order by source_deal_header_id
		from user_defined_deal_fields_template uddft
		inner join source_deal_header_template sdht on sdht.template_id = uddft.template_id
		inner join user_defined_deal_fields uddf on uddf.udf_template_id = uddft.udf_template_id
		inner join source_deal_header sdh on sdh.source_deal_header_id = uddf.source_deal_header_id
		where 1=1 --and uddft.Field_label IN ('Pipeline','Loss','Up Dn Party','From Deal')

		if object_id('tempdb..#tmp_data1') is not null
			drop table #tmp_data1
		select DISTINCT sdd.source_deal_header_id,sdh.deal_id [plant_id], sdh.source_system_id [unit_id], sdd.term_date term_start,dhu.Field_label
			, case dhu.field_label
				when 'Generation Category' then gc.code
				else dhu.udf_value
			  end [udf_value]
			,dbo.fnaremovetrailingzero(rhpd.hr1) [01],dbo.fnaremovetrailingzero(rhpd.hr2) [02],dbo.fnaremovetrailingzero(rhpd.hr3) [03]
			,dbo.fnaremovetrailingzero(rhpd.hr4) [04],dbo.fnaremovetrailingzero(rhpd.hr5) [05],dbo.fnaremovetrailingzero(rhpd.hr6) [06]
			,dbo.fnaremovetrailingzero(rhpd.hr7) [07],dbo.fnaremovetrailingzero(rhpd.hr8) [08],dbo.fnaremovetrailingzero(rhpd.hr9) [09]
			,dbo.fnaremovetrailingzero(rhpd.hr10) [10],dbo.fnaremovetrailingzero(rhpd.hr11) [11],dbo.fnaremovetrailingzero(rhpd.hr12) [12]
			,dbo.fnaremovetrailingzero(rhpd.hr13) [13],dbo.fnaremovetrailingzero(rhpd.hr14) [14],dbo.fnaremovetrailingzero(rhpd.hr15) [15]
			,dbo.fnaremovetrailingzero(rhpd.hr16) [16],dbo.fnaremovetrailingzero(rhpd.hr17) [17],dbo.fnaremovetrailingzero(rhpd.hr18) [18]
			,dbo.fnaremovetrailingzero(rhpd.hr19) [19],dbo.fnaremovetrailingzero(rhpd.hr20) [20],dbo.fnaremovetrailingzero(rhpd.hr21) [21]
			,dbo.fnaremovetrailingzero(rhpd.hr22) [22],dbo.fnaremovetrailingzero(rhpd.hr23) [23], dbo.fnaremovetrailingzero(rhpd.hr24) [24]
		into #tmp_data1
		from operational_dashboard_detail sdd --select * from operational_dashboard_detail
		inner join source_deal_header sdh on sdh.source_deal_header_id = sdd.source_deal_header_id
		left join report_hourly_position_deal rhpd on rhpd.source_deal_header_id = sdd.source_deal_header_id and rhpd.term_start = sdd.term_date
		inner join #deal_header_udf dhu on dhu.source_deal_header_id = sdd.source_deal_header_id
		left join static_data_value gc on cast(gc.value_id as varchar(30)) = dhu.udf_value and dhu.field_label = 'Generation Category'
		where 1=1
			and sdd.source_deal_header_id = @source_deal_header_id
			--and sdd.source_deal_header_id = 35757
			and sdd.term_date >= @term_start and sdd.term_date <= isnull(@term_end, @term_start)
			--and sdd.term_date >= '2015-11-02' and sdd.term_date <= '2015-11-02'
		
		if not exists(select top 1 1 from #tmp_data1)
		begin
			select 'No data found for : ' + convert(varchar(10),@term_start,21)
			return
		end
		--select * from #tmp_data1
		--select * from report_hourly_position_deal where source_deal_header_id = 35757 and term_start='2015-11-02'
		--return
		
		if object_id('tempdb..#tmp_data2') is not null
			drop table #tmp_data2
		select source_deal_header_id, plant_id, unit_id, term_start, field_label
			, udf_value
			, cast(cast(term_start as date) as varchar(30)) + ' ' + hr [hr], hr actual_hr, position
		into #tmp_data2
		from (
			select * from #tmp_data1
		) t1
		unpivot (
			position for hr in ([01], [02], [03], [04], [05], [06], [07], [08], [09], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24])
		) up
		where 1=1
			--AND dateadd(hour,cast(hr as int),term_start) >= dateadd(hour,@hr_from,@term_start)
		--return	
		
		--select * from #tmp_data2
		--return
		
		
		--test

		if object_id('tempdb..#tmp_data3') is not null
			drop table #tmp_data3
		select cast('udf' as nvarchar(max)) [category], t.source_deal_header_id, t.plant_id, t.unit_id, t.term_start, t.field_label
			, case 
				when t.field_label IN ('Fuel Type', 'Must Run Indicator', 'Online Indicator') then
					case when tdf.static_data_type_id is not null then sdv_ft.code else cast(tsd.value as varchar(30)) end 
				when t.Field_label in ('owner 1', 'owner 2') then cast(own.counterparty_name as varchar(500))
				when t.hr = '2015-11-01 03' and t.field_label IN ('Maximum Capacity', 'Minimum Capacity') and ISNUMERIC(t.udf_value) = 1 
					then cast(cast(t.udf_value as int) * 2 as varchar(30))
				else cast(t.udf_value as varchar(30)) 
			  end udf_value
			 , t.hr, t.actual_hr
			 
		into #tmp_data3 
		from #tmp_data2 t
		
		left join time_series_definition tdf on cast(tdf.time_series_definition_id as varchar(30)) = t.udf_value
		left join time_series_data tsd on t.field_label in ('Fuel Type', 'Must Run Indicator', 'Online Indicator')
			and cast(tsd.time_series_definition_id as varchar(30)) = tdf.time_series_definition_id
			and cast(tsd.maturity as date) = cast(t.term_start as date)
			and datepart(hour, tsd.maturity) = t.actual_hr
		left join static_data_value sdv_ft on cast(sdv_ft.value_id as varchar(30)) = cast(tsd.value as varchar(30)) and tdf.static_data_type_id is not null
		left join source_counterparty own on cast(own.source_counterparty_id as varchar(30)) = t.udf_value and t.Field_label in ('owner 1', 'owner 2')
		 where t.field_label  Not IN ('10 Mins Reserve', 'Outage/Derate', 'Capacity Usage')
		union all
		select 'position', t.source_deal_header_id, t.plant_id, t.unit_id, t.term_start, 'Available Capacity', t.position, t.hr, t.actual_hr
		from #tmp_data2  t
		union all
		select 'calc1', t.source_deal_header_id, t.plant_id, t.unit_id, t.term_start, 'Unit Availability'
		, cast((ca_pos.position / 
		  case when t.udf_value = 0 then 1 else 
			case when t.hr = '2015-11-01 03' and t.field_label IN ('Maximum Capacity', 'Minimum Capacity') and ISNUMERIC(t.udf_value) = 1 
				then cast(t.udf_value as int) * 2 
				else t.udf_value
			end
		  end) as varchar(30)) , t.hr, t.actual_hr
		from #tmp_data2 t
		cross apply (
			select cast(t1.position as float) position
			from #tmp_data2 t1 
			where t1.source_deal_header_id = t1.source_deal_header_id
				and t1.unit_id = t.unit_id and t1.term_start = t.term_start
				and t1.hr = t.hr
		) ca_pos
		where t.field_label = 'Maximum capacity'
		union all
		select 'calc2', t.source_deal_header_id, t.plant_id, t.unit_id, t.term_start, 'Fuel Cost ($/mmbtu)', cast(odd.price as varchar(30)), t.hr, t.actual_hr
		from #tmp_data2 t
		left join operational_dashboard_detail odd on t.source_deal_header_id = odd.source_deal_header_id
			and t.term_start = odd.term_date
			and right('00' + t.hr, 2) = right('00' + odd.hr, 2)
		union all
		select 'calc3', t.source_deal_header_id, t.plant_id, t.unit_id, t.term_start, 'Contracted hourly generation', cast(dbo.fnaremovetrailingzero(odd.tot_cap_vol) as varchar(30)), t.hr, t.actual_hr
		from #tmp_data2 t
		left join operational_dashboard_detail odd on t.source_deal_header_id = odd.source_deal_header_id
			and t.term_start = odd.term_date
			and right('00' + t.hr, 2) = right('00' + odd.hr, 2)
		union all
		select 'calc4', t.source_deal_header_id, t.plant_id, t.unit_id, t.term_start, 'Fuel required for contracted generation (mmbtu)', cast(dbo.fnaremovetrailingzero(odd.mmbtu_required) as varchar(30)), t.hr, t.actual_hr
		from #tmp_data2 t
		left join operational_dashboard_detail odd on t.source_deal_header_id = odd.source_deal_header_id
			and t.term_start = odd.term_date
			and right('00' + t.hr, 2) = right('00' + odd.hr, 2)
		union all
		select 'calc5', t.source_deal_header_id, t.plant_id, t.unit_id, t.term_start, 'Fuel cost contracted gen', cast(dbo.fnaremovetrailingzero(odd.price * odd.mmbtu_required) as varchar(30)), t.hr, t.actual_hr
		from #tmp_data2 t
		left join operational_dashboard_detail odd on t.source_deal_header_id = odd.source_deal_header_id
			and t.term_start = odd.term_date
			and right('00' + t.hr, 2) = right('00' + odd.hr, 2)
		union all
		select 'calc6', t.source_deal_header_id, t.plant_id, t.unit_id, t.term_start, 'O&M $', cast(dbo.fnaremovetrailingzero(odd.tot_cap_vol * t.udf_value) as varchar(30)), t.hr, t.actual_hr
		from #tmp_data2 t
		left join operational_dashboard_detail odd on t.source_deal_header_id = odd.source_deal_header_id
			and t.term_start = odd.term_date
			and right('00' + t.hr, 2) = right('00' + odd.hr, 2)
		where t.field_label = 'Variable OM Rate'
		union all
		select 'calc7', t.source_deal_header_id, t.plant_id, t.unit_id, t.term_start, 'Average cost contracted gen w/o startup ($/mwh)', cast(dbo.fnaround(((odd.tot_cap_vol * t.udf_value) + (odd.price * odd.mmbtu_required))
		/ case when odd.tot_cap_vol = 0 then 1 else odd.tot_cap_vol end, 3) as varchar(30)), t.hr, t.actual_hr
		from #tmp_data2 t
		left join operational_dashboard_detail odd on t.source_deal_header_id = odd.source_deal_header_id
			and t.term_start = odd.term_date
			and right('00' + t.hr, 2) = right('00' + odd.hr, 2)
		where t.field_label = 'Variable OM Rate'
		union all
		select 'calc8', t.source_deal_header_id, t.plant_id, t.unit_id, t.term_start, 'Contracted hourly generation - What If', cast(dbo.fnaremovetrailingzero(odd.tot_cap_vol) as varchar(30)), t.hr, t.actual_hr
		from #tmp_data2 t
		left join operational_dashboard_detail odd on t.source_deal_header_id = odd.source_deal_header_id
			and t.term_start = odd.term_date
			and right('00' + t.hr, 2) = right('00' + odd.hr, 2)
		union all
		select 'calc9', t.source_deal_header_id, t.plant_id, t.unit_id, t.term_start, 'Fuel required for contracted generation (mmbtu) - What If', cast(dbo.fnaremovetrailingzero(odd.mmbtu_required) as varchar(30)), t.hr, t.actual_hr
		from #tmp_data2 t
		left join operational_dashboard_detail odd on t.source_deal_header_id = odd.source_deal_header_id
			and t.term_start = odd.term_date
			and right('00' + t.hr, 2) = right('00' + odd.hr, 2)
		union all
		select 'calc10', t.source_deal_header_id, t.plant_id, t.unit_id, t.term_start, 'Fuel cost contracted gen - What If', cast(dbo.fnaremovetrailingzero(odd.price * odd.mmbtu_required) as varchar(30)), t.hr, t.actual_hr
		from #tmp_data2 t
		left join operational_dashboard_detail odd on t.source_deal_header_id = odd.source_deal_header_id
			and t.term_start = odd.term_date
			and right('00' + t.hr, 2) = right('00' + odd.hr, 2)
		union all
		select 'calc11', t.source_deal_header_id, t.plant_id, t.unit_id, t.term_start, 'O&M $ - What If', cast(dbo.fnaremovetrailingzero(odd.tot_cap_vol * t.udf_value) as varchar(30)), t.hr, t.actual_hr
		from #tmp_data2 t
		left join operational_dashboard_detail odd on t.source_deal_header_id = odd.source_deal_header_id
			and t.term_start = odd.term_date
			and right('00' + t.hr, 2) = right('00' + odd.hr, 2)
		where t.field_label = 'Variable OM Rate'
		union all
		select 'calc12', t.source_deal_header_id, t.plant_id, t.unit_id, t.term_start, 'Average cost contracted gen w/o startup ($/mwh) - What If', cast(dbo.fnaround(((odd.tot_cap_vol * t.udf_value) + (odd.price * odd.mmbtu_required))
		/ case when odd.tot_cap_vol = 0 then 1 else odd.tot_cap_vol end, 3) as varchar(30)), t.hr, t.actual_hr
		from #tmp_data2 t
		left join operational_dashboard_detail odd on t.source_deal_header_id = odd.source_deal_header_id
			and t.term_start = odd.term_date
			and right('00' + t.hr, 2) = right('00' + odd.hr, 2)
		where t.field_label = 'Variable OM Rate'
		
		--select * from #tmp_data3 order by term_start
		--return
		
		declare @pivot_cols varchar(max)
		
		SELECT @pivot_cols = STUFF(
			(SELECT distinct ',['  + cast(m.[hr] AS varchar) + ']'
			from #tmp_data3 m
			order by 1
			FOR XML PATH(''))
		, 1, 1, '')
		--print(@pivot_cols)
		
		--SELECT * FROM #tmp_data2 t WHERE field_label = 'Contracted hourly generation - what if'

		if object_id('tempdb..#tmp_datafinal') is not null
			drop table #tmp_datafinal
		SELECT DISTINCT * INTO #tmp_datafinal FROM #tmp_data3
		
		if (@process_id <> null OR @process_id <> '')
		BEGIN
		
			SET @sql =' UPDATE td3
				SET td3.udf_value = pdg.tot_cap_vol FROM #tmp_datafinal td3 INNER JOIN ' + @power_dashboard_generation + ' pdg ON td3.source_deal_header_id = pdg.source_deal_header_id AND DATEADD(hh,CAST(td3.actual_hr AS INT)-1, td3.term_start)  = pdg.term_hr
				WHERE td3.field_label IN (''Contracted hourly generation - what if'')'
			EXEC(@sql)

			--SET @sql =' UPDATE td3
			--	SET td3.udf_value = pdg.MMBTU_required FROM #tmp_datafinal td3 INNER JOIN ' + @power_dashboard_generation + ' pdg ON td3.source_deal_header_id = pdg.source_deal_header_id AND DATEADD(hh,CAST(td3.actual_hr AS INT)-1, td3.term_start)  = pdg.term_hr
			--	WHERE td3.field_label IN (''Fuel required for contracted generation (mmbtu) - What If'')'
			--EXEC(@sql)

			SET @sql ='	SELECT td3.hr [a_hr], udf_value [a_udf_value] INTO #temp_cal1 FROM #tmp_datafinal td3 WHERE td3.field_label IN (''Heat Rate A Coefficient'')
						SELECT td3.hr [b_hr], udf_value [b_udf_value] INTO #temp_cal2 FROM #tmp_datafinal td3 WHERE td3.field_label IN (''Heat Rate B Coefficient'')
						SELECT td3.hr [c_hr], udf_value [c_udf_value] INTO #temp_cal3 FROM #tmp_datafinal td3 WHERE td3.field_label IN (''Heat Rate C Coefficient'')
						SELECT td3.hr [x_hr], udf_value [x_udf_value] INTO #temp_cal4 FROM #tmp_datafinal td3 WHERE td3.field_label IN (''Contracted hourly generation - What If'')

						UPDATE td
						SET td.udf_value = (CAST(a.a_udf_value AS FLOAT) * CAST(x.x_udf_value AS FLOAT) * CAST(x.x_udf_value AS FLOAT)) + (CAST(b.b_udf_value AS FLOAT) * CAST(x.x_udf_value AS FLOAT)) + CAST(c.c_udf_value AS FLOAT)
						FROM #tmp_datafinal td 
						INNER JOIN #temp_cal1 a ON td.hr = a.a_hr
						INNER JOIN #temp_cal2 b ON a.a_hr = b.b_hr
						INNER JOIN #temp_cal3 c ON b.b_hr = c.c_hr
						INNER JOIN #temp_cal4 x ON c.c_hr = x.x_hr
						WHERE td.field_label IN (''Average cost contracted gen w/o startup ($/mwh) - What If'')'
			EXEC(@sql)

			SET @sql ='	SELECT td3.hr [a_hr], udf_value [a_udf_value] INTO #temp_cal1 FROM #tmp_datafinal td3 WHERE td3.field_label IN (''Fuel required for contracted generation (mmbtu) - What If'')
						SELECT td3.hr [b_hr], udf_value [b_udf_value] INTO #temp_cal2 FROM #tmp_datafinal td3 WHERE td3.field_label IN (''Fuel Cost ($/mmbtu)'')

						UPDATE td
						SET td.udf_value = CAST(a.a_udf_value AS FLOAT)* CAST(b.b_udf_value AS FLOAT)
						FROM #tmp_datafinal td 
						INNER JOIN #temp_cal1 a ON td.hr = a.a_hr
						INNER JOIN #temp_cal2 b ON a.a_hr = b.b_hr
						WHERE td.field_label IN (''Fuel required for contracted generation (mmbtu) - What If'')'
			EXEC(@sql)

			SET @sql ='	SELECT td3.hr [a_hr], udf_value [a_udf_value] INTO #temp_cal1 FROM #tmp_datafinal td3 WHERE td3.field_label IN (''Contracted hourly generation - What If'')
						SELECT td3.hr [b_hr], udf_value [b_udf_value] INTO #temp_cal2 FROM #tmp_datafinal td3 WHERE td3.field_label IN (''Variable OM Rate'')

						UPDATE td
						SET td.udf_value = CAST(a.a_udf_value AS FLOAT)* CAST(b.b_udf_value AS FLOAT)
						FROM #tmp_datafinal td 
						INNER JOIN #temp_cal1 a ON td.hr = a.a_hr
						INNER JOIN #temp_cal2 b ON a.a_hr = b.b_hr
						WHERE td.field_label IN (''O&M $ - What If'')'
			EXEC(@sql)

			SET @sql ='	SELECT td3.hr [a_hr], udf_value [a_udf_value] INTO #temp_cal1 FROM #tmp_datafinal td3 WHERE td3.field_label IN (''Fuel cost contracted gen - What If'')
						SELECT td3.hr [b_hr], udf_value [b_udf_value] INTO #temp_cal2 FROM #tmp_datafinal td3 WHERE td3.field_label IN (''O&M $ - What If'')
						SELECT td3.hr [c_hr], udf_value [c_udf_value] INTO #temp_cal3 FROM #tmp_datafinal td3 WHERE td3.field_label IN (''Contracted hourly generation - What If'')

						UPDATE td
						SET td.udf_value = (CAST(a.a_udf_value AS FLOAT) + CAST(b.b_udf_value AS FLOAT))/CASE WHEN (CAST(c.c_udf_value AS FLOAT)) = 0 THEN 1 ELSE (CAST(c.c_udf_value AS FLOAT)) END
						FROM #tmp_datafinal td 
						INNER JOIN #temp_cal1 a ON td.hr = a.a_hr
						INNER JOIN #temp_cal2 b ON a.a_hr = b.b_hr
						INNER JOIN #temp_cal3 c ON b.b_hr = c.c_hr
						WHERE td.field_label IN (''Average cost contracted gen w/o startup ($/mwh) - What If'')'
			EXEC(@sql)
		END

		set @sql = '
		select case when field_label = ''Minimum capacity'' then ''<b>'' + plant_id + ''</b>'' else null end [Plant ID]
			, case when field_label = ''Minimum capacity'' then ''<b>'' + cast(unit_id as varchar(30)) + ''</b>'' else null end [Unit ID]
			, field_label [Item]
			, ' + @pivot_cols + ' 
		from ( select [category],plant_id, unit_id, field_label, udf_value, hr from #tmp_datafinal) t1
		pivot ( max([udf_value]) for [hr] in (' + @pivot_cols + ')) p1
		order by 
		
			case field_label
				when ''Minimum capacity'' then 1
				when ''Maximum capacity'' then 2
				when ''Available capacity'' then 3
				when ''Fuel Type'' then 4
				when ''Heat Rate A Coefficient'' then 5
				when ''Heat Rate B Coefficient'' then 6
				when ''Heat Rate C Coefficient'' then 7
				when ''Flat Heat Rate'' then 8
				when ''Variable OM Rate'' then 9
				when ''Cold Start Dollars'' then 10
				when ''Warm Start dollars'' then 11
				when ''Hot Start Dollars'' then 12
				when ''Owner 1'' then 13
				when ''Owner 1 Percent Share'' then 14
				when ''Owner 2'' then 15
				when ''Owner 2 Percent Share'' then 16
				when ''Must Run Indicator'' then 17
				when ''Ramp Rate(MW/ Min)'' then 18
				
				when ''Average cost contracted gen w/o startup ($/mwh)'' then 100
				when ''O&M $'' then 99
				when ''Fuel cost contracted gen'' then 98
				when ''Fuel required for contracted generation (mmbtu)'' then 97
				when ''Contracted hourly generation'' then 96
				when ''Fuel Cost ($/mmbtu)'' then 95
				when ''Unit Availability'' then 94
				when ''Contracted hourly generation - what if'' then 101
				when ''Fuel required for contracted generation (mmbtu) - what if'' then 102
				when ''Fuel cost contracted gen - what if'' then 103
				when ''O&M $ - what if'' then 104
				when ''Average cost contracted gen w/o startup ($/mwh) - what if'' then 105
				else 50
			end
		'
		--print(@sql)
		exec(@sql)
		
		--test
		/*
		declare @pivot_cols varchar(max)
		
		SELECT @pivot_cols = STUFF(
			(SELECT distinct ',['  + cast(m.[hr] AS varchar) + ']'
			from #tmp_data2 m
			FOR XML PATH(''))
		, 1, 1, '')
		--print(@pivot_cols)
		
		set @sql = '
		select plant_id [Plant ID], unit_id [Unit ID], field_label [UDF], ' + @pivot_cols + ' 
		from ( select plant_id, unit_id, field_label, udf_value, hr from #tmp_data2) t1
		pivot ( max([udf_value]) for [hr] in (' + @pivot_cols + ')) p1
		
		'
		--print(@sql)
		exec(@sql)
		*/
		
	end
end try
begin catch
	declare @err_msg varchar(5000) = error_message()
	---print 'Catch Error (spa_generation_report) : ' + @err_msg

end catch
