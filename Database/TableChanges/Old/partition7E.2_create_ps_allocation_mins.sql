/* 
Author : Santosh Gupta 
Date: March 20th 2012
Purpose: To Create Partition Scheme for all tables related to Allocation data
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT exists( select 1 FROM sys.partition_schemes WHERE [NAME]=N'ps_allocation_mins')
BEGIN 

CREATE PARTITION SCHEME [ps_allocation_mins]
AS 
PARTITION pf_allocation_mins TO 
(			   [FG_DATE_001],[FG_DATE_002], [FG_DATE_003], [FG_DATE_004], [FG_DATE_005], [FG_DATE_006], 
				[PRIMARY]
               )

END


    