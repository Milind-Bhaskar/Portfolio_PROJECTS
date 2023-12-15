SELECT * FROM covid_death
where continent IS NOT NULL;

--Looking at the percentage deaths every day
--Shows the likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths:: numeric/total_cases)*100 AS deathpercentage
FROM covid_death
Where location ILIKE '%India%'
ORDER BY 1, 2;

--Looking at Total Cases VS Population
--Shows what Percentage of Population got Covid
SELECT Location, date, total_cases, Population, (total_cases:: NUMERIC/population)*100 AS Percentage_pop_infected
FROM covid_death
Where location ILIKE '%India%'
ORDER BY 1, 2;

--Looking at the countries with the highest infection rate
SELECT Location,Population,MAX(total_cases) AS Highest_Infection_Count,MAX((total_cases:: NUMERIC/population)*100) AS Percentage_pop_infected
FROM covid_death
GROUP BY location,Population
ORDER BY Percentage_pop_infected DESC;

--Showing the countries with the Highest Death Count per Population
SELECT Location,MAX(total_deaths) AS TotalDeathCount
FROM covid_death
where continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc;

--LET'S DO THIS FOR THE CONTINENTS

SELECT continent,MAX(total_deaths) AS TotalDeathCount
FROM covid_death
where continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS new_cases_onthisdate,
SUM(new_deaths) AS deaths_onthisdate,SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 AS Death_Percentage
FROM covid_death
--Where location ILIKE '%India%'
GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_cases) AS total_cases,
SUM(new_deaths) AS total_deaths,SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 AS Death_Percentage
FROM covid_death
--Where location ILIKE '%India%'
--GROUP BY date
ORDER BY 1,2;

--Total Population Vs Vaccination
SELECT * FROM covid_death dea 
INNER join covid_vaccination vac
ON dea.location = vac.location
		AND dea.date = vac.date;
		
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM covid_death dea 
INNER join covid_vaccination vac
ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


--TEMP TABLE

DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date TIMESTAMP,
Population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.Date)
AS RollingPeopleVaccinated

FROM covid_death dea 
INNER join covid_vaccination vac
ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated;

---Creating view for later data visualizations
CREATE VIEW percetagePopulationVaccinated_ AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.Date)
AS RollingPeopleVaccinated

FROM covid_death dea 
INNER join covid_vaccination vac
ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;

SELECT * FROM percetagePopulationVaccinated_;




