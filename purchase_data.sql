use sql_test;

# Q1 customers 테이블에서 customerID, customerName, Country 만 선택해서 출력

select customerID, customerName, Country
from customers;

#Q2 orders 테이블에서 주문일이 1997년 이후인 데이터 선택 (전체 열 출력)
select *
from orders
where OrderDate>='1997-01-01';



#Q3 customers 테이블 중 country의 고유 갯수 구하기
select count(distinct(country)) as cnt
from customers;

#Q4. customers 테이블 중 country 별 고객 수 구하고, 고객 수 별로 내림차순 정렬
select country,count(*)as cnt
from customers
group by country order by cnt desc;


#Q5. suppliers 테이블에서 국가별 공급자 숫자를 구하고, 그 갯수가 3 이상인 데이터만 선택
-- select * from suppliers; 
select country, count(*) as cnt
from suppliers
group by country having cnt>=3;


# Q6. products 테이블 중 평균가격 이상인 물품을 선택
select * 
from products
where Price>(select avg(price) from products);

#Q7. employees 테이블에서 직원 이름, 생년월일 출력 및 나이 계산하기(만 나이, 한국식 나이 상관없으므로 나이가 다소 차이나도 괜찮음)
select LastName, FirstName, BirthDate, (extract(year from current_date())-extract(year from BirthDate)) as age
from employees;

#Q8.suppliers 테이블 중 공급자 이름에 ‘ltd’가 들어가는 행 구하기
select *
from suppliers
where suppliername like '%ltd%';

#Q9. customers 테이블에서 고객 국가가 Sweden, Norway, Denmark, Finland인 데이터 선택. 
select * from customers; 
select *
from customers
where country in ('Sweden', 'Norway', 'Denmark', 'Finland');

#Q10. orders, order_details, products, categories 테이블을 결합
select orders.OrderID, orders.customerID, orders.employeeID, orders.orderdate, order_details.ProductID, order_details.Quantity,
products.ProductName,products.Price,categories.categoryName,categories.Description
from orders
inner join order_details as order_details
on orders.OrderID = order_details.OrderID
inner join products as products
on order_details.ProductID = products.ProductID
inner join categories as categories
on products.CategoryID = categories.CategoryID
order by OrderID, ProductID;

#Q11. suppliers 테이블에서 국가, 도시 별 공급자 갯수 및 합계와 소계 구하기
select country, city, count(*) as cnt
from suppliers
group by country,city with rollup;

#Q12. orderID 별 주문 금액의 합계를 구하고, orderID 별로 정렬하기
select order_details.orderID, sum(order_details.Quantity*Price) as price
from order_details
inner join products as products
on order_details.ProductID = products.ProductID group by orderID order by orderID;

#Q13. 매 월 별, 주문 금액에 대한 국가별 순위(내림차순) 계산. 그 후 년도, 월, 순위 순으로 정렬하며, NULL은 제외 (★)
select customers.country, extract(year from orders.orderdate) as y, 
extract(month from orders.orderdate) as m, 
sum(products.price*order_details.quantity) as sum, 
rank() over (partition by extract(month from orders.orderdate)
order by sum(products.price*order_details.quantity) desc) as rnk
from customers
inner join orders as orders
on customers.customerID = orders.customerID
inner join order_details as order_details
on orders.orderID=order_details.orderID
inner join products as products
on order_details.ProductID = products.productid
group by country, y, m order by y, m, rnk;
