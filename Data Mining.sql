SELECT date, total_cases, total_deaths, (total_deaths/covidDeaths.total_cases)*100 as DeathPercentage from covidDeaths where location="China" order by 1, 2 ;

# Looking at Total cases vs Population:
select location, date, total_cases, population, (total_cases/covidDeaths.population)*100 as CasePercentage from covidDeaths order by 5;

# Highest infection country
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/covidDeaths.population))*100 as PecentagePopulationInfected from covidDeaths group by location, population order by PecentagePopulationInfected desc;

# Showing countries with highest death count per population
select location, MAX(total_deaths) as TotalDeathCount from covidDeaths group by location order by 2 desc;
select location, MAX(ifnull(total_deaths, 0)) as TotalDeathCount from covidDeaths  where continent is not null
                                                                                   group by location order by TotalDeathCount desc;

# Let's break things down by continent

## Showing continents with highest death count per population
select continent, MAX(ifnull(total_deaths, 0)) as TotalDeathCount from covidDeaths where continent is not null
                                                                                   group by continent order by TotalDeathCount desc;

# Global numbers
select date, sum(new_cases) as TotalNewCases, sum(new_deaths) as TotalNewDeaths, sum(new_deaths)/sum(new_cases) * 100
    as TotalDeathRate from covidDeaths where continent is not null group by date order by date desc;

select sum(new_cases) as TotalNewCases, sum(new_deaths) as TotalNewDeaths, sum(new_deaths)/sum(new_cases) * 100
    as TotalDeathRate from covidDeaths where continent is not null  order by date desc;

# Looking at total population vs vaccination

select * from covidDeaths dea join covidVaccinations vac  on dea.location = vac.location and dea.date = vac.date;

select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covidDeaths dea
    join covidVaccinations vac on dea.location = vac.location
                                      and dea.date = vac.date where dea.continent is not null order by 1, 2, 3;


# USE CTE

with Pop_vs_Vac(continent, location, date, population, new_vaccination, RollingPeopleVaccinated) as (
    select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covidDeaths dea
    join covidVaccinations vac on dea.location = vac.location
                                      and dea.date = vac.date where dea.continent is not null)
select *, RollingPeopleVaccinated/population * 100 from Pop_vs_Vac;

# Temp table
Drop table if exists PercentPopulationVaccinated;
create table PercentPopulationVaccinated(
    continent nvarchar(255),
    location nvarchar(255),
    population numeric,
    date date,
    new_vaccination numeric,
    rolling_people_vaccinated numeric
);

insert into PercentPopulationVaccinated
    select dea.continent, dea.location, population, dea.date, vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covidDeaths dea
    join covidVaccinations vac on dea.location = vac.location
                                      and dea.date = vac.date where dea.continent is not null and dea.date is not null;
select *, data_analyst_project.PercentPopulationVaccinated.rolling_people_vaccinated/population * 100 from PercentPopulationVaccinated;


# creating view to store data for later visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, population, dea.date, vac.new_vaccinations, SUM(new_vaccinations) OVER
    (Partition BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covidDeaths dea JOIN covidVaccinations vac ON dea.date = vac.date and dea.location = vac.location
where dea.date is not null;


select * from PercentPopulationVaccinated;