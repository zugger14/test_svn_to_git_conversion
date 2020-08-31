
IF OBJECT_ID(N'spa_run_wght_avg_inventory_cost_report', N'P') IS NOT NULL
DROP PROC [dbo].[spa_run_wght_avg_inventory_cost_report] 
GO
/****** Object:  StoredProcedure [dbo].[spa_run_wght_avg_inventory_cost_report]    Script Date: 10/07/2009 11:28:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec spa_run_wght_avg_inventory_cost_report 135, '5/31/2001', '6/30/2006'

CREATE PROCEDURE [dbo].[spa_run_wght_avg_inventory_cost_report] 
	@as_of_date_from DATETIME,
	@as_of_date_to DATETIME = NULL,
	@account_name VARCHAR(100) = NULL,
	@gl_code INT = NULL,
	@inventory_group_id INT = NULL,
	@report_option CHAR(1) = 'f',
	@drill_as_of_date VARCHAR(100) = NULL,
	@group_name VARCHAR(100) = NULL,
	@drill_account_name VARCHAR(100) = NULL,
	@drill_gl_name VARCHAR(100) = NULL,
	@drill_term VARCHAR(100) = NULL
AS
SET NOCOUNT ON

DECLARE @sql VARCHAR(8000)

if @as_of_date_from is not null and @as_of_date_to is null
	set @as_of_date_to = @as_of_date_from
if @as_of_date_from is null and @as_of_date_to is not null
	set @as_of_date_from = @as_of_date_to

declare @wght_avg_cost_group_by int



--DEFAULT WGHT AVG COST GROUPING APPROACH: 0 means jurisdiction-> 1 means by jurisdiction, state -> 2 means jurisdiction, state, technology



CREATE TABLE #ssbm(
		fas_book_id int,
		stra_book_id int,
		sub_entity_id int
	)
	----------------------------------
	SET @sql=
	'INSERT INTO #ssbm
	SELECT
		 book.entity_id fas_book_id,book.parent_entity_id stra_book_id, stra.parent_entity_id sub_entity_id 
	FROM
		source_system_book_map ssbm 
	INNER JOIN
		portfolio_hierarchy book (nolock) 
	ON	
		 ssbm.fas_book_id = book.entity_id 
	INNER JOIN
		Portfolio_hierarchy stra (nolock)
	 ON
		 book.parent_entity_id = stra.entity_id 

	WHERE 1=1 '

	EXEC(@sql)





CREATE TABLE #wacog(
	[Inventory Group] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[Inventory] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[GL Name] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[GL Code] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[Date] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[Term] VARCHAR(20) COLLATE DATABASE_DEFAULT,
	[Inventory Value] FLOAT,
	[Units] FLOAT,
	[Wght Avg Cost] FLOAT

)



	SET @sql=
		'
		INSERT INTO #wacog
		select 	
			iatg.group_name AS [Group],
			glact.account_type_name AS [Inventory],
			gsm.gl_account_name [GL Name],
			gsm.gl_account_number [GL Code],
			dbo.fnadateformat(wavg.as_of_date) [Date],
			'+ CASE WHEN @report_option ='f' THEN 'dbo.fnadateformat(wavg.term_date)' ELSE '''''' END +' AS [Term],
			wavg.total_inventory [Inventory Cost],
			wavg.total_units [Units],
			wavg.wght_avg_cost [Wght Avg Cost]
		FROM  
			inventory_account_type glact
			LEFT  JOIN '+ CASE WHEN @report_option ='f' THEN 'calcprocess_inventory_wght_avg_cost_forward' ELSE 'calcprocess_inventory_wght_avg_cost' END +' wavg on wavg.gl_account_id=glact.gl_account_id 
						--AND glact.assignment_gl_number_id IS NULL
					   AND 	wavg.inventory_account_name=glact.account_type_name
			LEFT JOIN static_data_value sdv on sdv.value_id=glact.account_type_value_id
			LEFT JOIN gl_system_mapping gsm on gsm.gl_number_id=glact.gl_number_id
			LEFT JOIN inventory_account_type_group iatg ON glact.group_id=iatg.group_id
		WHERE	1=1
		AND dbo.FNAGetContractMonth(as_of_date) between dbo.FNAGetContractMonth('''+CAST(@as_of_date_from AS VARCHAR(20))+''') and dbo.FNAGetContractMonth('''+CAST(@as_of_date_to AS VARCHAR(20))+''') '
		+CASE WHEN @account_name IS NOT NULL THEN ' AND glact.account_type_name='''+@account_name+'''' ELSE '' END
		+CASE WHEN @gl_code IS NOT NULL THEN ' AND glact.gl_number_id='+CAST(@gl_code AS VARCHAR) ELSE '' END
		+CASE WHEN @inventory_group_id IS NOT NULL THEN ' AND glact.group_id='+CAST(@inventory_group_id AS VARCHAR) ELSE '' END
		+'ORDER BY glact.account_type_name ,gsm.gl_account_name,wavg.as_of_date'
	
	--PRINT @sql
	EXEC(@sql)


IF @drill_account_name IS NULL
	BEGIN

		SELECT * FROM #wacog --ORDER BY [Date]
	
	END
ELSE 
	BEGIN
		
--	SELECT 
--		sdd.source_deal_header_id,	
--		cid.deal_date,
--		CASE WHEN cid.buy_sell_flag='b' THEN 1 ELSE -1 END *cid.deal_volume AS deal_volume,
--		CASE WHEN cid.buy_sell_flag='b' THEN cid.rec_fixed_price ELSE
--			CASE WHEN cid.rec_fixed_price<>0 THEN cid.rec_fixed_price
--				 ELSE wacog.[Wght Avg Cost] END END
--			AS Price
--	INTO
--		#temp_deals
--	FROM
--		calcprocess_inventory_deals cid
--		LEFT JOIN source_deal_detail sdd on sdd.source_deal_detail_id=cid.source_deal_header_id
--		INNER JOIN #wacog wacog ON wacog.[Date]=DATEADD(day,-1,@drill_term)  
--	WHERE 1=1	
--		--sub_entity_id in (select sub_entity_id from #ssbm)
--		AND deal_date=@drill_term
--		--AND cid.curve_id=CASE WHEN @drill_account_name like '%nox%' THEN 183 ELSE 1248 END

	
	SELECT 
		dbo.fnadateformat(DATEADD(day,-1,@drill_as_of_date)) AS [Day],
		'Carrying' AS [Deal/Transaction],
		[Units] AS [Volume],
		[Wght Avg Cost] AS [Cost],
		[Inventory Value] AS [Value]
	FROM
		#wacog
	WHERE 1=1
		-- AND [Date]=dbo.fnadateformat(DATEADD(day,-1,@drill_term))
		AND [Inventory]=@drill_account_name
	UNION
--	SELECT
--		CAST(dbo.fnadateformat(deal_date) AS VARCHAR),
--		dbo.FNAHyperLinkText(120, cast(source_deal_header_id as varchar),cast(source_deal_header_id as varchar)),
--		deal_volume,
--		Price,
--		deal_volume*Price
--	FROM
--		#temp_deals			

--	UNION
	
	SELECT 
		'Total' AS [Day],
		'' AS [Deal/Transaction],
		[Units] AS [Volume],
		[Wght Avg Cost] AS [Cost],
		[Inventory Value] AS [Value]
	FROM
		#wacog
		
	WHERE
		[Date]=dbo.fnadateformat(DATEADD(day,0,@drill_as_of_date))
		AND [Inventory]=@drill_account_name
	
	END











