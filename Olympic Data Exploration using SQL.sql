
/*
Olympic Dataset: The dataset contains olympic history  of 120 years i.e from 1896 to 2016. There 2 excel files. 

The first file contains details of all the players and the team they belong to such as name,height,sex,team,etc.
Total Players - 135571 ; Males - 101590, Females - 33981
Total Teams - 1013

The second file contains the details of events,medal_earned,sports,year,etc.
Season: Winter and Summer
Year: 1896 - 2016
Events : 765
Sports: 66
Medals earned: 39783 ; Golds_won - 13372 , Silvers_won - 13116 , bronzes_won - 13295

Skills used: Joins, CTE's, Window Functions, Subquery, String Function, Case Statements, Aggregate Functions


*/


-- Team with maximum gold medals. 

select top 1 a.team, count(event) as total_gold_medals from athletes$ as a
inner join athlete_events$ as ae
on ae.athlete_id = a.id
where medal = 'Gold'
group by team
order by total_gold_medals desc;


-- Total silver medals and year in which the team won maximum silver medals.

with cte as (
select a.team, ae.year,count(distinct event) as total_silver_medals, 
rank() over(partition by team order by count(distinct event) desc) as rn
from athlete_events$ as ae
inner join athletes$ as a
on ae.athlete_id = a.id
where medal = 'Silver'
group by team,ae.year)
select team,sum(total_silver_medals) as total_silver_medals, max(case when rn=1 then year end )as year_of_maximum_silver
from cte
group by team;


-- Player with maximum gold medals amongst the players which have only won gold medal.

with cte as (
select a.name, ae.medal
from athlete_events$ as ae
inner join athletes$ as a
on ae.athlete_id = a.id)
select top 1 name, count(medal) as total_gold_medals from cte
where medal = 'Gold' and name not in (select name from cte where medal in ('Silver','Bronze'))
group by name
order by total_gold_medals desc;


-- Player(s) with maximum gold medals each year. In case of a tie player names are displayed comma separated.

with cte as(
select ae.year,a.name,count(medal) as golds_won,rank() over(partition by ae.year order by count(medal) desc) as rn
from athlete_events$ as ae
inner join athletes$ as a
on ae.athlete_id = a.id
where medal = 'Gold'
group by ae.year,a.name)
select year,golds_won,STRING_AGG(name,' , ') as names from cte
where rn = 1
group by year,golds_won
order by year;


-- Event and Year in which India won its first gold, silver,bronze medals.

with cte as (
select year,event,medal, rank()over(partition by medal order by year,medal asc) as rn
from athlete_events$ as ae
inner join athletes$ as a
on ae.athlete_id = a.id
where team = 'India' and medal in ('Gold','Silver','Bronze'))
,cte1 as (select medal, year, event from cte
where rn =1)
select distinct * from cte1;


-- Players who won gold medal in summer and winter olympics both.

select name from athlete_events$ as ae
inner join athletes$ as a
on ae.athlete_id = a.id
where medal = 'Gold' and season in ('Summer','Winter')
group by name
having count(distinct season) = 2;


-- Players who won gold, silver and bronze medal in a single olympics.

select name,year from athlete_events$ as ae
inner join athletes$ as a
on ae.athlete_id = a.id
where medal in ('Gold','Silver','Bronze')
group by year,name
having count(distinct medal) = 3;


-- Players who won gold medals in consecutive 3 summer olympics happeing in the year 2000 and onwards in the same event. 
--Assumption: Summer Olympics happen in every 4 years

with cte as(
select name,year,event from athlete_events$ as ae
inner join athletes$ as a
on ae.athlete_id = a.id
where season = 'Summer' and  year >=2000 and medal = 'Gold')
, cte1 as (select *, lead(year)over(partition by name,event order by year) as next_year,lag(year)over(partition by name,event order by year) as previous_year from cte)
select name,event from cte1
where year = previous_year + 4 and year = next_year -4;




