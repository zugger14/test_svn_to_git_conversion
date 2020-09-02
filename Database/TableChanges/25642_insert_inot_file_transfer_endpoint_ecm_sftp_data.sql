IF NOT EXISTS(SELECT 1 FROM file_transfer_endpoint WHERE [name] = 'Enercity SFTP ECM')
BEGIN
	INSERT INTO file_transfer_endpoint(auth_certificate_keys_id,[name],file_protocol,host_name_url,port_no,description,user_name,password,remote_directory)
	SELECT NULL, 'Enercity SFTP ECM', '2', '52.174.66.25', '22', 'Download / Upload from SFTP server with username', 'pioneer', 0x01000000E7FA2C9E120B71D9B4FE2D6B6D0DAA8C6437BDC015D16E920C96242BF0095511888F47BB719CCE5025C1DAF5B89E5ED667BEA2CB86138CBF34097815270FB41E12EF8BA32899032836BDC250EFE6A8C644F340FAAC5602630293BD55F33FE8AA2A711EBD45D81F9D,'/home/pioneer/equias/cms-uat/'
END
ELSE
BEGIN
	UPDATE file_transfer_endpoint
		SET auth_certificate_keys_id = NULL
		   ,file_protocol = '2'
		   ,host_name_url = '52.174.66.25'
		   ,port_no = '22'
		   ,description = 'Download / Upload from SFTP server with username'
		   ,user_name = 'pioneer'
		   ,password = 0x01000000E7FA2C9E120B71D9B4FE2D6B6D0DAA8C6437BDC015D16E920C96242BF0095511888F47BB719CCE5025C1DAF5B89E5ED667BEA2CB86138CBF34097815270FB41E12EF8BA32899032836BDC250EFE6A8C644F340FAAC5602630293BD55F33FE8AA2A711EBD45D81F9D
		   , remote_directory = '/home/pioneer/equias/cms-uat/'
	WHERE [name] = 'Enercity SFTP ECM'
END
