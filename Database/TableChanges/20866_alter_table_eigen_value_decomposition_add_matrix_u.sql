
IF COL_LENGTH('eigen_value_decomposition','matrix_u') IS NULL
	ALTER TABLE eigen_value_decomposition ADD matrix_u FLOAT
GO
IF COL_LENGTH('eigen_value_decomposition_whatif','matrix_u') IS NULL
	ALTER TABLE eigen_value_decomposition_whatif ADD matrix_u FLOAT
GO