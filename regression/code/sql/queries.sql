SELECT year,
       id,
       nm_distrit,
       ROUND(AVG(price_real_month), 3)           AS avg_rent,
       ROUND(AVG(CAST(teleworkable AS REAL)), 3) AS avg_teleworkable
FROM rent_2018_2021_out
GROUP BY year, nm_distrit
ORDER BY nm_distrit;

SELECT id,
       nm_distrit,
       ROUND(AVG(inequality_meter), 3)                                                                               AS inequality_meter,
       ROUND(AVG(CAST(delta_cbd_farialima AS REAL)), 3)                                                              AS avg_dist_cbd,
       ROUND(AVG(inequality_meter) * (1 / AVG(CAST(delta_cbd_farialima AS REAL))), 3)                                AS score,
       RANK() OVER (ORDER BY ROUND(AVG(inequality_meter) * (1 / AVG(CAST(delta_cbd_farialima AS REAL))), 3) DESC)    AS rank
FROM rent_2018_2021_out
GROUP BY nm_distrit
ORDER BY rank;
