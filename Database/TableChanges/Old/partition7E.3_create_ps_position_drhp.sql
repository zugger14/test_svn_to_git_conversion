/* 
Author : Santosh Gupta 
Date: 10th May 2012
Purpose: To Create Partition Scheme for Position - delta_Report_hourly_position
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS(SELECT 1 FROM sys.partition_schemes WHERE [NAME] = N'ps_position_delta_report_hourly_position')
BEGIN 

CREATE PARTITION SCHEME [ps_position_delta_report_hourly_position]
AS 
PARTITION pf_position_delta_report_hourly_position TO 
(			   [FG_DATE_001],[FG_DATE_002], [FG_DATE_003], [FG_DATE_004], [FG_DATE_005], [FG_DATE_006], 
			   [FG_DATE_007],[FG_DATE_008], [FG_DATE_009], [FG_DATE_010], [FG_DATE_011], [FG_DATE_012],
				[PRIMARY]
               )

END


    