IF NOT EXISTS (SELECT * FROM sys.filegroups WHERE name = 'FG_Kwartal_1') ALTER DATABASE Salon ADD FILEGROUP FG_Kwartal_1;
IF NOT EXISTS (SELECT * FROM sys.filegroups WHERE name = 'FG_Kwartal_2') ALTER DATABASE Salon ADD FILEGROUP FG_Kwartal_2;
IF NOT EXISTS (SELECT * FROM sys.filegroups WHERE name = 'FG_Kwartal_3') ALTER DATABASE Salon ADD FILEGROUP FG_Kwartal_3;
IF NOT EXISTS (SELECT * FROM sys.filegroups WHERE name = 'FG_Kwartal_4') ALTER DATABASE Salon ADD FILEGROUP FG_Kwartal_4;
GO

IF NOT EXISTS (SELECT * FROM sys.database_files WHERE name = 'Plik_Q1') ALTER DATABASE Salon ADD FILE (NAME = N'Plik_Q1', FILENAME = N'C:\baza_salon\Q1.ndf', SIZE = 5MB, FILEGROWTH = 1MB) TO FILEGROUP FG_Kwartal_1;
IF NOT EXISTS (SELECT * FROM sys.database_files WHERE name = 'Plik_Q2') ALTER DATABASE Salon ADD FILE (NAME = N'Plik_Q2', FILENAME = N'C:\baza_salon\Q2.ndf', SIZE = 5MB, FILEGROWTH = 1MB) TO FILEGROUP FG_Kwartal_2;
IF NOT EXISTS (SELECT * FROM sys.database_files WHERE name = 'Plik_Q3') ALTER DATABASE Salon ADD FILE (NAME = N'Plik_Q3', FILENAME = N'C:\baza_salon\Q3.ndf', SIZE = 5MB, FILEGROWTH = 1MB) TO FILEGROUP FG_Kwartal_3;
IF NOT EXISTS (SELECT * FROM sys.database_files WHERE name = 'Plik_Q4') ALTER DATABASE Salon ADD FILE (NAME = N'Plik_Q4', FILENAME = N'C:\baza_salon\Q4.ndf', SIZE = 5MB, FILEGROWTH = 1MB) TO FILEGROUP FG_Kwartal_4;
GO

IF NOT EXISTS (SELECT * FROM sys.partition_functions WHERE name = 'PF_Kwartaly_Data')
    EXEC('CREATE PARTITION FUNCTION PF_Kwartaly_Data (DATE) AS RANGE RIGHT FOR VALUES (''2023-04-01'', ''2023-07-01'', ''2023-10-01'');');
GO

IF NOT EXISTS (SELECT * FROM sys.partition_schemes WHERE name = 'PS_Kwartaly_Data')
    EXEC('CREATE PARTITION SCHEME PS_Kwartaly_Data AS PARTITION PF_Kwartaly_Data TO (FG_Kwartal_1, FG_Kwartal_2, FG_Kwartal_3, FG_Kwartal_4);');
GO

-- PRZYGOTOWANIE TABELI TRANSAKCJA
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'Faktura_Transakcja_FK')
    ALTER TABLE Faktura DROP CONSTRAINT Faktura_Transakcja_FK;
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'Transakcja_PK' AND object_id = OBJECT_ID('Transakcja'))
    ALTER TABLE Transakcja DROP CONSTRAINT Transakcja_PK;
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Transakcja_PartycjaData' AND object_id = OBJECT_ID('Transakcja'))
    DROP INDEX IX_Transakcja_PartycjaData ON Transakcja;
GO

-- UTWORZENIE NOWYCH INDEKSÓW
ALTER TABLE Transakcja ADD CONSTRAINT Transakcja_PK PRIMARY KEY NONCLUSTERED (Transakcja_ID) ON [PRIMARY];
GO

ALTER TABLE Faktura ADD CONSTRAINT Faktura_Transakcja_FK FOREIGN KEY (Transakcja_Transakcja_ID) REFERENCES Transakcja(Transakcja_ID);
GO

CREATE CLUSTERED INDEX IX_Transakcja_PartycjaData 
ON Transakcja (Data) 
ON PS_Kwartaly_Data (Data);
GO

-- Usypiamy tymczasowo sprawdzanie powiązań z tabelą Oferta
ALTER TABLE Transakcja NOCHECK CONSTRAINT Transakcja_Oferta_FK;

-- Czyścimy tabelę, aby w wynikach były dokładnie 4 transakcje
DELETE FROM Transakcja;

INSERT INTO Transakcja (Oferta_id_faktura, Oferta_id_towar, Data) VALUES 
(1, 1, '2023-02-15'), -- Q1
(1, 2, '2023-05-10'), -- Q2
(2, 1, '2023-08-20'), -- Q3
(3, 1, '2023-11-05'); -- Q4

-- Budzimy sprawdzanie powiązań z powrotem
ALTER TABLE Transakcja WITH NOCHECK CHECK CONSTRAINT Transakcja_Oferta_FK;
GO

SELECT 
    p.partition_number AS Numer_Partycji,
    fg.name AS Grupa_Plikow,
    p.rows AS Liczba_Rekordow
FROM sys.partitions p
JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN sys.partition_schemes ps ON i.data_space_id = ps.data_space_id
JOIN sys.destination_data_spaces dds ON ps.data_space_id = dds.partition_scheme_id AND p.partition_number = dds.destination_id
JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id
WHERE p.object_id = OBJECT_ID('Transakcja') AND i.index_id = 1;
GO