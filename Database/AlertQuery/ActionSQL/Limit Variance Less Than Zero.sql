IF EXISTS (SELECT 1 FROM adiha_process.sys.tables WHERE [name] = 'nested_alert_process_id_na')
BEGIN
SELECT [counterparty_name] [Counterparty],
       [total_limit_provided] [Limit],
       ISNULL(NULLIF(ABS(total_limit_provided) -ISNULL(net_exposure_to_us, 0),0),1) [Limit Variance],
       'Limit variance is less than zero.' [Description]
       INTO staging_table.alert_credit_exposure_output_process_id_aceo
FROM   [output_table] temp
END