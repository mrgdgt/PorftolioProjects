SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%mexico%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of the population got infected by covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%mexico%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 AS HighestTotalCases
FROM PortfolioProject..CovidDeaths
GROUP BY population, location
ORDER BY HighestTotalCases DESC

-- Showing countries with Highest Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing Continents with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global Numbers

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Total Population vs Vaccination

	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortfolioProject.dbo.CovidDeaths dea
	JOIN PortfolioProject.dbo.CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent is not null
	ORDER BY 1,2,3

-- Make CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortfolioProject.dbo.CovidDeaths dea
	JOIN PortfolioProject.dbo.CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent is not null
	--ORDER BY 1,2,3
) 
SELECT *, (rollingpeoplevaccinated/population)*100 as PercentagePopulationVaccinated
FROM PopvsVac

-- Temp Table

DROP TABLE if exists temp_PercentPopulationVaccinated
CREATE TABLE temp_PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO	temp_PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortfolioProject.dbo.CovidDeaths dea
	JOIN PortfolioProject.dbo.CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent is not null
	--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 as percentagepopulationvaccinated
FROM temp_PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPolationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortfolioProject.dbo.CovidDeaths dea
	JOIN PortfolioProject.dbo.CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent is not null

select *
from SQLTutorial..PercentPolationVaccinated