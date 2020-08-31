IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_locked_values]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_locked_values]
 GO 

-- exec spa_get_locked_values 'r', '77', '2009-06-12', '2011-06-12', 111
-- select * from reclassify_aoci
---- This procedure is used to retrieve dedesignation values for dedesignation by choice 
---- and update to reclassify to dedesignation by not probable
-- To retrieve unprocessed values: pass 's' for flag and pass fas_book_id and date range
-- To reclassify values: pass 'u' for flag and pass link_id, book_deal_type_map_id and reclassify_date
-- To retrieve processed values: pass 'p' for flag and pass fas_book_id and date range
-- To delete processed values: pass 'd' for flag and pass fas_book_id and date range
-- To see detailed deals for a given link after retrieving on the grid pass 'r' for flag, link_id, ad book_deal_type_map_id
CREATE PROCEDURE [dbo].[spa_get_locked_values]
	@flag CHAR(1),
	@fas_book_id VARCHAR(MAX),
	@dedesignation_date_from VARCHAR(20) = NULL,
	@dedesignation_date_to VARCHAR(20) = NULL,
	@link_id INT = NULL,
	@book_deal_type_map_id INT = NULL,
	@reclassify_date VARCHAR(20) = NULL
AS
SET NOCOUNT ON	
---------------------UNCOMMENT BELOW TO TEST ------------------
--DECLARE	@flag char(1),	@fas_book_id int, @dedesignation_date_from varchar(20),
--		@dedesignation_date_to varchar(20), @link_id int, @book_deal_type_map_id int,
--		@reclassify_date varchar(20)
--SET @flag = 's' --'s'
--SET @fas_book_id = 77 --296 --225
--SET @dedesignation_date_from = '2009-06-01'
--SET @dedesignation_date_to = '2011-06-01'
--set @reclassify_date = '2011-04-30'
--set @link_id = 111--718 ---296
--set @book_deal_type_map_id = null  --467 --469
--
--drop table #dedesig_deals
--------------------END OF TEST --------------------------------

DECLARE @sql_stmt VARCHAR(5000)

IF @dedesignation_date_from is null and @dedesignation_date_to is not null
	SET @dedesignation_date_from = @dedesignation_date_to
IF @dedesignation_date_from is not null and @dedesignation_date_to is null
	SET @dedesignation_date_to = @dedesignation_date_from


SELECT	flh.link_id, flh.fas_book_id, fld.source_deal_header_id, flh.link_end_date dedesignation_date,
		NULL book_deal_type_map_id, flh.link_description
INTO #dedesig_deals
FROM fas_link_detail fld INNER JOIN
		fas_link_header flh ON flh.link_id = fld.link_id
INNER JOIN dbo.SplitCommaSeperatedValues(@fas_book_id) i ON i.item = flh.fas_book_id
WHERE	fld.hedge_or_item = 'h' and -- only derivatives
		flh.link_end_date BETWEEN isnull(@dedesignation_date_from, flh.link_end_date) AND isnull(@dedesignation_date_to, flh.link_end_date) 
UNION 
SELECT	-1* ssbm.fas_book_id, ssbm.fas_book_id, sdh.source_deal_header_id, ssbm.end_date dedesignation_date,
		ssbm.book_deal_type_map_id, ph.entity_name link_description 
FROM	fas_books fb INNER JOIN 
		source_system_book_map ssbm ON fb.fas_book_id = ssbm.fas_book_id INNER JOIN
		source_deal_header sdh ON ssbm.source_system_book_id1 = sdh.source_system_book_id1 AND 
        ssbm.source_system_book_id2 = sdh.source_system_book_id2 AND 
		ssbm.source_system_book_id3 = sdh.source_system_book_id3 AND 
		ssbm.source_system_book_id4 = sdh.source_system_book_id4 INNER JOIN
		portfolio_hierarchy ph ON ph.entity_id = fb.fas_book_id 
INNER JOIN dbo.SplitCommaSeperatedValues(@fas_book_id) i ON i.item = fb.fas_book_id
WHERE	isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id) = 400 and -- only derivatives 
		ssbm.end_date BETWEEN isnull(@dedesignation_date_from, ssbm.end_date) AND isnull(@dedesignation_date_to, ssbm.end_date) 

IF @flag = 'p'  -- prior processed
BEGIN

	SELECT	dbo.FNADateFormat(dd.dedesignation_date) DedesignationDate, 
			dbo.FNAHyperLinkText(10233710, rmv.link_id, rmv.link_id) RelID,
			dd.book_deal_type_map_id BookMapID, 
			dd.link_description [RelDesc],
			--round(sum(rmv.reclass_aoci_value), 2) LockedAOCI,
			dbo.FNADateFormat(rmv.reclassify_date) [Reclassify Date]
	FROM reclassify_aoci rmv inner join
	#dedesig_deals dd ON dd.source_deal_header_id = rmv.source_deal_header_id and
		dd.link_id = rmv.link_id 	
	GROUP BY dd.dedesignation_date, rmv.link_id, dd.book_deal_type_map_id, rmv.reclassify_date, dd.link_description
	ORDER BY dd.dedesignation_date, rmv.link_id, dd.book_deal_type_map_id, rmv.reclassify_date, dd.link_description

	If @@ERROR <> 0
	BEGIN
		EXEC spa_ErrorHandler @@ERROR, 'Transaction Processing', 
				'spa_get_locked_values', 'DB Error', 
				'Selection of prior reclassified values failed.', ''
		RETURN
	END
END
/*
if @flag = 't'  -- prior processed
BEGIN

	declare @t_as_of_date datetime
	select @t_as_of_date = min(as_of_date) from measurement_run_dates where as_of_date >= (select max(dedesignation_date) from #dedesig_deals)

	exec spa_Create_Hedges_Measurement_Report @t_as_of_date, NULL, NULL, NULL, 'u', 'f', 'c', 'd', @link_id,'2',NULL,'n',NULL,NULL

	
--	select	dbo.FNADateFormat(dd.dedesignation_date) DedesignationDate, 
--			dbo.FNAHyperLinkText(10233710, rmv.link_id, rmv.link_id) RelID,
--			dd.book_deal_type_map_id BookMapID, 
--			round(sum(rmv.reclass_aoci_value), 2) LockedAOCI,
--			dbo.FNADateFormat(rmv.reclassify_date) [Reclassify Date]
--	from reclassify_aoci rmv inner join
--	#dedesig_deals dd ON dd.source_deal_header_id = rmv.source_deal_header_id and
--		dd.link_id = rmv.link_id 
--	WHERE rmv.link_id = @link_id 	
--	group by dd.dedesignation_date, rmv.link_id, dd.book_deal_type_map_id, rmv.reclassify_date
--	order by dd.dedesignation_date, rmv.link_id, dd.book_deal_type_map_id, rmv.reclassify_date

	If @@ERROR <> 0
	BEGIN
		Exec spa_ErrorHandler @@ERROR, 'Transaction Processing', 
				'spa_get_locked_values', 'DB Error', 
				'Selection of prior reclassified values failed.', ''
		Return
	END
END
*/
if @flag = 'd'  -- prior processed
BEGIN

	DELETE reclassify_aoci 
	FROM reclassify_aoci ra inner join
	#dedesig_deals dd ON dd.source_deal_header_id = ra.source_deal_header_id and
		dd.link_id = ra.link_id 	
	WHERE ra.link_id = @link_id  and isnull(dd.book_deal_type_map_id, -1) = coalesce(NULLIF(@book_deal_type_map_id,''), dd.book_deal_type_map_id, -1)		

	If @@ERROR <> 0
	BEGIN
		EXEC spa_ErrorHandler @@ERROR, 'Transaction Processing', 
				'spa_get_locked_values', 'DB Error', 
				'Failed to delete prior reclassified values.', ''
		RETURN
	END
	ELSE
	BEGIN
		EXEC spa_ErrorHandler 0, 'Transaction Processing', 
				'spa_get_locked_values', 'Success', 
				'Prior reclassified values deleted.', ''
	END
	
END
ELSE If @flag = 's' 
BEGIN
	SELECT	dbo.FNADateFormat(dd.dedesignation_date) dedesignation_date ,
			dbo.FNADateFormat(ra.reclassify_date) reclassify_date,
			dd.book_deal_type_map_id,
			CASE WHEN dd.link_id< 1 THEN CAST(dd.link_id AS VARCHAR(20)) ELSE dbo.FNATRMWinHyperlink('a', 10233700, dd.link_id, ABS(dd.link_id),null,null,null,null,null,null,null,null,null,null,null,0) END AS  [Rel ID],
			dd.link_description,
			dd.fas_book_id
	FROM #dedesig_deals dd 
		LEFT JOIN reclassify_aoci ra ON ra.link_id = dd.link_id
		AND ra.source_deal_header_id = dd.source_deal_header_id
	WHERE 1 = 1
	ORDER BY dd.dedesignation_date, dd.link_id
END
ELSE IF @flag = 'u'
BEGIN

	INSERT INTO reclassify_aoci
	SELECT	@reclassify_date  reclassify_date,
			dd.link_id link_id, 
			dd.source_deal_header_id, 
			'1900-01-01' term_start,
			0 reclass_aoci_value, 
			dbo.FNADBUser() create_user, 
			getdate() create_ts
	FROM #dedesig_deals dd 
	WHERE dd.link_id = @link_id

--
--	insert into reclassify_aoci
--	select	@reclassify_date  reclassify_date,
--			cast(rmv.link_id as int) link_id,  
--			rmv.source_deal_header_id, 
--			rmv.term_start,
--			sum(rmv.u_aoci) reclass_aoci_value, 
--			dbo.FNADBUser() create_user, 
--			getdate() create_ts
--	from calcprocess_deals rmv inner join
--	#dedesig_deals dd ON dd.source_deal_header_id = rmv.source_deal_header_id and
--		dd.link_id = rmv.link_id inner join
--	(select dd.link_id, dd.book_deal_type_map_id, dd.dedesignation_date, min(rmv.as_of_date) as_of_date 
--	from (select distinct link_id,book_deal_type_map_id, dedesignation_date from #dedesig_deals) dd inner join report_measurement_values rmv ON
--	dd.link_id = rmv.link_id and rmv.as_of_date >= dd.dedesignation_date 
--	group by dd.link_id, dd.book_deal_type_map_id, dd.dedesignation_date) cdate on cdate.link_id = rmv.link_id and cdate.as_of_date = rmv.as_of_date
--	and isnull(dd.book_deal_type_map_id, -1) = isnull(cdate.book_deal_type_map_id, -1)
--	inner join source_currency sc on sc.source_currency_id = rmv.pnl_currency_id
--	where rmv.link_id = @link_id  and isnull(cdate.book_deal_type_map_id, -1) = coalesce(@book_deal_type_map_id, cdate.book_deal_type_map_id, -1)
--	group by rmv.link_id, rmv.source_deal_header_id, rmv.term_start
--	order by rmv.link_id, rmv.source_deal_header_id, rmv.term_start

	If @@ERROR <> 0
	BEGIN
		EXEC spa_ErrorHandler @@ERROR, 'Transaction Processing', 
				'spa_get_locked_values', 'DB Error', 
				'Failed to reclassify de-designation link.', ''
		RETURN
	END
	ELSE
	BEGIN
		EXEC spa_ErrorHandler 0, 'Transaction Processing', 
				'spa_get_locked_values', 'Success', 
				'De-designation successfully reclassified.', ''
	END
END
ELSE If @flag in  ('r' , 't')
BEGIN

	DECLARE @r_as_of_date DATETIME
	SELECT @r_as_of_date = MIN(as_of_date) FROM measurement_run_dates WHERE as_of_date >= (SELECT MAX(dedesignation_date) FROM #dedesig_deals)

	EXEC spa_Create_Hedges_Measurement_Report @r_as_of_date, NULL, NULL, NULL, 'u', 'f', 'c', 'd', @link_id,'2',NULL,'n',NULL,NULL


--	select	dbo.FNADateFormat(cdate.dedesignation_date) DedesignationDate, 
--			case when (rmv.link_id > 0) then dbo.FNAHyperLinkText(10233710, rmv.link_id, rmv.link_id) else cast(rmv.link_id as varchar) end RelID, 
--			--rmv.source_deal_header_id [Deal ID],
--			--max(rmv.deal_id) [Ref Deal ID],
--			--dbo.FNAGetContractMonth(rmv.term_start) [Contract Month], 
--			dd.book_deal_type_map_id BookMapID, 
--			dbo.FNADateFormat(cdate.as_of_date) CalcAsOfDate,
--			round(sum(rmv.u_aoci), 2) LockedAOCI, 
--			round(sum(rmv.u_pnl_ineffectiveness), 2) PNLIneff, 
--			max(sc.currency_name) Currency
--	from calcprocess_deals rmv inner join
--	#dedesig_deals dd ON dd.source_deal_header_id = rmv.source_deal_header_id and
--		dd.link_id = rmv.link_id inner join
--	(select dd.link_id, dd.book_deal_type_map_id, dd.dedesignation_date, min(rmv.as_of_date) as_of_date 
--	from (select distinct link_id,book_deal_type_map_id, dedesignation_date from #dedesig_deals) dd inner join report_measurement_values rmv ON
--	dd.link_id = rmv.link_id and rmv.as_of_date >= dd.dedesignation_date 
--	group by dd.link_id, dd.book_deal_type_map_id, dd.dedesignation_date) cdate on cdate.link_id = rmv.link_id and cdate.as_of_date = rmv.as_of_date
--	and isnull(dd.book_deal_type_map_id, -1) = isnull(cdate.book_deal_type_map_id, -1)
--	inner join source_currency sc on sc.source_currency_id = rmv.pnl_currency_id	
--	where rmv.link_id = @link_id  and isnull(cdate.book_deal_type_map_id, -1) = coalesce(@book_deal_type_map_id, cdate.book_deal_type_map_id, -1)
--	group by cdate.dedesignation_date, rmv.link_id, rmv.source_deal_header_id, rmv.term_start, dd.book_deal_type_map_id, cdate.as_of_date
--	order by cdate.dedesignation_date, rmv.link_id, rmv.source_deal_header_id, rmv.term_start, dd.book_deal_type_map_id, cdate.as_of_date
--
		IF @@ERROR <> 0
		BEGIN
			EXEC spa_ErrorHandler @@ERROR, 
				'Transaction Processing', 
				'spa_get_locked_values', 
				'DB Error', 
				'Selection of dedesignation values failed.', 
				''
			RETURN
		END
END

