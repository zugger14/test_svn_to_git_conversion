
IF OBJECT_ID(N'dbo.optimizer_detail_hour', N'U') IS NULL 
BEGIN
    CREATE TABLE dbo.optimizer_detail_hour (

/**
	Contains hourly volume of optimizer detail

	Columns
	optimizer_detail_hour_id : Primary key 
	optimizer_header_id : Reference key of optimizer header table
	hr : hour
	period : sub hour (like 15 mins or 5 mins)
	flow_date : Flow Date 
	transport_deal_id : Transport Deal ID
	up_down_stream : Flag for up and down stream. U for up stream, D for down stream
	source_deal_header_id : Deal id of source deal
	source_deal_detail_id : deal detail id of source deal 
	deal_volume : Not in use
	volume_used : deal volume transferred
	create_user : specifies the username who creates the column
	create_ts : specifies the date when column was created
	update_user : specifies the username who updated the column
	update_ts : specifies the date when column was updated
	group_path_id : ID of group path
	single_path_id : ID of single path
	contract_id : ID of conntract
*/
		optimizer_detail_hour_id INT IDENTITY(1, 1) PRIMARY KEY
		, [optimizer_header_id] [int] NULL
		, hr INT
		, period INT
		, [flow_date] [datetime] NULL
		, [transport_deal_id] [int] NULL
		, [up_down_stream] [varchar](1) NULL
		, [source_deal_header_id] [int] NULL
		, [source_deal_detail_id] [int] NULL
		, [deal_volume] [numeric](38, 20) NULL
		, [volume_used] [numeric](38, 20) NULL
		, [create_user] [varchar](100) DEFAULT dbo.FNADBUser()
		, [create_ts] [datetime] DEFAULT GETDATE()
		, [update_user] [varchar](100) NULL
		, [update_ts] [datetime] NULL
		, [group_path_id] [int] NULL
		, [single_path_id] [int] NULL
		, [contract_id] [int] NULL
		, CONSTRAINT hourly_optimizer_detail_id FOREIGN KEY ([optimizer_header_id]) 
			REFERENCES optimizer_header(optimizer_header_id) 
			ON DELETE CASCADE	
		--, CONSTRAINT UniqueConstraintName UNIQUE(optimizer_header_id, transport_deal_id, flow_date, hr, period) --need to add up_down_stream, source_deal_header_id
		
    )
END
ELSE
BEGIN
    PRINT 'Table optimizer_detail_hour EXISTS'
END
 
GO
-- check if the trigger exists
IF  EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'dbo.TRGOptimizer_Detail_Hour'))
    DROP TRIGGER dbo.TRGOptimizer_Detail_Hour
GO

CREATE TRIGGER dbo.TRGOptimizer_Detail_Hour
ON dbo.optimizer_detail_hour
FOR UPDATE
AS
BEGIN
    --this check is required to prevent recursive trigger
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE optimizer_detail_hour
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM optimizer_detail_hour  TableAliasName
        INNER JOIN DELETED d ON d.optimizer_detail_hour_id =  TableAliasName.optimizer_detail_hour_id
    END
END
GO


