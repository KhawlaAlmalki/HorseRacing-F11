const express = require('express');
const mysql = require('mysql2');
const app = express();
const port = 3000;

// Database connection
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'Admin123',
    database: 'RACING'
});

// Middleware
app.use(express.static('public'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Database connection handler
db.connect((err) => {
    if (err) {
        console.log('Database connection failed: ' + err.message);
        return;
    }
    console.log('Connected to MySQL database');
});

// Server startup
app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
});

// Validation helpers
const validateIdFormat = (id, pattern, entity) => {
    if (!pattern.test(id)) {
        return `${entity} ID must be in format "${pattern}"`;
    }
    return null;
};

const validateName = (name, field) => {
    if (!/^[a-zA-Z\s]+$/.test(name)) {
        return `${field} can only contain letters and spaces`;
    }
    if (name.length < 2) {
        return `${field} must be at least 2 characters long`;
    }
    return null;
};

// Database query wrapper
const dbQuery = (query, params, res, successCallback) => {
    db.query(query, params, (err, results) => {
        if (err) {
            console.log('Database error:', err);
            return res.status(500).json({ error: err.message });
        }
        successCallback(results);
    });
};

// RACE ENDPOINTS
app.get('/api/races', (req, res) => {
    dbQuery('SELECT * FROM Race', [], res, (results) => res.json(results));
});

app.post('/api/races', (req, res) => {
    const { raceId, raceName, trackName, raceDate, raceTime } = req.body;

    // Validation
    if (!raceId || !raceName || !trackName || !raceDate) {
        return res.status(400).json({ error: 'All fields except Time are required' });
    }

    const idError = validateIdFormat(raceId, /^[a-zA-Z0-9]+$/, 'Race');
    if (idError) return res.status(400).json({ error: idError });

    if (raceName.length < 2) {
        return res.status(400).json({ error: 'Race Name must be at least 2 characters long' });
    }

    if (!/^\d{4}-\d{2}-\d{2}$/.test(raceDate)) {
        return res.status(400).json({ error: 'Invalid date format. Use YYYY-MM-DD' });
    }

    // Check track exists
    dbQuery('SELECT * FROM Track WHERE trackName = ?', [trackName], res, (trackResults) => {
        if (trackResults.length === 0) {
            return res.status(400).json({ error: `Track "${trackName}" does not exist` });
        }

        // Check race ID uniqueness
        dbQuery('SELECT * FROM Race WHERE raceId = ?', [raceId], res, (raceResults) => {
            if (raceResults.length > 0) {
                return res.status(400).json({ error: `Race ID "${raceId}" already exists` });
            }

            // Insert race
            const query = 'INSERT INTO Race (raceId, raceName, trackName, raceDate, raceTime) VALUES (?, ?, ?, ?, ?)';
            dbQuery(query, [raceId, raceName, trackName, raceDate, raceTime || null], res,
                () => res.json({ message: 'Race added successfully', raceId }));
        });
    });
});

// HORSE ENDPOINTS
app.get('/api/horses', (req, res) => {
    dbQuery('SELECT * FROM Horse', [], res, (results) => res.json(results));
});

app.put('/api/horses/:id/move', (req, res) => {
    const horseId = req.params.id;
    const { newStableId } = req.body;

    // Validation
    const horseIdError = validateIdFormat(horseId, /^horse[0-9]+$/i, 'Horse');
    if (horseIdError) return res.status(400).json({ error: horseIdError });

    const stableIdError = validateIdFormat(newStableId, /^stable[0-9]+$/i, 'Stable');
    if (stableIdError) return res.status(400).json({ error: stableIdError });

    // Check horse exists
    dbQuery('SELECT * FROM Horse WHERE horseId = ?', [horseId], res, (horseResults) => {
        if (horseResults.length === 0) {
            return res.status(404).json({ error: `Horse "${horseId}" not found` });
        }

        const currentStable = horseResults[0].stableId;
        if (currentStable === newStableId) {
            return res.status(400).json({ error: `Horse is already in stable ${newStableId}` });
        }

        // Check stable exists
        dbQuery('SELECT * FROM Stable WHERE stableId = ?', [newStableId], res, (stableResults) => {
            if (stableResults.length === 0) {
                return res.status(404).json({ error: `Stable "${newStableId}" not found` });
            }

            // Update horse stable
            dbQuery('UPDATE Horse SET stableId = ? WHERE horseId = ?', [newStableId, horseId], res,
                () => res.json({ message: `Horse moved from ${currentStable} to ${newStableId} successfully` }));
        });
    });
});

// TRAINER ENDPOINTS
app.get('/api/trainers', (req, res) => {
    dbQuery('SELECT * FROM Trainer', [], res, (results) => res.json(results));
});

app.post('/api/trainers', (req, res) => {
    const { trainerId, fname, lname, stableId } = req.body;

    // Validation
    if (!trainerId || !fname || !lname || !stableId) {
        return res.status(400).json({ error: 'All fields are required' });
    }

    const idError = validateIdFormat(trainerId, /^trainer[0-9]+$/i, 'Trainer');
    if (idError) return res.status(400).json({ error: idError });

    const stableError = validateIdFormat(stableId, /^stable[0-9]+$/i, 'Stable');
    if (stableError) return res.status(400).json({ error: stableError });

    const fnameError = validateName(fname, 'First name');
    if (fnameError) return res.status(400).json({ error: fnameError });

    const lnameError = validateName(lname, 'Last name');
    if (lnameError) return res.status(400).json({ error: lnameError });

    // Check trainer ID uniqueness
    dbQuery('SELECT * FROM Trainer WHERE trainerId = ?', [trainerId], res, (trainerResults) => {
        if (trainerResults.length > 0) {
            return res.status(400).json({ error: `Trainer ID "${trainerId}" already exists` });
        }

        // Check stable exists
        dbQuery('SELECT * FROM Stable WHERE stableId = ?', [stableId], res, (stableResults) => {
            if (stableResults.length === 0) {
                return res.status(404).json({ error: `Stable "${stableId}" not found` });
            }

            // Insert trainer
            const query = 'INSERT INTO Trainer (trainerId, fname, lname, stableId) VALUES (?, ?, ?, ?)';
            dbQuery(query, [trainerId, fname, lname, stableId], res,
                () => res.json({ message: 'Trainer approved successfully', trainerId }));
        });
    });
});

// OWNER ENDPOINTS
app.get('/api/owners', (req, res) => {
    dbQuery('SELECT * FROM Owner', [], res, (results) => res.json(results));
});

app.delete('/api/owners/:id', (req, res) => {
    const ownerId = req.params.id;

    // Check owner exists first
    db.query('SELECT * FROM Owner WHERE ownerId = ?', [ownerId], (err, results) => {
        if (err) {
            console.log('Database error:', err);
            return res.status(500).json({error: 'Database error: ' + err.message});
        }

        if (results.length === 0) {
            return res.status(404).json({error: 'Owner does not exist'});
        }

        // Use the stored procedure instead
        db.query('CALL DeleteOwner(?)', [ownerId], (err, results) => {
            if (err) {
                console.log('Delete owner error:', err);
                return res.status(500).json({error: 'Cannot delete owner: ' + err.message});
            }
            res.json({message: 'Owner and all related records deleted successfully'});
        });
    });
});

// Delete owner with all related information
app.delete('/api/owners/:id', (req, res) => {
    const ownerId = req.params.id;

    // Check owner exists first
    db.query('SELECT * FROM Owner WHERE ownerId = ?', [ownerId], (err, results) => {
        if (err) {
            console.log('Database error:', err);
            return res.status(500).json({error: 'Database error: ' + err.message});
        }

        if (results.length === 0) {
            return res.status(404).json({error: 'Owner does not exist'});
        }

        // Check if owner is also a trainer
        db.query('SELECT * FROM Trainer WHERE trainerId = ?', [ownerId], (err, trainerResults) => {
            if (err) {
                console.log('Trainer check error:', err);
                return res.status(500).json({error: 'Database error checking trainer'});
            }

            if (trainerResults.length > 0) {
                return res.status(400).json({error: 'Cannot delete owner who is also a trainer'});
            }

            // Use the stored procedure
            db.query('CALL DeleteOwner(?)', [ownerId], (err, results) => {
                if (err) {
                    console.log('Delete owner error:', err);
                    if (err.message.includes('Cannot delete owner who is also a trainer')) {
                        return res.status(400).json({error: 'Cannot delete owner who is also a trainer'});
                    }
                    return res.status(500).json({error: 'Cannot delete owner: ' + err.message});
                }
                res.json({message: 'Owner and all exclusively-owned horses deleted successfully'});
            });
        });
    });
});

// Get deleted horses from Old_Info
app.get('/api/old-info', (req, res) => {
    db.query('SELECT * FROM Old_Info ORDER BY deletion_date DESC', (err, results) => {
        if (err) return res.status(500).json({error: err.message});
        res.json(results);
    });
});

// Get deleted horses from Old_Info
app.get('/api/old-info', (req, res) => {
    db.query('SELECT * FROM Old_Info ORDER BY deletion_date DESC', (err, results) => {
        if (err) return res.status(500).json({error: err.message});
        res.json(results);
    });
});

// Delete individual horse (for manual horse deletion)
app.delete('/api/horses/:id', (req, res) => {
    const horseId = req.params.id;

    // Check horse exists first
    db.query('SELECT * FROM Horse WHERE horseId = ?', [horseId], (err, results) => {
        if (err) {
            return res.status(500).json({error: err.message});
        }

        if (results.length === 0) {
            return res.status(404).json({error: 'Horse does not exist'});
        }

        // Delete horse (trigger will automatically backup to Old_Info)
        db.query('DELETE FROM Horse WHERE horseId = ?', [horseId], (err, results) => {
            if (err) return res.status(500).json({error: err.message});
            res.json({message: 'Horse deleted and backed up to Old_Info'});
        });
    });
});

// RACE WITH RESULTS ENDPOINT
app.post('/api/races-with-results', (req, res) => {
    const { race, results } = req.body;

    if (!race || !results) {
        return res.status(400).json({ error: 'Invalid request format. Race and results are required.' });
    }

    const { raceId, raceName, trackName, raceDate, raceTime } = race;

    // Validation
    if (!raceId || !raceName || !trackName || !raceDate) {
        return res.status(400).json({ error: 'All race fields are required' });
    }

    const idError = validateIdFormat(raceId, /^race[0-9]+$/i, 'Race');
    if (idError) return res.status(400).json({ error: idError });

    if (!Array.isArray(results) || results.length === 0) {
        return res.status(400).json({ error: 'At least one race result is required' });
    }

    // Validate results
    for (let i = 0; i < results.length; i++) {
        const result = results[i];
        if (!result.horseId || !result.position) {
            return res.status(400).json({ error: `Result ${i + 1} is missing required fields` });
        }
        if (!/^horse[0-9]+$/i.test(result.horseId)) {
            return res.status(400).json({ error: `Invalid horse ID format: ${result.horseId}` });
        }
        if (result.prize && (result.prize < 0 || result.prize > 10000000)) {
            return res.status(400).json({ error: `Invalid prize amount for horse ${result.horseId}` });
        }
    }

    // Check for duplicate horse IDs
    const horseIds = results.map(r => r.horseId);
    if (horseIds.length !== new Set(horseIds).size) {
        return res.status(400).json({ error: 'Duplicate horse IDs found in the same race' });
    }

    // Transaction for race and results
    db.beginTransaction(err => {
        if (err) {
            console.log('Transaction begin error:', err);
            return res.status(500).json({ error: 'Database transaction error' });
        }

        // Check track exists
        dbQuery('SELECT * FROM Track WHERE trackName = ?', [trackName], res, (trackResults) => {
            if (trackResults.length === 0) {
                return db.rollback(() => res.status(400).json({ error: `Track "${trackName}" not found` }));
            }

            // Check race ID uniqueness
            dbQuery('SELECT * FROM Race WHERE raceId = ?', [raceId], res, (existingRaces) => {
                if (existingRaces.length > 0) {
                    return db.rollback(() => res.status(400).json({ error: `Race ID "${raceId}" already exists` }));
                }

                // Check all horses exist
                const horseChecks = results.map(result =>
                    new Promise((resolve) => {
                        db.query('SELECT * FROM Horse WHERE horseId = ?', [result.horseId], (err, horseResults) => {
                            resolve({ horseId: result.horseId, exists: !err && horseResults.length > 0 });
                        });
                    })
                );

                Promise.all(horseChecks).then(checks => {
                    const missingHorses = checks.filter(check => !check.exists).map(check => check.horseId);
                    if (missingHorses.length > 0) {
                        return db.rollback(() =>
                            res.status(400).json({ error: `Horses not found: ${missingHorses.join(', ')}` }));
                    }

                    // Insert race
                    const raceQuery = 'INSERT INTO Race (raceId, raceName, trackName, raceDate, raceTime) VALUES (?, ?, ?, ?, ?)';
                    db.query(raceQuery, [raceId, raceName, trackName, raceDate, raceTime || null], (err) => {
                        if (err) {
                            return db.rollback(() =>
                                res.status(err.code === 'ER_DUP_ENTRY' ? 400 : 500)
                                    .json({ error: err.code === 'ER_DUP_ENTRY' ? 'Race ID already exists' : 'Database error inserting race' }));
                        }

                        // Insert all results
                        let completed = 0;
                        let hasError = false;

                        results.forEach(result => {
                            const resultQuery = 'INSERT INTO RaceResults (raceId, horseId, results, prize) VALUES (?, ?, ?, ?)';
                            db.query(resultQuery, [raceId, result.horseId, result.position, result.prize || 0], (err) => {
                                if (err && !hasError) {
                                    hasError = true;
                                    return db.rollback(() =>
                                        res.status(500).json({ error: `Database error inserting result for horse ${result.horseId}` }));
                                }

                                completed++;
                                if (completed === results.length && !hasError) {
                                    db.commit(err => {
                                        if (err) {
                                            return db.rollback(() =>
                                                res.status(500).json({ error: 'Database commit error' }));
                                        }
                                        res.json({
                                            message: 'Race and results added successfully',
                                            raceId,
                                            resultsCount: results.length
                                        });
                                    });
                                }
                            });
                        });
                    });
                });
            });
        });
    });
});

// TRACK ENDPOINTS
app.get('/api/tracks', (req, res) => {
    dbQuery('SELECT trackName FROM Track', [], res, (results) => res.json(results));
});

// GUEST ENDPOINTS
app.get('/api/guest/horses-by-owner', (req, res) => {
    const { lastName } = req.query;

    if (!lastName || lastName.trim() === '') {
        return res.status(400).json({ error: 'Owner last name is required' });
    }

    const query = `
        SELECT 
            h.horseName, 
            h.age,
            t.fname as trainerFname,
            t.lname as trainerLname,
            o.fname as ownerFname,
            o.lname as ownerLname
        FROM Horse h
        JOIN Owns ow ON h.horseid = ow.horseid
        JOIN Owner o ON ow.ownerId = o.ownerId
        LEFT JOIN Trainer t ON h.stableId = t.stableId
        WHERE o.lname LIKE ?`;

    dbQuery(query, [`%${lastName}%`], res, (results) => res.json(results));
});

app.get('/api/guest/winning-trainers', (req, res) => {
    const query = `
        SELECT DISTINCT t.fname as trainerFname, t.lname as trainerLname, 
               h.horseName, r.raceName, rr.prize as prizeMoney
        FROM Trainer t
        JOIN Horse h ON t.stableId = h.stableId
        JOIN RaceResults rr ON h.horseId = rr.horseId
        JOIN Race r ON rr.raceId = r.raceId
        WHERE rr.results = 'first'
        ORDER BY rr.prize DESC`;

    dbQuery(query, [], res, (results) => res.json(results));
});

app.get('/api/guest/trainer-winnings', (req, res) => {
    const query = `
        SELECT t.fname as trainerFname, t.lname as trainerLname, 
               SUM(rr.prize) as totalWinnings
        FROM Trainer t
        JOIN Horse h ON t.stableId = h.stableId
        JOIN RaceResults rr ON h.horseId = rr.horseId
        GROUP BY t.trainerId, t.fname, t.lname
        ORDER BY totalWinnings DESC`;

    dbQuery(query, [], res, (results) => res.json(results));
});

app.get('/api/guest/track-statistics', (req, res) => {
    const query = `
        SELECT t.trackName, t.location, t.length,
               COUNT(DISTINCT r.raceId) as totalRaces,
               COUNT(DISTINCT rr.horseId) as totalHorses
        FROM Track t
        LEFT JOIN Race r ON t.trackName = r.trackName
        LEFT JOIN RaceResults rr ON r.raceId = rr.raceId
        GROUP BY t.trackName, t.location, t.length
        ORDER BY totalRaces DESC`;

    dbQuery(query, [], res, (results) => res.json(results));
});