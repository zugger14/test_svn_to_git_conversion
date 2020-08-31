IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARDutchTOU]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARDutchTOU]
-- SELECT DBO.FNARDutchTOU('2011-01-01', 95, 45)
GO
CREATE FUNCTION [dbo].[FNARDutchTOU] (
	@maturity_date datetime,
	@counterparty_id as varchar(50),
	@contract_id as varchar(50)
	)
RETURNS float AS  
BEGIN 

-----TESTING
--declare @maturity_date datetime,  @counterparty_id int, @contract_id int
--set @maturity_date='2011-01-01'
--set @counterparty_id=95
--set @contract_id=45
----END OF TESTING


	DECLARE @baseload float,  @max_rol_var float, @min_rol_var float, @max_volume float;
--
--	SELECT @baseload =  avg(volume) from 
--	(select volume
--	FROM
--	(
--	SELECT  
--		mdm.prod_date,  
--		SUM(hr1) hr1, SUM(hr2) hr2, SUM(hr3) hr3, SUM(hr4) hr4, SUM(hr5) hr5, SUM(hr6) hr6, SUM(hr7) hr7,  SUM(hr8) hr8,  
--		SUM(hr9) hr9, SUM(hr10) hr10, SUM(hr11) hr11, SUM(hr12) hr12, SUM(hr13) hr13, SUM(hr14) hr14, SUM(hr15) hr15,  
--		SUM(hr16) hr16, SUM(hr17) hr17,  SUM(hr18) hr18,  SUM(hr19) hr19,  SUM(hr20) hr20,  SUM(hr21) hr21,  
--		SUM(hr22) hr22,  SUM(hr23) hr23,  SUM(hr24) hr24
--	   FROM mv90_data_hour mdm
--		inner join recorder_properties rp on rp.recorderid = mdm.recorderid and rp.channel = mdm.channel
--		inner join recorder_generator_map rgm on rgm.recorderid = rp.recorderid
--		inner join rec_generator rg on rg.generator_id = rgm.generator_id and rg.ppa_counterparty_id = @counterparty_id
--		and rg.ppa_contract_id = @contract_id 
--		inner join
--		contract_group cg on rg.ppa_contract_id=cg.contract_id 
--		group by  mdm.prod_date
--	)p
--	UNPIVOT
--		  (volume for hour IN([hr1],[hr2],[hr3],[hr4],[hr5],[hr6],[hr7],[hr8],[hr9],[hr10],[hr11],[hr12],[hr13],[hr14],[hr15],[hr16],[hr17],[hr18],[hr19],[hr20],[hr21],[hr22],[hr23],[hr24])
--	) AS unpvt) x where volume <> 0
--
--
--	;WITH Meter_Data (row_id,term_start,volume, vol_variance) 
--	AS (select row_number() OVER(order by prod_date) row_id,
--			DATEADD(hour, (CAST(REPLACE(hour,'hr','') AS INT)-1), prod_date) term_start, volume, vol_variance
--		from 
--		(
--	select prod_date, Hour, volume, (Volume - @baseload) vol_variance
--		FROM
--		(
--		SELECT  
--		mdm.prod_date,  
--		SUM(hr1) hr1, SUM(hr2) hr2, SUM(hr3) hr3, SUM(hr4) hr4, SUM(hr5) hr5, SUM(hr6) hr6, SUM(hr7) hr7,  SUM(hr8) hr8,  
--		SUM(hr9) hr9, SUM(hr10) hr10, SUM(hr11) hr11, SUM(hr12) hr12, SUM(hr13) hr13, SUM(hr14) hr14, SUM(hr15) hr15,  
--		SUM(hr16) hr16, SUM(hr17) hr17,  SUM(hr18) hr18,  SUM(hr19) hr19,  SUM(hr20) hr20,  SUM(hr21) hr21,  
--		SUM(hr22) hr22,  SUM(hr23) hr23,  SUM(hr24) hr24
--	   FROM mv90_data_hour mdm
--		inner join recorder_properties rp on rp.recorderid = mdm.recorderid and rp.channel = mdm.channel
--		inner join recorder_generator_map rgm on rgm.recorderid = rp.recorderid
--		inner join rec_generator rg on rg.generator_id = rgm.generator_id and rg.ppa_counterparty_id = @counterparty_id
--		and rg.ppa_contract_id = @contract_id 
--		inner join
--		contract_group cg on rg.ppa_contract_id=cg.contract_id 
--		group by  mdm.prod_date
--	)p
--	UNPIVOT
--		  (volume for hour IN([hr1],[hr2],[hr3],[hr4],[hr5],[hr6],[hr7],[hr8],[hr9],[hr10],[hr11],[hr12],[hr13],[hr14],[hr15],[hr16],[hr17],[hr18],[hr19],[hr20],[hr21],[hr22],[hr23],[hr24])
--	) AS unpvt where volume<>0
--) x
--	)
--
--	select @max_rol_var=max(RollingSum), @min_rol_var=min(RollingSum), @max_volume=max(y.volume)
--	from (
--	select x1.term_start, x1.volume, 
--		(select sum(vol_variance) from  Meter_Data where row_id <= x1.row_id) RollingSum 
--	from
--	Meter_Data x1
--	) y
--
--	return (@max_rol_var-@min_rol_var)/(@max_volume-@baseload) 
RETURN(1)

END