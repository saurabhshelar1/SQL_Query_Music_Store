/* Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */

SELECT TITLE,
	LAST_NAME,
	FIRST_NAME
FROM EMPLOYEE
ORDER BY LEVELS DESC
LIMIT 1


/* Q2: Which countries have the most Invoices? */

SELECT COUNT(*) AS C,
	BILLING_COUNTRY
FROM INVOICE
GROUP BY BILLING_COUNTRY
ORDER BY C DESC


/* Q3: What are top 3 values of total invoice? */

SELECT TOTAL
FROM INVOICE
ORDER BY TOTAL DESC


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT BILLING_CITY,
	SUM(TOTAL) AS INVOICETOTAL
FROM INVOICE
GROUP BY BILLING_CITY
ORDER BY INVOICETOTAL DESC
LIMIT 1;


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT CU.CUSTOMER_ID,
	CU.FIRST_NAME,
	CU.LAST_NAME,
	SUM(IV.TOTAL) AS TOTAL_SPENDING
FROM CUSTOMER AS CU
JOIN INVOICE AS IV ON CU.CUSTOMER_ID = IV.CUSTOMER_ID
GROUP BY CU.CUSTOMER_ID
ORDER BY TOTAL_SPENDING DESC
LIMIT 1;


/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT DISTINCT CU.EMAIL AS EMAIL,
	CU.FIRST_NAME AS FIRSTNAME,
	CU.LAST_NAME AS LASTNAME,
	GE.NAME AS GENRENAME
FROM CUSTOMER AS CU
JOIN INVOICE AS IV ON IV.CUSTOMER_ID = CU.CUSTOMER_ID
JOIN INVOICE_LINE AS IVL ON IVL.INVOICE_ID = IV.INVOICE_ID
JOIN TRACK AS TR ON TR.TRACK_ID = IVL.TRACK_ID
JOIN GENRE AS GE ON GE.GENRE_ID = TR.GENRE_ID
WHERE GE.NAME LIKE 'Rock'
ORDER BY EMAIL;


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT AR.NAME,
	COUNT(AR.ARTIST_ID) AS NO_OF_SONGS
FROM ARTIST AS AR
JOIN ALBUM AS ALB ON ALB.ARTIST_ID = AR.ARTIST_ID
JOIN TRACK AS TR ON TR.ALBUM_ID = ALB.ALBUM_ID
JOIN GENRE AS GNR ON GNR.GENRE_ID = TR.GENRE_ID
WHERE GNR.NAME LIKE 'Rock'
GROUP BY AR.ARTIST_ID
ORDER BY NO_OF_SONGS DESC
LIMIT 10


/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT NAME,
	MILISECONDS
FROM TRACK
WHERE MILISECONDS >
		(SELECT AVG(MILISECONDS) AS AVG_TRACK_LENGTH
			FROM TRACK)
ORDER BY MILISECONDS DESC;


/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

WITH BEST_SELLING_ARTIST AS
	(SELECT AR.ARTIST_ID AS ARTIST_ID,
			AR.NAME AS ARTIST_NAME,
			SUM(IVL.UNIT_PRICE * IVL.QUANTITY) AS TOTAL_SALES
		FROM INVOICE_LINE AS IVL
		JOIN TRACK AS TR ON TR.TRACK_ID = IVL.TRACK_ID
		JOIN ALBUM AS ABL ON ABL.ALBUM_ID = TR.ALBUM_ID
		JOIN ARTIST AS AR ON AR.ARTIST_ID = ABL.ARTIST_ID
		GROUP BY AR.ARTIST_ID
		ORDER BY TOTAL_SALES DESC
		LIMIT 1)
SELECT CU.CUSTOMER_ID,
	CU.FIRST_NAME,
	CU.LAST_NAME,
	BSA.ARTIST_NAME,
	SUM(IVL.UNIT_PRICE * IVL.QUANTITY) AS AMOUNT_SPENT
FROM INVOICE IV
JOIN CUSTOMER AS CU ON CU.CUSTOMER_ID = IV.CUSTOMER_ID
JOIN INVOICE_LINE AS IVL ON IVL.INVOICE_ID = IV.INVOICE_ID
JOIN TRACK AS TR ON TR.TRACK_ID = IVL.TRACK_ID
JOIN ALBUM AS ALB ON ALB.ALBUM_ID = TR.ALBUM_ID
JOIN BEST_SELLING_ARTIST BSA ON BSA.ARTIST_ID = ALB.ARTIST_ID
GROUP BY CU.CUSTOMER_ID,
	CU.FIRST_NAME,
	CU.LAST_NAME,
	BSA.ARTIST_NAME
ORDER BY 5 DESC;


/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH POPULAR_GENRE AS
	(SELECT COUNT(IVL.QUANTITY) AS PURCHASES,
			CU.COUNTRY,
			GNR.NAME,
			GNR.GENRE_ID,
			ROW_NUMBER() OVER(PARTITION BY CU.COUNTRY ORDER BY COUNT(IVL.QUANTITY) DESC) AS ROWNO
		FROM INVOICE_LINE AS IVL
		JOIN INVOICE AS IV ON IV.INVOICE_ID = IVL.INVOICE_ID
		JOIN CUSTOMER AS CU ON CU.CUSTOMER_ID = IV.CUSTOMER_ID
		JOIN TRACK AS TR ON TR.TRACK_ID = IVL.TRACK_ID
		JOIN GENRE AS GNR ON GNR.GENRE_ID = TR.GENRE_ID
		GROUP BY CU.COUNTRY,
			GNR.NAME,
			GNR.GENRE_ID
		ORDER BY CU.COUNTRY ASC, PURCHASES DESC)
SELECT *
FROM POPULAR_GENRE
WHERE ROWNO <= 1


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH CUSTOMTER_WITH_COUNTRY AS
	(SELECT CU.CUSTOMER_ID,
			FIRST_NAME,
			LAST_NAME,
			BILLING_COUNTRY,
			SUM(TOTAL) AS TOTAL_SPENDING,
			ROW_NUMBER() OVER(PARTITION BY BILLING_COUNTRY ORDER BY SUM(TOTAL) DESC) AS ROWNO
		FROM INVOICE AS IV
		JOIN CUSTOMER AS CU ON CU.CUSTOMER_ID = IV.CUSTOMER_ID
		GROUP BY CU.CUSTOMER_ID,
			FIRST_NAME,
			LAST_NAME,
			BILLING_COUNTRY,
		ORDER BY BILLING_COUNTRY ASC,TOTAL_SPENDING DESC)
SELECT *
FROM CUSTOMTER_WITH_COUNTRY
WHERE ROWNO <= 1

/* Thank You :) */