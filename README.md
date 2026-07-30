# BrightLearn Data Warehouse - Data Engineering Assessment

A SQL Server data warehouse implementation demonstrating the medallion architecture pattern (Bronze → Silver → Gold layers) for the BrightLearn retail POS system.

## Project Overview

This project builds a complete data pipeline for analyzing BrightLearn point-of-sale data. The implementation uses SQL Server for data storage and SSIS for ETL orchestration, following modern data warehouse design principles.

## Architecture

**Three-Layer Medallion Pattern:**
- **Bronze Layer**: Raw data landing zone from CSV exports
- **Silver Layer**: Cleaned and standardized data with business rules applied
- **Gold Layer**: Dimensional model ready for analytics and reporting

## Project Structure

```
├── documentation/
│   ├── Architecture_Diagram.png
│   └── Business_Questions.md
├── sql_scripts/
│   ├── 01_Create_Databases.sql
│   ├── 02_Bronze_Landing_Schema.sql
│   ├── 03_Silver_Cleansing_Procedure.sql
│   ├── 04_Gold_Star_Schema.sql
│   └── 05_Business_Questions_BQ01_to_BQ08.sql
├── ssis_packages/
│   └── Load_CSV_To_Bronze.dtsx
├── sample_data/
│   └── BrightLearn_POS_Export.csv
└── README.md
```

## Setup Instructions

1. **Create Databases** - Run `01_Create_Databases.sql` to initialize Bronze, Silver, and Gold databases
2. **Build Bronze Schema** - Execute `02_Bronze_Landing_Schema.sql` to set up the landing tables
3. **Deploy SSIS Package** - Load `Load_CSV_To_Bronze.dtsx` into SQL Server Integration Services
4. **Run Cleansing** - Execute the stored procedures in `03_Silver_Cleansing_Procedure.sql`
5. **Create Gold Layer** - Run `04_Gold_Star_Schema.sql` to build the analytics-ready dimensional model

## Analysis

The warehouse supports eight key business questions covering sales performance, customer behavior, and inventory metrics. See `Business_Questions.md` for detailed queries and insights.

## Technologies

- **SQL Server** - Data storage and transformation
- **SSIS** - ETL pipeline orchestration
- **T-SQL** - Data manipulation and stored procedures

## Dataset

Sample data from `BrightLearn_POS_Export.csv` contains point-of-sale transactions including product sales, customer information, and transaction details.

