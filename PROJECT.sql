use film_rental;

# 1. What is the total revenue generated 
# from all rentals in the database? (2 Marks)

select * from payment;

select sum(amount) as total_revenue from payment;

# 2. How many rentals were made in each month_name? (2 Marks)

select * from rental;

select monthname(rental_date) as month_name,
count(rental_id) as no_of_rentals from rental
group by month_name ORDER BY NO_OF_RENTALS DESC;

# 3. What is the rental rate of the film with the longest title in the database? (2 Marks)

select * from film;

select title,length(title),rental_rate from film
order by length(title) desc limit 1;


# 4. What is the average rental rate for films that were 
# taken from the last 30 days from the date("2005-05-05 22:04:30")? (2 Marks)

select avg(rental_rate) as avg_rental_rate
from Film join inventory on film.film_id=inventory.film_id
join rental on inventory.inventory_id=rental.inventory_id
where datediff("2005-05-05 22:04:30", rental_date) <= 30;


# 5. What is the most popular category of films in terms of 
# the number of rentals? (3 Marks)

select * from rental;
select * from film_category;
select * from film;
select * from category;
select * from inventory;

select name,count(*) as no_of_rentals 
from category 
join film_category on category.category_id=film_category.category_id
join film on film_category.film_id=film.film_id
join rental on film.film_id=rental.inventory_id
group by name
order by no_of_rentals desc
limit 1;


# 6. Find the longest movie duration from the list of films 
# that have not been rented by any customer. (3 Marks)

select * from film;
select * from customer;
select * from rental;

SELECT MAX(length) AS longest_duration
FROM Film
WHERE film_id NOT IN (SELECT DISTINCT inventory_id FROM Rental);


# 7. What is the average rental rate for films, 
# broken down by category? (3 Marks)

select * from film;
select * from film_category;
select * from category;

select name,category.category_id,avg(rental_rate) from film 
join film_category on film.film_id=film_category.film_id
join category on film_category.category_id=category.category_id
group by category.category_id;


# 8. What is the total revenue generated from rentals for 
# each actor in the database? (3 Marks)

select * from film_actor;
select * from film;
select * from actor;
select * from payment;
select * from rental;

select actor.actor_id,concat_ws(' ',first_name,last_name) as Actor_Name,
sum(amount) as total_revenue from film
join film_actor on film.film_id=film_actor.film_id
join actor on film_actor.actor_id=actor.actor_id
join rental on film.film_id=rental.inventory_id
join payment on rental.rental_id=payment.rental_id
group by actor.actor_id;


# 9. Show all the actresses who worked in a film having a 
# "Wrestler" in the description. (3 Marks)

select * from film ;
select * from actor;
select * from  film_actor;

select distinct actor.actor_id,concat_ws(' ',first_name,last_name) as Actor_Name
from actor join film_actor on actor.actor_id=film_actor.actor_id
join film on film.film_id=film_actor.film_id
where description like '%Wrestler%';

-- NOTE : Since gender column is not given in dataset, 
-- it is not possible to filter out actresses.


# 10. Which customers have rented the same film 
# more than once? (3 Marks)

select * from customer;
select * from rental;
select * from inventory;

select customer_id,film_id,count(*) as rental_count from rental
join inventory on rental.inventory_id=inventory.inventory_id
group by customer_id,film_id
having count(*)>1;


# 11. How many films in the comedy category have a 
# rental rate higher than the average rental rate? (3 Marks)

select * from category;
select * from film_category;
select * from film;

select count(film.film_id) as no_of_films from film 
join film_category on film.film_id=film_category.film_id
join category on category.category_id=film_category.category_id
where category.name='comedy' and rental_rate>
(select avg(rental_rate) from film);


# 12. Which films have been rented the most by customers 
# living in each city? (3 Marks)

select * from customer;
select * from city;
select * from film;
select * from inventory;
select * from address;
select * from rental;


select city,film.title,count(*) as no_of_rentals from customer
join address on customer.address_id=address.address_id
join city on address.city_id=city.city_id
join rental on customer.customer_id=rental.customer_id
join inventory on rental.inventory_id=inventory.inventory_id
join film on inventory.film_id=film.film_id
group by city,film.title
order by no_of_rentals desc;


# 13. What is the total amount spent by customers whose 
# rental payments exceed $200? (3 Marks)

select * from payment;

select customer_id,sum(amount) as total_amount from payment
group by customer_id
having  total_amount>200;


# 14. Display the fields which are having foreign key constraints 
# related to the "rental" table. [Hint: using Information_schema] (2 Marks)

select table_name,column_name,constraint_name,
referenced_table_name,referenced_column_name
from information_schema.key_column_usage
where referenced_table_name='rental';


# 15. Create a View for the total revenue generated by each 
# staff member, broken down by store city with the country name. (4 Marks)

select * from staff;
select * from store;
select * from address;
select * from city;
select * from country;


create view STORE_VIEW as
select staff_id,concat_ws(',',city,country) as store_location,
sum(amount) as total_revenue from staff
join address using (address_id)
join city using (city_id)
join country using (country_id)
join store using (store_id)
join payment using (staff_id)
group by staff.staff_id,store_location;

select * from store_view;





# 16. Create a view based on rental information consisting of visiting_day, customer_name, the title of the film, 
# no_of_rental_days, the amount paid by the customer along with the percentage of customer spending. (4 Marks)

create view RENTAL_INFORMATION AS
select dayname(rental_date) as Visiting_Day,
concat_ws(' ',first_name,last_name) as customer_name,
title as film_title,
datediff(return_date,rental_date) as No_of_rental_days,
amount as amount_paid,
(amount/(select sum(amount) from payment where 
customer_id=rental.customer_id))*100 as Percentage
from rental join customer on rental.customer_id=customer.customer_id
join inventory on rental.inventory_id=inventory.inventory_id
join film on inventory.film_id=film.film_id
join payment on rental.rental_id=payment.rental_id;

SELECT * FROM RENTAL_INFORMATION;


# 17. Display the customers who paid 50% of their total rental 
# costs within one day. (5 Marks)


select customer.customer_id,concat_ws(' ',first_name,last_name) as Customer_name,
rental.rental_id,rental_date,amount,payment_date from rental
join customer on rental.customer_id=customer.customer_id
join payment on rental.rental_id=payment.rental_id
where amount>=0.5*(select sum(amount) from payment) and
datediff(payment_date,rental_date)<=1;
