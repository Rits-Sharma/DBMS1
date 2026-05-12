-- ============================
-- SCHEMA CREATION
-- ============================

CREATE TABLE Books (
    book_id INT PRIMARY KEY,
    title VARCHAR(200),
    author VARCHAR(100),
    published_year DATE,
    genre VARCHAR(100),
    available_copies INT CHECK (available_copies >= 0)
);

CREATE TABLE Members (
    member_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    age INT CHECK (age > 0),
    gender VARCHAR(10) CHECK (gender IN ('Male','Female','Other'))
);

CREATE TABLE Borrowed (
    borrow_id INT PRIMARY KEY,
    book_id INT,
    member_id INT,
    borrow_date DATE,
    return_date DATE,
    fine_amount DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (member_id) REFERENCES Members(member_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT unique_book_member UNIQUE (book_id, member_id)
);

-- ============================
-- SAMPLE DATA (Books)
-- ============================

INSERT INTO Books VALUES
(551, 'The_Great_Gatsby', 'F_Scott_Fitzgerald', '1925-04-10', 'Tragedy', 10000),
(552, 'ULYSSES', 'James_Joyce', '1922-02-02', 'Modernist_Novel', 10000),
(553, 'Lolita', 'Vladimir_Nabokov', '1955-01-01', 'Novel', 10000),
(554, 'Brave_New_World', 'Aldous_Huxley', '1932-05-05', 'Science_Fiction_Dystopian_Fiction', 10000),
(555, 'The_Sound_And_The_Fury', 'William_Faulkner', '1929-01-03', 'Southern_Gothic', 10000),
(556, 'Catch22', 'Joseph_Heller', '1961-10-10', 'Dark_Comedy', 10000),
(557, 'The_Grapes_Of_Wrath', 'John_Steinbeck', '1939-04-14', 'Novel', 10000),
(558, 'I_Claudius', 'Robert_Graves', '1934-08-10', 'Historical', 10000),
(559, 'To_The_Lighthouse', 'Virginia_Woolf', '1927-05-05', 'Modernism', 10000);

-- ============================
-- QUERIES
-- ============================

-- 1. Books borrowed by John Smith
SELECT b.title
FROM Books b JOIN Borrowed br ON b.book_id = br.book_id
JOIN Members m ON br.member_id = m.member_id
WHERE m.name = 'John Smith';

-- 2. Members who borrowed "Atomic Habits"
SELECT m.name
FROM Members m JOIN Borrowed br ON m.member_id = br.member_id
JOIN Books b ON br.book_id = b.book_id
WHERE b.title = 'Atomic Habits';

-- 3. Genre-wise available copies
SELECT genre, SUM(available_copies) AS total_available
FROM Books GROUP BY genre;

-- 4. Genre most liked by female members
SELECT b.genre, COUNT(*) AS borrow_count
FROM Borrowed br JOIN Members m ON br.member_id = m.member_id
JOIN Books b ON br.book_id = b.book_id
WHERE m.gender = 'Female'
GROUP BY b.genre
ORDER BY borrow_count DESC LIMIT 1;

-- 5. Genre most liked by senior citizens (age >= 60)
SELECT b.genre, COUNT(*) AS borrow_count
FROM Borrowed br JOIN Members m ON br.member_id = m.member_id
JOIN Books b ON br.book_id = b.book_id
WHERE m.age >= 60
GROUP BY b.genre
ORDER BY borrow_count DESC LIMIT 1;

-- 6. Members who returned books within 14 days
SELECT DISTINCT m.name
FROM Members m JOIN Borrowed br ON m.member_id = br.member_id
WHERE br.return_date IS NOT NULL
AND DATEDIFF(br.return_date, br.borrow_date) <= 14;

-- 7. Books currently borrowed and overdue
SELECT b.title, m.name
FROM Borrowed br JOIN Books b ON br.book_id = b.book_id
JOIN Members m ON br.member_id = m.member_id
WHERE br.return_date IS NULL
AND DATEDIFF(CURDATE(), br.borrow_date) > 14;

-- 8. Most popular genre
SELECT b.genre, COUNT(*) AS total_borrowed
FROM Borrowed br JOIN Books b ON br.book_id = b.book_id
GROUP BY b.genre
ORDER BY total_borrowed DESC LIMIT 1;

-- 9. Add fine_amount column (already added in schema)
-- ALTER TABLE Borrowed ADD fine_amount DECIMAL(10,2) DEFAULT 0;

-- 10. Total fines collected from overdue books
SELECT SUM(fine_amount) AS total_fines
FROM Borrowed
WHERE return_date IS NULL AND DATEDIFF(CURDATE(), borrow_date) > 14;

-- 11. Top 5 members who borrowed most books
SELECT m.name, COUNT(*) AS books_borrowed
FROM Members m JOIN Borrowed br ON m.member_id = br.member_id
GROUP BY m.name
ORDER BY books_borrowed DESC LIMIT 5;

-- 12. UNIQUE constraint already added in schema

-- 13. Books currently available
SELECT title, available_copies
FROM Books
WHERE available_copies > 0;

-- 14. Categorize members by borrowing behaviour
SELECT m.name,
CASE
    WHEN COUNT(br.borrow_id) > 10 THEN 'Frequent Borrower'
    WHEN COUNT(br.borrow_id) BETWEEN 5 AND 10 THEN 'Regular Borrower'
    ELSE 'Occasional Borrower'
END AS category
FROM Members m LEFT JOIN Borrowed br ON m.member_id = br.member_id
GROUP BY m.name;

-- 15. Members who return books quickly (avg < 7 days)
SELECT m.name, AVG(DATEDIFF(br.return_date, br.borrow_date)) AS avg_return_time
FROM Members m JOIN Borrowed br ON m.member_id = br.member_id
WHERE br.return_date IS NOT NULL
GROUP BY m.name
HAVING avg_return_time < 7;

-- ============================
-- TRIGGERS
-- ============================

-- a. After book issue, decrement available copies
CREATE TRIGGER after_book_issue
AFTER INSERT ON Borrowed
FOR EACH ROW
UPDATE Books
SET available_copies = available_copies - 1
WHERE book_id = NEW.book_id;

-- b. After book return, increment available copies
CREATE TRIGGER after_book_return
AFTER UPDATE ON Borrowed
FOR EACH ROW
WHEN NEW.return_date IS NOT NULL
UPDATE Books
SET available_copies = available_copies + 1
WHERE book_id = NEW.book_id;
