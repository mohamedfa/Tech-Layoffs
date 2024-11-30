# Tech Layoffs Dataset: COVID-2019 to Present
<div align="center">
  <img src="https://github.com/user-attachments/assets/f9c250b0-353e-48ad-97b2-6d1278a98920" alt="Layoff" width="500"/>
</div>


This repository contains a dataset of tech layoffs from COVID-2019 to the present, sourced from Kaggle. The dataset tracks tech industry layoffs reported by prominent platforms such as **Bloomberg**, **San Francisco Business Times**, **TechCrunch**, and **The New York Times**. This project involved cleaning, exploring, and visualizing the dataset to uncover insights into the impact of layoffs on the tech industry over time.

## Dataset Overview

- **Source**: Kaggle - [Layoffs Dataset](https://www.kaggle.com/datasets/swaptr/layoffs-2022)
- **Data Timeline**: March 2020 to November 2024
- **Data Sources**: Bloomberg, San Francisco Business Times, TechCrunch, The New York Times
- **Key Columns**:
  - `company`: Company name
  - `location`: Location of the company
  - `industry`: Industry of the company
  - `total_laid_off`: Total number of layoffs
  - `percentage_laid_off`: Percentage of workforce laid off
  - `date`: Date of the layoff announcement
  - `stage`: Stage of the company (e.g., pre-IPO, post-IPO)
  - `country`: Country where the company is located
  - `funds_raised`: Amount of funds raised by the company

## Project Workflow

### 1. **Data Cleaning and Preprocessing** (Using SQL with MS SQL Server)
![image](https://github.com/user-attachments/assets/c79cff60-d4f1-4e68-9049-4fedcae4ee81)


I started by creating a clean and structured dataset by performing the following steps:

#### Copying Data to a Staging Table:
```sql
select * into layoffs_staging from layoffs
```

#### Creating Unique Identifiers:
Since there was no unique ID column, I created a row number for identifying and removing duplicates:
```sql
select *, ROW_NUMBER() over(partition by company, [location], industry, total_laid_off, percentage_laid_off, [date], stage, country, funds_raised order by company) as row_num from layoffs_staging
```

#### Removing Duplicates:
I identified and removed duplicate rows based on relevant columns:
```sql
delete from layoffs_staging2 where duplicates > 1
```

#### Data Standardization:
I standardized data such as company names and countries:
```sql
update layoffs_staging2 set company = trim(company)
update layoffs_staging2 set country = 'United Arab Emirates' where country = 'UAE'
```

#### Handling Null Values:
I removed rows where both `total_laid_off` and `percentage_laid_off` were null:
```sql
delete from layoffs_staging2 where total_laid_off is null and percentage_laid_off is null
```

### 2. **Exploratory Data Analysis** (Using SQL)
![image](https://github.com/user-attachments/assets/82bde22f-28d9-4707-9795-165afa299ac8)


I performed several analyses to understand the data and identify key trends. Some of the key queries included:

#### Total Number of Companies Affected by Layoffs:
```sql
select count(distinct company) from layoffs_staging2
```

#### Minimum and Maximum Layoffs:
```sql
select min(total_laid_off), max(total_laid_off) from layoffs_staging2
```

#### Top 5 Countries with the Highest Layoffs:
```sql
select top(5) country, sum(total_laid_off) as [total laid off] from layoffs_staging2 group by country order by 2 desc
```

#### Layoffs Over Time:
```sql
select year([date]) as [year], sum(total_laid_off) as [total laid off] from layoffs_staging2 group by year([date]) order by 1
```

#### Top 5 Companies with the Highest Layoffs Every Year:
```sql
select * from company_ranking_of_year where ranking <= 5
```

### 3. **Data Visualization** (Using Power BI)

The insights derived from the SQL analysis were visualized using Power BI, which included the following KPIs and charts:

#### Key Performance Indicators (KPIs):
- **Total Companies**: 2,350
- **Start Date**: March 2020 (First Layoff)
- **End Date**: November 2024 (To Present)
- **Minimum Layoffs**: 3
- **Maximum Layoffs**: 15,000
- **Total Layoffs**: 674,000

#### Key Charts:
- **Line Chart**: Total layoffs by date – Highlights the significant spike in layoffs in 2023 with 264,000 layoffs.
- **Donut Chart**: Top 5 countries by total layoffs – The United States leads with 455,331 layoffs (78.58%).
- **Column Chart**: Top 5 stages by total layoffs – Post-IPO is the highest stage by layoffs with 375,000 layoffs.
- **Bar Chart**: Top 10 companies by total layoffs – Amazon has the highest total layoffs (28,000), followed by Meta and Intel.
- **Bar Chart**: Top 10 industries by total layoffs – Retail and Consumer industries had the most layoffs, with Retail at 72,000 and Consumer at 71,000.
- **Table**: A detailed table showing company names, countries, stages, and total layoffs.

## Conclusion

This project provides a comprehensive analysis of tech layoffs during the COVID-19 pandemic and beyond. The insights reveal trends such as which countries, companies, and industries were most affected by layoffs, as well as the stages of companies that experienced the highest job cuts. The Power BI dashboard makes these insights easily accessible and provides a clear visualization of the data trends over time.

---

Feel free to contribute to this project by submitting issues, suggestions, or improvements. Thank you for exploring the tech layoffs dataset!
