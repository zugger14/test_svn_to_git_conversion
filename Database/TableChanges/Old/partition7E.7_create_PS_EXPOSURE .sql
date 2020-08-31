/* 
Author : Santosh Gupta 
Date: 21st  June 2012
Purpose: To Create Partition Scheme for FX- Exposure
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS ( select 1 FROM sys.partition_schemes WHERE [NAME] = N'PS_FX_EXPOSURE')
BEGIN 
CREATE PARTITION SCHEME [PS_FX_EXPOSURE]
AS 
PARTITION PF_FX_EXPOSURE TO 
([FG_DATE_001],[FG_DATE_002],[PRIMARY]
               )
END
