const connect_to_db = require('./db');
const User = require('./User'); // il modello User con mongoose

// GET SIMILAR USERS BY VIDEO TAGS HANDLER
module.exports.get_similar_users = async (event, context) => {
    context.callbackWaitsForEmptyEventLoop = false;

    let body = {};
    if (event.body) {
        body = JSON.parse(event.body);
    }

    if (!body.user_id || !body.video_tags) {
        return {
            statusCode: 400,
            headers: { 'Content-Type': 'text/plain' },
            body: 'user_id and video_tags are required.'
        };
    }

    try {
        await connect_to_db();

        // Trova l'utente che ha messo like ai video con i tag specificati
        const user = await User.findOne({ user_id: body.user_id });

        if (!user) {
            return {
                statusCode: 404,
                headers: { 'Content-Type': 'text/plain' },
                body: 'User not found.'
            };
        }

        // Troviamo gli altri utenti che hanno messo like a video con gli stessi tag
        const similarUsers = await getUsersByTags(body.video_tags, user.user_id);

        return {
            statusCode: 200,
            body: JSON.stringify(similarUsers)
        };

    } catch (err) {
        console.error('Error fetching similar users:', err);
        return {
            statusCode: err.statusCode || 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Could not fetch similar users.'
        };
    }
};

// Funzione per trovare gli utenti che hanno messo like a video con gli stessi tag
async function getUsersByTags(tags, currentUserId) {
    try {
        // Troviamo tutti gli utenti che hanno messo like a video con uno dei tag
        const users = await User.find({
            'likes.tags': { $in: tags },
            user_id: { $ne: currentUserId }  // Escludiamo l'utente che ha fatto la richiesta
        });

        // Restituiamo solo gli user_id degli utenti trovati
        return users.map(user => ({
            user_id: user.user_id,
            first_name: user.first_name,
            last_name: user.last_name,
            username: user.username,
            likes: user.likes
        }));

    } catch (err) {
        console.error('Error fetching users by tags:', err);
        throw new Error('Error fetching users by tags');
    }
}