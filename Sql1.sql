--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4
--Where continent is not null
-- Select Data that we are using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelyhood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2


-- Looking at the total cases vs Population
-- Shows what precentage of population got Covid
Select location, date, Population, total_cases, (total_cases/population)*100 as PercentOfPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

-- Looking at countries with higest infection rate vs to population
Select location, Population, Max(total_cases) as HigestInfectionCount, MAX(total_cases/population)*100 as PercentOfPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, Population
order by PercentOfPopulationInfected desc

-- Showing countries with highest Deat Count per Population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

-- LETS BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count 
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select sum(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--group by date
order by 1,2




-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacinated
--,(RollingPeopleVacinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- USE CTE
With PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVacinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacinated
--,(RollingPeopleVacinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVacinated/population) *100
From PopvsVac




-- Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacinated
--,(RollingPeopleVacinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3
Select *, (RollingPeopleVaccinated/population) *100
From #PercentPopulationVaccinated

-- Creating a View to store data for later 

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacinated
--,(RollingPeopleVacinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3



Select * From PercentPopulationVaccinated