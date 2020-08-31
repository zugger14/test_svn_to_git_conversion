/* 
Author : Santosh Gupta 
Date: May 23, 2012
Purpose: To Create Partition Scheme for all tables related to Nomination
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT exists( select 1 FROM sys.partition_schemes WHERE [NAME]=N'ps_nomination')
BEGIN 

CREATE PARTITION SCHEME [ps_nomination]
AS 
PARTITION pf_nomination TO 
(			   [FG_DATE_001],[FG_DATE_002], 
				[PRIMARY]
               )

END


    