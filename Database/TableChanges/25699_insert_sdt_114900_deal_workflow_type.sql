IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 114900)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (114900, 'Deal Workflow Type', 'Workflow that works with deal/deal detail level data which requires monitoring per row during workflow execution.', 1, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 114900 - Deal Workflow Type.'
END
ELSE
BEGIN
    PRINT 'Static data type 114900 - Deal Workflow Type already EXISTS.'
END            