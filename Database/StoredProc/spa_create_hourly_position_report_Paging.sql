/****** Object:  StoredProcedure [dbo].[spa_create_hourly_position_report_Paging]    Script Date: 03/18/2010 18:23:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_create_hourly_position_report_Paging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_create_hourly_position_report_Paging]
/****** Object:  StoredProcedure [dbo].[spa_create_hourly_position_report_Paging]    Script Date: 03/18/2010 18:23:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--  exec spa_Create_Position_Report '2006-12-31', '1', '215', '216', 'm', '4', 'a', 301, 319, -3, -4
CREATE PROC [dbo].[spa_create_hourly_position_report_Paging]
	 @summary_option char(1)=null,-- 's' Summary, 'd' Detail
 	 @sub_entity_id varchar(100),             		
	 @strategy_entity_id varchar(100) = NULL,             
	 @book_entity_id varchar(100) = NULL, 
	 @counterparty VARCHAR(MAX)=NULL,         
	 @as_of_date datetime=null,
	 @term_start varchar(100)=null,
	 @term_end varchar(100)=null,
	 @granularity INT,
	 @group_by CHAR(1),-- 'i'- Index, 'l' - Location	
	 @source_system_book_id1 INT=NULL, 
	 @source_system_book_id2 INT=NULL, 
	 @source_system_book_id3 INT=NULL, 
	 @source_system_book_id4 INT=NULL,
	 @source_deal_header_id VARCHAR(50)=null,
	 @deal_id VARCHAR(50)=null,
	 @block_group INT=NULL,
	 @period INT=NULL,
	 @commodity VARCHAR(500)=NULL,
	 @convert_uom INT=NULL,
	 @round_value char(1) = '0',
	 @curve_id VARCHAR(500)=NULL,
	 @location_id VARCHAR(500)=NULL,	
	 @physical_financial_flag CHAR(1)='p',	
	 @tenor_option CHAR(1)='f',	
	 @allocation_option CHAR(1)='h',
	 @format_option char(1)='C',		
	 @hour_from int=NULL,
	 @hour_to int=NULL,
	 --@proxy_curve int=NULL,
	 @country int=NULL,
	 @location_group int=NULL, 
	 @location_grid INT=NULL,
	 @drill_index varchar(100)=NULL,  
	 @drill_term varchar(100)=NULL,  
	 @drill_freq CHAR(1)=NULL,   	
	 @drill_clm_hr VARCHAR(100)=NULL, 
	 @drill_uom VARCHAR(100)=NULL, 
	 @process_id varchar(200)=NULL, 
	 @page_size int =NULL,
	 @page_no int=NULL
	
	
AS

SET NOCOUNT ON

	declare @user_login_id varchar(50),@tempTable varchar(300) ,@flag char(1)

	set @user_login_id=dbo.FNADBUser()

	if @process_id is NULL
	Begin
		set @flag='i'
		set @process_id=REPLACE(newid(),'-','_')
	End
	set @tempTable=dbo.FNAProcessTableName('paging_temp_hourlyPosition_Report', @user_login_id,@process_id)
	declare @sqlStmt varchar(5000)

--Sub Strategy Book Counterparty DealNumber DealDate PNLDate Type Phy/Fin Expiration Cumulative FV 

if @flag='i'
begin
--if @summary_option='s'
	IF @group_by='b'
		set @sqlStmt='create table '+ @tempTable+'( 
					sno int  identity(1,1),
				[Block Name] VARCHAR(200),
				[Physical/Financial] VARCHAR(100),
				[Term] VARCHAR(20),
				[Volume] FLOAT,
				[Frequency] VARCHAR(100),
				[UOM] VARCHAR(30)
				)'
	ELSE
	BEGIN
		IF @summary_option='d'
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),
				[Index] VARCHAR(100),
				[Physical/Financial] VARCHAR(100),
				[Term] VARCHAR(20),
				[Volume] FLOAT,
				[Frequency] VARCHAR(100),
				[UOM] VARCHAR(20)
				)'

		ELSE IF @summary_option='h' AND @format_option='r'
			set @sqlStmt='create table '+ @tempTable+'( 
					sno int  identity(1,1),
					[Index] VARCHAR(100),
					[Year] VARCHAR(100),
					[Month] VARCHAR(20),
					[Day] INT,
					[Hour]Int,
					[DST] INT,
					[Position] Float
				)'


		ELSE IF @summary_option='l' 
			set @sqlStmt='create table '+ @tempTable+'( 
					sno int  identity(1,1),
					[DealID] VARCHAR(500),
					[RefID] VARCHAR(500),
					[DealDate] VARCHAR(20),
					[Counterparty] VARCHAR(500),
					[Index] VARCHAR(500),
					[Location]VARCHAR(500),
					[Term] VARCHAR(20),
					[Volume] Float,
					[UOM]  VARCHAR(20)
				)'
				
		ELSE IF @granularity=982 or @granularity=980
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),[Index] VARCHAR(100),[Physical/Financial] VARCHAR(100),[Term] VARCHAR(20),
				[Hr1] FLOAT,[Hr2] FLOAT,[Hr3] FLOAT,[Hr4] FLOAT,[Hr5] FLOAT,[Hr6] FLOAT,[Hr7] FLOAT,[Hr8] FLOAT,[Hr9] FLOAT,[Hr10] FLOAT,[Hr11] FLOAT,[Hr12] FLOAT,[Hr13] FLOAT,[Hr14] FLOAT,[Hr15] FLOAT,[Hr16] FLOAT,[Hr17] FLOAT,[Hr18] FLOAT,[Hr19] FLOAT,[Hr20] FLOAT,[Hr21] FLOAT,[Hr22] FLOAT,[Hr23] FLOAT,[Hr24] FLOAT,UOM VARCHAR(20)
				)'
		ELSE IF @granularity=989
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),[Index] VARCHAR(100),[Physical/Financial] VARCHAR(100),[Term] VARCHAR(20),
				[Hr0:30] FLOAT,[Hr1:00] FLOAT,[Hr1:30] FLOAT,[Hr2:00] FLOAT,[Hr2:30] FLOAT,[Hr3:00] FLOAT,[Hr3:30] FLOAT,[Hr4:00] FLOAT,[Hr4:30] FLOAT,[Hr5:00] FLOAT,[Hr5:30] FLOAT,[Hr6:00] FLOAT,[Hr6:30] FLOAT,[Hr7:00] FLOAT,[Hr7:30] FLOAT,[Hr8:00] FLOAT,[Hr8:30] FLOAT,[Hr9:00] FLOAT,[Hr9:30] FLOAT,[Hr10:00] FLOAT,[Hr10:30] FLOAT,[Hr11:00] FLOAT,[Hr11:30] FLOAT,[Hr12:00] FLOAT,[Hr12:30] FLOAT,[Hr13:00] FLOAT,[Hr13:30] FLOAT,[Hr14:00] FLOAT,[Hr14:30] FLOAT,[Hr15:00] FLOAT,[Hr15:30] FLOAT,[Hr16:00] FLOAT,[Hr16:30] FLOAT,[Hr17:00] FLOAT,[Hr17:30] FLOAT,[Hr18:00] FLOAT,[Hr18:30] FLOAT,[Hr19:00] FLOAT,[Hr19:30] FLOAT,[Hr20:00] FLOAT,[Hr20:30] FLOAT,[Hr21:00] FLOAT,[Hr21:30] FLOAT,[Hr22:00] FLOAT,[Hr22:30] FLOAT,[Hr23:00] FLOAT,[Hr23:30] FLOAT,[Hr24:00] FLOAT, UOM VARCHAR(20)
				)'

		ELSE IF @granularity=987
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),[Index] VARCHAR(100),[Physical/Financial] VARCHAR(100),[Term] VARCHAR(20),
				[Hr0:15] FLOAT,[Hr0:30] FLOAT,[Hr0:45] FLOAT,[Hr1:00] FLOAT,[Hr1:15] FLOAT,[Hr1:30] FLOAT,[Hr1:45] FLOAT,[Hr2:00] FLOAT,[Hr2:15] FLOAT,
				[Hr2:30] FLOAT,[Hr2:45] FLOAT,[Hr3:00] FLOAT,[Hr3:15] FLOAT,[Hr3:30] FLOAT,[Hr3:45] FLOAT,[Hr4:00] FLOAT,[Hr4:15] FLOAT,[Hr4:30] FLOAT,
				[Hr4:45] FLOAT,[Hr5:00] FLOAT,[Hr5:15] FLOAT,[Hr5:30] FLOAT,[Hr5:45] FLOAT,[Hr6:00] FLOAT,[Hr6:15] FLOAT,[Hr6:30] FLOAT,[Hr6:45] FLOAT,
				[Hr7:00] FLOAT,[Hr7:15] FLOAT,[Hr7:30] FLOAT,[Hr7:45] FLOAT,[Hr8:00] FLOAT,[Hr8:15] FLOAT,[Hr8:30] FLOAT,[Hr8:45] FLOAT,[Hr9:00] FLOAT,[Hr9:15] FLOAT,
				[Hr9:30] FLOAT,[Hr9:45] FLOAT,[Hr10:00] FLOAT,[Hr10:15] FLOAT,[Hr10:30] FLOAT,[Hr10:45] FLOAT,[Hr11:00] FLOAT,[Hr11:15] FLOAT,[Hr11:30] FLOAT,[Hr11:45] FLOAT,[Hr12:00] FLOAT,[Hr12:15] FLOAT,
				[Hr12:30] FLOAT,[Hr12:45] FLOAT,[Hr13:00] FLOAT,[Hr13:15] FLOAT,[Hr13:30] FLOAT,[Hr13:45] FLOAT,[Hr14:00] FLOAT,[Hr14:15] FLOAT,[Hr14:30] FLOAT,[Hr14:45] FLOAT,
				[Hr15:00] FLOAT,[Hr15:15] FLOAT,[Hr15:30] FLOAT,[Hr15:45] FLOAT,[Hr16:00] FLOAT,[Hr16:15] FLOAT,
				[Hr16:30] FLOAT,[Hr16:45] FLOAT,[Hr17:00] FLOAT,[Hr17:15] FLOAT,[Hr17:30] FLOAT,[Hr17:45] FLOAT,[Hr18:00] FLOAT,[Hr18:15] FLOAT,
				[Hr18:30] FLOAT,[Hr18:45] FLOAT,[Hr19:00] FLOAT,[Hr19:15] FLOAT,[Hr19:30] FLOAT,[Hr19:45] FLOAT,[Hr20:00] FLOAT,[Hr20:15] FLOAT,
				[Hr20:30] FLOAT,[Hr20:45] FLOAT,[Hr21:00] FLOAT,[Hr21:15] FLOAT,[Hr21:30] FLOAT,[Hr21:45] FLOAT,[Hr22:00] FLOAT,[Hr22:15] FLOAT,
				[Hr22:30] FLOAT,[Hr22:45] FLOAT,[Hr23:00] FLOAT,[Hr23:15] FLOAT,[Hr23:30] FLOAT,[Hr23:45] FLOAT,[Hr24:00] FLOAT,UOM VARCHAR(20)
				)'
	END

	
	EXEC(@sqlStmt)

	set @sqlStmt=' insert  '+@tempTable+'
	exec  spa_create_hourly_position_report '+ 
	dbo.FNASingleQuote(@summary_option) +','+ 
	dbo.FNASingleQuote(@sub_entity_id) +','+ 
	dbo.FNASingleQuote(@strategy_entity_id) +','+ 
	dbo.FNASingleQuote(@book_entity_id) +',' +
    dbo.FNASingleQuote(@counterparty)+',' +
	dbo.FNASingleQuote(@as_of_date)+','+
--	dbo.FNASingleQuote(@generator_id) +',' +
--	dbo.FNASingleQuote(@technology) +',' +
--	dbo.FNASingleQuote(@buy_sell_flag)+','+
--	dbo.FNASingleQuote(@generation_state)+','+
	dbo.FNASingleQuote(@term_start) +','+
	dbo.FNASingleQuote(@term_end) +','+
	dbo.FNASingleQuote(@granularity) +','+
	dbo.FNASingleQuote(@group_by)+','+
	dbo.FNASingleQuote(@source_system_book_id1)+','+
	dbo.FNASingleQuote(@source_system_book_id2)+','+
	dbo.FNASingleQuote(@source_system_book_id3)+','+
	dbo.FNASingleQuote(@source_system_book_id4)+','+
	dbo.FNASingleQuote(@source_deal_header_id)+','+
	dbo.FNASingleQuote(@deal_id)+','+
	dbo.FNASingleQuote(@block_group)+','+
	dbo.FNASingleQuote(@period)+','+
	dbo.FNASingleQuote(@commodity)+','+
	dbo.FNASingleQuote(@convert_uom)+','+
	dbo.FNASingleQuote(@round_value)+','+
	dbo.FNASingleQuote(@curve_id)+','+
	dbo.FNASingleQuote(@location_id)+','+
	dbo.FNASingleQuote(@physical_financial_flag)+','+
	dbo.FNASingleQuote(@tenor_option)+','+
	dbo.FNASingleQuote(@allocation_option)+','+
	dbo.FNASingleQuote(@format_option)+','+
	dbo.FNASingleQuote(@hour_from)+','+
	dbo.FNASingleQuote(@hour_to)+','+
	--dbo.FNASingleQuote(@proxy_curve)+','+
	dbo.FNASingleQuote(@country)+','+  
	dbo.FNASingleQuote(@location_group)+','+ 
	dbo.FNASingleQuote(@location_grid)+','+ 
	dbo.FNASingleQuote(@drill_index)+','+  
	dbo.FNASingleQuote(@drill_term)+','+  
	dbo.FNASingleQuote(@drill_freq)+','+ 	
	dbo.FNASingleQuote(@drill_clm_hr)+','+ 
	dbo.FNASingleQuote(@drill_uom)

	EXEC spa_print @sqlStmt
	exec(@sqlStmt)	

	set @sqlStmt='select count(*) TotalRow,'''+@process_id +''' process_id  from '+ @tempTable
	EXEC spa_print @sqlStmt
	exec(@sqlStmt)
end
else
	begin
		declare @row_to int,@row_from int
			set @row_to=@page_no * @page_size
		if @page_no > 1 
			set @row_from =((@page_no-1) * @page_size)+1
		else
			set @row_from =@page_no
	end
		set @sqlStmt=
			CASE WHEN @summary_option='l' THEN	
				'SELECT [DealID],[RefID],[DealDate],[Counterparty],[Index],[Location],[Term],[Volume],[UOM]'
			ELSE
				case when  @group_by='b'  then 'select [Block Name],[Physical/Financial],[Term],[Volume],[Frequency] ,[UOM] '
				else 
					'select '+	
						CASE  WHEN @group_by='d' THEN 'source_deal_header_id' 
						ELSE 
							'[Index]  AS '+CASE WHEN @group_by='i' THEN ' [Index]' 
	 		 				WHEN @group_by='g' THEN ' [Grid]' 
							WHEN @group_by='c' THEN ' [Country]' 
							WHEN @group_by='r' THEN ' [Region]' 
							WHEN @group_by='z' THEN ' [Zone]' 
							ELSE '[Location]' END 
						END 						
						+CASE WHEN @summary_option='h' AND @format_option='r' THEN
							CASE  WHEN @group_by='d' THEN ',[Term Date]' ELSE ',[Year],[Month],[Day]'	END  +',[Hour],[DST],[Position]'
						ELSE
							',[Physical/Financial],[Term],'
							+CASE
						 WHEN @summary_option='d' THEN '[Volume],[Frequency],' 
						 WHEN @granularity=982 or @granularity=980 THEN 'Hr1,Hr2,Hr3,Hr4,Hr5,Hr6,Hr7,Hr8,Hr9,Hr10,Hr11,Hr12,Hr13,Hr14,Hr15,Hr16,Hr17,Hr18,Hr19,Hr20,Hr21,Hr22,Hr23,Hr24,'
						 WHEN @granularity=989 THEN '[Hr0:30],[Hr1:00],[Hr1:30],[Hr2:00],[Hr2:30],[Hr3:00],[Hr3:30],[Hr4:00],[Hr4:30],[Hr5:00],[Hr5:30],[Hr6:00],[Hr6:30],[Hr7:00],[Hr7:30],[Hr8:00],[Hr8:30],[Hr9:00],[Hr9:30],[Hr10:00],[Hr10:30],[Hr11:00],[Hr11:30],[Hr12:00],[Hr12:30],[Hr13:00],[Hr13:30],[Hr14:00],[Hr14:30],[Hr15:00],[Hr15:30],[Hr16:00],[Hr16:30],[Hr17:00],[Hr17:30],[Hr18:00],[Hr18:30],[Hr19:00],[Hr19:30],[Hr20:00],[Hr20:30],[Hr21:00],[Hr21:30],[Hr22:00],[Hr22:30],[Hr23:00],[Hr23:30],[Hr24:00],'
						 WHEN @granularity=987 THEN '[Hr0:15],[Hr0:30],[Hr0:45],[Hr1:00],[Hr1:15],[Hr1:30],[Hr1:45],[Hr2:00],[Hr2:15],[Hr2:30],[Hr2:45],[Hr3:00],[Hr3:15],[Hr3:30],[Hr3:45],[Hr4:00],[Hr4:15],[Hr4:30],[Hr4:45],[Hr5:00],[Hr5:15],[Hr5:30],[Hr5:45],[Hr6:00],[Hr6:15],[Hr6:30],[Hr6:45],[Hr7:00],[Hr7:15],[Hr7:30],[Hr7:45],[Hr8:00],[Hr8:15],[Hr8:30],[Hr8:45],[Hr9:00],[Hr9:15],[Hr9:30],[Hr9:45],[Hr10:00],[Hr10:15],[Hr10:30],[Hr10:45],[Hr11:00],[Hr11:15],[Hr11:30],[Hr11:45],[Hr12:00],[Hr12:15],[Hr12:30],[Hr12:45],[Hr13:00],[Hr13:15],[Hr13:30],[Hr13:45],[Hr14:00],[Hr14:15],[Hr14:30],[Hr14:45],[Hr15:00],[Hr15:15],[Hr15:30],[Hr15:45],[Hr16:00],[Hr16:15],
													[Hr16:30],[Hr16:45],[Hr17:00],[Hr17:15],[Hr17:30],[Hr17:45],[Hr18:00],[Hr18:15],
													[Hr18:30],[Hr18:45],[Hr19:00],[Hr19:15],[Hr19:30],[Hr19:45],[Hr20:00],[Hr20:15],
													[Hr20:30],[Hr20:45],[Hr21:00],[Hr21:15],[Hr21:30],[Hr21:45],[Hr22:00],[Hr22:15],
													[Hr22:30],[Hr22:45],[Hr23:00],[Hr23:15],[Hr23:30],[Hr23:45],[Hr24:00],' 
						END+
					 'UOM ' END
				end
					
			END +'	
	   from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar)+ ' order by sno asc'

		EXEC spa_print @sqlStmt
		exec(@sqlStmt)
		
		
