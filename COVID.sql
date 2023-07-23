--SELECT*
--FROM CovidDeaths
--ORDER BY 3,4

--SELECT*
--FROM CovidVaccinations
--ORDER BY 3,4

-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--Looking at total cases vs total death
--Shows Likelihood of dying if you contract covid in your country 
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Looking at total cases vs population 
--Shows what percentage of population got covid
SELECT location, date, population, total_cases,(total_cases/population)*100 as perecentpopulationinfected
FROM CovidDeaths
WHERE location ='egypt' or location like '%states%'
ORDER BY 1,2

--Looking at Countries with hieghest infection rate compared to population 

SELECT location, population, MAX(total_cases) as Highestinfectioncount, MAX(total_cases/population)*100 as perecentpopulationinfected
FROM CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY perecentpopulationinfected desc


SELECT location, date, MAX(total_cases) as Highestinfectioncount, MAX(total_cases/population)*100 as perecentpopulationinfected
FROM CovidDeaths
WHERE location ='egypt' 
GROUP BY location, date
ORDER BY perecentpopulationinfected desc

--Showing Countries with Highest Death Count per population
SELECT location,MAX(cast(total_deaths as int)) AS totalDeathcount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not Null
GROUP BY location
ORDER BY totalDeathcount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent,MAX(cast(total_deaths as int)) AS totalDeathcount
FROM CovidDeaths
WHERE continent is not Null
GROUP BY continent
ORDER BY totalDeathcount desc

SELECT location,MAX(cast(total_deaths as int)) AS totalDeathcount
FROM CovidDeaths
WHERE continent is Null
GROUP BY location
ORDER BY totalDeathcount desc


--Showing continent with Highest Death Count per population
SELECT continent,MAX(cast(total_deaths as int)) AS totalDeathcount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not Null
GROUP BY continent
ORDER BY totalDeathcount desc

--Global Numbers
SELECT date, SUM(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Looking at Total Population vs Vaccinations 
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM CovidDeaths  dea
join CovidVaccinations  vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

--Looking at total population vs Vaccinations
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location,dea.date) as Rollingpeoplevaccinated
from CovidDeaths dea 
JOIN CovidVaccinations Vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

--USING CTE
WITH PopvsVac as
(SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location,dea.date) as Rollingpeoplevaccinated
from CovidDeaths dea 
JOIN CovidVaccinations Vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (Rollingpeoplevaccinated/population)*100
FROM PopvsVac

--USING TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
( 
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location,dea.date) as Rollingpeoplevaccinated
from CovidDeaths dea 
JOIN CovidVaccinations Vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (Rollingpeoplevaccinated/population)*100
FROM #PercentPopulationVaccinated
order by 1

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location,dea.date) as Rollingpeoplevaccinated
from CovidDeaths dea 
JOIN CovidVaccinations Vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated