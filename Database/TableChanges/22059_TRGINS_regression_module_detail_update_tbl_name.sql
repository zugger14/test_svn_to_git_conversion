SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGINS_regression_module_detail]'))
    DROP TRIGGER [dbo].[TRGINS_regression_module_detail]
GO
-- insert trigger 
CREATE TRIGGER [dbo].[TRGINS_regression_module_detail]
ON [dbo].[regression_module_detail]
FOR INSERT
AS
BEGIN
	UPDATE rmd
	SET table_name =  [name]
	FROM regression_module_detail rmd
	INNER JOIN report_paramset rp ON rmd.regg_rpt_paramset_hash = rp.paramset_hash
	INNER JOIN INSERTED i ON rmd.regression_module_detail_id = i.regression_module_detail_id 
	WHERE rmd.regg_type = 109701--report
END
GO


--update trigger
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_regression_module_detail]'))
    DROP TRIGGER [dbo].[TRGUPD_regression_module_detail]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_regression_module_detail]
ON [dbo].[regression_module_detail]
FOR UPDATE
AS
BEGIN
	IF (NOT UPDATE (update_ts))
	BEGIN
		UPDATE rmd
		SET table_name =  [name]
		FROM regression_module_detail rmd
		INNER JOIN report_paramset rp ON rmd.regg_rpt_paramset_hash = rp.paramset_hash
		INNER JOIN INSERTED i ON rmd.regression_module_detail_id = i.regression_module_detail_id 
		WHERE rmd.regg_type = 109701--report
	
		UPDATE [dbo].[regression_module_detail]
		SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
		FROM [dbo].[regression_module_detail] t
		INNER JOIN DELETED u ON t.[regression_module_detail_id] = u.[regression_module_detail_id]
	END
END

GO