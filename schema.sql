CREATE TABLE animals (
    id serial PRIMARY KEY,
    name VARCHAR(100),
    date_of_birth DATE,
    escape_attempts INTEGER,
    neutered BOOLEAN,
    weight_kg DECIMAL(5, 2));

ALTER TABLE animals
    ADD COLUMN species VARCHAR(255);