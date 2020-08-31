IF OBJECT_ID(N'[dbo].[spa_application_role_user]', N'P') IS NOT NULL 
 DROP PROCEDURE [dbo].[spa_application_role_user] 
Go
IF OBJECT_ID(N'[dbo].[spa_dump_csv_v2]', N'P') IS NOT NULL 
DROP PROCEDURE [dbo].[spa_dump_csv_v2] 
Go
IF OBJECT_ID(N'[dbo].[spa_rfx_export_import_binary_files]', N'P') IS NOT NULL 
DROP PROCEDURE [dbo].[spa_rfx_export_import_binary_files] 
Go
IF OBJECT_ID(N'[dbo].[spa_risk_factor_model_ui]', N'P') IS NOT NULL 
DROP PROCEDURE [dbo].[spa_risk_factor_model_ui] 
Go
IF OBJECT_ID(N'[dbo].[spa_risk_tenor_bucket_header]', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_risk_tenor_bucket_header] 
Go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ConstantValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[ConstantValue]
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Curve]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Curve]
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAExPostVolume]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAExPostVolume]

