SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID('[dbo].[TRGUPD_FAS_BOOKS]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_FAS_BOOKS]
GO

CREATE TRIGGER [dbo].[TRGUPD_FAS_BOOKS]
ON [dbo].[fas_books]
FOR  UPDATE
AS
	UPDATE FAS_BOOKS
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	WHERE  FAS_BOOKS.fas_book_id IN (SELECT fas_book_id
	                                 FROM   DELETED)
	
	IF NOT UPDATE (create_user) AND NOT UPDATE (create_ts)
	INSERT INTO fas_books_audit
	  (
	    [fas_book_id],
	    [no_link],
	    [no_links_fas_eff_test_profile_id],
	    [gl_number_id_st_asset],
	    [gl_number_id_st_liab],
	    [gl_number_id_lt_asset],
	    [gl_number_id_lt_liab],
	    [gl_number_id_item_st_asset],
	    [gl_number_id_item_st_liab],
	    [gl_number_id_item_lt_asset],
	    [gl_number_id_item_lt_liab],
	    [gl_number_id_aoci],
	    [gl_number_id_pnl],
	    [gl_number_id_set],
	    [gl_number_id_cash],
	    [gl_number_id_inventory],
	    [gl_number_id_expense],
	    [gl_number_id_gross_set],
	    [gl_id_amortization],
	    [gl_id_interest],
	    [convert_uom_id],
	    [cost_approach_id],
	    [gl_id_st_tax_asset],
	    [gl_id_st_tax_liab],
	    [gl_id_lt_tax_asset],
	    [gl_id_lt_tax_liab],
	    [gl_id_tax_reserve],
	    [user_action],
	    [update_user],
	    [update_ts],
	    [legal_entity],
	    [tax_perc],
	    hedge_item_same_sign,
	    fun_cur_value_id
	  )
	SELECT [fas_book_id],
	       [no_link],
	       [no_links_fas_eff_test_profile_id],
	       [gl_number_id_st_asset],
	       [gl_number_id_st_liab],
	       [gl_number_id_lt_asset],
	       [gl_number_id_lt_liab],
	       [gl_number_id_item_st_asset],
	       [gl_number_id_item_st_liab],
	       [gl_number_id_item_lt_asset],
	       [gl_number_id_item_lt_liab],
	       [gl_number_id_aoci],
	       [gl_number_id_pnl],
	       [gl_number_id_set],
	       [gl_number_id_cash],
	       [gl_number_id_inventory],
	       [gl_number_id_expense],
	       [gl_number_id_gross_set],
	       [gl_id_amortization],
	       [gl_id_interest],
	       [convert_uom_id],
	       [cost_approach_id],
	       [gl_id_st_tax_asset],
	       [gl_id_st_tax_liab],
	       [gl_id_lt_tax_asset],
	       [gl_id_lt_tax_liab],
	       [gl_id_tax_reserve],
	       'Update',
	       dbo.FNADBUser(),
	       GETDATE(),
	       [legal_entity],
	       [tax_perc],
	       hedge_item_same_sign,
	       fun_cur_value_id
	FROM   INSERTED
