import random

from faker import Faker

import pandas as pd

fake = Faker()


departments={
"Cardiology":{"department_id":"2367","diagnosis":"Chest pain","doctor":"Dr_Siva_Vignesh","Tx":"Angiogram","cost":"180000"},
"Neurology":{"department_id":"1289","diagnosis":"Migraine","doctor":"Dr_Sivakumar","Tx":"Therapy","cost":"2500"},
"Orthopedics":{"department_id":"4532","diagnosis":"Fracture","doctor":"Dr_Sabarinathan","Tx":"Surgery","cost":"300000"},
"General_Medicine":{"department_id":"2987","diagnosis":"Viral_Fever","doctor":"Dr_Arunkumar","Tx":"Medication","cost":"2300"}
}

rooms=["General","ICU","Private"]
wards=["A","B","C"]

payments=["Cash","UPI","Insurance"]

hospital=[]

for i in range(1,801):

    admit=fake.date_between(
        start_date='-1y',
        end_date='today'
    )

    stay=random.randint(2,10)

for i in range(1,801):
    Dpt=random.choice(list(departments.keys()))
    dpt_details=departments[Dpt]

    record={
    'patient_id':i,
    'admission_id':1000+i,
    'patient_name':fake.name(),
    'gender':random.choice(["Male","Female"]),
    'age':random.randint(18,80),
    'departments':Dpt,
    'department_id':dpt_details['department_id'],
    'doc':dpt_details['doctor'],
    'room':random.choice(rooms),
    'ward':random.choice(wards),
    'diag':dpt_details['diagnosis'],
    'treatment':dpt_details['Tx'],
    'cost':dpt_details['cost'],
    'admit':fake.date_between(),
    'stay':random.randint(2,10),
    'payment_mode':random.choice(payments),
    'company':random.choice(["Govt_scheme","HDFC_insurance","Bajaj_insurance","Star_health"]),
}

    hospital.append(record)


df=pd.DataFrame(hospital)


df.to_csv("psg.csv",index=False)

print("Data extracted successfully!")



