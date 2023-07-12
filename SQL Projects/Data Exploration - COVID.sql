SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


--Select Data that we are going to be using 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases VS Total Deaths
-- Shows Likelihood of dying if you contract COVID in your country 

SELECT Location, date, total_cases, total_deaths, ((cast(total_deaths as float)) / (total_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE total_cases IS NOT NULL AND Location like '%states%'
ORDER BY 1,2


-- Looking at total_cases VS population

SELECT Location, date, total_cases, Population, (total_cases / population)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL AND Location like '%Kazakh%'
ORDER BY 1,2


-- Looking at Countries With Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, (MAX((total_cases)/ (population))*100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL 
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- Showing Continents with Highest Death Count per Population

SELECT Continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS  

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/ SUM(new_cases) *100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL AND new_cases <> 0
GROUP BY date
ORDER BY 1, 2

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/ SUM(new_cases) *100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL AND new_cases <> 0
ORDER BY 1, 2


-- Looking at Total Population VS Vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order By dea.Location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
ORDER BY 2, 3


-- USE CTE

WITH PopVSVac (Continent, Location, date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition By dea.Location Order By dea.Location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
	AND population IS NOT NULL
)

SELECT * , (RollingPeopleVaccinated / Population)*100  
FROM PopVSVac
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
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition By dea.Location Order By dea.Location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
	AND population IS NOT NULL

SELECT * , (RollingPeopleVaccinated / Population)*100  
FROM #PercentPopulationVaccinated
ORDER BY 2,3


-- Creating View to Store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition By dea.Location Order By dea.Location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
	AND population IS NOT NULL

SELECT * 
FROM PercentPopulationVaccinated
