SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4
--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select the Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, ROUND(((total_deaths/total_cases)*100), 2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND continent = 'Europe'
ORDER BY 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of population got covid

SELECT location, date, population, total_cases, ROUND(((total_cases/population)*100), 2) AS Percentage_Of_Population_Infected
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE 'Europe'
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, ROUND(MAX(total_cases/population)*100, 2) AS Percentage_Of_Population_Infected
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE 'Europe'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Percentage_Of_Population_Infected DESC

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE 'Europe'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC

-- Let's break things down by continent

-- Showing continents with the Highest Death Count

SELECT continent, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE 'Europe'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC

-- GLOBAL NUMBERS

	SELECT SUM(new_cases) AS All_New_Cases, SUM(CAST(new_deaths AS int)) AS All_Deaths, ROUND((SUM(CAST(new_deaths AS int))/SUM(new_cases)*100), 2) AS DeathPercentage
	FROM PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL
	--GROUP BY date
	ORDER BY 1,2

	-- Looking at Total Population vs Vaccinations

		-- USE CTE

	WITH PopvsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
	AS
	(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
	FROM PortfolioProject..CovidDeaths	dea
	JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3
	)
	SELECT *, ROUND((Rolling_People_Vaccinated/population)*100, 3)
	FROM PopvsVac
	ORDER BY 2,3

	-- TEMP TABLE

	DROP TABLE IF EXISTS #PercentPopulationVaccinated
	CREATE TABLE #PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	Rolling_People_Vaccinated numeric
	)

	INSERT INTO #PercentPopulationVaccinated
		SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
	FROM PortfolioProject..CovidDeaths	dea
	JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3

	SELECT *, ROUND((Rolling_People_Vaccinated/population)*100, 3)
	FROM #PercentPopulationVaccinated


	-- Creating View to store data for later visualisations

	CREATE VIEW PercentPopulationVaccinated AS
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
	FROM PortfolioProject..CovidDeaths	dea
	JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3

	SELECT *
	FROM PercentPopulationVaccinated