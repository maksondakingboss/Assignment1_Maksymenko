-- робимо таблиці
-- CREATE DATABASE PA01;
-- Дані в таблицях були згенеровані завдяки сервісу  https://fabricate.tonic.ai/
CREATE TABLE membership_plans
(
    plan_id         SERIAL PRIMARY KEY,
    plan_name       VARCHAR(100),
    description     TEXT,
    monthly_price   DECIMAL(10, 2),
    duration_months INT,
    created_at      TIMESTAMP
);

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
FROM bookings; -- перевірив чи правильно імпортував файл
SELECT
--         bookings.booking_id,
--        members.first_name,
--        members.last_name,
--        classes.class_name,
--        classes.trainer_id,
--        trainers.trainer_id, вирішив групнути за тренерськими фаміліями та іменами
trainers.first_name,
trainers.last_name,
COUNT(bookings.booking_id) AS total_visited_classes
FROM bookings
         JOIN members ON bookings.member_id = members.member_id
         JOIN classes ON bookings.class_id = classes.class_id
         JOIN trainers ON classes.trainer_id = trainers.trainer_id
         JOIN membership_plans ON members.plan_id = membership_plans.plan_id
WHERE bookings.attended = true -- 200 людей не відвідало
GROUP BY trainers.last_name, trainers.first_name
ORDER BY total_visited_classes DESC;
