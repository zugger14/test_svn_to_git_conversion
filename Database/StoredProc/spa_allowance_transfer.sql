/****** Object:  StoredProcedure [dbo].[spa_allowance_transfer]   * Author:Bikash Agrawal Date:7thOct2009*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_allowance_transfer]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_allowance_transfer]
GO
/****** Object:  StoredProcedure [dbo].[spa_allowance_transfer]    ************/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spa_allowance_transfer]
@sub_entity_id varchar(100),             		
@strategy_entity_id varchar(100) = NULL,             
@book_entity_id varchar(100) = NULL,    
@assignment_type_value_id int=NULL, 
@counterparty_id int = NULL,
@vintage_from  varchar(300)=NULL,
@vintage_to varchar(300)=NULL,
@batch_process_id varchar(50)=NULL,
@batch_report_param varchar(1000)=NULL


as

--exec spa_allowance_transfer NULL,NULL,NULL,5149,18,'2009-01-01','2009-12-31'


DECLARE @Sql_Select Varchar(5000)
DECLARE @Sql_Where Varchar(5000)


--******************************************************            
--CREATE source book map table and build index            
--*********************************************************            
SET @sql_Where = ''  
CREATE TABLE #ssbm(            
 source_system_book_id1 int,            
 source_system_book_id2 int,            
 source_system_book_id3 int,            
 source_system_book_id4 int,            
 fas_deal_type_value_id int,            
 book_deal_type_map_id int,            
 fas_book_id int,            
 stra_book_id int,            
 sub_entity_id int            
)            
----------------------------------            
SET @Sql_Select=            
'INSERT INTO #ssbm            
SELECT            
 source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,fas_deal_type_value_id,            
  book_deal_type_map_id,book.entity_id fas_book_id,book.parent_entity_id stra_book_id, stra.parent_entity_id sub_entity_id             
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
IF @sub_entity_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND stra.parent_entity_id IN  ( ' + @sub_entity_id + ') '             
 IF @strategy_entity_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))'            
 IF @book_entity_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_entity_id + ')) '            
SET @Sql_Select=@Sql_Select+@Sql_Where            
EXEC (@Sql_Select)            
--------------------------------------------------------------            
CREATE  INDEX [IX_PH1] ON [#ssbm]([source_system_book_id1])                  
CREATE  INDEX [IX_PH2] ON [#ssbm]([source_system_book_id2])                  
CREATE  INDEX [IX_PH3] ON [#ssbm]([source_system_book_id3])                  
CREATE  INDEX [IX_PH4] ON [#ssbm]([source_system_book_id4])                  
CREATE  INDEX [IX_PH5] ON [#ssbm]([fas_deal_type_value_id])                  
CREATE  INDEX [IX_PH6] ON [#ssbm]([fas_book_id])                  
CREATE  INDEX [IX_PH7] ON [#ssbm]([stra_book_id])                  
CREATE  INDEX [IX_PH8] ON [#ssbm]([sub_entity_id])                  
            
--******************************************************            
--End of source book map table and build index            
--*********************************************************   


DECLARE @str_batch_table varchar(max)        
SET @str_batch_table = ''        
IF @batch_process_id IS NOT NULL        
	SELECT @str_batch_table = dbo.FNABatchProcess('s', @batch_process_id ,@batch_report_param, NULL, NULL, NULL)

DECLARE @sql Varchar (max)

set @sql='select
 sc.counterparty_name AS [SellAcct],
 sc1.counterparty_name [BuyAcct],
 ''NA'' AS SellAAR,
 ''NA'' AS BuyAAR,
 ''N'' AS Perpetuity,
 assign.compliance_year as [AllwYear],
 assign.cert_from as [SerStart],
 assign.cert_to as [SerEnd]
' + @str_batch_table + '
FROM
 source_deal_header sdh 
 INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id
 INNER JOIN assignment_audit assign ON assign.source_deal_header_id_from=sdd.source_deal_detail_id
 INNER JOIN source_counterparty sc ON sc.source_counterparty_id=sdh.counterparty_id
 INNER JOIN source_deal_detail sdd1 ON sdd1.source_deal_detail_id=assign.source_deal_header_id
 INNER JOIN source_deal_header sdh1 ON sdh1.source_deal_header_id=sdd1.source_deal_header_id
 INNER JOIN source_counterparty sc1 ON sc1.source_counterparty_id=sdh1.counterparty_id
INNER JOIN #ssbm ssbm            
ON sdh.source_system_book_id1=ssbm.source_system_book_id1             
AND sdh.source_system_book_id2=ssbm.source_system_book_id2             
AND sdh.source_system_book_id3=ssbm.source_system_book_id3             
AND sdh.source_system_book_id4=ssbm.source_system_book_id4  
WHERE
assign.assigned_volume>0 '


if @assignment_type_value_id is not null
	set @sql=@sql+ ' and assign.assignment_type='+ cast(@assignment_type_value_id as varchar)
if @counterparty_id is not null
	set @sql=@sql+ ' and (sdh.counterparty_id='+ cast(@counterparty_id as varchar) +' OR sdh1.counterparty_id='+ cast(@counterparty_id as varchar) +')'

if @vintage_from is not null
	set @sql=@sql+ ' and sdd.term_start>=convert(datetime,'''+@vintage_from+''', 102)'

if @vintage_to is not null
	set @sql=@sql+ ' and sdd.term_end<=convert(datetime,'''+@vintage_to+''', 102)'

set @sql=@sql + 'order by  sc.counterparty_name, sc1.counterparty_name,  assign.compliance_year'
EXEC spa_print @sql
exec(@sql)


   


--*****************FOR BATCH PROCESSING**********************************      
    

IF  @batch_process_id IS NOT NULL        
BEGIN        
 SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)         
 EXEC(@str_batch_table)        
 
 DECLARE @report_name varchar(100)
 SET @report_name = 'Allowance Transfer Report'        
        
 SELECT @str_batch_table=dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_allowance_transfer', @report_name)         
 EXEC(@str_batch_table)        
 
END
   
--********************************************************************  


