# Data Dictionary — Normalised Coaching Centre Database

**Project:** AVIRENZA Internship — Normalised Database Design for a Coaching Centre  
**Database engine:** MySQL (tested in DB Fiddle with MySQL v9)  
**Source of truth:** `sql/01-schema.sql`  
**Scope:** 10 tables, 39 columns.

## Notation

- **PK**: Primary Key. Each table has one integer auto-increment identifier.
- **FK**: Foreign Key. Referenced parent records must exist.
- **NN**: `NOT NULL`; **Nullable**: `NULL` permitted.
- **UQ**: `UNIQUE`, including composite (multi-column) constraints.
- **CHECK**: A row must satisfy the specified condition.
- Every foreign key in the schema uses **`ON DELETE RESTRICT`** to avoid deleting a referenced record while children exist.
- Column types and rules below describe the current implemented SQL, not hypothetical additional validation.

## 1. `parents`

Stores each parent or guardian once; a parent may be associated with multiple students.

| Column | MySQL type | Meaning | Constraints |
|---|---|---|---|
| `parent_id` | `INT` | Parent/guardian identifier | PK, NN, `AUTO_INCREMENT` |
| `parent_name` | `VARCHAR(100)` | Parent/guardian name | NN |
| `parent_phone` | `VARCHAR(20)` | Fictional phone placeholder | Nullable |

## 2. `students`

Stores student details and the linked guardian.

| Column | MySQL type | Meaning | Constraints |
|---|---|---|---|
| `student_id` | `INT` | Student identifier | PK, NN, `AUTO_INCREMENT` |
| `student_name` | `VARCHAR(100)` | Student name | NN |
| `student_phone` | `VARCHAR(20)` | Fictional student phone placeholder | Nullable |
| `parent_id` | `INT` | Guardian for this student | FK → `parents.parent_id`, NN, `ON DELETE RESTRICT` |

## 3. `batches`

Stores JEE/NEET study batches and one recurring day/time schedule per batch.

| Column | MySQL type | Meaning | Constraints |
|---|---|---|---|
| `batch_id` | `INT` | Batch identifier | PK, NN, `AUTO_INCREMENT` |
| `batch_name` | `VARCHAR(100)` | Unique batch label, e.g., JEE-A | NN, UQ |
| `exam_type` | `VARCHAR(10)` | Examination category | NN, CHECK `exam_type IN ('JEE', 'NEET')` |
| `schedule_day` | `VARCHAR(15)` | Scheduled weekday name | NN |
| `start_time` | `TIME` | Batch start time | NN |
| `end_time` | `TIME` | Batch end time | NN, CHECK `end_time > start_time` (constraint across start/end columns) |

## 4. `subjects`

Reference list of distinct subjects or teaching units.

| Column | MySQL type | Meaning | Constraints |
|---|---|---|---|
| `subject_id` | `INT` | Subject identifier | PK, NN, `AUTO_INCREMENT` |
| `subject_name` | `VARCHAR(100)` | Subject name | NN, UQ |

## 5. `faculty`

Stores teaching staff independently of their batch assignments.

| Column | MySQL type | Meaning | Constraints |
|---|---|---|---|
| `faculty_id` | `INT` | Teacher identifier | PK, NN, `AUTO_INCREMENT` |
| `faculty_name` | `VARCHAR(100)` | Faculty member name | NN |

## 6. `enrollments`

Junction table implementing the many-to-many relationship between students and batches.

| Column | MySQL type | Meaning | Constraints |
|---|---|---|---|
| `enrollment_id` | `INT` | Enrollment identifier | PK, NN, `AUTO_INCREMENT` |
| `student_id` | `INT` | Enrolled student | FK → `students.student_id`, NN, `ON DELETE RESTRICT` |
| `batch_id` | `INT` | Batch joined | FK → `batches.batch_id`, NN, `ON DELETE RESTRICT` |
| `enrollment_date` | `DATE` | Date of enrollment | NN |

**Table-level uniqueness:** `UNIQUE (student_id, batch_id)` prevents duplicate enrollment in the same batch.

## 7. `batch_subjects`

Junction table for subjects offered in each batch, with the assigned faculty member.

| Column | MySQL type | Meaning | Constraints |
|---|---|---|---|
| `batch_subject_id` | `INT` | Batch–subject offering identifier | PK, NN, `AUTO_INCREMENT` |
| `batch_id` | `INT` | Offering's batch | FK → `batches.batch_id`, NN, `ON DELETE RESTRICT` |
| `subject_id` | `INT` | Offered subject | FK → `subjects.subject_id`, NN, `ON DELETE RESTRICT` |
| `faculty_id` | `INT` | Assigned teacher | FK → `faculty.faculty_id`, NN, `ON DELETE RESTRICT` |

**Table-level uniqueness:** `UNIQUE (batch_id, subject_id)` means one faculty assignment per batch/subject combination in this model.

## 8. `fee_installments`

Records separate numbered fees for each enrollment. A missing payment date denotes an installment with no recorded payment yet.

| Column | MySQL type | Meaning | Constraints |
|---|---|---|---|
| `installment_id` | `INT` | Installment identifier | PK, NN, `AUTO_INCREMENT` |
| `enrollment_id` | `INT` | Enrollment charged | FK → `enrollments.enrollment_id`, NN, `ON DELETE RESTRICT` |
| `installment_no` | `INT` | Number of installment within an enrollment | NN, CHECK `installment_no > 0` |
| `amount` | `DECIMAL(10,2)` | Installment amount | NN, CHECK `amount > 0` |
| `payment_date` | `DATE` | Recorded payment date | Nullable |

**Table-level uniqueness:** `UNIQUE (enrollment_id, installment_no)` prevents duplicate numbered installments within one enrollment.

## 9. `tests`

Stores an examination or quiz for a specific subject in a specific batch.

| Column | MySQL type | Meaning | Constraints |
|---|---|---|---|
| `test_id` | `INT` | Test identifier | PK, NN, `AUTO_INCREMENT` |
| `batch_subject_id` | `INT` | Subject offering tested | FK → `batch_subjects.batch_subject_id`, NN, `ON DELETE RESTRICT` |
| `test_name` | `VARCHAR(100)` | Name of quiz or examination | NN |
| `test_date` | `DATE` | Date administered | NN |
| `max_marks` | `INT` | Maximum achievable score | NN, CHECK `max_marks > 0` |

## 10. `test_results`

Connects each enrollment to a particular test, including the obtained marks.

| Column | MySQL type | Meaning | Constraints |
|---|---|---|---|
| `result_id` | `INT` | Recorded result identifier | PK, NN, `AUTO_INCREMENT` |
| `test_id` | `INT` | Test taken | FK → `tests.test_id`, NN, `ON DELETE RESTRICT` |
| `enrollment_id` | `INT` | Enrollment of the student | FK → `enrollments.enrollment_id`, NN, `ON DELETE RESTRICT` |
| `marks` | `DECIMAL(6,2)` | Marks earned | NN, CHECK `marks >= 0` |

**Table-level uniqueness:** `UNIQUE (test_id, enrollment_id)` ensures no more than one result for the same test and enrollment.

## Relationship summary

| Parent → child | Cardinality in this design | Foreign key |
|---|---|---|
| `parents` → `students` | One-to-many | `students.parent_id` |
| `students` → `enrollments` | One-to-many | `enrollments.student_id` |
| `batches` → `enrollments` | One-to-many | `enrollments.batch_id` |
| `batches` → `batch_subjects` | One-to-many | `batch_subjects.batch_id` |
| `subjects` → `batch_subjects` | One-to-many | `batch_subjects.subject_id` |
| `faculty` → `batch_subjects` | One-to-many | `batch_subjects.faculty_id` |
| `enrollments` → `fee_installments` | One-to-many | `fee_installments.enrollment_id` |
| `batch_subjects` → `tests` | One-to-many | `tests.batch_subject_id` |
| `tests` → `test_results` | One-to-many | `test_results.test_id` |
| `enrollments` → `test_results` | One-to-many | `test_results.enrollment_id` |

The many-to-many **student–batch** relationship is implemented via `enrollments`; the many-to-many **batch–subject** relationship is implemented via `batch_subjects`.

## Constraint inventory

- 10 primary keys (one per table).
- 10 foreign key constraints.
- 6 unique constraints (batch name, subject name, and four composite constraints).
- 6 CHECK constraints: exam type, batch schedule time, installment number, amount, max marks, nonnegative marks.
- Required columns use `NOT NULL`; optional phone numbers and payment date permit `NULL`.

## Integrity limitations / future validation

Two `BEFORE INSERT` / `BEFORE UPDATE` triggers on `test_results` check that:

1. `test_results.marks <= tests.max_marks`.
2. The result's enrollment belongs to the same batch as its test.

These triggers were tested in DB Fiddle (MySQL v9). To avoid multi-statement delimiter issues in the online editor, the triggers deliberately rewrite invalid values to violate existing `CHECK` and `NOT NULL` constraints. This rejects invalid direct inserts/updates but produces generic errors rather than custom `SIGNAL` messages.

**Known limitation:** A later edit to `tests.max_marks`, `enrollments.batch_id` or `batch_subjects.batch_id` may invalidate previously recorded results without activating the `test_results` triggers. A more comprehensive production design needs protective triggers on those tables or an alternative relational model. The data-quality query in `sql/03-constraint-checks.sql` detects such rows.

**Design scope:** One day/time pair per batch, rather than a full multi-session calendar; phone values are placeholders; no actual identities or phone numbers are required.
