IF EXISTS (SELECT * FROM adiha_process.sys.tables WHERE [name] = 'nested_alert_process_id_na')
BEGIN
INSERT INTO message_board (user_login_id, [source], [description], [TYPE])
SELECT CASE WHEN au.role_user = 'r' THEN aru.user_login_id ELSE au.user_login_id END user_login_id,
'Alert',
'Counterparty <b>' + sc.counterparty_name + ' </b> has been disabled. Please reveiw and approve as necessary.<a target=f1 href="' + './dev/batch_process_save.php?__user_name__=' + dbo.fnadbuser() + '&sql_statement=EXEC spa_alert_activity ' + cast(sc.source_counterparty_id as varchar(20)) + ', 20801"><b> Approve </b></a>',
's'
FROM staging_table.nested_alert_process_id_na mv
INNER JOIN source_counterparty sc ON sc.source_counterparty_id = mv.Id
INNER JOIN alert_users au ON au.alert_sql_id = mv.sql_id 
LEFT JOIN application_role_user aru ON  aru.role_id = au.role_id
END