--
use database CLASS_MEMBER_MHMCB_DB;
use schema PROJECT_WORK;

--
set cdm_schema = 'DEIDENTIFIED_PCORNET_CDM.CDM_2022_JULY';
set prescribing = $cdm_schema || '.DEID_PRESCRIBING';
set demographic = $cdm_schema || '.DEID_DEMOGRAPHIC';
set procedures =  $cdm_schema || '.DEID_PROCEDURES';
set encounters =  $cdm_schema || '.DEID_ENCOUNTER';

--
Create or replace table ALL_MEDICATION_RECORDS as
select patid, encounterid, enc.admit_date as admit_date,datediff('YEAR', dem.birth_date, dp.rx_start_date) as AGE_AT_DOSE, rxnorm_cui, rx_start_date, rx_end_date, rx_dose_ordered, rx_dose_ordered_unit, rx_quantity,rx_refills, rx_frequency from identifier($prescribing) as dp
inner join identifier($demographic) as dem
using (patid)
inner join identifier($encounters) as enc
using (encounterID)
where
AGE_AT_DOSE >= 65
-- Methyldopa
and (RXNORM_CUI in ('197958', '201361', '214620','446452','485001','688647','197955','201354','375876',
'372854','411775','540389','688645','208028','104357','197961','197963','197956','201355','208008','372855',
'6876','411773','688643','197962','201358','208011','197957','376259','411774','197960','208020','311645','688649'
)
or RXNORM_CUI in ('372368','862023','1092571','206413','862028','862029','1092570','197746','862012','862016','862006',
'862011','862015','862027','1092566','197745','206412','862013','862022','862005','862019','40114','862021','862010','862017','862025'
)
--disopyramide
or RXNORM_CUI in ('902653','104284','209692','209972','415552','412273','411716','636794','371938','439121',
'309961','3541','371935','199543','371936','371937','439127','210242','209066','388730','902648','902649','636793',
'104285','199824','309960','411038','415737','428917','902652','199730','309958','309959','428918')
-- Nifedipine
or RXNORM_CUI in ('108781','152601','153223','152730','198032','198033','248708','252192','314132','311979','541611','672920','227122',     '200884','672921','844440','844442','844410','844852','844419','844428','844435','844724','108745','150753','153914','201449','200883',
'201455','246262','311981','360393','360394','360397','380915','373068','491070','351438','434570','491078','545054','360396','672917',
'7417','844586','844461','844727','844450','844462','844923','844460','845005','845008','844420','844723','844725','844430','844726','91691',
'844731','108494','152906','153593','198034','1812013','207769','207774','360395','602209','226663','433843','431813','227061','102338',
'151085','152731','199329','207765','227119','311980','373070','415900','227059','404110','844730','844748','844431','844436','844438',
'103944','108842','153538','201457','201458','226536','248631','542723','434135','446659','844728','844729','844456','844929','844750',
'845004','844721','880433','844443','844459','845006','845007','844421','104411','151244','201450','201451','201452','201456','207772',
'227060','250384','446660','373067','391901','207773','844439','844444','844741','844457','844846','844416','844424','844429','844434',
'880438','844745','104412','102337','153594','152801','152908','153103','199782','200885','1812015','227121','249620','380906','380907',
'373069','201453','104414','153308','153320','152909','198035','198036','200886','1812011','226347','227058','250206','284258','360392',
'391980','672916','380908','541603','227083','672918','491086','844441','844584','844585','844455','844458','844830','844722','91692',
'880434','880437')
) and
rx_start_date < '2022-08-01';

select count(*) from all_medication_records; -- 20608

