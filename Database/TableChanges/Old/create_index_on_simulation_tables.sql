/************************************************************
 * Author: Santosh Gupta
 * Time: 12/4/2013 4:02:14 PM
 * Purpose: Missing index added in Monte carlo simulation tables 
 ************************************************************/



/****** Object:  Index [IX_PT_source_price_curve_simulation_run_date]    Script Date: 12/04/2013 15:53:09 ******/
IF EXISTS (
       SELECT *
       FROM   sys.indexes
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[source_price_curve_simulation]')
              AND NAME = N'IX_PT_source_price_curve_simulation_run_date'
   )
    DROP INDEX [IX_PT_source_price_curve_simulation_run_date] ON [dbo].[source_price_curve_simulation] 
    WITH (ONLINE = OFF)
GO


/****** Object:  Index [IX_application_functions_func_ref_id]    Script Date: 12/04/2013 15:53:09 ******/
CREATE NONCLUSTERED INDEX [IX_PT_source_price_curve_simulation_run_date] ON 
[dbo].[source_price_curve_simulation] 
([run_date], [source_curve_def_id], [maturity_date])
 INCLUDE([curve_value])
WITH (
         PAD_INDEX = OFF,
         STATISTICS_NORECOMPUTE = OFF,
         SORT_IN_TEMPDB = OFF,
         IGNORE_DUP_KEY = OFF,
         DROP_EXISTING = OFF,
         ONLINE = OFF,
         ALLOW_ROW_LOCKS = ON,
         ALLOW_PAGE_LOCKS = ON
     ) ON [PRIMARY]
GO



/****** Object:  Index [IX_PT_source_price_simulation_delta_run_date]    Script Date: 12/04/2013 15:53:09 ******/
IF EXISTS (
       SELECT *
       FROM   sys.indexes
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[source_price_simulation_delta]')
              AND NAME = N'IX_PT_source_price_simulation_delta_run_date'
   )
    DROP INDEX [IX_PT_source_price_simulation_delta_run_date] ON [dbo].[source_price_simulation_delta] 
    WITH (ONLINE = OFF)
GO


/****** Object:  Index [IX_application_functions_func_ref_id]    Script Date: 12/04/2013 15:53:09 ******/
CREATE NONCLUSTERED INDEX [IX_PT_source_price_simulation_delta_run_date] ON 
[dbo].[source_price_simulation_delta] 
([run_date], [curve_source_value_id])
 INCLUDE(
            [source_curve_def_id],
            [as_of_date],
            [maturity_date]
        )
WITH (
         PAD_INDEX = OFF,
         STATISTICS_NORECOMPUTE = OFF,
         SORT_IN_TEMPDB = OFF,
         IGNORE_DUP_KEY = OFF,
         DROP_EXISTING = OFF,
         ONLINE = OFF,
         ALLOW_ROW_LOCKS = ON,
         ALLOW_PAGE_LOCKS = ON
     ) ON [PRIMARY]
GO

/****** Object:  Index [IX_PT_source_price_simulation_delta_run_date]    Script Date: 12/04/2013 15:53:09 ******/
IF EXISTS (
       SELECT *
       FROM   sys.indexes
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[hour_block_term]')
              AND NAME = N'IX_PT_hour_block_term_term_date'
   )
    DROP INDEX [IX_PT_hour_block_term_term_date] ON [dbo].[hour_block_term] WITH (ONLINE = OFF)
GO


/****** Object:  Index [hour_block_term]    Script Date: 12/04/2013 15:53:09 ******/
CREATE NONCLUSTERED INDEX [IX_PT_hour_block_term_term_date] ON [dbo].[hour_block_term] 
([term_date])
 INCLUDE(
            [block_define_id],
            [block_type],
            [Hr1],
            [Hr2],
            [Hr3],
            [Hr4],
            [Hr5],
            [Hr6],
            [Hr7],
            [Hr8],
            [Hr9],
            [Hr10],
            [Hr11],
            [Hr12],
            [Hr13],
            [Hr14],
            [Hr15],
            [Hr16],
            [Hr17],
            [Hr18],
            [Hr19],
            [Hr20],
            [Hr21],
            [Hr22],
            [Hr23],
            [Hr24],
            [add_dst_hour]
        )
WITH (
         PAD_INDEX = OFF,
         STATISTICS_NORECOMPUTE = OFF,
         SORT_IN_TEMPDB = OFF,
         IGNORE_DUP_KEY = OFF,
         DROP_EXISTING = OFF,
         ONLINE = OFF,
         ALLOW_ROW_LOCKS = ON,
         ALLOW_PAGE_LOCKS = ON
     ) ON [PRIMARY]
GO

/****** Object:  Index [IX_PT_source_deal_delta_value_run_date]    Script Date: 12/04/2013 15:53:09 ******/
IF EXISTS (
       SELECT *
       FROM   sys.indexes
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_delta_value]')
              AND NAME = N'IX_PT_source_deal_delta_value_run_date'
   )
    DROP INDEX [IX_PT_source_deal_delta_value_run_date] ON [dbo].[source_deal_delta_value] 
    WITH (ONLINE = OFF)
GO


/****** Object:  Index [hour_block_term]    Script Date: 12/04/2013 15:53:09 ******/
CREATE NONCLUSTERED INDEX [IX_PT_source_deal_delta_value_run_date] ON [dbo].[source_deal_delta_value] 
([run_date])
 INCLUDE([source_deal_header_id])
WITH (
         PAD_INDEX = OFF,
         STATISTICS_NORECOMPUTE = OFF,
         SORT_IN_TEMPDB = OFF,
         IGNORE_DUP_KEY = OFF,
         DROP_EXISTING = OFF,
         ONLINE = OFF,
         ALLOW_ROW_LOCKS = ON,
         ALLOW_PAGE_LOCKS = ON
     ) ON [PRIMARY]
GO







