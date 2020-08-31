ALTER TABLE report_netted_gl_entry_arch1
ADD tempID int NULL

GO 

UPDATE report_netted_gl_entry_arch1
SET tempID = netted_gl_entry_id

GO

ALTER TABLE report_netted_gl_entry_arch1
DROP COLUMN netted_gl_entry_id

GO

ALTER TABLE report_netted_gl_entry_arch1
ADD netted_gl_entry_id int NULL	

GO

UPDATE report_netted_gl_entry_arch1
SET netted_gl_entry_id = tempID

GO

ALTER TABLE report_netted_gl_entry_arch1
DROP COLUMN tempID

GO

ALTER TABLE report_netted_gl_entry_arch1
ALTER COLUMN netted_gl_entry_id INT NOT NULL	

GO

/*
select * from report_netted_gl_entry_arch1
	ALTER TABLE report_netted_gl_entry_arch1 DROP COLUMN netted_gl_entry_id
ALTER TABLE report_netted_gl_entry_arch1 DROP COLUMN tempID
ALTER TABLE report_netted_gl_entry_arch1 ADD netted_gl_entry_id int NOT NULL Identity(1, 1)
*/