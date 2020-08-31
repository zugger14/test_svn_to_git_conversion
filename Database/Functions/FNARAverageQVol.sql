IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARAverageQVol]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARAverageQVol]
GO
--SELECT dbo.FNARAverageQVol(23, 1, '2013-01-01', 1)

CREATE FUNCTION [dbo].[FNARAverageQVol]
(
	@meter_id INT, 
	@channel INT,
	@prod_date DATETIME, 
	@hour INT,
	@is_dst INT
	
)
RETURNS FLOAT 
AS  
BEGIN 
	
	DECLARE @avg_price FLOAT
	DECLARE @meter_data_id INT
	
	SELECT @meter_data_id = md.meter_data_id from mv90_data md
	JOIN mv90_data_mins mdm ON md.meter_data_id = mdm.meter_data_id 
	WHERE meter_id = @meter_id AND mdm.prod_date = @prod_date AND md.channel = @channel
	
	;WITH cte AS (
		SELECT SUBSTRING(REPLACE(unpvt.[hour],'hr',''), 0, CHARINDEX('_', REPLACE(unpvt.[hour],'hr',''))) [Hour],unpvt.min_mult FROM 
		(SELECT mdm.Hr1_15, mdm.Hr1_30, mdm.Hr1_45, mdm.Hr1_60, 
				mdm.Hr2_15, mdm.Hr2_30, mdm.Hr2_45, mdm.Hr2_60,
				CASE WHEN @is_dst = 0 THEN mdm.hr3_15 - ISNULL(mdm.hr25_15,0) ELSE mdm.hr25_15 END Hr3_15,
				CASE WHEN @is_dst = 0 THEN mdm.hr3_30 - ISNULL(mdm.hr25_30,0) ELSE mdm.hr25_30 END Hr3_30,
				CASE WHEN @is_dst = 0 THEN mdm.hr3_45 - ISNULL(mdm.hr25_45,0) ELSE mdm.hr25_45 END Hr3_45,
				CASE WHEN @is_dst = 0 THEN mdm.hr3_60 - ISNULL(mdm.hr25_60,0) ELSE mdm.hr25_60 END Hr3_60, 
				mdm.Hr4_15, mdm.Hr4_30, mdm.Hr4_45, mdm.Hr4_60,
				mdm.Hr5_15, mdm.Hr5_30, mdm.Hr5_45, mdm.Hr5_60,
				mdm.Hr6_15, mdm.Hr6_30, mdm.Hr6_45, mdm.Hr6_60,
				mdm.Hr7_15, mdm.Hr7_30, mdm.Hr7_45, mdm.Hr7_60,
				mdm.Hr8_15, mdm.Hr8_30, mdm.Hr8_45, mdm.Hr8_60,
				mdm.Hr9_15, mdm.Hr9_30, mdm.Hr9_45, mdm.Hr9_60,
				mdm.Hr10_15, mdm.Hr10_30, mdm.Hr10_45, mdm.Hr10_60,
				mdm.Hr11_15, mdm.Hr11_30, mdm.Hr11_45, mdm.Hr11_60,
				mdm.Hr12_15, mdm.Hr12_30, mdm.Hr12_45, mdm.Hr12_60,
				mdm.Hr13_15, mdm.Hr13_30, mdm.Hr13_45, mdm.Hr13_60,
				mdm.Hr14_15, mdm.Hr14_30, mdm.Hr14_45, mdm.Hr14_60,
				mdm.Hr15_15, mdm.Hr15_30, mdm.Hr15_45, mdm.Hr15_60,
				mdm.Hr16_15, mdm.Hr16_30, mdm.Hr16_45, mdm.Hr16_60,
				mdm.Hr17_15, mdm.Hr17_30, mdm.Hr17_45, mdm.Hr17_60,
				mdm.Hr18_15, mdm.Hr18_30, mdm.Hr18_45, mdm.Hr18_60,
				mdm.Hr19_15, mdm.Hr19_30, mdm.Hr19_45, mdm.Hr19_60,
				mdm.Hr20_15, mdm.Hr20_30, mdm.Hr20_45, mdm.Hr20_60,
				mdm.Hr21_15, mdm.Hr21_30, mdm.Hr21_45, mdm.Hr21_60,
				mdm.Hr22_15, mdm.Hr22_30, mdm.Hr22_45, mdm.Hr22_60,
				mdm.Hr23_15, mdm.Hr23_30, mdm.Hr23_45, mdm.Hr23_60,
				mdm.Hr24_15, mdm.Hr24_30, mdm.Hr24_45, mdm.Hr24_60,
				mdm.Hr25_15, mdm.Hr25_30, mdm.Hr25_45, mdm.Hr25_60
		 FROM mv90_data_mins mdm
		 WHERE meter_data_id = @meter_data_id AND
				prod_date = @prod_date
		) p
		   
		 UNPIVOT
		 (min_mult FOR [hour] IN (
				Hr1_15, Hr1_30, Hr1_45, Hr1_60, 
				Hr2_15, Hr2_30, Hr2_45, Hr2_60, 
				Hr3_15, Hr3_30, Hr3_45, Hr3_60,
				Hr4_15, Hr4_30, Hr4_45, Hr4_60,
				Hr5_15, Hr5_30, Hr5_45, Hr5_60,
				Hr6_15, Hr6_30, Hr6_45, Hr6_60,
				Hr7_15, Hr7_30, Hr7_45, Hr7_60,
				Hr8_15, Hr8_30, Hr8_45, Hr8_60,
				Hr9_15, Hr9_30, Hr9_45, Hr9_60,
				Hr10_15, Hr10_30, Hr10_45, Hr10_60,
				Hr11_15, Hr11_30, Hr11_45, Hr11_60,
				Hr12_15, Hr12_30, Hr12_45, Hr12_60,
				Hr13_15, Hr13_30, Hr13_45, Hr13_60,
				Hr14_15, Hr14_30, Hr14_45, Hr14_60,
				Hr15_15, Hr15_30, Hr15_45, Hr15_60,
				Hr16_15, Hr16_30, Hr16_45, Hr16_60,
				Hr17_15, Hr17_30, Hr17_45, Hr17_60,
				Hr18_15, Hr18_30, Hr18_45, Hr18_60,
				Hr19_15, Hr19_30, Hr19_45, Hr19_60,
				Hr20_15, Hr20_30, Hr20_45, Hr20_60,
				Hr21_15, Hr21_30, Hr21_45, Hr21_60,
				Hr22_15, Hr22_30, Hr22_45, Hr22_60,
				Hr23_15, Hr23_30, Hr23_45, Hr23_60,
				Hr24_15, Hr24_30, Hr24_45, Hr24_60,
				Hr25_15, Hr25_30, Hr25_45, Hr25_60)
		 ) AS unpvt )
 
	SELECT @avg_price = AVG(min_mult) FROM CTE
	WHERE hour = @hour
	
	RETURN @avg_price
END
