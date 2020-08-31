/****** Object:  StoredProcedure [dbo].[spa_bid_offer_formulator_detail]    Script Date: 07/28/2009 17:59:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_bid_offer_formulator_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_bid_offer_formulator_detail]
/****** Object:  StoredProcedure [dbo].[spa_bid_offer_formulator_detail]    Script Date: 07/28/2009 17:59:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec spa_bid_offer_formulator_detail 'a',1
--exec spa_bid_offer_formulator_detail 's',1
--exec spa_bid_offer_formulator_detail 's',1
--exec spa_bid_offer_formulator_detail 's',1

--exec spa_bid_offer_formulator_detail 's',NULL,1

CREATE procedure [dbo].[spa_bid_offer_formulator_detail]
    @flag char(1),
    @bid_offer_detail_id INT = NULL,
    @bid_offer_id INT =NULL,
    @block_id INT = NULL,
    @volume_formula_id INT = NULL,
    @price_formula_id INT = NULL
AS 
    IF @flag = 'i' 
        BEGIN
            INSERT  INTO bid_offer_formulator_detail
                    ( bid_offer_id,
                      block_id,
                      volume_formula_id,
                      price_formula_id
                    )
            VALUES  (
                      @bid_offer_id,
                      @block_id,
                      @volume_formula_id,
                      @price_formula_id                                                          
                    )
	
        END
    ELSE 
        IF @flag = 'u' 
            BEGIN
                UPDATE  bid_offer_formulator_detail
                SET     bid_offer_id = @bid_offer_id,
                        block_id = @block_id,
                        volume_formula_id = @volume_formula_id,
                        price_formula_id = @price_formula_id
                WHERE   bid_offer_detail_id = @bid_offer_detail_id
            END
        ELSE 
            IF @flag = 'd' 
                BEGIN
                    DELETE  bid_offer_formulator_detail
                    WHERE   bid_offer_detail_id = @bid_offer_detail_id
                END
            ELSE 
                IF @flag = 's' 
                    BEGIN  
                    SELECT  
							DISTINCT bid_offer_detail_id [Bid Offer Detail ID],
							block_id [Block ID],
							case fe.formula_type when  'n' then 'Nested Formula' else [dbo].[FNAFormulaFormat](fe.formula,'r') end [Volume Formula],
							case fe1.formula_type when   'n'  then 'Nested Formula' else [dbo].[FNAFormulaFormat](fe1.formula,'r') end [Price Formula]
							--[dbo].[FNAFormulaFormat](fe.formula,'r') [Volume Formula],
							--[dbo].[FNAFormulaFormat](fe1.formula,'r') [Price Formula],
							

							FROM    bid_offer_formulator_detail bofd
							LEFT  JOIN formula_editor fe ON fe.formula_id = bofd.volume_formula_id
							LEFT  JOIN formula_editor fe1 ON fe1.formula_id = bofd.price_formula_id
							LEFT  JOIN bid_offer_formulator_header bofh ON bofh.bid_offer_id = bofd.bid_offer_id
							WHERE bofd.bid_offer_id = @bid_offer_id

                    END
                ELSE 
						IF @flag = 'a' 
	                      BEGIN
							SELECT
							DISTINCT 
							bofd.bid_offer_id ,
							bofd.block_id,
							bofd.volume_formula_id,
							bofd.price_formula_id,
							case fe.formula_type when  'n' then 'Nested Formula' else [dbo].[FNAFormulaFormat](fe.formula,'r') end [Volume Formula],
							case fe1.formula_type when   'n'  then 'Nested Formula' else [dbo].[FNAFormulaFormat](fe1.formula,'r') end [Price Formula],
							--[dbo].[FNAFormulaFormat](fe.formula,'r') [Volume Formula],
							--[dbo].[FNAFormulaFormat](fe1.formula,'r') [Price Formula],
							fe.formula_type
							,fe1.formula_type
							FROM    bid_offer_formulator_detail bofd
							LEFT  JOIN formula_editor fe ON fe.formula_id = bofd.volume_formula_id
							LEFT  JOIN formula_editor fe1 ON fe1.formula_id = bofd.price_formula_id
							LEFT  JOIN bid_offer_formulator_header bofh ON bofh.bid_offer_id = bofd.bid_offer_id
							WHERE   bid_offer_detail_id = @bid_offer_detail_id
						END




