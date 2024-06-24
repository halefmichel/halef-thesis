/* Query to get the number of professionals in each CBO`s occupation in each district of São Paulo city */
SELECT r."CBO Ocupação 2002"                                                AS "id CBO 2002",
       round(avg("Vl Remun Média Nom"), 2)                                  AS "Salario medio",
       max(o.name)                                                          As "CBO Ocupação 2002",
       r."Distritos SP"                                                     AS "id Distritos SP",
       max(d.code)                                                          AS "Distritos SP",
       count(*) - sum(CASE WHEN r."Mês Desligamento" > 0 THEN 1 ELSE 0 END) AS "total de profissionais"
FROM rais_vinc_pub_sp_2018 r
         JOIN city_lkup c
              ON r.Município = c.id AND r.Município = 355030 /*Identificador do município de São Paulo capital*/
         LEFT JOIN district_lkup d
                   ON r."Distritos SP" = d.id
         JOIN occupations_cbo_lkup o ON r."CBO Ocupação 2002" = o.id
WHERE "Vl Remun Média Nom" > 0
  AND "Distritos SP" IS NOT NULL
GROUP BY r."CBO Ocupação 2002", r."Distritos SP"
ORDER BY "Distritos SP", "CBO Ocupação 2002";


/* Query to get the telework ability in each district of São Paulo city by year and quarter in the years 2018, 2019, 2020 and 2021 */
select "Distritos SP",
       Ano,
       sum(cast("total de profissionais" as integer))           as total_de_profissionais,
       round(avg(cast(teleworkable_score as real)), 3)          as avg_teleworkable_score,
       round(sum(cast("total de profissionais" as integer) * cast(teleworkable_score as real)) /
             sum(cast("total de profissionais" as integer)), 3) as weighted_avg_teleworkable_score
from (SELECT teleworkable_score_COD."Ano",
             teleworkable_score_COD."trimestre",
             final_translator."CBO CÓDIGO",
             final_translator."CBO TÍTULO",
             final_translator."PNAD CONTÍNUA _ COD(CÓDIGO)",
             final_translator."PNAD CONTÍNUA _COD(TÍTULO)",
             CBO."Distritos SP",
             CBO."total de profissionais",
             teleworkable_score_COD."teleworkable_score"
      FROM (SELECT *
            FROM CBO_2018_Distritos
            UNION ALL
            SELECT *
            FROM CBO_2019_Distritos
            UNION ALL
            SELECT *
            FROM CBO_2020_Distritos
            UNION ALL
            SELECT *
            FROM CBO_2021_Distritos) AS CBO
               LEFT JOIN final_translator ON CBO."id CBO 2002" = final_translator."CBO CÓDIGO"
               LEFT JOIN teleworkable_score_COD
                         ON final_translator."PNAD CONTÍNUA _ COD(CÓDIGO)" = teleworkable_score_COD."V4010" AND
                            teleworkable_score_COD."Ano" = CBO."Year"
      WHERE final_translator."CBO CÓDIGO" IS NOT NULL
        AND CBO."total de profissionais" > 0) t
where Ano IS NOT NULL
group by "Distritos SP", Ano
order by "Distritos SP", Ano;


select Ano,
       month,
       sum(cast("total" as integer))                   as total_de_profissionais,
       round(avg(cast(teleworkable_score as real)), 8) as avg_teleworkable_score,
       round(sum(cast("total" as integer) * cast(teleworkable_score as real)) /
             sum(cast("total" as integer)), 8)         as weighted_avg_teleworkable_score
from (SELECT teleworkable_score_COD."Ano",
             CBO.month,
             CBO.total,
             teleworkable_score_COD."teleworkable_score"
      FROM (SELECT *
            FROM CBO_2018_monthly
            union all
            SELECT *
            FROM CBO_2019_monthly
            union all
            SELECT *
            FROM CBO_2020_monthly
            union all
            SELECT *
            FROM CBO_2021_monthly) AS CBO
               LEFT JOIN final_translator ON CBO."id CBO 2002" = final_translator."CBO CÓDIGO"
               LEFT JOIN teleworkable_score_COD
                         ON final_translator."PNAD CONTÍNUA _ COD(CÓDIGO)" = teleworkable_score_COD."V4010" AND
                            teleworkable_score_COD."Ano" = CBO."Year" and CASE
                                                                              WHEN CBO.month IN (1, 2, 3) THEN 1
                                                                              WHEN CBO.month IN (4, 5, 6) THEN 2
                                                                              WHEN CBO.month IN (7, 8, 9) THEN 3
                                                                              WHEN CBO.month IN (10, 11, 12)
                                                                                  THEN 4 end =
                                                                          teleworkable_score_COD."trimestre"
      WHERE final_translator."CBO CÓDIGO" IS NOT NULL
        AND CBO.total > 0) t
where Ano IS NOT NULL
group by Ano, month
order by Ano, month;
