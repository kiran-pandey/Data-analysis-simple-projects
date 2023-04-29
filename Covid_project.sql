
--Showing the deathpercentage in Nepal
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage 
FROM portfolio_project..covid_deaths
WHERE location like'%Nepal%'
ORDER BY 1,2

--Showing the percentage of people infected by covid in Nepal
SELECT Location, date, total_cases, population, (total_cases/population)*100 as infected_percentage
FROM portfolio_project..covid_deaths
WHERE location like'%Nepal%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) as Highest_infection_count, MAX((total_cases/population)*100) as Highest_infected_percentage
FROM portfolio_project..covid_deaths
GROUP BY location, population
ORDER BY Highest_infected_percentage desc

--Countries with highest death count
SELECT Location, MAX(total_deaths) as Total_death_count
FROM portfolio_project..covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY Total_death_count desc

--Death count continent wise
SELECT continent, MAX(total_deaths) as Total_death_count
FROM portfolio_project..covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY Total_death_count desc


--New cases vs New death datewise
SELECT date, SUM(new_cases) as Total_new_cases, SUM(new_deaths) as Total_new_death_cases
FROM portfolio_project..covid_deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Showing all the informations about covid vaccines 
SELECT * 
FROM portfolio_project..covid_vaccines


--showing countries with highest number of vaccinated people
SELECT location, total_vaccinations
FROM portfolio_project..covid_vaccines
WHERE continent is not null
ORDER BY total_vaccinations desc

--combining two tables
SELECT * 
FROM portfolio_project..covid_deaths d
Join portfolio_project..covid_vaccines v
	On d.location = v.location
	and d.date = v.date

--Looking at Total populations vs Vaccinations
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM portfolio_project..covid_deaths d
Join portfolio_project..covid_vaccines v
	On d.location = v.location
	and d.date = v.date
WHERE d.continent is not null 
ORDER BY 2,3



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated

From portfolio_project..covid_deaths d
Join portfolio_project..covid_vaccines v
	On d.location = v.location
	and d.date = v.date


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
