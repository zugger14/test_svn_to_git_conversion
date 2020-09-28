IF COL_LENGTH('master_deal_view', 'counterparty') IS NOT NULL
BEGIN
    ALTER TABLE 
	/**
        Columns
        name : Counterparty Name
    */
	master_deal_view ALTER COLUMN counterparty VARCHAR(500) NOT NULL
END

IF COL_LENGTH('master_deal_view', 'contract') IS NOT NULL
BEGIN
    ALTER TABLE 
	/**
        Columns
        name : Contract Name
    */
	master_deal_view ALTER COLUMN contract VARCHAR(500)
END

IF COL_LENGTH('master_deal_view', 'location') IS NOT NULL
BEGIN
    ALTER TABLE
	/**
        Columns
        name : Location Name
    */
	master_deal_view ALTER COLUMN location VARCHAR(500)
END
