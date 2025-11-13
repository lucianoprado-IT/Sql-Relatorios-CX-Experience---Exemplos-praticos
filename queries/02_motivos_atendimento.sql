-- ====================================================
-- Script: Top Motivos de Atendimento
-- Autor: Luciano Prado
-- Objetivo: Identificar principais razões de contato
-- ====================================================

SELECT 
    MotivoContato,
    COUNT(*) AS TotalChamadas,
    AVG(DATEDIFF(SECOND, InicioAtendimento, FimAtendimento)) / 60.0 AS TMEMinutos,
    SUM(CASE WHEN Resolvido = 1 THEN 1 ELSE 0 END) AS ChamadasResolvidas,
    CAST(SUM(CASE WHEN Resolvido = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS TaxaResolucao,
    AVG(NotaSatisfacao) AS MediaSatisfacao
FROM 
    TabelaChamadas
WHERE 
    DataHora >= DATEADD(DAY, -30, GETDATE())
    AND MotivoContato IS NOT NULL
GROUP BY 
    MotivoContato
HAVING 
    COUNT(*) > 10 -- Apenas motivos com volume significativo
ORDER BY 
    TotalChamadas DESC;
