use layoff

--------------------
---Cleaning Stage---
--------------------

--let's copy layoffs data to a new table to gets our hands dirty with no risks
select * into layoffs_staging
from layoffs

select *
from layoffs_staging

--we have no IDs column to search for the duplicate row, so we make one
select *, ROW_NUMBER() over(partition by company, [location], industry, total_laid_off, percentage_laid_off, [date], stage, country, funds_raised order by company) as row_num
from layoffs_staging

with duplicate_cte as (
select *, 
ROW_NUMBER() 
over(partition by company, [location], industry, total_laid_off, percentage_laid_off, [date], stage, country, funds_raised order by company) as duplicates
from layoffs_staging
)
--show the duplicate rows
select *
from duplicate_cte
where duplicates > 1

select *, 
ROW_NUMBER() 
over(partition by company, [location], industry, total_laid_off, percentage_laid_off, [date], stage, country, funds_raised order by company) as duplicates
into layoffs_staging2
from layoffs_staging

select *
from layoffs_staging2
where duplicates > 1

delete 
from layoffs_staging2
where duplicates > 1

-- standardize data
select company, trim(company)
from layoffs_staging2

update layoffs_staging2
set company = trim(company)

--check country column
select distinct(country)
from layoffs_staging2
order by country

select *
from layoffs_staging2
where country in ('UAE', 'United Arab Emirates')

update layoffs_staging2
set country = 'United Arab Emirates'
where country = 'UAE'

--check industry column
select distinct(industry)
from layoffs_staging2
order by industry

--check stage column
select distinct(stage)
from layoffs_staging2
order by stage

--check company column
select distinct(company)
from layoffs_staging2
order by company

select count(*)
from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null

delete
from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null

alter table layoffs_staging2
drop column duplicates

-------------------------------
---Exploratory Data Analysis---
-------------------------------

select *
from layoffs_staging2

--How many companies did layoffs ?
select count(distinct company)
from layoffs_staging2

--Minimum of company's total layoffs, Maximum of company's total layoffs
select min(total_laid_off), max(total_laid_off)
from layoffs_staging2

--Minimum of company's % layoffs, Maximum of company's % layoffs
select min(percentage_laid_off), max(percentage_laid_off)
from layoffs_staging2

--Layoffs's start date, Layoffs's last date
select min([date]) as start_from, max([date]) as until
from layoffs_staging2

--Top 5 stages that contains companies with layoffs
select top(5) stage, count(company) as [count of companies]
from layoffs_staging2
group by stage
order by 2 desc

--Top 5 countries with highest layoffs
select top(5) country, sum(total_laid_off) as [total laid off]
from layoffs_staging2
group by country
order by 2 desc

--Top 5 industries with highest layoffs
select top(5) industry, sum(total_laid_off) as [total laid off]
from layoffs_staging2
group by industry
order by 2 desc

--Top 5 companies with highest layoffs
select top(5) company, sum(total_laid_off) as [total laid off]
from layoffs_staging2
group by company
order by 2 desc

--total layoffs thru years
select year([date]) as [year], sum(total_laid_off) as [total laid off]
from layoffs_staging2
group by year([date])
order by 1

with total_laid_off_year(company, [year], total_laid_off) as
(
--company's layoffs thru years
select company, year([date]) as [year], sum(total_laid_off) as total_laid_off
from layoffs_staging2
group by company, year([date])
having sum(total_laid_off) is not null
),
company_ranking_of_year as
(
--company's layoffs & rank thru years
select *, DENSE_RANK() over(partition by [year] order by total_laid_off desc) as ranking
from total_laid_off_year
)
--top 5 companies with highest layoffs every year
select *
from company_ranking_of_year
where ranking <= 5