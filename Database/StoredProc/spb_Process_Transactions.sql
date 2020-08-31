
IF OBJECT_ID('[dbo].[spb_Process_Transactions]') IS NOT null
DROP PROC [dbo].[spb_Process_Transactions]
GO
 
CREATE PROC [dbo].[spb_Process_Transactions]  @user varchar(100),   
  
         @table_name varchar(100) = NULL,      
        @gis_recon varchar(1) = 'n',
	@show_messageboard CHAR(1)='y'      
AS      


SET NOCOUNT ON      
-- 
-- drop table #transactions
-- drop table  #transactions_update
-- drop table #transactions_detail
-- drop table #temp_error
-- --drop table #unique_id
-- drop table #temp_trans
--    DECLARE @user varchar(100)      
--    DECLARE @table_name varchar(100)      
--    DECLARE @gis_recon varchar(1)   	
--    DECLARE @show_messageboard CHAR(1)	    
--    set @user = 'farrms_admin'      
--   	set 	@table_name ='adiha_process.dbo.reduction_deals_C5BF3646_7F80_4322_916A_A5DE2A20CF8D'
-- 	--set @table_name='Transactions'
--    set  @show_messageboard='n'
DECLARE @active int      
DECLARE @inactive int      
--set processID      
Declare @process_id varchar(100)      
Declare @job_name varchar (100)      
DECLARE @structure_deal_id int

      
	
SET @process_id = REPLACE(newid(),'-','_')      
SET @job_name = 'Process_Deal_CSV'       
	      
      
SET @active = NULL --Earn Bonus      
SET @inactive = 5170 --InActive      
      
--GIS RECONCILLATION      
IF isnull(@gis_recon, 'n') = 'y'      
BEGIN      
 SET @active = 5177 --Earn Bonus - GIS Recon      
 SET @inactive = 5179 --InActive - GIS Recon      
END      
      
Declare @gis_id int 
SET @gis_id=5164

CREATE TABLE [#Transactions] (
 [ID] int identity,	      
 [Book] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,      
 [Feeder System ID] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,      
 [Gen Date From] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,      
 [Gen Date To] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,      
 [Counterparty] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,      
 [Generator] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,      
 [Deal Type] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,      
 [Deal Sub Type] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,      
 [Trader] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,      
 [Broker] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,      
 [Deal Date] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,      
 [Category] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL,
 [buy_sell_flag] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL,       
)

CREATE TABLE [#Transactions_detail] (
 [ID] int identity,	      
 [Feeder System ID] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,      
 [Volume] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,      
 [UOM] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,      
 [Price] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,      
 [Formula] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,      
 [Index] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,      
 [Frequency] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,      
 [Currency] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,      
 [buy_sell_flag] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL,
 [leg] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL,
 [Gen Date From] varchar(100) COLLATE DATABASE_DEFAULT,
 [Gen Date To] varchar(100) COLLATE DATABASE_DEFAULT,
 [he] varchar (100) COLLATE DATABASE_DEFAULT,
 [settlement_volume] varchar(255) COLLATE DATABASE_DEFAULT,
 [settlement_uom] varchar(255) COLLATE DATABASE_DEFAULT	
)
      
CREATE TABLE #temp_trans (
	[Book] [nvarchar] (255) COLLATE DATABASE_DEFAULT  NULL ,
	[Feeder_System_ID] [nvarchar] (255) COLLATE DATABASE_DEFAULT  NULL ,
	[Gen_Date_From] [varchar] (50) COLLATE DATABASE_DEFAULT  NULL ,
	[Gen_Date_To] [varchar] (50) COLLATE DATABASE_DEFAULT  NULL ,
	[Volume] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,
	[UOM] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,
	[Price] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,
	[Formula] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,
	[Counterparty] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,
	[Generator] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,
	[Deal_Type] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,
	[Deal_Sub_Type] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,
	[Trader] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,
	[Broker] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,
	[Rec_Index] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,
	[Frequency] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,
	[Deal_Date] [varchar] (50) COLLATE DATABASE_DEFAULT  NULL ,
	[Currency] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,
	[Category] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,
	[buy_sell_flag] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,
	[leg] [varchar] (255) COLLATE DATABASE_DEFAULT  NULL ,
	[settlement_volume] varchar(255) COLLATE DATABASE_DEFAULT,
	[settlement_uom] varchar(255) COLLATE DATABASE_DEFAULT	
) 

--exec('insert into  #temp_trans select * from '  + @table_name )


exec('insert into  #temp_trans ([Book],
	[Feeder_System_ID] ,
	[Gen_Date_From],
	[Gen_Date_To] ,
	[Volume] ,
	[UOM],
	[Price] ,
	[Formula] ,
	[Counterparty],
	[Generator] ,
	[Deal_Type]  ,
	[Deal_Sub_Type] ,
	[Trader] ,
	[Broker]  ,
	[Rec_Index] ,
	[Frequency] ,
	[Deal_Date] ,
	[Currency] ,
	[Category],
	[buy_sell_flag],
	[leg],
	[settlement_volume] ,
	[settlement_uom])
	 select [Book],	[Feeder_System_ID] ,	[Gen_Date_From],	[Gen_Date_To] ,	[Volume] ,
	[UOM],	[Price] ,	[Formula] ,	[Counterparty],	[Generator] ,	[Deal_Type]  ,
	[Deal_Sub_Type] ,	[Trader] ,	[Broker]  ,	[Rec_Index] ,	[Frequency] ,
	[Deal_Date] ,	[Currency] ,	[Category],	[buy_sell_flag],
	[leg] ,	[settlement_volume] ,	[settlement_uom]
	 from '  + @table_name )
	 
--############ Check Blank Feeder System ID
	INSERT INTO [Import_Transactions_Log]       
	 (      
	 [process_id] ,      
	 [code],      
	 [module],      
	 [source],      
	 [type] ,      
	 [description],      
	 [nextsteps])      
	 
	SELECT     @process_id, 'Error', 'Import Transactions', 'Run Import' ,
	 'Data Errors', 'Blank Feeder System ID is found',
	'.Please fix error and import again'  			
	FROM   #temp_trans where [Feeder_System_ID] is null

--################## Check Trader  BLANK
	INSERT INTO [Import_Transactions_Log]       
	 (      
	 [process_id] ,      
	 [code],      
	 [module],      
	 [source],      
	 [type] ,      
	 [description],      
	 [nextsteps])      
	 
	SELECT     @process_id, 'Error', 'Import Transactions', 'Run Import' ,
	 'Data Errors', 'Blank Trader is found',
	'.Please fix error and import again'  			
	FROM   #temp_trans where Trader is null

--################## Check Generator  BLANK
	INSERT INTO [Import_Transactions_Log]       
	 (      
	 [process_id] ,      
	 [code],      
	 [module],      
	 [source],      
	 [type] ,      
	 [description],      
	 [nextsteps])      
	 
	SELECT     @process_id, 'Error', 'Import Transactions', 'Run Import' ,
	 'Data Errors', 'Blank Generator is found',
	'.Please fix error and import again'  			
	FROM   #temp_trans where generator is null
--################## Check Counterparty  BLANK

-- 	INSERT INTO [Import_Transactions_Log]       
-- 	 (      
-- 	 [process_id] ,      
-- 	 [code],      
-- 	 [module],      
-- 	 [source],      
-- 	 [type] ,      
-- 	 [description],      
-- 	 [nextsteps])      
-- 	 
-- 	SELECT     @process_id, 'Error', 'Import Transactions', 'Run Import' ,
-- 	 'Data Errors', 'Blank Counterparty is found',
-- 	'.Please fix error and import again'  			
-- 	FROM   #temp_trans where counterparty is null
-- 
--##### Remove all the Error from Temp
	delete #temp_trans where [Feeder_System_ID] is null or Trader is null or
		 generator is null 


--First get the Transactions data into a temp table      
 EXEC('INSERT INTO #Transactions(Book,[Feeder System ID],[Gen Date From],[Gen Date To],
	Counterparty,Generator,[Deal Type],[Deal Sub Type],Trader,Broker,[Deal Date],
	Category,buy_sell_flag
	)            
 Select max(Book),[Feeder_System_ID],min([Gen_Date_From]),max([Gen_Date_To]),
	max(Counterparty),max(Generator),max([Deal_Type]),max([Deal_Sub_Type]),max(Trader),max(Broker),max([Deal_Date]),
	max(Category),max(buy_sell_flag)
 FROM         #temp_trans group by [Feeder_System_ID] ' )      

 EXEC('INSERT INTO #Transactions_detail([Feeder System ID],
	Volume,UOM,Price,Formula,[Index],[Frequency],
	Currency,buy_sell_flag,leg,[Gen Date From],[Gen Date To],he,settlement_volume,settlement_uom
	)            
 Select [Feeder_System_ID],
	Volume,UOM,Price,Formula,[Rec_Index],[Frequency],
	Currency,buy_sell_flag,leg,[Gen_Date_From],[Gen_Date_To],case when (isnull(datepart(hh, [Gen_Date_To]), 0) = 0) then 0 else cast(datepart(hh, [Gen_Date_To]) as varchar) end,
	settlement_volume,settlement_uom       
 FROM        #temp_trans Ts ' )      


CREATE  INDEX [IX_Trans1] ON [#Transactions]([Generator])      
CREATE  INDEX [IX_Trans5] ON [#Transactions]([Deal Type])      
CREATE  INDEX [IX_Trans6] ON [#Transactions]([Feeder System ID])      
CREATE  INDEX [IX_Trans8] ON [#Transactions]([Counterparty])      
CREATE  INDEX [IX_Trans9] ON [#Transactions]([Book])      
CREATE  INDEX [IX_Trans10] ON [#Transactions]([Deal Sub Type])      
CREATE  INDEX [IX_Trans11] ON [#Transactions]([Trader])      
CREATE  INDEX [IX_Trans12] ON [#Transactions]([Broker])      


-----------------
--*******************************************************
--ADDED for Forward Transactions

DECLARE       
 @source_deal_header_id [int],      
 @source_system_id [int],      
 @deal_id [varchar] (50),      
-- @deal_date [datetime],      
 @ext_deal_id [varchar] (50),       
 @physical_financial_flag [char] (10),      
 @structured_deal_id [varchar] (50),      
 @counterparty_id [int],      
 @entire_term_start [datetime],      
 @entire_term_end [datetime],      
 @source_deal_type_id [int],      
 @deal_sub_type_type_id [int],      
 @option_flag [char] (1) ,      
 @option_type [char] (1),      
 @option_excercise_type [char] (1),      
 @source_system_book_id1 [int] ,      
 @source_system_book_id2 [int] ,      
 @source_system_book_id3 [int] ,      
 @source_system_book_id4 [int] ,      
 @description1 [varchar] (100) ,      
 @description2 [varchar] (50) ,      
 @description3 [varchar] (50) ,      
 @deal_category_value_id [int] ,      
 @trader_id [int],      
 @internal_deal_type_value_id [int],      
 @internal_deal_subtype_value_id [int],      
 @template_id [int] ,      
 @header_buy_sell_flag [varchar] (1),      
 @source_curve_def_id [int] ,      
 @generator_id [int],      
 @price [float],      
 @source_uom_id [int] ,      
 @broker_id [int] ,      
 @no_of_deals [int],      
 @deal_volume [int],      
 @max_deal_volume [int],      
 @leg [int],      
 @fixed_float_leg [char] (1),      
 @fixed_price_currency_id [int],      
 @option_strike_price [float],      
 @deal_volume_frequency [char] (1),      
 @block_description [varchar] (100),      
 @deal_detail_description [varchar] (100),      
 @formula_id [int],      
 @value_id [int],      
 @gis_value_id [int],      
 @gis_cert_date [datetime],      
 @user_id [varchar] (50),      
 @as_of_date [datetime],      
 @user_name [varchar] (50),      
 @url [varchar] (500),      
 @url_desc [varchar] (50),      
 @urlP [varchar] (50),      
 @desc [varchar] (5000),      
 @initial_deal_id int,      
 @deal_id_separator char(1),      
 @source_deal_type_id_I INT,      
 @source_deal_sub_type_id_I INT,      
 @source_trader_id_I INT,      
 @source_broker_id_I INT,      
 @Frequency_I VARCHAR(1),      
 @source_currency_id_I INT,      
 @category_id_I INT,      
 @buy_sell_flag_I VARCHAR(1),      
 @he VARCHAR(50),      
 @he_i INT,      
 @volume float      
      
      
--standard units and deal types used      
DECLARE @std_deal_uom_id int,      
 @std_rec_deal_type_id int,      
 @std_rec_energy_deal_type_id int      
      
set @std_deal_uom_id = 24      
--set @std_rec_deal_type_id = 55      
--set @std_rec_energy_deal_type_id = 53      
     
      
SET @deal_id_separator = '^'      
SET @user_id = @user      
SET @as_of_date = getdate()      
SET @source_system_id=2      
SET @physical_financial_flag='f'      
SET @source_deal_type_id = @std_rec_energy_deal_type_id --53      
SET @deal_sub_type_type_id=NULL      
SET @option_flag='n'      
SET @option_type=NULL      
SET @option_excercise_type=NULL      
SET @source_system_book_id2=-2      
SET @source_system_book_id3=-3      
SET @source_system_book_id4=-4      
SET @deal_category_value_id=475      
SET @trader_id=4      
SET @internal_deal_type_value_id=4      
SET @internal_deal_subtype_value_id=NULL      
SET @template_id=NULL      
SET @header_buy_sell_flag='b'      
SET @broker_id=NULL      
SET @leg = 1      
SET @fixed_float_leg = 't'      
SET @fixed_price_currency_id =2      
SEt @option_strike_price =0      
SET @deal_volume_frequency ='h'      
SET @block_description =NULL      
SET @deal_detail_description =NULL      
SEt @formula_id =NULL      
SET @he = NULL      
      


--********** Check if forward deal and group exists 
CREATE TABLE #temp_error
(
	deal_id varchar(100) COLLATE DATABASE_DEFAULT,
	source_deal_header_id int
)
--------------------------------------------
INSERT INTO #temp_error
	select a.[feeder system id],NULL
	from [#transactions_detail] a,
	(select max(deal_id) deal_id,ext_deal_id,sum(deal_volume/ISNULL(rg.auto_assignment_per,1)) volume 
	from source_deal_header sd inner join source_deal_detail sdd on
	sd.source_deal_header_id=sdd.source_deal_header_id
	inner join rec_generator rg on
        sd.generator_id=rg.generator_id
	where 	ext_deal_id is not null group by ext_deal_id
	) b
		
where
	(a.[feeder system id]=b.deal_id)
 	AND	a.volume<b.volume 

----------------------------------------------------------------------------	


INSERT INTO [Import_Transactions_Log]       
	 (      
	 [process_id] ,      
	 [code],      
	 [module],      
	 [source],      
	 [type] ,      
	 [description],      
	 [nextsteps])      
	      
	SELECT     @process_id, 'Error', 'Import Transactions', 'Run Import' ,
	 'Data Errors', 'Deal volume for deal '+TS.[feeder system id]+' is less than before',
	'.Please fix error and import again'  			
	FROM   #Transactions Ts INNER JOIN      
	       #temp_error temps  ON 
	      (TS.[feeder system id]=temps.deal_id) 

----------------------------------------------------------------------------
DELETE FROM #Transactions  
	where [feeder system id] in
(SELECT [deal_id] from #temp_error) 

------------------------------------------------------------------------	
--UPDATE source_deal_header if any of the input columns have changed

UPDATE source_deal_header     
SET
	deal_date =CHG.A ,      
	counterparty_id =CHG.B,      
	entire_term_start = CHG.C,      
	entire_term_end =CHG.D,      
	source_system_book_id1 =CHG.E,      
	source_deal_type_id = CHG.I,      
	deal_sub_type_type_id = CHG.J,      
	deal_category_value_id = CHG.K,      
	trader_id = CHG.L,      
	header_buy_sell_flag = CHG.M,      
	broker_id = CHG.N ,
	generator_id=CHG.generator_id      
--deal rec properties

FROM source_deal_header SD      
INNER JOIN      
(
SELECT 
   sd.source_deal_header_id,       
   ISNULL(Ts.[Deal Date], dbo.FNAGetSQLStandardDate(Ts.[Gen Date From])) A,       
   ISNULL(SC.source_counterparty_id , RG.ppa_counterparty_id ) B,       
   dbo.FNAGetSQLStandardDate(Ts.[Gen Date From]) C,       
   dbo.FNAGetSQLStandardDate(Ts.[Gen Date To]) D,       
   SB.source_book_id E,       
   SDTYPE.source_deal_type_id I,      
   SDSTYPE.source_deal_type_id J,      
   ISNULL(CAT.value_id, @deal_category_value_id) K,      
   ISNULL(STRADER.source_trader_id, @trader_id) L,      
   Ts.buy_sell_flag M,      
   ISNULL(SBROKER.source_broker_id, @broker_id) N,
--dealdetail   
--deal rec properties      
  RG.generator_id       

  FROM         #Transactions Ts (NOLOCK)      
  INNER JOIN source_deal_header sd (NOLOCK)      
   ON TS.[Feeder System ID] = sd.deal_id
   LEFT OUTER JOIN      
                        source_counterparty SC (NOLOCK)      
   ON Ts.Counterparty = SC.counterparty_id OR Ts.Counterparty = cast(SC.source_counterparty_id as varchar)      
    INNER JOIN      
                         source_book SB (NOLOCK)      
    ON Ts.Book = SB.source_system_book_id       
   INNER JOIN      
                        rec_generator RG (NOLOCK)      
   ON Ts.Generator = RG.code OR Ts.Generator = cast(RG.generator_id as varchar)      
   LEFT OUTER JOIN -- SDTYPE.source_deal_type_id PK      
                        source_deal_type SDTYPE (NOLOCK)      
   ON Ts.[Deal Type] = SDTYPE.deal_type_id OR Ts.[Deal Type] = cast(SDTYPE.source_deal_type_id as varchar)      
   LEFT OUTER JOIN -- SDSTYPE.source_deal_type_id PK      
                        source_deal_type SDSTYPE (NOLOCK)      
   ON Ts.[Deal Sub Type] = SDSTYPE.deal_type_id OR Ts.[Deal Sub Type] = cast(SDSTYPE.source_deal_type_id as varchar)      
   LEFT OUTER JOIN -- CAT.value_id PK      
                        static_data_value CAT (NOLOCK)      
   ON Ts.Category = CAT.code OR Ts.Category = cast(CAT.value_id as varchar)      
   LEFT OUTER JOIN -- STRADER.source_trader_id PK      
                        source_traders STRADER (NOLOCK)      
   ON Ts.Trader = STRADER.trader_id OR Ts.Trader = cast(STRADER.source_trader_id as varchar)      
   LEFT OUTER JOIN -- SBROKER.source_broker_id PK      
                        source_brokers SBROKER (NOLOCK)      
   ON Ts.Broker = SBROKER.broker_id OR Ts.Broker = cast(SBROKER.source_broker_id as varchar)      
--del detail
       
 --deal rec properties
  WHERE       
    ISNULL(SD.deal_date,'') <> ISNULL(Ts.[Deal Date],'')      
   OR(SD.deal_date <> dbo.FNAGetSQLStandardDate(Ts.[Gen Date From]) AND sd.deal_date IS NULL)      
   OR ISNULL(SD.counterparty_id,'') <> ISNULL(SC.source_counterparty_id,'')       
   OR (ISNULL(SD.counterparty_id,'') <>ISNULL(RG.ppa_counterparty_id,'') AND SC.source_counterparty_id IS NULL)      
   OR ISNULL(SD.entire_term_start,'')<>dbo.FNAGetSQLStandardDate(Ts.[Gen Date From])      
   OR SD.entire_term_end <> dbo.FNAGetSQLStandardDate(Ts.[Gen Date To])      
   OR ISNULL(SD.source_system_book_id1,'') <>ISNULL(SB.source_book_id,'')      
   --OR SD.description1 <> Ts.Volume       
   OR ISNULL(SD.source_deal_type_id,'') <>ISNULL(SDTYPE.source_deal_type_id,'')      
   OR (ISNULL(SD.source_deal_type_id,'')<>ISNULL(@source_deal_type_id,'') AND SDTYPE.source_deal_type_id IS NULL)      
   OR ISNULL(SD.deal_sub_type_type_id,'')<>ISNULL(SDSTYPE.source_deal_type_id,'')      
   OR (ISNULL(SD.deal_sub_type_type_id,'')<>ISNULL(@deal_sub_type_type_id,'') AND SDSTYPE.source_deal_type_id IS NULL)      
   OR ISNULL(SD.deal_category_value_id,'') <>ISNULL(CAT.value_id,'')      
   OR (ISNULL(SD.deal_category_value_id,'') <>ISNULL(@deal_category_value_id,'') AND CAT.value_id IS NULL)      
   OR ISNULL(SD.trader_id,'') <>ISNULL(STRADER.source_trader_id,'')      
   OR (ISNULL(SD.trader_id,'') <> ISNULL(@trader_id,'') AND STRADER.source_trader_id IS NULL)      
   OR ISNULL(SD.header_buy_sell_flag,'') <>ISNULL(Ts.buy_sell_flag,'')      
   OR ISNULL(sd.broker_id,'') <>ISNULL(SBROKER.source_broker_id,'')      
   OR (ISNULL(sd.broker_id,'') <>ISNULL(@broker_id,'') AND SBROKER.source_broker_id IS NULL)OR
--deal detail  
--deal rec Properties
   SD.generator_id <> RG.generator_id      
   OR (SD.generator_id IS NULL AND RG.generator_id IS NOT NULL)      
   OR (SD.generator_id IS NOT NULL AND RG.generator_id IS NULL)      
 ) CHG      
ON SD.source_deal_header_id = CHG.source_deal_header_id
--where SD.buy_sell_flag='b'      
--------------------------------------------------------------------------------------
-- update detail if exists

UPDATE 
	source_deal_detail
set
	term_start = CHG.O,      
	term_end =CHG.P,      
	contract_expiration_date = CHG.O,      
	curve_id = CHG.Q,      
	fixed_price = CHG.R,      
	deal_volume_uom_id = CHG.S,      
	buy_sell_flag = CHG.T,      
	fixed_price_currency_id = CHG.U,      
	deal_volume =CHG.V,
	deal_volume_frequency = CHG.W,
	[deal_detail_description]=CHG.he,                      
        [settlement_volume]=CHG.settlement_volume,
	[settlement_uom]=CHG.settlement_uom

FROM source_deal_detail SD      
INNER JOIN      
(
SELECT 
  sd.source_deal_header_id,       
  dbo.FNAGetSQLStandardDate(Ts.[Gen Date From]) O,       
  dbo.FNAGetSQLStandardDate(Ts.[Gen Date To]) P,       
  ISNULL(SCDEF.source_curve_def_id,RG.source_curve_def_id) Q,             
  Ts.Price R,       
  SUOM.source_uom_id S,  --      
  Ts.buy_sell_flag  T,      
 ISNULL(SCUR.source_currency_id, @fixed_price_currency_id) U,      
   cast(Ts.Volume as float) V,      
   Ts.Frequency  W,      
   case when (isnull(datepart(hh, dbo.FNAGetSQLStandardDate(Ts.[Gen Date To])), 0) = 0) then 0       
   else cast(datepart(hh, dbo.FNAGetSQLStandardDate(Ts.[Gen Date To])) as varchar) end X,
  TS.he,
  cast(TS.settlement_volume as float) settlement_volume,
  SUOM1.source_uom_id settlement_uom        	      

FROM 
   #Transactions_detail Ts (NOLOCK)      
   INNER JOIN source_deal_header sdh (NOLOCK)      
   ON TS.[Feeder System ID] = sdh.deal_id
   and [gen date from]=[gen date from] and [gen date to]=[gen date to]
   inner join source_deal_detail sd on
   sdh.source_deal_header_id=sd.source_deal_header_id 		
INNER JOIN      
            rec_generator RG (NOLOCK)      
  ON sdh.Generator_id = cast(RG.generator_id as varchar)      
INNER JOIN      
      source_uom SUOM (NOLOCK)      
  ON Ts.UOM = SUOM.uom_name OR Ts.UOM = CAST(SUOM.source_uom_id AS VARCHAR)      
  LEFT OUTER JOIN -- SCDEF.source_curve_def_id PK      
                       source_price_curve_def SCDEF (NOLOCK)      
  ON Ts.[Index] = SCDEF.curve_id OR Ts.[Index] = CAST(SCDEF.source_curve_def_id AS VARCHAR)      
  LEFT OUTER JOIN -- SCUR.source_currency_id PK      
                       source_currency SCUR (NOLOCK)      
  ON Ts.Currency = SCUR.currency_id OR Ts.Currency = CAST(SCUR.source_currency_id AS VARCHAR) 
LEFT JOIN source_uom SUOM1 (NOLOCK)        
  ON Ts.settlement_uom = SUOM1.uom_name OR Ts.settlement_uom = CAST(SUOM1.source_uom_id AS VARCHAR)      

WHERE
    ((SD.fixed_price IS NULL AND Ts.Price IS NOT NULL) OR SD.fixed_price<>Ts.Price)      
  OR ISNULL(SD.deal_volume_uom_id,'') <>ISNULL(SUOM.source_uom_id,'')      
  OR ISNULL(SD.buy_sell_flag,'') <>ISNULL(Ts.buy_sell_flag,'')      	
  OR (SD.fixed_price_currency_id <> SCUR.source_currency_id AND SCUR.source_currency_id IS NOT NULL)      
  OR (SD.fixed_price_currency_id <> @fixed_price_currency_id AND SCUR.source_currency_id IS NULL)      
  OR SD.deal_volume <>TS.Volume	       
 OR  ISNULL(SD.deal_volume_frequency,'')<>ISNULL(Ts.Frequency,'')       
   OR SD.deal_detail_description <> case when (isnull(datepart(hh, dbo.FNAGetSQLStandardDate(Ts.[Gen Date To])), 0) = 0) then 0       
    else cast(datepart(hh, dbo.FNAGetSQLStandardDate(Ts.[Gen Date To])) as varchar) end
AND( sdh.assignment_type_value_id is  null)
) CHG      
ON SD.source_deal_header_id = CHG.source_deal_header_id
--where SD.buy_sell_flag='b'      


--****************************
-- if deal exists populate in the table

select 
	sd.deal_id,sd.source_deal_header_id
into #transactions_update
  FROM         #Transactions Ts (NOLOCK)      
  INNER JOIN source_deal_header sd (NOLOCK)      
   ON TS.[Feeder System ID] = sd.deal_id


--====================================     
-- Insert new deals
INSERT INTO source_deal_header
  (      
  source_system_id ,      
  deal_id ,      
  deal_date ,      
  physical_financial_flag ,      
  structured_deal_id ,      
  counterparty_id ,      
  entire_term_start ,      
  entire_term_end ,      
  source_deal_type_id ,      
  deal_sub_type_type_id ,      
  option_flag  ,      
  option_type ,      
  option_excercise_type ,      
  source_system_book_id1  ,      
  source_system_book_id2  ,      
  source_system_book_id3  ,      
  source_system_book_id4  ,      
  description1  ,      
  description2  ,      
  description3  ,      
  deal_category_value_id  ,      
  trader_id ,      
  internal_deal_type_value_id ,      
  internal_deal_subtype_value_id ,      
  template_id  ,      
  header_buy_sell_flag ,      
  broker_id,
  generator_id
  
 )

SELECT    
  @source_system_id  as source_system_id,      
  Ts.[Feeder System ID] AS deal_id,       	
  ISNULL(Ts.[Deal Date], dbo.FNAGetSQLStandardDate(Ts.[Gen Date From])) as deal_date,  
  @physical_financial_flag as physical_financial_flag,
  NULL as structured_deal_id,

--@structure_deal_id as structured_deal_id,
  ISNULL(SC.source_counterparty_id , RG.ppa_counterparty_id ) AS source_counter_party,       
  dbo.FNAGetSQLStandardDate(Ts.[Gen Date From]) as entire_term_start,       
  dbo.FNAGetSQLStandardDate(Ts.[Gen Date To]) as entire_term_end ,       
  SDTYPE.source_deal_type_id as source_deal_type_id,         
  SDSTYPE.source_deal_type_id as source_deal_sub_type_id,
  @option_flag as option_flag,
  @option_type as option_type ,      
  @option_excercise_type as option_excercise_type,
  SB.source_book_id as source_system_book_id1,       
  @source_system_book_id2 as source_system_book_id2 ,      
  @source_system_book_id3 as source_system_book_id3 ,      
  @source_system_book_id4 as source_system_book_id4 ,
   NULL,
   NULL,
   NULL,			
  ISNULL(CAT.value_id, @deal_category_value_id) as deal_category_value_id,      
  ISNULL(STRADER.source_trader_id, @trader_id) as trader_id,
  @internal_deal_type_value_id as internal_deal_type_value_id,      
  @internal_deal_subtype_value_id as internal_deal_subtype_value_id,      
  @template_id as template_id,
  ISNULL(Ts.buy_sell_flag, @header_buy_sell_flag) as header_buy_sell_flag,      
  ISNULL(SBROKER.source_broker_id, @broker_id) AS BROKER_ID,
  rg.generator_id as generator_id

FROM       #Transactions Ts
 LEFT OUTER JOIN      
                      source_counterparty SC (NOLOCK)      
 ON Ts.Counterparty = SC.counterparty_id OR Ts.Counterparty = cast(SC.source_counterparty_id as varchar)      
 INNER JOIN      
                      source_book SB (NOLOCK)      
 ON Ts.Book = SB.source_system_book_id       
 INNER JOIN      
                      rec_generator RG (NOLOCK)      
 ON Ts.Generator = RG.code OR Ts.Generator = cast(RG.generator_id as varchar)      
      
 LEFT OUTER JOIN -- SDTYPE.source_deal_type_id PK      
          source_deal_type SDTYPE (NOLOCK)      
 ON Ts.[Deal Type] = SDTYPE.deal_type_id OR Ts.[Deal Type] = cast(SDTYPE.source_deal_type_id as varchar)      
 LEFT OUTER JOIN -- SDSTYPE.source_deal_type_id PK      
 source_deal_type SDSTYPE (NOLOCK)      
 ON Ts.[Deal Sub Type] = SDSTYPE.deal_type_id OR Ts.[Deal Sub Type] = cast(SDSTYPE.source_deal_type_id as varchar)      
 LEFT OUTER JOIN -- STRADER.source_trader_id PK      
                      source_traders STRADER (NOLOCK)      
 ON Ts.Trader = STRADER.trader_id OR Ts.Trader = cast(STRADER.source_trader_id as varchar)      
 LEFT OUTER JOIN -- SBROKER.source_broker_id PK      
                      source_brokers SBROKER (NOLOCK)      
 ON Ts.Broker = SBROKER.broker_id OR Ts.Broker = cast(SBROKER.source_broker_id as varchar)      
 LEFT OUTER JOIN -- CAT.value_id PK      
                      static_data_value CAT (NOLOCK)      
 ON Ts.Category = CAT.code OR Ts.Category = cast(CAT.value_id as varchar)      
      
 WHERE coalesce(SC.source_counterparty_id , RG.ppa_counterparty_id ) IS NOT NULL       
  and [feeder system id] not in(select cast(isnull(deal_id,'') as varchar) from source_deal_header)



---------insert into source deal detail

INSERT INTO source_deal_detail(
	 [source_deal_header_id],
	 [term_start] ,
	 [term_end] ,
	 [Leg] ,
	 [contract_expiration_date],      
	 [fixed_float_leg],
	 [buy_sell_flag],
	 [curve_id],
	 [fixed_price],
	 [fixed_price_currency_id],      
	 [option_strike_price],
	 [deal_volume],
	 [deal_volume_frequency],
	 [deal_volume_uom_id],      
	 [block_description],
	 [deal_detail_description],
	 [formula_id],
	 [volume_left],
	 [settlement_volume],
	 [settlement_uom]
)
SELECT 
	  sd.source_deal_header_id,
	  dbo.FNAGetSQLStandardDate(Ts.[Gen Date From]) as term_start,       
	  dbo.FNAGetSQLStandardDate(Ts.[Gen Date To]) as term_end,       
	  isnull(leg, @leg) as leg,      
	  dbo.FNAGetSQLStandardDate(Ts.[Gen Date From]) as contract_expiration_date,      
	  @fixed_float_leg as fixed_float_leg,      
	  ISNULL(Ts.buy_sell_flag, @header_buy_sell_flag) as buy_sell_flag,      
	  ISNULL(SCDEF.source_curve_def_id, RG.source_curve_def_id) as  source_curve_def_id,     
	  TS.Price as price,      
	  ISNULL( SCUR.source_currency_id, @fixed_price_currency_id) as currency_id,      
	  @option_strike_price as option_strike_price,      
	  CAST(Ts.Volume As float) as deal_volume,      
	  ISNULL(TS.Frequency, @deal_volume_frequency) as deal_volume_frequency,
	  SUOM.source_uom_id as deal_volume_uom_id,      
	  @block_description as block_description,      
	  TS.he as deal_detail_description, --@deal_detail_description,      
	  @formula_id as formula_id,
	  TS.volume as volume_left,
	  cast(TS.settlement_Volume as varchar) as settlement_Volume,
	  SUOM1.source_uom_id as settlement_uom	
FROM
	#Transactions_detail Ts  (NOLOCK) 
	INNER JOIN
		source_deal_header sd on
	TS.[feeder system id]=sd.deal_id
	INNER JOIN      
                        rec_generator RG (NOLOCK)      
  ON sd.Generator_id = cast(RG.generator_id as varchar)   
        INNER JOIN      
	                      source_uom SUOM (NOLOCK)      
	 ON Ts.UOM = SUOM.uom_name OR Ts.UOM = cast(SUOM.source_uom_id as varchar)      


	 LEFT OUTER JOIN -- SCDEF.source_curve_def_id PK      
	                      source_price_curve_def SCDEF (NOLOCK)      
	 ON Ts.[Index] = SCDEF.curve_id OR Ts.[Index] = cast(SCDEF.source_curve_def_id as varchar)      
	 LEFT OUTER JOIN -- SCUR.source_currency_id PK      
	                      source_currency SCUR (NOLOCK)      
	 ON Ts.Currency = SCUR.currency_id OR Ts.Currency = cast(SCUR.source_currency_id as varchar)      
	LEFT OUTER JOIN
         source_uom SUOM1 (NOLOCK)      
	 ON Ts.settlement_uom = SUOM1.uom_name OR Ts.settlement_uom = cast(SUOM1.source_uom_id as varchar)      

--WHERE [feeder system id] not in(select cast(isnull(deal_id,'') as varchar) from source_deal_header)
where source_deal_header_id not in(select source_deal_header_id from source_deal_detail)


EXEC spa_print @@rowcount

----- Insert new deal if auto assignment is not null

----------------------------------------------------------------------------
-- delete from #transactions which exists
--delete from #transactions where [feeder system id] in(select ISNULL(deal_id,'') from #transactions_update)
----------------------------
--select * from #transactions

IF @@rowcount<>0 -- if new deal is inserted then check for auto assignment
BEGIN

if exists(select * FROM  #Transactions Ts  (NOLOCK)  INNER JOIN  source_deal_header sdh
	on sdh.deal_id=TS.[feeder system id]
	inner join rec_generator rg on sdh.generator_id=rg.generator_id	
	WHERE rg.auto_assignment_type is not null	
)
BEGIN	
	DECLARE @maxid int
	create table #unique_id([ID] varchar(50) COLLATE DATABASE_DEFAULT ,unique_ID int)
	
	select @maxid=max(farrms_id) from farrms_dealId

	insert farrms_dealId(generate_date) select TS.[id] from #transactions TS inner join source_deal_header sdh
	on sdh.deal_id=TS.[feeder system id]
	inner join rec_generator rg on sdh.generator_id=rg.generator_id	
	WHERE rg.auto_assignment_type is not null	
	
	--set @structure_deal_id=@@identity
	insert into #unique_id([id],unique_ID) select generate_date,farrms_id from farrms_dealId 
	where farrms_id>@maxid

	insert into source_deal_header (
		source_system_id ,      
		deal_id ,      
		deal_date ,      
		physical_financial_flag ,      
		structured_deal_id ,      
		counterparty_id ,      
		entire_term_start ,      
		entire_term_end ,      
		source_deal_type_id ,      
		deal_sub_type_type_id ,      
		option_flag  ,      
		option_type ,      
		option_excercise_type ,      
		source_system_book_id1  ,      
		source_system_book_id2  ,      
		source_system_book_id3  ,      
		source_system_book_id4  ,      
		description1  ,      
		description2  ,      
		description3  ,      
		deal_category_value_id  ,      
		trader_id ,      
		internal_deal_type_value_id ,      
		internal_deal_subtype_value_id ,      
		template_id  ,      
		header_buy_sell_flag ,      
		broker_id,
		generator_id,
		assignment_type_value_id,
		ext_deal_id,
		compliance_year,
		state_value_id	,
		assigned_date,
		assigned_by
	)
	select 
		source_system_id ,      
		unq.unique_ID deal_id ,      
		sdh.deal_date ,      
		physical_financial_flag ,      
		structured_deal_id ,      
		counterparty_id ,      
		entire_term_start ,      
		entire_term_end ,      
		source_deal_type_id ,      
		deal_sub_type_type_id ,      
		option_flag  ,      
		option_type ,      
		option_excercise_type ,      
		source_system_book_id1  ,      
		source_system_book_id2  ,      
		source_system_book_id3  ,      
		source_system_book_id4  ,      
		description1  ,      
		description2  ,      
		description3  ,      
		deal_category_value_id  ,      
		trader_id ,      
		internal_deal_type_value_id ,      
		internal_deal_subtype_value_id ,      
		template_id  ,      
		's',      
		broker_id,
		sdh.generator_id,
		rg.auto_assignment_type,
		sdh.source_deal_header_id,


		YEAR(sdh.deal_date),
		rg.state_value_id,
		dbo.FNAGetSQLStandardDate(sdh.deal_date),
		@user
	 from 
		source_deal_header sdh inner join
		#Transactions TS on 
		sdh.deal_id=TS.[feeder system id]
		inner join rec_generator rg on sdh.generator_id=rg.generator_id	
		and rg.auto_assignment_type is not null 
		inner join #unique_id unq on cast(unq.[ID] as int)=TS.[ID]

-------inser detail record if auto assignment is not null

insert into source_deal_detail (
		 [source_deal_header_id],
		 [term_start] ,
		 [term_end] ,
		 [Leg] ,
		 [contract_expiration_date],      
		 [fixed_float_leg],
		 [buy_sell_flag],
		 [curve_id],
		 [fixed_price],
		 [fixed_price_currency_id],      
		 [option_strike_price],
		 [deal_volume],
		 [deal_volume_frequency],
		 [deal_volume_uom_id],      
		 [block_description],
		 [deal_detail_description],
		 [formula_id],
		 [volume_left],
		 [settlement_volume],
		 [settlement_uom]
	)
	

	select 
		 sdh1.[source_deal_header_id],
		 sdd.[term_start] ,
		 sdd.[term_end] ,
		 sdd.[Leg] ,
		 [contract_expiration_date],      
		 [fixed_float_leg],
		 case when (sdd.buy_sell_flag = 'b') then 's' else 'b' end buy_sell_flag,
		 sdd.curve_id,
--		 rg.auto_assignment_type,
		 [fixed_price],
		 [fixed_price_currency_id],      
		 [option_strike_price],
		 [deal_volume] * auto_assignment_per ,
		 [deal_volume_frequency],
		 [deal_volume_uom_id],      
		 [block_description],
		 [deal_detail_description],
		 [formula_id],
		 volume_left,
		 settlement_volume * auto_assignment_per ,
		 settlement_uom	
	
	  from 
		source_deal_header sdh inner join
		#Transactions TS on 
		sdh.deal_id=TS.[feeder system id]
		inner join source_deal_header sdh1 on sdh1.ext_deal_id=sdh.source_deal_header_id
		inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
		inner join rec_generator rg on sdh.generator_id=rg.generator_id	
		and rg.auto_assignment_type is not null 
	

--- insert into assignment_audit if auto assign is true

INSERT INTO
	assignment_audit(
		assignment_type,
		assigned_volume,
		source_deal_header_id,
		source_deal_header_id_from,
		compliance_year,
		state_value_id,
		assigned_date,
		assigned_by,
		cert_from,
		cert_to		
	)

	SELECT 
		rg.auto_assignment_type,
		sdd.deal_volume* ISNULL(rg.auto_assignment_per,1),
		Sdd1.source_deal_detail_id,
		sdd.source_deal_detail_id,
		YEAR(sdh.deal_date),
		rg.state_value_id,
		dbo.FNAGetSQLStandardDate(sdh.deal_date),
		'Auto Assigned',
		1,
		round(sdd.deal_volume* ISNULL(rg.auto_assignment_per,1),0)
	
	FROM
		source_deal_header sdh inner join
		#Transactions  TS on 
		sdh.deal_id=TS.[feeder system id]
		inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
		inner join source_deal_header sdh1 on sdh1.ext_deal_id=sdh.source_deal_header_id
		inner join source_deal_detail sdd1 on sdh1.source_deal_header_id=sdd1.source_deal_header_id
		inner join rec_generator rg on
	        sdh.generator_id=rg.generator_id
	
	WHERE
		 rg.auto_assignment_type is not null	

END	
END	
--### Assign Auto Certificate

	update gis_certificate
	set gis_certificate_number_from= dbo.FNACertificateRule(cr.cert_rule,rg.generator_id,1,sdd.term_start),	
	gis_certificate_number_to= dbo.FNACertificateRule(cr.cert_rule,rg.generator_id,sdd.deal_volume,sdd.term_start),	
	certificate_number_from_int=1,
	certificate_number_to_int=cast(deal_volume as int),
	gis_cert_date= sdd.term_start
	from gis_certificate gc,source_deal_header sdh,source_deal_detail sdd,certificate_rule cr,rec_generator rg,#Transactions t
	where t.[feeder system id]=sdh.deal_id and sdh.generator_id = RG.generator_id  and 
	sdh.source_deal_header_id=sdd.source_deal_header_id and 
	gc.source_deal_header_id=sdd.source_deal_detail_id and
	ISNULL(sdh.assignment_type_value_id,@gis_id)=cr.gis_id
	 
	
	INSERT INTO gis_certificate
		( source_deal_header_id,
		  gis_certificate_number_from,
		  gis_certificate_number_to,
	       	  certificate_number_from_int,
		  certificate_number_to_int,
		  gis_cert_date	
	     )
	SELECT    distinct	 	  	
		   sdd.source_deal_detail_id,

		   dbo.FNACertificateRule(cr.cert_rule,rg.generator_id,1,sdd.term_start),		   	 	
		   dbo.FNACertificateRule(cr.cert_rule,rg.generator_id,sdd.deal_volume,sdd.term_start),		   	 	
		   1,
		   cast(deal_volume as int),
		   sdd.term_start
		FROM
			source_deal_header sdh join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id 
			inner join rec_generator rg 
			ON sdh.generator_id = RG.generator_id     
			inner join certificate_rule cr on
			ISNULL(sdh.assignment_type_value_id,@gis_id)=cr.gis_id join 
			#Transactions t on t.[feeder system id]=sdh.deal_id 

			left outer join gis_certificate gc on gc.source_deal_header_id=sdd.source_deal_detail_id
		WHERE 	rg.auto_certificate_number='y'
			and sdd.buy_sell_flag='b' and gc.source_deal_header_id is null


IF @show_messageboard ='y' OR exists(select process_id from Import_Transactions_Log where process_id=@process_id)
 BEGIN
	--Find bad Book records.      
	BEGIN TRAN      
	INSERT INTO [Import_Transactions_Log]       
	 (      
	 --[Import_Transaction_log_id],      
	 [process_id] ,      
	 [code],      
	 [module],      
	 [source],      
	 [type] ,      
	 [description],      
	 [nextsteps])      
	      
	SELECT     @process_id, 'Error', 'Import Transactions', 'Run Import' , 'Data Errors', 'Book : ' + CAST(Ts.Book As Varchar) + ' is not a valid member for DEAL: ' + TS.[Feeder System ID], 'Correct the error and reimport.'      
	FROM         #Transactions Ts LEFT OUTER JOIN      
	                      source_book SB ON Ts.Book = SB.source_system_book_id      
	WHERE     (SB.source_system_book_id IS NULL)      
	COMMIT TRAN      
	
	
	--Find bad UOM records.      
	BEGIN TRAN      
	INSERT INTO [Import_Transactions_Log]       
	 (      
	 --[Import_Transaction_log_id],      
	 [process_id] ,      
	 [code],      
	 [module],      
	 [source],      
	 [type] ,      
	 [description],      
	 [nextsteps])      
	      
	SELECT     @process_id, 'Error', 'Import Transactions', 'Run Import' , 'Data Errors', 'UOM : ' + CAST(Ts.UOM As Varchar) + ' is not a valid member for DEAL: ' + TS.[Feeder System ID], 'Correct the error and reimport.'      
	FROM         #Transactions_detail Ts LEFT OUTER JOIN      
	                      source_uom SUOM ON Ts.UOM = SUOM.uom_name OR Ts.UOM = cast(SUOM.source_uom_id as varchar)      
	WHERE     (SUOM.uom_name IS NULL)      
	COMMIT TRAN      
	      
	--Find bad GIS records.      
	      
	-- INSERT INTO [Import_Transactions_Log]       
	--  (      
	--  --[Import_Transaction_log_id],      
	--  [process_id] ,      
	--  [code],      
	--  [module],      
	--  [source],      
	--  [type] ,      
	--  [description],      
	--  [nextsteps])      
	--       
	-- SELECT     @process_id, 'Error', 'Import Transactions', 'Run Import' , 'Data Errors', 'GIS : ' + CAST(ISNULL(Ts.GIS, ' ') As Varchar) + ' is not a valid member for DEAL: ' + TS.[Feeder System ID] , 'Correct the error and reimport.'      
	-- FROM         #Transactions Ts LEFT OUTER JOIN      
	--                       static_data_value SV ON Ts.GIS = SV.code      
	--   LEFT OUTER JOIN      
	--           rec_generator RG (NOLOCK)      
	--    ON Ts.Generator = RG.code       
	-- WHERE     (SV.code IS NULL) AND (RG.gis_value_id IS NULL)      
	      
	      
	--select * from #Transactions      
	--Find bad deal type      
	BEGIN TRAN      
	INSERT INTO [Import_Transactions_Log]       
	 (      
	 --[Import_Transaction_log_id],      
	 [process_id] ,      
	 [code],      
	 [module],      
	 [source],      
	 [type] ,      
	 [description],      
	 [nextsteps])      
	      
	SELECT     @process_id, 'Error', 'Import Transactions', 'Run Import' , 'Data Errors', 'Deal Type : ' + CAST(Ts.[Deal Type] As Varchar) + ' is not a valid member for DEAL: ' + TS.[Feeder System ID], 'Correct the error and reimport.'      
	FROM         #Transactions Ts LEFT OUTER JOIN      
 source_deal_type SDTYPE ON Ts.[Deal Type] = SDTYPE.deal_type_id OR Ts.[Deal Type] = cast(SDTYPE.source_deal_type_id as varchar)      
	WHERE     (Ts.[Deal Type] IS NOT NULL AND SDTYPE.source_deal_type_id IS NULL)      
	COMMIT TRAN      
	      
	--Find bad deal sub type      
	BEGIN TRAN      
	INSERT INTO [Import_Transactions_Log]       
	 (      
	 --[Import_Transaction_log_id],      
	 [process_id] ,      
	 [code],      
	 [module],      
	 [source],      
	 [type] ,      
	 [description],      
	 [nextsteps])      
	      
	SELECT    @process_id, 'Error', 'Import Transactions', 'Run Import' , 'Data Errors', 'Deal Sub Type : ' + CAST(Ts.[Deal Sub Type] As Varchar) + ' is not a valid member for DEAL: ' + TS.[Feeder System ID], 'Correct the error and reimport.'      
	FROM     #Transactions Ts LEFT OUTER JOIN      
	                      source_deal_type SDSTYPE ON Ts.[Deal Sub Type] = SDSTYPE.deal_type_id OR Ts.[Deal Sub Type] = cast(SDSTYPE.source_deal_type_id as varchar)      
	WHERE     (Ts.[Deal Sub Type] IS NOT NULL AND SDSTYPE.source_deal_type_id IS NULL)      
	COMMIT TRAN      
	      
	--Find bad trader      
	BEGIN TRAN      
	INSERT INTO [Import_Transactions_Log]       
	 (      
	 --[Import_Transaction_log_id],      
	 [process_id] ,      
	 [code],      
	 [module],      
	 [source],      
	 [type] ,      
	 [description],      
	 [nextsteps])      
	      
	SELECT    @process_id, 'Error', 'Import Transactions', 'Run Import' , 'Data Errors', 'Trader : ' + CAST(Ts.Trader As Varchar) + ' is not a valid member for DEAL: ' + TS.[Feeder System ID], 'Correct the error and reimport.'      
	FROM      #Transactions Ts LEFT OUTER JOIN      
	        source_traders STRADER  ON Ts.Trader = STRADER.trader_id OR Ts.Trader = cast(STRADER.source_trader_id as varchar)      
	WHERE     (Ts.Trader IS NOT NULL AND STRADER.source_trader_id IS NULL)      
	COMMIT TRAN      
	      
	--Find bad broker      
	      
	BEGIN TRAN      
	INSERT INTO [Import_Transactions_Log]       
	 (      
	 --[Import_Transaction_log_id],      
	 [process_id] ,      
	 [code],      
	 [module],      
	 [source],      
	 [type] ,      
	 [description],      
	 [nextsteps])      
	      
	SELECT     @process_id, 'Error', 'Import Transactions', 'Run Import' , 'Data Errors', 'Broker : ' + CAST(Ts.Broker As Varchar) + ' is not a valid member for DEAL: ' + TS.[Feeder System ID], 'Correct the error and reimport.'      
	FROM         #Transactions Ts LEFT OUTER JOIN      
	                      source_brokers SBROKER  ON Ts.Broker = SBROKER.broker_id OR Ts.Broker = cast(SBROKER.source_broker_id as varchar)      
	WHERE     (Ts.Broker IS NOT NULL AND SBROKER.source_broker_id IS NULL)      
	COMMIT TRAN      
	      
	--Find bad Index      
	BEGIN TRAN      
	INSERT INTO [Import_Transactions_Log]       
	 (      
	 --[Import_Transaction_log_id],      
	 [process_id] ,      
	 [code],      
	 [module],      
	 [source],      
	 [type] ,      
	 [description],      
	 [nextsteps])      
	      
	SELECT     @process_id, 'Error', 'Import Transactions', 'Run Import' , 'Data Errors', 'Index : ' + CAST(Ts.[Index] As Varchar) + ' is not a valid member for DEAL: ' + TS.[Feeder System ID], 'Correct the error and reimport.'      
	FROM         #Transactions_detail Ts LEFT OUTER JOIN      
	                      source_price_curve_def SCDEF ON Ts.[Index] = SCDEF.curve_id OR Ts.[Index] = cast(SCDEF.source_curve_def_id as varchar)      
	WHERE     (Ts.[Index] IS NOT NULL AND SCDEF.source_curve_def_id IS NULL)      
	COMMIT TRAN      
	      
	--Find bad Currency      
	BEGIN TRAN      
	INSERT INTO [Import_Transactions_Log]       
	 (      
	 --[Import_Transaction_log_id],      
	 [process_id] ,      
	 [code],      
	 [module],      
	 [source],      
	 [type] ,      
	 [description],      
	 [nextsteps])      
	      
	SELECT     @process_id, 'Error', 'Import Transactions', 'Run Import' , 'Data Errors', 'Currency : ' + CAST(Ts.[Currency] As Varchar) + ' is not a valid member for DEAL: ' + TS.[Feeder System ID], 'Correct the error and reimport.'      
	FROM         #Transactions_detail Ts LEFT OUTER JOIN      
	      source_currency SCUR  ON Ts.Currency = SCUR.currency_id OR Ts.Currency = cast(SCUR.source_currency_id as varchar)      
	WHERE     (Ts.Currency IS NOT NULL AND SCUR.source_currency_id IS NULL)      
	COMMIT TRAN      
	      
	--Find bad Category      
	BEGIN TRAN      
	INSERT INTO [Import_Transactions_Log]       
	 (      
	 --[Import_Transaction_log_id],      
	 [process_id] ,      
	 [code],      
	 [module],      
	 [source],      
	 [type] ,      
	 [description],      
	 [nextsteps])      
	      
	SELECT     @process_id, 'Error', 'Import Transactions', 'Run Import' , 'Data Errors', 'Category : ' + CAST(Ts.[Category] As Varchar) + ' is not a valid member for DEAL: ' + TS.[Feeder System ID], 'Correct the error and reimport.'      
	FROM         #Transactions Ts LEFT OUTER JOIN      
	                      static_data_value CAT  ON Ts.Category = CAT.code OR Ts.Category = cast(CAT.value_id as varchar)      
	WHERE     (Ts.Category IS NOT NULL AND CAT.value_id IS NULL)      
	COMMIT TRAN      
	      
	--Find bad Generator records.      
	BEGIN TRAN      
	INSERT INTO [Import_Transactions_Log]       
	 (      
	 --[Import_Transaction_log_id],      
	 [process_id] ,      
	 [code],      
	 [module],      
	 [source],      
	 [type] ,      
	 [description],      
	 [nextsteps])      
	      
	SELECT     @process_id, 'Error', 'Import Transactions', 'Run Import' , 'Data Errors', 'Generator : ' + CAST(Ts.Generator As Varchar) + ' is not a valid member for DEAL: ' + TS.[Feeder System ID], 'Correct the error and reimport.'      
	FROM         #Transactions Ts LEFT OUTER JOIN      
	                      rec_generator RG ON Ts.Generator = RG.code OR Ts.Generator = cast(RG.generator_id as varchar)      
	WHERE     (RG.code IS NULL)      
	COMMIT TRAN      
	       
	--Find bad Counterparty records.      
	BEGIN TRAN      
	INSERT INTO [Import_Transactions_Log]       
	 (      
	 --[Import_Transaction_log_id],      
	 [process_id] ,      
	 [code],      
	 [module],      
	 [source],      
	 [type] ,      
	 [description],      
	 [nextsteps])      
	      
	SELECT     @process_id, 'Error', 'Import Transactions', 'Run Import' , 'Data Errors', 'Counterparty : ' + CAST(ISNULL(Ts.Counterparty,' ') As Varchar) + ' is not a valid member for DEAL: ' + TS.[Feeder System ID], 'Correct the error and reimport.'      
	FROM         #Transactions Ts LEFT OUTER JOIN      
	                      source_counterparty SC ON Ts.Counterparty = SC.counterparty_id OR Ts.Counterparty = cast(SC.source_counterparty_id as varchar)      
	 LEFT OUTER JOIN      
	          rec_generator RG (NOLOCK)      
	   ON Ts.Generator = RG.code       
	          
	WHERE     (SC.counterparty_id IS NULL ANd RG.ppa_counterparty_id IS NULL)      
	COMMIT TRAN      
	      
	      
	--Check for errors      
	SET @user_name = @user_id      
	--SET @desc = 'Assessment process completed for run date ' + @run_date       
	SET @url_desc = 'Detail...'      
	SET @url = './dev/spa_html.php?__user_name__=' + @user_name +       
	 '&spa=exec spa_get_import_transactions_log ''' + @process_id + ''''      
	           
	DECLARE @error_count int      
	DECLARE @type char      
	      
	SELECT  @error_count =   COUNT(*)       
	FROM        Import_Transactions_Log      
	WHERE     process_id = @process_id AND code = 'Error'      
	      
	If @error_count > 0       
	 BEGIN      
	 BEGIN TRAN      
	 INSERT INTO [Import_Transactions_Log]       
	 (      
	 --[Import_Transaction_log_id],      
	 [process_id] ,      
	 [code],      
	 [module],      
	 [source],      
	 [type] ,      
	 [description],      
	 [nextsteps])      
	 SELECT     @process_id, 'Error', 'Import Transactions', 'Run Import' , 'Results', 'Import/Update REC transactions completed with error(s).', 'Correct error(s) and reimport.'      
	 COMMIT TRAN      
	      
	 SET @type = 'e'      
	 ENd      
	Else      
	 BEGIN      
	 BEGIN TRAN      
	 INSERT INTO [Import_Transactions_Log]       
	 (      
	 --[Import_Transaction_log_id],      
	 [process_id] ,      
	 [code],      
	 [module],      
	 [source],      
	 [type] ,      
	 [description],      
	 [nextsteps])      
	 SELECT     @process_id, 'Success', 'Import Transactions', 'Run Import' , 'Results',       
	 'Import/Update REC transactions completed without error for Book: ' + isnull(Book, 'UNKNOWN') + ', Feeder System ID: ' +       
	 isnull(TS.[Feeder System ID], 'UNKNOWN') + ', Volume: ' + isnull(Volume, 'UNKNOWN'),  ''      
	 from #Transactions_detail TSD inner join #Transactions TS   on
	 TSD.[feeder system id]=TS.[feeder system id]
	 COMMIT TRAN      
	      
	 SET @type = 's'      

	 END      
	      
	
		declare @total_count int, @total_count_v varchar(50)      
		set @total_count = 0      
		Select @total_count = count(*) from #Transactions      
		      
		set @total_count_v = cast(isnull(@total_count, 0) as varchar)      
		      
		SET @desc = '<a target="_blank" href="' + @url + '">' +       
		  'Import Transactions processed ' + @total_count_v  + ' record(s) for run date ' + dbo.FNAUserDateFormat(@as_of_date, @user_id) +       

		  case when (@type = 'e') then ' (ERRORS found)' else '' end +      
		  '.</a>'      
		      
		EXEC  spa_message_board 'i', @user_name,      
		   NULL, 'Import Transaction ',      
		   @desc, '', '', @type, @job_name      
END







