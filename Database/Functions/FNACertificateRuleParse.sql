IF OBJECT_ID(N'FNACertificateRuleParse', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNACertificateRuleParse]
GO

CREATE FUNCTION [dbo].[FNACertificateRuleParse]
(
	@certformat         VARCHAR(500),
	@certificate_value  VARCHAR(100)
)
RETURNS INT
BEGIN
	declare @ind_position int,@parse_val varchar(50),@return_val int, @index int,@more_index int
	declare @right_index int
	set @right_index=0
	set @ind_position=CHARINDEX('<i#',@certformat)
	if @ind_position = 0 
		set @return_val=-1
	else
	begin
			set @index= substring(@certformat,@ind_position+3,1)
			set @more_index=CHARINDEX('#',@certformat,@ind_position+4 )
			if @more_index > 0
			begin
				set @right_index= substring(@certformat,@more_index+1,1)
				while @more_index > 0 
				BEGIN
					set @more_index=CHARINDEX('#',@certformat,@more_index+1 )		
					if @more_index > 0
						SET @right_index=@right_index+ substring(@certformat,@more_index+1,1)

				END
			end
			 if isNumeric(right(left(@certificate_value,len(@certificate_value)-@right_index),@index))=1
				set @return_val=right(left(@certificate_value,len(@certificate_value)-@right_index),@index)
			else
				set @return_val=-1
	end
	return @return_val
END










