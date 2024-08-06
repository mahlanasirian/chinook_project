-- 1) 10آهنگ برتر که بیشترین درامد رو داشتن به همراه درامد ایجاد  شده
-- 1)The top 10 songs with the highest income have been created along with the income


SELECT t.Name AS TrackName, 
SUM(il.UnitPrice * il.Quantity) AS TotalRevenue 
FROM  invoiceline il
JOIN track t ON il.TrackId = t.TrackId
GROUP BY  t.TrackId
ORDER BY  TotalRevenue DESC
LIMIT 10;

################################################################################
-- 2) محبوب ترین ژانر، به تر تیب از نظر تعداد آهنگهای فروخته شده و کل درامد
-- 2)The most popular genre, the best in terms of number of songs sold and total revenue
SELECT g.Name AS GenreName,
COUNT(il.InvoiceLineId) AS TotalTracksSold,
SUM(il.UnitPrice * il.Quantity) AS TotalRevenue
FROM invoiceline il
JOIN track t ON il.TrackId = t.TrackId
JOIN genre g ON t.GenreId = g.GenreId
GROUP BY g.GenreId
ORDER BY TotalRevenue DESC, TotalTracksSold DESC;
################################################################################
-- 3) کاربرانی که تا حاال خرید نداشتند
-- 3) Users who have not purchased yet
-- تعداد کل مشتریان و تعداد مشتریانی که خرید کرده‌اند
SELECT
    (SELECT COUNT(*) FROM customer) AS TotalCustomers,
    (SELECT COUNT(DISTINCT CustomerId) FROM invoice) AS CustomersWithPurchase;

-- بررسی نهایی برای اطمینان از خرید تمام مشتریان
SELECT 
    CASE
WHEN (SELECT COUNT(*) FROM customer) = (SELECT COUNT(DISTINCT CustomerId) FROM invoice) 
THEN 'All customers have made a purchase'
	ELSE 'Some customers have not made a purchase'
    END AS PurchaseCheck;
###############################################################################
-- 4) میانگین زمان آهنگ ها در در هر آلبوم
-- 4) Average time of songs in per album

SELECT a.AlbumId, a.Title AS AlbumTitle,
ROUND(AVG(t.Milliseconds), 2) AS Avg_Track
FROM album a
JOIN track t ON a.AlbumId = t.AlbumId
GROUP BY a.AlbumId, a.Title
ORDER BY a.AlbumId;
###############################################################################
-- 5)  کارمندی که بیشترین تعداد فروش را داشته
-- 5) The employee who had the most sales

SELECT e.EmployeeId,e.FirstName,e.LastName,
      COUNT(i.InvoiceId) AS TotalSales
FROM  employee e
JOIN customer c ON e.EmployeeId = c.SupportRepId
JOIN invoice i ON c.CustomerId = i.CustomerId
GROUP BY e.EmployeeId, e.FirstName, e.LastName
ORDER BY TotalSales DESC
LIMIT 1;
#############################################################################
-- 6) کاربرانی که از بیش از یک ژانر خرید کردند 
-- 6) Users who purchased from more than one genre

SELECT c.CustomerId, c.FirstName, c.LastName,
COUNT(DISTINCT g.GenreId) AS GenreCount
FROM customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY c.CustomerId, c.FirstName, c.LastName
HAVING COUNT(DISTINCT g.GenreId) > 1;
#############################################################################
-- 7) سه آهنگ برتر از نظر درامد فروش برای هر ژانر
-- 7) Top three grossing songs for each genre

SELECT g.Name AS GenreName,t.TrackId,t.Name AS TrackName,
SUM(il.UnitPrice * il.Quantity) AS TotalSales
FROM  genre g
JOIN  track t ON g.GenreId = t.GenreId
JOIN  invoiceline il ON t.TrackId = il.TrackId
GROUP BY  g.GenreId, t.TrackId
ORDER BY  g.GenreId, TotalSales DESC
LIMIT 3;
############################################################################
-- 8) تعداد آهنگهای فروخته شده به صورت تجمعی در هر سال به صورت جداگانه
-- 8) Cumulative number of songs sold each year individually
SELECT YEAR(i.InvoiceDate) AS SaleYear,
SUM(il.Quantity) AS Total_Tracks_Sold,
SUM(SUM(il.Quantity)) OVER (ORDER BY YEAR(i.InvoiceDate)) AS Cumulative_Total
FROM   invoice i
JOIN   invoiceline il ON i.InvoiceId = il.InvoiceId
GROUP BY YEAR(i.InvoiceDate)
ORDER BY   SaleYear;
############################################################################
-- 9)  کاربرانی که مجموع خریدشان باالتر از میانگین مجموع خرید تمام کاربران است
-- 9) Users whose purchase total is higher than the average total purchase of all users

SELECT c.CustomerId, c.FirstName, c.LastName,
SUM(il.UnitPrice * il.Quantity) AS TotalPurchase
FROM customer c
JOIN invoice i ON c.CustomerId = i.CustomerId
JOIN invoiceline il ON i.InvoiceId = il.InvoiceId
GROUP BY c.CustomerId

HAVING
    SUM(il.UnitPrice * il.Quantity) > (
        SELECT
            AVG(TotalPurchase)
        FROM (
            SELECT
                SUM(il.UnitPrice * il.Quantity) AS TotalPurchase
            FROM
                invoice i
            JOIN
                invoiceline il ON i.InvoiceId = il.InvoiceId
            GROUP BY
                i.CustomerId
        ) AS CustomerAverages
)
ORDER BY
    TotalPurchase DESC;
##########################################################################

