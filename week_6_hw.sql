--1. 1.Show all customers whose last names start with T. Order them by first name from A-Z.
select *
from customer
where last_name like 'T%'
order by first_name ASC;

--2.Show all rentals returned from 5/28/2005 to 6/1/2005
select *
from rental
WHERE return_date 
BETWEEN '2005/5/28' and '2005/6/1';

--3.How would you determine which movies are rented the most?
select title, count(*)
from inventory
inner join rental
on inventory.inventory_id =rental.inventory_id
inner join film
on inventory.film_id = film.film_id
group by title
order by count desc;

--4.Show how much each customer spent on movies (for all time) . Order them from least to most.
select customer.customer_id, customer.first_name,
customer.last_name, sum(payment.amount)
from customer
inner join payment
on customer.customer_id = payment.customer_id
group by customer.customer_id
order by sum(payment.amount);

--5.Which actor was in the most movies in 2006 (based on this dataset)? Be sure to alias the actor name and count as a more descriptive name. Order the results from most to least.
SELECT count(film.title) As movies_done,
concat(actor.first_name,' ',actor.last_name)as Actor_fullname ,film.release_year
FROM film
INNER JOIN  film_actor
ON film.film_id=film_actor.film_id
INNER JOIN actor
ON film_actor.actor_id=actor.actor_id
GROUP BY film.release_year , actor.first_name, actor.last_name
HAVING film.release_year=2006
ORDER BY count(film.title) desc;

--6.Write an explain plan for 4 and 5. Show the queries and explain what is happening in each one. Use the following link to understand how this works http://postgresguide.com/performance/explain.html 
In 4th question i select two tables. customer and payment. In  customer and payment table customer_id is a primary key so i join customer and payment table using the primary key. in this question to find out customer spent on movies, i use sum function for amount for payment table. i use order by to show result asending order.
In 5th question i use concat funtion to add two or more strings together. I use  HAVING clause in my SQL because the WHERE keyword cannot be used with aggregate functions. 

--7.What is the average rental rate per genre?
SELECT c.name AS genre, round(AVG(f.rental_rate),3) AS Average_rental_rate
FROM category c
INNER JOIN film_category fc
on c.category_id = fc.category_id
INNER JOIN film f
on f.film_id = fc.film_id
GROUP BY genre
ORDER BY Average_rental_rate DESC;

--8.How many films were returned late? Early? On time?
WITH t1 AS (Select *, DATE_PART('day', return_date - rental_date) AS date_difference
            FROM rental),
t2 AS (SELECT rental_duration, date_difference,
              CASE
                WHEN rental_duration > date_difference THEN 'Returned early'
                WHEN rental_duration = date_difference THEN 'Returned on Time'
                ELSE 'Returned late'
              END AS Return_Status
          FROM film f
          JOIN inventory i
          USING(film_id)
          JOIN t1
          USING (inventory_id))
SELECT Return_status, count(*) As total_no_of_films
FROM t2
GROUP BY 1
ORDER BY 2 DESC;

--9.What categories are the most rented and what are their total sales?
SELECT c.name AS Categories , COUNT(cust.customer_id) AS "total demand" ,
SUM(p.amount) AS "total sales"
FROM Category c
INNER JOIN Film_category fc
ON c.category_id=fc.category_id
INNER JOIN  film f
on fc.film_id=f.film_id
INNER JOIN inventory i
ON f.film_id=i.film_id
INNER JOIN  rental r
ON i.inventory_id=r.inventory_id
INNER JOIN  customer cust
on r.customer_id=cust.customer_id
INNER JOIN  payment p
ON r.rental_id=p.rental_id
GROUP BY c.category_id
ORDER BY COUNT(cust.customer_id)desc;

--10.Create a view for 8 and a view for 9. Be sure to name them appropriately. 
SELECT CASE
        WHEN rental_duration > date_part('day', return_date-rental_date)THEN 'Returned Early'
        WHEN rental_duration = date_part('day' , return_date-rental_date)THEN 'Returned on time'
		ELSE 'Returned Late'
		END AS status_of_return,
		COUNT(*) AS total_no_of_films
		FROM film
		INNER JOIN inventory
		ON film.film_id=inventory.film_id
		INNER JOIN rental
		ON inventory.inventory_id=rental.inventory_id
		GROUP BY 1
		ORDER BY 2 DESC;
for case
CREATE VIEW Movies_Return_Stats AS
SELECT CASE
        WHEN rental_duration > date_part('day', return_date-rental_date)THEN 'Returned Early'
        WHEN rental_duration = date_part('day' , return_date-rental_date)THEN 'Returned on time'
		ELSE 'Returned Late'
		END AS status_of_return,
		COUNT(*) AS total_no_of_films
		FROM film
		INNER JOIN inventory
		ON film.film_id=inventory.film_id
		INNER JOIN rental
		ON inventory.inventory_id=rental.inventory_id
		GROUP BY 1
		ORDER BY 2 DESC;
SELECT * FROM Movies_Return_Stats ;*/
SELECT count(film.title) As movies_done,
concat(actor.first_name,' ',actor.last_name)as Actor_fullname ,film.release_year
FROM film
INNER JOIN  film_actor
ON film.film_id=film_actor.film_id
INNER JOIN actor
ON film_actor.actor_id=actor.actor_id
GROUP BY film.release_year , actor.first_name, actor.last_name
HAVING film.release_year=2006
ORDER BY count(film.title) desc
FETCH FIRST 1 ROWS ONLY;*/

--Bonus:
--Write a query that shows how many films were rented each month. Group them by category and month. 

SELECT
    DATE_PART('MONTH', rental_date) months,
    c.name AS Categories,
    COUNT(*) AS Total_films
FROM category c
JOIN film_category fc
  ON c.category_id =fc.category_id
JOIN film f
  ON fc.film_id = f.film_id
JOIN inventory i
  ON f.film_id=i.film_id
JOIN rental r
  ON i.inventory_id=r.inventory_id
GROUP BY 1,2;
