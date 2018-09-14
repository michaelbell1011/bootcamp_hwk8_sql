-- 1a. Display the first and last names of all actors from the table actor.
USE sakila;
SELECT first_name, last_name from actor;


-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT ucase(concat(first_name, "  ", last_name)) as "Actor Name" from actor;


-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information? 
SELECT actor_id, first_name, last_name from actor where first_name = "Joe";


-- 2b. Find all actors whose last name contain the letters GEN: (I'm interpreting the question as 'contains the substring "GEN"')
SELECT actor_id, first_name, last_name from actor 
where last_name like "%gen%";


-- 2c. Find all actors whose last names contain the letters LI. (I'm interpreting the question as 'contains the substring "LI"')
-- This time, order the rows by last name and first name, in that order: (I'm interpretting as the order of the columns and  the order of last_name)
SELECT last_name, first_name from actor 
where last_name like "%li%"
order by last_name;


-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country
where country in ("Afghanistan", "Bangladesh", "China");


-- 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type 'BLOB' (aka binary large object dataINSERT INTO `sakila`.`actor`
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE `sakila`.`actor` ADD COLUMN `description` BLOB NULL AFTER `last_update`;
select * from actor;


-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE `sakila`.`actor` DROP COLUMN `description`;
select * from actor;


-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name) as name_count from actor
group by last_name;


-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
select last_name, count(last_name) as name_count from actor
group by last_name
having name_count > 1;


-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
-- Write a query to fix the record. (not instructed to update the timestamp)
select actor_id from actor where first_name = "Groucho" and last_name = "Williams";

UPDATE `sakila`.`actor`
SET `first_name` = "HARPO"
WHERE `actor_id` = 172;

select * from actor WHERE `actor_id` = 172;

-- attempt trying to use sub query didnt work:
-- reverting value
#UPDATE `sakila`.`actor`
#SET `first_name` = "GROUCHO" 
#WHERE `actor_id` = 172;

-- queries needed ID
#select actor_id from `sakila`.`actor` where first_name = "Groucho" and last_name = "Williams";

-- update using sub query (errors)
#UPDATE `sakila`.`actor`
#SET `first_name` = "HARPO"
#WHERE `actor_id` in (select actor_id from `sakila`.`actor` where first_name = "Groucho" and last_name = "Williams");


-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
-- needed to disable safe mode
update actor set first_name = "GROUCHO" where first_name = "HARPO";
select * from actor where first_name = "HARPO";
select * from actor where first_name = "GROUCHO";


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table address;


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select first_name, last_name, address from staff
join address
using (address_id);


-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select staff_id, amount, payment_date, first_name, last_name from payment 
join staff using (staff_id);


select sum(amount), min(payment_date), max(payment_date), first_name, last_name from payment 
join staff using (staff_id)
where payment_date like "2005-08%"
group by staff_id;


-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join
select title, count(actor_id) as "Number of Actors" from film_actor
join film using (film_id)
group by title;


-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system? (used sub query approach)
select count(*) as "in stock", film_id from inventory
where film_id in (
	select film_id from film where title = "Hunchback Impossible"
);


-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer and the customers alphabetically by last name:
select first_name, last_name, sum(amount) as "total paid" from payment
join customer using (customer_id)
group by customer_id
order by last_name;


-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title as "Films in english starting with K or Q" from film
where language_id in (select language_id from `language` where `name` = "English")
and (
		title like "k%" or
        title like "q%"
	);
    

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
-- get film id from film table
select film_id from film where title = "Alone Trip";

-- middle mapping table. get actor ids asscoiated with film ids
select * from film_actor;

-- get actor names from actor table using retrieved actor ids
select first_name, last_name, (select title from film where title = "Alone Trip") as "reference film" from actor where actor_id in 
(
	select actor_id from film_actor where film_id in
		(
			select film_id from film where title = "Alone Trip"
        )
);


-- 7c. Use joins to retrieve the names and email addresses of all Canadian customers. You want to run an email marketing campaign in Canada...
-- country table has contry_id
select c.country_id, c.country from country c where c.country = "Canada";
select c.country_id from country c where c.country = "Canada";
-- city table has country_id
select city_id from city where country_id = 20;
-- address table has city_id
select address_id from address where city_id in (1,2,3);
-- customer table has names, email, and address_id
select first_name, last_name from customer where address_id in (4,5,6);

-- full query
select first_name, last_name, (select c.country from country c where c.country = "Canada") as "reference country" 
from customer where address_id in
(
	select address_id from address where city_id in
	(
		select city_id from city where country_id in
		(
			select c.country_id from country c where c.country = "Canada"
        )
	)
);


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
select title, (select `name` from category where `name` = "Family") as "Target Category" from film 
join film_category using (film_ID)
where category_id in
(
	select category_id from category where `name` = "Family"
);


-- 7e. Display the most frequently rented movies in descending order.
select title, count(*) as "Rental Count" from rental
join inventory using (inventory_id)
join film using (film_id)
group by film_id
order by count(*) desc;



-- 7f. Write a query to display how much business, in dollars, each store brought in.
select store_id, sum(amount) as "Total business dollars" from payment 
join staff using (staff_id)
group by store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.
select store_id, city, country from store
join address using (address_id)
join city using (city_id)
join country using (country_id);


-- 7h. List the top five genres in gross revenue in descending order.
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

select sum(amount) as "Gross Rev", `name` as Genre from payment
join rental using (rental_id)
join inventory using (inventory_id)
join film_category using (film_id)
join category using (category_id)
group by category_id
order by sum(amount) desc
limit 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view.
create view Top5Genres as
select sum(amount) as "Gross Rev", `name` as Genre from payment
join rental using (rental_id)
join inventory using (inventory_id)
join film_category using (film_id)
join category using (category_id)
group by category_id
order by sum(amount) desc
limit 5;


-- 8b. How would you display the view that you created in 8a?
select * from Top5Genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view Top5Genres;