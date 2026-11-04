-- 02_insert_sample_data.sql
-- NOTE: two students share the last name 'Mukamana' on purpose (TOO_MANY_ROWS test).
-- NOTE: course 5 has capacity 3 and 3 enrolled students on purpose (course-full test).

INSERT INTO students (student_id, first_name, last_name, email, status) VALUES (101,'Jean','Habimana','jean.habimana@auca.ac.rw','ACTIVE');
INSERT INTO students (student_id, first_name, last_name, email, status) VALUES (102,'Alice','Uwase','alice.uwase@auca.ac.rw','ACTIVE');
INSERT INTO students (student_id, first_name, last_name, email, status) VALUES (103,'Eric','Mukamana','eric.mukamana@auca.ac.rw','ACTIVE');
INSERT INTO students (student_id, first_name, last_name, email, status) VALUES (104,'Grace','Niyonsenga','grace.niyonsenga@auca.ac.rw','ACTIVE');
INSERT INTO students (student_id, first_name, last_name, email, status) VALUES (105,'Patrick','Nshuti','patrick.nshuti@auca.ac.rw','ACTIVE');
INSERT INTO students (student_id, first_name, last_name, email, status) VALUES (106,'Diane','Ingabire','diane.ingabire@auca.ac.rw','ACTIVE');
INSERT INTO students (student_id, first_name, last_name, email, status) VALUES (107,'Samuel','Kagabo','samuel.kagabo@auca.ac.rw','ACTIVE');
INSERT INTO students (student_id, first_name, last_name, email, status) VALUES (108,'Claudine','Mukamana','claudine.mukamana@auca.ac.rw','ACTIVE');
INSERT INTO students (student_id, first_name, last_name, email, status) VALUES (109,'David','Mugisha','david.mugisha@auca.ac.rw','ACTIVE');
INSERT INTO students (student_id, first_name, last_name, email, status) VALUES (110,'Olivier','Rurangwa','olivier.rurangwa@auca.ac.rw','INACTIVE');

INSERT INTO courses VALUES (1,'INSY8311','Database Development with PL/SQL',3,30);
INSERT INTO courses VALUES (2,'INSY8201','Systems Analysis and Design',3,30);
INSERT INTO courses VALUES (3,'CSC8101','Data Structures',4,25);
INSERT INTO courses VALUES (4,'MATH8101','Discrete Mathematics',3,25);
INSERT INTO courses VALUES (5,'SEM8001','Research Seminar',1,3);

-- (student, course, status, grade)
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,101,1,'COMPLETED',92);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,101,2,'COMPLETED',85);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,101,3,'COMPLETED',78);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,102,1,'COMPLETED',74);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,102,2,'COMPLETED',66);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,102,4,'COMPLETED',81);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,103,1,'ENROLLED',88);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,103,3,'ENROLLED',91);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,103,4,'ENROLLED',NULL);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,104,1,'COMPLETED',55);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,104,2,'COMPLETED',62);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,104,3,'COMPLETED',70);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,105,1,'ENROLLED',79);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,105,2,'ENROLLED',83);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,105,3,'DROPPED',NULL);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,106,1,'COMPLETED',95);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,106,3,'COMPLETED',89);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,106,4,'COMPLETED',93);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,107,1,'ENROLLED',NULL);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,107,2,'ENROLLED',70);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,108,1,'ENROLLED',61);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,108,4,'ENROLLED',58);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,109,2,'COMPLETED',90);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,109,3,'COMPLETED',84);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,110,1,'DROPPED',NULL);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,110,2,'DROPPED',NULL);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,101,5,'ENROLLED',NULL);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,102,5,'ENROLLED',NULL);
INSERT INTO enrollments (enrollment_id, student_id, course_id, status, grade) VALUES (enrollment_seq.NEXTVAL,106,5,'ENROLLED',NULL);

COMMIT;

PROMPT --- Row counts:
SELECT 'STUDENTS' AS tbl, COUNT(*) AS rows_count FROM students
UNION ALL SELECT 'COURSES', COUNT(*) FROM courses
UNION ALL SELECT 'ENROLLMENTS', COUNT(*) FROM enrollments;
