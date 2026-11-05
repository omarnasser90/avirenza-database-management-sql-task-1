-- Full sample data. Run ONCE on the empty schema, not after earlier INSERT statements.

-- Run after 01-schema.sql.
INSERT INTO parents (parent_name, parent_phone) VALUES
('Rajesh Sharma', 'PHONE-001'),
('Amit Verma', 'PHONE-002'),
('Sunita Gupta', 'PHONE-003'),
('Vikram Singh', 'PHONE-004'),
('Neha Patel', 'PHONE-005'),
('Suresh Mehta', 'PHONE-006'),
('Anjali Jain', 'PHONE-007'),
('Ravi Kumar', 'PHONE-008'),
('Pooja Agarwal', 'PHONE-009'),
('Deepak Joshi', 'PHONE-010');

INSERT INTO students (student_name, student_phone, parent_id) VALUES
('Aarav Sharma', 'STU-001', 1),
('Riya Verma', 'STU-002', 2),
('Aditya Gupta', 'STU-003', 3),
('Priya Singh', 'STU-004', 4),
('Rahul Patel', 'STU-005', 5),
('Sneha Mehta', 'STU-006', 6),
('Karan Jain', 'STU-007', 7),
('Ananya Kumar', 'STU-008', 8),
('Ishita Agarwal', 'STU-009', 9),
('Rohan Joshi', 'STU-010', 10),
('Diya Sharma', 'STU-011', 1),
('Nikhil Gupta', 'STU-012', 3);

INSERT INTO batches (batch_name, exam_type, schedule_day, start_time, end_time) VALUES
('JEE-A', 'JEE', 'Monday', '09:00:00', '11:00:00'),
('JEE-B', 'JEE', 'Tuesday', '10:00:00', '12:00:00'),
('JEE-C', 'JEE', 'Wednesday', '11:00:00', '13:00:00'),
('JEE-D', 'JEE', 'Thursday', '14:00:00', '16:00:00'),
('JEE-E', 'JEE', 'Friday', '15:00:00', '17:00:00'),
('NEET-A', 'NEET', 'Monday', '12:00:00', '14:00:00'),
('NEET-B', 'NEET', 'Tuesday', '13:00:00', '15:00:00'),
('NEET-C', 'NEET', 'Wednesday', '14:00:00', '16:00:00'),
('NEET-D', 'NEET', 'Thursday', '09:00:00', '11:00:00'),
('NEET-E', 'NEET', 'Friday', '10:00:00', '12:00:00');

INSERT INTO subjects (subject_name) VALUES
('Mathematics'),
('Physics'),
('Chemistry'),
('Biology'),
('Algebra'),
('Calculus'),
('Organic Chemistry'),
('Physical Chemistry'),
('Botany'),
('Zoology');

INSERT INTO faculty (faculty_name) VALUES
('Arjun Mehta'),
('Neha Kapoor'),
('Vivek Sharma'),
('Priya Nair'),
('Rohit Verma'),
('Anita Rao'),
('Kunal Singh'),
('Pooja Desai'),
('Sanjay Gupta'),
('Meera Joshi');

INSERT INTO enrollments (student_id, batch_id, enrollment_date) VALUES
(1, 1, '2026-09-01'),
(2, 1, '2026-09-01'),
(1, 2, '2026-09-02'),
(3, 2, '2026-09-02'),
(2, 3, '2026-09-03'),
(4, 3, '2026-09-03'),
(3, 4, '2026-09-04'),
(5, 4, '2026-09-04'),
(4, 5, '2026-09-05'),
(6, 5, '2026-09-05'),
(7, 6, '2026-09-06'),
(8, 6, '2026-09-06'),
(7, 7, '2026-09-07'),
(9, 7, '2026-09-07'),
(8, 8, '2026-09-08'),
(10, 8, '2026-09-08'),
(9, 9, '2026-09-09'),
(11, 9, '2026-09-09'),
(10, 10, '2026-09-10'),
(12, 10, '2026-09-10');

-- 20 batch-subject assignments; IDs start at 1 on a fresh DB Fiddle run.
INSERT INTO batch_subjects (batch_id, subject_id, faculty_id) VALUES
(1, 1, 1),
(1, 2, 2),
(2, 1, 3),
(2, 3, 4),
(3, 5, 5),
(3, 6, 6),
(4, 2, 2),
(4, 7, 7),
(5, 1, 1),
(5, 3, 8),
(6, 4, 9),
(6, 3, 4),
(7, 9, 10),
(7, 10, 9),
(8, 4, 9),
(8, 8, 8),
(9, 10, 10),
(9, 2, 2),
(10, 9, 10),
(10, 3, 4);

-- 40 instalments: one paid and one pending per enrollment.
INSERT INTO fee_installments (enrollment_id, installment_no, amount, payment_date) VALUES
(1, 1, 2500, '2026-09-15'),
(1, 2, 2000, NULL),
(2, 1, 2500, '2026-09-15'),
(2, 2, 2000, NULL),
(3, 1, 2500, '2026-09-15'),
(3, 2, 2000, NULL),
(4, 1, 2500, '2026-09-15'),
(4, 2, 2000, NULL),
(5, 1, 2500, '2026-09-15'),
(5, 2, 2000, NULL),
(6, 1, 2500, '2026-09-15'),
(6, 2, 2000, NULL),
(7, 1, 2500, '2026-09-15'),
(7, 2, 2000, NULL),
(8, 1, 2500, '2026-09-15'),
(8, 2, 2000, NULL),
(9, 1, 2500, '2026-09-15'),
(9, 2, 2000, NULL),
(10, 1, 2500, '2026-09-15'),
(10, 2, 2000, NULL),
(11, 1, 2200, '2026-09-15'),
(11, 2, 1800, NULL),
(12, 1, 2200, '2026-09-15'),
(12, 2, 1800, NULL),
(13, 1, 2200, '2026-09-15'),
(13, 2, 1800, NULL),
(14, 1, 2200, '2026-09-15'),
(14, 2, 1800, NULL),
(15, 1, 2200, '2026-09-15'),
(15, 2, 1800, NULL),
(16, 1, 2200, '2026-09-15'),
(16, 2, 1800, NULL),
(17, 1, 2200, '2026-09-15'),
(17, 2, 1800, NULL),
(18, 1, 2200, '2026-09-15'),
(18, 2, 1800, NULL),
(19, 1, 2200, '2026-09-15'),
(19, 2, 1800, NULL),
(20, 1, 2200, '2026-09-15'),
(20, 2, 1800, NULL);

-- 20 tests, one for each batch-subject assignment.
INSERT INTO tests (batch_subject_id, test_name, test_date, max_marks) VALUES
(1, 'JEE-A Mathematics Quiz', '2026-10-05', 100),
(2, 'JEE-A Physics Quiz', '2026-10-12', 50),
(3, 'JEE-B Mathematics Quiz', '2026-10-06', 100),
(4, 'JEE-B Chemistry Quiz', '2026-10-13', 50),
(5, 'JEE-C Algebra Quiz', '2026-10-07', 100),
(6, 'JEE-C Calculus Quiz', '2026-10-14', 50),
(7, 'JEE-D Physics Quiz', '2026-10-08', 100),
(8, 'JEE-D Organic Chemistry Quiz', '2026-10-15', 50),
(9, 'JEE-E Mathematics Quiz', '2026-10-09', 100),
(10, 'JEE-E Chemistry Quiz', '2026-10-16', 50),
(11, 'NEET-A Biology Quiz', '2026-10-05', 100),
(12, 'NEET-A Chemistry Quiz', '2026-10-12', 50),
(13, 'NEET-B Botany Quiz', '2026-10-06', 100),
(14, 'NEET-B Zoology Quiz', '2026-10-13', 50),
(15, 'NEET-C Biology Quiz', '2026-10-07', 100),
(16, 'NEET-C Physical Chemistry Quiz', '2026-10-14', 50),
(17, 'NEET-D Zoology Quiz', '2026-10-08', 100),
(18, 'NEET-D Physics Quiz', '2026-10-15', 50),
(19, 'NEET-E Botany Quiz', '2026-10-09', 100),
(20, 'NEET-E Chemistry Quiz', '2026-10-16', 50);

-- 40 results; each test has exactly two enrolled students.
INSERT INTO test_results (test_id, enrollment_id, marks) VALUES
(1, 1, 84),
(1, 2, 92),
(2, 1, 43),
(2, 2, 47),
(3, 3, 88),
(3, 4, 75),
(4, 3, 39),
(4, 4, 42),
(5, 5, 77),
(5, 6, 89),
(6, 5, 45),
(6, 6, 41),
(7, 7, 81),
(7, 8, 74),
(8, 7, 48),
(8, 8, 40),
(9, 9, 91),
(9, 10, 85),
(10, 9, 42),
(10, 10, 38),
(11, 11, 87),
(11, 12, 78),
(12, 11, 44),
(12, 12, 39),
(13, 13, 83),
(13, 14, 90),
(14, 13, 40),
(14, 14, 46),
(15, 15, 76),
(15, 16, 88),
(16, 15, 35),
(16, 16, 43),
(17, 17, 92),
(17, 18, 82),
(18, 17, 47),
(18, 18, 39),
(19, 19, 85),
(19, 20, 79),
(20, 19, 41),
(20, 20, 37);

-- Verification: expected counts are 20, 40, 20, 40.
SELECT 'batch_subjects' AS table_name, COUNT(*) AS row_count FROM batch_subjects
UNION ALL SELECT 'fee_installments', COUNT(*) FROM fee_installments
UNION ALL SELECT 'tests', COUNT(*) FROM tests
UNION ALL SELECT 'test_results', COUNT(*) FROM test_results;

-- Check that all marks and batch memberships are valid for the fictional data.
SELECT tr.result_id, tr.test_id, tr.enrollment_id, tr.marks, t.max_marks
FROM test_results tr
JOIN tests t ON tr.test_id = t.test_id
JOIN batch_subjects bs ON t.batch_subject_id = bs.batch_subject_id
JOIN enrollments e ON tr.enrollment_id = e.enrollment_id
WHERE tr.marks > t.max_marks OR e.batch_id <> bs.batch_id;
-- Expected: 0 rows. The current schema does not enforce these two conditions automatically.
