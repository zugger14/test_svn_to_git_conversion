/* 
Author : Santosh Gupta 
Date: 21st June 2012
Purpose: To Create Partition Function for FX_Exposure


*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS( select 1 FROM sys.partition_functions WHERE [NAME] = N'PF_FX_EXPOSURE')
BEGIN 

CREATE PARTITION FUNCTION PF_FX_EXPOSURE(DATETIME)
AS 
RANGE LEFT FOR VALUES (
----------------------------- Single partition to hole only 1 week data 
'2012-07-20',   -- Jul 2012
'2012-07-31'
)   
END

