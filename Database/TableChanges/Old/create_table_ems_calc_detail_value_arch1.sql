IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ems_calc_detail_value_arch1]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ems_calc_detail_value_arch1](
	[detail_id] [int] NOT NULL,
	[inventory_id] [int] NULL,
	[as_of_date] [datetime] NOT NULL,
	[term_start] [datetime] NOT NULL,
	[term_end] [datetime] NOT NULL,
	[generator_id] [int] NOT NULL,
	[curve_id] [int] NOT NULL,
	[input_id] [int] NULL,
	[formula_value] [float] NULL,
	[volume] [float] NULL,
	[uom_id] [int] NULL,
	[frequency] [int] NULL,
	[current_forecast] [char](1) NULL,
	[sequence_number] [int] NULL,
	[formula_id] [int] NULL,
	[formula_str] [varchar](5000) NULL,
	[formula_value_reduction] [float] NULL,
	[formula_id_reduction] [int] NULL,
	[reduction] [char](1) NULL,
	[output_id] [int] NULL,
	[output_value] [float] NULL,
	[output_uom_id] [int] NULL,
	[heatcontent_value] [float] NULL,
	[heatcontent_uom_id] [int] NULL,
	[formula_str_reduction] [varchar](5000) NULL,
	[formula_eval] [varchar](1000) NULL,
	[formula_eval_reduction] [varchar](1000) NULL,
	[char1] [varchar](50) NULL,
	[char2] [varchar](50) NULL,
	[char3] [varchar](50) NULL,
	[char4] [varchar](50) NULL,
	[char5] [varchar](50) NULL,
	[char6] [varchar](50) NULL,
	[char7] [varchar](50) NULL,
	[char8] [varchar](50) NULL,
	[char9] [varchar](50) NULL,
	[char10] [varchar](50) NULL,
	[base_year_volume] [float] NULL,
	[forecast_type] [int] NULL,
	[fuel_type_value_id] [int] NULL,
	[formula_detail_id] [int] NULL,
	[emissions_factor] [float] NULL,
	[fas_book_id] [int] NULL
) ON [PRIMARY]
END
