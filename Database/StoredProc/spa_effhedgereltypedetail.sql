
IF OBJECT_ID(N'[dbo].spa_effhedgereltypedetail', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].spa_effhedgereltypedetail
GO 

--This proc will be used to select, insert, update and delete hedge relationship record
--from the fas_eff_hedge_rel_type_detail table
--The fisrt parameter or flag to pass: select = 's', for Insert='i'. Update='u' and Delete='d'
--For insert and update, pass all the parameters defined for this stored procedure
--For delete, pass the flag and the fas_book_id

-- DROP PROC spa_effhedgereltypedetail
-- EXEC spa_effhedgereltypedetail 's', 'h', 4
-- EXEC spa_effhedgereltypedetail 'a', 'i', 4, 1

CREATE PROC [dbo].[spa_effhedgereltypedetail]
	@flag CHAR(1),
	@flag2 CHAR(1) = NULL,
	@eff_test_profile_id INT = NULL, 
	@eff_test_profile_detail_id VARCHAR(1000) = NULL,
	@deal_sequence_number INT = NULL,
	@book_deal_type_map_id INT = NULL,
	@source_deal_type_id INT = NULL,
	@deal_sub_type_id INT = NULL,
	@fixed_float_flag CHAR(1) = NULL,
	@leg INT = NULL ,
	@buy_sell_flag CHAR(1) = NULL,
	@source_curve_def_id INT = NULL,
	@strip_month_from CHAR(3) = NULL,
	@strip_month_to CHAR(3) = NULL,
	@strip_year_overlap INT = NULL,
	@roll_forward_year INT = NULL,
	@volume_mix_percentage FLOAT = NULL,
	@uom_conversion_factor FLOAT = NULL,
	@deal_xfer_source_book_id INT = NULL,
	@hedge_or_item CHAR(1) = NULL,
	@strip_months INT = NULL,
	@price_adder FLOAT = NULL,
	@price_multiplier FLOAT = NULL,
	@volume_round INT = NULL,
	@price_round INT = NULL,
	@source_system_book_id1 INT = NULL,
	@source_system_book_id2 INT = NULL,
	@source_system_book_id3 INT = NULL,
	@source_system_book_id4 INT = NULL,
	@sub_id INT = NULL
AS
SET NOCOUNT ON
--If @flag = 's' and @flag2 = 'h'
IF @flag = 's'
BEGIN
    -- 	select b.*
    -- 	from fas_eff_hedge_rel_type a, fas_eff_hedge_rel_type_detail b
    -- 	where a.eff_test_profile_id = b.eff_test_profile_id
    -- 	and b.eff_test_profile_id = @eff_test_profile_id
    --         and upper(hedge_or_item) = 'H' 
    
    --########### Group Label
    DECLARE @group1  VARCHAR(100),
            @group2  VARCHAR(100),
            @group3  VARCHAR(100),
            @group4  VARCHAR(100)
    
    IF EXISTS(
           SELECT group1,
                  group2,
                  group3,
                  group4
           FROM   source_book_mapping_clm
       )
    BEGIN
        SELECT @group1 = group1,
               @group2 = group2,
               @group3 = group3,
               @group4 = group4
        FROM   source_book_mapping_clm
    END
    ELSE
    BEGIN
        SET @group1 = 'Group 1'
        SET @group2 = 'Group 2'
        SET @group3 = 'Group 3'
        SET @group4 = 'Group 4'
    END
    --######## End
    
    DECLARE @sql_stmt AS VARCHAR(5000)
    CREATE TABLE #strip_month(
		value_id VARCHAR(4) COLLATE DATABASE_DEFAULT,
		code VARCHAR(10) COLLATE DATABASE_DEFAULT
    )
    INSERT INTO #strip_month
    EXEC spa_execute_query '[''jan'',''January''],[''feb'',''February''],[''mar'',''March''],[''apr'',''April''],[''may'',''May''],[''jun'',''June''],[''jul'',''July''],[''aug'',''August''],[''sep'',''September''],[''oct'',''October''],[''nov'',''November''],[''dec'',''December'']'
    
    SET @sql_stmt = 
				'SELECT
					 hrtd.eff_test_profile_detail_id 
					, hrtd.eff_test_profile_id 
					, sub.entity_name subsidiary_id
					, (Book1.source_book_name + ''|'' + Book2.source_book_name + ''|'' 
						+ Book3.source_book_name + ''|'' + Book4.source_book_name + ''|'' 
						+ static_data_value.code)  source_book_map					
					, ISNULL(Book1.source_book_name, sb1.source_book_name) ''group1''
					, ISNULL(Book2.source_book_name, sb2.source_book_name) ''group2'' 
					, ISNULL(Book3.source_book_name, sb3.source_book_name) ''group3'' 
					, ISNULL(Book4.source_book_name, sb4.source_book_name) ''group4'' 
					, CASE WHEN hrtd.hedge_or_item = ''h'' THEN ''Hedge'' ELSE ''Item'' END hedge_item
					, (case hrtd.buy_sell_flag when ''b'' Then ''Receive'' Else ''Pay'' end) buy_sell
					, (case hrtd.fixed_float_flag when ''f'' Then ''Fixed'' Else ''Float'' end) AS fixed_float
				    , spcd.curve_name AS [curve_index]
				    , hrtd.deal_sequence_number
				    , hrtd.leg
					, stm.code strip_month_from 
					, stm1.code strip_month_to
					, sdt.source_deal_type_name deal_type
					, sdst.source_deal_type_name AS deal_sub_type  
					, Cast(hrtd.volume_mix_percentage as varchar) volume_mix 
					, hrtd.uom_conversion_factor
					, hrtd.price_adder
					, hrtd.price_multiplier
					, hrtd.strip_months
					, hrtd.strip_year_overlap lag_month
					, hrtd.roll_forward_year item_strip_month
					, hrtd.volume_round		
					, hrtd.price_round
					, hrtd.deal_xfer_source_book_id
						----static_data_value.code AS Type, 
						----hrtd.create_user AS [Create By], dbo.FNADateFormat(hrtd.create_ts) AS [Create TS], 
						----hrtd.update_user AS [Update By], dbo.FNADateFormat(hrtd.update_ts) AS [Update TS]
                FROM source_price_curve_def  spcd
                RIGHT OUTER JOIN static_data_value 
                INNER JOIN source_system_book_map ON static_data_value.value_id = source_system_book_map.fas_deal_type_value_id 
                INNER JOIN source_book Book1 ON source_system_book_map.source_system_book_id1 = Book1.source_book_id 
                INNER JOIN source_book Book2 ON source_system_book_map.source_system_book_id2 = Book2.source_book_id 
                INNER JOIN source_book Book3 ON source_system_book_map.source_system_book_id3 = Book3.source_book_id 
                INNER JOIN source_book Book4 ON source_system_book_map.source_system_book_id4 = Book4.source_book_id 
                RIGHT OUTER JOIN fas_eff_hedge_rel_type_detail hrtd ON source_system_book_map.book_deal_type_map_id = hrtd.book_deal_type_map_id 
                ON spcd.source_curve_def_id = hrtd.source_curve_def_id 
                LEFT OUTER JOIN source_deal_type sdt ON hrtd.source_deal_type_id = sdt.source_deal_type_id 
                LEFT OUTER JOIN source_deal_type sdst ON hrtd.deal_sub_type_id = sdst.source_deal_type_id
				left JOIN source_book sb1 ON  sb1.source_book_id = hrtd.source_system_book_id1
				left JOIN source_book sb2 ON  sb2.source_book_id = hrtd.source_system_book_id2
				left JOIN source_book sb3 ON  sb3.source_book_id = hrtd.source_system_book_id3
				left JOIN source_book sb4 ON  sb4.source_book_id = hrtd.source_system_book_id4 
				LEFT JOIN portfolio_hierarchy sub ON sub.hierarchy_level = 2 AND sub.entity_id = hrtd.sub_id
				LEFT JOIN #strip_month stm ON stm.value_id = hrtd.strip_month_from
				LEFT JOIN #strip_month stm1 ON stm1.value_id = hrtd.strip_month_to
				WHERE eff_test_profile_id = ' + CAST(@eff_test_profile_id AS VARCHAR)

    IF UPPER(@flag2) = 'H'
        SET @sql_stmt = @sql_stmt + ' AND UPPER(hedge_or_item) = ''H'''
    
    IF UPPER(@flag2) = 'I'
        SET @sql_stmt = @sql_stmt + ' AND UPPER(hedge_or_item) = ''I'' ' 
    
    
    SET @sql_stmt = @sql_stmt + 
        ' ORDER BY hrtd.deal_sequence_number, hrtd.leg'
   
    EXEC (@sql_stmt)
    
    
    IF @@ERROR <> 0
        EXEC spa_ErrorHandler @@ERROR,
             'Effective Hedge Relation detail table',
             'spa_effhedgereltypedetail',
             'DB Error',
             'Failed to select effective hedge relation detail record of Hedge type.',
             ''
END
ELSE 
IF @flag = 'a'
BEGIN
    SELECT b.eff_test_profile_detail_id,
           b.eff_test_profile_id,
           b.hedge_or_item,
           b.book_deal_type_map_id,
           b.source_deal_type_id,
           b.deal_sub_type_id,
           b.fixed_float_flag,
           b.deal_sequence_number,
           b.leg,
           b.buy_sell_flag,
           b.source_curve_def_id,
           b.strip_month_from,
           b.strip_month_to,
           b.strip_year_overlap,
           b.roll_forward_year,
           b.volume_mix_percentage AS volume_mix_percentage,
           b.uom_conversion_factor AS uom_conversion_factor,
           b.deal_xfer_source_book_id,
           b.create_user,
           b.create_ts,
           b.update_user,
           b.update_ts,
           b.strip_months,
           b.price_adder,
           b.price_multiplier,
           b.volume_round,
           b.price_round,
           b.source_system_book_id1,
           b.source_system_book_id2,
           b.source_system_book_id3,
           b.source_system_book_id4,
           b.sub_id
    FROM   fas_eff_hedge_rel_type_detail b
    WHERE  b.eff_test_profile_detail_id = @eff_test_profile_detail_id
    
    IF @@ERROR <> 0
        EXEC spa_ErrorHandler @@ERROR,
             'Effective Hedge Relation detail table',
             'spa_effhedgereltypedetail',
             'DB Error',
             'Failed to select effective hedge relation detail record of Item type.',
             ''
    ELSE
        EXEC spa_ErrorHandler 0,
             'Effective Hedge Relation detail table',
             'spa_effhedgereltypedetail',
             'Success',
             'Effective hedge relation detail record of Item Type successfully selected.',
             ''
END
ELSE 
IF @flag = 'i'
BEGIN
	IF EXISTS( SELECT 1 FROM fas_eff_hedge_rel_type_detail
				WHERE 	1 = 1
						AND eff_test_profile_id = @eff_test_profile_id 
						AND hedge_or_item = @hedge_or_item 
						AND deal_sequence_number = @deal_sequence_number 
 						AND leg = @leg)
	BEGIN
		 EXEC spa_ErrorHandler @@ERROR,
             'Effective Hedge Relation DETAIL table',
             'spa_effhedgereltypedetail',
             'DB Error',
             'Duplicate data.',
             ''
         RETURN
	END 		

	INSERT INTO fas_eff_hedge_rel_type_detail
      (
        eff_test_profile_id,
        hedge_or_item,
        book_deal_type_map_id,
        source_deal_type_id,
        deal_sub_type_id,
        fixed_float_flag,
        deal_sequence_number,
        leg,
        buy_sell_flag,
        source_curve_def_id,
        strip_month_from,
        strip_month_to,
        strip_year_overlap,
        roll_forward_year,
        volume_mix_percentage,
        uom_conversion_factor,
        deal_xfer_source_book_id,
        strip_months,
        price_adder,
        price_multiplier,
        volume_round,
        price_round,
        source_system_book_id1,
        source_system_book_id2,
        source_system_book_id3,
        source_system_book_id4,
        sub_id
      )
    VALUES
      (
        @eff_test_profile_id,
        @hedge_or_item,
        @book_deal_type_map_id,
        @source_deal_type_id,
        @deal_sub_type_id,
        @fixed_float_flag,
        @deal_sequence_number,
        @leg,
        @buy_sell_flag,
        @source_curve_def_id,
        @strip_month_from,
        @strip_month_to,
        @strip_year_overlap,
        @roll_forward_year,
        @volume_mix_percentage,
        @uom_conversion_factor,
        @deal_xfer_source_book_id,
        @strip_months,
        @price_adder,
        @price_multiplier,
        @volume_round,
        @price_round,
        @source_system_book_id1,
        @source_system_book_id2,
        @source_system_book_id3,
        @source_system_book_id4,
        @sub_id
      )
    
    IF @@ERROR <> 0
        EXEC spa_ErrorHandler @@ERROR,
             'Effective Hedge Relation DETAIL table',
             'spa_effhedgereltypedetail',
             'DB Error',
             'Failed to insert effective hedge detail relation record.',
             ''
    ELSE
        EXEC spa_ErrorHandler 0,
             'Effective Hedge Relation detail table',
             'spa_effhedgereltypedetail',
             'Success',
             'Effective hedge relation detail record successfully Inserted.',
             ''
END
ELSE 
IF @flag = 'u'
BEGIN
	IF EXISTS( SELECT 1 FROM fas_eff_hedge_rel_type_detail
				WHERE 	1 = 1
						AND eff_test_profile_id = @eff_test_profile_id 
						AND hedge_or_item = @hedge_or_item 
						AND deal_sequence_number = @deal_sequence_number 
 						AND leg = @leg
						AND eff_test_profile_detail_id <> @eff_test_profile_detail_id)
	BEGIN
		 EXEC spa_ErrorHandler @@ERROR,
             'Effective Hedge Relation DETAIL table',
             'spa_effhedgereltypedetail',
             'DB Error',
             'Duplicate data.',
             ''
         RETURN
	END 		
	
    UPDATE fas_eff_hedge_rel_type_detail
    SET    eff_test_profile_id = @eff_test_profile_id,
           hedge_or_item = @hedge_or_item,
           book_deal_type_map_id = @book_deal_type_map_id,
           source_deal_type_id = @source_deal_type_id,
           deal_sub_type_id = @deal_sub_type_id,
           fixed_float_flag = @fixed_float_flag,
           deal_sequence_number = @deal_sequence_number,
           leg = @leg,
           buy_sell_flag = @buy_sell_flag,
           source_curve_def_id = @source_curve_def_id,
           strip_month_from = @strip_month_from,
           strip_month_to = @strip_month_to,
           strip_year_overlap = @strip_year_overlap,
           roll_forward_year = @roll_forward_year,
           volume_mix_percentage = @volume_mix_percentage,
           uom_conversion_factor = @uom_conversion_factor,
           deal_xfer_source_book_id = @deal_xfer_source_book_id,
           strip_months = @strip_months,
           price_adder = @price_adder,
           price_multiplier = @price_multiplier,
           volume_round = @volume_round,
           price_round = @price_round,
           source_system_book_id1 = @source_system_book_id1,
           source_system_book_id2 = @source_system_book_id2,
           source_system_book_id3 = @source_system_book_id3,
           source_system_book_id4 = @source_system_book_id4,
           sub_id = @sub_id,
           update_ts = GETDATE(),
           update_user = dbo.FNADBuser()
    WHERE  eff_test_profile_detail_id = @eff_test_profile_detail_id
    
    IF @@ERROR <> 0
        EXEC spa_ErrorHandler @@ERROR,
             'Effective Hedge Relation detail table',
             'spa_effhedgereltypedetail',
             'DB Error',
             'Failed to update effective hedge relation detailrecord.',
             ''
    ELSE
        EXEC spa_ErrorHandler 0,
             'Effective Hedge Relation detail table',
             'spa_effhedgereltypedetail',
             'Success',
             'Effective hedge relation detail record successfully updated.',
             ''
END
ELSE 
IF @flag = 'd'
BEGIN
	--DECLARE @hedge_item CHAR(1)
	--SELECT @hedge_item = hedge_or_item FROM fas_eff_hedge_rel_type_detail where eff_test_profile_detail_id = @eff_test_profile_detail_id

    DELETE fehrtd
    FROM fas_eff_hedge_rel_type_detail fehrtd
	INNER JOIN dbo.FNASplit(@eff_test_profile_detail_id, ',') di ON di.item = fehrtd.eff_test_profile_detail_id
    
    IF @@ERROR <> 0
        EXEC spa_ErrorHandler @@ERROR,
			'Effective Hedge Relation detail table',
			'spa_effhedgereltypedetail',
			'DB Error',
			'Failed to delete effective hedge relation detail record.',
			''
    ELSE
        EXEC spa_ErrorHandler 0,
            'Effective Hedge Relation detail table',
            'spa_effhedgereltypedetail',
            'Success',
            'Changes have been saved successfully.',
            @eff_test_profile_detail_id
END 

IF @flag = 'w'
BEGIN
    SELECT source_book_id,
           source_book_name
    FROM   source_book
    WHERE  source_system_book_type_value_id = 50
END

IF @flag = 'x'
BEGIN
    SELECT source_book_id,
           source_book_name
    FROM   source_book
    WHERE  source_system_book_type_value_id = 51
END

IF @flag = 'y'
BEGIN
    SELECT source_book_id,
           source_book_name
    FROM   source_book
    WHERE  source_system_book_type_value_id = 52
END

IF @flag = 'z'
BEGIN
    SELECT source_book_id,
           source_book_name
    FROM   source_book
    WHERE  source_system_book_type_value_id = 53
END

IF @flag = 'v'
BEGIN
    SELECT sbmc.group1,
           sbmc.group2,
           sbmc.group3,
           sbmc.group4
    FROM   source_book_mapping_clm sbmc
END

GO
