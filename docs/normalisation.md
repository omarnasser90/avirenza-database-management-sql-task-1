# Normalisation Walkthrough — Coaching Centre Database

## 1. Objective and starting point

A fictional coaching centre prepares students for JEE and NEET examinations. Its original spreadsheet combines student and parent details, batches, subjects, assigned faculty, fee instalments and test marks. This creates duplicate values and update, insertion and deletion anomalies.

**Simplifying assumptions for this worked example:** One student can enrol in multiple batches; each test is associated with one subject in one batch; a student enrolment has numbered fee instalments; and each student enrolment has no more than one result for a particular test. These assumptions match the accompanying business rules.

## 2. Unnormalised form (UNF / 0NF)

The following single spreadsheet row contains lists inside cells. These are **illustrative fictional values**, not real personal data.

| Student ID | Student | Phone placeholder | Parent | Batch | Subjects and faculty | Fee instalments | Test results |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Ahmed | 000-STUDENT-01 | Mahmoud | JEE-A (batch 10) | Mathematics — Mr Ali; Physics — Ms Sara | #1: 500; #2: 700 | Math Test 501: 80; Physics Test 502: 90 |

**Problem:** Cells hold multiple subject/teacher pairs, payment instalments and marks. Different facts are bundled into one record, making searching and updating unreliable.

## 3. First normal form (1NF)

**Rule:** Each column holds one value per row; repeated groups and lists in cells are removed. Rows should be uniquely identifiable.

An illustrative 1NF expansion follows. The student name, phone, parent, batch name and faculty shown in the original row are still stored as ordinary atomic columns and are therefore repeated; some are omitted from the displayed columns here to keep the table readable.

| student_id | batch_id | subject_id | subject_name | faculty_name | installment_no | amount | test_id | marks |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 10 | 101 | Mathematics | Mr Ali | 1 | 500 | 501 | 80 |
| 1 | 10 | 101 | Mathematics | Mr Ali | 2 | 700 | 501 | 80 |
| 1 | 10 | 102 | Physics | Ms Sara | 1 | 500 | 502 | 90 |
| 1 | 10 | 102 | Physics | Ms Sara | 2 | 700 | 502 | 90 |

For this simplified flattened dataset, `(student_id, test_id, installment_no)` distinguishes rows. A database may also introduce a separate technical row identifier, but that does **not** remove the dependencies illustrated below.

**What 1NF fixes:** A cell no longer contains a comma-separated list of subjects, payments or marks. Values can be queried individually.

**What remains:** Both instalments are repeated once for each test and vice versa; changing Ahmed's name, the faculty name or an amount would require updates in multiple rows. Thus 1NF alone does **not** remove data duplication or update anomalies.

## 4. Second normal form (2NF)

**Rule:** The table must be in 1NF, and every non-key attribute must depend on the **whole** candidate key, not on just part of a composite candidate key.

In the 1NF example, the following are partial dependencies on `(student_id, test_id, installment_no)`:

- `student_id → student_name, student_phone, parent_id, parent_name, parent_phone`
- `test_id → test_name, test_date, max_marks, batch_id, subject_id`
- `(student_id, test_id) → marks` (one mark for a student and a test)
- `(student_id, test_id, installment_no) → amount` in the flattened view, but in the real business domain an instalment belongs to a **student–batch enrolment** and is identified by its enrolment and number, independently of a test.

Separate the independent concepts to stop storing student, test and fee facts together. A possible **intermediate 2NF** decomposition is:

| Intermediate table | Columns (primary key indicated by `PK`) |
| --- | --- |
| `students_2nf` | `student_id PK`, `student_name`, `student_phone`, `parent_id`, `parent_name`, `parent_phone` |
| `batches_2nf` | `batch_id PK`, `batch_name`, `exam_type`, `schedule_day`, `start_time`, `end_time` |
| `subjects_2nf` | `subject_id PK`, `subject_name` |
| `batch_subjects_2nf` | `(batch_id, subject_id) PK`, `faculty_id`, `faculty_name` |
| `enrollments_2nf` | `enrollment_id PK`, `student_id`, `batch_id`, `enrollment_date`; unique (`student_id`, `batch_id`) |
| `fee_installments_2nf` | `installment_id PK`, `enrollment_id`, `installment_no`, `amount`, `payment_date`; unique (`enrollment_id`, `installment_no`) |
| `tests_2nf` | `test_id PK`, `batch_id`, `subject_id`, `test_name`, `test_date`, `max_marks` |
| `test_results_2nf` | `result_id PK`, `test_id`, `enrollment_id`, `marks`; unique (`test_id`, `enrollment_id`) |

`students_2nf` still repeats parent information for siblings; `batch_subjects_2nf` still repeats a faculty member's name for each class they teach. These remaining transitive dependencies are intentional here, to illustrate the difference between 2NF and 3NF.

**What 2NF fixes:** A test result is no longer copied into every instalment row, nor is an instalment copied for every test. Student and test facts are not stored on unrelated composite-key rows.

**What remains:** Parent and faculty descriptive details can still be duplicated across records.

## 5. Third normal form (3NF)

**Rule:** The table must be in 2NF. Non-key attributes should not depend transitively on a key via another non-key attribute (more formally, for each nontrivial functional dependency X → A, X is a superkey or A is a prime attribute).

Examples of transitive dependencies in the intermediate design:

- `student_id → parent_id → parent_name, parent_phone`
- `(batch_id, subject_id) → faculty_id → faculty_name`

**Solution:** Store parent details in `parents` and faculty details in `faculty`. Keep only `parent_id` in `students` and `faculty_id` in `batch_subjects`.

### Final 3NF schema, matching the ER diagram

| Table | Relevant columns / key structure | Responsibility |
| --- | --- | --- |
| `parents` | `parent_id PK`, `parent_name`, `parent_phone` | Guardian details stored once |
| `students` | `student_id PK`, `student_name`, `student_phone`, `parent_id FK` | Student details and guardian link |
| `batches` | `batch_id PK`, `batch_name UNIQUE`, `exam_type`, `schedule_day`, `start_time`, `end_time` | One schedule per batch in this design |
| `subjects` | `subject_id PK`, `subject_name UNIQUE` | Subject details stored once |
| `faculty` | `faculty_id PK`, `faculty_name` | Faculty details stored once |
| `enrollments` | `enrollment_id PK`, `student_id FK`, `batch_id FK`, `enrollment_date`; UNIQUE (`student_id`, `batch_id`) | Student–batch junction table |
| `batch_subjects` | `batch_subject_id PK`, `batch_id FK`, `subject_id FK`, `faculty_id FK`; UNIQUE (`batch_id`, `subject_id`) | Batch–subject junction and its assigned faculty |
| `fee_installments` | `installment_id PK`, `enrollment_id FK`, `installment_no`, `amount`, `payment_date`; UNIQUE (`enrollment_id`, `installment_no`) | Individual fee instalments |
| `tests` | `test_id PK`, `batch_subject_id FK`, `test_name`, `test_date`, `max_marks` | Test belongs to a batch–subject offering |
| `test_results` | `result_id PK`, `test_id FK`, `enrollment_id FK`, `marks`; UNIQUE (`test_id`, `enrollment_id`) | One result for each enrollment–test pair |

### Examples of anomalies removed

| Anomaly | Flat spreadsheet problem | 3NF improvement |
| --- | --- | --- |
| **Update** | Renaming a faculty member requires correcting many spreadsheet rows. | Update one row in `faculty`. |
| **Insertion** | A new subject or faculty member cannot easily be recorded until a student/test row exists. | Add `subjects` or `faculty` records independently. |
| **Deletion** | Removing a student's only test-mark row could accidentally erase payment and faculty information. | Test results and payments are stored in separate tables with foreign-key relationships. |

## 6. Data integrity and implementation notes

- The `enrollments` junction resolves the student–batch many-to-many relationship; `batch_subjects` resolves the batch–subject many-to-many relationship.
- Add `NOT NULL`, `UNIQUE`, and `CHECK` constraints as appropriate, including `amount > 0`, `max_marks > 0`, `exam_type IN ('JEE', 'NEET')`, and `end_time > start_time`.
- `marks >= 0` can be enforced in `test_results` with a local `CHECK`. The rule `marks <= tests.max_marks` refers to another table and cannot be directly expressed using a normal cross-table `CHECK` in MySQL. Likewise, verifying that a test's batch matches the enrollment's batch needs a trigger, alternative composite-key design or application-side validation.
- The final SQL must use the exact table and column names represented in the ER diagram and data dictionary; refer to `sql/01-schema.sql` for the authoritative DDL once completed.

## 7. Summary

- **UNF:** Lists and unrelated facts are combined inside a row.
- **1NF:** One value per field; the list problem is removed, but repeated facts remain.
- **2NF:** Remove dependencies on only part of a composite key; separate student, test, enrollment and fee facts.
- **3NF:** Remove transitive dependencies; keep parent and faculty details in their own tables.

The goal is not just more tables: it is to store each fact in the right place, link facts with reliable keys and avoid inconsistent duplicated data.
