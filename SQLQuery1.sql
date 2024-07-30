select * from PortfolioProject..CovidDeaths$

select * from PortfolioProject..CovidVaccinations$

Select location,date, total_cases_per_million, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2 

-- total cases vs total deaths 
--shows the likelihood of dying if you contract covid in your country
Select location,date, total_cases_per_million , total_deaths_per_million, (total_deaths_per_million/total_cases_per_million)*100 as Death_percentage
from PortfolioProject..CovidDeaths$
where location like '%inDia%'
order by 1,2 

--looking at the total cases vs population 
--shows what percentage got covid
Select location,date, total_cases_per_million as total_cases , population, (total_cases_per_million/population)*100 as percentage_of_populationaffected
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2 

--looking at countries with highest infection rates paired to population
Select location,MAX( total_cases_per_million/1000000 *population) as HighestInfectioncount, population, Max((total_cases_per_million/1000000 *population/population))*100 as PerofPop_affected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
group by population,location
order by PerofPop_affected DESC

--SHOwing countries with highest death count per population
Select location,MAX(cast( total_deaths as int) ) as Highestdeathcount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by Highestdeathcount DESC

-- LETS BREAK BY CONTINENT 

Select continent,MAX(cast( total_deaths as int) ) as Highestdeathcount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by Highestdeathcount DESC

-- showing the continenets with the highest death count 

-- global numbers 

Select  sum(new_cases) as total_cases , sum (cast(new_deaths as int))as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths$
where continent is not null
--group by date
order by 1,2 


--looking at total population vs vaccination


select dea.continent,dea.location, dea.date , dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over 
(partition by dea.location order by dea.location, dea.date) as rolling_ppl_vacc
--(rolling_ppl_vacc/population)*100
from PortfolioProject..CovidDeaths$ dea
Join 
PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--use cte 

with PopvsVac (Continent, Location, Date , Population ,New_vaccinations, rolling_ppl_vacc)
as
(
select dea.continent,dea.location, dea.date , dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over 
(partition by dea.location order by dea.location, dea.date) as rolling_ppl_vacc
--(rolling_ppl_vacc/population)*100
from PortfolioProject..CovidDeaths$ dea
Join 
PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3 
)
select *,(rolling_ppl_vacc/Population)*100
from PopvsVac

--temp table 

drop table if exists #percentpopvaccinated
create table #percentpopvaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Data datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)



insert into #percentpopvaccinated
select dea.continent,dea.location, dea.date , dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over 
(partition by dea.location order by dea.location, dea.date) as rolling_ppl_vacc
--(rolling_ppl_vacc/population)*100
from PortfolioProject..CovidDeaths$ dea
Join 
PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3 

select *,(RollingPeopleVaccinated/Population)*100
from #percentpopvaccinated


--creating view to store data for later visualizations 

create view percentpopvaccinated as
select dea.continent,dea.location, dea.date , dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over 
(partition by dea.location order by dea.location, dea.date) as rolling_ppl_vacc
--(rolling_ppl_vacc/population)*100
from PortfolioProject..CovidDeaths$ dea
Join 
PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3 

select * from percentpopvaccinated

