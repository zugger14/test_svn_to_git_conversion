IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_books]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_books]

--SELECT * FROM fas_books

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- EXEC spa_books 's', 262
-- DROP PROC spa_books

--This proc will be used to perform select, insert, update and delete record
--from the fas_books table
--The fisrt parameter or flag to pass: select = 's', for Insert='i'. Update='u' and Delete='d'
--For insert and update, pass all the parameters defined for this stored procedure
--For delete, pass the flag and the fas_book_id parameter

CREATE proc [dbo].[spa_books]
@flag char(1),
@fas_book_id int=NULL,
@fas_book_name varchar(100)=NULL,
@no_link char(1)=NULL,
@no_links_fas_eff_test_profile_id int=NULL,
@gl_number_id_st_asset int= NULL,
@gl_number_id_st_liab int= NULL,
@gl_number_id_lt_asset int= NULL,
@gl_number_id_lt_liab int= NULL,
@gl_number_id_item_st_asset int= NULL,
@gl_number_id_item_st_liab int= NULL,
@gl_number_id_item_lt_asset int= NULL,
@gl_number_id_item_lt_liab int= NULL,
@gl_number_id_aoci int= NULL,
@gl_number_id_pnl int= NULL,
@gl_number_id_set int= NULL,
@gl_number_id_cash int= NULL,
@fas_strategy_id int = Null,
@gl_number_id_inventory int = NULL,
@gl_number_id_amortization int = NUll,
@gl_number_id_interest int = NUll,
@gl_number_id_expense int=NULL,
@gl_number_id_gross_set int=NULL,
@convert_uom_id int=null,
@cost_approach_id int=NULL,
@gl_id_st_tax_asset int = NULL,
@gl_id_st_tax_liab int = NULL,
@gl_id_lt_tax_asset int = NULL,
@gl_id_lt_tax_liab int = NULL,
@gl_id_tax_reserve int=null,
@legal_entity int=null,
@tax_perc float=null,
-- Added 
@fun_cur_value_id int=NULL,
@hedge_item_same_sign char(1)=NULL,
@hedge_type_value_id INT = NULL,
@gl_number_unhedged_der_st_asset INT = NULL,
@gl_number_unhedged_der_lt_asset INT = NULL,
@gl_number_unhedged_der_st_liab INT = NULL,
@gl_number_unhedged_der_lt_liab INT = NULL

AS 
SET NOCOUNT ON

DECLARE  @tmp_strategy  varchar(200)

If @flag = 's'
begin
-- 	SELECT a.*, b.entity_name
-- 	FROM fas_books a, portfolio_hierarchy b
-- 	WHERE a.fas_book_id = @fas_book_id
-- 	AND a.fas_book_id = b.entity_id

--SELECT fas_books.fas_book_id,
--       no_link,
--       no_links_fas_eff_test_profile_id,
--       gl_number_id_st_asset,
--       gl_number_id_st_liab,
--       gl_number_id_lt_asset,
--       gl_number_id_lt_liab,
--       gl_number_id_item_st_asset,
--       gl_number_id_item_st_liab,
--       gl_number_id_item_lt_asset,
--       gl_number_id_item_lt_liab,
--       gl_number_id_aoci,
--       gl_number_id_pnl,
--       gl_number_id_set,
--       gl_number_id_cash,
--       fas_books.create_user,
--       fas_books.create_ts,
--       fas_books.update_user,
--       fas_books.update_ts,
--       --fas_books.*, 
--       portfolio_hierarchy.entity_name AS entity_name,
--       gl1.gl_account_number + ' (' + gl1.gl_account_name + ')' AS gl_number_id_st_asset_display,
--       gl2.gl_account_number + ' (' + gl2.gl_account_name + ')' AS gl_number_id_st_liab_display,
--       gl3.gl_account_number + ' (' + gl3.gl_account_name + ')' AS gl_number_id_lt_asset_display,
--       gl4.gl_account_number + ' (' + gl4.gl_account_name + ')' AS gl_number_id_lt_liab_display,
--       gl5.gl_account_number + ' (' + gl5.gl_account_name + ')' AS gl_number_id_item_st_asset_display,
--       gl6.gl_account_number + ' (' + gl6.gl_account_name + ')' AS gl_number_id_item_st_liab_display,
--       gl7.gl_account_number + ' (' + gl7.gl_account_name + ')' AS gl_number_id_item_lt_asset_display,
--       gl8.gl_account_number + ' (' + gl8.gl_account_name + ')' AS gl_number_id_item_lt_liab_display,
--       gl9.gl_account_number + ' (' + gl9.gl_account_name + ')' AS gl_number_id_aoci_display,
--       gl10.gl_account_number + ' (' + gl10.gl_account_name + ')' AS gl_number_id_pnl_display,
--       gl11.gl_account_number + ' (' + gl11.gl_account_name + ')' AS gl_number_id_set_display,
--       gl12.gl_account_number + ' (' + gl12.gl_account_name + ')' AS gl_number_id_cash_display,
--       fas_eff_hedge_rel_type.eff_test_name AS no_links_fas_eff_test_profile_id_name,
--       gl_number_id_inventory,
--       gl13.gl_account_number + ' (' + gl13.gl_account_name + ')' AS gl_number_id_inventory_display,
--       gl_id_amortization,
--       gl14.gl_account_number + ' (' + gl14.gl_account_name + ')' AS gl_number_id_Amortize_display,
--       gl_id_interest,
--       gl15.gl_account_number + ' (' + gl15.gl_account_name + ')' AS gl_number_id_Intrest_display,
--       gl_number_id_expense,
--       gl16.gl_account_number + ' (' + gl16.gl_account_name + ')' AS gl_number_id_Expense_display,
--       gl_number_id_gross_set,
--       gl17.gl_account_number + ' (' + gl17.gl_account_name + ')' AS  gl_number_id_Gross_display,
--       fas_books.convert_uom_id,
--       fas_books.cost_approach_id,
--       fas_books.gl_id_st_tax_asset,
--       gl18.gl_account_number + ' (' + gl18.gl_account_name + ')' AS  gl_id_st_tax_asset_display,
--       fas_books.gl_id_st_tax_liab,
--       gl19.gl_account_number + ' (' + gl19.gl_account_name + ')' AS  gl_id_st_tax_liab_display,
--       fas_books.gl_id_lt_tax_asset,
--       gl20.gl_account_number + ' (' + gl20.gl_account_name + ')' AS  gl_id_lt_tax_asset_display,
--       fas_books.gl_id_lt_tax_liab,
--       gl21.gl_account_number + ' (' + gl21.gl_account_name + ')' AS  gl_id_lt_tax_liab_display,
--       fas_books.gl_id_tax_reserve,
--       gl22.gl_account_number + ' (' + gl22.gl_account_name + ')' AS  gl_id_tax_reserve_display,
--       fas_books.legal_entity,
--       fas_books.tax_perc,
--       fas_books.hedge_item_same_sign,
--       fas_books.fun_cur_value_id,
--       fas_books.hedge_type_value_id,
--	   fas_books.gl_number_unhedged_der_st_asset,
--	   gl23.gl_account_number + ' (' + gl23.gl_account_name +')' as gl_number_unhedged_der_st_asset_display,
--	   fas_books.gl_number_unhedged_der_lt_asset,
--	   gl24.gl_account_number + ' (' + gl24.gl_account_name +')' as gl_number_unhedged_der_lt_asset_display,
--	   fas_books.gl_number_unhedged_der_st_liab,
--	   gl25.gl_account_number + ' (' + gl25.gl_account_name +')' as gl_number_unhedged_der_st_liab_display,
--	   fas_books.gl_number_unhedged_der_lt_liab,
--	   gl26.gl_account_number + ' (' + gl26.gl_account_name +')' as gl_number_unhedged_der_lt_liab_display
--FROM   fas_books
--       INNER JOIN portfolio_hierarchy
--            ON  fas_books.fas_book_id = portfolio_hierarchy.entity_id
--       LEFT OUTER JOIN gl_system_mapping gl1
--            ON  fas_books.gl_number_id_st_asset = gl1.gl_number_id
--       LEFT OUTER JOIN gl_system_mapping gl2
--            ON  fas_books.gl_number_id_st_liab = gl2.gl_number_id
--       LEFT OUTER JOIN gl_system_mapping gl3
--            ON  fas_books.gl_number_id_lt_asset = gl3.gl_number_id
--       LEFT OUTER JOIN gl_system_mapping gl4
--            ON  fas_books.gl_number_id_lt_liab = gl4.gl_number_id
--       LEFT OUTER JOIN gl_system_mapping gl5
--            ON  fas_books.gl_number_id_item_st_asset = gl5.gl_number_id
--       LEFT OUTER JOIN gl_system_mapping gl6
--            ON  fas_books.gl_number_id_item_st_liab = gl6.gl_number_id
--       LEFT OUTER JOIN gl_system_mapping gl7
--            ON  fas_books.gl_number_id_item_lt_asset = gl7.gl_number_id
--       LEFT OUTER JOIN gl_system_mapping gl8
--            ON  fas_books.gl_number_id_item_lt_liab = gl8.gl_number_id
--       LEFT OUTER JOIN gl_system_mapping gl9
--            ON  fas_books.gl_number_id_aoci = gl9.gl_number_id
--       LEFT OUTER JOIN gl_system_mapping gl10
--            ON  fas_books.gl_number_id_pnl = gl10.gl_number_id
--       LEFT OUTER JOIN gl_system_mapping gl11
--            ON  fas_books.gl_number_id_set = gl11.gl_number_id
--       LEFT OUTER JOIN gl_system_mapping gl12
--            ON  fas_books.gl_number_id_cash = gl12.gl_number_id
--       LEFT OUTER JOIN gl_system_mapping gl13
--            ON  fas_books.gl_number_id_inventory = gl13.gl_number_id
--       LEFT OUTER JOIN gl_system_mapping gl14
--            ON  fas_books.gl_id_amortization = gl14.gl_number_id
--       LEFT OUTER JOIN gl_system_mapping gl15
--            ON  fas_books.gl_id_interest = gl15.gl_number_id
--       LEFT OUTER JOIN gl_system_mapping gl16
--            ON  fas_books.gl_number_id_expense = gl16.gl_number_id
--       LEFT OUTER JOIN gl_system_mapping gl17
--            ON  fas_books.gl_number_id_gross_set = gl17.gl_number_id
--       LEFT OUTER JOIN gl_system_mapping gl18
--            ON  fas_books.gl_id_st_tax_asset = gl18.gl_number_id
--       LEFT OUTER JOIN gl_system_mapping gl19
--            ON  fas_books.gl_id_st_tax_liab = gl19.gl_number_id
--       LEFT OUTER JOIN gl_system_mapping gl20
--            ON  fas_books.gl_id_lt_tax_asset = gl20.gl_number_id
--       LEFT OUTER JOIN gl_system_mapping gl21
--            ON  fas_books.gl_id_lt_tax_liab = gl21.gl_number_id
--       LEFT OUTER JOIN gl_system_mapping gl22
--            ON  fas_books.gl_id_tax_reserve = gl22.gl_number_id
--		LEFT OUTER JOIN gl_system_mapping gl23 
--			ON   fas_books.gl_number_unhedged_der_st_asset = gl23.gl_number_id 
--		LEFT OUTER JOIN	gl_system_mapping gl24 
--			ON   fas_books.gl_number_unhedged_der_lt_asset = gl24.gl_number_id 
--		LEFT OUTER JOIN	gl_system_mapping gl25 
--			ON   fas_books.gl_number_unhedged_der_st_liab = gl25.gl_number_id 
--		LEFT OUTER JOIN	gl_system_mapping gl26 
--			ON   fas_books.gl_number_unhedged_der_lt_liab = gl26.gl_number_id        
--		LEFT OUTER JOIN fas_eff_hedge_rel_type
--            ON  fas_books.no_links_fas_eff_test_profile_id = fas_eff_hedge_rel_type.eff_test_profile_id
--WHERE  fas_books.fas_book_id = @fas_book_id

SELECT * FROM vwBookOption WHERE fas_book_id = @fas_book_id          
	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Book Properties', 
				'spa_books', 'DB Error', 
				'Failed to select the book properties.', ''
	Else
		Exec spa_ErrorHandler 0, 'Book Properties', 
				'spa_books', 'Success', 
				'Book properties successfully selected.', ''
End

Else if @flag = 'i'
BEGIN
	DECLARE @smt VARCHAR(500)
	IF EXISTS (
	       SELECT 1
	       FROM   portfolio_hierarchy
	       WHERE  entity_name = @fas_book_name
	              AND hierarchy_level = 0
	              AND parent_entity_id = @fas_strategy_id
	   )
	BEGIN
	    --select @tmp_strategy=entity_name from portfolio_hierarchy where hierarchy_level =1  and  
	    SELECT @tmp_strategy = entity_name
	    FROM   portfolio_hierarchy
	    WHERE  entity_id = @fas_strategy_id
	    
	    SET @smt = 'The book ''' + @fas_book_name + ''' already exists under strategy ''' + @tmp_strategy + '''.'
	    
	    EXEC spa_ErrorHandler -1,
	         @smt,
	         'spa_books',
	         'DB Error',
	         @smt,
	         ''
	    
	    RETURN
	END
	
	BEGIN TRANSACTION
	INSERT INTO portfolio_hierarchy
	VALUES
	  (
	    @fas_book_name,
	    527,
	    0,
	    @fas_strategy_id,
	    NULL,
	    NULL,
	    NULL,
	    NULL
	  )	
	
	SET @fas_book_id = SCOPE_IDENTITY() 
	IF @@ERROR <> 0
	BEGIN
	    EXEC spa_ErrorHandler @@ERROR,
	         'Book Properties',
	         'spa_books',
	         'DB Error',
	         'Failed to insert book properties.',
	         ''
	    
	    ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
	    INSERT INTO fas_books
	      (
	        fas_book_id,
	        no_link,
	        no_links_fas_eff_test_profile_id,
	        gl_number_id_st_asset,
	        gl_number_id_st_liab,
	        gl_number_id_lt_asset,
	        gl_number_id_lt_liab,
	        gl_number_id_item_st_asset,
	        gl_number_id_item_st_liab,
	        gl_number_id_item_lt_asset,
	        gl_number_id_item_lt_liab,
	        gl_number_id_aoci,
	        gl_number_id_pnl,
	        gl_number_id_set,
	        gl_number_id_cash,
	        gl_number_id_inventory,
	        gl_id_amortization,
	        gl_id_interest,
	        gl_number_id_expense,
	        gl_number_id_gross_set,
	        convert_uom_id,
	        cost_approach_id,
	        gl_id_st_tax_asset,
	        gl_id_st_tax_liab,
	        gl_id_lt_tax_asset,
	        gl_id_lt_tax_liab,
	        gl_id_tax_reserve,
	        legal_entity,
	        tax_perc,
	        hedge_item_same_sign,
	        fun_cur_value_id,
	        hedge_type_value_id,
			gl_number_unhedged_der_st_asset,
			gl_number_unhedged_der_lt_asset,
			gl_number_unhedged_der_st_liab,
			gl_number_unhedged_der_lt_liab
	      )
	    VALUES
	      (
	        @fas_book_id,
	        @no_link,
	        @no_links_fas_eff_test_profile_id,
	        @gl_number_id_st_asset,
	        @gl_number_id_st_liab,
	        @gl_number_id_lt_asset,
	        @gl_number_id_lt_liab,
	        @gl_number_id_item_st_asset,
	        @gl_number_id_item_st_liab,
	        @gl_number_id_item_lt_asset,
	        @gl_number_id_item_lt_liab,
	        @gl_number_id_aoci,
	        @gl_number_id_pnl,
	        @gl_number_id_set,
	        @gl_number_id_cash,
	        @gl_number_id_inventory,
	        @gl_number_id_amortization,
	        @gl_number_id_interest,
	        @gl_number_id_expense,
	        @gl_number_id_gross_set,
	        @convert_uom_id,
	        @cost_approach_id,
	        @gl_id_st_tax_asset,
	        @gl_id_st_tax_liab,
	        @gl_id_lt_tax_asset,
	        @gl_id_lt_tax_liab,
	        @gl_id_tax_reserve,
	        @legal_entity,
	        @tax_perc,
	        @hedge_item_same_sign,
	        @fun_cur_value_id,
	        @hedge_type_value_id,
			@gl_number_unhedged_der_st_asset,
			@gl_number_unhedged_der_lt_asset,
			@gl_number_unhedged_der_st_liab,
			@gl_number_unhedged_der_lt_liab
	      )
	    
	    IF @@ERROR <> 0
	    BEGIN
	        EXEC spa_ErrorHandler @@ERROR,
	             'Book Properties',
	             'spa_books',
	             'DB Error',
	             'Failed to insert book properties.',
	             ''
	        
	        ROLLBACK TRANSACTION
	    END
	    ELSE
	    BEGIN
	        EXEC spa_ErrorHandler 0,
	             'Book Properties',
	             'spa_books',
	             'Success',
	             'Book properties successfully inserted.',
	             @fas_book_id
	        
	        COMMIT TRANSACTION
	    END
	END
END	

ELSE IF @flag = 'u'
     BEGIN
         DECLARE @stmt VARCHAR(500)
         
         --don't allow to update any book to have existing name under same strategy
         
         IF EXISTS (
                SELECT 1
                FROM   portfolio_hierarchy book
                       INNER JOIN (
                                SELECT parent_entity_id entity_id
                                FROM   portfolio_hierarchy
                                WHERE  entity_id = @fas_book_id
                            ) stra
                            ON  book.parent_entity_id = stra.entity_id
                WHERE  book.entity_name = @fas_book_name
                       AND book.entity_id <> @fas_book_id
            )
         BEGIN
             --select @tmp_strategy=entity_name from portfolio_hierarchy where hierarchy_level =1  and  
             SELECT @tmp_strategy = stra.entity_name
             FROM   portfolio_hierarchy book
                    INNER JOIN portfolio_hierarchy stra
                         ON  stra.entity_id = book.parent_entity_id
             WHERE  book.entity_id = @fas_book_id
             
             SET @stmt = 'The book ''' + @fas_book_name + ''' already exists under strategy ''' + @tmp_strategy + '''.'
             
             EXEC spa_ErrorHandler -1,
                  @stmt,
                  'spa_books',
                  'DB Error',
                  @stmt,
                  ''
             
             RETURN
         END
         
         SELECT 'p' AS TYPE,
                portfolio_hierarchy.entity_name AS [entity_name],
                fas_book_id,
                no_link,
                no_links_fas_eff_test_profile_id,
                gl_number_id_st_asset,
                gl_number_id_st_liab,
                gl_number_id_lt_asset,
                gl_number_id_lt_liab,
                gl_number_id_item_st_asset,
                gl_number_id_item_st_liab,
                gl_number_id_item_lt_asset,
                gl_number_id_item_lt_liab,
                gl_number_id_aoci,
                gl_number_id_pnl,
                gl_number_id_set,
                gl_number_id_cash,
                gl_number_id_inventory,
                gl_id_amortization,
                gl_id_interest,
                convert_uom_id,
                cost_approach_id
                INTO #temp_fas_books
         FROM   fas_books
                INNER JOIN portfolio_hierarchy
                     ON  portfolio_hierarchy.entity_id = fas_books.fas_book_id
         WHERE  fas_book_id = @fas_book_id
         
         
         BEGIN TRANSACTION
         UPDATE portfolio_hierarchy
         SET    entity_name = @fas_book_name
         WHERE  entity_id = @fas_book_id
         
         IF @@ERROR <> 0
         BEGIN
             EXEC spa_ErrorHandler @@ERROR,
                  'Book Properties',
                  'spa_books',
                  'DB Error',
                  'Failed to update book properties.',
                  ''
             
             ROLLBACK TRANSACTION
         END
         ELSE
         BEGIN
             UPDATE fas_books
             SET    no_link = @no_link,
                    no_links_fas_eff_test_profile_id = @no_links_fas_eff_test_profile_id,
                    gl_number_id_st_asset = @gl_number_id_st_asset,
                    gl_number_id_st_liab = @gl_number_id_st_liab,
                    gl_number_id_lt_asset = @gl_number_id_lt_asset,
                    gl_number_id_lt_liab = @gl_number_id_lt_liab,
                    gl_number_id_item_st_asset = @gl_number_id_item_st_asset,
                    gl_number_id_item_st_liab = @gl_number_id_item_st_liab,
                    gl_number_id_item_lt_asset = @gl_number_id_item_lt_asset,
                    gl_number_id_item_lt_liab = @gl_number_id_item_lt_liab,
                    gl_number_id_aoci = @gl_number_id_aoci,
                    gl_number_id_pnl = @gl_number_id_pnl,
                    gl_number_id_set = @gl_number_id_set,
                    gl_number_id_cash = @gl_number_id_cash,
                    gl_number_id_inventory = @gl_number_id_inventory,
                    gl_id_amortization = @gl_number_id_amortization,
                    gl_id_interest = @gl_number_id_interest,
                    gl_number_id_expense = @gl_number_id_expense,
                    gl_number_id_gross_set = @gl_number_id_gross_set,
                    convert_uom_id = @convert_uom_id,
                    cost_approach_id = @cost_approach_id,
                    gl_id_st_tax_asset = @gl_id_st_tax_asset,
                    gl_id_st_tax_liab = @gl_id_st_tax_liab,
                    gl_id_lt_tax_asset = @gl_id_lt_tax_asset,
                    gl_id_lt_tax_liab = @gl_id_lt_tax_liab,
                    gl_id_tax_reserve = @gl_id_tax_reserve,
                    legal_entity = @legal_entity,
                    tax_perc = @tax_perc,
                    hedge_item_same_sign = @hedge_item_same_sign,
                    fun_cur_value_id = @fun_cur_value_id,
                    hedge_type_value_id = @hedge_type_value_id,
					gl_number_unhedged_der_st_asset = @gl_number_unhedged_der_st_asset,
					gl_number_unhedged_der_lt_asset = @gl_number_unhedged_der_lt_asset,
					gl_number_unhedged_der_st_liab = @gl_number_unhedged_der_st_liab,
					gl_number_unhedged_der_lt_liab = @gl_number_unhedged_der_lt_liab
             WHERE  fas_book_id = @fas_book_id
             
             IF @@ERROR <> 0
             BEGIN
                 EXEC spa_ErrorHandler @@ERROR,
                      'Book Properties',
                      'spa_books',
                      'DB Error',
                      'Failed to update book properties.',
                      ''
                 
                 ROLLBACK TRANSACTION
             END
             ELSE
             BEGIN
                 EXEC spa_ErrorHandler 0,
                      'Book Properties',
                      'spa_books',
                      'Success',
                      'Book properties successfully updated.',
                      ''
                 
                 COMMIT TRANSACTION
             END
         END
         
         -- 		insert into #temp_fas_books
         -- 	select 'c' as type,portfolio_hierarchy.entity_name as [entity_name],
         -- 	  fas_book_id, no_link, no_links_fas_eff_test_profile_id, gl_number_id_st_asset, gl_number_id_st_liab, gl_number_id_lt_asset, gl_number_id_lt_liab,
         --                        gl_number_id_item_st_asset, gl_number_id_item_st_liab, gl_number_id_item_lt_asset, gl_number_id_item_lt_liab, gl_number_id_aoci,
         --                       gl_number_id_pnl, gl_number_id_set, gl_number_id_cash, gl_number_id_inventory, gl_id_amortization,gl_id_interest,
         -- 		convert_uom_id,cost_approach_id
         -- 	from fas_books inner join portfolio_hierarchy on portfolio_hierarchy.entity_id=fas_books.fas_book_id
         -- 	where fas_book_id=@fas_book_id
         
         
         --exec spa_audit_trail '#temp_fas_books',@fas_book_id
     END
     ELSE 
     IF @flag = 'd'
     BEGIN
         IF EXISTS(
                SELECT TOP 1 1
                FROM   source_system_book_map WITH(NOLOCK)
                WHERE  fas_book_id = @fas_book_id
            )
         BEGIN
             EXEC spa_ErrorHandler -1,
                  'Book Properties',
                  'spa_books',
                  'DB Error',
                  'Source book mapping(s) in the selected book should be deleted first.',
                  ''
             
             RETURN
         END
         
        BEGIN TRY 
			BEGIN TRAN
			
				DELETE an FROM application_notes an 
					INNER JOIN fas_books fb  ON fb.fas_book_id = ISNULL(an.parent_object_id, an.notes_object_id)
				WHERE an.internal_type_value_id = 27
					AND fb.fas_book_id = @fas_book_id
				UPDATE en SET notes_object_id = NULL 			
				FROM email_notes en
					INNER JOIN fas_books fb  ON CAST(fb.fas_book_id AS VARCHAR(50)) = en.notes_object_id
				WHERE en.internal_type_value_id = 27
					AND fb.fas_book_id = @fas_book_id
			
				DELETE 
				FROM   fas_books
				WHERE  fas_book_id = @fas_book_id         
        
				DELETE 
				FROM   portfolio_hierarchy
				WHERE  entity_id = @fas_book_id
            
				EXEC spa_ErrorHandler 0,
							'Book Properties',
							'spa_books',
							'Success',
							'Changes have been saved successfully.',
							''
                 
			 COMMIT TRANSACTION 
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK

			EXEC spa_ErrorHandler -1,
				'Book Properties',
				'spa_books',
				'DB Error',
				'Failed to delete book properties.',
				''
                 
			ROLLBACK TRANSACTION
			
		END CATCH
     END
ELSE IF @flag = 'g'
BEGIN
	SELECT fs.gl_grouping_value_id gl_entry_grouping, fs.hedge_type_value_id accounting_type FROM dbo.portfolio_hierarchy ph 
	LEFT JOIN dbo.portfolio_hierarchy ph1 ON ph1.parent_entity_id = ph.entity_id
	LEFT JOIN fas_strategy fs ON fs.fas_strategy_id = ph.entity_id 
	--LEFT JOIN static_data_value sdv ON sdv.value_id = fs.gl_grouping_value_id
	WHERE ph1.entity_id = @fas_book_id--1473
END
ELSE IF @flag = 'h'
BEGIN
	SELECT fs.gl_grouping_value_id gl_entry_grouping, fs.hedge_type_value_id accounting_type FROM dbo.portfolio_hierarchy ph 
	LEFT JOIN dbo.portfolio_hierarchy ph1 ON ph1.parent_entity_id = ph.entity_id
	LEFT JOIN fas_strategy fs ON fs.fas_strategy_id = ph.entity_id 
	--LEFT JOIN static_data_value sdv ON sdv.value_id = fs.gl_grouping_value_id
	WHERE ph.entity_id = @fas_book_id--1473 -- here @fas_book_id is Strategy ID 
END
ELSE IF @flag = 'a'
BEGIN
	SELECT DISTINCT 
		ssbm.book_deal_type_map_id,
		ssbm.logical_name sub_book, 
		book.entity_name book,
		stra.entity_name strategy,
		sub.entity_name subsidiary
	FROM   portfolio_hierarchy book(NOLOCK)
		INNER JOIN Portfolio_hierarchy stra(NOLOCK)
			ON  book.parent_entity_id = stra.entity_id
		INNER JOIN Portfolio_hierarchy sub (NOLOCK)
			ON  stra.parent_entity_id = sub.entity_id
		INNER JOIN source_system_book_map ssbm
			ON  ssbm.fas_book_id = book.entity_id
	ORDER BY sub.entity_name, stra.entity_name , book.entity_name, ssbm.logical_name  ASC
END
GO