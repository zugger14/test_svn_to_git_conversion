-- SELECT description1, description2, description3, description4 FROM source_deal_header, aggregate_envrionment_comment WHERE source_deal_header_id = 249958
IF COL_LENGTH('source_deal_header', 'description1') IS NOT NULL
BEGIN
	ALTER TABLE
	/**
        Columns
        description1 : Description Number 1
    */
	source_deal_header ALTER COLUMN description1 NVARCHAR(MAX)
END

IF COL_LENGTH('source_deal_header', 'description2') IS NOT NULL
BEGIN
	ALTER TABLE 
	/**
        Columns
        description2 : Description Number 2
    */
	source_deal_header ALTER COLUMN description2 NVARCHAR(MAX)
END

IF COL_LENGTH('source_deal_header', 'description3') IS NOT NULL
BEGIN
	ALTER TABLE
	/**
        Columns
        description3 : Description Number 3
    */
	source_deal_header ALTER COLUMN description3 NVARCHAR(MAX)
END

IF COL_LENGTH('source_deal_header', 'description4') IS NOT NULL
BEGIN
	ALTER TABLE 
	/**
        Columns
        description4 : Description Number 4
    */
	source_deal_header ALTER COLUMN description4 NVARCHAR(MAX)
END

IF COL_LENGTH('source_deal_header', 'aggregate_envrionment_comment') IS NOT NULL
BEGIN
	ALTER TABLE 
	/**
        Columns
        description4 : Aggregate Comments
    */
	source_deal_header ALTER COLUMN aggregate_envrionment_comment NVARCHAR(MAX)
END

GO