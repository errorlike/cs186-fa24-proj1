-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era) AS
  SELECT MAX(era)
FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst,namelast,birthyear
  from people where
  weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst,namelast,birthyear
  from people
  where namefirst like "% %"
  order by namefirst
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear,avg(height) as avgheight ,count(*) as count
  from people group by birthyear
  order by birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear,avg(height) as avgheight ,count(*) as count
  from people
  group by birthyear
  having avg(height) > 70
  order by birthyear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
select p.nameFirst,p.nameLast,p.playerId,hf.yearid
from people as p
join halloffame hf
on p.playerId = hf.playerId
where hf.inducted = 'Y'
order by hf.yearId desc,hf.playerId;
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS

select p.nameFirst,p.nameLast,p.playerId,s.schoolID,hf.yearid
from people as p
join collegeplaying cp
on p.playerID = cp.playerid
join halloffame hf
on p.playerId = hf.playerId
join schools s
on cp.schoolID = s.schoolID
where hf.inducted = 'Y' and s.schoolState = "CA"
order by hf.yearid desc,s.schoolID,p.playerid;

;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  select p.playerID,p.nameFirst,p.nameLast,s.schoolID 
from people as p
join halloffame hf on p.playerID = hf.playerID 
left outer join collegeplaying cp on p.playerID=cp.playerid
left outer join schools as s on cp.schoolID = s.schoolID
where hf.inducted = 'Y'
order by p.playerID desc,s.schoolID 
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
select p.playerID,p.namefirst,p.nameLast,b.yearID, 1.0*(H-H2B-H3B-HR+H2B*2+H3B*3+HR*4) /AB as sig 
from batting b,people p 
where b.playerID=p.playerID and b.AB>50
group by p.playerID,b.yearID,b.teamID
order by sig desc,b.yearid,p.playerID 
LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  select p.playerID,p.nameFirst,p.nameLast, 1.0*sum(H-H2B-H3B-HR+H2B*2+H3B*3+HR*4) /sum(AB) as lsig 
  from batting b,people p 
  where b.playerID=p.playerID 
  group by p.playerID
  having sum(AB) > 50
  order by lsig desc,p.playerID 
  limit 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  select p.nameFirst,p.nameLast, 1.0*sum(H-H2B-H3B-HR+H2B*2+H3B*3+HR*4) /sum(AB) as lsig 
  from batting b,people p 
  where b.playerID=p.playerID 
  group by p.playerID
  having sum(AB) > 50 and lsig > (select 1.0*sum(H-H2B-H3B-HR+H2B*2+H3B*3+HR*4) /sum(AB) from batting b, people p where p.playerID="mayswi01" and b.playerID="mayswi01" ) 
  order by lsig desc,p.playerID 
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
select yearId,min(s.salary) as min,max(s.salary) as max,avg(s.salary) as avg 
from salaries s,people p 
where s.playerID =p.playerID  
group by s.yearId 
order by s.yearid
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  with year_statis(min,max,range) as (
  select min(s.salary) ,max(s.salary),(max(s.salary)-min(s.salary))/10 from salaries s where yearId =2016 ),
  bin as (
  select binid,binid*(select range from year_statis)+(select min from year_statis) as low,(binid+1)*(select range from year_statis)+(select min from year_statis) as high from binids)
  select *,(select iif(binid = 9,count(*)+1,count(*)) from salaries where salary>=low and salary<high and yearid = 2016) as count from bin
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  with y(yearId,max,min,avg) as  
  (select yearID,max(salary),min(salary),avg(salary) 
    from salaries 
    group by yearID 
    )
  select current.yearId,current.min-last.min as mindiff, current.max-last.max as maxdiff,current.avg-last.avg as avgdiff  
  from y current 
  join y last on current.yearId -1 = last.yearId
  order by current.yearId
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
with max_statis as (select max(salary) as max, yearId from salaries s 
where yearId = 2000 or yearId = 2001 group BY yearId) 
select p.playerID,p.nameFirst,p.nameLast,s.salary,s.yearId 
from salaries s 
join max_statis m on s.salary = m.max and s.yearId=m.yearId 
join people p on p.playerID = s.playerID 
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  with star_salary(teamID,min,max) as (select a.teamID,min(salary),max(salary) 
  from salaries s,allstarfull a  
  where s.yearId = 2016 and s.yearID = a.yearId and a.playerID=s.playerID and a.teamID=s.teamID 
  group by a.teamID )
  select teamID,max-min as diffAvg from star_salary
;

