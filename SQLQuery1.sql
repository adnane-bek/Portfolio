	SELECT *
	FROM PortfolioProject.dbo.CovidDeaths
	WHERE continent IS NOT NULL
	ORDER BY location, date

	SELECT location, date, total_cases, new_cases, total_deaths, population
	FROM PortfolioProject.dbo.CovidDeaths
	WHERE continent IS NOT NULL
	ORDER BY location, date

	-- Total daths Vs Total Cases
	SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercent
	FROM PortfolioProject.dbo.CovidDeaths
	WHERE continent IS NOT NULL
	ORDER BY location, date

	-- Total cases Vs Total Deaths specific country
	SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercent
	FROM PortfolioProject.dbo.CovidDeaths
	WHERE location = 'United States'
	ORDER BY location, date

	-- Total cases Vs Population specific country
	SELECT location, date, total_cases, population, (total_cases/population)*100 AS CasePercent
	FROM PortfolioProject.dbo.CovidDeaths
	--WHERE location = 'United States'
	WHERE continent IS NOT NULL
	ORDER BY location, date

	-- Countries with highest infection rate Vs Population
	SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS MaxPercentPopulationInfected
	FROM PortfolioProject.dbo.CovidDeaths
	--WHERE location = 'United States'
	WHERE continent IS NOT NULL
	GROUP BY location, population
	ORDER BY MaxPercentPopulationInfected DESC

	-- Countries with highest death COunt
	SELECT location, MAX(total_deaths) AS TotalDeathCount
	FROM PortfolioProject.dbo.CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY location
	ORDER BY TotalDeathCount DESC

	-- Death Count Per Continent exclude income segmentation using new_deaths indicator
	SELECT continent, SUM(new_deaths) AS TotalDeaths
	FROM PortfolioProject.dbo.CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY continent
	ORDER BY TotalDeaths DESC

	-- Death Count North America
	SELECT location, MAX(total_deaths) AS TotalDeathCount
	FROM PortfolioProject.dbo.CovidDeaths
	WHERE continent = 'North America'
	GROUP BY location
	ORDER BY TotalDeathCount DESC


	-- Death Count By income segmentation
	SELECT location, MAX(total_deaths) AS DeathCount, SUM(new_deaths) AS TotalDeaths, (MAX(total_deaths) - sum(new_deaths)) AS DIFF
	FROM PortfolioProject.dbo.CovidDeaths
	WHERE continent IS NULL AND location like '%income%'
	GROUP BY location
	ORDER BY location

	-- Death Count Per Continent exclude income segmentation

	SELECT continent, SUM(new_deaths) AS TotalDeathCount
	FROM PortfolioProject.dbo.CovidDeaths
	WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
	GROUP BY continent
	ORDER BY TotalDeathCount DESC


	-- Global figures Total Cases & deaths per day over the world 

	SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS TotalPercentDeaths
	FROM PortfolioProject.dbo.CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY date
	ORDER BY date DESC

	-- Total cases worldwide per continent

	SELECT continent, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS TotalPercentDeaths
	FROM PortfolioProject.dbo.CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY continent
	ORDER BY TotalPercentDeaths DESC

	-- Total People Vaccinated Cumulated Per Country

	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RolingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date	
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
ORDER BY dea.location, dea.date

-- USE CTE  Calculate Percent People Vaccinated Over time by Country

WITH PopvsVac (continent, location, date, population, new_vaccinations, RolingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RolingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date	
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
)
SELECT *, (RolingPeopleVaccinated/population)*100 AS PercentVaccinated
FROM PopvsVac


-- Calculate Percent People Vaccinated OVers time by Country With TEMP Table
DROP TABLE IF EXISTS #PercentPopulaltionVaccinated

CREATE TABLE #PercentPopulaltionVaccinated
(
continent nvarchar(255),
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric,
RolingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulaltionVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RolingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date	

-- View Temporary Table

SELECT *, (RolingPeopleVaccinated/population)*100
FROM #PercentPopulaltionVaccinated
ORDER BY location, date

-- Creat View to Visualize

Create view PercentPopulaltionVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RolingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulaltionVaccinated




