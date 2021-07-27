SELECT *
FROM PortfolioProject..Covid_Deaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..Covid_Vaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..Covid_Deaths
WHERE Location = 'India' 
ORDER BY 1,2

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..Covid_Deaths
WHERE Location like '%States' 
ORDER BY 1,2

-- Looking with countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count
SELECT Location, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY HighestDeathCount DESC

-- Showing Continents with Highest Death Count
SELECT continent, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

--GLOBAL NUMBERS
SELECT SUM(new_cases) AS totalCases, SUM(CAST(new_deaths AS INT)) AS totalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

SELECT date, SUM(new_cases) AS totalCases, SUM(CONVERT(INT,new_deaths)) AS totalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT *
FROM PortfolioProject..Covid_Deaths AS Deaths
JOIN PortfolioProject..Covid_Vaccinations AS Vac
	ON Deaths.location=Vac.location 
	AND Deaths.date=Vac.date

--Total Population vs Vaccinations using Temporary Table
WITH Pop_vs_Vacc (continent, Location, date, Population, new_vaccinations, UpdatingVaccinations)
AS
(
SELECT Deaths.continent, Deaths.Location, Deaths.date, Deaths.Population, Vac.new_vaccinations, 
SUM(CAST(Vac.new_vaccinations AS INT)) OVER (PARTITION BY Deaths.Location ORDER BY Deaths.Location, Deaths.date) AS UpdatingVaccinations
FROM PortfolioProject..Covid_Deaths AS Deaths
JOIN PortfolioProject..Covid_Vaccinations AS Vac
	ON Deaths.location=Vac.location 
	AND Deaths.date=Vac.date
WHERE Deaths.continent IS NOT NULL
)
SELECT *, (UpdatingVaccinations/Population) * 100
FROM Pop_vs_Vacc


--Creating a TEMP Table
CREATE TABLE PercentagePopluationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
UpdatingVaccinations numeric
)


INSERT INTO PercentagePopluationVaccinated
SELECT Deaths.continent, Deaths.Location, Deaths.date, Deaths.Population, Vac.new_vaccinations, 
SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER (PARTITION BY Deaths.Location ORDER BY Deaths.Location, Deaths.date) AS UpdatingVaccinations
FROM PortfolioProject..Covid_Deaths AS Deaths
JOIN PortfolioProject..Covid_Vaccinations AS Vac
	ON Deaths.location=Vac.location 
	AND Deaths.date=Vac.date

SELECT *, (UpdatingVaccinations/Population) * 100
FROM PercentagePopluationVaccinated

--Creating View
GO
CREATE VIEW ViewPercentagePopluationVaccinated 
AS 
SELECT Deaths.continent, Deaths.Location, Deaths.date, Deaths.Population, Vac.new_vaccinations, 
SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER (PARTITION BY Deaths.Location ORDER BY Deaths.Location, Deaths.date) AS UpdatingVaccinations
FROM PortfolioProject..Covid_Deaths AS Deaths
JOIN PortfolioProject..Covid_Vaccinations AS Vac
	ON Deaths.location=Vac.location 
	AND Deaths.date=Vac.date