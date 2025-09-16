const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  user_id: String,
  first_name: String,
  last_name: String,
  username: String,
  likes: mongoose.Schema.Types.Mixed
});

module.exports = mongoose.model('User', UserSchema);
