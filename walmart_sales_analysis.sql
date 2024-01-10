CREATE DATABASE IF NOT EXISTS salesDataWalmart;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) not null,
    product_line VARCHAR(100) not null,
    unit_proce DECIMAL(10,2) not null,
    quantity INT not null,
    VAT FLOAT(6,4) not null,
    total DECIMAL(12,4) not null,
    date DATETIME not null,
    time TIME not null,
    payment_method VARCHAR(15) not null,
    cogs DECIMAL(10,2) not null ,/*cost of goods sold*/
    gross_margin_pct float(11,9),
    gross_income decimal(12,4) not null,
    rating float(2,1)
    );
    
    
    
    
   
  /*FEATURE ENGINEERING--------------------------*/
    
	/*time_of_day---- this tells us which time of the day is the sale done like morning,afternoon or in the evening*/
    
SELECT
		time,
       CASE
			WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
            WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
            ELSE 'Evening'
		END AS time_of_day
FROM sales;

ALTER TABLE sales
ADD COLUMN time_of_day VARCHAR(20);

/* insert data into the column*/
UPDATE sales
set time_of_day=(CASE
			WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
            WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
            ELSE 'Evening'
		END);
    
/* day finding, which week of the day the sale has happened*/
select date, DAYNAME(date) from sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(20);
UPDATE sales
SET day_name=DAYNAME(date);

/*   MONTH NAME  */

select date, MONTHNAME(date) from sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(20);
UPDATE sales
SET month_name=MONTHNAME(date);

-----------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

/* 1. How many unique cities does the data have?*/

select distinct city from sales;

/* In which city is each branch...so how many branches*/
select distinct branch from sales;

select distinct city,branch from sales; 

/* how many unique product lines does the data have*/
select distinct product_line from sales;

/* what is the most common payment method*/
select count(invoice_id) as cnt, payment_method from sales
group by payment_method
order by count(invoice_id) desc;

/* what is the most selling product_line*/
select product_line, count(product_line) as cnt
 from sales
 group by product_line
 order by cnt desc;

/*what is the total revenue by month*/
select sum(total) as total_income,month_name from sales
group by month_name;

/* what month had the largest cogs*/
select month_name, sum(cogs) as cogs_total from sales group by month_name;

/*  What product line has the largest revenue*/
select product_line, sum(total) as total_revenue
from sales
group by product_line
order by total_revenue desc;

/*what city has the largest revenue */
select branch,city, sum(total) as total_revenue
from sales
group by branch,city
order by total_revenue desc;

/*what product line has the largest vat */
select product_line, avg(VAT) as avg_tax
from sales
group by product_line
order by avg_tax desc;

/* Fetach each product line and add a column to those product line showing "Good","bad". good it is is greater 
than the avg sales */
select product_line,
	CASE
		WHEN sum(total)> (select avg(total) from sales) then "Good"
        ELSE "Bad"
	END AS performance
from sales
group by product_line;
    
/* which branch sold more products than the average products sold*/
select branch, sum(quantity) as qty
from sales
group by branch
having qty>(select avg(quantity) from sales);

/*what is the most common product line by gender */
select gender, product_line, count(gender) as total_cnt
from sales
group by gender, product_line
order by total_cnt desc;

/*what is the average rating of each product line*/
select product_line,avg(rating) as average
from sales
group by product_line;

/*Number of sales made in each time of the day per weekday*/
select  time_of_day,count(*) from sales
group by time_of_day;

/*which type of cutomer types bring the most revenue*/
select customer_type, sum(total) as total_rev from sales
group by customer_type
order by total_rev desc;

/*which city has the largest tax percent VAT*/
select city,avg(VAT) as vp from sales
group by city
order by vp desc;
/*which customer type pays the most in VAT*/
select customer_type,avg(VAT) as vp from sales
group by customer_type
order by vp desc;

-------------------------------customers---------------------
/*what is the most common cutomer type*/
select customer_type,count(*) cust_count from sales
group by customer_type
order by cust_count desc;

/*what customer type buys the most*/
select customer_type,sum(total) cust_sales from sales
group by customer_type
order by cust_sales desc;

/*what is the gender of the most customers*/

select gender,count(*) as gender_count
from sales
group by gender;

/*what is the gender distribution per branch*/
select gender,count(*) as gender_count
from sales
where branch='A'
group by gender;

/*what time of the day do customers give most ratings*/
select time_of_day, avg(rating) as avg_rating
from sales
group by time_of_day
order by avg_rating desc;

/*what time of the day do customers give most ratings per branch*/
select time_of_day, avg(rating) as avg_rating
from sales
where branch='B'
group by time_of_day
order by avg_rating desc;

/*which day for the week has the best avg rating */
select day_name, avg(rating) as avg_rating from sales
group by day_name
order by avg_rating desc;

/*which day of the week has the best average ratings per branch*/
select day_name, avg(rating) as avg_rating from sales
where branch='C'
group by day_name
order by avg_rating desc;

