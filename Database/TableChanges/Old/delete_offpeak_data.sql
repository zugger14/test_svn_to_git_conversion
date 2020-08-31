DELETE FROM holiday_block WHERE Onpeak_offpeak = 'o'
DELETE FROM hourly_block WHERE Onpeak_offpeak = 'o'
DELETE FROM static_data_value WHERE value_id = 12001
DELETE FROM hour_block_term WHERE block_type = 12001

EXEC spa_generate_hour_block_term NULL, 2000, 2030
/*

SELECT * FROM holiday_block hb WHERE Onpeak_offpeak = 'o'
SELECT * FROM hourly_block hb2 WHERE Onpeak_offpeak = 'o'
SELECT * FROM hour_block_term hbt WHERE hbt.block_type <> 12000

--*/
