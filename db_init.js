const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

async function initializeDatabase() {
    console.log("Connecting to local MySQL server...");
    
    // Connect to the MySQL server without specifying a database yet
    const connection = await mysql.createConnection({
        host: 'localhost',
        user: 'root',
        password: '',
        multipleStatements: true // Required to run the bulk SQL file
    });

    try {
        console.log("Creating database 'secteur212' if it does not exist...");
        await connection.query(`CREATE DATABASE IF NOT EXISTS secteur212;`);
        
        console.log("Switching to database 'secteur212'...");
        await connection.changeUser({ database: 'secteur212' });

        console.log("Reading secteur212.sql...");
        const sqlFilePath = path.join(__dirname, 'secteur212.sql');
        const sqlContent = fs.readFileSync(sqlFilePath, 'utf8');

        console.log("Importing base tables...");
        if (sqlContent.trim()) {
            await connection.query(sqlContent);
            console.log("Base tables imported successfully!");
        } else {
            console.log("Warning: secteur212.sql is empty or missing content.");
        }

        console.log("Injecting Master Directive v2.0 custom columns (job, gang, metadata)...");
        // We use IF NOT EXISTS logic via a try-catch for simplicity, or just run ALTER TABLE and suppress duplicate column errors
        try {
            await connection.query(`
                ALTER TABLE \`characters\` 
                ADD COLUMN IF NOT EXISTS \`job\` LONGTEXT DEFAULT '{"name":"unemployed","grade":{"level":0}}',
                ADD COLUMN IF NOT EXISTS \`gang\` LONGTEXT DEFAULT '{"name":"none","grade":{"level":0}}',
                ADD COLUMN IF NOT EXISTS \`metadata\` LONGTEXT DEFAULT '{"hunger":100,"thirst":100}';
            `);
            console.log("Custom columns injected successfully!");
        } catch (alterError) {
            // MySQL 8.0.28+ supports IF NOT EXISTS for ADD COLUMN, but MariaDB (XAMPP) might not.
            // If it fails due to syntax (older MariaDB), we fall back to raw query and ignore ER_DUP_FIELDNAME
            if (alterError.code === 'ER_PARSE_ERROR') {
                try {
                    await connection.query(`
                        ALTER TABLE \`characters\` 
                        ADD COLUMN \`job\` LONGTEXT DEFAULT '{"name":"unemployed","grade":{"level":0}}',
                        ADD COLUMN \`gang\` LONGTEXT DEFAULT '{"name":"none","grade":{"level":0}}',
                        ADD COLUMN \`metadata\` LONGTEXT DEFAULT '{"hunger":100,"thirst":100}';
                    `);
                    console.log("Custom columns injected successfully via fallback!");
                } catch (fallbackError) {
                    if (fallbackError.code === 'ER_DUP_FIELDNAME') {
                        console.log("Custom columns already exist. Skipping injection.");
                    } else {
                        throw fallbackError;
                    }
                }
            } else {
                throw alterError;
            }
        }

        console.log("======================================");
        console.log("DATABASE AUTOMATION COMPLETE!");
        console.log("You may now rejoin the server.");
        console.log("======================================");

    } catch (err) {
        console.error("Database initialization failed:");
        console.error(err);
    } finally {
        await connection.end();
    }
}

initializeDatabase();
