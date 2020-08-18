


/* ********************************************************** */
/* ********************************************************** */
/* *******      ANALYSIS                               ****** */
/* ********************************************************** */
/* ********************************************************** */

---- 2a. Number of students by Department

SELECT c.DepartmentName, COUNT(DISTINCT a.StudentId) AS students
FROM Classrooms a
INNER JOIN Courses b
  ON b.CourseId = a.CourseId
INNER JOIN Departments c
  ON b.DepartmentId = c.DepartmentId
GROUP BY c.DepartmentName

---- 2b. How many studenst has the English teacher by course and in total?

SELECT b.CourseName, COUNT(DISTINCT a.StudentId) AS students
FROM Classrooms a
INNER JOIN Courses b
  ON b.CourseId = a.CourseId
WHERE b.DepartmentID = 1  
GROUP BY b.CourseName
UNION ALL
SELECT 'Total' AS CourseName, COUNT(DISTINCT a.StudentId) AS students
FROM Classrooms a
INNER JOIN Courses b
  ON b.CourseId = a.CourseId
WHERE b.DepartmentID = 1  

---- 2c. How many small (<22) and bigger (>=22) Classrooms has the Science Department?

SELECT 
    (CASE WHEN (sci.classcnt < 22) THEN ('Small classrooms') 
         ELSE ('Big classrooms') 
    END) AS classroom_size,
    COUNT(1) AS num_classrooms
FROM (
    SELECT b.CourseId, COUNT(1) AS classcnt
    FROM Classrooms a
    INNER JOIN Courses b
      ON b.CourseId = a.CourseId
    WHERE b.DepartmentID = 2
    GROUP BY b.CourseID
) AS sci
GROUP BY (CASE WHEN (sci.classcnt < 22) THEN ('Small classrooms') 
         ELSE ('Big classrooms') 
    END)
  
----- 2d. How many students are by Gender?

SELECT Gender, COUNT(1) num_students
FROM students
GROUP BY Gender

----- 2e. In which courses the percentage of males / females are higher than 70% ?

SELECT cls.CourseId,
		cls.CourseName, 
		 cls.Gender, 
		 ((cls.num_students * 1.0 / cls.students_total)*100) AS studentsPercent
FROM (
SELECT a.CourseId,
	   c.CourseName, 
       b.Gender, 
       COUNT(1) AS num_students,
       (SELECT COUNT(1) FROM Classrooms WHERE CourseId = a.CourseId) AS students_total
FROM Classrooms a
LEFT OUTER JOIN Students b
  ON a.StudentId = b.StudentId
LEFT OUTER JOIN Courses c
  ON a.CourseId = c.CourseId
GROUP BY c.CourseName, 
         b.Gender,
		 a.CourseId
) AS cls
WHERE ((cls.num_students * 1.0 / cls.students_total)) > 0.7

----- 2f. How many students (n and %) have a degree of 80+ by Department?

-- possibility 1: getting the number of students with at least one degree with more than 80 per department
SELECT cls.DepartmentName, 
	   SUM(cls.gt80) AS students_80,
       COUNT(DISTINCT cls.StudentId) as total_students,
	   (SUM(cls.gt80)*1.0/COUNT(DISTINCT cls.StudentId)*100) AS students_80_pct
FROM (
SELECT DISTINCT c.DepartmentName,
       a.StudentId, 
       CASE WHEN (a.degree > 80) THEN (1) ELSE (0) END AS gt80
FROM Classrooms a
INNER JOIN Courses b
  ON a.CourseId = b.CourseId
INNER JOIN Departments c
  ON b.DepartmentId = c.DepartmentId
  --order by  a.StudentId,  c.DepartmentName
) AS cls
GROUP BY cls.DepartmentName

-- possibility 2: getting the number of students with mean degree higher than 80 per department
SELECT cls.DepartmentName, 
	   SUM(CASE WHEN (cls.deggree_avg > 80) THEN (1) ELSE (0) END) AS students_80,
       COUNT(DISTINCT cls.StudentId) as total_students,
	   (SUM(CASE WHEN (cls.deggree_avg > 80) THEN (1) ELSE (0) END)*1.0/COUNT(DISTINCT cls.StudentId)*100) AS students_80_pct
FROM (
SELECT c.DepartmentName,
       a.StudentId, 
       AVG(a.degree) AS deggree_avg
FROM Classrooms a
INNER JOIN Courses b
  ON a.CourseId = b.CourseId
INNER JOIN Departments c
  ON b.DepartmentId = c.DepartmentId
  --order by  a.StudentId,  c.DepartmentName
  GROUP BY c.DepartmentName,a.StudentId
) AS cls
GROUP BY cls.DepartmentName

---- 2g. How many students (n and %) have a degree lower than 60 by Department?
-- possibility 1: getting the number of students with at least one degree with less than 60 per department
SELECT cls.DepartmentName, 
	   SUM(cls.lt60) AS students_60,
       COUNT(DISTINCT StudentId) as total_students,
	   (SUM(cls.lt60)*1.0/COUNT(1)*100) AS students_60_pct
FROM (
SELECT DISTINCT c.DepartmentName,
       a.StudentId, 
       CASE WHEN (a.degree < 60) THEN (1) ELSE (0) END AS lt60
FROM Classrooms a
INNER JOIN Courses b
  ON a.CourseId = b.CourseId
INNER JOIN Departments c
  ON b.DepartmentId = c.DepartmentId
) AS cls
GROUP BY cls.DepartmentName


-- possibility 2: getting the number of students with mean degree higher than 80 per department
SELECT cls.DepartmentName, 
	   SUM(CASE WHEN (cls.deggree_avg < 60) THEN (1) ELSE (0) END) AS students_60,
       COUNT(DISTINCT cls.StudentId) as total_students,
	   (SUM(CASE WHEN (cls.deggree_avg < 60) THEN (1) ELSE (0) END)*1.0/COUNT(DISTINCT cls.StudentId)*100) AS students_60_pct
FROM (
SELECT c.DepartmentName,
       a.StudentId, 
       AVG(a.degree) AS deggree_avg
FROM Classrooms a
INNER JOIN Courses b
  ON a.CourseId = b.CourseId
INNER JOIN Departments c
  ON b.DepartmentId = c.DepartmentId
  --order by  a.StudentId,  c.DepartmentName
  GROUP BY c.DepartmentName,a.StudentId
) AS cls
GROUP BY cls.DepartmentName

---- 2h Rate in descending order the teachers by their student's mean degree.

SELECT  (FirstName + ' ' + LastName) AS Teacher,
	avg_degrees
FROM (
  SELECT c.FirstName, 
       c.LastName,
       AVG(a.degree) AS avg_degrees
  FROM Classrooms a
  INNER JOIN Courses b
    ON a.CourseId = b.CourseId
  INNER JOIN Teachers c
    ON b.TeacherId = c.TeacherId
  GROUP BY c.FirstName, 
       c.LastName
) AS cls
ORDER BY avg_degrees DESC

----- 3a. Create a view that shows the courses, departments, teachers and number 
-----   of students on each
-- DROP VIEW ClassrommList_v

CREATE VIEW ClassrommList_v AS 
SELECT a.CourseId, a.CourseName, b.DepartmentName, d.FirstName, d.LastName,
       COUNT(DISTINCT c.StudentId) AS num_students
FROM Courses a
LEFT OUTER JOIN Departments b
  ON a.DepartmentId = b.DepartmentId
LEFT OUTER JOIN Classrooms c
  ON a.CourseId = c.CourseId
LEFT OUTER JOIN Teachers d
  ON a.TeacherId = d.TeacherId
GROUP BY  a.CourseId, a.CourseName, b.DepartmentName, d.FirstName, d.LastName
;

SELECT * FROM ClassrommList_v

----- 3b. Create a view that shows each student, the number of courses taken, 
-----   their mean degree by department and the total degree mean.

CREATE VIEW StudentList_v 
--ALTER VIEW StudentList_v 
AS 
SELECT a.StudentId, a.FirstName, a.LastName, 
       COUNT(DISTINCT b.CourseId) as num_courses,
       AVG(CASE WHEN (c.DepartmentId = 1 ) THEN (b.degree) END) as English_degree,
       AVG(CASE WHEN (c.DepartmentId = 3 ) THEN (b.degree) END) as Arts_degree,
       AVG(CASE WHEN (c.DepartmentId = 2 ) THEN (b.degree) END) as Science_degree,
       AVG(CASE WHEN (c.DepartmentId = 4 ) THEN (b.degree) END) as Sports_degree,
       AVG(b.degree) as General_degree
FROM Students a
LEFT OUTER JOIN Classrooms b
  ON a.StudentId = b.StudentId
LEFT OUTER JOIN Courses c
  ON b.CourseId = c.CourseId
GROUP BY a.StudentId, a.FirstName, a.LastName
;

SELECT * FROM StudentList_v
select * from Departments
