# Supply Chain Control Tower: Shipment Exception Management

## Project Overview

This project develops a Control Tower-style analytics solution for identifying, investigating, and prioritizing shipment exceptions. The purpose is not only to report delivery performance, but to help logistics and operations teams decide which exception cases should be reviewed first and what type of follow-up may be appropriate.

The project was completed as a final Data Analytics Bootcamp project using Python, MySQL, and Tableau.

## Business Question

**How can operational data be used to identify, prioritize, and manage shipment exceptions to minimize their impact on service performance?**

Supporting questions:

1. What types of shipment exceptions occur most frequently?
2. Where are exceptions concentrated?
3. Which exceptions should operations prioritize?
4. What operational patterns are associated with high-priority exceptions?
5. What actions could operations take based on the findings?

## Data Source

The analysis uses the [DataCo Smart Supply Chain dataset](https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis).

The original main dataset contains 180,519 rows and 53 columns. One row represents an order-item line rather than one complete order. Because an order may contain several products, using the raw rows as separate shipments would overstate order and exception counts.

The dataset files are excluded from this repository because of file size, licensing, and data-governance considerations. They can be downloaded from the Kaggle source and placed in `data/raw/`.

## Tools Used

- **Python and Pandas:** data inspection, cleaning, validation, aggregation, and exploratory analysis
- **MySQL Workbench:** database validation, KPI calculation, business analysis, and priority queue queries
- **Tableau:** dashboard development, exception investigation, prioritization, and presentation story
- **Git and GitHub:** version control and project documentation

## Project Workflow

### 1. Initial Data Inspection

The first notebook examines the available files, column names, data types, missing values, duplicate records, delivery categories, and the meaning of one dataset row.

Delivery-related fields were checked for conflicting values within the same order. Delivery Status, shipping duration, shipping date, late-delivery risk, Shipping Mode, and Order Status returned zero order-level conflicts.

### 2. Data Cleaning and Order-Level Transformation

The data was converted from 180,519 order-item rows into 65,752 unique order records.

- Consistent order-level fields were retained once per Order ID.
- Item-level measures such as quantity and order value were aggregated.
- Unnecessary and sensitive customer fields were excluded from the analytical dataset.
- Dates and numeric fields were converted to appropriate data types.
- The final dataset was validated for unique Order IDs and required values.

The following analytical fields were created:

```text
delay_days = actual_shipping_days - scheduled_shipping_days
```

```text
is_delivery_exception = 1
when Delivery Status is Late delivery or Shipping canceled
```

### 3. Exploratory and SQL Analysis

Python was used to explore exception frequency, monthly performance, shipping modes, delay severity, geographical concentration, and order value.

The cleaned order-level data was then loaded into MySQL. SQL queries reproduced the KPIs and answered the supporting business questions. Because MySQL's direct local-file import was unavailable in the working environment, a Python helper script generated smaller SQL insert batches. MySQL validation confirmed that all 65,752 order records were loaded successfully.

### 4. Tableau Control Tower

The Tableau workbook contains:

- A presentation story explaining the business problem and analytical approach
- Exception volume and monthly exception-rate analysis
- Shipping-mode risk comparison
- Delay-severity and regional concentration analysis
- High-priority order and value exposure analysis
- Recommended operational actions and a priority action queue

Open or download the packaged workbook: [Supply Chain Exception Control Tower](tableau/supply_chain_exception_control_tower.twbx)
https://public.tableau.com/app/profile/iffah.nurahmah/viz/supply_chain_exception_control_tower_story_v5/ControlTowerStory

## Priority Framework

A transparent rule-based framework was proposed:

| Priority | Rule |
|---|---|
| High | Shipping canceled, or late by at least 3 days |
| Medium | Late by 2 days |
| Low | Late by 1 day |
| No Exception | On-time or advance shipping |

This is an analytical starting rule, not an official company service-level agreement. A real organization should validate the thresholds using customer commitments, operational costs, and internal policies.

High-priority orders are sorted first by cancellation status, followed by delay severity and order value. Severity determines entry into the priority category; order value helps refine the review sequence within the queue.

## Key Findings

- The cleaned dataset contains **65,752 unique orders**.
- **38,903 orders** were delivery exceptions, producing a **59.2% exception rate**.
- Late deliveries accounted for **36,048 exceptions**, while **2,855 shipments** were canceled.
- Monthly exception rates remained between approximately **56.9% and 61.6%**, indicating a persistent rather than strongly seasonal problem.
- First Class recorded a **100% exception rate** because its one-day scheduled duration was consistently exceeded or the shipment was canceled.
- Second Class produced the largest high-priority workload, with **5,430 high-priority orders**.
- **7,763 orders** were classified as high priority, representing approximately **$3.88 million in exposed order value**.
- Western Europe and Central America contained the highest regional concentrations of high-priority orders.

The exposed order value is not confirmed financial loss. The dataset does not contain delay penalties, refunds, lost-sales values, or service-recovery costs.

## Recommended Operational Actions

The action labels are analytical recommendations created for this project; they are not original instructions from the dataset.

| Observed condition | Proposed action |
|---|---|
| Canceled shipment with Suspected Fraud order status | Fraud or payment review |
| Other canceled shipment | Cancellation investigation |
| Delay of at least 3 days | Severe-delay escalation |
| Delay of 2 days | Carrier follow-up |
| Delay of 1 day | Routine monitoring |
| No delivery exception | No immediate action |

In a real Control Tower, these actions would be supported by case owners, workflow status, escalation timestamps, resolution timestamps, and service-level targets.

## Repository Structure

```text
supply-chain-exception-control-tower/
├── data/
│   ├── raw/                  # Source datasets are not tracked
│   └── processed/            # Generated cleaned data is not tracked
├── notebooks/
│   ├── 01_data_inspection.ipynb
│   ├── 02_data_cleaning.ipynb
│   └── 03_exploratory_analysis.ipynb
├── scripts/
│   └── create_mysql_import_batches.py
├── sql/
│   ├── 01_create_database.sql
│   ├── 02_import_clean_data.sql
│   ├── 03_validate_database.sql
│   ├── 04_business_analysis.sql
│   └── README.md
├── tableau/
│   └── supply_chain_exception_control_tower.twbx
├── .gitignore
└── README.md
```

## How to Reproduce the Project

1. Download the DataCo dataset from Kaggle.
2. Place the CSV files inside `data/raw/`.
3. Run the notebooks in numerical order.
4. Use the cleaned CSV generated in `data/processed/` for the database import.
5. Run the SQL files in numerical order in MySQL Workbench.
6. Open the packaged Tableau workbook in the `tableau/` folder.

The batch-generation script is only required when direct CSV import is blocked. See `sql/README.md` for the MySQL process.

## Limitations

- Order ID is used as the shipment-analysis unit because the dataset does not provide a separate shipment ID.
- The dataset does not include carrier names, warehouse processing events, route details, or exception reason codes.
- Recommended actions and priority thresholds have not been validated against a real company's SLA.
- Order value represents financial exposure, not actual exception cost.
- The analysis identifies associations and operational patterns; it does not establish causal relationships.

## Possible Next Steps

- Add carrier, warehouse, route, and tracking-event data for root-cause analysis.
- Add case owner, resolution status, and response timestamps for workflow monitoring.
- Measure time to acknowledge, time to resolve, backlog, and SLA compliance.
- Validate the priority rules with operations managers and customer-service policies.
- Consider predictive modelling only if suitable pre-shipment risk variables and a clear early-warning use case become available.

## Author

**Iffah Nurahmah**
Data Analytics Bootcamp - Ironhack
