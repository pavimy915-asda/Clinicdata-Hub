use sample;

show tables;

select * from psg;

select distinct department_id from fact_admission;

-- creating dimension tables

-- 1)patient dimension

create table dim_patient(patient_id int primary key,patient_name varchar(80),gender varchar(10),age int);

-- 2)doctor dimension

create table dim_doc(doc_id int auto_increment primary key,departments varchar(70),doc varchar(70),diag varchar(70),flag varchar(20));


-- 3)facility dimension

create table  dim_facility(facility_id int auto_increment primary key,room varchar(40),ward varchar(10));

-- 4)revenue dimension

create table dim_revenue(revenue_id int primary key auto_increment,departments varchar(40),doc varchar(40),treatment varchar(40),cost decimal(10,2));

drop table dim_revenue;

-- 5) department dimension

create table dim_dpt(department_id int primary key,departments varchar(40),doc varchar(40));

drop table dim_dpt;

-- creating fact table

-- admission fact table

drop table fact_admission;

create table fact_admission(admission_id int primary key,patient_id int,doc_id int,facility_id int,
revenue_id int,department_id int,admit date,stay int,cost int,payment_mode varchar(70),company varchar(80),treatment varchar(50),
foreign key(patient_id) references dim_patient(patient_id),
foreign key(doc_id) references dim_doc(doc_id),
foreign key(facility_id) references dim_facility(facility_id),
foreign key(department_id) references dim_dpt(department_id));

drop table fact_admission;

-- data insertion into dimension tables and fact table

-- dim_patient
 
insert into dim_patient(patient_id,patient_name,gender,age)
select distinct patient_id,patient_name,gender,age from psg;

select * from dim_patient;
 
-- dim_doc 

update dim_doc set flag="Active";

insert into dim_doc(departments,doc,diag)
select distinct departments,doc,diag from psg;

select * from dim_doc;

-- APPLYING SCD-2 ON DIM_DOC

-- updating source table

update psg set diag="Numbness"
where doc="Dr_Sivakumar";

-- updating dim_doc
 
update dim_doc d join psg p on d.doc=p.doc
set d.flag="No records"
where d.doc="Dr_Sivakumar"
and d.flag="Active"
and d.diag<>p.diag;

-- inserting values into dim_doc
 
insert into dim_doc(departments,doc,diag,flag)
select distinct p.departments,p.doc,p.diag,"Active"
from psg p left join dim_doc d on p.doc=d.doc and d.flag="Active"
where p.doc="Dr_Sivakumar" and d.doc_id is null;

select * from dim_doc;

-- dim_facility
 
insert into dim_facility(room,ward)
select distinct room,ward from psg;

select * from dim_facility;

-- dim_revenue
 
insert into dim_revenue(departments,doc,treatment,cost)
select departments,doc,treatment,sum(cost) as total_cost from psg group by departments,doc,treatment;

-- dim_dpt

insert into dim_dpt(department_id,departments,doc)
select department_id,departments,doc from psg group by department_id,departments,doc;

select * from dim_dpt;

select * from psg;

select * from dim_revenue;

-- fact_admission 

insert into fact_admission(admission_id,patient_id,doc_id,facility_id,revenue_id,department_id,admit,stay,cost,payment_mode,company,treatment)
select 
p.admission_id,
p.patient_id,
dc.doc_id,
f.facility_id,
r.revenue_id,
dp.department_id,
p.admit,
p.stay,
p.cost,
p.payment_mode,
p.company,
p.treatment
from psg p
join dim_doc dc on p.departments=dc.departments and p.doc=dc.doc and p.diag=dc.diag
join dim_facility f on p.room=f.room and p.ward=f.ward
join dim_revenue r on p.treatment=r.treatment and p.departments=r.departments
join dim_dpt dp on p.department_id=dp.department_id and p.departments=dp.departments and p.doc=dp.doc;
-- where dc.flag="Active";  

select * from dim_revenue;

select * from fact_admission;

-- creating data marts

-- 1)cardiology mart

create view cardiology_mart as 
select f.admission_id,pt.patient_name,d.doc,d.diag,f.admit,f.stay,f.treatment
from fact_admission f 
join dim_patient pt on f.patient_id=pt.patient_id
join dim_doc d on f.doc_id=d.doc_id
where d.departments="cardiology";

select * from cardiology_mart; 


-- 2)ortho mart

create view ortho_mart as 
select f.admission_id,pt.patient_name,dc.doc,dc.diag,f.admit,f.stay,f.treatment
from fact_admission f 
join dim_patient pt on f.patient_id=pt.patient_id
join dim_doc dc on f.doc_id=dc.doc_id
where dc.departments="orthopedics"; 

select * from ortho_mart;

-- 3)neuro mart

create view neuro_mart as 
select f.admission_id,pt.patient_name,dc.doc,dc.diag,f.admit,f.stay,f.treatment
from fact_admission f 
join dim_patient pt on f.patient_id=pt.patient_id
join dim_doc dc on f.doc_id=dc.doc_id
where dc.departments="neurology";

select * from neuro_mart;  

-- 4) gen_med mart

create view gen_med_mart as 
select f.admission_id,pt.patient_name,dc.doc,dc.diag,f.admit,f.stay,f.treatment
from fact_admission f 
join dim_patient pt on f.patient_id=pt.patient_id
join dim_doc dc on f.doc_id=dc.doc_id
where dc.departments="general_medicine";

select * from gen_med_mart;

-- 5) hr mart

create view hr_mart as 
select gender,age,count(admission_id) as total_admissions,round(avg(stay),1) as avg_len_of_stay
from fact_admission f 
join dim_patient pt on f.patient_id=pt.patient_id
group by gender,age;

select * from hr_mart;

select count(total_admissions) from hr_mart where gender="female" and age between 30 and 80;


-- BUSINESS CASES

-- REVENUE AND FINANCE

-- 1)DEPARTMENT REVENUE

select departments,cost as total_revenue from dim_revenue; 

-- 2)YEARLY ADMISSION TREND

select year(admit),count(year(admit)) as total_admissions from fact_admission f group by year(admit);

create view yearly_Admission_trend as select year(admit),count(year(admit)) as total_admissions from fact_admission f group by year(admit);

select * from yearly_Admission_trend;

-- 3)AVERAGE REVENUE PER YEAR

select year(f.admit) as year,count(year(f.admit)) as total_admissions,round(avg(r.cost),2) as avg_revenue from fact_admission f join dim_revenue r on f.revenue_id=r.revenue_id group by year(admit);

select * from dim_revenue;

select * from psg;

select * from fact_admission;

-- 4)High value patient(usefull if data contains different cost)

select * from dim_revenue;

select patient_id,admission_id,sum(cost) as total_spent from fact_admission group by patient_id,admission_id
order by total_spent desc limit 5;

-- 5)Treatment wise revenue

select * from dim_revenue;

select treatment,sum(cost) as revenue from fact_admission f group by treatment;

select * from dim_facility;

-- 6) Average length of stay

select admission_id,avg(stay) from fact_admission group by admission_id order by stay desc;

-- 7) Department wise stay

select * from fact_admission;

select dp.department_id,dp.departments,round(avg(f.stay),2) as avg_len_of_stay from fact_admission f
join dim_dpt dp on f.department_id=dp.department_id group by f.department_id,dp.departments;

select * from dim_dpt;

-- 8) Order of first 5 long stayed patient with their admission_id and treatment 

select stay, admission_id,treatment from(select stay, admission_id,treatment,row_number()over(partition by stay order by admission_id desc) as top from fact_admission)stay
where top=1  -- top row in each stay group
order by stay desc
limit 5;

-- 9)  Total cases and peak admission

select treatment,count(treatment) as total_cases from fact_admission group by treatment order by total_cases desc;

select treatment,count(treatment) as total_cag from fact_admission where treatment="Angiogram";
select treatment,count(treatment) as tot_op from fact_admission where treatment="Medication";
select treatment,count(treatment) as tot_op from fact_admission where treatment="Therapy";
select treatment,count(treatment) as tot_adm from fact_admission where treatment="Surgery";

-- 10) Doctor workload

select * from fact_admission;
select * from dim_doc;
select dc.doc,count(dc.doc_id) as patient_flow from dim_doc dc join fact_admission f on dc.doc_id=f.doc_id group by dc.doc order by patient_flow desc;



