IF NOT EXISTS(SELECT 'x' FROM deal_report_template WHERE template_name = 'Confirm Template')
INSERT INTO deal_report_template(template_name,template_type,[filename])
VALUES ('Confirm Template','c','confirm_template.php')
IF NOT EXISTS(SELECT 'x' FROM deal_report_template WHERE template_name = 'Revision Confirm Template')
INSERT INTO deal_report_template(template_name,template_type,[filename])
VALUES ('Revision Confirm Template','r','confirm_template_replacement.php')