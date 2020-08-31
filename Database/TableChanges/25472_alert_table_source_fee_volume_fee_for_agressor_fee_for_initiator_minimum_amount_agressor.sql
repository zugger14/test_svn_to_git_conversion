/* Added new column in table source_fee_volume:
	fee_for_agressor, fee_for_initiator, minimum_amount_agressor
*/

IF COL_LENGTH('source_fee_volume', 'fee_for_agressor') IS NULL
BEGIN
	ALTER TABLE source_fee_volume ADD fee_for_agressor FLOAT
END

IF COL_LENGTH('source_fee_volume', 'fee_for_initiator') IS NULL
BEGIN
	ALTER TABLE source_fee_volume ADD fee_for_initiator FLOAT
END

IF COL_LENGTH('source_fee_volume', 'minimum_amount_agressor') IS NULL
BEGIN
	ALTER TABLE source_fee_volume ADD minimum_amount_agressor FLOAT
END







