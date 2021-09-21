DECLARE @ixp_clr_functions_id INT

SELECT @ixp_clr_functions_id = ixp_clr_functions_id 
FROM ixp_clr_functions 
WHERE method_name  = 'PrismaImporter'

IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_auctionId' and clr_function_id = @ixp_clr_functions_id)
BEGIN
	INSERT INTO ixp_parameters(parameter_name, parameter_label, operator_id, field_type,  clr_function_id, validation_message, insert_required, default_value)
	SELECT 'PS_auctionId' --parameter_name
	, 'Auction Id' -- parameter_label
	, 1	 -- operator_id
	, 'input' -- field_type
	, @ixp_clr_functions_id -- clr_function_id
	, NULL --validation_message
	, 'N' -- insert_required
	, NULL -- default_value

END

IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_bookedAt' and clr_function_id = @ixp_clr_functions_id)
BEGIN
	INSERT INTO ixp_parameters(parameter_name, parameter_label, operator_id, field_type,  clr_function_id, validation_message, insert_required, default_value)
	SELECT 'PS_bookedAt' --parameter_name
	, 'Booked At' -- parameter_label
	, 1	 -- operator_id
	, 'calendar' -- field_type
	, @ixp_clr_functions_id -- clr_function_id
	, NULL --validation_message
	, 'N' -- insert_required
	, NULL -- default_value

END

IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_bookedSince' and clr_function_id = @ixp_clr_functions_id)
BEGIN
	INSERT INTO ixp_parameters(parameter_name, parameter_label, operator_id, field_type,  clr_function_id, validation_message, insert_required, default_value)
	SELECT 'PS_bookedSince' --parameter_name
	, 'Booked Since' -- parameter_label
	, 1	 -- operator_id
	, 'calendar' -- field_type
	, @ixp_clr_functions_id -- clr_function_id
	, NULL --validation_message
	, 'N' -- insert_required
	, NULL -- default_value

END

IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_bookedBefore' and clr_function_id = @ixp_clr_functions_id)
BEGIN
	INSERT INTO ixp_parameters(parameter_name, parameter_label, operator_id, field_type,  clr_function_id, validation_message, insert_required, default_value)
	SELECT 'PS_bookedBefore' --parameter_name
	, 'Booked Before' -- parameter_label
	, 1	 -- operator_id
	, 'calendar' -- field_type
	, @ixp_clr_functions_id -- clr_function_id
	, NULL --validation_message
	, 'N' -- insert_required
	, NULL -- default_value

END

