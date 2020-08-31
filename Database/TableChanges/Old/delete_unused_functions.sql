/*
* Drop unused user defined functions.
*/

--FNA6MsBlockAverage
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNA6MsBlockAverage]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNA6MsBlockAverage]

--FNAEMS6MsBlockAverage    
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAEMS6MsBlockAverage]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNAEMS6MsBlockAverage]
    
--FNA24HrsAverage 
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNA24HrsAverage]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNA24HrsAverage]

--FNA3Hrs2Samples    
IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNA3Hrs2Samples]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNA3Hrs2Samples] 
 
--FNAUDFCharges
IF EXISTS (SELECT 1 FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[FNAUDFCharges]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION [dbo].[FNAUDFCharges] 
    
--FNAYearCount
IF EXISTS (SELECT 1 FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[FNAYearCount]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION [dbo].[FNAYearCount] 
    
    
--FNARwSum
IF EXISTS (SELECT 1 FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[FNARwSum]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION [dbo].[FNARwSum]     
    