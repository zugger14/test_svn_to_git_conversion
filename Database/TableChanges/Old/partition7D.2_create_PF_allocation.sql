/* 
Author : Santosh Gupta 
Date: March 20th 2012
Purpose: To Create Partition Function for all tables related to Allocation data
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT exists( select 1 FROM sys.partition_functions WHERE [NAME]=N'PF_allocation')
BEGIN 
	

CREATE PARTITION FUNCTION PF_allocation(datetime)
AS 
RANGE LEFT FOR VALUES (
'2011-09-30',   -- Sep 2011
'2011-10-31',    -- Oct 2011
'2011-11-30',   -- Nov 2011
'2011-12-31',   -- Dec 2011
'2012-01-31',   -- Jan 2012
'2012-02-29'--,    -- Feb 2012
--'2012-03-31'    -- March 2012
 )   
END


    