 CREATE TABLE reporting_schema.customer_dimension (
     customer_id INT PRIMARY KEY,
 	first_name VARCHAR,
 	last_name VARCHAR
 );

INSERT INTO reporting_schema.customer_dimension(customer_id, first_name,last_name)
SELECT
	se_customer.customer_id,
 	se_customer.first_name,
	se_customer.last_name
FROM public.customer AS se_customer;


CREATE TABLE reporting_schema.rental_fact (
    id SERIAL PRIMARY KEY,
	rental_id INT,
    customer_id INT,
    rental_date DATE,
    return_date DATE,
    rental_fee DECIMAL,
    FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id)
);

INSERT INTO reporting_schema.rental_fact (rental_id, customer_id, rental_date, return_date, rental_fee)
SELECT
	se_rental.rental_id,
    se_rental.customer_id,
    se_rental.rental_date,
    se_rental.return_date,
    se_paymeny.amount AS rental_fee
FROM public.rental AS se_rental
JOIN public.payment AS se_paymeny 
	ON se_rental.rental_id = se_paymeny.rental_id;


CREATE TABLE reporting_schema.customer_agg (
    customer_id INT PRIMARY KEY,
    total_movies_rented INT,
    total_paid DECIMAL,
    average_rental_duration NUMERIC
);


INSERT INTO reporting_schema.customer_agg (customer_id, total_movies_rented, total_paid, average_rental_duration)
SELECT
    se_customer.customer_id,
    COUNT(se_rental.rental_id) AS total_movies_rented,
    SUM(se_payment.amount) AS total_paid,
    AVG(DATE_PART('day', se_rental.return_date - se_rental.rental_date)) AS average_rental_duration
FROM public.customer AS se_customer
INNER JOIN public.rental AS se_rental 
	ON se_customer.customer_id = se_rental.customer_id
INNER JOIN public.payment AS se_payment 
	ON se_rental .rental_id = se_payment.rental_id
GROUP BY se_customer.customer_id;





