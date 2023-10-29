SELECT location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100, 3) as death_percentage
FROM CovidActual
WHERE continent IS NOT NULL
ORDER BY 1, 2;

SELECT location, MAX(total_deaths) as total_death, MAX(total_cases) as total_cases, 
round((MAX(total_deaths)/MAX(total_cases))*100, 3) as death_percentage
FROM CovidActual
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 4 DESC;

SELECT location, date, total_cases, population, round((total_cases/population)*100, 10) as population_percentage_infected 
FROM CovidActual
WHERE continent IS NOT NULL
ORDER BY 1, 2;

SELECT location, MAX(total_deaths) as total_death, max((total_deaths/population)*100) as percenage_of_population_death
FROM CovidActual
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 3 desc;

SELECT date, sum(new_cases) as worldwide_cases_per_day, sum(new_deaths) as worldwide_death_per_day,
round((sum(new_deaths)/sum(new_cases)) * 100, 3) as worldwide_everyday_death_per_case_percentage
FROM CovidActual
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date asc;

SELECT continent, avg(median_age)
FROM CovidActual
WHERE continent IS NOT NULL
GROUP BY continent;

SELECT location, date, population, new_vaccinations, 
SUM(new_vaccinations) OVER (PARTITION by location ORDER BY location, date) as vaccination_progress
FROM CovidActual
WHERE continent IS NOT NULL
ORDER BY 1, 2;

WITH VacInd (location, date, population, new_vaccinations, vaccination_progress) as
(
SELECT location, date, population, new_vaccinations, 
SUM(new_vaccinations) OVER (PARTITION by location ORDER BY location, date) as vaccination_progress
FROM CovidActual
WHERE continent IS NOT NULL
)

SELECT *,(vaccination_progress/population) * 100 as persentage_of_vaccinated_population
FROM VacInd
ORDER BY 1,2;

WITH VacInd (location, date, population, new_vaccinations, vaccination_progress) as
(
SELECT location, date, population, new_vaccinations, 
SUM(new_vaccinations) OVER (PARTITION by location ORDER BY location, date) as vaccination_progress
FROM CovidActual
WHERE continent IS NOT NULL
)

SELECT location, date, max(vaccination_progress), 
(max(vaccination_progress)/population) * 100 as persentage_of_vaccinated_population
FROM VacInd
GROUP BY location, date, population
ORDER BY 1, 2; 

WITH VacInd (location, date, population, new_vaccinations, vaccination_progress) as
(
SELECT location, date, population, new_vaccinations, 
SUM(new_vaccinations) OVER (PARTITION by location ORDER BY location, date) as vaccination_progress
FROM CovidActual
WHERE continent IS NOT NULL
)

SELECT VacInd.location, VacInd.date, MAX(VacInd.vaccination_progress), MAX(CoAc.total_deaths)
FROM VacInd INNER JOIN CovidActual as CoAc ON VacInd.location = CoAc.location AND VacInd.date = CoAc.date
GROUP BY VacInd.location, VacInd.date
ORDER BY 1,2;

CREATE VIEW DeathPercentage AS
SELECT location, date, total_deaths, total_cases, round(((total_deaths/total_cases)*100), 3) as death_percentage
FROM CovidActual
WHERE continent IS NOT NULL;

SELECT * from DeathPercentage ORDER BY 1, 2;

CREATE VIEW PopulationInfectedPercentage AS
SELECT location, date, total_cases, population, round((total_cases/population)*100, 10) as population_percentage_infected 
FROM CovidActual
WHERE continent IS NOT NULL;

SELECT * FROM PopulationInfectedPercentage ORDER BY 1, 2; 