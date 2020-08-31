/* 
Author : Santosh Gupta 
Date: 16th  Feb 2012
Purpose: To Create Partition Scheme


*/



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF NOT exists( select 1 FROM sys.partition_schemes WHERE [NAME]=N'PS_Source_price_curve')
BEGIN 
	

CREATE PARTITION SCHEME [PS_Source_price_curve]
AS 
PARTITION PF_Source_price_curve TO 
([FG_DATE_001],[FG_DATE_002], [FG_DATE_003], [FG_DATE_004], [FG_DATE_005], [FG_DATE_006], [FG_DATE_007], 
               [FG_DATE_008], [FG_DATE_009], [FG_DATE_010], [FG_DATE_011],[FG_DATE_012],[FG_DATE_013],
               [FG_DATE_014],[FG_DATE_015],[FG_DATE_016],[FG_DATE_017],[FG_DATE_018],[FG_DATE_019],
               [PRIMARY]
               )


END


    