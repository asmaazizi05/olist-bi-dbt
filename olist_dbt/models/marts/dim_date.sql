-- Hiérarchie : jour -> mois -> trimestre -> année. Calendrier 2016-2018 + jours fériés / événements (seed).
with spine as (
    select cast(d as date) as date_day
    from generate_series(date '2016-01-01', date '2018-12-31', interval 1 day) as t(d)
)

select
    s.date_day                                         as date_key,
    extract(year from s.date_day)                      as year,
    extract(quarter from s.date_day)                   as quarter,
    extract(month from s.date_day)                     as month,
    strftime(s.date_day, '%Y-%m')                      as year_month,
    monthname(s.date_day)                              as month_name,
    extract(day from s.date_day)                       as day_of_month,
    isodow(s.date_day)                                 as day_of_week,
    dayname(s.date_day)                                as day_name,
    isodow(s.date_day) in (6, 7)                       as is_weekend,
    h.event_name is not null                           as is_holiday_or_event,
    h.event_name,
    h.event_type
from spine s
left join {{ ref('ref_holidays_events') }} h on s.date_day = h.event_date
