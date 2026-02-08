-- Создание таблиц

CREATE TABLE products (
    product_id INT,
    product_name VARCHAR(50),
    category VARCHAR(50),
    price INT
);

CREATE TABLE sales (
    sale_id INT,
    product_id INT,
    quantity INT,
    sale_date DATE
);

INSERT INTO products VALUES
(1, 'Apple', 'Fruit', 30),
(2, 'Banana', 'Fruit', 20),
(3, 'Orange', 'Fruit', 50),
(4, 'Mango', 'Fruit', 70),
(5, 'Milk', 'Dairy', 40);

INSERT INTO sales VALUES
(1, 1, 2, '2024-01-01'),
(2, 1, 1, '2024-01-02'),
(3, 2, 5, '2024-01-02'),
(4, 3, 1, '2024-01-03'),
(5, 3, 4, '2024-01-04'),
(6, 4, 6, '2024-01-05'),
(7, NULL, 3, '2024-01-06'),
(8, 99, 2, '2024-01-06');

-- Шаг 1. Выручка по товарам

SELECT p.product_name, SUM (p.price*s.quantity) AS revenue
FROM products p
LEFT JOIN sales s
ON p.product_id = s.product_id
GROUP BY p.product_name;

-- Результаты:
-- Apple — имеет стабильную выручку за счёт нескольких продаж в разные дни
-- Banana — показывает хорошую выручку благодаря большому объёму продаж (quantity = 5)
-- Orange — высокая выручка обусловлена сочетанием цены и количества продаж
-- Mango — самый высокий показатель выручки, за счёт высокой цены и большого количества продаж
-- Milk — выручка отсутствует, так как по данному товару нет записей о продажах

--Шаг 2. Товары с выручкой выше средней

WITH revenue_by_product AS (
SELECT p.product_name, SUM(p.price*s.quantity) AS revenue
FROM products p
LEFT JOIN sales s
ON p.product_id = s.product_id
GROUP BY p.product_name),
avg_revenue AS (SELECT AVG(revenue) AS avg_rev
FROM revenue_by_product)
SELECT r.product_name, r.revenue
FROM revenue_by_product r
JOIN avg_revenue a
ON r.revenue > a.avg_rev;

-- Комментарии:
-- Mango и Orange имеют выручку выше среднего уровня
-- Эти товары являются ключевыми источниками дохода
-- Остальные товары приносят выручку ниже среднего и могут требовать анализа ассортимента или цен

--Шаг 3. Выручка по категориям товаров

SELECT p.category, SUM (p.price*s.quantity) AS category_revenue
FROM products p 
LEFT JOIN sales s
ON p.product_id = s.product_id
GROUP BY p.category;

-- Комментарии:
-- Категория Fruit является основной по объёму выручки
-- Категория Dairy не имеет продаж за анализируемый период
-- Бизнесу стоит обратить внимание на развитие категории Fruit
-- Категория Dairy может требовать дополнительных маркетинговых действий

--Шаг 4.1 Продажи без указания товара (NULL product_id)

SELECT 
sale_id,
product_id,
quantity,
sale_date
FROM sales
WHERE product_id IS NULL;

-- Комментарии:
-- Обнаружены продажи без указания product_id
-- Такие записи невозможно связать со справочником товаров
-- Данные продажи не учитываются в расчётах выручки
-- Требуется проверка источника данных или логики загрузки

ШАГ 4.2 Продажи с product_id, отсутствующими в справочнике товаров

SELECT 
s.sale_id,
s.product_id,
s.quantity,
s.sale_date
FROM sales s
LEFT JOIN products p
ON s.product_id = p.product_id
WHERE p.product_id IS NULL
AND s.product_id IS NOT NULL;

-- Комментарии:
-- Найдены продажи с product_id, отсутствующими в таблице products
-- Это указывает на несогласованность справочников
-- Такие продажи искажают финансовую аналитику
-- Необходимо либо добавить товары в справочник, либо исправить данные продаж