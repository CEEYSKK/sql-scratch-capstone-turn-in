/* SLIDE 1.1, provides a distinct list of each utm_campaign and each one's related utm_source */

SELECT DISTINCT utm_campaign,
	utm_source
FROM page_visits;

--

/* SLIDE 1.2, provides a distinct list of all page_names */

SELECT DISTINCT page_name
FROM page_visits;

--

/* SLIDE 2.1, Query a list of number of first touches by utm_campaign. */

WITH first_touch AS (
    SELECT user_id,
        MIN(timestamp) as first_touch_at
    FROM page_visits
    GROUP BY user_id),
ft_attr AS (
    SELECT ft.user_id,
         ft.first_touch_at,
         pv.utm_source,
         pv.utm_campaign
    FROM first_touch ft
    JOIN page_visits pv
      ON ft.user_id = pv.user_id
      AND ft.first_touch_at = pv.timestamp
)
SELECT ft_attr.utm_source,
       ft_attr.utm_campaign,
       COUNT(*)
FROM ft_attr
GROUP BY 1, 2
ORDER BY 3 DESC;


/* also on SLIDE 2.1, I slightly modified the query to get the number for "Total First Touches" */

SELECT SUM(number_of_ft)
FROM(
WITH first_touch AS (
    SELECT user_id,
        MIN(timestamp) as first_touch_at
    FROM page_visits
    GROUP BY user_id),
ft_attr AS (
    SELECT ft.user_id,
         ft.first_touch_at,
         pv.utm_source,
         pv.utm_campaign
    FROM first_touch ft
    JOIN page_visits pv
      ON ft.user_id = pv.user_id
      AND ft.first_touch_at = pv.timestamp
)
SELECT ft_attr.utm_source,
       ft_attr.utm_campaign,
       COUNT(*) AS number_of_ft
FROM ft_attr
GROUP BY 1, 2
ORDER BY 3 DESC);

--

/* SLIDE 2.2, virtually the same as the query used in 2.1, but modified for MAX(timestamp) to generate last touch info*/

WITH last_touch AS (
    SELECT user_id,
        MAX(timestamp) as last_touch_at
    FROM page_visits
    GROUP BY user_id),
lt_attr AS (
    SELECT lt.user_id,
         lt.last_touch_at,
         pv.utm_source,
         pv.utm_campaign,
         pv.page_name
    FROM last_touch lt
    JOIN page_visits pv
      ON lt.user_id = pv.user_id
      AND lt.last_touch_at = pv.timestamp
)
SELECT lt_attr.utm_source,
       lt_attr.utm_campaign,
       COUNT(*) AS number_of_lt
FROM lt_attr
GROUP BY 1, 2
ORDER BY 3 DESC;


/* also SLIDE 2.2, to double check that my numbers were correct, I used a similar query for the SUM of the numbers to make sure they matched
the SUM in the query from 2.1*/

SELECT SUM(number_of_lt)
FROM(
WITH last_touch AS (
    SELECT user_id,
        MAX(timestamp) as last_touch_at
    FROM page_visits
    GROUP BY user_id),
lt_attr AS (
    SELECT lt.user_id,
         lt.last_touch_at,
         pv.utm_source,
         pv.utm_campaign,
         pv.page_name
    FROM last_touch lt
    JOIN page_visits pv
      ON lt.user_id = pv.user_id
      AND lt.last_touch_at = pv.timestamp
)
SELECT lt_attr.utm_source,
       lt_attr.utm_campaign,
       COUNT(*) AS number_of_lt
FROM lt_attr
GROUP BY 1, 2
ORDER BY 3 DESC);

--

/*SLIDE 2.3- to determine the total number of purchases made */

SELECT COUNT(distinct user_id)
FROM page_visits
WHERE page_name = '4 - purchase';

/*SLIDE 2.3- to determine the total number of last touches on the purchase page each campaign was responsible for*/

WITH last_touch AS (
    SELECT user_id,
        MAX(timestamp) as last_touch_at
    FROM page_visits
    WHERE page_name = '4 - purchase'
    GROUP BY user_id),
lt_attr AS (
    SELECT lt.user_id,
         lt.last_touch_at,
         pv.utm_source,
         pv.utm_campaign,
         pv.page_name
    FROM last_touch lt
    JOIN page_visits pv
      ON lt.user_id = pv.user_id
      AND lt.last_touch_at = pv.timestamp
)
SELECT lt_attr.utm_source,
       lt_attr.utm_campaign,
       COUNT(*) AS purchases
FROM lt_attr
GROUP BY 1, 2
ORDER BY 3 DESC;

--

/*SLIDE 2.4 - Determines how many purchases resulted from different First Touch and Last Touch Campaigns (336)*/

SELECT COUNT(*)
FROM(
WITH last_touch AS (
    SELECT user_id,
  	page_name,
  	utm_campaign as last_touch_campaign,
        MAX(timestamp) as last_touch_at
    FROM page_visits
    WHERE page_name = '4 - purchase'
    GROUP BY user_id),
first_touch AS (
    SELECT user_id,
  	page_name,
	MIN(timestamp) as first_touch_at,
  	utm_campaign as first_touch_campaign
    FROM page_visits
    GROUP BY user_id)
SELECT ft.first_touch_campaign,
       lt.last_touch_campaign
  FROM last_touch lt
  JOIN first_touch ft
    ON lt.user_id = ft.user_id
    WHERE lt.last_touch_campaign NOT like ft.first_touch_campaign
ORDER BY ft.first_touch_campaign, lt.last_touch_campaign);

--

/*SLIDE 2.4.1-2.4.4  - lists all combinations of First Touch Campaign and Last Touch Campaign that resulted in a purchase */

WITH last_touch AS (
    SELECT user_id,
  	page_name,
  	utm_campaign as last_touch_campaign,
        MAX(timestamp) as last_touch_at
    FROM page_visits
    WHERE page_name = '4 - purchase'
    GROUP BY user_id),
first_touch AS (
    SELECT user_id,
  	page_name,
	MIN(timestamp) as first_touch_at,
  	utm_campaign as first_touch_campaign
    FROM page_visits
    GROUP BY user_id)
SELECT first || ' AND ' || last AS combination,
    COUNT(*) AS number
FROM(
    SELECT ft.first_touch_campaign AS first,
         lt.last_touch_campaign AS last
    FROM last_touch lt
    JOIN first_touch ft
      ON lt.user_id = ft.user_id
    ORDER BY ft.first_touch_campaign, lt.last_touch_campaign)
GROUP BY combination
ORDER BY number DESC;


