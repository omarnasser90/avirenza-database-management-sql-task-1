-- AVIRENZA Coaching Centre - Task 1
-- MySQL 8.0.16 or newer (CHECK constraints are enforced)
-- Run this script against a fresh schema / database.
-- DB Fiddle: paste this entire file into the Schema SQL panel.

CREATE TABLE parents (
    parent_id INT AUTO_INCREMENT,
    parent_name VARCHAR(100) NOT NULL,
    parent_phone VARCHAR(20),
    CONSTRAINT parents_pk PRIMARY KEY (parent_id)
);

CREATE TABLE students (
    student_id INT AUTO_INCREMENT,
    student_name VARCHAR(100) NOT NULL,
    student_phone VARCHAR(20),
    parent_id INT NOT NULL,
    CONSTRAINT students_pk PRIMARY KEY (student_id),
    CONSTRAINT students_parent_fk FOREIGN KEY (parent_id)
        REFERENCES parents(parent_id) ON DELETE RESTRICT
);

CREATE TABLE batches (
    batch_id INT AUTO_INCREMENT,
    batch_name VARCHAR(100) NOT NULL UNIQUE,
    exam_type VARCHAR(10) NOT NULL,
    schedule_day VARCHAR(15) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    CONSTRAINT batches_pk PRIMARY KEY (batch_id),
    CONSTRAINT check_exam_type CHECK (exam_type IN ('JEE', 'NEET')),
    CONSTRAINT check_batch_time CHECK (end_time > start_time)
);

CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT,
    subject_name VARCHAR(100) NOT NULL,
    CONSTRAINT subjects_pk PRIMARY KEY (subject_id),
    CONSTRAINT subjects_name_unique UNIQUE (subject_name)
);

CREATE TABLE faculty (
    faculty_id INT AUTO_INCREMENT,
    faculty_name VARCHAR(100) NOT NULL,
    CONSTRAINT faculty_pk PRIMARY KEY (faculty_id)
);

CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT,
    student_id INT NOT NULL,
    batch_id INT NOT NULL,
    enrollment_date DATE NOT NULL,
    CONSTRAINT enrollments_pk PRIMARY KEY (enrollment_id),
    CONSTRAINT enrollments_student_fk FOREIGN KEY (student_id)
        REFERENCES students(student_id) ON DELETE RESTRICT,
    CONSTRAINT enrollments_batch_fk FOREIGN KEY (batch_id)
        REFERENCES batches(batch_id) ON DELETE RESTRICT,
    CONSTRAINT unique_student_batch UNIQUE (student_id, batch_id)
);

CREATE TABLE batch_subjects (
    batch_subject_id INT AUTO_INCREMENT,
    batch_id INT NOT NULL,
    subject_id INT NOT NULL,
    faculty_id INT NOT NULL,
    CONSTRAINT batch_subjects_pk PRIMARY KEY (batch_subject_id),
    CONSTRAINT bs_batch_fk FOREIGN KEY (batch_id)
        REFERENCES batches(batch_id) ON DELETE RESTRICT,
    CONSTRAINT bs_subject_fk FOREIGN KEY (subject_id)
        REFERENCES subjects(subject_id) ON DELETE RESTRICT,
    CONSTRAINT bs_faculty_fk FOREIGN KEY (faculty_id)
        REFERENCES faculty(faculty_id) ON DELETE RESTRICT,
    CONSTRAINT unique_batch_subject UNIQUE (batch_id, subject_id)
);

CREATE TABLE fee_installments (
    installment_id INT AUTO_INCREMENT,
    enrollment_id INT NOT NULL,
    installment_no INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATE,
    CONSTRAINT fee_installments_pk PRIMARY KEY (installment_id),
    CONSTRAINT fees_enrollment_fk FOREIGN KEY (enrollment_id)
        REFERENCES enrollments(enrollment_id) ON DELETE RESTRICT,
    CONSTRAINT check_fee_amount CHECK (amount > 0),
    CONSTRAINT check_installment_no CHECK (installment_no > 0),
    CONSTRAINT unique_enrollment_installment UNIQUE (enrollment_id, installment_no)
);

CREATE TABLE tests (
    test_id INT AUTO_INCREMENT,
    batch_subject_id INT NOT NULL,
    test_name VARCHAR(100) NOT NULL,
    test_date DATE NOT NULL,
    max_marks INT NOT NULL,
    CONSTRAINT tests_pk PRIMARY KEY (test_id),
    CONSTRAINT tests_batch_subject_fk FOREIGN KEY (batch_subject_id)
        REFERENCES batch_subjects(batch_subject_id) ON DELETE RESTRICT,
    CONSTRAINT check_max_marks CHECK (max_marks > 0)
);

CREATE TABLE test_results (
    result_id INT AUTO_INCREMENT,
    test_id INT NOT NULL,
    enrollment_id INT NOT NULL,
    marks DECIMAL(6,2) NOT NULL,
    CONSTRAINT test_results_pk PRIMARY KEY (result_id),
    CONSTRAINT results_test_fk FOREIGN KEY (test_id)
        REFERENCES tests(test_id) ON DELETE RESTRICT,
    CONSTRAINT results_enrollment_fk FOREIGN KEY (enrollment_id)
        REFERENCES enrollments(enrollment_id) ON DELETE RESTRICT,
    CONSTRAINT check_marks CHECK (marks >= 0),
    CONSTRAINT unique_test_enrollment UNIQUE (test_id, enrollment_id)
);

-- Database-level cross-table validation for result writes.
-- Single-statement triggers are used for DB Fiddle compatibility (no DELIMITER).
-- They turn an invalid value into a violation of an existing constraint.
-- These were tested with MySQL v9 in DB Fiddle (see trigger-errors.png).
-- LIMITATION: changes to tests.max_marks, enrollments.batch_id, or
-- batch_subjects.batch_id can invalidate results already recorded;
-- that would require additional triggers or a revised schema.

CREATE TRIGGER validate_result_insert
BEFORE INSERT ON test_results
FOR EACH ROW
SET
    NEW.marks = IF(
        NEW.marks > (
            SELECT max_marks FROM tests WHERE test_id = NEW.test_id
        ),
        -1,
        NEW.marks
    ),
    NEW.enrollment_id = IF(
        (SELECT batch_id FROM enrollments
         WHERE enrollment_id = NEW.enrollment_id) <>
        (SELECT bs.batch_id FROM tests t
         JOIN batch_subjects bs
           ON bs.batch_subject_id = t.batch_subject_id
         WHERE t.test_id = NEW.test_id),
        NULL,
        NEW.enrollment_id
    );

CREATE TRIGGER validate_result_update
BEFORE UPDATE ON test_results
FOR EACH ROW
SET
    NEW.marks = IF(
        NEW.marks > (
            SELECT max_marks FROM tests WHERE test_id = NEW.test_id
        ),
        -1,
        NEW.marks
    ),
    NEW.enrollment_id = IF(
        (SELECT batch_id FROM enrollments
         WHERE enrollment_id = NEW.enrollment_id) <>
        (SELECT bs.batch_id FROM tests t
         JOIN batch_subjects bs
           ON bs.batch_subject_id = t.batch_subject_id
         WHERE t.test_id = NEW.test_id),
        NULL,
        NEW.enrollment_id
    );
