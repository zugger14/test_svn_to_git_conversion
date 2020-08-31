--user_defined_deal_fields_audit
IF OBJECT_ID(N'cum_pnl_series_audit', N'U') IS NOT NULL 
BEGIN
	 PRINT 'Table cum_pnl_series_audit already exists.'
END
ELSE
BEGIN
    CREATE TABLE [dbo].[cum_pnl_series_audit](
		audit_id INT IDENTITY(1,1),
		cum_pnl_series_id INT,
		as_of_date DATETIME NOT NULL
		,link_id INT NOT NULL
		,u_h_mtm FLOAT NOT NULL
		,u_i_mtm FLOAT NOT NULL
		,d_h_mtm FLOAT NULL
		,d_i_mtm FLOAT NULL
		,comments VARCHAR(1000)  NULL
		,create_user VARCHAR(50) NULL
		,create_ts DATETIME NULL		
	)
	PRINT 'Table cum_pnl_series_audit created.'
END


