--
-- PostgreSQL database dump
--

-- Dumped from database version 14.5 (Ubuntu 14.5-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.5 (Ubuntu 14.5-0ubuntu0.22.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: addmusictomyplaylist(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addmusictomyplaylist() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	DECLARE playlista INT;
BEGIN
	playlista := (SELECT playlistId FROM Playlists
				WHERE new.userId = userId 
				AND name = 'My Music');
	INSERT INTO PlaylistMusic (playlistId, musicId)
		VALUES (playlista, NEW.musicId);
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.addmusictomyplaylist() OWNER TO postgres;

--
-- Name: checkifinlist(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.checkifinlist() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	DECLARE postoji BOOLEAN;
BEGIN
	postoji := (SELECT musicId FROM PlaylistMusic WHERE musicId = NEW.musicId AND NEW.playlistId = playlistId);
	IF NOT postoji THEN
		INSERT INTO PlaylistMusic (playlistId, musicId, ordered) VALUES (NEW.playlistId, NEW.musicId, NEW.ordered);
	END IF;
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.checkifinlist() OWNER TO postgres;

--
-- Name: makeplaylists(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.makeplaylists() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE x INT := (SELECT userId FROM Users WHERE email = NEW.email);
BEGIN
	INSERT INTO Playlists (name, description, userId)
		VALUES ('Liked Music', 'Music liked by you', x), 
			('My Music', 'Music you have uploaded', x);
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.makeplaylists() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: artists; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.artists (
    artistid integer NOT NULL,
    name character varying(45)
);


ALTER TABLE public.artists OWNER TO postgres;

--
-- Name: artists_artistid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.artists_artistid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.artists_artistid_seq OWNER TO postgres;

--
-- Name: artists_artistid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.artists_artistid_seq OWNED BY public.artists.artistid;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comments (
    commentid integer NOT NULL,
    content text NOT NULL,
    userid integer,
    musicid integer
);


ALTER TABLE public.comments OWNER TO postgres;

--
-- Name: comments_commentid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.comments_commentid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.comments_commentid_seq OWNER TO postgres;

--
-- Name: comments_commentid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.comments_commentid_seq OWNED BY public.comments.commentid;


--
-- Name: genres; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.genres (
    genreid integer NOT NULL,
    name character varying(45) NOT NULL
);


ALTER TABLE public.genres OWNER TO postgres;

--
-- Name: genres_genreid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.genres_genreid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.genres_genreid_seq OWNER TO postgres;

--
-- Name: genres_genreid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.genres_genreid_seq OWNED BY public.genres.genreid;


--
-- Name: music; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.music (
    musicid integer NOT NULL,
    title character varying(45) NOT NULL,
    description text,
    publicationdate timestamp without time zone NOT NULL,
    turnoffcomments boolean DEFAULT false,
    link text NOT NULL,
    duration time without time zone NOT NULL,
    userid integer
);


ALTER TABLE public.music OWNER TO postgres;

--
-- Name: music_musicid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.music_musicid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.music_musicid_seq OWNER TO postgres;

--
-- Name: music_musicid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.music_musicid_seq OWNED BY public.music.musicid;


--
-- Name: musicartists; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.musicartists (
    musicid integer NOT NULL,
    artistid integer NOT NULL
);


ALTER TABLE public.musicartists OWNER TO postgres;

--
-- Name: musicgenres; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.musicgenres (
    musicid integer NOT NULL,
    genreid integer NOT NULL
);


ALTER TABLE public.musicgenres OWNER TO postgres;

--
-- Name: playlistmusic; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.playlistmusic (
    playlistid integer NOT NULL,
    musicid integer NOT NULL
);


ALTER TABLE public.playlistmusic OWNER TO postgres;

--
-- Name: playlists; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.playlists (
    playlistid integer NOT NULL,
    name character varying(40) NOT NULL,
    description text,
    userid integer
);


ALTER TABLE public.playlists OWNER TO postgres;

--
-- Name: playlists_playlistid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.playlists_playlistid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.playlists_playlistid_seq OWNER TO postgres;

--
-- Name: playlists_playlistid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.playlists_playlistid_seq OWNED BY public.playlists.playlistid;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    roleid integer NOT NULL,
    name character varying(15)
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: roles_roleid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_roleid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.roles_roleid_seq OWNER TO postgres;

--
-- Name: roles_roleid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_roleid_seq OWNED BY public.roles.roleid;


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subscriptions (
    userid integer NOT NULL,
    subscribetoid integer NOT NULL,
    CONSTRAINT subscriptions_check CHECK ((userid <> subscribetoid))
);


ALTER TABLE public.subscriptions OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    userid integer NOT NULL,
    username character varying(45) NOT NULL,
    email character varying(45) NOT NULL,
    firstname character varying(30) NOT NULL,
    lastname character varying(30) NOT NULL,
    roleid integer,
    password character varying(64)
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_userid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_userid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_userid_seq OWNER TO postgres;

--
-- Name: users_userid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_userid_seq OWNED BY public.users.userid;


--
-- Name: artists artistid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.artists ALTER COLUMN artistid SET DEFAULT nextval('public.artists_artistid_seq'::regclass);


--
-- Name: comments commentid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments ALTER COLUMN commentid SET DEFAULT nextval('public.comments_commentid_seq'::regclass);


--
-- Name: genres genreid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genres ALTER COLUMN genreid SET DEFAULT nextval('public.genres_genreid_seq'::regclass);


--
-- Name: music musicid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.music ALTER COLUMN musicid SET DEFAULT nextval('public.music_musicid_seq'::regclass);


--
-- Name: playlists playlistid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists ALTER COLUMN playlistid SET DEFAULT nextval('public.playlists_playlistid_seq'::regclass);


--
-- Name: roles roleid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN roleid SET DEFAULT nextval('public.roles_roleid_seq'::regclass);


--
-- Name: users userid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN userid SET DEFAULT nextval('public.users_userid_seq'::regclass);


--
-- Data for Name: artists; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.artists (artistid, name) FROM stdin;
1	Years and Years
2	Queen
3	Britney Spears
4	Gojira
5	John Newman
6	Ed Sheeran
7	Mozzart
8	Elton John
9	Micheal Jackson
10	The Weeknd
11	Kungs
12	Kygo
13	by User
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comments (commentid, content, userid, musicid) FROM stdin;
1	I like it very much	2	2
\.


--
-- Data for Name: genres; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.genres (genreid, name) FROM stdin;
1	pop
2	rock
3	edm
4	jazz
5	blues
6	metal
7	fresh metal
8	thresh
9	emo
10	grunge
11	alt
12	dubstep
13	classical
14	opera
15	indie
\.


--
-- Data for Name: music; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.music (musicid, title, description, publicationdate, turnoffcomments, link, duration, userid) FROM stdin;
2	My First Music	This is my first attempt at music. Tell me whether you like it!	2022-12-15 13:48:29.963461	f	https:www.somelink.com	00:02:30	5
3	My Second Music	This is my SECOND attempt at music. Tell me whether you like it!	2022-12-15 14:21:46.51121	f	https:www.someotherlink.com	00:02:19	5
\.


--
-- Data for Name: musicartists; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.musicartists (musicid, artistid) FROM stdin;
2	13
3	13
\.


--
-- Data for Name: musicgenres; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.musicgenres (musicid, genreid) FROM stdin;
2	11
3	9
3	2
\.


--
-- Data for Name: playlistmusic; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.playlistmusic (playlistid, musicid) FROM stdin;
12	2
12	3
11	2
11	3
\.


--
-- Data for Name: playlists; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.playlists (playlistid, name, description, userid) FROM stdin;
5	Liked Music	Music liked by you	2
6	My Music	Music you have uploaded	2
11	Liked Music	Music liked by you	5
12	My Music	Music you have uploaded	5
13	Liked Music	Music liked by you	6
14	My Music	Music you have uploaded	6
15	Liked Music	Music liked by you	7
16	My Music	Music you have uploaded	7
17	Liked Music	Music liked by you	8
18	My Music	Music you have uploaded	8
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (roleid, name) FROM stdin;
1	registered
2	moderator
3	administrator
\.


--
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subscriptions (userid, subscribetoid) FROM stdin;
2	5
5	6
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (userid, username, email, firstname, lastname, roleid, password) FROM stdin;
2	dantelion	darionewman@gmail.com	Dario	Newman	1	c06b0cfe0cc5e900c57784484094331f095bf441995c3c31ea6c75691c786c35
5	EmaBB	emabb@gmail.com	Ema	Baumgartner	1	750f869c345e78d6542373f4c9b427117209344dd27fca39cf6be2472b71418a
6	SomeOneThings	john@gmail.com	John	Jonnster	1	045928218d6d5a42f976163d70cdfe9226e9d1c3ea6bf1647ae1d8f44c2edc7d
7	ModManDan	dannydan@gmail.com	Danny	Dan	2	12f2189d12d1747b27b260a8d43cae84b5bfc901de87d932acaf9b3cb0c426a1
8	XHeyX	allyalles@gmail.com	Ally	Alles	1	28c3c24bf3e3a40f9628a8f3e62f116c3164beb899fbcfe9cc8dd15d905e03a5
\.


--
-- Name: artists_artistid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.artists_artistid_seq', 13, true);


--
-- Name: comments_commentid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.comments_commentid_seq', 1, true);


--
-- Name: genres_genreid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.genres_genreid_seq', 15, true);


--
-- Name: music_musicid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.music_musicid_seq', 3, true);


--
-- Name: playlists_playlistid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.playlists_playlistid_seq', 18, true);


--
-- Name: roles_roleid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_roleid_seq', 3, true);


--
-- Name: users_userid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_userid_seq', 8, true);


--
-- Name: artists artists_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.artists
    ADD CONSTRAINT artists_pkey PRIMARY KEY (artistid);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (commentid);


--
-- Name: genres genres_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genres
    ADD CONSTRAINT genres_pkey PRIMARY KEY (genreid);


--
-- Name: music music_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.music
    ADD CONSTRAINT music_pkey PRIMARY KEY (musicid);


--
-- Name: musicartists musicartists_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musicartists
    ADD CONSTRAINT musicartists_pkey PRIMARY KEY (musicid, artistid);


--
-- Name: musicgenres musicgenres_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musicgenres
    ADD CONSTRAINT musicgenres_pkey PRIMARY KEY (musicid, genreid);


--
-- Name: playlistmusic playlistmusic_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlistmusic
    ADD CONSTRAINT playlistmusic_pkey PRIMARY KEY (playlistid, musicid);


--
-- Name: playlists playlists_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists
    ADD CONSTRAINT playlists_pkey PRIMARY KEY (playlistid);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (roleid);


--
-- Name: users solomail; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT solomail UNIQUE (email);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (userid, subscribetoid);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (userid);


--
-- Name: music addingmusic; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER addingmusic AFTER INSERT ON public.music FOR EACH ROW EXECUTE FUNCTION public.addmusictomyplaylist();


--
-- Name: users creatinguser; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER creatinguser AFTER INSERT ON public.users FOR EACH ROW EXECUTE FUNCTION public.makeplaylists();


--
-- Name: playlistmusic insertion; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER insertion BEFORE INSERT ON public.playlistmusic FOR EACH ROW EXECUTE FUNCTION public.checkifinlist();


--
-- Name: comments comments_musicid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_musicid_fkey FOREIGN KEY (musicid) REFERENCES public.music(musicid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comments comments_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_userid_fkey FOREIGN KEY (userid) REFERENCES public.users(userid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: music music_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.music
    ADD CONSTRAINT music_userid_fkey FOREIGN KEY (userid) REFERENCES public.users(userid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: musicartists musicartists_artistid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musicartists
    ADD CONSTRAINT musicartists_artistid_fkey FOREIGN KEY (artistid) REFERENCES public.artists(artistid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: musicartists musicartists_musicid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musicartists
    ADD CONSTRAINT musicartists_musicid_fkey FOREIGN KEY (musicid) REFERENCES public.music(musicid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: musicgenres musicgenres_genreid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musicgenres
    ADD CONSTRAINT musicgenres_genreid_fkey FOREIGN KEY (genreid) REFERENCES public.genres(genreid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: musicgenres musicgenres_musicid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musicgenres
    ADD CONSTRAINT musicgenres_musicid_fkey FOREIGN KEY (musicid) REFERENCES public.music(musicid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: playlistmusic playlistmusic_musicid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlistmusic
    ADD CONSTRAINT playlistmusic_musicid_fkey FOREIGN KEY (musicid) REFERENCES public.music(musicid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: playlistmusic playlistmusic_playlistid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlistmusic
    ADD CONSTRAINT playlistmusic_playlistid_fkey FOREIGN KEY (playlistid) REFERENCES public.playlists(playlistid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: playlists playlists_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists
    ADD CONSTRAINT playlists_userid_fkey FOREIGN KEY (userid) REFERENCES public.users(userid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: subscriptions subscriptions_subscribetoid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_subscribetoid_fkey FOREIGN KEY (subscribetoid) REFERENCES public.users(userid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: subscriptions subscriptions_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_userid_fkey FOREIGN KEY (userid) REFERENCES public.users(userid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users users_roleid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_roleid_fkey FOREIGN KEY (roleid) REFERENCES public.roles(roleid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

