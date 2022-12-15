--
use database CLASS_MEMBER_MHMCB_DB;
use schema PROJECT_WORK;

--
set cdm_schema = 'DEIDENTIFIED_PCORNET_CDM.CDM_2022_JULY';
set prescribing = $cdm_schema || '.DEID_PRESCRIBING';
set demographic = $cdm_schema || '.DEID_DEMOGRAPHIC';
set procedures =  $cdm_schema || '.DEID_PROCEDURES';
set encounters =  $cdm_schema || '.DEID_ENCOUNTER';

create or replace table ALL_PROCEDURES as
with Procedures as (
    select patid, px, admit_date from identifier($procedures)
    where 
    admit_date < '2022-08-01' and (
        (
            raw_px_type = 'CPT4' 
            and 
            px in (
            '99201', '99202', '99203', '99204', '99205', '99212', '99213', '99214', '99215', '99341', '99342', '99343', 
                '99344', '99345', '99347', '99348', '99349', '99350'
            )
         )
        or 
        (
            raw_px_type = 'HCPCS' 
            and px in (
            'G0438', 'G0439', 'G9741'
            )
        )
    )
)
select 
distinct alm.patid
, iff(hcpcs1.proc_date is not null, '1', '0') as c1--G0438
, iff(hcpcs2.proc_date is not null, '1', '0') as c2 --G0439
, iff(hcpcs3.proc_date is not null, '1', '0') as c3 --G9741
, iff(cpt1.proc_date is not null, '1', '0') as c4--99201
, iff(cpt2.proc_date is not null, '1', '0') as c5--99202
, iff(cpt3.proc_date is not null, '1', '0') as c6--99203
, iff(cpt4.proc_date is not null, '1', '0') as c7--99204
, iff(cpt5.proc_date is not null, '1', '0') as c8--99205
, iff(cpt6.proc_date is not null, '1', '0') as c9--99212
, iff(cpt7.proc_date is not null, '1', '0') as c10--99213
, iff(cpt8.proc_date is not null, '1', '0') as c11--99214
, iff(cpt9.proc_date is not null, '1', '0') as c12--99215
, iff(cpt10.proc_date is not null, '1', '0') as c13--99341
, iff(cpt11.proc_date is not null, '1', '0') as c14--99342
, iff(cpt12.proc_date is not null, '1', '0') as c15--99343
, iff(cpt13.proc_date is not null, '1', '0') as c16--99344
, iff(cpt14.proc_date is not null, '1', '0') as c17--99345
, iff(cpt15.proc_date is not null, '1', '0') as c18--99347
, iff(cpt16.proc_date is not null, '1', '0') as c19--99348
, iff(cpt17.proc_date is not null, '1', '0') as c20--99349
, iff(cpt18.proc_date is not null, '1', '0') as c21--99350
from all_medication_records as alm
left join (
    select patid, min(admit_date) as proc_date from Procedures
    where px = 'G9741' 
    group by patid
    
) as hcpcs1
using(patid)
left join (
    select patid, min(admit_date) as proc_date from Procedures
    where px = 'G0439' 
    group by patid
    
) as hcpcs2
using(patid)
left join (
    select patid, min(admit_date) as proc_date from Procedures
    where px = 'G0438' 
    group by patid
    
) as hcpcs3
using(patid)
left join (
    select patid, min(admit_date) as proc_date from Procedures
    where px = '99201' 
    group by patid
    
) as cpt1
using(patid)
left join (
    select patid, min(admit_date) as proc_date from Procedures
    where px = '99202' 
    group by patid
    
) as cpt2
using(patid)
left join (
    select patid, min(admit_date) as proc_date from Procedures
    where px = '99203' 
    group by patid
    
) as cpt3
using(patid)
left join (
    select patid, min(admit_date) as proc_date from Procedures
    where px = '99204' 
    group by patid
    
) as cpt4
using(patid)
left join (
    select patid, min(admit_date) as proc_date from Procedures
    where px = '99205' 
    group by patid
    
) as cpt5
using(patid)
left join (
    select patid, min(admit_date) as proc_date from Procedures
    where px = '99212' 
    group by patid
    
) as cpt6
using(patid)
left join (
    select patid, min(admit_date) as proc_date from Procedures
    where px = '99213' 
    group by patid
    
) as cpt7
using(patid)
left join (
    select patid, min(admit_date) as proc_date from Procedures
    where px = '99214' 
    group by patid
    
) as cpt8
using(patid)
left join (
    select patid, min(admit_date) as proc_date from Procedures
    where px = '99215' 
    group by patid
    
) as cpt9
using(patid)
left join (
    select patid, min(admit_date) as proc_date from Procedures
    where px = '99341' 
    group by patid
    
) as cpt10
using(patid)
left join (
    select patid, min(admit_date) as proc_date from Procedures
    where px = '99342' 
    group by patid
    
) as cpt11
using(patid)
left join (
    select patid, min(admit_date) as proc_date from Procedures
    where px = '99343' 
    group by patid
    
) as cpt12
using(patid)
left join (
    select patid, min(admit_date) as proc_date from Procedures
    where px = '99344' 
    group by patid
    
) as cpt13
using(patid)
left join (
    select patid, min(admit_date) as proc_date from Procedures
    where px = '99345' 
    group by patid
    
) as cpt14
using(patid)
left join (
    select patid, min(admit_date) as proc_date from Procedures
    where px = '99347' 
    group by patid
    
) as cpt15
using(patid)
left join (
    select patid, min(admit_date) as proc_date from Procedures
    where px = '99348' 
    group by patid
    
) as cpt16
using(patid)
left join (
    select patid, min(admit_date) as proc_date from Procedures
    where px = '99349' 
    group by patid
    
) as cpt17
using(patid)
left join (
    select patid, min(admit_date) as proc_date from Procedures
    where px = '99350' 
    group by patid
    
) as cpt18
using(patid);


select count(*) from all_procedures; --3702
