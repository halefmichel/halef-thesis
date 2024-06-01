SELECT BF."PNAD CONTÍNUA _ COD(CÓDIGO)",
       BF."PNAD CONTÍNUA _COD(TÍTULO)",
       AVG(D.teleworkable) AS avg_teleworkable
FROM BF_convertion_table BF
         LEFT JOIN main.DN_ONET_Teleworkable D ON BF."O*NET-SOC 2010 (CÓDIGO)" = D."onetsoccode"
WHERE D.teleworkable IS NOT NULL
GROUP BY BF."PNAD CONTÍNUA _ COD(CÓDIGO)", BF."PNAD CONTÍNUA _COD(TÍTULO)";


SELECT PC.Ano,
       PC.Trimestre,
       PC."V4010",
       MIN(CASE WHEN PC."S01015" = 'Diária, em tempo integral' THEN 1 ELSE 0 END) AS S01015_binary,
       MIN(CASE WHEN PC."S01028" = 'Sim' THEN 1 ELSE 0 END)                       AS S01028_binary,
       MIN(CASE WHEN PC."S01029" = 'Sim' THEN 1 ELSE 0 END)                       AS S01029_binary,
       MIN(CASE WHEN PC."S01015" = 'Diária, em tempo integral' THEN 1 ELSE 0 END)
           * MIN(CASE WHEN PC."S01028" = 'Sim' THEN 1 ELSE 0 END)
           * MIN(CASE WHEN PC."S01029" = 'Sim' THEN 1 ELSE 0 END)                 AS minimum_conditions
FROM (SELECT *
      FROM pnad_continua_2018I1
      UNION ALL
      SELECT *
      FROM pnad_continua_2019I1
      UNION ALL
      SELECT *
      FROM pnad_continua_2022I1) PC
WHERE PC."V4010" != 'NA'
GROUP BY PC.Ano, PC.Trimestre, PC."V4010";


SELECT PNADC_vf.Ano,
       PNADC_vf.Trimestre,
       PNADC_vf."V4010",
       BF_technic."PNAD CONTÍNUA _COD(TÍTULO)",
       AVG(BF_technic.avg_teleworkable)                                    AS avg_teleworkable,
       MIN(PNADC_vf.minimum_conditions)                                    AS minimum_conditions,
       AVG(BF_technic.avg_teleworkable) * MIN(PNADC_vf.minimum_conditions) AS teleworkable_score
FROM BF_technic
         LEFT JOIN PNADC_vf ON BF_technic."PNAD CONTÍNUA _ COD(CÓDIGO)" = PNADC_vf."V4010"
WHERE V4010 IS NOT NULL
GROUP BY PNADC_vf.Ano, PNADC_vf.Trimestre, PNADC_vf."V4010";
