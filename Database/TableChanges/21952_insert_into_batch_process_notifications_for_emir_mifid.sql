DELETE 
FROM batch_process_notifications 
WHERE process_id IN ('5errMifid86a1', '5a27mifida69e')

DECLARE @temp_path VARCHAR(500), 
		@regulatory_role INT,
		@ftp_url VARCHAR(1000),
		@ftp_username VARCHAR(1000),
		@ftp_password VARBINARY(1024)

SELECT @regulatory_role = role_id 
FROM application_security_role 
WHERE role_name = 'Regulatory Submission'

SELECT @temp_path = document_path + '\temp_Note',
	   @ftp_url = export_ftp_url,
	   @ftp_username = export_ftp_username,
	   @ftp_password = export_ftp_password
FROM connection_string

IF NOT EXISTS(SELECT 1 FROM batch_process_notifications WHERE process_id = '5a27mifida69e' AND role_id = @regulatory_role)
BEGIN
	INSERT INTO batch_process_notifications (
		user_login_id, role_id, process_id, notification_type, attach_file, scheduled, csv_file_path, compress_file, delimiter, 
		report_header, output_file_format, xml_format, is_ftp, ftp_url, ftp_username, ftp_password, ftp_folder_path
	)
	VALUES (NULL, @regulatory_role, '5a27mifida69e', 752, 'y', 'n', @temp_path, 'y', ',', 1, '.xml', -100002, 1, @ftp_url, @ftp_username, @ftp_password, 'outgoing')
END

IF NOT EXISTS(SELECT 1 FROM batch_process_notifications WHERE process_id = '5errMifid86a1' AND role_id = @regulatory_role)
BEGIN
	INSERT INTO batch_process_notifications (
		user_login_id, role_id, process_id, notification_type, attach_file, scheduled, csv_file_path, compress_file, delimiter, 
		report_header, output_file_format, xml_format, is_ftp
	)
	VALUES (NULL, @regulatory_role, '5errMifid86a1', 752, 'y', 'n', @temp_path, 'n', ',', 1, '.csv', NULL, 0)
END