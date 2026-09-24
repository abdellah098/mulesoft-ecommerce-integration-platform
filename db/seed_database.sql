INSERT INTO products (sku, name, description, unit_price, status) VALUES
('SEPH-001', 'Sauvage Eau de Parfum 100ml', 'Dior - Eau de parfum aux notes boisées et épicées', 145.00, 'ACTIVE'),
('SEPH-002', 'La Vie Est Belle Eau de Parfum 50ml', 'Lancôme - Parfum gourmand floral et irisé', 105.00, 'ACTIVE'),
('SEPH-003', 'Soft Pinch Liquid Blush', 'Rare Beauty by Selena Gomez - Blusher liquide longue tenue', 25.00, 'ACTIVE'),
('SEPH-004', 'Gloss Bomb Universal Lip Luminizer', 'Fenty Beauty by Rihanna - Gloss lèvres brillance extrême', 22.50, 'ACTIVE'),
('SEPH-005', 'BHA Liquid Exfoliant 118ml', 'Paulas Choice - Lotion exfoliante 2% BHA aux acides de fruits', 39.00, 'ACTIVE'),
('SEPH-006', 'Lip Sleeping Mask Berry 20g', 'LANEIGE - Masque de nuit réparateur pour les lèvres', 24.00, 'ACTIVE'),
('SEPH-007', 'Rouge Matte Edition Limitée', 'Sephora Collection - Rouge à lèvres mat édition passée', 12.99, 'DISCONTINUED');

INSERT INTO inventory (product_id, available_quantity, reserved_quantity) VALUES
(1, 45, 3),  
(2, 28, 2),   
(3, 150, 12),
(4, 85, 5),
(5, 30, 0),
(6, 0,  4),
(7, 0,  0);