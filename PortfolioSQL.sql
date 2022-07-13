select * from covidDeaths
order by 3,4 ;

select * from CovidVaccinations
order by 3,4 ;


--Selecting Data we rae going to use

select location,date,total_cases,new_cases,total_deaths,population from CovidDeaths
order by 1,2 ;

--Total case vs total deaths
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercetage from CovidDeaths
where location like '%india%'
order by 1,2 ;

--Total cases vs the population
--Population got covid
select location,date,total_cases,population, (total_cases/population)*100 as CovidPercetage from CovidDeaths
--where location like '%india%'
order by 1,2


--Looking at countries with highest covid rate as compared to the population

select location,population, max((total_cases/population))*100 as CovidPercetage from CovidDeaths

group by location,population
order by CovidPercetage desc;

--Showing countries with hightest death count 

select location, max(cast(total_deaths as int)) as DeathsCount from CovidDeaths
where continent is not null
group by location
order by DeathsCount desc ;

--Showing the continent with the highest death count

select continent , max(cast(total_deaths as int)) as deathcount from CovidDeaths
where continent is not null
group by continent
order by deathcount desc; 

--
select sum(new_cases) as total_cases, sum(cast(new_deaths as int))as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage 
from CovidDeaths
where continent is not null;

--join two table
select * from CovidDeaths
join CovidVaccinations on CovidDeaths.location=CovidVaccinations.location
and CovidDeaths.date=CovidVaccinations.date
;

--Looking at total population got vaccinated
select CovidDeaths.continent,CovidDeaths.location, CovidDeaths.date, CovidDeaths.population,CovidVaccinations.new_vaccinations,
sum(convert(bigint,CovidVaccinations.new_vaccinations)) over (partition by coviddeaths.location order by coviddeaths.location,coviddeaths.date)
as peoplevaccinated from CovidDeaths
join CovidVaccinations on CovidDeaths.location=CovidVaccinations.location
and CovidDeaths.date=CovidVaccinations.date
where covidDeaths.continent is not null
order by 2,3
;

--Use CTE
with popvsvac (continent,location,date,population,new_vaccinations,peoplevaccinated)
as
(
select CovidDeaths.continent,CovidDeaths.location, CovidDeaths.date, CovidDeaths.population,CovidVaccinations.new_vaccinations,
sum(convert(bigint,CovidVaccinations.new_vaccinations)) over (partition by coviddeaths.location order by coviddeaths.location,coviddeaths.date)
as peoplevaccinated from CovidDeaths
join CovidVaccinations on CovidDeaths.location=CovidVaccinations.location
and CovidDeaths.date=CovidVaccinations.date
where covidDeaths.continent is not null
--order by 2,3
)
select *, peoplevaccinated/population*100 as percentage from popvsvac;


--Temp Table
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from PercentPopulationVaccinated

