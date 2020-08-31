SET IDENTITY_INSERT static_data_value ON
GO

INSERT INTO static_data_value(value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (890, 800, 'CounterpartyRating', 'Rating of a Counterparty', dbo.FNADBUser(), GETDATE())
INSERT INTO static_data_value(value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (891, 800, 'CounterpartyMTM', 'MTM value of the deals associated with the Counterparty', dbo.FNADBUser(), GETDATE())
INSERT INTO static_data_value(value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (892, 800, 'CounterpartyNetPowerPurchase', 'Position of the physical deals associated with the Counterparty', dbo.FNADBUser(), GETDATE())
INSERT INTO static_data_value(value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (893, 800, 'LoadVolume', 'Position of Load deals', dbo.FNADBUser(), GETDATE())


SET IDENTITY_INSERT static_data_value OFF
GO
            