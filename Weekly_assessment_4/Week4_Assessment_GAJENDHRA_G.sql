-- ===================================================================================
-- ======================================THE UNLOX ACADEMY============================
-- ======================================Weekly Assessment============================
-- ==============================Joins, Subqueries,Windows & CTEs=====================
-- ===================================================================================

-- ======================================Section A - Theory===========================

-- A1.  b) INNER JOIN returns only matched rows; LEFT JOIN returns all left-table rows with NULL for non-matches

-- A2. c) Restarts the aggregate calculation for each department while keeping all input rows

-- A3. c) It silently joins on ALL columns with matching names — behaviour can change unexpectedly when
-- the schema is modified

-- A4. b) When the two queries cannot produce overlapping rows, OR when performance matters more than
-- deduplication

-- A5. b) If the subquery inside NOT IN returns any NULL value, the entire NOT IN silently returns zero rows.

-- A6. b) The inner query references a column from the outer query, causing it to re-execute for each outer row

-- A7. b) WHERE runs BEFORE window functions are calculated, so the alias doesn't exist yet

-- A8. b) A named temporary result set defined with the WITH clause, existing only for the duration of the query

-- ==============================Section B - Output Prediction========================

-- B1. How many rows does this query return?
-- SELECT * FROM books b
-- INNER JOIN authors a ON b.author_id = a.author_id;

-- B1 answer: All the books has a corresponding author hence the inner join is used to join everything 
-- and returns all the books without missing a single book.alter

-- B2. How many rows does this query return?
-- SELECT a.name FROM authors a
-- LEFT JOIN books b ON a.author_id = b.author_id
-- WHERE b.book_id IS NULL;

-- B2 answer: All authors have atleast one book when checked so it will return zero rows

-- B3. How many rows does this self-join return, and who are they?
-- SELECT a.name AS author, m.name AS mentor
-- FROM authors a
-- JOIN authors m ON a.mentor_id = m.author_id;

-- B3 answer: It returns preeti,alex,malcom and chetan,yuval,again yuval respectively as author and mentor
-- hence it returns 3 rows

-- B4. How many rows does this UNION return?
-- SELECT name FROM authors WHERE country = 'India'
-- UNION
-- SELECT a.name FROM authors a
-- JOIN books b ON a.author_id = b.author_id
-- WHERE b.genre = 'Mythology';

-- B4 answer: it will return all the authors from india without eliminating anything 
-- because union eliminates all duplicates and there are no duplicates (5 rows)

-- B5. What single value does this query return?
-- SELECT COUNT(*) FROM books
-- WHERE price > (SELECT AVG(price) FROM books);

-- B5 answer: 13

-- B6. How many rows does this query return?
-- SELECT * FROM books b
-- WHERE NOT EXISTS (
-- SELECT 1 FROM sales s WHERE s.book_id = b.book_id);

-- B6 answer: 15 rows

-- B7. What is the total_qty of the top-selling book (first row)?
-- SELECT b.title, SUM(s.quantity) AS total_qty
-- FROM sales s JOIN books b ON s.book_id = b.book_id
-- GROUP BY b.book_id
-- ORDER BY total_qty DESC
-- LIMIT 1;

-- B7 answer: Atomic Habits - 30 quantity

-- B8. What does this query output for Business genre books?
-- SELECT title, price,
-- RANK() OVER (PARTITION BY genre ORDER BY price DESC) AS rank_in_genre
-- FROM books WHERE genre = 'Business';

-- B8 answer: it will return all the business genre book with highest priced book to lowest-priced 
-- book and higest priced book is ranked 1 and so on

-- ======================================Section C - Applied SQL======================

-- C1 - Basic Joins (INNER, LEFT, aggregate)

-- C1. Write a query using INNER JOIN to display each book's title alongside its author's name.
-- Your query:
SELECT b.title, a.name AS author
FROM books b
INNER JOIN authors a
ON b.author_id = a.author_id;

-- C2. Write a LEFT JOIN query listing every author's name and every book they've written.
-- Authors with no books should still appear (once) with NULL for book columns.
-- Your query:
SELECT a.name AS author, b.title
FROM authors a
LEFT JOIN books b
ON a.author_id = b.author_id;

-- C3. Write a query to compute total revenue (sum of quantity × price) per genre. Sort by
-- revenue descending.
-- Your query:
SELECT b.genre, SUM(s.quantity * b.price) AS total_revenue
FROM sales s
INNER JOIN books b
ON s.book_id = b.book_id
GROUP BY b.genre
ORDER BY total_revenue DESC;

-- C4. Write a query to find the single city that has generated the most revenue.
-- Your query:
SELECT s.city, SUM(s.quantity * b.price) AS total_revenue
FROM sales s
INNER JOIN books b
ON s.book_id = b.book_id
GROUP BY s.city
ORDER BY total_revenue DESC
LIMIT 1;

-- C2 - Extended Joins (RIGHT, FULL OUTER, SELF)

-- C5. Write a RIGHT JOIN query showing every book (via RIGHT JOIN from authors) alongside its
-- author. Explain briefly why the result count matches INNER JOIN here.
-- Your query:
SELECT a.name AS author, b.title
FROM authors a
RIGHT JOIN books b
ON a.author_id = b.author_id;

-- C6. Write a FULL OUTER JOIN of authors and books using the UNION trick (since MySQL doesn't
-- support FULL OUTER directly).
-- Your query:
SELECT a.author_id, a.name, b.title
FROM authors a
LEFT JOIN books b
ON a.author_id = b.author_id
UNION
SELECT a.author_id, a.name, b.title
FROM authors a
RIGHT JOIN books b
ON a.author_id = b.author_id;

-- C7. Write a SELF JOIN query showing the name of every mentored author alongside their
-- mentor's name.
-- Your query:
SELECT a.name AS author, mentor.name AS mentor
FROM authors a
INNER JOIN authors mentor
ON a.mentor_id = mentor.author_id;

-- C3 - Set Operations (CROSS, UNION, anti-join)

-- C8. Write a CROSS JOIN query generating every possible combination of city and customer_type
-- from the sales table (use SELECT DISTINCT subqueries).
-- Your query:
SELECT c.city, t.customer_type
FROM (SELECT DISTINCT city FROM sales) c
CROSS JOIN (SELECT DISTINCT customer_type FROM sales) t;

-- C9. Write a UNION query combining: (a) all Indian authors, (b) all authors born after 1970.
-- Result should be deduplicated.
-- Your query:
SELECT name
FROM authors
WHERE country = 'India'
UNION
SELECT name
FROM authors
WHERE YEAR(born_year) > 1970;

-- C10. Write an anti-join query using LEFT JOIN + IS NULL to find all books that have NEVER been sold.
-- Your query:
SELECT b.title
FROM books b
LEFT JOIN sales s
ON b.book_id = s.book_id
WHERE s.book_id IS NULL;

-- C4 - Subqueries (scalar, IN, ANY/ALL, correlated)

-- C11. Write a scalar subquery to find all books priced above the overall average book price.
-- Your query:
SELECT title, price
FROM books
WHERE price > (
				SELECT AVG(price)
				FROM books
			);
            
-- C12. Write a query using IN with a subquery to show all sales of books whose genre is either
-- 'History' or 'Mythology'.
-- Your query:
SELECT *FROM sales
WHERE book_id IN
(
    SELECT book_id
    FROM books
    WHERE genre IN ( 'Mythology','History')
);

-- C13. Write a query using > ALL to find books priced higher than every single Fiction book.
-- Your query:
SELECT title, price
FROM books
WHERE price > ALL
(
    SELECT price FROM books
    WHERE genre = 'Fiction'
);

-- C14. Write a correlated subquery to find books priced above their genre's average price.
-- Your query:
SELECT book1.title, book1.genre, book1.price
FROM books book1
WHERE book1.price >
(
    SELECT AVG(book2.price)
    FROM books book2
    WHERE book2.genre = book1.genre
);

-- C5 - EXISTS / NOT EXISTS

-- C15. Write an EXISTS query to find all authors who have written at least one book published after 2018.
-- Your query:
SELECT a.name FROM authors a
WHERE EXISTS
(
    SELECT 1
    FROM books b
    WHERE b.author_id = a.author_id
      AND YEAR(b.published_year) > 2018
);

-- C16. Write a NOT EXISTS query to find all authors who have never written a book in the 'Business' genre.
-- Your query:
SELECT a.name FROM authors a
WHERE NOT EXISTS
(
    SELECT 1
    FROM books b
    WHERE b.author_id = a.author_id
      AND b.genre = 'Business'
);

-- C17. Write a query using IN with a subquery to find all sales made for books written by Indian authors.
-- Your query:
SELECT * FROM sales
WHERE book_id IN
(
    SELECT b.book_id
    FROM books b
    JOIN authors a
    ON b.author_id = a.author_id
    WHERE a.country = 'India'
);

-- C6 - Window Functions (PARTITION, ROW_NUMBER, LAG, running total)

-- C18. Write a query showing every book alongside its genre's average price (using AVG OVER
-- PARTITION BY) - all 25 rows should appear.
-- Your query:
SELECT title, genre, price, AVG(price) OVER(PARTITION BY genre) AS avg_price_of_genre FROM books;

-- C19. Write a query using ROW_NUMBER to find the top 2 highest-priced books in each genre.
-- Your query:
WITH book_ranks AS
(
    SELECT title, genre, price,
    ROW_NUMBER() OVER
        (
            PARTITION BY genre
            ORDER BY price DESC
        ) AS roll_number FROM books
)
SELECT title, genre, price
FROM book_ranks
WHERE roll_number <= 2
ORDER BY genre, price DESC;

-- C20. Using LAG, write a query showing each sale of book_id 115 (Atomic Habits) alongside the
-- quantity of the previous sale (sorted by sale_date). The first sale should show NULL for previous quantity.
-- Your query:
SELECT sale_id, sale_date, quantity,
    LAG(quantity) OVER
    (
        ORDER BY sale_date
    ) AS last_quantity
FROM sales
WHERE book_id = 115
ORDER BY sale_date;

-- C21. Write a query using SUM() OVER (ORDER BY sale_date) to compute a running total of
-- quantity across all sales.
-- Your query:
SELECT sale_id, sale_date, quantity,
    SUM(quantity) OVER
    (
        ORDER BY sale_date
    ) AS running_total
FROM sales
ORDER BY sale_date;

-- C7 - CTEs & Synthesis

-- C22. Rewrite this query using a CTE (WITH clause) for readability. Compute total quantity sold
-- per book, then join to book details showing title and total.
-- Your query:
WITH books_sold AS
(
    SELECT book_id,
	SUM(quantity) AS total_quantity
    FROM sales
    GROUP BY book_id
)

SELECT b.title, bksld.total_quantity
FROM books b
JOIN books_sold bksld
ON b.book_id = bksld.book_id;

-- C23. Write a multi-CTE query: first CTE computes revenue per genre, second CTE ranks genres
-- by revenue using RANK(). Final SELECT shows genre, revenue, and rank.
-- Your query:
WITH revenue_of_genre AS
(
    SELECT b.genre,
	SUM(s.quantity * b.price) AS revenue
    FROM books b
    JOIN sales s
    ON b.book_id = s.book_id
    GROUP BY b.genre
),
genre_ranking AS
(
    SELECT genre, revenue,
	RANK() OVER
	(
		ORDER BY revenue DESC
	) AS rank_of_genre
    FROM revenue_of_genre
)
SELECT genre, revenue, rank_of_genre FROM genre_ranking;

-- C24. Write a comprehensive query: for each genre, show the top-selling book (by total quantity
-- sold), its author's name, its total quantity, and the genre's total revenue. Use CTEs + window
-- functions + joins. Sort by genre revenue descending.
-- Your query:
WITH books_sold AS
(
    SELECT b.book_id, b.title, b.genre, a.name AS author,
	SUM(s.quantity) AS total_quantity,
	SUM(s.quantity * b.price) AS books_revenue
    FROM books b
    
    JOIN authors a
	ON b.author_id = a.author_id
    
    JOIN sales s
	ON b.book_id = s.book_id
    GROUP BY b.book_id, b.title, b.genre, a.name
),

revenue_of_genre AS
(
    SELECT genre, SUM(books_revenue) AS revenue_of_genre
    FROM books_sold
    GROUP BY genre
),

book_ranks AS
(
    SELECT *,
	ROW_NUMBER() OVER
	(
		PARTITION BY genre
		ORDER BY total_quantity DESC
	) AS roll_number
    FROM books_sold
)

SELECT br.genre, br.title, br.author, br.total_quantity, rog.revenue_of_genre
FROM book_ranks br
JOIN revenue_of_genre rog
ON br.genre = rog.genre
WHERE br.roll_number = 1
ORDER BY rog.revenue_of_genre DESC;
