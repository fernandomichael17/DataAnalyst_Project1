select *
from CovidDeath
select *
from CovidVaccin
--order by 1,2
--select * from CovidVaccin
--order by 3,4
alter table dbo.CovidVaccin
alter column new_vaccinations numeric


--Presentasi Kematian oleh Covid berdasarkan banyaknya kasus di Indonesia
select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as precentage
from CovidDeath
where location = 'Indonesia'
order by date desc


--presentasi Kasus berdasarkan populasi di Indonesia
select location, date, total_cases, population, (total_cases/population)*100 as Cases_precentage
from CovidDeath
--where location = 'Indonesia'
order by Cases_precentage desc

--Presentasi kasus tertinggi berdasarkan wilayah di dunia
select location, population, max(total_cases) as highest_infect, max((total_cases/population)*100) as Cases_precentage
from CovidDeath
where continent is not null
--where location = 'Indonesia'
group by location, population
order by Cases_precentage desc

--Presentasi kematian berdasarkan total kasus
select location, max(total_deaths) as TotalDeath, max(total_cases) as TotalCase, max((total_deaths/total_cases)*100) as DeathPrecentage
from CovidDeath
where continent is not null
group by location
order by DeathPrecentage desc

--Penambahan Kasus hari ini
select  location, date, sum(new_deaths) as NewDeath, sum(new_cases) as NewCases, sum(new_deaths)/sum(new_cases) * 100 as DeathPrecentage
from CovidDeath
where continent is not null and
new_deaths != 0 and
new_cases != 0
group by location, date
order by location,date desc

select * from CovidDeath dea
join CovidVaccin vac
on dea.location = vac.location

-- Presentase populasi dan orang yang telah divaksin
select dea.continent, dea.location, dea.date, max(vac.people_vaccinated) as Vaccinated, max(dea.population) as Population, (max(vac.people_vaccinated) / max(dea.population)) * 100 as VaccinPrecentage
from CovidDeath dea
join CovidVaccin vac
on dea.location = vac.location
where dea.continent is not null --and
--dea.location = 'Indonesia'
group by dea.continent, dea.location, dea.date 
order by dea.date desc

--Pertumbuhan masyarakat yang divaksin tiap harinya
with PopVac(continent, location, date, population, new_vaccinations, GrowthVaccin)
as
(
select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as GrowthVaccin
from CovidDeath dea
join CovidVaccin vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--group by dea.continent, dea.location, dea.date, dea.population
)

select *, (GrowthVaccin / population) * 100 as GrowthPrecentage from
PopVac

--Membuat Tabel baru
drop table if exists PeopleVaccinated
create table PeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
GrowthVaccin numeric
)
insert into PeopleVaccinated (continent, location, date, population, new_vaccinations, GrowthVaccin)
select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) 
as GrowthVaccin
from CovidDeath dea
join CovidVaccin vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null

select *, (GrowthVaccin / population)*100 as GrowthPrecentage
from PeopleVaccinated
order by location, continent, date