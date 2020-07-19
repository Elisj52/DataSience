--2.A)

select count( [StudentId]) As Count_Student,
       d.[DepartmentId] As Department_Id,
	 d.[DepartmentName] As Department_Name
from [dbo].[Courses] c
inner join [dbo].[Departments] d on c.[DepartmentID] = d.[DepartmentId]
inner join [dbo].[Classrooms]cl on cl.[CourseId] = c.[CourseId]
group by d.[DepartmentId],d.[DepartmentName]


--2.B)


select count( [StudentId]) As Count_Student,
        	  c.[CourseName]
from [dbo].[Courses] c
inner join [dbo].[Departments] d on c.[DepartmentID] = d.[DepartmentId]
inner join [dbo].[Classrooms]cl on cl.[CourseId] = c.[CourseId]
Where [DepartmentName] = 'English'
group by c.[CourseName]
union all
select count( [StudentId]) As Count_Student,'Sum Student'
from [dbo].[Courses] c
inner join [dbo].[Departments] d on c.[DepartmentID] = d.[DepartmentId]
inner join [dbo].[Classrooms]cl on cl.[CourseId] = c.[CourseId]
Where [DepartmentName] = 'English'



--2.C)

select count(ClassType) ClassNumber,ClassType
from
(
select count(cl.[StudentId]) as a1,
       co.[CourseName],
	   case 
	      WHEN count(cl.[StudentId]) >= 22 THEN 'Big Class'
		    else 'Smal Class' 
        end as ClassType
from [dbo].[Classrooms] cl
inner join  [dbo].[Courses] co
on cl.[CourseId] = co.[CourseId]
where co.[DepartmentID] = 2
group by co.[CourseName]
) A
group by ClassType




--2.D) 

select count(*) As Count_Student,gender
from [dbo].[Students]
group by gender


--Answer : על פי תוצאת השאילתא מספר הסטודנטיות גדול ממספר הסטודנטים לכן הטענה של הפעילה הפמיניסטית אינה נכונה.


--2.E) 


select Cours_Name,(count_studet*1.0/all_student*1.0)*100.0 As studet_percent
from
(
  select count(*) As count_studet,
         [CourseId] As CourseId,
	  (select [CourseName] 
          from [dbo].[Courses] 
          where [dbo].[Courses].[CourseId] = c.[CourseId]) As Cours_Name,
         gender As gender, 
         (select count(*) 
          from [dbo].[Classrooms] 
          where [dbo].[Classrooms].[CourseId] = c.[CourseId]) as all_student
  from [dbo].[Classrooms] C
  inner join [dbo].[Students] S 
  on C.[StudentId] = S.[StudentId]
  group by [CourseId],gender 
) A
Where (count_studet*1.0/all_student*1.0)*100.0 > 70.0
order by CourseId



--2.F) 

select Student_number_great_80 ,
        DepartmentID,
       (select count(*) from [dbo].[Classrooms],[dbo].[Courses] where [dbo].[Classrooms].[CourseId] = [dbo].[Courses].[CourseId]  and [DepartmentID] = A.DepartmentID) As All_studet_department,
	   (select [DepartmentName] from [dbo].[Departments] where [DepartmentId] = A.[DepartmentID]) As Department_name
into Marks_Student_Over80
from
(
select  count(*) As Student_number_great_80,
        C.[DepartmentID] As DepartmentID
from [dbo].[Classrooms] cl
inner join [dbo].[Courses] C on cl.[CourseId] = C.[CourseId]
where [degree] > 80.0
group by C.[DepartmentID]
) A

select Department_name,Student_number_great_80,All_studet_department,(Student_number_great_80*1.0/All_studet_department*1.0) *100.0 As studet_percent from Marks_Student_Over80




--2.G)

select Student_number_under_60 ,
        DepartmentID,
       (select count(*) from [dbo].[Classrooms],[dbo].[Courses] where [dbo].[Classrooms].[CourseId] = [dbo].[Courses].[CourseId]  and [DepartmentID] = C.DepartmentID) As All_studet_department,
	   (select [DepartmentName] from [dbo].[Departments] where [DepartmentId] = c.[DepartmentID]) As Department_name
into Marks_Student_under60
from
(
select  count(*) As Student_number_under_60,
        C.[DepartmentID] As DepartmentID
from [dbo].[Classrooms] cl
inner join [dbo].[Courses] C on cl.[CourseId] = C.[CourseId]
where [degree] < 60.0
group by C.[DepartmentID]
) C

select Department_name,Student_number_under_60,All_studet_department,(Student_number_under_60*1.0/All_studet_department*1.0) *100.0 As studet_percent from Marks_Student_under60






--2.H)
select co.[TeacherId],
(select CONCAT([FirstName],[LastName]) as techer_name from [dbo].[Teachers] where [TeacherId] = co.[TeacherId])as Teachername,
avg([degree]) as avarage
 from [dbo].[Classrooms] cl
inner join [dbo].[Courses] co
on cl.[CourseId] = co.[CourseId]
group by [TeacherId]
order by 3 desc




--3.A)

CREATE  VIEW viewDepCourTea AS
select d.[DepartmentName],c. [CourseName],t.[FirstName],t.[LastName],
       (select count([StudentId]) from [dbo].[Classrooms] where [CourseId] = c.[CourseId] ) SudentCount
from [dbo].[Courses] c
inner join [dbo].[Departments] d
on c.[DepartmentID] = d.[DepartmentId]
inner join [dbo].[Teachers] t
on c.[TeacherId] = t.[TeacherId]

select * from viewDepCourTea

--3.B)

CREATE  VIEW viewStudentRemarks AS
select StudentId,
       FirstName,
	LastName,
	DepartmentName,
	(select count(*) from [dbo].[Classrooms] where [StudentId] = A.[StudentId]) as NumberOfCourse ,
	AVG(degree)  as Avg_per_Department,
      (select AVG(isnull(degree,0.0)*1.0)  from [dbo].[Classrooms] where [StudentId] = A.StudentId group by [StudentId]) as Avg_all_Course
from
(select s.[StudentId] as StudentId,
       s.[FirstName] as FirstName,
	   s.[LastName] as LastName,
	   C.[CourseId] as CourseId,
	   C.[degree] as degree,
       (select [DepartmentName] from [dbo].[Courses] inner join  [dbo].[Departments] on [dbo].[Courses].[DepartmentID] = [dbo].[Departments].[DepartmentID] and [dbo].[Courses].[CourseId] = C.[CourseId]) as DepartmentName 
from [dbo].[Students] s
left outer join [dbo].[Classrooms] C
on s.[StudentId] = C.[StudentId]
) A
group by StudentId,FirstName,LastName,DepartmentName

select * from viewStudentRemarks
