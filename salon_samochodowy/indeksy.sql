IF NOT EXISTS (SELECT * FROM Salon WHERE ID_Salon = 1)
    INSERT INTO Salon (ID_Salon, Adres) VALUES (1, 'Ulica Testowa 1');

IF NOT EXISTS (SELECT * FROM Katalog WHERE ID_Katalog = 1)
    INSERT INTO Katalog (ID_Katalog, Typ_Kliienta, Salon_ID_Salon) VALUES (1, 'I', 1);

IF NOT EXISTS (SELECT * FROM Samochód WHERE ID_Samochód = 1)
BEGIN
    INSERT INTO Samochód (ID_Samochód, Model, Wersja, Cena, Rok_Produkcji, Katalog_ID_Katalog) 
    VALUES 
    (1, 'Audi A4', 'Premium', 150000, 2022, 1),
    (2, 'BMW 3', 'Sport', 160000, 2023, 1),
    (3, 'Toyota Corolla', 'Podstawowa', 100000, 2021, 1),
    (4, 'Skoda Octavia', 'Ambition', 120000, 2022, 1),
    (5, 'Ford Focus', 'Titanium', 110000, 2020, 1);
END
GO

-- DEMONSTRACJA INDEKSÓW KLASTROWYCH I NIEKLASTROWYCH
-- Indeks Klastrowy został już utworzony przez klucz główny (ID_Samochód) 
EXEC sp_helpindex 'Samochód';

-- Indeks Nieklastrowy (Non-Clustered Index) na kolumnie Model
IF EXISTS (SELECT name FROM sys.indexes WHERE name = 'IX_Samochod_Model')
    DROP INDEX IX_Samochod_Model ON Samochód;
GO

CREATE NONCLUSTERED INDEX IX_Samochod_Model 
ON Samochód (Model)
INCLUDE (Cena, Rok_Produkcji);
GO

SET STATISTICS IO ON;
GO

-- PRZYKŁAD A: Wyszukiwanie po kolumnie BEZ INDEKSU
-- Tutaj silnik wykona 'Clustered Index Scan' (przeczyta całą tabelę).
SELECT ID_Samochód, Model, Wersja 
FROM Samochód 
WHERE Wersja = 'Sport'; 
GO

-- PRZYKŁAD B: Wyszukiwanie po kolumnie Z INDEKSEM (Model)
-- Tutaj silnik wykona 'Index Seek' (dotrze bezpośrednio do danych).
SELECT Model, Cena, Rok_Produkcji 
FROM Samochód 
WHERE Model = 'Audi A4';
GO

SET STATISTICS IO OFF;
GO