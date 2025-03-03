import sql from 'mssql';
import dotenv from 'dotenv';

// Load environment variables from the .env file
dotenv.config();

// Configuration for AuthDB (Authentication Database)
const authDbNotEmpConfig = {
    user: process.env.DB1_NOTEMP,
    password: process.env.DB1_NOTEMP_PASSWORD,
    server: process.env.DB_SERVER,
    database: process.env.DB1_NAME,
    options: {
        encrypt: true,
        trustServerCertificate: true
    }
};

const authDbEmpConfig = {
    user: process.env.DB1_EMP,
    password: process.env.DB1_EMP_PASSWORD,
    server: process.env.DB_SERVER,
    database: process.env.DB1_NAME,
    options: {
        encrypt: true,
        trustServerCertificate: true
    }
};


// Configuration for ApptDB Patient (Application Database)
const apptDbPatConfig = {
    user: process.env.DB2_PAT,
    password: process.env.DB2_PAT_PWD,
    server: process.env.DB_SERVER,
    database: process.env.DB2_NAME,
    options: {
        encrypt: true,
        trustServerCertificate: true
    }
};

// Configuration for ApptDB Doctor (Application Database)
const apptDbDocConfig = {
    user: process.env.DB2_DOC,
    password: process.env.DB2_DOC_PWD,
    server: process.env.DB_SERVER,
    database: process.env.DB2_NAME,
    options: {
        encrypt: true,
        trustServerCertificate: true
    }
};

// Configuration for ApptDB Clerk (Application Database)
const apptDbClkConfig = {
    user: process.env.DB2_CLK,
    password: process.env.DB2_CLK_PWD,
    server: process.env.DB_SERVER,
    database: process.env.DB2_NAME,
    options: {
        encrypt: true,
        trustServerCertificate: true
    }
};

// Function to query a database with specific configuration
async function queryDatabase(config, query, params = {}) {
    try {
        let pool = await sql.connect(config);
        let request = pool.request();

        for (const param in params) {
            request.input(param, params[param]);
        }

        let result = await request.query(query);
        console.log('Query executed:', query);
        console.log('Query result:', result);
        return result.recordset;
    } catch (err) {
        console.error('SQL error', err);
        return [];
    } finally {
        await sql.close();
    }
}

// Function to query AuthDB
async function queryAuthDbEmp(query, params = {}) {
    return queryDatabase(authDbEmpConfig, query, params);
}

async function queryAuthDbNotEmp(query, params = {}) {
    return queryDatabase(authDbNotEmpConfig, query, params);
}


// Function to query AppDB
async function queryApptDbPat(query, params = {}) {
    return queryDatabase(apptDbPatConfig, query, params);
}
async function queryApptDbDoc(query, params = {}) {
    return queryDatabase(apptDbDocConfig, query, params);
}
async function queryApptDbClk(query, params = {}) {
    return queryDatabase(apptDbClkConfig, query, params);
}

// Export the query functions for use in other files
export { queryAuthDbEmp, queryAuthDbNotEmp, queryApptDbPat, queryApptDbDoc, queryApptDbClk };
