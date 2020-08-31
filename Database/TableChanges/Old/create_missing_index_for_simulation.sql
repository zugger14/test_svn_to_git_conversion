/************************************************************
 * Author: Santosh Gupta
 * Added missing index in source_price_curve_simulation table
 * Time: 2/5/2014 3:58:23 PM
 ************************************************************/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[source_price_curve_simulation]') AND name = N'IX_PT_source_price_curve_simulation_run_date_curve_source_value_id')
DROP INDEX [IX_PT_source_price_curve_simulation_run_date_curve_source_value_id] ON [dbo].[source_price_curve_simulation] WITH ( ONLINE = OFF )
GO

CREATE INDEX 
[IX_PT_source_price_curve_simulation_run_date_curve_source_value_id] ON 
[source_price_curve_simulation] ([run_date], [curve_source_value_id]) 
INCLUDE(
           [source_curve_def_id],
           [as_of_date],
           [maturity_date],
           [is_dst]
       )
