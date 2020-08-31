--Author: Tara Nath Subedi
--Dated: 2010 June 04
--Purpose: Insert data in table 'internal_deal_type_subtype_types' when it is empty.
--Issue Against: 2595

IF ( OBJECT_ID(N'internal_deal_type_subtype_types',N'U') IS NOT NULL ) AND (NOT EXISTS(SELECT 'X' from internal_deal_type_subtype_types))
BEGIN
	INSERT  INTO [internal_deal_type_subtype_types]
			(
			  [internal_deal_type_subtype_id],
			  [internal_deal_type_subtype_type],
			  [type_subtype_flag]
			)
	VALUES  ( 1, 'Swap', NULL )
	INSERT  INTO [internal_deal_type_subtype_types]
			(
			  [internal_deal_type_subtype_id],
			  [internal_deal_type_subtype_type],
			  [type_subtype_flag]
			)
	VALUES  ( 2, 'Options', NULL )
	INSERT  INTO [internal_deal_type_subtype_types]
			(
			  [internal_deal_type_subtype_id],
			  [internal_deal_type_subtype_type],
			  [type_subtype_flag]
			)
	VALUES  (
			  3,
			  'Spread Options',
			  NULL
			)
	INSERT  INTO [internal_deal_type_subtype_types]
			(
			  [internal_deal_type_subtype_id],
			  [internal_deal_type_subtype_type],
			  [type_subtype_flag]
			)
	VALUES  ( 4, 'Env', NULL )
	INSERT  INTO [internal_deal_type_subtype_types]
			(
			  [internal_deal_type_subtype_id],
			  [internal_deal_type_subtype_type],
			  [type_subtype_flag]
			)
	VALUES  ( 5, 'OEnv', NULL )
	INSERT  INTO [internal_deal_type_subtype_types]
			(
			  [internal_deal_type_subtype_id],
			  [internal_deal_type_subtype_type],
			  [type_subtype_flag]
			)
	VALUES  ( 6, 'IR', NULL )
	INSERT  INTO [internal_deal_type_subtype_types]
			(
			  [internal_deal_type_subtype_id],
			  [internal_deal_type_subtype_type],
			  [type_subtype_flag]
			)
	VALUES  ( 7, 'Loan', NULL )
	INSERT  INTO [internal_deal_type_subtype_types]
			(
			  [internal_deal_type_subtype_id],
			  [internal_deal_type_subtype_type],
			  [type_subtype_flag]
			)
	VALUES  ( 8, 'FX', NULL )
	INSERT  INTO [internal_deal_type_subtype_types]
			(
			  [internal_deal_type_subtype_id],
			  [internal_deal_type_subtype_type],
			  [type_subtype_flag]
			)
	VALUES  ( 9, 'EFP', NULL )
	INSERT  INTO [internal_deal_type_subtype_types]
			(
			  [internal_deal_type_subtype_id],
			  [internal_deal_type_subtype_type],
			  [type_subtype_flag]
			)
	VALUES  ( 10, 'Trigger', NULL )
	INSERT  INTO [internal_deal_type_subtype_types]
			(
			  [internal_deal_type_subtype_id],
			  [internal_deal_type_subtype_type],
			  [type_subtype_flag]
			)
	VALUES  ( 11, 'Capacity NG', NULL )
	INSERT  INTO [internal_deal_type_subtype_types]
			(
			  [internal_deal_type_subtype_id],
			  [internal_deal_type_subtype_type],
			  [type_subtype_flag]
			)
	VALUES  ( 12, 'Lagging', NULL )
	INSERT  INTO [internal_deal_type_subtype_types]
			(
			  [internal_deal_type_subtype_id],
			  [internal_deal_type_subtype_type],
			  [type_subtype_flag]
			)
	VALUES  (
			  13,
			  'Transportation',
			  NULL
			)
	INSERT  INTO [internal_deal_type_subtype_types]
			(
			  [internal_deal_type_subtype_id],
			  [internal_deal_type_subtype_type],
			  [type_subtype_flag]
			)
	VALUES  ( 14, 'Exercise', NULL )
	INSERT  INTO [internal_deal_type_subtype_types]
			(
			  [internal_deal_type_subtype_id],
			  [internal_deal_type_subtype_type],
			  [type_subtype_flag]
			)
	VALUES  (
			  15,
			  'Storage Injection ',
			  NULL
			)
	INSERT  INTO [internal_deal_type_subtype_types]
			(
			  [internal_deal_type_subtype_id],
			  [internal_deal_type_subtype_type],
			  [type_subtype_flag]
			)
	VALUES  (
			  16,
			  'Storage Withdrawal',
			  NULL
			)
	INSERT  INTO [internal_deal_type_subtype_types]
			(
			  [internal_deal_type_subtype_id],
			  [internal_deal_type_subtype_type],
			  [type_subtype_flag]
			)
	VALUES  (
			  17,
			  'Storage Inventory',
			  NULL
			)
	INSERT  INTO [internal_deal_type_subtype_types]
			(
			  [internal_deal_type_subtype_id],
			  [internal_deal_type_subtype_type],
			  [type_subtype_flag]
			)
	VALUES  (
			  18,
			  'Spread Options Single Ast',
			  NULL
			)

	PRINT 'Data inserted in ''internal_deal_type_subtype_types'' table.'

END
ELSE
BEGIN
	PRINT 'Data already exists.'
END


