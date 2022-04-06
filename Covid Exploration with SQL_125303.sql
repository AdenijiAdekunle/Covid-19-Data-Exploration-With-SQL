/*
COVID 19 DATA EXPLORATION WITH SQL
The dataset was downloaded from www.ourworldindata.org/covid-deaths
A little cutting, joining and splitting has been done to the dataset on Excel

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


Select *
From [Data Exploration with SQL]..CovidDeaths

Select *
From [Data Exploration with SQL]..CovidVaccinations


--COVID_DEATHS DATA EXPLORATION
--Select Data that we are going to be starting with
Select Location, date, total_cases, new_cases, total_deaths, population
From [Data Exploration with SQL]..CovidDeaths
order by 1,2


--Total Cases Vs Total Death
--Shows what percentage of population infected with Covid
--I will stick to Exploring Data of my Country (Nigeria)
Select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercent
From [Data Exploration with SQL]..CovidDeaths
where location like 'Nigeria'
order by 1,2


--Total Case Vs Population
--Shows percentage of population that has covid
Select location, date, population, total_cases, (total_cases /population) * 100 as populationwithcovid
From [Data Exploration with SQL]..CovidDeaths
where location like 'Nigeria'


--Countries with Highest Covid Infection Vs population
Select location, population, MAX(total_cases) as highestInfectionCount, MAX(total_cases /population) * 100 as percentpopulationInfected
From [Data Exploration with SQL]..CovidDeaths
Group by location, population
order by percentpopulationInfected desc


--Countries with Highest Death Count per Population
Select location, Max(cast(total_deaths as int)) as totalDeathCount
From [Data Exploration with SQL]..CovidDeaths
where continent is not null
group by location
order by totalDeathCount desc


-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Data Exploration with SQL]..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
Select date, SUM(new_cases) as totalCases, SUM(cast (new_deaths as int)) as totalDeath, SUM(cast (new_deaths as int))/SUM(new_cases) * 100 as DeathPercent
from [Data Exploration with SQL]..CovidDeaths
where continent is not null
group by date
order by 1,2

--Total Cases Across the World
Select SUM(new_cases) as totalCases, SUM(cast (new_deaths as int)) as totalDeath, SUM(cast (new_deaths as int))/SUM(new_cases) * 100 as DeathPercent
from [Data Exploration with SQL]..CovidDeaths
where continent is not null
order by 1,2


--COVID_VACCINATIONS DATA EXPLORATION

Select *
From [Data Exploration with SQL]..CovidDeaths death
Join [Data Exploration with SQL]..CovidVaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date


--Total Population Vs Vaccination
--Shows Percentage of Population that has recieved at least one Covid Vaccine
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
From [Data Exploration with SQL]..CovidDeaths death
Join [Data Exploration with SQL]..CovidVaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
order by 1, 2, 3


--Sum of new vaccination per locations
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(Cast(vaccine.new_vaccinations as bigint)) OVER (Partition by death.location order by death.location, death.date) as PopulaceVaccinated
From [Data Exploration with SQL]..CovidDeaths death
Join [Data Exploration with SQL]..CovidVaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
order by 2, 3


--Using CTE to perform Calculation on Partition By in previous query
With VaccinatePeople (Continent, location, Date, Population, new_vaccinations, PopulaceVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(Cast(vaccine.new_vaccinations as bigint)) OVER (Partition by death.location order by death.location, death.date) as PopulaceVaccinated
From [Data Exploration with SQL]..CovidDeaths death
Join [Data Exploration with SQL]..CovidVaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
--order by 2, 3
)
Select *, (PopulaceVaccinated/Population)*100
From VaccinatePeople


--Using Temp Table to perform Calculation on Partition By in previous query
Create Table #PopulaceVaccinatedPercentage
(
Continent nvarchar(255),
location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PopulaceVaccinated numeric
)

Insert into #PopulaceVaccinatedPercentage
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(Cast(vaccine.new_vaccinations as bigint)) OVER (Partition by death.location order by death.location, death.date) as PopulaceVaccinated
From [Data Exploration with SQL]..CovidDeaths death
Join [Data Exploration with SQL]..CovidVaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
--order by 2, 3
Select *, (PopulaceVaccinated/Population)*100
From #PopulaceVaccinatedPercentage


--Creating View to store data for later visualizations

Create View PopulaceVaccinatedPercentage as 
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(Cast(vaccine.new_vaccinations as bigint)) OVER (Partition by death.location order by death.location, death.date) as PopulaceVaccinated
From [Data Exploration with SQL]..CovidDeaths death
Join [Data Exploration with SQL]..CovidVaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
--order by 2, 3