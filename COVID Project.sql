--SELECT * 
--FROM PortfolioProject..CovidDeaths
--ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT Location, Date, Total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Likelihood of dying if you contract Covid

SELECT Location, Date, Total_cases, total_deaths, (total_deaths * 100.0 / total_cases) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths for Spain
-- Likelihood of dying if you contract Covid in Spain

SELECT Location, Date, Total_cases, total_deaths, (total_deaths * 100.0 / total_cases) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE LOCATION = 'Spain'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- What percentage of the population has been infected
SELECT Location, Date, Total_cases, population, (total_cases * 100.0 / population) AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Population for Spain
-- What percentage of population has been infected in Spain
SELECT Location, Date, Total_cases, population, (total_cases * 100.0 / population) AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE LOCATION = 'Spain'
ORDER BY 1,2

-- Looking at countries with highest Infection Rate compared to Population

SELECT Location, FORMAT(Population, '#,###') AS FormatedPopulation, MAX(Total_cases) AS HighestInfectionCount, MAX(total_cases * 100.0 / population) AS MAXInfectedPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY MAXInfectedPercentage DESC

-- Looking at countries with highest Death Count

SELECT Location, FORMAT(Population, '#,###') AS FormatedPopulation, MAX(total_deaths) AS MAXTotalDeath
FROM PortfolioProject..CovidDeaths
WHERE CONTINENT IS NOT NULL
GROUP BY Location, Population
ORDER BY MAXTotalDeath DESC

-- Looking at Continents with highest Death Count

SELECT Location, MAX(total_deaths) AS MAXTotalDeath
FROM PortfolioProject..CovidDeaths
WHERE CONTINENT IS NULL
GROUP BY Location
ORDER BY MAXTotalDeath DESC

-- Global numbers

SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths) * 100.0 / SUM(new_cases) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE CONTINENT IS NOT NULL AND new_cases <> 0 AND new_deaths <> 0
ORDER BY 1,2

-- Global numbers by date

SELECT Date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths) * 100.0 / SUM(new_cases) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE CONTINENT IS NOT NULL AND new_cases <> 0 AND new_deaths <> 0
GROUP BY Date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Looking at Total Population vs Vaccinations with rolling sum

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE to see Percentage of people Vaccinated

WITH POPvsVAC (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated * 100.0/ Population) AS PercentagePeopleVaccinated
FROM POPvsVAC

-- Create view to store data for later visualizations

Create View PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
