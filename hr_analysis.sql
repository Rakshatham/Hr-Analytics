CREATE VIEW v_employees AS
SELECT *,
  CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END AS left_flag,
  CASE WHEN Age < 25 THEN '18-24' WHEN Age < 35 THEN '25-34'
       WHEN Age < 45 THEN '35-44' WHEN Age < 55 THEN '45-54' ELSE '55+' END AS age_group,
  CASE WHEN MonthlyIncome < 10000 THEN 'Low' WHEN MonthlyIncome < 25000 THEN 'Medium'
       WHEN MonthlyIncome < 40000 THEN 'High' ELSE 'Very High' END AS income_band
FROM employees;
SELECT COUNT(*) total, SUM(left_flag) leavers,
       ROUND(100*AVG(left_flag),2) attrition_pct
FROM v_employees;
SELECT Department, COUNT(*) headcount,
       ROUND(100*AVG(left_flag),2) attrition_pct
FROM v_employees GROUP BY Department ORDER BY attrition_pct DESC;
SELECT OverTime, COUNT(*) headcount,
       ROUND(100*AVG(left_flag),2) attrition_pct
FROM v_employees GROUP BY OverTime;
SELECT Attrition, ROUND(AVG(Age),1) avg_age, ROUND(AVG(MonthlyIncome)) avg_income,
       ROUND(AVG(YearsAtCompany),1) avg_tenure,
       ROUND(AVG(DistanceFromHome),1) avg_distance
FROM employees GROUP BY Attrition;
SELECT age_group, COUNT(*) n, ROUND(100*AVG(left_flag),2) attrition_pct
FROM v_employees GROUP BY age_group ORDER BY age_group;
SELECT income_band, COUNT(*) n, ROUND(100*AVG(left_flag),2) attrition_pct
FROM v_employees GROUP BY income_band;
-- Top 3 highest-paid employees in each department
SELECT * FROM (
  SELECT EmployeeNumber, Department, JobRole, MonthlyIncome,
         RANK() OVER (PARTITION BY Department ORDER BY MonthlyIncome DESC) rnk
  FROM employees) t
WHERE rnk <= 3;
-- Employees paid below 70% of their job-role average
WITH role_avg AS (
  SELECT JobRole, AVG(MonthlyIncome) avg_inc FROM employees GROUP BY JobRole)
SELECT e.EmployeeNumber, e.JobRole, e.MonthlyIncome, ROUND(r.avg_inc) role_avg
FROM employees e JOIN role_avg r ON e.JobRole = r.JobRole
WHERE e.MonthlyIncome < r.avg_inc * 0.7
LIMIT 100;
-- Current employees at risk: no promotion in 5+ years, overtime, low satisfaction
SELECT EmployeeNumber, Department, JobRole, YearsSinceLastPromotion
FROM employees
WHERE Attrition='No' AND YearsSinceLastPromotion >= 5
  AND OverTime='Yes' AND JobSatisfaction <= 2
LIMIT 100;
SHOW DATABASES;
SELECT COUNT(*) FROM analytics.employees;   -- expect 50000
