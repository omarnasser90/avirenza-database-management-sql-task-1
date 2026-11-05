# Business Rules — Coaching Centre Database

## Project overview

The coaching centre offers JEE and NEET preparation batches. The database stores students, parents/guardians, batches, enrollments, subjects, faculty, fee instalments, tests, and test results. The rules below define how these records relate to one another.

## Business rules

1. **Student enrollment in multiple batches (assignment requirement).** A student can enroll in several batches.
2. **Multiple students in a batch (design interpretation).** A batch can have many students. Each student–batch membership is represented by an enrollment record.
3. **One enrollment per student–batch pair (design decision).** A student must not have duplicate enrollment records for the same batch.
4. **One schedule per batch (assignment requirement).** Each batch has one schedule, represented in this design by a schedule day, start time, and end time.
5. **Subjects offered by batches (assignment requirement).** Each batch offers multiple subjects; a subject can be offered in multiple batches.
6. **One faculty member for a subject within a batch (assignment requirement).** Each batch–subject combination is assigned exactly one faculty member. A faculty member may teach multiple batch–subject combinations.
7. **Parent/guardian association (design decision).** Each student is linked to one parent/guardian record; one parent/guardian may be linked to several students.
8. **Fees paid in instalments (assignment requirement).** Fee instalments are recorded separately, and each instalment belongs to one student enrollment. An enrollment can have multiple instalments.
9. **Valid instalment details (design decision).** Each instalment has a positive amount, and its instalment number is unique within its enrollment. A missing payment date indicates that payment has not yet been recorded.
10. **Tests for batch subjects (design decision).** Each test is associated with one subject offered in one batch. A batch–subject combination can have multiple tests.
11. **Students take multiple tests (assignment requirement).** Students can take many tests, and each recorded test result links a test to a student enrollment.
12. **One result per test and enrollment (design decision).** A given enrollment can have at most one result for any particular test.
13. **Valid marks and batch membership (design decision).** Test marks cannot be negative or higher than the test's maximum marks, and the enrollment must belong to the same batch as the test.
14. **Allowed exam types and valid times (design decision based on the scenario).** A batch's exam type is JEE or NEET, and its end time must be later than its start time.

## Mapping to database tables

| Business concept | Table(s) |
| --- | --- |
| Parent or guardian | `parents`, `students` |
| Student in a batch | `students`, `batches`, `enrollments` |
| Batch schedule | `batches` |
| Subjects and faculty by batch | `batches`, `subjects`, `faculty`, `batch_subjects` |
| Fee payments | `enrollments`, `fee_installments` |
| Tests and marks | `batch_subjects`, `tests`, `enrollments`, `test_results` |

## Notes for the SQL implementation

- Enforce unique student–batch pairs with `UNIQUE (student_id, batch_id)` in `enrollments`.
- Enforce one faculty assignment per batch–subject combination with `UNIQUE (batch_id, subject_id)` in `batch_subjects`.
- Enforce unique instalment numbers with `UNIQUE (enrollment_id, installment_no)` in `fee_installments`.
- Enforce one test result per enrollment with `UNIQUE (test_id, enrollment_id)` in `test_results`.
- Use `CHECK` constraints for positive amounts, positive maximum marks, valid exam types, and valid schedule times.
- The 'marks at most max_marks' and 'same batch as test' rules involve comparing rows across tables. They need an appropriate relational design or additional enforcement (for example, triggers); a simple single-table `CHECK` constraint is not sufficient.

## Cross-table rule enforcement scope

The submitted MySQL schema includes two single-statement triggers on `test_results` that reject a new or changed result if its marks exceed the test maximum or its enrollment is from a different batch. They do **not** automatically revalidate recorded results following later modifications to the related `tests`, `enrollments` or `batch_subjects` records; additional triggers would be required in production.
