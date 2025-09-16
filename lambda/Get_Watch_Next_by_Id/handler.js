const connect_to_db = require('./db');
const talk = require('./Talk');

module.exports.get_watch_next_by_id = async (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log('Received event:', JSON.stringify(event, null, 2));
    
    let body = {};
    if (event.body) {
        body = JSON.parse(event.body);
    }

    if (!body.id) {
        return callback(null, {
            statusCode: 400,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Missing talk id.'
        });
    }

    try {
        await connect_to_db();
        console.log("=> Fetching talk by id:", body.id);

        const t = await talk.findById(body.id).select('watch_next');

        if (!t) {
            return callback(null, {
                statusCode: 404,
                headers: { 'Content-Type': 'text/plain' },
                body: 'Talk not found.'
            });
        }

        return callback(null, {
            statusCode: 200,
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(t.watch_next || [])
        });

    } catch (err) {
        console.error('Error fetching watch_next:', err);
        return callback(null, {
            statusCode: 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Could not fetch watch_next.'
        });
    }
};
