--Portfolio Project

select * from PortfolioProject..['covid deaths$']
where continent is not null
order by 3,4;


select * from PortfolioProject..['covid vacc$']
order by 3,4;


--Selecting Data from Covid Deaths

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..['covid deaths$']
where continent is not null
order by 1,2;



--Total cases vs Population
select location,date,total_cases,population,(total_cases/population)*100 as populationinfected
from PortfolioProject..['covid deaths$']
where location like '%India%'
order by 1,2;

--Countries with highest infection rate as compared to population
select location,population,max(total_cases) as HighestInfectionCount , max((total_cases/population)*100) as Deathpercentage
from PortfolioProject..['covid deaths$']
where continent is not null
group by location,population
order by populationinfected desc;


--Showing Countries with Highest Death count per population
select location,max(total_deaths) as Totaldeathcount
from PortfolioProject..['covid deaths$']
where continent is not null
group by location
order by Totaldeathcount desc;


--Showing Countries with Highest Death count per population by continents
select continent,max(total_deaths) as Totaldeathcount
from PortfolioProject..['covid deaths$']
where continent is not null
group by continent
order by Totaldeathcount desc;

--Total Population vs Vaccinations
select dea.continent,dea.date,dea.location,dea.population,vacc.new_vaccinations
from PortfolioProject..['covid deaths$'] as dea join 
PortfolioProject..['covid vacc$'] as vacc on
dea.location=vacc.location
and dea.date=vacc.date
where dea.continent is not null
order by 1,2,3;

--Partition by location
select dea.continent,dea.date,dea.location,dea.population,vacc.new_vaccinations, sum(cast(vacc.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated 
from PortfolioProject..['covid deaths$'] as dea join 
PortfolioProject..['covid vacc$'] as vacc on
dea.location=vacc.location
and dea.date=vacc.date
where dea.continent is not null
order by 2,3;

--using CTE
with POPvsVACC (continent,date,location,population,new_vaccinations,Rollingpeoplevaccinated)
as
(
select dea.continent,dea.date,dea.location,dea.population,vacc.new_vaccinations, sum(cast(vacc.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated 
from PortfolioProject..['covid deaths$'] as dea join 
PortfolioProject..['covid vacc$'] as vacc on
dea.location=vacc.location
and dea.date=vacc.date
where dea.continent is not null

)
select*, (Rollingpeoplevaccinated/Population)*100 as Percentage 
from POPvsVACC ;

--temp table

create table #perpopulationvaccinated
(
   continent nvarchar(255),
   date datetime,
   location nvarchar(255),
   population numeric,
   new_vaccinations numeric,
   Rollingpeoplevaccinated numeric
)


Insert into #perpopulationvaccinated

select dea.continent,dea.date,dea.location,dea.population,vacc.new_vaccinations, sum(cast(vacc.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated 
from PortfolioProject..['covid deaths$'] as dea join 
PortfolioProject..['covid vacc$'] as vacc on
dea.location=vacc.location
and dea.date=vacc.date
where dea.continent is not null

select*,(Rollingpeoplevaccinated/population)*100
from #perpopulationvaccinated


--creating view to store data for data visualisation

Create View [p] as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..['covid deaths$'] dea
Join PortfolioProject..['covid vacc$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 






