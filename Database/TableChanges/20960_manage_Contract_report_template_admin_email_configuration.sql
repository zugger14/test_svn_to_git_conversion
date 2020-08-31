

IF NOT EXISTS(SELECT * FROM Contract_report_template where template_name ='Invoice Report Collection' )
BEGIN
	INSERT INTO Contract_report_template (template_name,template_desc,sub_id,[filename],template_type,[default],template_category,document_type,xml_map_filename)
	VALUES('Invoice Report Collection','Invoice Report Collection',NULL,'Invoice Report Collection',38,1,42024,'r',NULL)
END
 

 UPDATE admin_email_configuration SET  default_email = 'y'   WHERE  template_name = 'Email Template' and module_type = 17804


 