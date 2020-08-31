/****** Object:  UserDefinedFunction [dbo].[FNAREODHours]    Script Date: 01/11/2011 09:49:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAREOHHours]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAREOHHours]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAREOHHours]    Script Date: 01/11/2011 09:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAREOHHours](@prod_date DATETIME,@commodity INT,@meter_id INT,@channel INT)

RETURNS FLOAT AS
BEGIN

/* TEST
select [dbo].[FNAREODHours]('2012-07-01',-2,21388,5)
DECLARE @prod_date DATETIME,@meter_id INT,@channel INT
SET  @meter_id=21388
SET  @prod_date='2012-07-01'
SET @channel=1
 
--*/


	DECLARE @no_of_hours INT
		
		;WITH CTE AS (
			SELECT REPLACE(SUBSTRING(unpvt.[hour],0,CHARINDEX('_',unpvt.[hour],0)),'hr','') [Hour],prod_date FROM 
			(SELECT mvs.prod_date, 
					CASE WHEN @commodity=-1 THEN mvs.Hr7_15 ELSE mvs.Hr1_15 END Hr1_15, CASE WHEN @commodity=-1 THEN mvs.Hr7_30 ELSE mvs.Hr1_30 END Hr1_30, CASE WHEN @commodity=-1 THEN mvs.Hr7_45 ELSE mvs.Hr1_45 END Hr1_45,CASE WHEN @commodity=-1 THEN  mvs.Hr7_60 ELSE mvs.Hr1_60 END Hr1_60,
					CASE WHEN @commodity=-1 THEN mvs.Hr8_15 ELSE mvs.Hr2_15 END Hr2_15, CASE WHEN @commodity=-1 THEN mvs.Hr8_30 ELSE mvs.Hr2_30 END Hr2_30, CASE WHEN @commodity=-1 THEN mvs.Hr8_45 ELSE mvs.Hr2_45 END Hr2_45, CASE WHEN @commodity=-1 THEN  mvs.Hr8_60 ELSE mvs.Hr2_60 END Hr2_60,
					CASE WHEN @commodity=-1 THEN mvs.Hr9_15 ELSE mvs.Hr3_15 END Hr3_15, CASE WHEN @commodity=-1 THEN mvs.Hr9_30 ELSE mvs.Hr3_30 END Hr3_30, CASE WHEN @commodity=-1 THEN mvs.Hr9_45 ELSE mvs.Hr3_45 END Hr3_45, CASE WHEN @commodity=-1 THEN  mvs.Hr9_60 ELSE mvs.Hr3_60 END Hr3_60,
					CASE WHEN @commodity=-1 THEN mvs.Hr10_15 ELSE mvs.Hr4_15 END Hr4_15, CASE WHEN @commodity=-1 THEN mvs.Hr10_30 ELSE mvs.Hr4_30 END Hr4_30, CASE WHEN @commodity=-1 THEN mvs.Hr10_45 ELSE mvs.Hr4_45 END Hr4_45, CASE WHEN @commodity=-1 THEN  mvs.Hr10_60 ELSE mvs.Hr4_60 END Hr4_60,
					CASE WHEN @commodity=-1 THEN mvs.Hr11_15 ELSE mvs.Hr5_15 END Hr5_15, CASE WHEN @commodity=-1 THEN mvs.Hr11_30 ELSE mvs.Hr5_30 END Hr5_30, CASE WHEN @commodity=-1 THEN mvs.Hr11_45 ELSE mvs.Hr5_45 END Hr5_45, CASE WHEN @commodity=-1 THEN  mvs.Hr11_60 ELSE mvs.Hr5_60 END Hr5_60,
					CASE WHEN @commodity=-1 THEN mvs.Hr12_15 ELSE mvs.Hr6_15 END Hr6_15, CASE WHEN @commodity=-1 THEN mvs.Hr12_30 ELSE mvs.Hr6_30 END Hr6_30, CASE WHEN @commodity=-1 THEN mvs.Hr12_45 ELSE mvs.Hr6_45 END Hr6_45, CASE WHEN @commodity=-1 THEN  mvs.Hr12_60 ELSE mvs.Hr6_60 END Hr6_60,
					CASE WHEN @commodity=-1 THEN mvs.Hr13_15 ELSE mvs.Hr7_15 END Hr7_15, CASE WHEN @commodity=-1 THEN mvs.Hr13_30 ELSE mvs.Hr7_30 END Hr7_30, CASE WHEN @commodity=-1 THEN mvs.Hr13_45 ELSE mvs.Hr7_45 END Hr7_45, CASE WHEN @commodity=-1 THEN  mvs.Hr13_60 ELSE mvs.Hr7_60 END Hr7_60,
					CASE WHEN @commodity=-1 THEN mvs.Hr14_15 ELSE mvs.Hr8_15 END Hr8_15, CASE WHEN @commodity=-1 THEN mvs.Hr14_30 ELSE mvs.Hr8_30 END Hr8_30, CASE WHEN @commodity=-1 THEN mvs.Hr14_45 ELSE mvs.Hr8_45 END Hr8_45, CASE WHEN @commodity=-1 THEN  mvs.Hr14_60 ELSE mvs.Hr8_60 END Hr8_60,
					CASE WHEN @commodity=-1 THEN mvs.Hr15_15 ELSE mvs.Hr9_15 END Hr9_15, CASE WHEN @commodity=-1 THEN mvs.Hr15_30 ELSE mvs.Hr9_30 END Hr9_30, CASE WHEN @commodity=-1 THEN mvs.Hr15_45 ELSE mvs.Hr9_45 END Hr9_45, CASE WHEN @commodity=-1 THEN  mvs.Hr15_60 ELSE mvs.Hr9_60 END Hr9_60,
					CASE WHEN @commodity=-1 THEN mvs.Hr16_15 ELSE mvs.Hr10_15 END Hr10_15, CASE WHEN @commodity=-1 THEN mvs.Hr16_30 ELSE mvs.Hr10_30 END Hr10_30, CASE WHEN @commodity=-1 THEN mvs.Hr16_45 ELSE mvs.Hr10_45 END Hr10_45, CASE WHEN @commodity=-1 THEN  mvs.Hr16_60 ELSE mvs.Hr10_60 END Hr10_60,
					CASE WHEN @commodity=-1 THEN mvs.Hr17_15 ELSE mvs.Hr11_15 END Hr11_15, CASE WHEN @commodity=-1 THEN mvs.Hr17_30 ELSE mvs.Hr11_30 END Hr11_30, CASE WHEN @commodity=-1 THEN mvs.Hr17_45 ELSE mvs.Hr11_45 END Hr11_45, CASE WHEN @commodity=-1 THEN  mvs.Hr17_60 ELSE mvs.Hr11_60 END Hr11_60,
					CASE WHEN @commodity=-1 THEN mvs.Hr18_15 ELSE mvs.Hr12_15 END Hr12_15,CASE WHEN @commodity=-1 THEN  mvs.Hr18_30 ELSE mvs.Hr12_30 END Hr12_30, CASE WHEN @commodity=-1 THEN mvs.Hr18_45 ELSE mvs.Hr12_45 END Hr12_45, CASE WHEN @commodity=-1 THEN  mvs.Hr18_60 ELSE mvs.Hr12_60 END Hr12_60,
					CASE WHEN @commodity=-1 THEN mvs.Hr19_15 ELSE mvs.Hr13_15 END Hr13_15, CASE WHEN @commodity=-1 THEN mvs.Hr19_30 ELSE mvs.Hr13_30 END Hr13_30, CASE WHEN @commodity=-1 THEN mvs.Hr19_45 ELSE mvs.Hr13_45 END Hr13_45, CASE WHEN @commodity=-1 THEN  mvs.Hr19_60 ELSE mvs.Hr13_60 END Hr13_60,
					CASE WHEN @commodity=-1 THEN mvs.Hr20_15 ELSE mvs.Hr14_15 END Hr14_15, CASE WHEN @commodity=-1 THEN mvs.Hr20_30 ELSE mvs.Hr14_30 END Hr14_30, CASE WHEN @commodity=-1 THEN mvs.Hr20_45 ELSE mvs.Hr14_45 END Hr14_45, CASE WHEN @commodity=-1 THEN  mvs.Hr20_60 ELSE mvs.Hr14_60 END Hr14_60,
					CASE WHEN @commodity=-1 THEN mvs.Hr21_15 ELSE mvs.Hr15_15 END Hr15_15, CASE WHEN @commodity=-1 THEN mvs.Hr21_30 ELSE mvs.Hr15_30 END Hr15_30, CASE WHEN @commodity=-1 THEN mvs.Hr21_45 ELSE mvs.Hr15_45 END Hr15_45, CASE WHEN @commodity=-1 THEN  mvs.Hr21_60 ELSE mvs.Hr15_60 END Hr15_60,
					CASE WHEN @commodity=-1 THEN mvs.Hr22_15 ELSE mvs.Hr16_15 END Hr16_15, CASE WHEN @commodity=-1 THEN mvs.Hr22_30 ELSE mvs.Hr16_30 END Hr16_30, CASE WHEN @commodity=-1 THEN mvs.Hr22_45 ELSE mvs.Hr16_45 END Hr16_45, CASE WHEN @commodity=-1 THEN  mvs.Hr22_60 ELSE mvs.Hr16_60 END Hr16_60,
					CASE WHEN @commodity=-1 THEN mvs.Hr23_15 ELSE mvs.Hr17_15 END Hr17_15, CASE WHEN @commodity=-1 THEN mvs.Hr23_30 ELSE mvs.Hr17_30 END Hr17_30, CASE WHEN @commodity=-1 THEN mvs.Hr23_45 ELSE mvs.Hr17_45 END Hr17_45, CASE WHEN @commodity=-1 THEN  mvs.Hr23_60 ELSE mvs.Hr17_60 END Hr17_60,
					CASE WHEN @commodity=-1 THEN mvs.Hr24_15 ELSE mvs.Hr18_15 END Hr18_15,CASE WHEN @commodity=-1 THEN  mvs.Hr24_30 ELSE mvs.Hr18_30 END Hr18_30, CASE WHEN @commodity=-1 THEN mvs.Hr24_45 ELSE mvs.Hr18_45 END Hr18_45, CASE WHEN @commodity=-1 THEN  mvs.Hr24_60 ELSE mvs.Hr18_60 END Hr18_60,
					CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr1_15,mvs1.Hr1_15) ELSE mvs.Hr19_15 END Hr19_15, CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr1_30,mvs1.Hr1_30) ELSE mvs.Hr19_30 END Hr19_30, CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr1_45,mvs1.Hr1_45) ELSE mvs.Hr19_45 END Hr19_45, CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr1_60,mvs1.Hr1_60) ELSE mvs.Hr19_60 END Hr19_60,
					CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr2_15,mvs1.Hr2_15) ELSE mvs.Hr20_15 END Hr20_15,CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr2_30,mvs1.Hr2_30) ELSE mvs.Hr20_30 END Hr20_30, CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr2_45,mvs1.Hr2_45) ELSE mvs.Hr20_45 END Hr20_45, CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr2_60,mvs1.Hr2_60) ELSE mvs.Hr20_60 END Hr20_60,
					CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr3_15,mvs1.Hr3_15) ELSE mvs.Hr21_15 END Hr21_15, CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr3_30,mvs1.Hr3_30) ELSE mvs.Hr21_30 END Hr21_30, CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr3_45,mvs1.Hr3_45) ELSE mvs.Hr21_45 END Hr21_45, CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr3_60,mvs1.Hr3_60) ELSE mvs.Hr21_60 END Hr21_60,
					CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr4_15,mvs1.Hr4_15) ELSE mvs.Hr22_15 END Hr22_15, CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr4_30,mvs1.Hr4_30) ELSE mvs.Hr22_30 END Hr22_30, CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr4_45,mvs1.Hr4_45) ELSE mvs.Hr22_45 END Hr22_45, CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr4_60,mvs1.Hr4_60) ELSE mvs.Hr22_60 END Hr22_60,
					CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr5_15,mvs1.Hr5_15) ELSE mvs.Hr23_15 END Hr23_15, CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr5_30,mvs1.Hr5_30) ELSE mvs.Hr23_30 END Hr23_30, CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr5_45,mvs1.Hr5_45) ELSE mvs.Hr23_45 END Hr23_45, CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr5_60,mvs1.Hr5_60) ELSE mvs.Hr23_60 END Hr23_60,
					CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr6_15,mvs1.Hr6_15) ELSE mvs.Hr24_15 END Hr24_15, CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr6_30,mvs1.Hr6_30) ELSE mvs.Hr24_30 END Hr24_30, CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr6_45,mvs1.Hr6_45) ELSE mvs.Hr24_45 END Hr24_45, CASE WHEN @commodity=-1 THEN ISNULL(mvs2.Hr6_60,mvs1.Hr6_60) ELSE mvs.Hr24_60 END Hr24_60
				FROM
					meter_id mi
					INNER JOIN mv90_data mv ON mi.meter_id = mv.meter_id
						AND mv.from_date = @prod_date
						AND channel = @channel
					INNER JOIN mv90_data_mins mvs ON mvs.meter_data_id = mv.meter_data_id
					LEFT JOIN mv90_data mv1 ON mv1.meter_id=mv.meter_id
						AND mv1.from_date=DATEADD(m,1,mv.from_date)
						AND @commodity = -1
					LEFT JOIN mv90_data_mins mvs1 ON mvs1.meter_data_id=mv1.meter_data_id
						AND DAY(mvs1.prod_date)=1	
						AND @commodity = -1
					LEFT JOIN mv90_data_mins mvs2 ON mvs2.meter_data_id=mv.meter_data_id
						AND mvs2.prod_date-1=mvs.prod_date
						AND @commodity = -1
				)p
			
				UNPIVOT
				(hr_vol FOR [hour] IN (Hr1_15, Hr1_30, Hr1_45, Hr1_60,
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
					Hr24_15, Hr24_30, Hr24_45, Hr24_60)
				) AS unpvt 
			WHERE
			unpvt.[hr_vol]>0
		)
	
	SELECT @no_of_hours=COUNT(*) FROM (SELECT DISTINCT prod_date,[hour]  from CTE GROUP BY prod_date,[hour]) a
	
	RETURN 	@no_of_hours
END


