IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pnl_explain_view]') AND type in (N'U'))
BEGIN
	PRINT 'pnl explain view is already created'
END
ELSE
BEGIN
	CREATE TABLE [dbo].[pnl_explain_view]
	(
	pnl_explain_view_id [int] IDENTITY(1,1) NOT NULL,
	source_deal_header_id	int,
	term_start	datetime,
	term_end	datetime             ,
	curve_id	int                  ,
	leg	int                          ,
	deal_status_id	int              ,
	begin_mtm	numeric(38,20)                ,
	new_mtm	numeric(38,20)                    ,
	modify_MTM	numeric(38,20)              ,
	deleted_mtm	numeric(38,20)                ,
	delivered_mtm	numeric(38,20)          ,
	price_changed_mtm	numeric(38,20)      ,
	end_mtm	numeric(38,20)                    ,
	begin_vol	numeric(38,20)                ,
	new_vol	numeric(38,20)                    ,
	modify_vol	numeric(38,20)              ,
	deleted_vol	numeric(38,20)                ,
	end_vol	numeric(38,20)                    ,
	delta_price	numeric(38,20)                ,
	delivered_vol	numeric(38,20)          ,
	price_to	numeric(38,20)                ,
	price_from	numeric(38,20)               ,
	pnl_currency_id	int              ,
	charge_type	int                  ,
	create_ts	VARCHAR(100)              ,
	unexplained_vol	numeric(38,20)          ,
	unexplained_mtm	numeric(38,20)          ,
	source_curve_def_id	int          ,
	source_uom_id	int              ,
	source_currency_id	int          ,
	as_of_date_from	datetime         ,
	as_of_date_to	datetime         ,
	filter_sub_id	VARCHAR(100)          ,
	filter_stra_id	VARCHAR(100)          ,
	filter_book_id	VARCHAR(100)          ,
	book_id	int                      ,
	Strategy_id	int                  ,
	Sub_id	int                      ,
	source_counterparty_id	int      ,
	reference_id	VARCHAR(100)          ,
	transaction_type_id	int          ,
	transaction_type_name	VARCHAR(100)  ,
	commodity_id	int              ,
	sub_book_id	int                  ,
	deal_sub_type	int               ,
	current_included BIT,
	total_change_mtm  numeric(38,20),
	total_change_vol  numeric(38,20),
	CONSTRAINT [PK_pnl_explain_view] PRIMARY KEY CLUSTERED 
	(
		[pnl_explain_view_id] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY]
END