-- Ranking klientów wg wydatków
SELECT
    k.id_klient,
    k.nazwa,
    SUM(o.cena) AS SumaZakupow,

    ROW_NUMBER() OVER (ORDER BY ROUND(SUM(o.cena), -4) DESC) AS row_number,
    RANK() OVER (ORDER BY ROUND(SUM(o.cena), -4) DESC) AS rank,
    DENSE_RANK() OVER (ORDER BY ROUND(SUM(o.cena), -4) DESC) AS dense_rank

FROM Klient k
JOIN Oferta o ON k.id_klient = o.Klient_id_klient
GROUP BY k.id_klient, k.nazwa;

-- Ranking sprzedawców w salonach (PARTITION)
SELECT
    s.Salon_ID_Salon,
    s.ID_Sprzedawca,
    SUM(o.cena) AS Sprzedaz,

    ROW_NUMBER() OVER (
        PARTITION BY s.Salon_ID_Salon
        ORDER BY ROUND(SUM(o.cena), -4) DESC
    ) AS row_number,

    RANK() OVER (
        PARTITION BY s.Salon_ID_Salon
        ORDER BY ROUND(SUM(o.cena), -4) DESC
    ) AS rank,

    DENSE_RANK() OVER (
        PARTITION BY s.Salon_ID_Salon
        ORDER BY ROUND(SUM(o.cena), -4) DESC
    ) AS dense_rank

FROM Sprzedawca s
JOIN Oferta o ON s.ID_Sprzedawca = o.Sprzedawca_ID_Sprzedawca
GROUP BY s.Salon_ID_Salon, s.ID_Sprzedawca;

-- LAG – poprzednia sprzedaż (dzienna)
SELECT 
    t.Data,
    SUM(o.cena) AS Sprzedaz,

    LAG(SUM(o.cena), 1, 0) OVER (
        ORDER BY t.Data
    ) AS PoprzedniaSprzedaz

FROM Transakcja t
JOIN Oferta o
    ON t.Oferta_id_faktura = o.id_faktura
   AND t.Oferta_id_towar = o.id_towar
GROUP BY t.Data
ORDER BY t.Data;

-- LEAD – następna sprzedaż
SELECT
    t.Data,
    SUM(o.cena) AS Sprzedaz,

    LEAD(SUM(o.cena), 1, 0) OVER (
        ORDER BY t.Data
    ) AS NastepnaSprzedaz

FROM Transakcja t
JOIN Oferta o
    ON t.Oferta_id_faktura = o.id_faktura
   AND t.Oferta_id_towar = o.id_towar
GROUP BY t.Data
ORDER BY t.Data;

-- FIRST_VALUE i LAST_VALUE (najtańszy / najdroższy samochód)
SELECT
    ID_Samochód,
    Model,
    Cena,

    FIRST_VALUE(Model) OVER (
        ORDER BY Cena ASC
    ) AS NajtanszyModel,

    LAST_VALUE(Model) OVER (
        ORDER BY Cena ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS NajdrozszyModel

FROM Samochód;