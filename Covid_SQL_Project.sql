--Basic SQL queries

select * from PortfolioProject..death
order by 3,4

select * from PortfolioProject..vaccination
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..death order by 1,2


-- Altering the table and columns--

alter table PortfolioProject..death 
alter column total_deaths float

alter table PortfolioProject..death 
alter column total_cases float


-- Works as desc of any table in SSMS --

EXEC sp_help 'PortfolioProject..death'


--Looking at the total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percentage
from PortfolioProject..death
order by 1,2


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percentage
from PortfolioProject..death
where location like '%india%'
order by 1,2
--(OR)
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percentage
from PortfolioProject..death
where location = 'india'
order by 1,2


-- Total cases vs population

select location, date, population, total_cases, (total_cases/population)*100 as percentage
from PortfolioProject..death
where location like '%india%'
order by 1,2

select location, date, population, total_cases, (total_cases/population)*100 as percentage
from PortfolioProject..death
--where location like '%india%'
order by 1,2


-- Selecting the highest count of infection in comparison to the population

select location, population, max(total_cases) as max_total_cases, max((total_cases/population))*100 as max_infection_percentage
from PortfolioProject..death
group by location, population
order by 1,2

select location, population, max(total_cases) as max_total_cases, max((total_cases/population))*100 as max_infection_percentage
from PortfolioProject..death
group by location, population
order by max_infection_percentage desc

select * from PortfolioProject..death


-- Selecting the countries with the highest deaths.  

select location, max(total_deaths) as max_death_cases
from PortfolioProject..death
where continent is not null
group by location
order by max_death_cases desc


-- This is used to type cast the data type from varchar to INT or any other Dtypes
--select location, max(cast(total_deaths as INT)) as max_death_cases
--from PortfolioProject..death
--where continent is not null
--group by location
--order by max_death_cases desc


-- Selecting the continents with highest deaths.  

select continent, max(total_deaths) as max_death_cases
from PortfolioProject..death
where continent is not null
group by continent
order by max_death_cases desc

select location, max(total_deaths) as max_death_cases
from PortfolioProject..death
where continent is null
group by location
order by max_death_cases desc

select count(continent) as total
from PortfolioProject..death
where continent is not null

select count(continent) as total
from PortfolioProject..death
where continent is null

select continent, count(continent) from PortfolioProject..death group by continent


--Global cases in total

select date, sum(total_cases)
from PortfolioProject..death
--where continent is not null
group by date
order by 1,2



select
	sum(new_cases) as Total_New_cases,
	sum(new_deaths) as Total_New_deaths,
	sum(new_deaths)/sum(new_cases)*100 as Death_percent
from
	PortfolioProject..death
--order by 
--	1,2


-- Now looking at the vaccination table.

select * from PortfolioProject..vaccination

select * from PortfolioProject..death dea
join PortfolioProject..vaccination vac
on dea.location = vac.location
and dea.date = vac.date


--Finding the total vaccination vs population

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(decimal, vac.new_vaccinations)) over (partition by dea.location order by dea.date) 
as RollingPeopleVaccine
from PortfolioProject..death dea
join PortfolioProject..vaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3


-- Using of CTE (Common Table Expresion)

With popvsvac(continent, location, date, population, new_vaccinations, RollingPeopleVaccine)
as
(
select 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
sum(convert(decimal, vac.new_vaccinations)) over (partition by dea.location order by dea.date) 
as 
RollingPeopleVaccine
from 
PortfolioProject..death dea
join PortfolioProject..vaccination vac
on 
dea.location = vac.location
and dea.date = vac.date
where 
dea.continent is not null and vac.new_vaccinations is not null
)
--order by 2,3
select *, (RollingPeopleVaccine/population)*100
from popvsvac


--Creating a temp table with all the data.

drop table if exists TempTable

create table TempTable 
(
continent varchar(200),
location varchar(200),
date datetime,
population decimal,
new_vaccination decimal,
rolling_people_vaccine decimal
)

insert into TempTable
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(decimal, vac.new_vaccinations)) over (partition by dea.location order by dea.date) 
as RollingPeopleVaccine
from PortfolioProject..death dea
join PortfolioProject..vaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3

select *, (rolling_people_vaccine/population)*100 as rolling_data  from TempTable











