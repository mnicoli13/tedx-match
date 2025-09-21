const mongoose = require('mongoose');

const talk_schema = new mongoose.Schema({
    _id: String, 
    title: String,
    url: String,
    description: String,
    speakers: String,
    comprehend_analysis: mongoose.Schema.Types.Mixed,
    tags: [String],
    duration: String,
    publishedAt: String,
    presenterDisplayName: String,
    thumbnails: [mongoose.Schema.Types.Mixed],
    watch_next: [mongoose.Schema.Types.Mixed],
}, { collection: 'video_with_images' });

module.exports = mongoose.model('talk', talk_schema);