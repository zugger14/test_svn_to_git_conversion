DELETE ixp 
FROM ixp_clr_functions cf 
INNER JOIN ixp_parameters ixp ON ixp.clr_function_id = ixp_clr_functions_id
WHERE cf.ixp_clr_functions_name = 'Prisma' AND parameter_name = 'PS_bookedBefore'
