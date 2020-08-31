-- create the fulltext index  on counterparty_bank_info

IF NOT OBJECTPROPERTY(OBJECT_ID('counterparty_bank_info'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON counterparty_bank_info (bank_name,wire_ABA,ACH_ABA,Account_no,Address1,Address2,accountname,reference) KEY INDEX PK_counterparty_bank_info;
END
ELSE
    PRINT 'FULLTEXT INDEX ON counterparty_bank_info Already Exists.'
GO