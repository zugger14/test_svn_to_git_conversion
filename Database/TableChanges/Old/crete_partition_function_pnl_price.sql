
IF NOT exists( select 1 FROM sys.partition_functions WHERE [NAME]='PF_PNL')
begin  
	CREATE PARTITION FUNCTION PF_PNL(datetime)
	AS RANGE LEFT FOR VALUES('2010-01-31','2010-02-28','2010-03-31','2010-04-30','2010-05-31','2010-06-30','2010-07-31','2010-08-31','2010-09-30','2010-10-31','2010-11-30','2010-12-31','2011-01-31','2011-02-28','2011-03-31','2011-04-30','2011-05-31','2011-06-30','2011-07-31','2011-08-31','2011-09-30','2011-10-31','2011-11-30','2011-12-31','2012-01-31','2012-02-29','2012-03-31','2012-04-30','2012-05-31','2012-06-30','2012-07-31','2012-08-31','2012-09-30','2012-10-31','2012-11-30','2012-12-31');

	CREATE PARTITION SCHEME PS_PNL AS PARTITION PF_PNL ALL TO ([PRIMARY]);

END

GO
IF NOT exists( select 1 FROM sys.partition_functions WHERE [NAME]='PF_PNL_DETAIL')
begin  
	CREATE PARTITION FUNCTION PF_PNL_DETAIL(datetime)
	AS RANGE LEFT FOR VALUES('2010-01-31','2010-02-28','2010-03-31','2010-04-30','2010-05-31','2010-06-30','2010-07-31','2010-08-31','2010-09-30','2010-10-31','2010-11-30','2010-12-31','2011-01-31','2011-02-28','2011-03-31','2011-04-30','2011-05-31','2011-06-30','2011-07-31','2011-08-31','2011-09-30','2011-10-31','2011-11-30','2011-12-31','2012-01-31','2012-02-29','2012-03-31','2012-04-30','2012-05-31','2012-06-30','2012-07-31','2012-08-31','2012-09-30','2012-10-31','2012-11-30','2012-12-31');

	CREATE PARTITION SCHEME PS_PNL_DETAIL AS PARTITION PF_PNL_DETAIL ALL TO ([PRIMARY]);

END

GO
IF NOT exists( select * FROM sys.partition_functions WHERE [NAME]='PF_PRICECURVE')
begin  
	CREATE PARTITION FUNCTION PF_PRICECURVE(datetime)
	AS RANGE LEFT FOR VALUES('2010-01-31','2010-02-28','2010-03-31','2010-04-30','2010-05-31','2010-06-30','2010-07-31','2010-08-31','2010-09-30','2010-10-31','2010-11-30','2010-12-31','2011-01-31','2011-02-28','2011-03-31','2011-04-30','2011-05-31','2011-06-30','2011-07-31','2011-08-31','2011-09-30','2011-10-31','2011-11-30','2011-12-31','2012-01-31','2012-02-29','2012-03-31','2012-04-30','2012-05-31','2012-06-30','2012-07-31','2012-08-31','2012-09-30','2012-10-31','2012-11-30','2012-12-31');

	CREATE PARTITION SCHEME PS_PRICECURVE AS PARTITION PF_PRICECURVE ALL TO ([PRIMARY]);
end
GO


IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_price_curve]') AND name = N'PK_source_price_curve')
ALTER TABLE [dbo].[source_price_curve] DROP CONSTRAINT [PK_source_price_curve]
GO


IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.source_price_curve') AND name = N'unq_cur_indx_source_price_curve')
BEGIN
	CREATE UNIQUE CLUSTERED INDEX unq_cur_indx_source_price_curve  on [dbo].[source_price_curve]
	(
		[source_curve_def_id] ASC,
		[as_of_date] ASC,
		[Assessment_curve_type_value_id] ASC,
		[curve_source_value_id] ASC,
		[maturity_date] ASC,
		[is_dst] ASC
	) on PS_PRICECURVE([as_of_date])
	
	PRINT 'Index unq_cur_indx_source_price_curve created.'
END
ELSE
BEGIN
	PRINT 'Index unq_cur_indx_source_price_curve already exists.'
END
GO


/****** Object:  Index [PK_source_deal_pnl]    Script Date: 07/13/2011 14:03:30 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_deal_pnl]') AND name = N'PK_source_deal_pnl')
ALTER TABLE [dbo].[source_deal_pnl] DROP CONSTRAINT [PK_source_deal_pnl]
GO



/****** Object:  Index [PK_source_deal_pnl]    Script Date: 07/13/2011 14:03:21 ******/
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.source_deal_pnl') AND name = N'unq_cur_indx_source_deal_pnl')
BEGIN
	CREATE UNIQUE CLUSTERED INDEX unq_cur_indx_source_deal_pnl ON source_deal_pnl
	(
		[source_deal_header_id] ASC,
		[term_start] ASC,
		[term_end] ASC,
		[Leg] ASC,
		[pnl_as_of_date] ASC,
		[pnl_source_value_id] ASC
	)  on PS_PNL([pnl_as_of_date])
	
	PRINT 'Index unq_cur_indx_source_deal_pnl created.'
END
ELSE
BEGIN
	PRINT 'Index unq_cur_indx_source_deal_pnl already exists.'
END
GO




/****** Object:  Index [PK_source_deal_pnl_detail]    Script Date: 07/13/2011 14:02:33 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_deal_pnl_detail]') AND name = N'PK_source_deal_pnl_detail')
ALTER TABLE [dbo].[source_deal_pnl_detail] DROP CONSTRAINT [PK_source_deal_pnl_detail]
GO


/****** Object:  Index [PK_source_deal_pnl]    Script Date: 07/13/2011 14:03:21 ******/
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.source_deal_pnl_detail') AND name = N'unq_cur_indx_source_deal_pnl_detail')
BEGIN
	--DROP  INDEX unq_cur_indx_source_deal_pnl_detail ON source_deal_pnl_detail
	CREATE UNIQUE CLUSTERED INDEX unq_cur_indx_source_deal_pnl_detail ON source_deal_pnl_detail
	(
		[source_deal_header_id] ASC,
		[term_start] ASC,
		[term_end] ASC,
		[Leg] ASC,
		[pnl_as_of_date] ASC,
		[pnl_source_value_id] ASC
	)  on PS_PNL_DETAIL ([pnl_as_of_date])
	
	PRINT 'Index unq_cur_indx_source_deal_pnl_detail created.'
END
ELSE
BEGIN
	PRINT 'Index unq_cur_indx_source_deal_pnl_detail already exists.'
END
GO

