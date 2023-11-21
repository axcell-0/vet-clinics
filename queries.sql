SELECT * FROM animals WHERE name LIKE '%mon';

SELECT name FROM animals WHERE date_of_birth BETWEEN '2016-01-01' AND '2019-12-31';

SELECT name FROM animals WHERE neutered = TRUE AND escape_attempts < 3;

SELECT date_of_birth FROM animals WHERE name IN ('Agumon', 'Pikachu');

SELECT name, escape_attempts FROM animals WHERE weight_kg > 10.5;

SELECT * FROM animals WHERE neutered = TRUE;

SELECT * FROM animals WHERE name != 'Gabumon';

SELECT * FROM animals WHERE weight_kg BETWEEN 10.4 AND 17.3;

BEGIN;
UPDATE animals SET species = 'Unspecified';
SELECT * FROM animals;
ROLLBACK;

START TRANSACTION;
UPDATE animals SET species = 'digimon' WHERE name LIKE '%mon';
UPDATE animals SET species = 'pokemon' WHERE species IS NULL;
SELECT * FROM animals;
COMMIT;
SELECT * FROM animals;

START TRANSACTION;
DELETE FROM animals;
ROLLBACK;
SELECT * FROM animals;

START TRANSACTION;
DELETE FROM animals WHERE date_of_birth > '2022-01-01';
SAVEPOINT weight_update_savepoint;
UPDATE animals SET weight_kg = weight_kg * -1;
ROLLBACK TO weight_update_savepoint;
UPDATE animals SET weight_kg = weight_kg * -1 WHERE weight_kg < 0;
COMMIT;
SELECT * FROM animals;

SELECT COUNT(*) AS total_animals FROM animals;
SELECT COUNT(*) AS non_escaping_animals FROM animals WHERE escape_attempts = 0;
SELECT AVG(weight_kg) AS average_weight FROM animals;
SELECT neutered, SUM(escape_attempts) AS total_escape_attempts FROM animals GROUP BY neutered;
SELECT species, MIN(weight_kg) AS min_weight, MAX(weight_kg) AS max_weight FROM animals GROUP BY species;
SELECT species, AVG(escape_attempts) AS avg_escape_attempts FROM animals WHERE date_of_birth BETWEEN '1990-01-01' AND '2000-12-31' GROUP BY species;

-- What animals belong to Melody Pond?
SELECT a.name FROM animals a JOIN owners o ON a.owner_id = o.id WHERE o.full_name = 'Melody Pond';

-- List of all animals that are pokemon (their type is Pokemon).
SELECT a.name FROM animals a JOIN species s ON a.species_id = s.id WHERE s.name = 'Pokemon';

-- List all owners and their animals, including those without animals
SELECT o.full_name, COALESCE(array_agg(a.name), '{}'::VARCHAR[]) AS owned_animals FROM owners o LEFT JOIN animals a ON o.id = a.owner_id GROUP BY o.full_name;

-- How many animals are there per species?
SELECT s.name, COUNT(*) AS animal_count FROM species s JOIN animals a ON s.id = a.species_id GROUP BY s.name;

-- List all Digimon owned by Jennifer Orwell.
SELECT a.name FROM animals a JOIN species s ON a.species_id = s.id JOIN owners o ON a.owner_id = o.id WHERE s.name = 'Digimon' AND o.full_name = 'Jennifer Orwell';

-- List all animals owned by Dean Winchester that haven't tried to escape.
SELECT a.name FROM animals a JOIN owners o ON a.owner_id = o.id WHERE o.full_name = 'Dean Winchester' AND a.escape_attempts = 0;

-- Who owns the most animals?
SELECT o.full_name, COUNT(*) AS animal_count FROM owners o JOIN animals a ON o.id = a.owner_id GROUP BY o.full_name ORDER BY animal_count DESC LIMIT 1;

-- Who was the last animal seen by William Tatcher?
SELECT a.name AS last_animal_seen FROM animals a
JOIN visits v ON a.id = v.animal_id JOIN vets vt ON v.vet_id = vt.id
WHERE vt.name = 'William Tatcher' ORDER BY v.date_of_visit DESC LIMIT 1;

-- How many different animals did Stephanie Mendez see?
SELECT COUNT(DISTINCT a.id) AS animals_seen
FROM animals a
JOIN visits v ON a.id = v.animal_id
JOIN vets vt ON v.vet_id = vt.id
WHERE vt.name = 'Stephanie Mendez';

-- List all vets and their specialties, including vets with no specialties.
SELECT v.name, s.name AS specialization
FROM vets v
LEFT JOIN specializations sp ON v.id = sp.vet_id
LEFT JOIN species s ON sp.species_id = s.id;

-- List all animals that visited Stephanie Mendez between April 1st and August 30th, 2020.
SELECT a.name AS visited_animal
FROM animals a
JOIN visits v ON a.id = v.animal_id
JOIN vets vt ON v.vet_id = vt.id
WHERE vt.name = 'Stephanie Mendez'
  AND v.date_of_visit BETWEEN '2020-04-01' AND '2020-08-30';

-- What animal has the most visits to vets?
SELECT a.name AS most_visited_animal, COUNT(v.id) AS visit_count
FROM animals a JOIN visits v ON a.id = v.animal_id
GROUP BY a.id ORDER BY visit_count DESC LIMIT 1;

-- Who was Maisy Smith's first visit?
SELECT a.name AS first_visited_animal, MIN(v.date_of_visit) AS first_visit_date FROM animals a
JOIN visits v ON a.id = v.animal_id JOIN vets vt ON v.vet_id = vt.id JOIN vets ms ON ms.name = 'Maisy Smith'
WHERE vt.id = ms.id GROUP BY a.name ORDER BY first_visit_date LIMIT 1;

-- Details for the most recent visit: animal information, vet information, and date of visit.
SELECT a.name AS animal_name, vt.name AS vet_name, v.date_of_visit FROM animals a
JOIN visits v ON a.id = v.animal_id JOIN vets vt ON v.vet_id = vt.id
ORDER BY v.date_of_visit DESC LIMIT 1;

-- How many visits were with a vet that did not specialize in that animal's species?
SELECT COUNT(*) AS visits_with_unspecialized_vets FROM visits v
JOIN vets vt ON v.vet_id = vt.id JOIN animals a ON v.animal_id = a.id
LEFT JOIN specializations sp ON vt.id = sp.vet_id AND a.species_id = sp.species_id WHERE sp.vet_id IS NULL;

-- What specialty should Maisy Smith consider getting? Look for the species she gets the most.
SELECT s.name AS suggested_specialty, COUNT(*) AS animal_count FROM animals a
JOIN visits v ON a.id = v.animal_id JOIN vets vt ON v.vet_id = vt.id JOIN vets ms ON ms.name = 'Maisy Smith'
JOIN specializations sp ON vt.id = sp.vet_id AND a.species_id = sp.species_id JOIN species s ON sp.species_id = s.id
WHERE ms.id = vt.id GROUP BY s.name ORDER BY animal_count DESC LIMIT 1;