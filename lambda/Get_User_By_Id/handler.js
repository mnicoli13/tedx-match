const connect_to_db = require('./db');
const User = require('./User'); // il tuo model mongoose User

// GET USER BY ID HANDLER
module.exports.get_user_by_id = async (event, context) => {
    context.callbackWaitsForEmptyEventLoop = false;

    let body = {};
    if (event.body) {
        body = JSON.parse(event.body);
    }

    if (!body.user_id) {
        return {
            statusCode: 400,
            headers: { 'Content-Type': 'text/plain' },
            body: 'user_id is required.'
        };
    }

    try {
        await connect_to_db();

        const user = await User.findOne({ user_id: body.user_id });

        if (!user) {
            return {
                statusCode: 404,
                headers: { 'Content-Type': 'text/plain' },
                body: 'User not found.'
            };
        }

        return {
            statusCode: 200,
            body: JSON.stringify(user)
        };

    } catch (err) {
        console.error('Error fetching user:', err);
        return {
            statusCode: err.statusCode || 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Could not fetch the user.'
        };
    }
};
