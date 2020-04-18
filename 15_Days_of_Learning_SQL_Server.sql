WITH submission_count AS 
(
    select distinct s.submission_date, s.hacker_id, h.name, count(*) as submission_cnt
    from submissions s, hackers h 
    where s.hacker_id = h.hacker_id  
    group by s.submission_date, s.hacker_id, h.name
),
min_date AS
(
    select min(submission_date) as min_submission_date from submissions
),
top_hackers AS
(
    select submission_date, hacker_id, name from (
    select *, row_number() over (partition by submission_date order by submission_cnt desc, hacker_id) as rank from submission_count) s where rank = 1
),
unique_count AS (
    select submission_date, count(*) as uniq from (
    select submission_date, hacker_id, submission_cnt, row_number() over (partition by hacker_id order by submission_date ASC) as num 
    from submission_count
  ) s1
  where num - 1 = datediff(day, (select min_submission_date from min_date), submission_date) 
  group by submission_date
)
select u.submission_date, u.uniq, t.hacker_id, t.name from top_hackers t, unique_count u where t.submission_date = u.submission_date order by u.submission_date;