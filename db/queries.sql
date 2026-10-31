-- =====================================================
-- db/queries.sql — SQL-запросы для приложения (пара 11)
-- Знак ? — параметр, подставляется из C#-кода.
-- =====================================================


-- -----------------------------------------------------
-- Этап 4. Вход в приложение
-- Чек-лист: 2.5, 2.6, 3.17
-- Пустой результат = неверный логин/пароль;
-- иначе берём full_name и role для отображения после входа.
-- -----------------------------------------------------
SELECT u.id, u.full_name, r.name AS role
FROM users u
JOIN roles r ON r.id = u.role_id
WHERE u.login = ? AND u.password = ?;


-- -----------------------------------------------------
-- Этап 5. Каталог товаров (окна Гостя и Администратора)
-- Чек-лист: 2.7–2.11
-- -----------------------------------------------------
SELECT p.id, p.article, p.name, p.unit, p.price, p.discount, p.stock_qty,
       p.description, p.photo,
       c.name AS category, m.name AS manufacturer, s.name AS supplier
FROM products p
JOIN categories c ON c.id = p.category_id
JOIN manufacturers m ON m.id = p.manufacturer_id
JOIN suppliers s ON s.id = p.supplier_id;


-- -----------------------------------------------------
-- Этап 6. Поиск + фильтр по поставщику + сортировка по остатку
-- Чек-лист: 3.2–3.3 (сортировка), 3.4–3.5 (фильтр), 3.6 (всё вместе)
-- -----------------------------------------------------

-- 6.1 Всё вместе (3.6)
SELECT p.id, p.article, p.name, p.unit, p.price, p.discount, p.stock_qty,
       p.description, p.photo,
       c.name AS category, m.name AS manufacturer, s.name AS supplier
FROM products p
JOIN categories c ON c.id = p.category_id
JOIN manufacturers m ON m.id = p.manufacturer_id
JOIN suppliers s ON s.id = p.supplier_id
WHERE p.name LIKE CONCAT('%', ?, '%')
  AND p.supplier_id = ?
ORDER BY p.stock_qty DESC;

-- 6.2 Только сортировка (3.2–3.3): ASC / DESC подставляется в коде
SELECT p.id, p.article, p.name, p.price, p.stock_qty, s.name AS supplier
FROM products p
JOIN suppliers s ON s.id = p.supplier_id
ORDER BY p.stock_qty ASC;   -- или DESC

-- 6.3 Только фильтр по поставщику (3.4–3.5)
SELECT p.id, p.article, p.name, p.price, p.stock_qty, s.name AS supplier
FROM products p
JOIN suppliers s ON s.id = p.supplier_id
WHERE p.supplier_id = ?;

-- 6.4 Только поиск по названию
SELECT p.id, p.article, p.name, p.price, p.stock_qty, s.name AS supplier
FROM products p
JOIN suppliers s ON s.id = p.supplier_id
WHERE p.name LIKE CONCAT('%', ?, '%');


-- -----------------------------------------------------
-- Этап 7. Добавление и редактирование товара
-- Чек-лист: 3.7, 3.10, 3.12, 3.19
-- -----------------------------------------------------

-- справочники для выпадающих списков в форме
SELECT id, name FROM categories;
SELECT id, name FROM manufacturers;
SELECT id, name FROM suppliers;

-- добавление товара
INSERT INTO products
  (article, name, unit, price, discount, stock_qty, description, photo,
   category_id, manufacturer_id, supplier_id)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);

-- открыть товар для редактирования — заполнить все поля сразу
SELECT * FROM products WHERE id = ?;

-- сохранить изменения
UPDATE products
SET article=?, name=?, unit=?, price=?, discount=?, stock_qty=?,
    description=?, photo=?,
    category_id=?, manufacturer_id=?, supplier_id=?
WHERE id = ?;


-- -----------------------------------------------------
-- Этап 8. Защита от удаления купленного товара
-- Чек-лист: 3.16
-- Сначала проверка (чтобы показать понятное предупреждение),
-- затем удаление. Если товар есть в заказах, БД откажет:
-- Error 1451: Cannot delete or update a parent row: a foreign key constraint fails
-- -----------------------------------------------------
SELECT COUNT(*) AS used_in_orders FROM prodorders WHERE product_id = ?;

DELETE FROM products WHERE id = ?;
