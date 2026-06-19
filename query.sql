-- робимо таблиці
-- CREATE DATABASE PA01;
-- Дані в таблицях були згенеровані завдяки сервісу  https://fabricate.tonic.ai/

-- створюємо таблицю абонементів
CREATE TABLE membership_plans
(
    plan_id         SERIAL PRIMARY KEY,
    plan_name       VARCHAR(100),
    description     TEXT,
    monthly_price   DECIMAL(10, 2),
    duration_months INT,
    created_at      TIMESTAMP
);

--створюємо таблицю в якій будуть лежати тренера
CREATE TABLE trainers
(
    trainer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name  VARCHAR(100),
    email      VARCHAR(150),
    phone      VARCHAR(50),
    specialty  VARCHAR(100),
    hire_date  DATE
);

-- робмо таблицю клієнтів
CREATE TABLE members
(
    member_id     SERIAL PRIMARY KEY,
    plan_id       INT REFERENCES membership_plans (plan_id),
    first_name    VARCHAR(100),
    last_name     VARCHAR(100),
    email         VARCHAR(150),
    phone         VARCHAR(50),
    date_of_birth DATE,
    gender        VARCHAR(20),
    city          VARCHAR(100),
    state         VARCHAR(50),
    postal_code   VARCHAR(20),
    join_date     DATE
);

-- робимо таблицю розкладу всяких занять
CREATE TABLE classes
(
    class_id         SERIAL PRIMARY KEY,
    trainer_id       INT REFERENCES trainers (trainer_id),
    class_name       VARCHAR(100),
    class_type       VARCHAR(100),
    capacity         INT,
    scheduled_at     TIMESTAMP,
    duration_minutes INT
);

-- створюємо таблицю з бронюваннями через яку будемо зв'язувати інші табоиці
CREATE TABLE bookings
(
    booking_id   SERIAL PRIMARY KEY,
    member_id    INT REFERENCES members (member_id),
    class_id     INT REFERENCES classes (class_id),
    booking_date TIMESTAMP,
    status       VARCHAR(50),
    attended     BOOLEAN
);

SELECT COUNT(*)
FROM bookings;

--explain analyze
--Planning Time: 0.679 ms
--Execution Time: 0.838 ms

SELECT
--         bookings.booking_id,
--        members.first_name,
--        members.last_name,
--        classes.class_name,
--        classes.trainer_id,
--        trainers.trainer_id, в ході розмислення вирішив групнути за тренерськими фаміліями та іменами,спочатку виводило ці дані
trainers.first_name,
trainers.last_name,
COUNT(bookings.booking_id) AS total_visited_classes
FROM bookings -- joinнимо таблиці іннер джоіном
    -- так як я вирішив рахувати саме атендед заняття то беремо дані з букінгу, це така таблиця в якій є майже всі спільні дані
         JOIN members ON bookings.member_id = members.member_id
    -- буукінг і мембери повязані за мембер айді
         JOIN classes ON bookings.class_id = classes.class_id
    -- по клас айді пов'язані
         JOIN trainers ON classes.trainer_id = trainers.trainer_id
    -- по трейнер айді  але тут беремо не з букінгу, а з таблиці занять щоб подивитись який саме тренер веде яке завдання
    -- також завдяки цьому можна буде зробити груп бай
         JOIN membership_plans ON members.plan_id = membership_plans.plan_id
    -- ну тут до таблиці клієнтів під'єднуємо мемберщіп плани
WHERE bookings.attended = true --   вирішив виводити лише ті записи,які відвідали
GROUP BY trainers.last_name, trainers.first_name --групаєм за імя фамілія
ORDER BY total_visited_classes DESC; -- сортуємо тренерів за к-стю виконаних занять

-- чистий селект без коментарів
SELECT
trainers.first_name,
trainers.last_name,
COUNT(bookings.booking_id) AS total_visited_classes
FROM bookings
    JOIN members ON bookings.member_id = members.member_id
         JOIN classes ON bookings.class_id = classes.class_id
         JOIN trainers ON classes.trainer_id = trainers.trainer_id
         JOIN membership_plans ON members.plan_id = membership_plans.plan_id
WHERE bookings.attended = true
GROUP BY trainers.last_name, trainers.first_name
ORDER BY total_visited_classes DESC;