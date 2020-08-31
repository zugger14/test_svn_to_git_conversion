
IF COL_LENGTH('index_fees_breakdown', 'contract_id') IS NULL
BEGIN
alter table index_fees_breakdown add contract_id int
alter table index_fees_breakdown add counterparty_id int
END

IF COL_LENGTH('index_fees_breakdown_settlement', 'contract_id') IS NULL
BEGIN
	alter table index_fees_breakdown_settlement add contract_id int
	alter table index_fees_breakdown_settlement add counterparty_id int
END
