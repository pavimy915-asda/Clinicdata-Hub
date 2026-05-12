Clinicdata-Hub: Healthcare Data Warehouse & Analytics

This project demonstrates an end-to-end Healthcare Data Warehousing (DWH) solution. It includes automated synthetic data generation, an ETL process into a Star Schema, implementation of Slowly Changing Dimensions (SCD Type 2), and the creation of specialized Data Marts for clinical business cases.

Tech Stack
Python: Used for synthetic data generation (Faker, Pandas).

SQL (MySQL): Used for DWH architecture, Fact/Dimension modeling, and Data Marts.

Data Modeling: Star Schema design.

Project Architecture
1. Data Generation (generate_data.py)
Used Python's Faker library to generate 800+ realistic clinical records, including:

Patient demographics.

Department-specific diagnoses (Cardiology, Neurology, Orthopedics, etc.).

Hospital logistics (Wards, Room types, Payment methods).

2. Data Warehouse Schema (dwh_project.sql)
The database follows a Star Schema to optimize query performance:

Fact Table: fact_admission (Metrics: Cost, Stay Duration, Admission Dates).

Dimension Tables: dim_patient, dim_doc, dim_facility, dim_revenue, and dim_dpt.

3. Advanced SQL Implementation (SCD Type 2)
Implemented Slowly Changing Dimension (SCD) Type 2 on the dim_doc table. This allows the warehouse to track historical changes (e.g., a doctor changing departments) using:

Flags: Tracking "Active" vs "Inactive" records.

Joins: Using Left Joins and NULL checks to handle record updates and insertions.

4. Specialized Data Marts
Created View-based Data Marts to serve specific hospital departments:

Cardiology / Ortho / Neuro Marts: Filtered clinical data for department-specific analysis.

HR Mart: Analyzes patient volume and average length of stay by gender and age.

Business Insights Generated
The project answers critical healthcare business questions:

Revenue Analysis: Total revenue by department and yearly admission trends.

Clinical Efficiency: Average length of stay (LOS) per department.

Patient Analytics: Identifying "High-Value Patients" based on treatment costs.

How to Run
Generate Data: Run python generate_data.py to create the initial dataset.

Setup DWH: Execute the dwh_project.sql script in your MySQL environment.

Verify Marts: Query the view tables (e.g., SELECT * FROM cardiology_mart) to see processed insights.


