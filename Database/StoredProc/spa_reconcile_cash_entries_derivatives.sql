IF OBJECT_ID(N'spa_reconcile_cash_entries_derivatives', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_reconcile_cash_entries_derivatives]
 GO 
--
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--
CREATE PROCEDURE [dbo].[spa_reconcile_cash_entries_derivatives]
	@flag CHAR(1),
	@xmltext TEXT,
	@user_name VARCHAR(250) = NULL,
	@cash_settlement_id VARCHAR(200) = NULL
AS

DECLARE @sqlStmt VARCHAR(8000)
DECLARE @tempdetailtable  VARCHAR(128)
DECLARE @user_login_id    VARCHAR(100),
        @process_id       VARCHAR(50)

SET @user_login_id = dbo.FNADBUser()

SET @process_id = REPLACE(NEWID(), '-', '_')

SET @tempdetailtable = dbo.FNAProcessTableName('invoice_process', @user_login_id, @process_id)

SET  @sqlStmt='create table '+ @tempdetailtable+'(
     [source_deal_settlement_id] int NULL,
	 [source_deal_header_id] int  NULL ,    
	 [cash_received] float  NULL ,      
	 [description] varchar(500)  NULL,
     [as_of_date] datetime NULL,  
     [term_start] datetime NULL,
     [term_end] datetime NULL,
     [source_currency_id] INT NULL,
     [cash_settlement] float NULL,
     [cash_variance] float NULL
     
      
	)     
	'
	
	exec(@sqlStmt)

DECLARE @idoc int
DECLARE @doc varchar(1000)
DECLARE @sqlStmt1 varchar(5000)
DECLARE @sqlStmt2 varchar(5000)

exec sp_xml_preparedocument @idoc OUTPUT, @xmltext

SELECT * into #ztbl_xmlvalue
FROM   OPENXML (@idoc, '/Root/PSRecordset',2)
         WITH (
         source_deal_settlement_id varchar(500)	'@source_deal_cash_settlement_id',      
		 source_deal_header_id  int    '@source_deal_header_id',
		 cash_received varchar (100)    '@invoice_amount',
         description varchar(500)    '@description',
         counterparty_id int '@counterparty_id',
         as_of_date varchar(250) '@as_of_date',
         term_start varchar(250) '@term_start',
         term_end varchar(250) '@term_end',
         source_currency_id int '@source_currency_id',
         cash_settlement  varchar (100) '@und_pnl',
         cash_variance varchar(100) '@cash_variance'
       )





 --exec spa_reconcile_cash_entries_derivatives NULL,'<Root><PSRecordset  source_deal_header_id="578" description="test" invoice_amount="20" counterparty_name="Duke Energy" description1="NULL" as_of_date="2028-08-29" term_start="01-06-2005" term_end="30-06-2005" currency="USD" und_pnl="-113400"></PSRecordset></Root>'
--select @source_deal_header_id_temp=source_deal_header_id from source_deal_cash_settlement where source_deal_header_id in (select invoice_detail_id from #ztbl_xmlvalue)

		set @sqlStmt1 = 'UPDATE  source_deal_cash_settlement
                   
				    	    SET  
                                 source_deal_cash_settlement.as_of_date= CAST(NULLIF(B.as_of_date,''NULL'') AS DATEtIME),
                                 source_deal_cash_settlement.term_start= cast(B.term_start as datetime),
						         source_deal_cash_settlement.term_end= cast(B.term_end as datetime),
						         source_deal_cash_settlement.cash_settlement= B.cash_settlement,
                                 source_deal_cash_settlement.cash_received = NULLIF(B.cash_received,''NULL''), 
						         source_deal_cash_settlement.cash_variance=NULLIF( B.cash_variance,''NULL'') ,
						         source_deal_cash_settlement.source_currency_id= B.source_currency_id,
						         source_deal_cash_settlement.description= NULLIF(B.description,''NULL''),
								 source_deal_cash_settlement.update_user= dbo.FNADBUser(),
								 source_deal_cash_settlement.update_ts=getdate() 
										
						    FROM source_deal_cash_settlement A
						   INNER JOIN #ztbl_xmlvalue B ON
                                                          A.source_deal_header_id = B.source_deal_header_id and
                                                          A.term_start = cast(B.term_start as datetime) 
                                      
						   where NULLIF(B.cash_received,''NULL'') is not null'	
--	exec spa_print @sqlStmt1
    exec(@sqlStmt1)

			 
	set	@sqlStmt2 = 'INSERT  INTO source_deal_cash_settlement(source_deal_header_id,term_start,term_end,cash_settlement,cash_received,
							cash_variance,source_currency_id,description,as_of_date, create_user, create_ts)
            			SELECT
                           X.source_deal_header_id,
						   cast(X.term_start as datetime) as term_start,
						   cast(X.term_end as datetime) as  term_end,
						   X.cash_settlement,
                           NULLIF(X.cash_received,''NULL'') as cash_received,
	   					   X.cash_variance,
					       X.source_currency_id,
						   NULLIF(X.description,''NULL'') description,
						   cast(NULLIF(X.as_of_date,''NULL'')  as datetime) as as_of_date,
						   dbo.FNADBUser() create_user,
						   getdate()  create_ts
	
    				FROM   #ztbl_xmlvalue  X
				    LEFT OUTER JOIN  source_deal_cash_settlement Y   ON X.source_deal_header_id = Y.source_deal_header_id
				
                WHERE  NULLIF(X.source_deal_settlement_id,''NULL'') is NULL
                AND NULLIF(X.cash_received,''NULL'') is not null 
                 group by X.source_deal_header_id,X.term_start,X.term_end,X.cash_settlement,X.cash_received,X.cash_variance,X.source_currency_id,X.description,X.as_of_date' 

        --print(@sqlStmt2)
		exec(@sqlStmt2)

	Exec spa_ErrorHandler 0, "Cash Entries", 
					"spa_reconcile_cash_entries_derivatives", "Status",
					"Successfully saved cash entries.","Recommendation"
