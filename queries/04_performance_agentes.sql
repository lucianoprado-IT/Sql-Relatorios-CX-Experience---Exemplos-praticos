-- ====================================================
-- Script: Performance de Agentes
-- Autor: Luciano Prado
-- Objetivo: Análise de produtividade e qualidade
-- ====================================================

WITH MetricasAgentes AS (
    SELECT 
        AgenteID,
        NomeAgente,
        COUNT(*) AS TotalAtendimentos,
        AVG(DATEDIFF(SECOND, InicioAtendimento, FimAtendimento)) / 60.0 AS TMEMinutos,
        AVG(NotaSatisfacao) AS MediaSatisfacao,
        SUM(CASE WHEN Resolvido = 1 THEN 1 ELSE 0 END) AS AtendimentosResolvidos,
        SUM(CASE WHEN NotaSatisfacao >= 4 THEN 1 ELSE 0 END) AS AvaliacoesPositivas
    FROM 
        TabelaChamadas
    WHERE 
        DataHora >= DATEADD(DAY, -30, GETDATE())
        AND AgenteID IS NOT NULL
    GROUP BY 
        AgenteID, NomeAgente
    HAVING 
        COUNT(*) >= 50 -- Mínimo de atendimentos para análise
)

SELECT 
    AgenteID,
    NomeAgente,
    TotalAtendimentos,
    ROUND(TMEMinutos, 2) AS TMEMinutos,
    ROUND(MediaSatisfacao, 2) AS MediaSatisfacao,
    CAST(AtendimentosResolvidos * 100.0 / TotalAtendimentos AS DECIMAL(5,2)) AS TaxaResolucao,
    CAST(AvaliacoesPositivas * 100.0 / TotalAtendimentos AS DECIMAL(5,2)) AS TaxaSatisfacao,
    -- Score de Performance (0-100)
    (CAST(AtendimentosResolvidos * 100.0 / TotalAtendimentos AS DECIMAL(5,2)) * 0.4) +
    (CAST(AvaliacoesPositivas * 100.0 / TotalAtendimentos AS DECIMAL(5,2)) * 0.4) +
    (CASE WHEN TMEMinutos <= 5 THEN 20 ELSE 10 END) AS ScorePerformance,
    -- Classificação
    CASE 
        WHEN (CAST(AtendimentosResolvidos * 100.0 / TotalAtendimentos AS DECIMAL(5,2)) * 0.4) +
             (CAST(AvaliacoesPositivas * 100.0 / TotalAtendimentos AS DECIMAL(5,2)) * 0.4) +
             (CASE WHEN TMEMinutos <= 5 THEN 20 ELSE 10 END) >= 80 THEN 'Excelente'
        WHEN (CAST(AtendimentosResolvidos * 100.0 / TotalAtendimentos AS DECIMAL(5,2)) * 0.4) +
             (CAST(AvaliacoesPositivas * 100.0 / TotalAtendimentos AS DECIMAL(5,2)) * 0.4) +
             (CASE WHEN TMEMinutos <= 5 THEN 20 ELSE 10 END) >= 60 THEN 'Bom'
        ELSE 'Precisa Melhorar'
    END AS Classificacao
FROM 
    MetricasAgentes
ORDER BY 
    ScorePerformance DESC;
