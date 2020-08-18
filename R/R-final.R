#R Intro - Final Exercise


library(DBI)
library(dplyr)
### In windows, Using a ODBC DNS (predefined connection name)
### Some possible strings for the driver:
### the DSN must be the same as you created in the ODBC (check it!)
#driver <- "Driver={SQL Server};DSN=COLLEGE;Trusted_Connection=yes;"

#driver <- "Driver={SQL Server Native Connection 11.0};DSN=COLLEGE;Trusted_Connection=True;"

### XXXXX\\XXXXX is the name of the server as it appears in the SQL server management studio
### COLLEGE is the name of the database (check how do you called it in your local server)
#driver <- "Driver={SQL Server Native Connection 11.0};Server=XXXXX\\XXXXX;Database=COLLEGE;Trusted_Connection=True;"


### Try with the diferent driver strings to see what works for you
#conn <- dbConnect(odbc::odbc, .connection_string = driver)
conn <- DBI::dbConnect(odbc::odbc(), 
                      Driver = "SQL Server", 
                      Server = "localhost\\SQLEXPRESS", 
                      Database = "COLLEGE", 
                      Trusted_Connection = "True")

### Get the students table
#students = dbQuery(conn, "SELECT * FROM Students")
dbListTables(conn)

dfTeachers <- dbReadTable(conn, "Teachers")
dfClassrooms <- dbReadTable(conn, "Classrooms")
dfCourses <- dbReadTable(conn, "Courses")
dfDepartments <- dbReadTable(conn, "Departments")
dfStudents <- dbReadTable(conn, "Students")

dbDisconnect(conn)

 
#Questions


#Q1. Count the number of students on each department
df_Cl_Co_Q1 <- inner_join(dfClassrooms,dfCourses,by="CourseId")
df_Cl_Co_De_Q1 <- inner_join(df_Cl_Co_Q1,dfDepartments,by=c("DepartmentID" = "DepartmentId"))
resultQ1 <- df_Cl_Co_De_Q1  %>%
           group_by(DepartmentName) %>% 
           summarise(Unique_Elements = n_distinct(StudentId)) 
print(resultQ1)



#Q2. How many students have each course of the English department and the total number of students in the department?

df_Englihs <- df_Cl_Co_De_Q1 %>% filter(DepartmentName =="English")
resultQ2 <- df_Englihs  %>%
            group_by(CourseName) %>% 
            summarise(StudentCount = n_distinct(StudentId)) 
dfTotalCount <- df_Englihs  %>% summarise(count = n_distinct(StudentId))
dfTotalCount <- cbind(c("TotalStudents"),dfTotalCount)
names(dfTotalCount)[1] <- "CourseName"
names(dfTotalCount)[2] <- "StudentCount"
resultQ2 <- rbind(resultQ2, dfTotalCount)
print(resultQ2)


#Q3. How many small (<22 students) and large (22+ students) classrooms are needed for the Science department?

df_Cl_Co_Q3 <- inner_join(dfClassrooms,dfCourses,by="CourseId")
df_Cl_Co_Q3 <- df_Cl_Co_Q3  %>% 
               filter(DepartmentID == 2) %>% 
               group_by(CourseId) %>% 
               summarise(TotalStudentClass = n_distinct(StudentId))

dfBigClass <- df_Cl_Co_Q3  %>% 
              filter(TotalStudentClass >= 22) %>% 
              summarise(CountClass = n())
             
dfBigClass <- dfBigClass %>%  
              mutate(classType = "Big Class")  %>%  
              select(classType,CountClass)


dfSmallClass <- df_Cl_Co_Q3  %>% 
                filter(TotalStudentClass < 22) %>% 
                summarise(CountClass = n())

dfSmallClass <- dfSmallClass %>%  
                mutate(classType = "Small Class")  %>%  
                select(classType,CountClass)


result3 <- rbind(dfBigClass, dfSmallClass)
print(result3)



#Q4. A feminist student claims that there are more male than female in the College. Justify if the argument is correct

resultQ4 <- dfStudents  %>%
  group_by(Gender) %>% 
  summarise(StudentCount = n_distinct(StudentId)) 
print(resultQ4)

#Q5. For which courses the percentage of male/female students is over 70%?

df_Cl_Co_Q5 <- left_join(dfClassrooms,dfStudents,by="StudentId")
df_Cl_Co_St_Q5 <- left_join(df_Cl_Co_Q5,dfCourses,by="CourseId")
dfTotalStudentCoures <- dfClassrooms  %>%
                        group_by(CourseId) %>% 
                        summarise(TotalStudentCount = n()) 

resultQ5 <- df_Cl_Co_St_Q5 %>%
            group_by(CourseId,CourseName,Gender) %>% 
            summarise(StudentCount = n()) 

resultQ5 <- inner_join(resultQ5,dfTotalStudentCoures ,by="CourseId")
#colnames(resultQ5)
resultQ5 <- resultQ5 %>% 
                     mutate(studentsPercent = (StudentCount*1.0/TotalStudentCount*1.0)*100.0) %>%
                     filter(studentsPercent > 70.0) %>%
                     select(CourseId ,CourseName,Gender,studentsPercent)

print(resultQ5)

#Q6. For each department, how many students passed with a grades over 80?

df_Cl_Co_Q6 <- inner_join(dfClassrooms,dfCourses,by="CourseId")
df_Cl_Co_De_Q6 <- inner_join(df_Cl_Co_Q6,dfDepartments,by=c("DepartmentID" = "DepartmentId"))
result6 <- df_Cl_Co_De_Q6 %>%
            filter(degree > 80.0) %>%
            group_by(DepartmentName) %>% 
            summarise(StudentCount80 = n_distinct(StudentId)) 

dfTotalStudent80 <- df_Cl_Co_De_Q6  %>% 
                  group_by(DepartmentName) %>% 
                  summarise(TotalStudent = n_distinct(StudentId))            
result6 <- inner_join(result6,dfTotalStudent80,by="DepartmentName")
result6 <- result6 %>%
            mutate(students_80_pct = (StudentCount80 *1.0/TotalStudent*1.0)*100.0)
print(result6)


#Q7. For each department, how many students passed with a grades under 60?

df_Cl_Co_Q7 <- inner_join(dfClassrooms,dfCourses,by="CourseId")
df_Cl_Co_De_Q7 <- inner_join(df_Cl_Co_Q7,dfDepartments,by=c("DepartmentID" = "DepartmentId"))
result7 <- df_Cl_Co_De_Q7 %>%
  filter(degree < 60.0) %>%
  group_by(DepartmentName) %>% 
  summarise(StudentCount60 = n_distinct(StudentId)) 

dfTotalStudent60 <- df_Cl_Co_De_Q7  %>% 
  group_by(DepartmentName) %>% 
  summarise(TotalStudent = n_distinct(StudentId))            
result7 <- inner_join(result7,dfTotalStudent,by="DepartmentName")
result7 <- result7 %>%
  mutate(students_60_pct = (StudentCount60 *1.0/TotalStudent*1.0)*100.0)
print(result7)






#Q8. Rate the teachers by their average student's grades (in descending order).

df_Cl_Co_Q8 <- inner_join(dfClassrooms,dfCourses,by="CourseId")
df_Cl_Co_Te_Q8 <- inner_join(df_Cl_Co_Q8,dfTeachers,by=c("TeacherId" = "TeacherId"))
df_Cl_Co_Te_Q8$TeacherName = paste(df_Cl_Co_Te_Q8$FirstName,df_Cl_Co_Te_Q8$LastName) 
#colnames(df_Cl_Co_Te_Q8)
result8 <- df_Cl_Co_Te_Q8 %>%
           group_by(TeacherName) %>% 
           summarise(avg_degrees = mean(degree,na.rm=TRUE))
result8 <- result8 %>% 
           arrange(desc(avg_degrees))
result8 <- result8 %>% 
           select(TeacherName,avg_degrees)
print(result8)



#Q9. Create a dataframe showing the courses, departments they are associated with, the teacher in each course, and the number of students enrolled in the course (for each course, department and teacher show the names).

df_Cl_Co_Q9 <- left_join(dfCourses,dfDepartments ,by=c("DepartmentID" = "DepartmentId"))
df_Cl_Co_Q9 <- left_join(df_Cl_Co_Q9,dfClassrooms ,by=c("CourseId" = "CourseId"))
df_Cl_Co_Q9 <- left_join(df_Cl_Co_Q9,dfTeachers ,by=c("TeacherId" = "TeacherId"))
result9 <- df_Cl_Co_Q9 %>%
           group_by(CourseId, CourseName, DepartmentName, FirstName, LastName) %>%
           summarise(TotalStudent = n_distinct(StudentId,na.rm=TRUE))
print(result9)


#Q10. Create a dataframe showing the students, the number of courses they take, the average of the grades per class, and their overall average (for each student show the student name).

df_Cl_Co_Q10 <- left_join(dfStudents,dfClassrooms ,by=c("StudentId" = "StudentId"))
df_Cl_Co_Q10 <- left_join(df_Cl_Co_Q10,dfCourses ,by=c("CourseId" = "CourseId"))
colnames(df_Cl_Co_Q10)
df_avg_DepartmentId1 <- df_Cl_Co_Q10 %>%
                        filter(DepartmentID == 1)  %>%
                        group_by(StudentId) %>%
                        summarise(English_degree = mean(degree,na.rm=TRUE))
df_avg_DepartmentId2 <- df_Cl_Co_Q10 %>%
                        filter(DepartmentID == 2)  %>%
                        group_by(StudentId) %>%
                        summarise(Science_degree = mean(degree,na.rm=TRUE))
df_avg_DepartmentId3 <- df_Cl_Co_Q10 %>%
                        filter(DepartmentID == 3)  %>%
                        group_by(StudentId) %>%
                         summarise(Arts_degree = mean(degree,na.rm=TRUE))
df_avg_DepartmentId4 <- df_Cl_Co_Q10 %>%
                        filter(DepartmentID == 4)  %>%
                        group_by(StudentId) %>%
                        summarise(Sport_degree = mean(degree,na.rm=TRUE))
df_avg_General <- df_Cl_Co_Q10 %>%
                  group_by(StudentId) %>%
                  summarise(General_degree = mean(degree,na.rm=TRUE))

result10 <- df_Cl_Co_Q10 %>%
            group_by(StudentId, FirstName, LastName) %>%
             summarise(TotalCourse = n_distinct(CourseId,na.rm=TRUE))
result10 <- left_join(result10,df_avg_DepartmentId1, by = "StudentId")
result10 <- left_join(result10,df_avg_DepartmentId2, by = "StudentId")
result10 <- left_join(result10,df_avg_DepartmentId3, by = "StudentId")
result10 <- left_join(result10,df_avg_DepartmentId4, by = "StudentId")
result10 <- left_join(result10,df_avg_General, by = "StudentId")
