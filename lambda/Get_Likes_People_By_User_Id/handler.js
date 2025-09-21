const connect_to_db = require('./db');
const User = require('./User'); // mongoose User model

// GET LIKES BY USER IDS HANDLER
module.exports.get_likes_by_user_ids = async (event, context) => {
    context.callbackWaitsForEmptyEventLoop = false;

    let body = {};
    if (event.body) {
        try {
            body = JSON.parse(event.body);
        } catch (err) {
            return {
                statusCode: 400,
                headers: { 'Content-Type': 'text/plain' },
                body: 'Invalid JSON in request body.'
            };
        }
    }

    if (!body.user_ids || !Array.isArray(body.user_ids)) {
        return {
            statusCode: 400,
            headers: { 'Content-Type': 'text/plain' },
            body: 'user_ids (array) is required.'
        };
    }

    try {
        await connect_to_db();

        const users = await User.find({ user_id: { $in: body.user_ids } });

        return {
            statusCode: 200,
            body: JSON.stringify(users)
        };

    } catch (err) {
        console.error('Error fetching users:', err);
        return {
            statusCode: err.statusCode || 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Could not fetch users.'
        };
    }
};
