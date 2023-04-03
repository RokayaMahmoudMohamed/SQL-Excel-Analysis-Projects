SELECT * 
FROM
CovidDeaths
ORDER BY 3,4

SELECT * 
FROM
CovidVaccinations
ORDER BY 3,4

--let's see the charge of death rate per day in each country
-- and put in view for visualization
CREATE VIEW LocationDeathRate AS(
SELECT location,
		convert(date,date) date,
		cast(total_deaths as int) total_deaths,
		total_cases
FROM CovidDeaths 
where total_deaths is not null and total_cases is not null and location is not null
--order by location,date
)

--let's see the charge of infection rate per day in each country
-- and put in view for visualization
CREATE VIEW LocationInfectionRate AS(
SELECT location,
		convert(date,date) date,
		total_cases,
		population
FROM CovidDeaths 
where population is not null and total_cases is not null and location is not null
--order by location,date
)


--view total cases vs total deaths and find percentage of death pepole order by max percentage
--so we note that the country with less cases all thier cases die
--country which have 100 percentage of die is [iran,sudan,Guyana]
----and then put it in view for viz
CREATE VIEW LocationDeathPercentage AS(
SELECT location,
		total_cases,
		max(cast(total_deaths as int)) total_deaths,
		round((max(total_deaths)/total_cases)*100,2) as DeathPercentage
from CovidDeaths
where location is not null
group by location,total_cases
--order by DeathPercentage desc
)
--same query but in ascending order
--country which have 0.04 percentage of die is [qatar] 
--so we can search for the way that they take care of their health to learn from them
SELECT location,
		total_cases,
		max(cast(total_deaths as int)) total_deaths,
		round((max(total_deaths)/total_cases)*100,2) as DeathPercentage
from CovidDeaths
where total_cases is not null and total_deaths is not null and location is not null
group by location,total_cases
order by DeathPercentage asc


--now we will look for percentage of population get covid
--country with high cases according to it population is [andorra]
--note we take the below query as view for viz this
SELECT location,
		max(total_cases) total_cases,
		population,
		round((max(total_cases)/population)*100,2) as CasesPercentage
from CovidDeaths
where total_cases is not null and population is not null and location is not null
group by location,population
order by CasesPercentage desc


--country with less cases according to it population is
--[micronesia,vanuatu,samoa] 
--and note that each of them have at least 1 and at most 3 cases but we can also discuss how they take care about thier self from covid
----and then put it in view for viz
CREATE VIEW LocationCasesPercentage AS(
SELECT location,
		max(total_cases)total_cases,
		population,
		round((max(total_cases)/population)*100,2 )as CasesPercentage
from CovidDeaths
where total_cases is not null and population is not null and location is not null
group by location,population
--order by CasesPercentage 
)

--let's focus on  continent
--and then put it in view for viz
CREATE VIEW ContinentTotalDeath AS(
SELECT continent,
		MAX(CAST(total_deaths as int)) total_death_count
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
--ORDER BY total_death_count desc
)

--calc across the world the percentage of new death according to new cases
--and then put it in view for viz
CREATE VIEW WorldNewDeathPercentage AS(
SELECT SUM(new_cases) as total_cases,
		SUM(CAST(new_deaths as int)) total_death,
		ROUND(SUM(CAST(new_deaths as int))/SUM(new_cases)*100,2) as DeathPercentage
FROM CovidDeaths
WHERE continent is not null 
)

--now let's join the two table
SELECT * 
FROM CovidDeaths 
JOIN CovidVaccinations 
ON CovidDeaths.location=CovidVaccinations.location
AND CovidDeaths.date=CovidVaccinations.date


---total amount people in the world that have been vaccinated
--looking at population vs vaccination
-- and looking for date the location start to take vaccination
CREATE VIEW RollingPeopleVacc AS(
SELECT death.continent,
		death.location,
		death.date,
		death.population,
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) 
		OVER(PARTITION BY death.LOCATION 
		ORDER BY death.location,death.date) AS RollingPeopleVacc
FROM CovidDeaths death
JOIN CovidVaccinations vac
ON death.date=vac.date
AND death.location=vac.location
WHERE death.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
--ORDER BY death.location,death.date
)


--now calc percentage of RollingPeopleVacc from population per location
--put it into table for visualization
CREATE VIEW PercentagePeopleVacC AS(
SELECT continent,location,date,population,new_vaccinations,RollingPeopleVacc,
		ROUND((RollingPeopleVacc/population)*100,2) Percentage_poep_vcc
FROM
(
SELECT death.continent,
		death.location,
		death.date,
		death.population,
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) 
		OVER(PARTITION BY death.LOCATION 
		ORDER BY death.location,death.date) AS RollingPeopleVacc
FROM CovidDeaths death
JOIN CovidVaccinations vac
ON death.date=vac.date
AND death.location=vac.location
WHERE death.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
) AS People_vs_vacc
--ORDER BY Percentage_poep_vcc
)





		






