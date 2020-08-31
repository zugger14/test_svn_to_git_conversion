/* 
Author : Santosh Gupta 
Date: 16th  Feb 2012
Purpose: To Create Partition Function 


*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS( select 1 FROM sys.partition_functions WHERE [NAME] = N'pf_price_curve')
BEGIN 

CREATE PARTITION FUNCTION pf_price_curve(DATETIME)
AS 
RANGE LEFT FOR VALUES (


-----------------------------

'2011-02-01',
'2011-02-28',   -- Feb 2011
'2011-03-31',   -- Mar 2011
'2011-04-30',   -- Apr 2011
'2011-05-31',   -- May 2011
'2011-06-30',   -- Jun 2011
'2011-07-31',   -- Jul 2011
'2011-08-31',   -- Aug 2011
'2011-09-30',   -- Sep 2011
'2011-10-31',    -- Oct 2011
'2011-11-30',   -- Nov 2011
'2011-12-31',   -- Dec 2011
'2012-01-31',   -- Jan 2012
'2012-02-29',   -- Feb 2012
'2012-03-31',	-- Mar 2012
'2012-04-30',	-- Apr 2012
'2012-05-31',   -- May 2012
'2012-06-30',   -- Jun 2012
'2012-07-31',   -- Jul 2012
'2012-08-31',	-- Aug 2012
'2012-09-30',   -- Sep 2012
'2012-10-31',    -- Oct 2012
'2012-11-30',   -- Nov 2012
'2012-12-31',   -- Dec 2012
'2013-01-31'
)   
END


   -------- FOr cached curve 
   /* 
Author : Santosh Gupta 
Date: 16th  Feb 2012
Purpose: To Create Partition Function 


*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS( select 1 FROM sys.partition_functions WHERE [NAME] = N'pf_cached_curve')
BEGIN 

CREATE PARTITION FUNCTION pf_cached_curve(DATETIME)
AS 
RANGE LEFT FOR VALUES (


-----------------------------

'2011-02-01',
'2011-02-28',   -- Feb 2011
'2011-03-31',   -- Mar 2011
'2011-04-30',   -- Apr 2011
'2011-05-31',   -- May 2011
'2011-06-30',   -- Jun 2011
'2011-07-31',   -- Jul 2011
'2011-08-31',   -- Aug 2011
'2011-09-30',   -- Sep 2011
'2011-10-31',    -- Oct 2011
'2011-11-30',   -- Nov 2011
'2011-12-31',   -- Dec 2011
'2012-01-31',   -- Jan 2012
'2012-02-29',   -- Feb 2012
'2012-03-31',	-- Mar 2012
'2012-04-30',	-- Apr 2012
'2012-05-31',   -- May 2012
'2012-06-30',   -- Jun 2012
'2012-07-31',   -- Jul 2012
'2012-08-31',	-- Aug 2012
'2012-09-30',   -- Sep 2012
'2012-10-31',    -- Oct 2012
'2012-11-30',   -- Nov 2012
'2012-12-31',   -- Dec 2012
'2013-01-31'
)   
END


    