--streaming application kafka
--not sure if it needs emit changes
--https://docs.ksqldb.io/en/0.7.1-ksqldb/tutorials/connect-integration/
-- CREATE SOURCE CONNECTOR `jdbc-connector` WITH(
-- 	"connector.class" = 'io.confluent.connect.jdbc.JdbcSourceConnector',
-- 	"connection.url" = 'jdbc:postgresql://localhost:5432/postgres',
-- 	"mode" = 'bulk',
-- 	"topic.prefix" = 'jdbc-pg-',
-- 	"key" = 'postgres'
-- );
-- DESCRIBE CONNECTOR "jdbc-connector";
-- CREATE TABLE MusicDesc (
-- 	musicId INT PRIMARY KEY,
-- 	name VARCHAR,
-- 	description VARCHAR,
-- 	publicationDate VARCHAR,
-- 	-- link TEXT,
-- 	turnOffComments BOOLEAN,
-- 	duration VARCHAR
-- ) WITH (
-- 	kafka_topic = 'music',
-- 	value_format = 'json',
-- 	partitions = 1
-- );
-- CREATE STREAM MusicStats(musidId INT, views BIGINT, likes BIGINT) WITH (
-- 	kafka_topic = 'musicStats',
-- 	value_format = 'json',
-- 	partitions = 1
-- );
-- CREATE STREAM MUSIC AS
-- SELECT musicId,
-- 	name,
-- 	description,
-- 	turnOffComments,
-- 	duration,
-- 	views,
-- 	likes
-- FROM MusicStats
-- 	INNER JOIN MusicDesc ON musidId = musicId;
-- INSERT INTO Music
-- VALUES (
-- 		1,
-- 		'My music',
-- 		'mine musica',
-- 		false,
-- 		'02:22',
-- 		3,
-- 		5
-- 	);
-- CREATE TABLE Statistics AS
-- SELECT musicId,
-- 	latest_by_offset(views) as musicViews,
-- 	latest_by_offset(likes) as musicLikes
-- FROM Music
-- group by musicId;
-- -- if we'll need views and likes, we'll create them
-- -- easiest this way
-- CREATE TABLE LikesMusic AS
-- SELECT musicId,
-- 	latest_by_offset(likes) as musicLikes
-- FROM Music
-- group by musicId;
-- CREATE TABLE ViewsMusic AS
-- SELECT musicId,
-- 	latest_by_offset(views) as musicViews
-- FROM Music
-- group by musicId;
-- SELECT * FROM Statistics where 
-- musicLikes > 0 and musicViews > 0 EMIT CHANGES;
--SELECT * FROM LikesMusic where musicLikes > 0 EMIT CHANGES;
--SELECT * FROM ViewsMusic where musicLikes > 0 EMIT CHANGES;
-- CREATE STREAM CommentStream(
-- 	commentId INT,
-- 	content VARCHAR
-- 	) WITH (
-- 	kafka_topic='commentStream',
-- 	value_format='json',
-- 	partitions = 1
-- );
-- CREATE TABLE Comment AS
-- 	SELECT commentId, 
-- 	LATEST_BY_OFFSET(content) AS recentComment
-- FROM CommentStream
-- GROUP BY commentId;
--SELECT * FROM Comment WHERE recentComment IS NOT NULL EMIT CHANGES;
--INSERT INTO CommentStream VALUES (1, 'Very cool!');
--INSERT INTO CommentStream VALUES (2, 'This is exciting...');
--INSERT INTO CommentStream VALUES (3, 'They never disappoint.');
--INSERT INTO CommentStream VALUES (4, null);
--INSERT INTO CommentStream VALUES (5, 'I've been meaning to ask - how??');
--INSERT INTO CommentStream VALUES (6, 'First.');
--INSERT INTO CommentStream VALUES (7, 'Nice!');
-- our file stream - not sure what to do
-- CREATE STREAM FileStream(
-- 	musicId INT,
-- 	file BLOB
-- 	) WITH (
-- 	kafka_topic='fileStream',
-- 	value_format = 'json',
-- 	partitions = 1
-- );
CREATE STREAM IF NOT EXISTS MusicData (musicId INT, views BIGINT, likes BIGINT) WITH (
	kafka_topic = 'music-data',
	value_format = 'json',
	partitions = 1
);
CREATE TABLE IF NOT EXISTS LikesMusic AS
SELECT musicId,
	latest_by_offset(likes) as musicLikes
FROM MusicData
GROUP BY musicId EMIT CHANGES;
CREATE TABLE IF NOT EXISTS ViewsMusic AS
SELECT musicId,
	latest_by_offset(views) as musicViews
FROM MusicData
group by musicId EMIT CHANGES;
SHOW TABLES;
SHOW STREAMS;