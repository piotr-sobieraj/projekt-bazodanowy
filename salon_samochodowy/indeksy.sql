-- ============================================================================
-- PLIK: 11. indeksy.sql
-- OPIS: Demonstracja indeksów dla tabeli Samochód wraz z danymi testowymi
-- ============================================================================

-- ============================================================================
-- KROK 0: GENEROWANIE DANYCH TESTOWYCH (wymagane do zadania 2)
-- ============================================================================
PRINT '--- Generowanie danych testowych ---';

-- Dodajemy Salon (jeśli nie istnieje)
IF NOT EXISTS (SELECT * FROM Salon WHERE ID_Salon = 1)
    INSERT INTO Salon (ID_Salon, Adres) VALUES (1, 'Ulica Testowa 1');

-- Dodajemy Katalog (jeśli nie istnieje)
IF NOT EXISTS (SELECT * FROM Katalog WHERE ID_Katalog = 1)
    INSERT INTO Katalog (ID_Katalog, Typ_Kliienta, Salon_ID_Salon) VALUES (1, 'I', 1);

-- Dodajemy testowe samochody (jeśli tabela jest pusta)
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


-- ============================================================================
-- ZADANIE 1: DEMONSTRACJA INDEKSÓW KLASTROWYCH I NIEKLASTROWYCH
-- ============================================================================
PRINT '--- Tworzenie indeksów ---';

-- 1.1 Indeks Klastrowy został już utworzony przez klucz główny (ID_Samochód) 
-- Pokazujemy w wynikach wszystkie indeksy przypisane do tabeli Samochód:
EXEC sp_helpindex 'Samochód';

-- 1.2 Indeks Nieklastrowy (Non-Clustered Index) na kolumnie Model
IF EXISTS (SELECT name FROM sys.indexes WHERE name = 'IX_Samochod_Model')
    DROP INDEX IX_Samochod_Model ON Samochód;
GO

CREATE NONCLUSTERED INDEX IX_Samochod_Model 
ON Samochód (Model)
INCLUDE (Cena, Rok_Produkcji);
GO


-- ============================================================================
-- ZADANIE 2: REDUKCJA ODCZYTÓW I PLAN WYKONANIA
-- ============================================================================

-- Włączamy statystyki odczytów stron pamięci
SET STATISTICS IO ON;
GO

-- PRZYKŁAD A: Wyszukiwanie po kolumnie BEZ INDEKSU (np. Wersja)
-- Tutaj silnik wykona 'Clustered Index Scan' (przeczyta całą tabelę).
PRINT '--- Wyszukiwanie bez indeksu nieklastrowego (Scan) ---';
SELECT ID_Samochód, Model, Wersja 
FROM Samochód 
WHERE Wersja = 'Sport'; 
GO

-- PRZYKŁAD B: Wyszukiwanie po kolumnie Z INDEKSEM (Model)
-- Tutaj silnik wykona 'Index Seek' (dotrze bezpośrednio do danych).
PRINT '--- Wyszukiwanie z indeksem nieklastrowym (Seek) ---';
SELECT Model, Cena, Rok_Produkcji 
FROM Samochód 
WHERE Model = 'Audi A4';
GO

-- Wyłączamy statystyki
SET STATISTICS IO OFF;
GO