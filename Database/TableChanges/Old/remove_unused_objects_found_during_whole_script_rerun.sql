--Remove unused objects identified during whole script re-run using tool built by Surya.

IF OBJECT_ID(N'[dbo].[FNACoIncidentPeak]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNACoIncidentPeak]
GO

IF OBJECT_ID(N'[dbo].[FNAFormulaTextEMS_WhatIf]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAFormulaTextEMS_WhatIf]
GO

IF OBJECT_ID(N'[dbo].[FNARCoIncidentPeak]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARCoIncidentPeak]
GO
 

IF OBJECT_ID(N'[dbo].[FNARDmdDateTime]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARDmdDateTime]
GO
 
IF OBJECT_ID(N'[dbo].[FNARExPostVolume]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARExPostVolume]
GO
 
IF OBJECT_ID(N'[dbo].[FNARHourlyDmd]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARHourlyDmd]
GO
 
IF OBJECT_ID(N'[dbo].[spa_check_mitigated_dependent_activity_status]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_check_mitigated_dependent_activity_status]
GO

IF OBJECT_ID(N'[dbo].[spa_create_rec_compliance_requirement_report]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_create_rec_compliance_requirement_report]
GO
  

 

