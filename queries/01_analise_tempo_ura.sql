-- ====================================================
-- Script: Análise de Tempo de Espera na URA
-- Autor: Luciano Prado
-- Objetivo: Identificar gargalos e horários de pico
-- ====================================================

-- CTE para calcular tempo médio de espera por hora
WITH TempoURA AS (
    SELECT 
        DATEPART(HOUR, DataHora) AS Hora,
        AVG(DATEDIFF(SECOND, InicioURA, FimURA)) AS TempoMedioSegundos,
        COUNT(*) AS TotalChamadas,
        SUM(CASE WHEN AbandonoURA = 1 THEN 1 ELSE 0 END) AS ChamadasAbandonadas
    FROM 
        TabelaChamadas
    WHERE 
        DataHora >= DATEADD(DAY, -30, GETDATE()) -- Últimos 30 dias
        AND InicioURA IS NOT NULL
    GROUP BY 
        DATEPART(HOUR, DataHora)
)

SELECT 
    Hora,
    TempoMedioSegundos,
    TempoMedioSegundos / 60.0 AS TempoMedioMinutos,
    TotalChamadas,
    ChamadasAbandonadas,
    CAST(ChamadasAbandonadas * 100.0 / TotalChamadas AS DECIMAL(5,2)) AS TaxaAbandono,
    -- Classificação de criticidade
    CASE 
        WHEN TempoMedioSegundos > 180 THEN 'Crítico'
        WHEN TempoMedioSegundos > 120 THEN 'Atenção'
        ELSE 'Normal'
    END AS StatusAtendimento
FROM 
    TempoURA
ORDER BY 
    TotalChamadas DESC;

-- Consulta complementar: Identificar dias da semana mais críticos
SELECT 
    DATENAME(WEEKDAY, DataHora) AS DiaSemana,
    AVG(DATEDIFF(SECOND, InicioURA, FimURA)) / 60.0 AS TempoMedioMinutos,
    COUNT(*) AS TotalChamadas
FROM 
    TabelaChamadas
WHERE 
    DataHora >= DATEADD(DAY, -30, GETDATE())
    AND InicioURA IS NOT NULL
GROUP BY 
    DATENAME(WEEKDAY, DataHora),
    DATEPART(WEEKDAY, DataHora)
ORDER BY 
    DATEPART(WEEKDAY, DataHora);
