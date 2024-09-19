select * from coviddeaths

select * from covidvaccinations

/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select * from coviddeaths

select * from covidvaccinations

Select *
From coviddeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select country, date, total_cases, new_cases, total_deaths, population
From coviddeaths
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select country, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From coviddeaths
Where country like '%india%'
and continent is not null and total_cases <> 0
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select country, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From coviddeaths
--Where location like '%india%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select country, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From coviddeaths
--Where country like '%india%'
Group by country, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population
 
 Select country, MAX(cast(Total_deaths as int)) as TotalDeathCount
From coviddeaths
--Where country like '%india%'
Where continent is not null 
Group by country
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From coviddeaths
--Where country like '%india%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From coviddeaths
--Where country like '%india%'
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.country Order by dea.country, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From coviddeaths dea
Join covidvaccinations vac
	On dea.country = vac.country
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, country, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.country Order by dea.country, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From coviddeaths dea
Join covidvaccinations vac
	On dea.country = vac.country
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.country Order by dea.country, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [dbo].[coviddeaths] dea
Join [dbo].[covidvaccinations] vac
	On dea.country = vac.country
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.country Order by dea.country, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [dbo].[coviddeaths] dea
Join [dbo].[covidvaccinations] vac
	On dea.country = vac.country
	and dea.date = vac.date
where dea.continent is not null 
