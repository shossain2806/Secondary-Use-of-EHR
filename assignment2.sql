# Q.1
--   How many patients have ever been diagnosed with at least 1 ALS diagnosis code (ICD9: 
--   335.20; ICD10: G12.21)? How many have at least 2 diagnosis codes assigned at on different dates? 
#
-- atleast one
select count(distinct patid) as cn 
from "DEIDENTIFIED_PCORNET_CDM"."CDM_2022_JULY"."DEID_DIAGNOSIS"
where (dx_type = '09' and dx = '335.20') or
        (dx_type = '10' and dx = 'G12.21');

-- atleast two at different dates
select count(distinct patid) from (
    select 
        patid
        , admit_date
        , count(*) as diagnosis_count 
    from "DEIDENTIFIED_PCORNET_CDM"."CDM_2022_JULY"."DEID_DIAGNOSIS"
    where ((dx_type = '09' and dx = '335.20') or
             (dx_type = '10' and dx = 'G12.21')) 
    group by patid, admit_date
    order by diagnosis_count desc
) 
where diagnosis_count > 1;

# Q.2
-- Among those who have at least 1 ALS diagnosis, what is the mean and median age at their 
-- first ALS diagnosis? Remove patients whose age at diagnosis is above 90 years, and what is the mean 
-- and median age at first ALS now? 
#
SELECT 
    AVG(AGE_AT_VISIT) as MEAN
    , median(AGE_AT_VISIT) AS MEDIAN 
    FROM (
        SELECT 
            patid
            ,  AGE_AT_VISIT 
        FROM (
            select 
                patid
                , datediff('YEAR', min(BIRTH_DATE), min(admit_date)) as AGE_AT_VISIT 
            from "DEIDENTIFIED_PCORNET_CDM"."CDM_2022_JULY"."DEID_DIAGNOSIS"
            left join "DEIDENTIFIED_PCORNET_CDM"."CDM_2022_JULY"."DEID_DEMOGRAPHIC"
            using(patid)
            where (dx_type = '09' and dx = '335.20') or
                    (dx_type = '10' and dx = 'G12.21')
            group by patid
            order by AGE_AT_VISIT
        )
        where AGE_AT_VISIT < 90
    );

# Q.3
-- Among those who have at least 1 ALS diagnosis, how many females are in this cohort? How 
-- many males?
#

WITH Demograpics AS (
    SELECT 
        distinct patid
        , sex  
    from "DEIDENTIFIED_PCORNET_CDM"."CDM_2022_JULY"."DEID_DIAGNOSIS" 
    left join "DEIDENTIFIED_PCORNET_CDM"."CDM_2022_JULY"."DEID_DEMOGRAPHIC" 
    using(patid)
    where (dx_type = '09' and dx = '335.20') or
             (dx_type = '10' and dx = 'G12.21')
 )
SELECT 'Male' as Sex, count(*) as cn from Demograpics
where sex = 'M'
union all
SELECT 'Female' as Sex, count(*) as cn from Demograpics
where Demograpics.sex = 'F';


# Q.4 
-- Create a patient table for ALS patients (you can name it ALS_PT) with the following 
-- specifications and order by PATID
#

CREATE OR REPLACE TABLE "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS".ALS_PT AS ( 
    SELECT 
        patid
        , min(admit_date) as ALS_1DX_DATE
        , datediff('YEAR', min(BIRTH_DATE), min(admit_date)) as AGE_AT_1DX
        , min(sex) AS SEX, min(race) as RACE
        , min(hispanic) AS HISPANIC 
    from "DEIDENTIFIED_PCORNET_CDM"."CDM_2022_JULY"."DEID_DIAGNOSIS" 
    left join "DEIDENTIFIED_PCORNET_CDM"."CDM_2022_JULY"."DEID_DEMOGRAPHIC" 
    using(patid)
    where (dx_type = '09' and dx = '335.20') or
            (dx_type = '10' and dx = 'G12.21')
    group by patid
    order by patid
);

# Q.5
-- Create a mortality outcome table for the ALS patients who have passed away (You can call it ALS_PT_DEATH), 
-- with the following specifications and order by PATID:  
#
CREATE OR REPLACE TABLE "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS".ALS_PT_DEATH AS (
    select 
        patid
        , min(DEATH_DATE) as "ENDPOINT_DATE"
        , datediff('DAY', min(admit_date), min(DEATH_DATE)) as "DAYS_SINCE_ALS_DX1"  
        from "DEIDENTIFIED_PCORNET_CDM"."CDM_2022_JULY"."DEID_DIAGNOSIS" as diag
    inner join "DEIDENTIFIED_PCORNET_CDM"."CDM_2022_JULY"."DEID_DEATH" as death
    using (patid)
    where (dx_type = '09' and dx = '335.20') or
            (dx_type = '10' and dx = 'G12.21')
    group by patid
    order by patid  
);

# Q.6
-- Create a censor table for the ALS patients who is still alive (You can call it ALS_PT_ALIVE), 
--with the following specifications and order by PATID
#
CREATE OR REPLACE TABLE "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS".ALS_PT_ALIVE AS (
    WITH NOT_DEAD AS (
        SELECT 
            PATID
            , ALS_1DX_DATE from "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT"
        WHERE PATID NOT IN (   SELECT patid from "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT_DEATH")
    )
    SELECT 
        NOT_DEAD.PATID
        , last_visit.ENDPOINT_DATE
        , datediff('DAY', not_dead.ALS_1DX_DATE
        , last_visit.ENDPOINT_DATE) as DAYS_SINCE_ALS_DX1 
    from NOT_DEAD
    INNER JOIN (
        SELECT 
            PATID
            , MAX(admit_date) as ENDPOINT_DATE 
        from "DEIDENTIFIED_PCORNET_CDM"."CDM_2022_JULY"."DEID_DIAGNOSIS"
        group by patid
    ) as last_visit
    using (patid)
    order by patid  
);

# Q.7
--	Using tables created for Q4 – Q6, answer the following questions: 
#

-- 7.a How many ALS patients have survived for at least 5 (≥ 5) years?  -- 25
select count(*) as total_pat from "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT" as all_als
inner join "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT_DEATH" as all_death
using (patid)
where datediff(year, all_als.ALS_1DX_DATE, all_death.ENDPOINT_DATE) >= 5
 
-- 7.b How many ALS patients have survived for less than 3 years (< 3)? --190
select count(*) as total_pat from "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT" as all_als
inner join "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT_DEATH" as all_death
using (patid)
where datediff(year, all_als.ALS_1DX_DATE, all_death.ENDPOINT_DATE) < 5

-- 7.C What is the overall mortality rate of ALS patients? -- 51.2%
select (
    (
        SELECT count(*) as total_dead from "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT_DEATH"
    )  
    * 100 / 
    (
        SELECT COUNT(*) as total_als from "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT"
    )
) as ratio

-- 7.d What is the risk ratio of mortality between female and male ALS patients? 

-- 51.87% MALE
SELECT (
    ( 
        select count(*) as total_dead_male from "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT" as pat
        inner join "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT_DEATH" as dead
        using(patid)
        where sex = 'M' 
    ) 
    * 100 / 
    (
        SELECT COUNT(*) as total_als from "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT" where sex = 'M'
    )
) AS RATIO

-- 50.28% FEMALE
SELECT (
    ( 
        select count(*) as total_dead_female from "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT" as pat
        inner join "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT_DEATH" as dead
        using(patid)
        where sex = 'F' 
    ) 
    * 100 / 
    (
        SELECT COUNT(*) as total_als from "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT" where sex = 'F'
    )
) AS RATIO

-- 7.e What is the risk ratio of mortality between white and non-white patients?

-- 51.30% white
SELECT (
    ( 
        select count(*) as total_dead_white from "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT" as pat
        inner join "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT_DEATH" as dead
        using(patid)
        where race = '05' 
    ) 
    * 100 / 
    (
        SELECT COUNT(*) as total_als from "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT" where race = '05'
    )
) AS RATIO

-- 39.13% not white
SELECT (
    ( 
        select count(*) as total_dead_female from "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT" as pat
        inner join "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT_DEATH" as dead
        using(patid)
        where race != '05' 
    ) 
    * 100 / 
    (
        SELECT COUNT(*) as total_als from "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT" where race != '05'
        )
    ) AS RATIO

-- 7.f What is the risk ratio of mortality between patients with age at first ALS diagnosis <65 and ≥ 65 years old?  --

-- 42.74% < 65 
SELECT (
    ( 
        select count(*) as total from "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT" as pat
        inner join "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT_DEATH" as dead
        using(patid)
        where AGE_AT_1DX < 65 
    ) 
    * 100 / 
    (
        SELECT COUNT(*) as total_als from "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT" where AGE_AT_1DX < 65
    )
) AS RATIO

-- 63.37% >= 65 
SELECT (
    ( 
        select count(*) as total from "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT" as pat
        inner join "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT_DEATH" as dead
        using(patid)
        where AGE_AT_1DX >=65
    ) 
    * 100 / 
    (
        SELECT COUNT(*) as total_als from "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT" where AGE_AT_1DX >= 65
    )
) AS RATIO

-- 7.g What is the risk ratio of mortality between patients with ethnicity information and without? 

-- 41.01 with ethnicity information

SELECT (
    ( 
        select count(*) as total from "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT" as pat
        inner join "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT_DEATH" as dead
        using(patid)
        where hispanic in ('Y', 'N') 
    ) 
    * 100 / 
    (
        SELECT COUNT(*) as total_als from "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT" where hispanic in ('Y', 'N')
    )
) AS RATIO

-- 82.52 without ethnicity information

SELECT (
    ( 
        select count(*) as total from "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT" as pat
        inner join "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT_DEATH" as dead
        using(patid)
        where hispanic is null or hispanic not in ('Y', 'N') 
    ) 
    * 100 / 
    (
        SELECT COUNT(*) as total_als from "CLASS_MEMBER_MHMCB_DB"."CLASS_WORKS"."ALS_PT"
        where hispanic is null or hispanic not in ('Y', 'N')
    )
) AS RATIO




