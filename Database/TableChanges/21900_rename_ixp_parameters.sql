IF OBJECT_ID(N'[dbo].ixp_ssis_parameters', N'U') IS NOT NULL
BEGIN
	EXEC sp_rename 'ixp_ssis_parameters', 'ixp_parameters'
END

IF  EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_ixp_ssis_parameters]'))
    DROP TRIGGER [dbo].[TRGUPD_ixp_ssis_parameters]
GO

IF COL_LENGTH('ixp_parameters', 'ixp_ssis_parameters_id') IS NOT NULL 
BEGIN
	EXEC sp_rename 'ixp_parameters.ixp_ssis_parameters_id', 'ixp_parameters_id', 'COLUMN';
END

IF COL_LENGTH('[dbo].ixp_parameters','clr_function_id') IS NULL 
BEGIN
	ALTER TABLE dbo.ixp_parameters ADD clr_function_id INT	
END

IF COL_LENGTH('[dbo].ixp_parameters','ssis_package') IS NULL 
BEGIN
	ALTER TABLE dbo.ixp_parameters ADD ssis_package INT	
END

IF COL_LENGTH('[dbo].ixp_parameters','validation_message') IS NULL
BEGIN
	ALTER TABLE ixp_parameters ADD validation_message VARCHAR(max)
END

IF COL_LENGTH('[dbo].ixp_parameters','insert_required') IS NULL
BEGIN
	ALTER TABLE ixp_parameters ADD insert_required VARCHAR(max)
END


IF  EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_ixp_parameters]'))
    DROP TRIGGER [dbo].[TRGUPD_ixp_parameters]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ixp_parameters]
ON [dbo].ixp_parameters
FOR UPDATE
AS
BEGIN
    --this check is required to prevent recursive trigger
    UPDATE ixp_parameters
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM ixp_parameters t
      INNER JOIN DELETED u ON t.[ixp_parameters_id] = u.[ixp_parameters_id]
END
GO