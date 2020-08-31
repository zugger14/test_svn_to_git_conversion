/* 
Author : Santosh Gupta 
Date: 10th May 2012
Purpose: To Create Partition Function for report_hourly_position_profile


*/



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF NOT exists( SELECT 1 FROM sys.partition_functions WHERE [NAME]=N'PF_Position_report_hourly_position_profile')
BEGIN 
	

CREATE PARTITION FUNCTION PF_Position_report_hourly_position_profile(DATETIME)
AS 
RANGE LEFT FOR VALUES (
'2011-06-30',   -- Jun 2011
'2011-07-31',   -- Jul 2011
'2011-08-31',   -- Aug 2011
'2011-09-30',   -- Sep 2011
'2011-10-31',    -- Oct 2011
'2011-11-30',   -- Nov 2011
'2011-12-31',   -- Dec 2011
'2012-01-31',   -- Jan 2012
'2012-02-29',    -- Feb 2012
'2012-03-31',    -- Mar 2012
'2012-04-30',    -- Apr 2012
'2012-05-31'--,   -- May 2012
 )   
END


    