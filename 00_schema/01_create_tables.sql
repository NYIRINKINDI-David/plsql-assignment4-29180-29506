-- 01_create_tables.sql : Student Registration and Grading schema
-- Tables, relationships, constraints, sequence and collection types.

CREATE TABLE students (
  student_id     NUMBER(6)     CONSTRAINT pk_students PRIMARY KEY,
  first_name     VARCHAR2(50)  NOT NULL,
  last_name      VARCHAR2(50)  NOT NULL,
  email          VARCHAR2(100) NOT NULL CONSTRAINT uq_students_email UNIQUE,
  status         VARCHAR2(10)  DEFAULT 'ACTIVE' NOT NULL
                 CONSTRAINT ck_students_status CHECK (status IN ('ACTIVE','INACTIVE')),
  registered_on  DATE          DEFAULT SYSDATE NOT NULL
);

CREATE TABLE courses (
  course_id     NUMBER(4)     CONSTRAINT pk_courses PRIMARY KEY,
  course_code   VARCHAR2(15)  NOT NULL CONSTRAINT uq_courses_code UNIQUE,
  title         VARCHAR2(100) NOT NULL,
  credits       NUMBER(1)     NOT NULL CONSTRAINT ck_courses_credits CHECK (credits BETWEEN 1 AND 6),
  max_capacity  NUMBER(3)     NOT NULL CONSTRAINT ck_courses_capacity CHECK (max_capacity > 0)
);

CREATE SEQUENCE enrollment_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE enrollments (
  enrollment_id NUMBER(8)    CONSTRAINT pk_enrollments PRIMARY KEY,
  student_id    NUMBER(6)    NOT NULL CONSTRAINT fk_enr_student REFERENCES students(student_id),
  course_id     NUMBER(4)    NOT NULL CONSTRAINT fk_enr_course  REFERENCES courses(course_id),
  enroll_date   DATE         DEFAULT SYSDATE NOT NULL,
  status        VARCHAR2(10) DEFAULT 'ENROLLED' NOT NULL
                CONSTRAINT ck_enr_status CHECK (status IN ('ENROLLED','COMPLETED','DROPPED')),
  grade         NUMBER(5,2)  CONSTRAINT ck_enr_grade CHECK (grade BETWEEN 0 AND 100),
  CONSTRAINT uq_enr_student_course UNIQUE (student_id, course_id)
);
CREATE INDEX idx_enr_course ON enrollments(course_id);

CREATE TABLE grade_audit (
  audit_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  enrollment_id NUMBER(8) NOT NULL
                CONSTRAINT fk_audit_enr REFERENCES enrollments(enrollment_id) ON DELETE CASCADE,
  old_grade     NUMBER(5,2),
  new_grade     NUMBER(5,2),
  changed_on    DATE DEFAULT SYSDATE NOT NULL
);

CREATE TABLE error_log (
  log_id        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  source_name   VARCHAR2(60)   NOT NULL,
  error_code    NUMBER,
  error_message VARCHAR2(4000),
  logged_on     TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

-- Scratch table used only by performance_compare
CREATE TABLE perf_test (
  id     NUMBER PRIMARY KEY,
  val    VARCHAR2(50),
  amount NUMBER
);

-- Collection types (schema level so they can be used as procedure parameters / in SQL)
CREATE OR REPLACE TYPE t_id_list AS TABLE OF NUMBER;
/
CREATE OR REPLACE TYPE t_student_gpa_obj AS OBJECT (
  student_id NUMBER,
  full_name  VARCHAR2(100),
  gpa        NUMBER
);
/
CREATE OR REPLACE TYPE t_top_students AS VARRAY(10) OF t_student_gpa_obj;
/

PROMPT --- Tables created:
SELECT table_name FROM user_tables ORDER BY table_name;
