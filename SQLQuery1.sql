
select *
from PortifolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortifolioProject..CovidVaccinations
--order by 3,4

--select data that we are going to be using	

select location, date, total_cases, new_cases, total_deaths, population
from PortifolioProject..CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathspresentage
from PortifolioProject..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2

--looking at toyal cases vs population
--show what precentage of population got covid

select location, date, population, total_cases, population, (total_cases/population)*100 as precentpopulationinfected
from PortifolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as highestinfationcount , population, max(total_cases/population)*100 as precentpopulationinfected
from PortifolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by  precentpopulationinfected desc




--LET'S BREAK THNGS DOWN BY CONTINENT
--showing countries with highest death count per population


select continent, max(cast(total_deaths as int))as totaldeathcount
from PortifolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by totaldeathcount  desc


--global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int))as total_deaths 
,sum(cast(new_deaths as int ))/sum(new_cases)*100 as deathspresentage
from PortifolioProject..CovidDeaths
--where location like '%states%' 
where continent is not null
--group by date
order by 1,2


--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date)
as rollingpeoplevaccenated

from PortifolioProject..CovidDeaths dea
join PortifolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use CTE

With popvsvac (continent, location, date, population, new_vaccinations,rollingpeoplevaccenated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date)
as rollingpeoplevaccenated
--,(rollingpeoplevaccenated/population)*100
from PortifolioProject..CovidDeaths dea
join PortifolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(rollingpeoplevaccenated/population)*100
from popvsvac



--TEMP TABLE


 drop table if exists #precentpopulationinfected
create table #precentpopulationinfected
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinated numeric,
rollingpeoplevaccenated numeric
)

insert into #precentpopulationinfected

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date)
as rollingpeoplevaccenated
--,(rollingpeoplevaccenated/population)*100
from PortifolioProject..CovidDeaths dea
join PortifolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


select * ,(rollingpeoplevaccenated/population)*100
from #precentpopulationinfected


--creating view to store data for later visulasation

create view precentpopulationinfected as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date)
as rollingpeoplevaccenated
--,(rollingpeoplevaccenated/population)*100
from PortifolioProject..CovidDeaths dea
join PortifolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from precentpopulationinfected