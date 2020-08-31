/* 
Author : Santosh Gupta 
Date: May 23 2012
Purpose: To Create Partition Function for all tables related to Nomination
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT exists( select 1 FROM sys.partition_functions WHERE [NAME]=N'PF_nomination')
BEGIN 
	

CREATE PARTITION FUNCTION PF_nomination(datetime)
AS 
RANGE LEFT FOR VALUES (

'2012-06-30',    -- April 2012
'2012-07-31'    -- May 2012

 )   
END


    