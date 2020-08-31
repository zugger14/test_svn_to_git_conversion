IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_bid_offer_formulator_header]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_bid_offer_formulator_header]
GO
--exec spa_bid_offer_formulator_header 's'
CREATE procedure [dbo].[spa_bid_offer_formulator_header]
@flag char(1),
@bid_offer_id INT=NULL, 
@name VARCHAR(200)=NULL,
@description VARCHAR(200)=NULL,
@product_type_id INT=NULL,
@bid_offer_flag CHAR(1)=NULL
AS
    IF @flag = 'i' 
        BEGIN
            INSERT  INTO bid_offer_formulator_header
                       ([name]
					   ,[description]
					   ,[product_type_id]
					   ,[bid_offer_flag])
             VALUES  (
                      @name,
                      @description,
                      @product_type_id,
                      @bid_offer_flag                                                          
                    )
	
        END
    ELSE 
        IF @flag = 'u' 
            BEGIN
                UPDATE  bid_offer_formulator_header
                SET     
					[name]=@name,
					description = @description,
					product_type_id = @product_type_id,
					bid_offer_flag = @bid_offer_flag 
						
                WHERE   bid_offer_id = @bid_offer_id
            END
        ELSE 
            IF @flag = 'd' 
                BEGIN
                    DELETE  bid_offer_formulator_header
                    WHERE   bid_offer_id = @bid_offer_id
                END
            ELSE 
                IF @flag = 's' 
                    BEGIN
						SELECT  
						 bofh.bid_offer_id [Bid Offer ID]
						,bofh.[name] [Name]
						,bofh.description [Description]
						,sdv.code AS ProductType,
						CASE WHEN bid_offer_flag='b' THEN 'Bid' WHEN bid_offer_flag = 'o' THEN 'Offer' END  [Bid/Offer]
						FROM bid_offer_formulator_header bofh
						INNER JOIN static_data_value sdv ON sdv.value_ID = bofh.product_type_id 

                    END
                    ELSE IF @flag = 'a' 
                    BEGIN
                        SELECT  
							name,
							description,
							product_type_id,
							bid_offer_flag  
                        FROM    bid_offer_formulator_header
                        WHERE 
								bid_offer_id = @bid_offer_id
                    END

