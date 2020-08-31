/* 
Author : Santosh Gupta 
Date: 22nd June 2012
Purpose: To Create Partition Function for MTM


*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS( select 1 FROM sys.partition_functions WHERE [NAME] = N'PF_MTM_DEAL_PNL')
BEGIN 

CREATE PARTITION FUNCTION PF_MTM_DEAL_PNL(DATETIME)
AS 
RANGE LEFT FOR VALUES (
----------------------------- Single partition to hole only 1 week data 
'2012-07-20',   -- Jul 2012
'2012-07-31'
)   
END

-------------------------------------- Source Deal_pnl_detail

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS( select 1 FROM sys.partition_functions WHERE [NAME] = N'PF_MTM_DEAL_PNL_DETAIL')
BEGIN 

CREATE PARTITION FUNCTION PF_MTM_DEAL_PNL_DETAIL(DATETIME)
AS 
RANGE LEFT FOR VALUES (
----------------------------- Single partition to hole only 1 week data 
'2012-07-20',   -- Jul 2012
'2012-07-31'

)   
END



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS( select 1 FROM sys.partition_functions WHERE [NAME] = N'PF_MTM_INDEX_FEES')
BEGIN 

CREATE PARTITION FUNCTION PF_MTM_INDEX_FEES(DATETIME)
AS 
RANGE LEFT FOR VALUES (
----------------------------- Single partition to hole only 1 week data 
'2012-07-20',   -- Jul 2012
'2012-07-31'
)   
END

