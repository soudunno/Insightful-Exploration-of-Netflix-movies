CREATE TABLE dim_movie (
    movie_id UNIQUEIDENTIFIER,
    movie_name NVARCHAR(255),
    movie_description NVARCHAR(MAX),
    movie_duration NVARCHAR(50),  -- assuming formattedDuration is a string; adjust if it's a numeric duration in minutes
    movie_released_date DATE,
    movie_season INT,  -- assuming numberOfSeasons is an integer
    movie_season_date DATE,
    movie_source NVARCHAR(100),
    PRIMARY KEY (movie_id)
);



INSERT INTO dim_movie (movie_id, movie_name, movie_description, movie_duration, movie_released_date, movie_season, movie_season_date, movie_source)
SELECT 
    uniqId, 
    name, 
    description, 
    formattedDuration, 
    releasedDate, 
    numberOfSeasons, 
    seasonStartDate, 
    source
FROM 
    movie;



CREATE TABLE fact_movie_revenue (
    actor_id SMALLINT,
    creator_id TINYINT,
    movie_id UNIQUEIDENTIFIER,
    director_id TINYINT,
    movie_revenue DECIMAL(18,2), 
    FOREIGN KEY (actor_id) REFERENCES dim_actor(actor_id),
    FOREIGN KEY (creator_id) REFERENCES dim_creator(creator_id),
    FOREIGN KEY (movie_id) REFERENCES dim_movie(movie_id),
    FOREIGN KEY (director_id) REFERENCES dim_director(director_id)
);




-- SQL to insert data into fact_movie_revenue
INSERT INTO fact_movie_revenue (actor_id, creator_id, movie_id, director_id, movie_revenue)
SELECT 
    a.actor_id, 
    c.creator_id, 
    m.movie_id, 
    d.director_id, 
    mo.Revenue
FROM 
    movie mo
JOIN 
    dim_movie m ON mo.name = m.movie_name  -- Linking via movie name
LEFT JOIN 
    dim_actor a ON mo.actors LIKE '%' + a.actor_name + '%'  -- Handling multiple actors
LEFT JOIN 
    dim_director d ON mo.director = d.director_name  -- Linking via director name
LEFT JOIN 
    dim_creator c ON (c.creator_name = mo.creator OR c.creator_name IS NULL)  -- Handling NULL creators
WHERE
    mo.Revenue IS NOT NULL;  -- Ensures that only records with valid revenue data are inserted





CREATE TABLE fact_movie_review (
    movie_id UNIQUEIDENTIFIER,
    genre_id TINYINT,
    rating_id TINYINT,  -- Assuming this is linked to a content rating
    movie_rotten_tomato_review NVARCHAR(255),  -- Adjust the datatype based on actual review data type
    FOREIGN KEY (movie_id) REFERENCES dim_movie(movie_id),
    FOREIGN KEY (genre_id) REFERENCES dim_genre(genre_id),
    FOREIGN KEY (rating_id) REFERENCES dim_content_rating(rating_id)
);



-- SQL to insert data into fact_movie_review
INSERT INTO fact_movie_review (movie_id, genre_id, rating_id, movie_rotten_tomato_review)
SELECT 
    m.movie_id, 
    g.genre_id, 
    r.rating_id, 
    mo.rotten_tomato_reviews
FROM 
    movie mo
JOIN 
    dim_movie m ON mo.name = m.movie_name  -- Assuming movie_name is a unique and valid identifier
LEFT JOIN 
    dim_genre g ON mo.genre = g.genre_name  -- Adjust if you are using genre names in the movie table
LEFT JOIN 
    dim_content_rating r ON mo.contentRating = r.rating_name  -- Adjust similarly
WHERE
    mo.rotten_tomato_reviews IS NOT NULL;  -- Ensuring only records with reviews are inserted


select * from fact_movie_revenue
select * from fact_movie_review



