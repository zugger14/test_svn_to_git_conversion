

IF OBJECT_ID(N'spa_genhedgegroup', N'P') IS NOT NULL
DROP PROCEDURE spa_genhedgegroup
 GO 
--[spa_genhedgegroup]'a',927



-- EXEC spa_genhedgegroup 'i', NULL, 'Hedged Item Repricing', '2003-01-03', 450, 4, 'n', 64, '2004-06-01', '2004-08-01'
-- EXEC spa_genhedgegroup 's'
-- EXEC spa_genhedgegroup 'a', 369
--This proc will be used to perform select, insert, update and delete record
--from the gen_hedge_group table
--The fisrt parameter or flag to pass: select = 's', for Insert='i'. Update='u' and Delete='d'
--For insert and update, pass all the parameters defined for this stored procedure

-- drop proc spa_genhedgegroup 

create PROCEDURE [dbo].[spa_genhedgegroup] 
@flag char(1) = NULL,
@gen_hedge_group_id VARCHAR(max) = NULL,
@gen_hedge_group_name varchar(100) = NULL,
@hedge_effective_date DATETIME = NULL,
@link_type_value_id INT = NULL,
@eff_test_profile_id INT = NULL,
@perfect_hedge char(1) = NULL,
@link_id int = NULL,
@tenor_from varchar(10) = NULL,
@tenor_to varchar(10) = NULL,
@reprice_date varchar(10) =  NULL,
@grid_xml		VARCHAR(MAX) = NULL

AS
SET NOCOUNT ON

	IF @flag='s' AND @gen_hedge_group_id IS NULL
BEGIN
	SELECT ghg.gen_hedge_group_id AS GenGroupID, 
		ghg.gen_hedge_group_name AS GenGroupName, 
		fhrt.eff_test_name AS RelType, 
        dbo.FNADateFormat(ghg.hedge_effective_date) AS EffDate, 
		sdv.code,
	--	dbo.FNATRMWinHyperlink('a', 10231900, sdv.code, sdv.code,null,null,null,null,null,null,null,null,null,null,null,0) AS [RelTypeID],
		CASE WHEN ghg.perfect_hedge = 'y' THEN 'Yes' ELSE 'No' END AS perfect_hedge
	FROM gen_hedge_group ghg
	INNER JOIN fas_eff_hedge_rel_type fhrt ON fhrt.eff_test_profile_id = ghg.eff_test_profile_id
	INNER JOIN static_data_value sdv ON sdv.value_id = ghg.link_type_value_id AND type_id = 450			
	WHERE ghg.reprice_items_id IS  NULL  
		AND ghg.gen_hedge_group_id NOT IN (SELECT gen_hedge_group_id FROM gen_fas_link_header)			
			
END
ELSE IF @flag='s' and @gen_hedge_group_id IS NOT NULL
BEGIN
	select gen_hedge_group.gen_hedge_group_id AS GenGroupID, 
		gen_hedge_group.gen_hedge_group_name AS GenGroupName, 
		gen_hedge_group.link_type_value_id AS RelTypeID, 
        dbo.FNADateFormat(gen_hedge_group.hedge_effective_date) AS EffDate, 
		gen_hedge_group.eff_test_profile_id AS RelType, 
		gen_hedge_group.perfect_hedge AS PerfectHedge, 
		gen_hedge_group.create_user AS CreatedUser, 
        dbo.FNADateTimeFormat(gen_hedge_group.create_ts,2) AS CreatedTS, 
		gen_hedge_group.update_user AS UpdateUser, 
		dbo.FNADateTimeFormat(gen_hedge_group.update_ts,2) AS UpdateTS 
    FROM gen_hedge_group  
	INNER JOIN dbo.SplitCommaSeperatedValues(@gen_hedge_group_id) csv ON gen_hedge_group.gen_hedge_group_id = csv.Item
	WHERE gen_hedge_group.gen_hedge_group_id NOT IN (SELECT gen_hedge_group_id FROM gen_fas_link_header)
		
IF @@ERROR<> 0 
BEGIN
	EXEc spa_ErrorHandler @@ERROR, 
		'Hedge Group', 
		'spa_genhedgegroup', 
		'DB Error', 
		'Failed to select hedge group.', 
		''
END
ELSE
BEGIN
	EXEC spa_ErrorHandler 0, 
		'Hedge Group', 
		'spa_genhedgegroup',
		'Success', 
		'hedge group successfully selected',
		''
END
END
ELSE If @flag='a'
begin
	SELECT [gen_hedge_group_id],
	       a.[gen_hedge_group_name],
	       a.[link_type_value_id],
	       dbo.FNAUserDateFormat(a.[hedge_effective_date], dbo.FNADBUser()) 
	       [hedge_effective_date],
	       a.[eff_test_profile_id],
	       a.[perfect_hedge],
	       a.[reprice_items_id],
	       a.[tenor_from],
	       a.[tenor_to],
	       a.[reprice_date],
	       a.[create_user],
	       a.[create_ts],
	       a.[update_user],
	       a.[update_ts],
	       a.[tran_type],
	       b.eff_test_name,
	       b.fas_book_id
	FROM   [gen_hedge_group] a
	       LEFT JOIN fas_eff_hedge_rel_type b
	            ON  a.[eff_test_profile_id] = b.eff_test_profile_id
	INNER JOIN dbo.SplitCommaSeperatedValues(@gen_hedge_group_id) csv
		ON a.gen_hedge_group_id = csv.Item

end
	else if @flag='i'
		begin
		DECLARE @idoc INT
		--<GridGroup><PSRecordset  hedging_relationship_type='19'  effective_date='02/07/2012'  perfect_hedge='n'  source_deal_header_id='15067'  ></PSRecordset> <PSRecordset  hedging_relationship_type='33'  effective_date='02/07/2012'  perfect_hedge='y'  source_deal_header_id='15066'  ></PSRecordset> </GridGroup>
		
		IF OBJECT_ID(N'tempdb..#collect_xml_data') IS NOT NULL DROP TABLE #collect_xml_data
	
		EXEC sp_xml_preparedocument @idoc OUTPUT, @grid_xml		
		
		SELECT hedging_relationship_type
			, [dbo].[FNAClientToSqlDate](effective_date) effective_date
			, ISNULL(NULLIF(perfect_hedge, ''), 'n') perfect_hedge
			, source_deal_header_id
		INTO #collect_xml_data
		FROM   OPENXML(@idoc, '/GridGroup/PSRecordset', 1)
				WITH (
					hedging_relationship_type INT '@hedging_relationship_type',
				effective_date VARCHAR(30) '@effective_date',
					perfect_hedge CHAR(1) '@perfect_hedge',
				source_deal_header_id INT '@source_deal_header_id'
				)
			
		--SELECT sdh.deal_id, * FROM #collect_xml_data cxd
		--INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = cxd.source_deal_header_id
		
		--450	Hedge Designation
		/* TODO While calling from automation of forcasted transaction @link_id, @tenor_from, @tenor_to, @reprice_date values not set.
			If needed then have to collect those data and process as xml data.
		*/

		BEGIN TRY
			BEGIN TRAN	
			IF OBJECT_ID(N'tempdb..#inserted_hedge_group') IS NOT NULL DROP TABLE #inserted_hedge_group
			
			CREATE TABLE #inserted_hedge_group(
				gen_hedge_group_id			INT, 
				effective_date				DATETIME, 
				hedging_relationship_type	INT,
				perfect_hedge				CHAR(1) COLLATE DATABASE_DEFAULT 
			)
			
			INSERT INTO gen_hedge_group(gen_hedge_group_name
				, link_type_value_id
				, hedge_effective_date
				, eff_test_profile_id
				, perfect_hedge)
			OUTPUT INSERTED.gen_hedge_group_id, INSERTED.hedge_effective_date, INSERTED.eff_test_profile_id, INSERTED.perfect_hedge
			INTO #inserted_hedge_group 
			SELECT 'hedge_group_deal:' + MAX(rs_inner.hedge_group_name)
					, 450
					, rs_main.effective_date
					, rs_main.hedging_relationship_type
					, rs_main.perfect_hedge				
			FROM #collect_xml_data rs_main
			OUTER APPLY (SELECT STUFF((
							SELECT ','+ CAST(sdh.source_deal_header_id  AS VARCHAR) + '(' +  MAX(sdh.deal_id) + ')' 
							FROM #collect_xml_data cxd
							INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = cxd.source_deal_header_id 
								AND cxd.hedging_relationship_type = rs_main.hedging_relationship_type
								AND cxd.effective_date = rs_main.effective_date
								AND cxd.perfect_hedge = rs_main.perfect_hedge
							GROUP BY  sdh.source_deal_header_id  
							FOR XML PATH ('')
						  ), 1, 1, '') hedge_group_name
						  ) rs_inner
			GROUP BY rs_main.hedging_relationship_type
					, rs_main.effective_date
					, rs_main.perfect_hedge
			
			-- Insert into detail table
			INSERT INTO gen_hedge_group_detail (gen_hedge_group_id,source_deal_header_id,percentage_use)
			SELECT hed_group.gen_hedge_group_id, cxd.source_deal_header_id, 1 
			FROM #inserted_hedge_group hed_group
			INNER JOIN #collect_xml_data cxd ON cxd.hedging_relationship_type = hed_group.hedging_relationship_type
				AND cxd.effective_date = hed_group.effective_date
				AND cxd.perfect_hedge = hed_group.perfect_hedge
				
			
				--insert into gen_hedge_group(gen_hedge_group_name, 
				--	link_type_value_id, hedge_effective_date, eff_test_profile_id,
				--	perfect_hedge, reprice_items_id,tenor_from, tenor_to, reprice_date) 
				--values(@gen_hedge_group_name, @link_type_value_id, 
				--	@hedge_effective_date, @eff_test_profile_id, @perfect_hedge,
				--	@link_id, @tenor_from, @tenor_to, @reprice_date)
			
			
		
			--This is  for repricing of hedged items
			DECLARE @new_id varchar(100)
			SET @new_id = CAST(SCOPE_IDENTITY() AS VARCHAR)
			--insert logic is changed in this logic so have to change @new_id logic.
			
			If @link_id IS NOT NULL
			BEGIN
				INSERT INTO gen_hedge_group_detail(gen_hedge_group_id, source_deal_header_id, percentage_use)
				SELECT DISTINCT @new_id, source_deal_header_id, percentage_included FROM fas_link_detail(NOLOCK)
				WHERE link_id = @link_id 
				AND hedge_or_item = CASE WHEN (@perfect_hedge = 'n') THEN 'i' ELSE 'h' END AND percentage_included <> 0
			END				

			Exec spa_ErrorHandler 0, 'Hedge Group', 
				'spa_genhedgegroup', 'Success' , 
				'Hedge Group added successfully.', ''

		
			COMMIT
		END TRY
		BEGIN CATCH
			ROLLBACK
			Exec spa_ErrorHandler @@ERROR, 'Hedge Group', 
					'spa_genhedgegroup', 'DB Error', 
					'Failed to add hedge group.',''
		END CATCH
	END

	ELSE IF @flag='m' -- it is used in matching while editing relationshiptype updated
			BEGIN
				UPDATE ghg 
				SET gen_hedge_group_name = @gen_hedge_group_name,
					eff_test_profile_id = @eff_test_profile_id
					--where gen_hedge_group_id=@gen_hedge_group_id
				FROM gen_hedge_group ghg
				INNER JOIN dbo.SplitCommaSeperatedValues(@gen_hedge_group_id) csv
					ON ghg.gen_hedge_group_id = csv.Item
				

				--select * from gen_fas_link_header
				--select * from gen_hedge_group
				update gen_fas_link_header SET fas_book_id=rtype.fas_book_id,eff_test_profile_id=@eff_test_profile_id
						FROM	gen_fas_link_header INNER JOIN
						gen_hedge_group ON gen_hedge_group.gen_hedge_group_id = gen_fas_link_header.gen_hedge_group_id
						inner join fas_eff_hedge_rel_type rtype on gen_hedge_group.eff_test_profile_id=rtype.eff_test_profile_id
			IF @@ERROR<> 0 
				BEGIN
					Exec spa_ErrorHandler @@ERROR, 'Hedge Group', 
						'spa_genhedgegroup', 'DB Error', 
						'Failed to update hedge group',''
				END
			ELSE
				BEGIN
					Exec spa_ErrorHandler 0, 'Hedge Group', 
						'spa_genhedgegroup','Success', 
						' hedge group updated successfully ', ''
		
				END
			END

	ELSE IF @flag='u'
			BEGIN
				UPDATE ghg 
				SET gen_hedge_group_name =@gen_hedge_group_name,
					link_type_value_id = @link_type_value_id,
					hedge_effective_date = @hedge_effective_date
				FROM gen_hedge_group ghg
				INNER JOIN dbo.SplitCommaSeperatedValues(@gen_hedge_group_id) csv
					ON csv.Item = ghg.gen_hedge_group_id 
				--where gen_hedge_group_id=@gen_hedge_group_id
			
	
			IF @@ERROR<> 0 
				BEGIN
					Exec spa_ErrorHandler @@ERROR, 'Hedge Group', 
						'spa_genhedgegroup', 'DB Error', 
						'Failed to update hedge group',''
				END
			ELSE
				BEGIN
					Exec spa_ErrorHandler 0, 'Hedge Group', 
						'spa_genhedgegroup','Success', 
						' hedge group updated successfully ', ''
		
				END
			END

	ELSE IF @flag='d'
				BEGIN
					BEGIN TRANSACTION
						
					if @@ERROR = 0 
					BEGIN
						--delete from gen_deal_detail
						DELETE gen_deal_detail
	--					select * from gen_deal_detail
						WHERE gen_deal_detail.gen_deal_header_id in (
						SELECT     gen_fas_link_detail.deal_number
						FROM       gen_fas_link_header INNER JOIN
						           gen_fas_link_detail ON gen_fas_link_header.gen_link_id = gen_fas_link_detail.gen_link_id 
-- 							INNER JOIN
-- 						           gen_hedge_group ON gen_fas_link_header.gen_hedge_group_id = gen_hedge_group.gen_hedge_group_id
							INNER JOIN dbo.[SplitCommaSeperatedValues](@gen_hedge_group_id) ghgi ON ghgi.item = gen_fas_link_header.gen_hedge_group_id
						WHERE gen_fas_link_detail.hedge_or_item = 'i' )
-- 							AND 
-- 							gen_fas_link_header.gen_approved = 'n')

						if @@ERROR = 0 
						BEGIN

							DELETE gen_deal_header
		--					SELECT * FROM gen_deal_header
							WHERE gen_deal_header.gen_deal_header_id in (
							SELECT     gen_fas_link_detail.deal_number
							FROM       gen_fas_link_header INNER JOIN
							           gen_fas_link_detail ON gen_fas_link_header.gen_link_id = gen_fas_link_detail.gen_link_id 
-- 								INNER JOIN
-- 							           gen_hedge_group ON gen_fas_link_header.gen_hedge_group_id = gen_hedge_group.gen_hedge_group_id
							INNER JOIN dbo.[SplitCommaSeperatedValues](@gen_hedge_group_id) ghgi ON ghgi.item = gen_fas_link_header.gen_hedge_group_id
							WHERE gen_fas_link_detail.hedge_or_item = 'i' )
-- 								AND 
-- 								gen_fas_link_header.gen_approved = 'n')

							if @@ERROR = 0 
							BEGIN
			------- add by gyan ----------------------------------
								select source_deal_header_id into #source_deal from source_deal_header inner join gen_fas_link_detail on source_deal_header.source_deal_header_id=gen_fas_link_detail.deal_number
								 INNER JOIN gen_fas_link_header ON gen_fas_link_header.gen_link_id = gen_fas_link_detail.gen_link_id
								 INNER JOIN dbo.[SplitCommaSeperatedValues](@gen_hedge_group_id) ghgi ON ghgi.item = gen_fas_link_header.gen_hedge_group_id
								WHERE source_deal_header.deal_id like '%_off%'
--------------------------------------------------------------------------------------------------------
								-- DELETE FROM gen_fas_link_detail
								DELETE gen_fas_link_detail 
			--					SELECT * FROM gen_fas_link_detail 
								WHERE gen_fas_link_detail.deal_number in (
								SELECT     gen_fas_link_detail.deal_number
								FROM       gen_fas_link_header INNER JOIN
								           gen_fas_link_detail ON gen_fas_link_header.gen_link_id = gen_fas_link_detail.gen_link_id 
-- 									INNER JOIN
-- 								           gen_hedge_group ON gen_fas_link_header.gen_hedge_group_id = gen_hedge_group.gen_hedge_group_id
								INNER JOIN dbo.[SplitCommaSeperatedValues](@gen_hedge_group_id) ghgi ON ghgi.item = gen_fas_link_header.gen_hedge_group_id
								 )
-- 									AND 
-- 									gen_fas_link_header.gen_approved = 'n')
	
								if @@ERROR = 0 
								BEGIN
									-- add by mrigess
									DELETE fas_link_detail_dicing
									WHERE link_id IN (
										SELECT gflh.gen_link_id FROM gen_fas_link_header gflh
										INNER JOIN dbo.[SplitCommaSeperatedValues](@gen_hedge_group_id) ghgi ON ghgi.item = gflh.gen_hedge_group_id
									)
									
									DELETE gen_fas_link_detail_dicing
									WHERE link_id IN (
										SELECT gflh.gen_link_id FROM gen_fas_link_header gflh
										INNER JOIN dbo.[SplitCommaSeperatedValues](@gen_hedge_group_id) ghgi ON ghgi.item = gflh.gen_hedge_group_id
									)
									
									
									                                  -- delete gen_fas_link_header
									DELETE gen_fas_link_header
									FROM gen_fas_link_header
									INNER JOIN dbo.[SplitCommaSeperatedValues](@gen_hedge_group_id) ghgi ON ghgi.item = gen_fas_link_header.gen_hedge_group_id 
										--and gen_fas_link_header.gen_approved = 'n'

									if @@ERROR = 0 
									BEGIN
	---------------------------------- added by gyan
										if exists(select * from #source_deal) -- deleting offset deals that are created for matching
										begin
											delete source_deal_detail from source_deal_detail inner join #source_deal on source_deal_detail.source_deal_header_id=#source_deal.source_deal_header_id
											delete source_deal_header from source_deal_header inner join #source_deal on source_deal_header.source_deal_header_id=#source_deal.source_deal_header_id
										end
----------------------------------------------------------------------------------------
										delete gen_hedge_group_detail 
										FROM gen_hedge_group_detail
										INNER JOIN dbo.[SplitCommaSeperatedValues](@gen_hedge_group_id) ghgi ON ghgi.item = gen_hedge_group_detail.gen_hedge_group_id

										delete gen_hedge_group
										FROM gen_hedge_group  
										INNER JOIN dbo.[SplitCommaSeperatedValues](@gen_hedge_group_id) ghgi ON ghgi.item = gen_hedge_group.gen_hedge_group_id
										
										if @@ERROR = 0 
										BEGIN
				
											Exec spa_ErrorHandler 0, 'Hedge Group', 
												'spa_genhedgegroup', 'Success', 
												' Hedge group deleted successfully. ', ''

											COMMIT 
											Return
										
										END
										ELSE
										BEGIN
											Exec spa_ErrorHandler @@ERROR, 'Hedge Group', 
												'spa_genhedgegroup','DB Error', 
												'Failed to delete gen hedge group',''
											ROLLBACK
											Return
										END

									END
									ELSE
									BEGIN
										Exec spa_ErrorHandler @@ERROR, 'Hedge Group', 
											'spa_genhedgegroup','DB Error', 
											'Failed to delete gen_fas_link_header while deleting hedge group',''
										ROLLBACK
										Return
									END
		
								END
								ELSE
								BEGIN
										Exec spa_ErrorHandler @@ERROR, 'Hedge Group', 
											'spa_genhedgegroup','DB Error', 
											'Failed to delete gen_fas_link_detail while deleting hedge group',''
										ROLLBACK
										Return
								END

							END
							ELSE
							BEGIN
										Exec spa_ErrorHandler @@ERROR, 'Hedge Group', 
											'spa_genhedgegroup','DB Error', 
											'Failed to delete gen_deal_header while deleting hedge group',''
										ROLLBACK
										Return
							END
						END
						ELSE
						BEGIN
										Exec spa_ErrorHandler @@ERROR, 'Hedge Group', 
											'spa_genhedgegroup','DB Error', 
											'Failed to delete gen_deal_detail while deleting hedge group',''
										ROLLBACK
										Return
						END

					END	
					ELSE
					BEGIN
								Exec spa_ErrorHandler @@ERROR, 'Hedge Group Detail', 
									'spa_genhedgegroup', 'DB Error', 
									'Fail to delete hedge group detail', ''
								ROLLBACK 
								Return
					END
				
				END
	ELSE IF @flag = 'e'
	BEGIN
		
		DECLARE @sql_stmt VARCHAR(max)
		BEGIN TRANSACTION
		BEGIN TRY
			SET @sql_stmt = 'UPDATE gen_fas_link_header 
						SET gen_approved = ''n'' 
		                 WHERE gen_hedge_group_id in (' + @gen_hedge_group_id + ')'
		    EXEC spa_print @sql_stmt
			EXEC (@sql_stmt)
		    EXEC spa_ErrorHandler 0, 'Hedge Group', 'spa_genhedgegroup', 'Success', ' Data From hedge group deleted successfully ', ''
		    COMMIT
		    RETURN
		END TRY
		BEGIN CATCH
			EXEC spa_ErrorHandler @@ERROR, 'Hedge Group', 'spa_genhedgegroup','DB Error', 'Failed to delete gen hedge group',''
			ROLLBACK
			RETURN
		END CATCH
	END




