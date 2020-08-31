/**
update report_id to null for all report_id = 0, table:data_source
sligal
10/05/2012
**/

UPDATE data_source
SET    report_id = NULL
WHERE report_id = 0