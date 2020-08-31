/****** Object:  UserDefinedFunction [dbo].[FNAEMSEMSConv]    Script Date: 11/01/2009 12:02:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAEMSEMSConv]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAEMSEMSConv]
/****** Object:  UserDefinedFunction [dbo].[FNAEMSEMSConv]    Script Date: 11/01/2009 12:02:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  FUNCTION [dbo].[FNAEMSEMSConv](
		@curve_id int,
		@generator_id int,
		@term_start datetime,
		@char1 int,
		@char2 int,
		@char3 int,
		@char4 int,
		@char5 int,
		@char6 int,
		@char7 int,
		@char8 int,
		@char9 int,
		@char10 int,
		@ems_source_input_id int,
		@conversion_type int,
		@from_uom_id int,
		@to_uom_id int,
		@conv_source int
	)
Returns Float
AS
BEGIN
	DECLARE @char_factor FLOAT
if @ems_source_input_id is null 
	set @ems_source_input_id=-1



	 select @char_factor=emsconv.char_factor 
from 
	ems_source_conversion emsconv
	inner join(select max(ISNULL(effective_date,'1900-01-01')) as effective_date,
				ems_conversion_type_id,ems_source_input_id,uom_id,uom_id_by,emission_type,char1,char2,char3,char4,char5,
				char6,char7,char8,char9,char10,source,generator_id from ems_source_conversion where
				ISNULL(effective_date,'')<=@term_start 
				AND ((generator_id=@generator_id AND generator_id is not null) OR generator_id is null)
				group by ems_conversion_type_id,ems_source_input_id,uom_id,uom_id_by,emission_type,char1,char2,char3,char4,char5,
				char6,char7,char8,char9,char10,source,generator_id) a
	on 
		ISNULL(emsconv.effective_date,'1900-01-01')=a.effective_date
		and emsconv.ems_conversion_type_id=a.ems_conversion_type_id
		and ISNULL(emsconv.ems_source_input_id,'')=ISNULL(a.ems_source_input_id,'')
		and ISNULL(emsconv.uom_id,'')=ISNULL(a.uom_id,'')
		and ISNULL(emsconv.uom_id_by,'')=ISNULL(a.uom_id_by,'')
		and ISNULL(emsconv.char1,'')=ISNULL(a.char1,'')
		and ISNULL(emsconv.char2,'')=ISNULL(a.char2,'')
		and ISNULL(emsconv.char3,'')=ISNULL(a.char3,'')
		and ISNULL(emsconv.char4,'')=ISNULL(a.char4,'')
		and ISNULL(emsconv.char5,'')=ISNULL(a.char5,'')
		and ISNULL(emsconv.char6,'')=ISNULL(a.char6,'')
		and ISNULL(emsconv.char7,'')=ISNULL(a.char7,'')
		and ISNULL(emsconv.char8,'')=ISNULL(a.char8,'')
		and ISNULL(emsconv.char9,'')=ISNULL(a.char9,'')
		and ISNULL(emsconv.char10,'')=ISNULL(a.char10,'')
		and ISNULL(emsconv.source,'')=ISNULL(a.source,'')
		and ISNULL(emsconv.emission_type,'')=ISNULL(a.emission_type,'')
		and ISNULL(emsconv.generator_id,'')=ISNULL(a.generator_id,'')
		
where 1=1
	AND ISNULL(emsconv.ems_source_input_id,-1)=@ems_source_input_id
	AND ( ISNULL(emsconv.ems_source_input_id,-1)=-1  
	OR(ISNULL(emsconv.char1,'')	=isnull(@char1,'')
	AND ISNULL(emsconv.char2,'')	=isnull(@char2,'')
	AND ISNULL(emsconv.char3,'')	=isnull(@char3,'')
	AND ISNULL(emsconv.char4,'')	=isnull(@char4,'')
	AND ISNULL(emsconv.char5,'')	=isnull(@char5,'')
	AND ISNULL(emsconv.char6,'')	=isnull(@char6,'')
	AND ISNULL(emsconv.char7,'')	=isnull(@char7,'')
	AND ISNULL(emsconv.char8,'')	=isnull(@char8,'')
	AND ISNULL(emsconv.char9,'')	=isnull(@char9,'')
	AND ISNULL(emsconv.char10,'')	=isnull(@char10,'')))
	AND isnull(emsconv.uom_id,'')=isnull(@to_uom_id,'')
	AND isnull(emsconv.uom_id_by,'')=ISNULL(@from_uom_id,'')
	AND isnull(emsconv.ems_conversion_type_id,'')=isnull(@conversion_type,'')
	AND isnull(emsconv.source,'')=isnull(@conv_source,'')
	AND ((emsconv.generator_id=@generator_id AND emsconv.generator_id is not null) OR emsconv.generator_id is null)
	--AND ISNULL(emission_type,'')=isnull(@curve_id,'')
	RETURN @char_factor

END


