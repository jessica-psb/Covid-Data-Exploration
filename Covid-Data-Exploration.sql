select 
	location, 
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
from deaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Indonesia
select 
	location, 
	date,
	total_cases,
	total_deaths,
	total_deaths/total_cases *100 as death_percentage
from deaths
where location like 'indonesia'
order by 1,2

-- Looking at Total Cases vs Population
-- Show the percentage of population got Covid
select 
	location, 
	date,
	total_cases,
	population,
	total_cases/population *100 as percent_population_infection
from deaths
where location like 'indonesia'
order by 1,2

-- Looking at countries with highest infection rate compared to population
select 
	location,
	population,
	max(total_cases) as HighestInfectionCount,
	max(total_cases/population*100) as cases_percentage
from deaths
group by 1,2
order by 4 desc

-- Show countries with highest death count per location
select 
	location,
	max(total_deaths) as TotalDeathCount
from deaths
where continent != ''
group by 1
order by 2 desc

-- Break things down by continent
select 
	continent,
	max(total_deaths) as TotalDeathCount
from deaths
where continent != ''
group by 1
order by 2 desc

-- Death Percentage by date
select 
	date,
	sum(new_cases) new_cases,
	sum(new_deaths) new_deaths,
	sum(new_deaths)/sum(new_cases) *100 death_percentage
from deaths
where continent !=''
group by 1
order by 1

-- Global numbers
select 
	sum(new_cases) total_cases,
	sum(new_deaths) total_deaths,
	sum(new_deaths)/sum(new_cases) *100 death_percentage
from deaths
where continent !=''
order by 1,2


-- Total population vs vaccinations
select
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(vac.new_vaccinations) over 
		(partition by dea.location order by dea.location, dea.date) rolling_people_vaccinated
from deaths dea
join vaccinations vac 
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent !=''
order by 2,3

-- use CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccination,  RollingPeopleVaccinated)
as(
	select
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		sum(vac.new_vaccinations) over 
			(partition by dea.location order by dea.location, dea.date) rolling_people_vaccinated
	from deaths dea
	join vaccinations vac 
		on dea.location = vac.location 
		and dea.date = vac.date
	where dea.continent !=''
	order by 2,3
)
select 
	*,
	RollingPeopleVaccinated/Population *100
from PopvsVac

-- Temp Table
drop table if exists PercPopVac
create table PercPopVac(
	continent varchar(255),
	location varchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	rolling_people_vaccinated numeric
)

insert ignore into PercPopVac
select
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		sum(vac.new_vaccinations) over 
			(partition by dea.location order by dea.location, dea.date) rolling_people_vaccinated
	from deaths dea
	join vaccinations vac 
		on dea.location = vac.location 
		and dea.date = vac.date
		
-- create view 4 visualizations
create view percentpopvac as
select
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		sum(vac.new_vaccinations) over 
			(partition by dea.location order by dea.location, dea.date) rolling_people_vaccinated
	from deaths dea
	join vaccinations vac 
		on dea.location = vac.location 
		and dea.date = vac.date
	where dea.continent !=''
	
select * from percentpopvac