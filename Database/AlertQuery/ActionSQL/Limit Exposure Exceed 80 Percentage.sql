BEGIN TRAN

IF EXISTS (SELECT 1 FROM adiha_process.sys.tables WHERE [name] = 'nested_alert_process_id_na')
BEGIN


SELECT 
[counterparty_name] [Counterparty],
[total_limit_provided] [Limit],
[limit_variance] [Limit Variance],
[exposure_percent] [Exposure Percentage],
'Limit Exposure Exceed 80%' [Description]
INTO staging_table.alert_credit_exposure_output_process_id_aceo
FROM [output_table] temp



END

ROLLBACK