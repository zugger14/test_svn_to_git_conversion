/* 
Author : Santosh Gupta 
Date: 16th  Feb 2012
Purpose: To Create Partition Scheme for price curve
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS ( select 1 FROM sys.partition_schemes WHERE [NAME] = N'ps_price_curve')
BEGIN 
CREATE PARTITION SCHEME [ps_price_curve]
AS 
PARTITION pf_price_curve TO 
([FG_DATE_001],[FG_DATE_002], [FG_DATE_003], [FG_DATE_004], [FG_DATE_005], [FG_DATE_006], [FG_DATE_007], 
               [FG_DATE_008], [FG_DATE_009], [FG_DATE_010], [FG_DATE_011],[FG_DATE_012],[FG_DATE_013],
               [FG_DATE_014],[FG_DATE_015],[FG_DATE_016],[FG_DATE_017],[FG_DATE_018],[FG_DATE_019],
               [FG_DATE_020],[FG_DATE_021],[FG_DATE_022],[FG_DATE_023],[FG_DATE_024],[FG_DATE_025],
               [PRIMARY]
               )
END


  ------ For Cached  Curve 
  
  /* 
Author : Santosh Gupta 
Date: 16th  Feb 2012
Purpose: To Create Partition Scheme for price curve
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS ( select 1 FROM sys.partition_schemes WHERE [NAME] = N'ps_cached_curve')
BEGIN 
CREATE PARTITION SCHEME [ps_cached_curve]
AS 
PARTITION pf_cached_curve TO 
([FG_DATE_001],[FG_DATE_002], [FG_DATE_003], [FG_DATE_004], [FG_DATE_005], [FG_DATE_006], [FG_DATE_007], 
               [FG_DATE_008], [FG_DATE_009], [FG_DATE_010], [FG_DATE_011],[FG_DATE_012],[FG_DATE_013],
               [FG_DATE_014],[FG_DATE_015],[FG_DATE_016],[FG_DATE_017],[FG_DATE_018],[FG_DATE_019],
               [FG_DATE_020],[FG_DATE_021],[FG_DATE_022],[FG_DATE_023],[FG_DATE_024],[FG_DATE_025],
               [PRIMARY]
               )
END


    