
--SELECT * FROM portfolioproject..covidVaccinations$ ORDER BY 3,4



-- looking at total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portfolioproject..covidDeaths$ 
ORDER BY 1,2

-- looking at total cases vs population
SELECT location, date,total_cases,population, (total_cases/population)*100 as percentpopulationinfected
FROM portfolioproject..covidDeaths$ 
--WHERE location like 'India'
ORDER BY 1,2

--looking at countries with highest infection rate compared to population
SELECT location, max (total_cases) as highestinfectioncount,population, max((total_cases/population))*100 as percentpopulationinfected
FROM portfolioproject..covidDeaths$ 
--WHERE location like 'India'
group by location, population
ORDER BY percentpopulationinfected desc

-- looking at countries with highest death count over population
SELECT continent, max(cast(total_deaths as int)) as totaldeathcount
FROM portfolioproject..covidDeaths$ 
--WHERE location like 'India'
where continent is not null
group by continent
ORDER BY totaldeathcount desc

-- shwoing the continent with highest death count per population
SELECT continent, max(cast(total_deaths as int)) as totaldeathcount
FROM portfolioproject..covidDeaths$ 
--WHERE location like 'India'
where continent is not null
group by continent
ORDER BY totaldeathcount desc

-- global numbers
SELECT date,sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portfolioproject..covidDeaths$ 
where continent is not null
group by date
ORDER BY 1,2

with popvsvac (continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated) as 
(SELECT dea.continent, dea.location,dea.date, dea.population, vacc.new_vaccinations,
sum(convert(int,vacc.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
--(Rollingpeoplevaccinated/population)*100
FROM portfolioproject..covidDeaths$ dea JOIN portfolioproject..covidVaccinations$ vacc 
on dea.location = vacc.location and dea.date = vacc.date
where dea.continent is not null
--order by 2,3
)
select (Rollingpeoplevaccinated/population)*100 from popvsvac

-- temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric 
)
insert into #percentpopulationvaccinated
SELECT dea.continent, dea.location,dea.date, dea.population, vacc.new_vaccinations,
sum(convert(int,vacc.new_vaccinations)) over (partition by dea.Location order by dea.location,dea.date) as Rollingpeoplevaccinated
--(Rollingpeoplevaccinated/population)*100
FROM portfolioproject..covidDeaths$ dea JOIN portfolioproject..covidVaccinations$ vacc 
on dea.location = vacc.location and dea.date = vacc.date
--where dea.continent is not null
--order by 2,3
select *, (Rollingpeoplevaccinated/population)*100 from #percentpopulationvaccinated
 
 --view
create view percentpopulationvaccinated as
SELECT dea.continent, dea.location,dea.date, dea.population, vacc.new_vaccinations,
sum(convert(int,vacc.new_vaccinations)) over (partition by dea.Location order by dea.location,dea.date) as Rollingpeoplevaccinated
--(Rollingpeoplevaccinated/population)*100
FROM portfolioproject..covidDeaths$ dea JOIN portfolioproject..covidVaccinations$ vacc 
on dea.location = vacc.location and dea.date = vacc.date
where dea.continent is not null
--order by 2,3

select* from percentpopulationvaccinated 
  

