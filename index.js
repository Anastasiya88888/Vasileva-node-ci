const http = require('http');
const { Client } = require('pg');

const PORT = process.env.PORT || 3000;

const client = new Client({
    host: 'db',
    user: 'postgres',
    password: 'postgres',
    database: 'mydb',
});

client.connect()
    .then(() => console.log('Connected to Postgres!'))
    .catch(err => console.error('Connection error! ', err));

const server = http.createServer((req, res) => {
    res.end('this is node on docker, hello :D');
});

server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
