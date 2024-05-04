--1. Who is the senior most employee based on job title?

SELECT TOP 1 title, last_name, first_name 
FROM employee
ORDER BY levels DESC

--2. Which countries have the most Invoices?

SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC

--3. What are top 3 values of total invoice

SELECT TOP 3 total
FROM invoice
ORDER BY total DESC

--4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals

SELECT SUM(total) as invoice_total, billing_city
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total

--5. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money.

SELECT TOP 1 c.customer_id, c.first_name, c.last_name, SUM(i.total) as total
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total DESC

--6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A

SELECT DISTINCT c.email, c.first_name, c.last_name
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line l ON i.invoice_id = l.invoice_id
JOIN track t ON t.track_id = l.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name LIKE 'Rock'

--7. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands.

SELECT TOP 10 a.artist_id, a.name, COUNT(a.artist_id) as number_of_songs
FROM artist a
JOIN album alb ON a.artist_id = alb.artist_id
JOIN track t ON alb.album_id = t.album_id
WHERE t.genre_id = 1
GROUP BY a.artist_id, a.name
ORDER BY number_of_songs DESC

--8. Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

SELECT name, milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;

--9. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

WITH best_selling_artist AS (
	SELECT TOP 1 a.artist_id, a.name, SUM(l.unit_price * l.quantity) as total_sales
	FROM artist a
	JOIN album alb ON a.artist_id = alb.artist_id
	JOIN track t ON t.album_id = alb.album_id
	JOIN invoice_line l ON l.track_id = t.track_id
	GROUP BY a.artist_id, a.name
	ORDER BY total_sales DESC)
	
SELECT c.customer_id, c.first_name, c.last_name, bsa.name as artist_name, SUM(l.unit_price * l.quantity) as amout_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line l ON l.invoice_id = i.invoice_id
JOIN track t ON t.track_id = l.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.name
ORDER BY amout_spent DESC

--10. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres.

WITH most_popular_genre AS (
    SELECT TOP 1 g.name AS genre_name, COUNT(*) as genre_id
    FROM invoice_line l
    JOIN track t ON t.track_id = l.track_id
    JOIN genre g ON g.genre_id = t.genre_id
    GROUP BY g.name
    ORDER BY COUNT(*) DESC)
SELECT c.country, genre_name, COUNT(l.quantity) AS purchases
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line l ON l.invoice_id = i.invoice_id
JOIN track t ON t.track_id = l.track_id
JOIN genre g ON g.genre_id = t.genre_id
JOIN most_popular_genre mpg ON g.name = mpg.genre_name
GROUP BY c.country, genre_name

--11. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount.

WITH Customer_with_country AS (
    SELECT c.customer_id, c.first_name, c.last_name, i.billing_country, SUM(i.total) AS total_spending,
    ROW_NUMBER() OVER(PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) AS RowNo 
    FROM invoice i
    JOIN customer c ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country)
SELECT *
FROM Customer_with_country 
WHERE RowNo <= 1
