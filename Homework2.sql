use sakila;

# 1) List each customer’s customer id, first and last name, sorted alphabetically by last name and the total amount spent on rentals. The name of the total amount column should be TOTAL SPENT.
SELECT c.customer_id,
	c.first_name,
	c.last_name,
	SUM(p.amount) AS 'TOTAL SPENT'
FROM customer c
JOIN payment p
	ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name ASC,
	SUM(p.amount) DESC;

# 2) List the unique (no duplicates) District and city name where the postal code is null or empty
SELECT DISTINCT a.district,
	c.city
FROM city c
JOIN address a
	ON a.city_id = c.city_id
WHERE a.postal_code = NULL
	OR a.postal_code = '';
    
# 3) List all the films have the words DOCTOR or FIRE in their title?
SELECT title FROM film WHERE title LIKE '%doctor%' OR title LIKE '%fire%'; 

# 4) List each actor’s actor id, first and last name, sorted alphabetically by last name and the total number of films they have been in. There should be no duplicates. You should have one row per actor. The name of the number of films column should be NUMBER OF MOVIES.
SELECT DISTINCT a.actor_id,
	a.last_name,
    a.first_name,
    COUNT(*) AS 'NUMBER OF MOVIES'
FROM actor a
JOIN film_actor f
	ON a.actor_id = f.actor_id
GROUP BY a.actor_id
ORDER BY a.last_name ASC,
	COUNT(*) DESC;
    
# 5) What is the average run time of each film by category? Order the results by the average run time lowest to highest.
SELECT c.name,
	AVG(f.length) AS 'AVG RUN TIME'
FROM category c
JOIN film_category i
	ON i.category_id = c.category_id
JOIN film f
	ON f.film_id = i.film_id
GROUP BY c.name
ORDER BY AVG(f.length);

# 6) How much business (in dollars) did each store bring in? There should be no duplicates. Just list of each store id and the total dollar amount. Order the result by dollar amount greatest to lowest.
SELECT DISTINCT s.store_id,
	SUM(p.amount) AS 'AMOUNT'
FROM staff s
JOIN payment p
	ON p.staff_id = s.staff_id
GROUP BY s.store_id
ORDER BY SUM(p.amount) DESC;

#7) What is the first and last name, email and total amount spent on movies by customers in Canada? Order alphabetically by their last name.
SELECT c.first_name,
	c.last_name,
	c.email,
	co.country,
    SUM(p.amount) AS 'TOTAL AMOUNT'
FROM customer c
JOIN payment p
	ON c.customer_id = p.customer_id
JOIN address a
	ON a.address_id = c.address_id
JOIN city ci
	ON ci.city_id = a.city_id
JOIN country co
	ON co.country_id = ci.country_id
WHERE co.country = 'Canada'
GROUP BY c.customer_id
ORDER BY c.last_name ASC,
	SUM(p.amount) DESC;

# 8) MATHEW BOLIN would like to rent the movie HUNGER ROOF from staff JON STEPHENS at store 2 today. The rental fee is 2.99. Insert this rental and payment into the database.

-- I will use these queries to get the data that I need
SELECT * FROM customer WHERE last_name = 'bolin'; # 539
SELECT * FROM staff WHERE last_name = 'Stephens'; # 2
SELECT * FROM film WHERE title = 'hunger Roof'; # 440
SELECT * FROM inventory WHERE film_id = 440; #2026

-- Now I can insert the data
START TRANSACTION;

INSERT INTO rental(rental_date, inventory_id, customer_id, staff_id, last_update) 
VALUES(NOW(), 2026, 539, 2, NOW());

# Valiable to get the rental id of the above query
SET @id = (select rental_id FROM rental WHERE customer_id = 539 AND staff_id = 2 AND inventory_id = 2026);


INSERT INTO payment(customer_id, staff_id, rental_id, amount, payment_date, last_update)
VALUES (539, 2, @id, 2.99, NOW(), NOW());

ROLLBACK; -- Rollback or Commit


# 9) TRACY COLE would like to return the movie ALI FOREVER. Update the rental table to reflect this. You can write multiple queries to get the IDs before writing the update statement. You can also do it in a single update statement using joins or sub queries.

-- I will use these queries to get the data that I need
SELECT * FROM customer WHERE last_name = 'Cole'; # 108
SELECT * FROM film WHERE title = 'Ali Forever'; # 13
SELECT inventory_id FROM inventory WHERE film_id = 13; #70
SELECT * FROM rental WHERE inventory_id  = 70 AND customer_id = 108; #15294

START TRANSACTION;
UPDATE rental SET return_date = NOW(),
	last_update = NOW()
WHERE rental_id = 15294;

ROLLBACK; -- Rollback or Commit


#10) Change the original language id for all films in the category ANIMATION to JAPANESE.

-- I will use these queries to get the data that I need
SELECT * FROM language WHERE name = 'Japanese'; #3

START TRANSACTION;

SET SQL_SAFE_UPDATES = 0;

UPDATE film f
JOIN  film_category fc
	ON f.film_id = fc.film_id
JOIN category c
	ON fc.category_id = c.category_id
SET f.original_language_id = 3
WHERE c.name = "Animation";

SET SQL_SAFE_UPDATES = 1;

ROLLBACK; -- Rollback or Commit