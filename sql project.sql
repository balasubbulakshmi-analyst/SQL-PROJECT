drop database if exists elearner;
create database Elearner;
use Elearner;
create table learners(
learner_id int primary key,
full_name varchar(100),
country varchar(50)
);
create table courses(
course_id int primary key,
course_name varchar(100),
category varchar(50),
unit_price decimal(10,2)
);
create table purchases(
purchase_id int primary key,
learner_id int,
course_id int,
quantity int,
purchaes_date date,
constraint fk_purchases_learners foreign key (learner_id) references learners(learner_id),
constraint fk_purchases_courses foreign key (course_id) references courses(course_id)
);

use Elearner;
INSERT INTO learners (learner_id, full_name, country) VALUES
(1, 'Aarav Sharma',   'India'),
(2, 'Emily Johnson',  'USA'),
(3, 'Liam Brown',     'UK'),
(4, 'Sofia Garcia',   'Spain'),
(5, 'Chen Wei',       'China');

INSERT INTO courses (course_id, course_name, category, unit_price) VALUES
(101, 'Python for Data Analysis',   'Programming',    49.99),
(102, 'SQL Masterclass',            'Data',           39.50),
(103, 'Digital Marketing Basics',   'Marketing',      29.00),
(104, 'Machine Learning Essentials','Data',           79.99),
(105, 'Graphic Design Fundamentals','Design',         34.75);

INSERT INTO purchases (purchase_id, learner_id, course_id, quantity, purchaes_date) VALUES
(1, 1, 101, 1, '2025-01-10'),
(2, 1, 102, 2, '2025-01-15'),
(3, 2, 104, 1, '2025-02-05'),
(4, 2, 103, 1, '2025-02-20'),
(5, 3, 101, 3, '2025-03-02'),
(6, 3, 102, 1, '2025-03-18'),
(7, 4, 104, 2, '2025-04-07'),
(8, 1, 104, 1, '2025-04-25');
use Elearner;
select* from learners;
select* from courses;
select* from purchases;

-- INNER JOIN: each learner's purchase details (only learners who purchased)

SELECT
    l.full_name                                  AS learner_name,
    c.course_name                                AS course_name,
    c.category                                   AS category,
    p.quantity                                   AS quantity,
    FORMAT(p.quantity * c.unit_price, 2)         AS total_amount,
    p.purchaes_date                              AS purchaes_date
FROM purchases p
INNER JOIN learners l ON p.learner_id = l.learner_id
INNER JOIN courses  c ON p.course_id  = c.course_id
ORDER BY p.quantity * c.unit_price DESC;

-- LEFT JOIN: all learners, including those who have not purchased anything

SELECT
    l.learner_id                                          AS learner_id,
    l.full_name                                           AS learner_name,
    l.country                                             AS country,
    c.course_name                                         AS course_name,
    c.category                                            AS category,
    p.quantity                                            AS quantity,
    FORMAT(IFNULL(p.quantity * c.unit_price, 0), 2)       AS total_amount,
    p.purchaes_date                                       AS purchaes_date
FROM learners l
LEFT JOIN purchases p ON l.learner_id = p.learner_id
LEFT JOIN courses   c ON p.course_id  = c.course_id
ORDER BY l.full_name, p.purchaes_date;

-- RIGHT JOIN: all courses, including those never purchased

SELECT
    c.course_id                                           AS course_id,
    c.course_name                                         AS course_name,
    c.category                                            AS category,
    l.full_name                                           AS learner_name,
    p.quantity                                            AS quantity,
    FORMAT(IFNULL(p.quantity * c.unit_price, 0), 2)       AS total_amount,
    p.purchaes_date                                       AS purchaes_date
FROM purchases p
INNER JOIN learners l ON p.learner_id = l.learner_id
RIGHT JOIN courses  c ON p.course_id  = c.course_id
ORDER BY c.course_name, p.purchaes_date;

-- 3. ANALYTICAL QUERIES
-- Q1. Display each learner’s total spending (quantity × unit_price) along with their country.
SELECT
    l.full_name                                               AS learner_name,
    l.country                                                AS country,
    FORMAT(IFNULL(SUM(p.quantity * c.unit_price), 0), 2)     AS total_spent
FROM learners l
LEFT JOIN purchases p ON l.learner_id = p.learner_id
LEFT JOIN courses   c ON p.course_id  = c.course_id
GROUP BY l.learner_id, l.full_name, l.country
ORDER BY IFNULL(SUM(p.quantity * c.unit_price), 0) DESC;


-- Q2. Find the top 3 most purchased courses based on total quantity sold.
SELECT
    c.course_name                AS course_name,
    c.category                   AS category,
    SUM(p.quantity)              AS total_quantity_sold
FROM courses c
INNER JOIN purchases p ON c.course_id = p.course_id
GROUP BY c.course_id, c.course_name, c.category
ORDER BY total_quantity_sold DESC, c.course_name
LIMIT 3;

-- Q3. Each category's total revenue and number of unique learners

SELECT
    c.category                                       AS category,
    FORMAT(SUM(p.quantity * c.unit_price), 2)        AS total_revenue,
    COUNT(DISTINCT p.learner_id)                     AS unique_learners
FROM courses c
INNER JOIN purchases p ON c.course_id = p.course_id
GROUP BY c.category
ORDER BY SUM(p.quantity * c.unit_price) DESC;

-- Q4. Learners who purchased courses from more than one category

SELECT
    l.full_name                          AS learner_name,
    l.country                            AS country,
    COUNT(DISTINCT c.category)           AS categories_purchased
FROM learners l
INNER JOIN purchases p ON l.learner_id = p.learner_id
INNER JOIN courses   c ON p.course_id  = c.course_id
GROUP BY l.learner_id, l.full_name, l.country
HAVING COUNT(DISTINCT c.category) > 1
ORDER BY categories_purchased DESC, l.full_name;

-- Q5. Courses that have not been purchased at all

SELECT
    c.course_id      AS course_id,
    c.course_name    AS course_name,
    c.category       AS category,
    c.unit_price     AS unit_price
FROM courses c
LEFT JOIN purchases p ON c.course_id = p.course_id
WHERE p.purchase_id IS NULL;









