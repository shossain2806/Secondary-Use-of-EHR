use database CLASS_MEMBER_MHMCB_DB;
use schema PROJECT_WORK;
set cdm_schema = 'DEIDENTIFIED_PCORNET_CDM.CDM_2022_JULY';
set demographic = $cdm_schema || '.DEID_DEMOGRAPHIC';
set encounters = $cdm_schema || '.DEID_ENCOUNTER';
set death = $cdm_schema || '.DEID_DEATH';

create or replace table HRM_INIT as 
select 
    dm.patid
    , dm.birth_date
    , dm.sex
    , dm.race
    , dm.hispanic
    , rec1.first_dose as first_dose
    , rec1.AGE_AT_FIRST_DOSE
    , rec2.AGE_AT_LAST_DOSE
    , rec4.TOTAL_MEDICATION_TYPE
    , iff(rec3.death_date is null, '0', '1') as IS_DEAD
    , datediff('YEAR', rec1.first_dose, rec3.death_date) as DEATH_AFTER_FIRST_DOSE
from identifier($demographic) as dm
inner join (
    select patid, min(AGE_AT_DOSE) as AGE_AT_FIRST_DOSE, min(rx_start_date) as first_dose from ALL_MEDICATION_RECORDS
    group by patid
) as rec1
using (patid) 
inner join (
    select patid, max(AGE_AT_DOSE) as AGE_AT_LAST_DOSE from ALL_MEDICATION_RECORDS
    group by patid
) as rec2
using (patid) 
left join (
    select patid, min(death_date) as death_date from identifier($death)
    group by patid
) as rec3
using (patid)
inner join(
    select patid, count(distinct rxnorm_cui) as TOTAL_MEDICATION_TYPE from ALL_MEDICATION_RECORDS
    group by patid
) as rec4
using(patid)
inner join all_procedures as t2
on dm.patid = t2.patid
and (
    c1='0'and 
    (
        c2='1'or
        c3='1'or
        c4='1'or
        c5='1'or
        c6='1'or
        c7='1'or
        c8='1'or
        c9='1'or
        c10='1'or
        c11='1'or
        c12='1'or
        c13='1'or
        c14='1'or
        c15='1'or
        c16='1'or
        c17='1'or
        c18='1'or
        c19='1'or
        c20='1'or
        c21='1'
    )
)

order by patid
;

alter table hrm_init
add column total_visits_before_first_dose int default 0;
alter table hrm_init 
add column total_visits_after_first_dose int default 0;


update  hrm_init as hrm
set total_visits_before_first_dose = enc1.total_visits_before_first_dose
FROM (
    select patid, count(*) as total_visits_before_first_dose from (
        select patid, admit_date from identifier($encounters) as enc
        inner join hrm_init
        using(patid)
        having enc.admit_date < hrm_init.first_dose and enc.admit_date >= '2012-01-01'
    )
    group by patid
                                                                           
) as enc1
WHERE hrm.patid = enc1.patid;

update  hrm_init as hrm
set total_visits_after_first_dose = enc2.total_visits_after_first_dose
FROM (
    select patid, count(*) as total_visits_after_first_dose from (
        select patid, admit_date from identifier($encounters) as enc
        inner join hrm_init
        using(patid)
        having enc.admit_date >= hrm_init.first_dose and enc.admit_date < '2022-08-01'
    )
    group by patid
                                                                           
) as enc2
WHERE hrm.patid = enc2.patid;

--
select count(*) from hrm_init; -- 3360
