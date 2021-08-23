SELECT *
FROM [COVID Project]..['covid-deaths']
ORDER BY 3,4

--SELECT *
--FROM [COVID Project]..['covid-vaccinations']
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [COVID Project]..['covid-deaths']
ORDER BY 1,2

-- To compare between total deaths and total cases in a country
-- Death percent is a new important feature showing us the rise or decline of death rates in countries
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
FROM [COVID Project]..['covid-deaths']
WHERE location = 'India'
ORDER BY 1,2

--Total cases vs population
--What percent contracted the virus
SELECT location, date, total_cases, population, (total_cases/population)*100 as covid_percent
FROM [COVID Project]..['covid-deaths']
WHERE location = 'India'
ORDER BY 1,2

--Highest infection rate compared to population
SELECT location, MAX(total_cases) as high_infection, population, MAX((total_cases/population)*100) as covid_percent2
FROM [COVID Project]..['covid-deaths']
GROUP BY location, population
ORDER BY covid_percent2 desc

--Showing countries with high death rates from COVID per population
SELECT location, MAX(cast(total_deaths as int)) as total_death_count 
FROM [COVID Project]..['covid-deaths']
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count desc

--By continent
SELECT location, MAX(cast(total_deaths as int)) as total_death_count 
FROM [COVID Project]..['covid-deaths']
WHERE continent is null
GROUP BY location
ORDER BY total_death_count desc


-- Global Numbers
SELECT date, SUM(new_cases), SUM(cast(new_deaths as int)), (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_perc
FROM [COVID Project]..['covid-deaths']
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Looking at total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.date, dea.location) as roll_people_vac
FROM [COVID Project]..['covid-deaths'] dea
JOIN [COVID Project]..['covid-vaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3 

--Using CTE 
WITH PopvsVac (continent, location, date, population, new_vaccinations, roll_people_vac)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.date, dea.location) as roll_people_vac
FROM [COVID Project]..['covid-deaths'] dea
JOIN [COVID Project]..['covid-vaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 
)

SELECT * , (roll_people_vac/population)*100 as roll_perc
FROM PopvsVac

--Using Temp Table



CREATE TABLE PercPopulationVaccine
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
roll_people_vac numeric)

INSERT INTO PercPopulationVaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.date, dea.location) as roll_people_vac
FROM [COVID Project]..['covid-deaths'] dea
JOIN [COVID Project]..['covid-vaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 
SELECT * , (roll_people_vac/population)*100 as roll_perc
FROM PercPopulationVaccine
DROP TABLE PercPopulationVaccine

--Creating view for data visualization

CREATE VIEW PercentPopVac as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.date, dea.location) as roll_people_vac
FROM [COVID Project]..['covid-deaths'] dea
JOIN [COVID Project]..['covid-vaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 

--Tableau Table 1
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM [COVID Project]..['covid-deaths']
WHERE continent is not null 
ORDER BY 1,2

-- Tableau Table 2
SELECT location, SUM(cast(new_deaths as int)) AS TotalDeathCount
FROM [COVID Project]..['covid-deaths']
WHERE continent is null 
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC

--Tableau Table 3
SELECT location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
FROM [COVID Project]..['covid-deaths']
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Tableau Table 4
SELECT location, population, date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM [COVID Project]..['covid-deaths']
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC


