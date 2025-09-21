const connect_to_db = require('./db');
const User = require('./User'); // mongoose User model

// ADD LIKE TO USER HANDLER
module.exports.add_like_to_user = async (event, context) => {
    context.callbackWaitsForEmptyEventLoop = false;

    let body = {};
    if (event.body) {
        body = JSON.parse(event.body);
    }

    if (!body.user_id || !body.liked_user_id) {
        return {
            statusCode: 400,
            headers: { 'Content-Type': 'text/plain' },
            body: 'user_id and liked_user_id are required.'
        };
    }

    try {
        await connect_to_db();

        const updatedUser = await User.findOneAndUpdate(
            { user_id: body.user_id },
            { $addToSet: { likes_people: body.liked_user_id } }, // evita duplicati
            { new: true } // restituisce l'utente aggiornato
        );

        if (!updatedUser) {
            return {
                statusCode: 404,
                headers: { 'Content-Type': 'text/plain' },
                body: 'User not found.'
            };
        }

        return {
            statusCode: 200,
            body: JSON.stringify(updatedUser)
        };

    } catch (err) {
        console.error('Error updating likes_people:', err);
        return {
            statusCode: err.statusCode || 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Could not update likes_people.'
        };
    }
};
