/* 
Author : Santosh Gupta 
Date: 24th  Feb 2012
Purpose: To Create Partition Scheme for all tables related to position
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT exists( select 1 FROM sys.partition_schemes WHERE [NAME]=N'ps_position')
BEGIN 

CREATE PARTITION SCHEME [ps_position]
AS 
PARTITION ps_position TO 
(			   [FG_DATE_001],[FG_DATE_002], [FG_DATE_003], [FG_DATE_004], [FG_DATE_005], [FG_DATE_006], 
			   [FG_DATE_007], [FG_DATE_008], [FG_DATE_009], [FG_DATE_010], [FG_DATE_011],[FG_DATE_012],
 [PRIMARY]
               )

END


    