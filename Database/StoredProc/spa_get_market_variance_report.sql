
/****** Object:  StoredProcedure [dbo].[spa_get_market_variance_report]    Script Date: 07/28/2009 17:58:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_market_variance_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_market_variance_report]
/****** Object:  StoredProcedure [dbo].[spa_get_market_variance_report]    Script Date: 07/28/2009 17:58:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec spa_get_market_variance_report '2009-05-01', '2009-04-26', '2009-04-26', '2', NULL, NULL, 'b', NULL, 'd', 0
--
--/*
-- EXEC spa_get_market_variance_report '2009-05-01', NULL, NULL, 2  
-- EXEC spa_get_market_variance_report '2009-05-01', NULL, NULL, 1  , NULL, NULL, 'b', NULL, 'h', 0
--*/
--

CREATE PROCEDURE [dbo].[spa_get_market_variance_report]
	@as_of_date VARCHAR(20),
	@term_start VARCHAR(20),
	@term_end VARCHAR(20),
	@charge_type INT,
	@hour_from INT = NULL,
	@hour_to INT = NULL,
	@load_plant VARCHAR(1) = 'b',
	@contract_id INT = NULL,
	@summary_detail VARCHAR(1) = 's',
	@threshold FLOAT = 0,
	@line_desc VARCHAR(200) = NULL
AS
SET NOCOUNT ON 	
--
--
--------------------To test uncomment this
/*
declare @as_of_date varchar(20) -- required
declare @term_start varchar(20) -- required
declare @term_end varchar(20) -- required
declare @charge_type int -- Required 1 for Trading amount, 2 for line rental
declare @hour_from int -- optional
declare @hour_to int -- optional
declare @contract_id  int -- optional all for default
declare @load_plant varchar(1) -- 'l' for load, 'p' for gen/plant and 'b' for both which is default
declare @summary_detail varchar(1) -- 's' summary default, 'd' for detail by day, 'h' for detail by hour
declare @threshold float -- default to 0 brings all 


set @as_of_date = '2009-05-01'
set @charge_type = 1
set @summary_detail = 'h'
set @term_start = '2009-04-26'
--set @load_plant = 'l'
drop table #calc
drop table #temp1
drop table #temp2
drop table #calc_formula_value
drop table #wesm_calc_formula_value
--select * from #wesm_calc_formula_value
*/
------------------end of test

if @term_start is null and @term_end is not null
	set @term_start = @term_end
if @term_end is null and @term_start is not null
	set @term_end = @term_start
if @hour_to is null and @hour_from is not null
	set @hour_to = @hour_from
if @hour_from is null and @hour_to is not null
	set @hour_from = @hour_to

if @line_desc IS NOT NULL
BEGIN

	If @line_desc = 'Energy Trading Amount'
		SET @charge_type = 1
	Else If @line_desc = 'Line Rental Trading Amount'
		SET @charge_type = 2
	Else
		SET @charge_type = 0
END
--select @line_desc, @charge_type


if @threshold is null
	set @threshold = 0


SELECT civv.calc_id,
       civv.as_of_date,
       --civv.recorderid,
       civv.counterparty_id,
       civv.generator_id,
       civv.contract_id,
       cg.contract_name,
       sc.counterparty_name
       INTO #calc
FROM   calc_invoice_volume_variance civv
       LEFT OUTER JOIN contract_group cg ON  cg.contract_id = civv.contract_id
       LEFT OUTER JOIN source_counterparty sc ON  sc.source_counterparty_id = civv.counterparty_id
       LEFT OUTER JOIN rec_generator rg ON  rg.generator_id = civv.generator_id
WHERE  as_of_date = @as_of_date
       AND ((@contract_id IS NOT NULL AND civv.contract_id = @contract_id) OR @contract_id IS NULL)

-- select * from #calc

DECLARE @where1 varchar(1000)
DECLARE @sql1 varchar(max)
DECLARE @sql2 varchar(max)

--Line Rental 
IF @charge_type = 2
BEGIN
	SET @where1 = ' cfv.invoice_line_item_id = 12570  ' +
			CASE WHEN (@term_start IS NOT NULL) THEN ' AND (cfv.prod_date BETWEEN ''' + @term_start + ''' AND ''' + @term_end + ''')' ELSE '' END +  
			CASE WHEN (@hour_from IS NOT NULL) THEN ' AND (cfv.hour BETWEEN ''' + CAST(@hour_from AS VARCHAR) + ''' AND ''' + CAST(@hour_to AS VARCHAR) + ''')' ELSE '' END

	CREATE TABLE #temp2(
		[Res Type] [varchar](100) COLLATE DATABASE_DEFAULT  NULL,
		[Node] [varchar](50) COLLATE DATABASE_DEFAULT  NULL,
		[Deal ID] [int] NULL,
		[Date] [varchar](20) COLLATE DATABASE_DEFAULT NULL,
		[Hour] [int] NULL,
		[Shadow BCQ] [float] NULL,
		[Invoice BCQ] [int] NULL,
		[Shadow EPP Injection] [float] NULL,
		[Invoice EPP Injection] [float] NULL,
		[Shadow EPP Withdrawal] [float] NULL,
		[Invoice EPP Withdrawal] [float] NULL,
		[Shadow Line Rental Fees] [float] NULL,
		[Invoice Line Rental Fees] [int] NULL,
		[Variance] [float] NULL,
		[Variance %] [int] NULL
	) 


	SET @sql1 = '
	insert into #temp2
	select	CASE	WHEN (CHARINDEX(''Load'', eapw.counterparty_name) > 0) Then ''LOAD''
					WHEN (CHARINDEX(''Gen'', eapw.counterparty_name) > 0) Then ''GEN''
					ELSE eapw.counterparty_name 
			END [Res Type],
			eapw.contract_name [Node],
			eapw.deal_detail_id [Deal ID],
			dbo.FNADateFormat(eapw.prod_date) [Date],
			eapw.hour [Hour],
			bcq.BCQ [Shadow BCQ],
			0 [Invoice BCQ],
			eap.[EPP Injection] [Shadow EPP Injection],
			eap.[EPP Injection] [Invoice EPP Injection],
			eapw.[EAP Withdrawal] [Shadow EPP Withdrawal],
			eapw.[EAP Withdrawal] [Invoice EPP Withdrawal],
			val.[Line Rental Fees] [Shadow Line Rental Fees],
			0 [Invoice Line Rental Fees],
			-1*val.[Line Rental Fees] [Variance],
			100 [Variance %]
	from 
	(select calc.calc_id, civd.deal_id deal_detail_id, calc.counterparty_name, calc.contract_name, cfv.prod_date, cfv.hour , cfv.[value] [EAP Withdrawal] 
	from calc_formula_value cfv INNER JOIN
		 calc_invoice_volume_detail civd ON civd.calc_id = cfv.calc_id and civd.prod_date = cfv.prod_date and civd.hour = cfv.hour and
				civd.invoice_line_item_id = cfv.invoice_line_item_id INNER JOIN
		 #calc calc ON	calc.calc_id = cfv.calc_id 
	where seq_number = 1 AND ' + @where1 + '
	) eapw INNER JOIN
	(select calc.calc_id, civd.deal_id deal_detail_id, calc.counterparty_name, calc.contract_name, cfv.prod_date, cfv.hour , cfv.[value] [EPP Injection] 
	from calc_formula_value cfv INNER JOIN
		 calc_invoice_volume_detail civd ON civd.calc_id = cfv.calc_id and civd.prod_date = cfv.prod_date and civd.hour = cfv.hour and
				civd.invoice_line_item_id = cfv.invoice_line_item_id INNER JOIN
		 #calc calc ON  calc.calc_id = cfv.calc_id 
	where seq_number = 2 AND ' + @where1 + '
	) eap ON eap.prod_date = eapw.prod_date AND eap.hour = eapw.hour AND eap.calc_id = eapw.calc_id INNER JOIN
	(select calc.calc_id, civd.deal_id deal_detail_id, calc.counterparty_name, calc.contract_name, cfv.prod_date, cfv.hour , cfv.[value] [BCQ] 
	from calc_formula_value cfv INNER JOIN
		 calc_invoice_volume_detail civd ON civd.calc_id = cfv.calc_id and civd.prod_date = cfv.prod_date and civd.hour = cfv.hour and
				civd.invoice_line_item_id = cfv.invoice_line_item_id INNER JOIN
		 #calc calc ON  calc.calc_id = cfv.calc_id 
	where seq_number = 3 AND ' + @where1 + '
	) bcq ON bcq.prod_date = eapw.prod_date AND bcq.hour = eapw.hour AND bcq.calc_id = eapw.calc_id INNER JOIN

	(select calc.calc_id, civd.deal_id deal_detail_id, calc.counterparty_name, calc.contract_name, cfv.prod_date, cfv.hour , cfv.[value] [Line Rental Fees] 
	from calc_formula_value cfv INNER JOIN		 
				calc_invoice_volume_detail civd ON civd.calc_id = cfv.calc_id and civd.prod_date = cfv.prod_date and civd.hour = cfv.hour and
				civd.invoice_line_item_id = cfv.invoice_line_item_id INNER JOIN
		 #calc calc ON  calc.calc_id = cfv.calc_id 
	where seq_number = 4 AND ' + @where1 + '
	) val ON val.prod_date = eapw.prod_date AND val.hour = eapw.hour AND val.calc_id = eapw.calc_id 

	'

	--print @sql1
	exec (@sql1)

	if @summary_detail = 'h'
	BEGIN
		set @sql2 = 'select * from #temp2 x  ' +
				' WHERE ' + CASE	WHEN (@load_plant = 'p') THEN ' x.[Res Type] = ''GEN'''
									WHEN (@load_plant = 'l') THEN ' x.[Res Type] = ''LOAD'''
									ELSE ' 1 = 1 '  END +
				CASE WHEN (ISNULL(@threshold, 0) <> 0) THEN ' AND ABS(x.[Variance %]) >= ' + CAST(@threshold as  VARCHAR) ELSE '' END +
				' ORDER BY x.[Res Type], x.[Node], cast(x.[Date] as DateTime), x.[Hour] '
		exec(@sql2)
	END
	ELSE IF @summary_detail = 'd'
	BEGIN
		set @sql2 = 'select [Res Type], [Node], sdd.source_deal_header_id [Deal ID], [Date], 
				sum([Shadow BCQ]) [Shadow BCQ],  sum([Invoice BCQ]) [Invoice BCQ],  ' +
				' sum([Shadow EPP Injection]) [Shadow EPP Injection],  sum([Invoice EPP Injection]) [Invoice EPP Injection],  ' +
				' sum([Shadow EPP Withdrawal]) [Shadow EPP Withdrawal],  sum([Invoice EPP Withdrawal]) [Invoice EPP Withdrawal],  ' +
				' sum([Shadow Line Rental Fees]) [Shadow Line Rental Fees],  sum([Invoice Line Rental Fees]) [Invoice Line Rental Fees], 
				  sum([Variance]) [Variance], ' +
				' 100 [Variance %] ' +
				' from #temp2 x  left outer join source_deal_detail sdd ON sdd.source_deal_detail_id = x.[Deal ID] ' +
				' WHERE ' + CASE	WHEN (@load_plant = 'p') THEN ' x.[Res Type] = ''GEN'''
									WHEN (@load_plant = 'l') THEN ' x.[Res Type] = ''LOAD'''
									ELSE ' 1 = 1 '  END +
				CASE WHEN (ISNULL(@threshold, 0) <> 0) THEN ' AND ABS(x.[Variance %]) >= ' + CAST(@threshold as  VARCHAR) ELSE '' END +
				' GROUP BY [Res Type], [Node], sdd.source_deal_header_id,[Date]' +
				' ORDER BY x.[Res Type], x.[Node], sdd.source_deal_header_id, cast(x.[Date] as DateTime)'

		--PRINT @sql2
		--select 1
		exec(@sql2)
		--select 2
		
	END
	ELSE
	BEGIN
		set @sql2 = 'select [Res Type], [Node], sum([Shadow BCQ]) [Shadow BCQ],  sum([Invoice BCQ]) [Invoice BCQ], ' +
				' sum([Shadow EPP Injection]*[Shadow BCQ])/sum([Shadow BCQ]) [Shadow EPP Injection],  
				  sum([Shadow EPP Injection]*[Shadow BCQ])/sum([Shadow BCQ]) [Invoice EPP Injection], ' +
				' sum([Shadow EPP Withdrawal]*[Shadow BCQ])/sum([Shadow BCQ]) [Shadow EPP Withdrawal],  
				  sum([Shadow EPP Withdrawal]*[Shadow BCQ])/sum([Shadow BCQ]) [Invoice EPP Withdrawal], ' +
				' sum([Shadow Line Rental Fees]) [Shadow Line Rental Fees],  sum([Invoice Line Rental Fees]) [Invoice Line Rental Fees], sum([Variance]) [Variance], ' +
				' 100 [Variance %] ' +
				' from #temp2 x  ' +
				' WHERE ' + CASE	WHEN (@load_plant = 'p') THEN ' x.[Res Type] = ''GEN'''
									WHEN (@load_plant = 'l') THEN ' x.[Res Type] = ''LOAD'''
									ELSE ' 1 = 1 '  END +
				CASE WHEN (ISNULL(@threshold, 0) <> 0) THEN ' AND ABS(x.[Variance %]) >= ' + CAST(@threshold as  VARCHAR) ELSE '' END +
				' GROUP BY [Res Type], [Node]' +
				' ORDER BY x.[Res Type], x.[Node]'

		--PRINT @sql2
		exec(@sql2)
		
	END
END
ELSE IF @charge_type = 1   --Trading Amount
BEGIN

SET @where1 = ' cfv.invoice_line_item_id = 12598  ' +
			CASE WHEN (@term_start IS NOT NULL) THEN ' AND (cfv.prod_date BETWEEN ''' + @term_start + ''' AND ''' + @term_end + ''')' ELSE '' END +  
			CASE WHEN (@hour_from IS NOT NULL) THEN ' AND (cfv.hour BETWEEN ''' + CAST(@hour_from AS VARCHAR) + ''' AND ''' + CAST(@hour_to AS VARCHAR) + ''')' ELSE '' END

CREATE TABLE #calc_formula_value(
	seq_number int,
	calc_id int, 
	counterparty_name varchar(500) COLLATE DATABASE_DEFAULT,
	contract_name varchar(500) COLLATE DATABASE_DEFAULT,
	prod_date datetime,
	hour int, 
	[value] float
	)	
	
	SET @sql1 = 
	'
	INSERT INTO #calc_formula_value
	select seq_number, calc.calc_id, calc.counterparty_name, calc.contract_name, cfv.prod_date, cfv.hour , cfv.[value] 
	from calc_formula_value cfv INNER JOIN
		 #calc calc ON	calc.calc_id = cfv.calc_id 
	where ' + @where1 + '
	'
	exec(@sql1)


CREATE TABLE #wesm_calc_formula_value(
	seq_number int,
	calc_id int, 
	counterparty_name varchar(500) COLLATE DATABASE_DEFAULT,
	contract_name varchar(500) COLLATE DATABASE_DEFAULT,
	prod_date datetime,
	hour int, 
	[value] float
	)	
	--wesm_calc_formula_value
	SET @sql1 = 
	'
	INSERT INTO #wesm_calc_formula_value
	select seq_number, calc.calc_id, calc.counterparty_name, calc.contract_name, cfv.prod_date, cfv.hour , cfv.[value] 
	from calc_formula_value cfv INNER JOIN
		 #calc calc ON	calc.calc_id = cfv.calc_id 
	where ' + @where1 + '
	'
	exec(@sql1)


CREATE TABLE #temp1(
	[Res Type] [varchar](100) COLLATE DATABASE_DEFAULT  NULL,
	[Node] [varchar](50) COLLATE DATABASE_DEFAULT  NULL,
	[Date] [varchar](50) COLLATE DATABASE_DEFAULT  NULL,
	[Hour] [int] NULL,
	[Shadow Initial Volume] [float] NULL,
	[Invoice Initial Volume] [float] NULL,
	[Shadow Target Volume] [float] NULL,
	[Invoice Target Volume] [float] NULL,
	[Shadow BCQ] [float] NULL,
	[Invoice BCQ] [float] NULL,
	[Shadow EAQSI/EAQSW] [float] NULL,
	[Invoice EAQSI/EAQSW] [float] NULL,
	[Shadow EAP (PHP)] [float] NULL,
	[Invoice EAP (PHP)] [float] NULL,
	[Shadow EAETA] [float] NULL,
	[Invoice EAETA] [float] NULL,
	[Variance EAETA] [float] NULL,
	[Variance% EAETA] [float] NOT NULL,
	[Shadow Raw MQ] [float] NULL,
	[Invoice Raw MQ] [float] NULL,
	[UOM] [varchar](3) COLLATE DATABASE_DEFAULT  NOT NULL,
	[Shadow SSLA%] [float] NULL,
	[Invoice SSLA%] [float] NULL,
	[Shadow Adj MQ] [float] NULL,
	[Invoice Adj MQ] [float] NULL,
	[Shadow Imbalance] [float] NULL,
	[Invoice Imbalance] [float] NULL,
	[Shadow EPP (PHP)] [float] NULL,
	[Invoice EPP (PHP)] [float] NULL,
	[Shadow EPETA] [float] NULL,
	[Invoice EPETA] [float] NULL,
	[Variance EPETA] [float] NULL,
	[Variance% EPETA] [float] NOT NULL,
	[Shadow ETA] [float] NULL,
	[Invoice ETA] [float] NULL,
	[Variance ETA] [float] NULL,
	[Variance% ETA] [float] NOT NULL
) ON [PRIMARY]

	SET @sql1 = '
	insert into #temp1
	select	CASE	WHEN (CHARINDEX(''Load'', iv.counterparty_name) > 0) Then ''LOAD''
					WHEN (CHARINDEX(''Gen'', iv.counterparty_name) > 0) Then ''GEN''
					ELSE iv.counterparty_name 
			END [Res Type],
			iv.contract_name [Node],
			dbo.FNADateFormat(iv.prod_date) [Date],
			iv.hour [Hour],
			iv.[value] [Shadow Initial Volume],
			iv_i.[value] [Invoice Initial Volume],
			tv.[value] [Shadow Target Volume],
			tv_i.[value] [Invoice Target Volume],
			bcq.[value] [Shadow BCQ],
			bcq_i.[value] [Invoice BCQ],
			eaq.[value] [Shadow EAQSI/EAQSW],
			eaq_i.[value] [Invoice EAQSI/EAQSW],
			eap.[value] [Shadow EAP (PHP)],
			eap_i.[value] [Invoice EAP (PHP)],
			eaeta.[value] [Shadow EAETA],
			eaeta_i.[value] [Invoice EAETA],
			eaeta_i.[value] - eaeta.[value] [Variance EAETA],
			round(isnull((eaeta_i.[value] - eaeta.[value])/nullif(eaeta.[value], 0),0) * 100, 2) [Variance% EAETA],
			rmq.[value] [Shadow Raw MQ],
			rmq_i.[value] [Invoice Raw MQ],
			''MWh'' [UOM],
			ssla.[value] [Shadow SSLA%],
			ssla_i.[value] [Invoice SSLA%],
			amq.[value] [Shadow Adj MQ],		
			amq_i.[value] [Invoice Adj MQ],		
			imb.[value] [Shadow Imbalance],
			imb_i.[value] [Invoice Imbalance],
			epp.[value] [Shadow EPP (PHP)],
			epp_i.[value] [Invoice EPP (PHP)],
			epeta.[value] [Shadow EPETA],
			epeta_i.[value] [Invoice EPETA],
			epeta_i.[value] - epeta.[value] [Variance EPETA],
			round(isnull((epeta_i.[value] - epeta.[value])/nullif(epeta.[value], 0), 0) * 100, 2) [Variance% EPETA],
			eta.[value] [Shadow ETA],
			eta_i.[value] [Invoice ETA],
			eta_i.[value] - eta.[value] [Variance ETA],
			round(isnull((eta_i.[value] - eta.[value])/nullif(eta.[value], 0), 0) * 100, 2) [Variance% ETA]

	from 
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #calc_formula_value 
	where seq_number = 1 
	) iv INNER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #calc_formula_value 
	where seq_number = 2 
	) tv ON iv.prod_date = tv.prod_date AND iv.hour = tv.hour AND iv.calc_id = tv.calc_id INNER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #calc_formula_value 
	where seq_number = 3 
	) bcq ON iv.prod_date = bcq.prod_date AND iv.hour = bcq.hour AND iv.calc_id = bcq.calc_id INNER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #calc_formula_value 
	where seq_number = 4 
	) eaq ON iv.prod_date = eaq.prod_date AND iv.hour = eaq.hour AND iv.calc_id = eaq.calc_id INNER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #calc_formula_value 
	where seq_number = 5 
	) eap ON iv.prod_date = eap.prod_date AND iv.hour = eap.hour AND iv.calc_id = eap.calc_id INNER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #calc_formula_value 
	where seq_number = 6 
	) eaeta ON iv.prod_date = eaeta.prod_date AND iv.hour = eaeta.hour AND iv.calc_id = eaeta.calc_id INNER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #calc_formula_value 
	where seq_number = 7 
	) rmq ON iv.prod_date = rmq.prod_date AND iv.hour = rmq.hour AND iv.calc_id = rmq.calc_id INNER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #calc_formula_value 
	where seq_number = 8 
	) ssla ON iv.prod_date = ssla.prod_date AND iv.hour = ssla.hour AND iv.calc_id = ssla.calc_id INNER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #calc_formula_value 
	where seq_number = 9 
	) amq ON iv.prod_date = amq.prod_date AND iv.hour = amq.hour AND iv.calc_id = amq.calc_id INNER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #calc_formula_value 
	where seq_number = 11 
	) imb ON iv.prod_date = imb.prod_date AND iv.hour = imb.hour AND iv.calc_id = imb.calc_id INNER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #calc_formula_value 
	where seq_number = 12 
	) epp ON iv.prod_date = epp.prod_date AND iv.hour = epp.hour AND iv.calc_id = epp.calc_id INNER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #calc_formula_value 
	where seq_number = 13 
	) epeta ON iv.prod_date = epeta.prod_date AND iv.hour = epeta.hour AND iv.calc_id = epeta.calc_id INNER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #calc_formula_value 
	where seq_number = 14 
	) eta ON iv.prod_date = eta.prod_date AND iv.hour = eta.hour AND iv.calc_id = eta.calc_id 
	'
	set @sql2 = '
	LEFT OUTER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #wesm_calc_formula_value cfv 
	where seq_number = 1 
	) iv_i ON iv.prod_date = iv_i.prod_date AND iv.hour = iv_i.hour AND iv.calc_id = iv_i.calc_id LEFT OUTER JOIN

	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #wesm_calc_formula_value cfv 
	where seq_number = 2 
	) tv_i ON iv.prod_date = tv_i.prod_date AND iv.hour = tv_i.hour AND iv.calc_id = tv_i.calc_id LEFT OUTER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #wesm_calc_formula_value cfv 
	where seq_number = 3 
	) bcq_i ON iv.prod_date = bcq_i.prod_date AND iv.hour = bcq_i.hour AND iv.calc_id = bcq_i.calc_id LEFT OUTER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #wesm_calc_formula_value cfv 
	where seq_number = 4 
	) eaq_i ON iv.prod_date = eaq_i.prod_date AND iv.hour = eaq_i.hour AND iv.calc_id = eaq_i.calc_id LEFT OUTER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #wesm_calc_formula_value cfv 
	where seq_number = 5 
	) eap_i ON iv.prod_date = eap_i.prod_date AND iv.hour = eap_i.hour AND iv.calc_id = eap_i.calc_id LEFT OUTER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #wesm_calc_formula_value cfv 
	where seq_number = 6 
	) eaeta_i ON iv.prod_date = eaeta_i.prod_date AND iv.hour = eaeta_i.hour AND iv.calc_id = eaeta_i.calc_id LEFT OUTER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #wesm_calc_formula_value cfv 
	where seq_number = 7 
	) rmq_i ON iv.prod_date = rmq_i.prod_date AND iv.hour = rmq_i.hour AND iv.calc_id = rmq_i.calc_id LEFT OUTER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #wesm_calc_formula_value cfv 
	where seq_number = 8 
	) ssla_i ON iv.prod_date = ssla_i.prod_date AND iv.hour = ssla_i.hour AND iv.calc_id = ssla_i.calc_id LEFT OUTER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #wesm_calc_formula_value cfv 
	where seq_number = 9 
	) amq_i ON iv.prod_date = amq_i.prod_date AND iv.hour = amq_i.hour AND iv.calc_id = amq_i.calc_id LEFT OUTER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #wesm_calc_formula_value cfv 
	where seq_number = 11 
	) imb_i ON iv.prod_date = imb_i.prod_date AND iv.hour = imb_i.hour AND iv.calc_id = imb_i.calc_id LEFT OUTER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #wesm_calc_formula_value cfv 
	where seq_number = 12 
	) epp_i ON iv.prod_date = epp_i.prod_date AND iv.hour = epp_i.hour AND iv.calc_id = epp_i.calc_id LEFT OUTER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #wesm_calc_formula_value cfv 
	where seq_number = 13 
	) epeta_i ON iv.prod_date = epeta_i.prod_date AND iv.hour = epeta_i.hour AND iv.calc_id = epeta_i.calc_id LEFT OUTER JOIN
	(select calc_id, counterparty_name, contract_name, prod_date, hour , [value] 
	from #wesm_calc_formula_value cfv 
	where seq_number = 14 
	) eta_i ON iv.prod_date = eta_i.prod_date AND iv.hour = eta_i.hour AND iv.calc_id = eta_i.calc_id 	

	'	
	
--	EXEC spa_print @sql1
--	EXEC spa_print @sql2
	exec(@sql1 + @sql2)

	--select 1	

	if @summary_detail = 'h'
	BEGIN
		set @sql2 = 'select * from #temp1 x  ' +
				' WHERE ' + CASE	WHEN (@load_plant = 'p') THEN ' x.[Res Type] = ''GEN'''
									WHEN (@load_plant = 'l') THEN ' x.[Res Type] = ''LOAD'''
									ELSE ' 1 = 1 '  END +
				CASE WHEN (ISNULL(@threshold, 0) <> 0) THEN ' AND (ABS(x.[Variance% EAETA]) >= ' + CAST(@threshold as  VARCHAR)  +
					' OR x.[Variance% EPETA] >= ' + CAST(@threshold as  VARCHAR) +
					' OR x.[Variance% ETA] >= ' + CAST(@threshold as  VARCHAR) + ') ' ELSE '' END +		
				' ORDER BY x.[Res Type], x.[Node], cast(x.[Date] as DateTime), x.[Hour] '
		exec(@sql2)
	END
	ELSE IF @summary_detail = 'd'
	BEGIN
		set @sql2 = 'select [Res Type], [Node], [Date], ' +
				'
				sum([Shadow Initial Volume]) [Shadow Initial Volume],
				sum([Invoice Initial Volume]) [Invoice Initial Volume],
				sum([Shadow Target Volume]) [Shadow Target Volume],
				sum([Invoice Target Volume]) [Invoice Target Volume],
				sum([Shadow BCQ]) [Shadow BCQ],
				sum([Invoice BCQ]) [Invoice BCQ],
				sum([Shadow EAQSI/EAQSW]) [Shadow EAQSI/EAQSW], 
				sum([Invoice EAQSI/EAQSW]) [Invoice EAQSI/EAQSW],
				sum([Shadow EAETA])/sum([Shadow EAQSI/EAQSW]) [Shadow EAP (PHP)],
				sum([Invoice EAETA])/sum([Invoice EAQSI/EAQSW]) [Invoice EAP (PHP)],
				sum([Shadow EAETA]) [Shadow EAETA],
				sum([Invoice EAETA]) [Invoice EAETA],
				sum([Variance EAETA]) [Variance EAETA], 
				round((sum([Invoice EAETA]) -  sum([Shadow EAETA]))/nullif(sum([Shadow EAETA]), 0) * 100, 2) [Variance% EAETA],
				sum([Shadow Raw MQ]) [Shadow Raw MQ],
				sum([Invoice Raw MQ]) [Invoice Raw MQ],
				max([UOM]) [UOM],
				sum([Shadow SSLA%]*[Shadow Adj MQ])/nullif(sum([Shadow Adj MQ]), 0) [Shadow SSLA%],
				sum([Invoice SSLA%]*[Invoice Adj MQ])/nullif(sum([Invoice Adj MQ]), 0) [Invoice SSLA%],
				sum([Shadow Adj MQ]) [Shadow Adj MQ],		
				sum([Invoice Adj MQ]) [Invoice Adj MQ],		
				sum([Shadow Imbalance]) [Shadow Imbalance], 
				sum([Invoice Imbalance]) [Invoice Imbalance],
				sum([Shadow EPETA])/sum([Shadow EAQSI/EAQSW]) [Shadow EPP (PHP)],
				sum([Invoice EPETA])/sum([Invoice EAQSI/EAQSW]) [Invoice EPP (PHP)],
				sum([Shadow EPETA]) [Shadow EPETA],
				sum([Invoice EPETA]) [Invoice EPETA],
				sum([Variance EPETA]) [Variance EPETA],
				round((sum([Invoice EPETA]) -  sum([Shadow EPETA]))/nullif(sum([Shadow EPETA]), 0) * 100, 2) [Variance% EPETA],
				sum([Shadow ETA]) [Shadow ETA],
				sum([Invoice ETA]) [Invoice ETA],
				sum([Variance ETA]) [Variance ETA],
				round((sum([Invoice ETA]) -  sum([Shadow ETA]))/nullif(sum([Shadow ETA]), 0) * 100, 2) [Variance% ETA]
				' +
				' from #temp1 x  ' +
				' WHERE ' + CASE	WHEN (@load_plant = 'p') THEN ' x.[Res Type] = ''GEN'''
									WHEN (@load_plant = 'l') THEN ' x.[Res Type] = ''LOAD'''
									ELSE ' 1 = 1 '  END +
				CASE WHEN (ISNULL(@threshold, 0) <> 0) THEN ' AND (ABS(x.[Variance% EAETA]) >= ' + CAST(@threshold as  VARCHAR)  +
					' OR x.[Variance% EPETA] >= ' + CAST(@threshold as  VARCHAR) +
					' OR x.[Variance% ETA] >= ' + CAST(@threshold as  VARCHAR) + ') ' ELSE '' END +	
				' GROUP BY [Res Type], [Node], [Date] ' +
				' ORDER BY x.[Res Type], x.[Node], cast(x.[Date] as DateTime)'

		EXEC spa_print @sql2
		exec(@sql2)
	END
	ELSE
	BEGIN
		set @sql2 = 'select [Res Type], [Node], ' +
				'
				sum([Shadow Initial Volume]) [Shadow Initial Volume],
				sum([Invoice Initial Volume]) [Invoice Initial Volume],
				sum([Shadow Target Volume]) [Shadow Target Volume],
				sum([Invoice Target Volume]) [Invoice Target Volume],
				sum([Shadow BCQ]) [Shadow BCQ],
				sum([Invoice BCQ]) [Invoice BCQ],
				sum([Shadow EAQSI/EAQSW]) [Shadow EAQSI/EAQSW], 
				sum([Invoice EAQSI/EAQSW]) [Invoice EAQSI/EAQSW],
				sum([Shadow EAETA])/sum([Shadow EAQSI/EAQSW]) [Shadow EAP (PHP)],
				sum([Invoice EAETA])/sum([Invoice EAQSI/EAQSW]) [Invoice EAP (PHP)],
				sum([Shadow EAETA]) [Shadow EAETA],
				sum([Invoice EAETA]) [Invoice EAETA],
				sum([Variance EAETA]) [Variance EAETA], 
				round((sum([Invoice EAETA]) -  sum([Shadow EAETA]))/nullif(sum([Shadow EAETA]), 0) * 100, 2) [Variance% EAETA],
				sum([Shadow Raw MQ]) [Shadow Raw MQ],
				sum([Invoice Raw MQ]) [Invoice Raw MQ],
				max([UOM]) [UOM],
				sum([Shadow SSLA%]*[Shadow Adj MQ])/nullif(sum([Shadow Adj MQ]), 0) [Shadow SSLA%],
				sum([Invoice SSLA%]*[Invoice Adj MQ])/nullif(sum([Invoice Adj MQ]), 0) [Invoice SSLA%],
				sum([Shadow Adj MQ]) [Shadow Adj MQ],		
				sum([Invoice Adj MQ]) [Invoice Adj MQ],		
				sum([Shadow Imbalance]) [Shadow Imbalance], 
				sum([Invoice Imbalance]) [Invoice Imbalance],
				sum([Shadow EPETA])/sum([Shadow EAQSI/EAQSW]) [Shadow EPP (PHP)],
				sum([Invoice EPETA])/sum([Invoice EAQSI/EAQSW]) [Invoice EPP (PHP)],
				sum([Shadow EPETA]) [Shadow EPETA],
				sum([Invoice EPETA]) [Invoice EPETA],
				sum([Variance EPETA]) [Variance EPETA],
				round((sum([Invoice EPETA]) -  sum([Shadow EPETA]))/nullif(sum([Shadow EPETA]), 0) * 100, 2) [Variance% EPETA],
				sum([Shadow ETA]) [Shadow ETA],
				sum([Invoice ETA]) [Invoice ETA],
				sum([Variance ETA]) [Variance ETA],
				round((sum([Invoice ETA]) -  sum([Shadow ETA]))/nullif(sum([Shadow ETA]), 0) * 100, 2) [Variance% ETA]
				' +
				' from #temp1 x  ' +
				' WHERE ' + CASE	WHEN (@load_plant = 'p') THEN ' x.[Res Type] = ''GEN'''
									WHEN (@load_plant = 'l') THEN ' x.[Res Type] = ''LOAD'''
									ELSE ' 1 = 1 '  END +
				CASE WHEN (ISNULL(@threshold, 0) <> 0) THEN ' AND (ABS(x.[Variance% EAETA]) >= ' + CAST(@threshold as  VARCHAR)  +
					' OR x.[Variance% EPETA] >= ' + CAST(@threshold as  VARCHAR) +
					' OR x.[Variance% ETA] >= ' + CAST(@threshold as  VARCHAR) + ') ' ELSE '' END +	
				' GROUP BY [Res Type], [Node] ' +
				' ORDER BY x.[Res Type], x.[Node]'


		--PRINT @sql2
		exec(@sql2)
		
	END


END
ELSE
	Select 'Unsupported charge type ' + isnull(@line_desc, '') + ' for variance analysis.'   [Message]






