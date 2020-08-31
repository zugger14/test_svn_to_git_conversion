TRUNCATE TABLE Contract_report_template
--insert into Contract_report_template (template_name  ,template_desc, sub_id, filename)
-- values ('DWP Invoice Template','DWP Invoice Template',1 ,'report_template_dwp_invoice.php')
SET IDENTITY_INSERT Contract_report_template ON 

--insert into Contract_report_template (template_id, template_name  ,template_desc, sub_id, filename)
-- values (1, 'Ladwp Template','Ladwp Template',1 ,'report_template_ladwp.php')

insert into Contract_report_template (template_id, template_name  ,template_desc, sub_id, filename)
 values (2, 'DWP Invoice Template','DWP Invoice Template',1 ,'report_template_dwp_invoice.php')
 
 
--insert into Contract_report_template (template_id, template_name  ,template_desc, sub_id, filename)
-- values (3, 'Ladwp Template','Ladwp Template',12 ,'report_template_ladwp.php')

insert into Contract_report_template (template_id, template_name  ,template_desc, sub_id, filename)
 values (4, 'DWP Invoice Template','DWP Invoice Template',12 ,'report_template_dwp_invoice.php')

SET IDENTITY_INSERT Contract_report_template OFF 

