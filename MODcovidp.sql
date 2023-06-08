SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
Order By 3,4


SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER By 3,4


SELECT *
FROM PortfolioProject..CovidDeaths
ALTER TABLE PortfolioProject..CovidDeaths
DROP COLUMN hosp_patients, hosp_patients_per_million, weekly_icu_admissions, weekly_icu_admissions_per_million, weekly_hosp_admissions,
weekly_hosp_admissions_per_million;
   

   DELETE FROM PortfolioProject..CovidDeaths
   WHERE icu_patients_per_million is NULL; 

SELECT *
FROM PortfolioProject..CovidVaccinations
ALTER TABLE PortfolioProject..CovidVaccinations
DROP COLUMN female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, life_expectancy, human_development_index,
excess_mortality_cumulative_absolute, excess_mortality_cumulative, excess_mortality, excess_mortality_cumulative_per_million;



DELETE FROM PortfolioProject..CovidDeaths
WHERE year(date) > 2022-01-01;


DELETE FROM PortfolioProject..CovidVaccinations
WHERE year(date) > 2022-01-01;


-- Select the Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
where continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Deaths

SELECT *
FROM PortfolioProject..CovidDeaths
EXEC sp_help 'total_deaths'
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths float

SELECT *
FROM PortfolioProject..CovidDeaths
EXEC sp_help 'total_cases'
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_cases float


SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%state%'
and continent is not null
Order by 1,2


-- Looking at the Total Cases vs the Population 
-- Shows what percentage of the population got Covid


SELECT Location, date, Population, total_cases, (total_cases/Population)*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location like '%state%'
and continent is not null
Order by 1,2

-- Countries with higher infection rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null
Group By Location, Population
Order by PercentPopulationInfected desc


-- Show the Countries with the Highest Death count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null
Group By Location
Order by TotalDeathCount desc

-- By continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null
Group By continent
Order by TotalDeathCount desc


-- Continent with highest death count per population


SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null
Group By continent
Order by TotalDeathCount desc

-- Global

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null
--Group by date
Order by 1,2


-- Total Population vs Vaccinations

-- USE CTE


with PopvsVac(Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as (

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location , dea.date)	
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
 -- order by 2,3
  )
  SELECT *, (RollingPeopleVaccinated/population)*100
  FROM PopvsVac


  -- TEMP TABLE

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

  Insert into  #PercentPopulationVaccinated
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location , dea.date)	
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
--where dea.continent is not null
 --order by 2,3


  SELECT *, (RollingPeopleVaccinated/population)*100
  FROM #PercentPopulationVaccinated



 -- Creating View to Store data for Viz

 Create View PercentPopulationVaccinated as
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location , dea.date)	
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Create view Global as
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null
Group by date
--Order by 1,2



SELECT *
From PercentPopulationVaccinated


