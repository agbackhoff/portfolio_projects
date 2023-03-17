
-- TEST QUERIES
SELECT *
FROM coviddeaths;

SELECT *
FROM covidvaccinations;


---- Transform empty values in 'continent' column to 'NULL'
WITH null_continent AS (
SELECT location, 
date, 
NULLIF(continent, '') as new_continent
FROM coviddeaths
) UPDATE coviddeaths AS cc
SET continent = nc.new_continent
FROM null_continent nc
WHERE nc.location = cc.location AND nc.date = cc.date;
----

---- Transform 0 (zero) to 'NULL' in 'new_cases' columns

WITH null_cases AS (
SELECT location,
date,
NULLIF(new_cases, 0) as null_cases
FROM coviddeaths
)
UPDATE coviddeaths AS cc
SET new_cases = nc.null_cases
FROM null_cases nc
WHERE nc.location = cc.location AND nc.date = cc.date;
----

--- Transform 0 (zero) to 'NULL' in 'new_deaths' columns

WITH null_deaths AS (
SELECT location,
date,
NULLIF(new_deaths, 0) as null_deaths
FROM coviddeaths
)
UPDATE coviddeaths AS cc
SET new_deaths = nc.null_deaths
FROM null_deaths nc
WHERE nc.location = cc.location AND nc.date = cc.date;
----

-- Data Exploration

-- Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths c
WHERE location like 'Mexico'
ORDER BY 1,2;


-- Total Cases vs Population

SELECT location, date, total_cases, population , (total_cases/population)*100 as covidcasepercentage
FROM coviddeaths c
WHERE location like 'Mexico'
ORDER BY 1,2;


-- Highest Infection Rate vs Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentofPopulationInfected
FROM coviddeaths c
GROUP BY location, population
ORDER BY PercentofPopulationInfected DESC;


-- Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM coviddeaths c 
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount DESC;

-- Total Deaths by Continent

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM coviddeaths c 
WHERE continent is null
GROUP BY location, population
ORDER BY TotalDeathCount DESC;

-- Global Numbers

SELECT date, SUM(total_cases) AS sum_cases, SUM(total_deaths) AS sum_deaths
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

WITH sum_cd AS (
SELECT date, SUM(new_cases) AS sum_new_cases, SUM(new_deaths) AS sum_new_deaths
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
) SELECT *
	FROM sum_cd;

WITH sum_cd AS (
SELECT date, SUM(new_cases) AS sum_new_cases, SUM(new_deaths) AS sum_new_deaths
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
) SELECT date, sum_new_cases, sum_new_deaths, ROUND((sum_new_deaths/sum_new_cases)*100) as death_percentage
FROM sum_cd;



-- Total Population vs Total Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
ORDER BY 2,3;

SELECT dea.continent,
dea.location, dea.date,
dea.population,
vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_total_vaccinations
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
ORDER BY 2,3;

-- Total Population and Vaccination Rate

WITH pop_vac (continent, location, date, population, new_vaccinations, rolling_total_vaccinations) AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS rolling_total_vaccinations
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
) SELECT *, (rolling_total_vaccinations/population)*100 AS percentage_vaccinated
FROM pop_vac;



---- TEMP TABLE
DROP TABLE IF EXISTS percent_population_vaccinated

CREATE TEMP TABLE percent_population_vaccinated(
	continent varchar(50),
	location varchar(50),
	date date,
	population float8,
	new_vaccinations float8,
	rolling_total_vaccinations float8
)

INSERT INTO percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_total_vaccinations
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (rolling_total_vaccinations/population)*100 AS percentage_vaccinated
FROM percent_population_vaccinated


----


--- Create View For Later Visualizations

CREATE VIEW percent_population_vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_total_vaccinations
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

