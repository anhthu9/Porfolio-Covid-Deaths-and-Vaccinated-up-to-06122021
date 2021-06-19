select *
from [portfolio covid]..['covid death$']
where continent is not null
order by 3,4

--select *
--from [portfolio covid]..['covid vaccination']
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from [portfolio covid]..['covid death$']
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in Vietnam
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [portfolio covid]..['covid death$']
where location like '%viet%'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of Vietnam poplation go Covid
select location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
from [portfolio covid]..['covid death$']
where location like '%viet%'
and continent is not null
order by 1,2

-- Looking at countries with highest infection rate compared to Poplation
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentofPopulationInfected
from [portfolio covid]..['covid death$']
where continent is not null
group by location, population
order by PercentofPopulationInfected desc

--Showing Countries with Highest Death Count per Population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [portfolio covid]..['covid death$']
where continent is not null
group by location
order by TotalDeathCount desc

-- Showing Continents with Highest Death Count
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [portfolio covid]..['covid death$']
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

select sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [portfolio covid]..['covid death$']
where continent is not null
order by 1,2

--Looking at Total Population vs Vaccination
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [portfolio covid]..['covid death$'] as dea
join [portfolio covid]..['covid vaccination'] as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinate
Create Table #PercentPopulationVaccinate
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinate
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [portfolio covid]..['covid death$'] as dea
join [portfolio covid]..['covid vaccination'] as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinate

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [portfolio covid]..['covid death$'] as dea
join [portfolio covid]..['covid vaccination'] as vac
	on dea.location = vac.location
	and dea.date = vac.date

	Select *
	From PercentPopulationVaccinated