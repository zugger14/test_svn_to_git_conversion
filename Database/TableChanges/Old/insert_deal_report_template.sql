SET IDENTITY_INSERT deal_report_template ON
GO
IF NOT EXISTS(SELECT 'X' FROM DEAL_REPORT_TEMPLATE WHERE template_id = 100)
BEGIN
	INSERT INTO deal_report_template(template_id, template_name, template_type, [filename], create_user, create_ts, update_user, update_ts)
		VALUES (100, 'Confirm Template', 'c', 'confirm_template.php', dbo.FNADBUser(), GETDATE(), dbo.FNADBUser(), GETDATE())
END
ELSE
BEGIN
PRINT 'Data of template_id = 100 already exist in table deal_report_template.'
END
IF NOT EXISTS(SELECT 'X' FROM DEAL_REPORT_TEMPLATE WHERE template_id = 101)
BEGIN
	INSERT INTO deal_report_template(template_id, template_name, template_type, [filename], create_user, create_ts, update_user, update_ts)
		VALUES (101, 'Revision Confirm Template', 'r', 'confirm_template_replacement.php', dbo.FNADBUser(), GETDATE(), dbo.FNADBUser(), GETDATE())
END
ELSE
BEGIN
PRINT 'Data of template_id = 101 already exist in table deal_report_template.'
END
SET IDENTITY_INSERT deal_report_template OFF
GO

            