ALTER TABLE report_netted_gl_entry_arch2
ADD tempID int NULL

GO 

UPDATE report_netted_gl_entry_arch2
SET tempID = netted_gl_entry_id

GO

ALTER TABLE report_netted_gl_entry_arch2
DROP COLUMN netted_gl_entry_id

GO

ALTER TABLE report_netted_gl_entry_arch2
ADD netted_gl_entry_id int NULL	

GO

UPDATE report_netted_gl_entry_arch2
SET netted_gl_entry_id = tempID

GO

ALTER TABLE report_netted_gl_entry_arch2
DROP COLUMN tempID

GO

ALTER TABLE report_netted_gl_entry_arch2
ALTER COLUMN netted_gl_entry_id INT NOT NULL	

GO
