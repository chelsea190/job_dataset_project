/* ⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
Database Load Issues (follow if receiving permission denied when running SQL code below)

NOTE: If you are having issues with permissions. And you get error: 

'could not open file "[your file path]\job_postings_fact.csv" for reading: Permission denied.'

1. Open pgAdmin
2. In Object Explorer (left-hand pane), navigate to `sql_course` database
3. Right-click `sql_course` and select `PSQL Tool`
    - This opens a terminal window to write the following code
4. Get the absolute file path of your csv files
    1. Find path by right-clicking a CSV file in VS Code and selecting “Copy Path”
5. Paste the following into `PSQL Tool`, (with the CORRECT file path)

\copy company_dim FROM '[Insert File Path]/company_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_dim FROM '[Insert File Path]/skills_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy job_postings_fact FROM '[Insert File Path]/job_postings_fact.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_job_dim FROM '[Insert File Path]/skills_job_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

*/

-- NOTE: This has been updated from the video to fix issues with encoding

COPY company_dim
FROM 'C:\Projects\csv_files\company_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY skills_dim
FROM 'C:\Projects\csv_files\skills_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY job_postings_fact
FROM 'C:\Projects\csv_files\job_postings_fact.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY skills_job_dim
FROM 'C:\Projects\csv_files\skills_job_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');


CREATE TABLE january_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

CREATE TABLE february_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE TABLE march_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

CREATE TABLE april_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 4;

CREATE TABLE may_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 5;

CREATE TABLE june_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 6;


CREATE TABLE july_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 7;

CREATE TABLE august_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 8;


CREATE TABLE september_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 9;


CREATE TABLE october_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 10;


CREATE TABLE november_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 11;


CREATE TABLE december_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 12;


SELECT *
FROM job_postings_fact ;



SELECT 
    COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
   END AS  location_category   
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY location_category;
    

WITH job_amount AS(
    SELECT company_id , 
    COUNT(*) as number_of_jobs
FROM job_postings_fact
GROUP BY company_id
)

SELECT job_amount.number_of_jobs AS total_jobs, 
company_dim.name AS company_name
FROM company_dim
JOIN job_amount ON job_amount.company_id = company_dim.company_id
ORDER BY number_of_jobs DESC
;


WITH top_skills AS(
    SELECT skill_id , COUNT(*) AS amount
    FROM skills_job_dim
    GROUP BY skill_id
    ORDER BY amount DESC
    LIMIT 5
)

SELECT skills_dim.skills , top_skills.amount
FROM skills_dim
JOIN top_skills ON top_skills.skill_id = skills_dim.skill_id ;



WITH amount_of_jobs AS(
    SELECT company_id , COUNT(job_id) as jobs
    FROM job_postings_fact
    GROUP BY company_id
),
categorized AS (
   SELECT company_id , jobs,
   CASE
   WHEN jobs < 10 THEN 'Small'
   WHEN jobs BETWEEN 10 AND 50 THEN 'Medium'
   ELSE 'Large'
   END AS categories
   FROM amount_of_jobs 
)

SELECT 
company_dim.name AS company_name, categorized.jobs AS amount_of_jobs , categorized.categories AS categories
FROM categorized
JOIN company_dim ON categorized.company_id = company_dim.company_id
ORDER BY categorized.jobs DESC
;


WITH top5_remote_skills AS(
    SELECT skills_job_dim.skill_id , COUNT(*) AS demand
    FROM skills_job_dim
    JOIN job_postings_fact ON
    job_postings_fact.job_id = skills_job_dim.job_id
    WHERE job_postings_fact.job_location = 'Anywhere' AND job_postings_fact.job_title_short = 'Data Analyst'
    GROUP BY skills_job_dim.skill_id 
    
)

SELECT top5_remote_skills.skill_id , skills_dim.skills , top5_remote_skills.demand
FROM top5_remote_skills
JOIN skills_dim ON
skills_dim.skill_id = top5_remote_skills.skill_id
ORDER BY top5_remote_skills.demand DESC
LIMIT 5
;


SELECT 
first_quarter_jobs.
 (
    SELECT *
    FROM january_jobs
    UNION ALL
    SELECT *
    FROM february_jobs
    UNION ALL
    SELECT *
    FROM march_jobs
) AS first_quarter_jobs
WHERE first_quarter_jobs.salary_year_avg > 70000






