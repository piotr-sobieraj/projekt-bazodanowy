-- Zwykły widok - sprzedaż samochodów
CREATE VIEW dbo.v_SprzedazSamochodow
AS
SELECT 
    s.ID_Salon,
    k.ID_Katalog,
    COUNT(*) AS LiczbaTransakcji,
    SUM(o.cena * o.ilosc * (1 - ISNULL(o.rabat,0)/100.0)) AS WartoscSprzedazy
FROM Oferta o
JOIN Samochód sa ON o.Samochód_ID_Samochód = sa.ID_Samochód
JOIN Katalog k ON sa.Katalog_ID_Katalog = k.ID_Katalog
JOIN Salon s ON k.Salon_ID_Salon = s.ID_Salon
GROUP BY s.ID_Salon, k.ID_Katalog;
GO

-- Widok sprzedaży dziennej
CREATE VIEW dbo.v_SprzedazDzienna
AS
SELECT 
    t.Data,
    COUNT(*) AS LiczbaTransakcji,
    SUM(o.cena) AS WartoscSprzedazy
FROM Transakcja t
JOIN Oferta o
    ON t.Oferta_id_faktura = o.id_faktura
   AND t.Oferta_id_towar = o.id_towar
GROUP BY t.Data;
GO


-- Widok indeksowy
CREATE VIEW dbo.v_SprzedazIndeksowana
WITH SCHEMABINDING
AS
SELECT 
    t.Data,
    o.Sprzedawca_ID_Sprzedawca,
    COUNT_BIG(*) AS LiczbaTransakcji,
    SUM(o.cena) AS WartoscSprzedazy
FROM dbo.Transakcja t
JOIN dbo.Oferta o
    ON t.Oferta_id_faktura = o.id_faktura
   AND t.Oferta_id_towar = o.id_towar
GROUP BY 
    t.Data,
    o.Sprzedawca_ID_Sprzedawca;
GO

-- Indeks
CREATE UNIQUE CLUSTERED INDEX IDX_SprzedazIndeksowana
ON dbo.v_SprzedazIndeksowana (Data, Sprzedawca_ID_Sprzedawca);
GO


SELECT * FROM dbo.v_SprzedazSamochodow;
SELECT * FROM dbo.v_SprzedazDzienna;
SELECT * FROM dbo.v_SprzedazIndeksowana;

SELECT 
    t.Data,
    o.Sprzedawca_ID_Sprzedawca,
    SUM(o.cena) AS WartoscSprzedazy
FROM dbo.Transakcja t
JOIN dbo.Oferta o
    ON t.Oferta_id_faktura = o.id_faktura
   AND t.Oferta_id_towar = o.id_towar
GROUP BY 
    t.Data,
    o.Sprzedawca_ID_Sprzedawca;