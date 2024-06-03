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
WHERE "Vl Remun Média Nom" > 0 AND "Distritos SP" IS NOT NULL
GROUP BY r."CBO Ocupação 2002", r."Distritos SP"
ORDER BY "Distritos SP", "CBO Ocupação 2002";
