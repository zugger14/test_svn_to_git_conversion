IF EXISTS (SELECT 1 FROM adiha_process.sys.tables WHERE [name] = 'nested_alert_process_id_na')
BEGIN
SELECT 'Account Status' [Changed Column],
       sdv_p.code [Previous Value],
       sdv_c.code [Current Value]
INTO staging_table.alert_credit_file_output_process_id_acfo
FROM [output_table] temp
INNER JOIN counterparty_credit_info cci ON  temp.counterparty_id = cci.counterparty_id
LEFT JOIN static_data_value sdv_p ON  sdv_p.value_id = temp.previous_account_status
LEFT JOIN static_data_value sdv_c ON  sdv_c.value_id = cci.account_status
WHERE  temp.account_status_compare = 0

UNION ALL

SELECT 'Limit' [Changed Column],
       CAST(ISNULL(temp.previous_credit_limit, 0) AS VARCHAR(100)) [Previous Value],
       CAST(ISNULL(cci.credit_limit, 0) AS VARCHAR(100)) [Current Value]
FROM [output_table] temp
INNER JOIN counterparty_credit_info cci ON  temp.counterparty_id = cci.counterparty_id
WHERE temp.credit_limit_compare = 0

UNION ALL

SELECT 'Primary Debt Rating' [Changed Column],
       sdv_p.code [Previous Value],
       sdv_c.code [Current Value]
FROM [output_table] temp
INNER JOIN counterparty_credit_info cci ON  temp.counterparty_id = cci.counterparty_id
LEFT JOIN static_data_value sdv_p ON  sdv_p.value_id = temp.previous_Debt_rating
LEFT JOIN static_data_value sdv_c ON  sdv_c.value_id = cci.Debt_rating
WHERE  temp.debt_rating_compare = 0

UNION ALL

SELECT 'Debt Rating 2' [Changed Column],
       sdv_p.code [Previous Value],
       sdv_c.code [Current Value]
FROM [output_table] temp
INNER JOIN counterparty_credit_info cci ON  temp.counterparty_id = cci.counterparty_id
LEFT JOIN static_data_value sdv_p ON  sdv_p.value_id = temp.previous_Debt_Rating2
LEFT JOIN static_data_value sdv_c ON  sdv_c.value_id = cci.Debt_Rating2
WHERE  temp.debt_rating2_compare = 0

UNION ALL

SELECT 'Debt Rating 3' [Changed Column],
       sdv_p.code [Previous Value],
       sdv_c.code [Current Value]
FROM [output_table] temp
INNER JOIN counterparty_credit_info cci ON  temp.counterparty_id = cci.counterparty_id
LEFT JOIN static_data_value sdv_p ON  sdv_p.value_id = temp.previous_Debt_Rating3
LEFT JOIN static_data_value sdv_c ON  sdv_c.value_id = cci.Debt_Rating3
WHERE  temp.debt_rating3_compare = 0

UNION ALL

SELECT 'Debt Rating 4' [Changed Column],
       sdv_p.code [Previous Value],
       sdv_c.code [Current Value]
FROM [output_table] temp
INNER JOIN counterparty_credit_info cci ON  temp.counterparty_id = cci.counterparty_id
LEFT JOIN static_data_value sdv_p ON  sdv_p.value_id = temp.previous_Debt_Rating4
LEFT JOIN static_data_value sdv_c ON  sdv_c.value_id = cci.Debt_Rating4
WHERE  temp.debt_rating4_compare = 0

UNION ALL

SELECT 'Debt Rating 5' [Changed Column],
       sdv_p.code [Previous Value],
       sdv_c.code [Current Value]
FROM [output_table] temp
INNER JOIN counterparty_credit_info cci ON  temp.counterparty_id = cci.counterparty_id
LEFT JOIN static_data_value sdv_p ON  sdv_p.value_id = temp.previous_Debt_Rating5
LEFT JOIN static_data_value sdv_c ON  sdv_c.value_id = cci.Debt_Rating5
WHERE  temp.debt_rating5_compare = 0
END