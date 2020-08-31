IF OBJECT_ID(N'FNARGeneratorMxHour', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARGeneratorMxHour]
GO
 
CREATE FUNCTION [dbo].[FNARGeneratorMxHour]
(
	@prod_date     VARCHAR(20),
	@generator_id  INT
)
RETURNS FLOAT
AS
BEGIN
	
DECLARE @value FLOAT

	
--select @value=max([value]) from 	
--(
--select
-- MAX(CASE Num WHEN 1 THEN hr1 
--              WHEN 2 THEN hr2 
--              WHEN 3 THEN hr3 
--	      WHEN 4 THEN hr4 
--	      WHEN 5 THEN hr5 
--	      WHEN 6 THEN hr6 
--	      WHEN 7 THEN hr7 
--	      WHEN 8 THEN hr8 
--	      WHEN 9 THEN hr9 
--	      WHEN 10 THEN hr10 
--	      WHEN 11 THEN hr11
--	      WHEN 12 THEN hr12 
--	      WHEN 13 THEN hr13 
--	      WHEN 14 THEN hr14
--	      WHEN 15 THEN hr15 
--	      WHEN 16 THEN hr16 
--	      WHEN 17 THEN hr17
--	      WHEN 18 THEN hr18 
--	      WHEN 19 THEN hr19 
--	      WHEN 20 THEN hr20 
--	      WHEN 21 THEN hr21 
--	      WHEN 22 THEN hr22 
--	      WHEN 23 THEN hr23 
--	      WHEN 24 THEN hr24 
--           END) AS [Value] 
--from
--(
--select
--sum(HR1) as Hr1,
--sum(HR2) as Hr2,
--sum(HR3) as Hr3,
--sum(HR4) as Hr4,
--sum(HR5) as Hr5,
--sum(HR6) as Hr6,
--sum(HR7) as Hr7,
--sum(HR8) as Hr8,
--sum(HR9) as Hr9,
--sum(HR10) as Hr10,
--sum(HR11) as Hr11,
--sum(HR12) as Hr12,
--sum(HR13) as Hr13,
--sum(HR14) as Hr14,
--sum(HR15) as Hr15,
--sum(HR16) as Hr16,
--sum(HR17) as Hr17,
--sum(HR18) as Hr18,
--sum(HR19) as Hr19,
--sum(HR20) as Hr20,
--sum(HR21) as Hr21,
--sum(HR22) as Hr22,
--sum(HR23) as Hr23,
--sum(HR24) as Hr24
--from
--(select
--	mv.[prod_date],
--	rg.generator_id,
--	rgm.recorderid,
--	rg.ppa_contract_id contract_id,
--	rp.uom_id,
--	Hr1*rp.mult_factor HR1,
--	Hr2*rp.mult_factor HR2,
--	Hr3*rp.mult_factor HR3,
--	Hr4*rp.mult_factor HR4,
--	Hr5*rp.mult_factor HR5,
--	Hr6*rp.mult_factor HR6,
--	Hr7*rp.mult_factor HR7,
--	Hr8*rp.mult_factor HR8,
--	Hr9*rp.mult_factor HR9,
--	Hr10*rp.mult_factor HR10,
--	Hr11*rp.mult_factor HR11,
--	Hr12*rp.mult_factor HR12,
--	Hr13*rp.mult_factor HR13,
--	Hr14*rp.mult_factor HR14,
--	Hr15*rp.mult_factor HR15,
--	Hr16*rp.mult_factor HR16,
--	Hr17*rp.mult_factor HR17,
--	Hr18*rp.mult_factor HR18,
--	Hr19*rp.mult_factor HR19,
--	Hr20*rp.mult_factor HR20,
--	Hr21*rp.mult_factor HR21,
--	Hr22*rp.mult_factor HR22,
--	Hr23*rp.mult_factor HR23,
--	Hr24*rp.mult_factor HR24
--from
--	rec_generator rg  inner join	
--	recorder_generator_map rgm on rgm.generator_id=rg.generator_id
--	inner join mv90_data_hour mv on mv.recorderid=rgm.recorderid
--	inner join recorder_properties rp on mv.recorderid=rp.recorderid and rp.channel=mv.channel
--where
--	rg.generator_id=@generator_id and dbo.fnagetcontractmonth(mv.prod_date)=@prod_date
--) 
--a 
---- inner join contract_group cg on cg.contract_id=a.contract_id
---- inner join rec_volume_unit_conversion conv on
---- a.uom_id=conv.from_source_uom_id and conv.to_source_uom_id=cg.volume_uom
---- and conv.state_value_id is null and conv.assignment_type_value_id is null and conv.curve_id is null 
--group by recorderid,prod_date
--)a
--CROSS JOIN ( SELECT 1 UNION 
--             SELECT 2 UNION 
--             SELECT 3 UNION 
--             SELECT 4 UNION 
--             SELECT 5 UNION 
--             SELECT 6 UNION 
--             SELECT 7 UNION 
--             SELECT 8 UNION 
--             SELECT 9 UNION 
--             SELECT 10 UNION 
--             SELECT 11 UNION 
--             SELECT 12 UNION 
--             SELECT 13 UNION 
--             SELECT 14 UNION 
--             SELECT 15 UNION 
--             SELECT 16 UNION 
--             SELECT 17 UNION 
--             SELECT 18 UNION 
--             SELECT 19 UNION 
--             SELECT 20 UNION 
--             SELECT 21 UNION 
--             SELECT 22 UNION 
--             SELECT 23 UNION 
--             SELECT 24  

--) _D(Num)
--GROUP BY  CAST(Num AS VARCHAR) )a

	return @value
END










