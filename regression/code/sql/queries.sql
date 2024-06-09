select avg(price_real_month)           as avg_rent,
       avg(cast(teleworkable as real)) as avg_teleworkable,
       year,
       district
from rent_2018_2021_out
group by year, district, cast(teleworkable as real);


select *
from rent_2018_2021_out;
