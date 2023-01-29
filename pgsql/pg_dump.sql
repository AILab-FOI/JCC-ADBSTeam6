--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1 (Ubuntu 15.1-1.pgdg20.04+1)
-- Dumped by pg_dump version 15.1 (Ubuntu 15.1-1.pgdg20.04+1)

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
	DECLARE ordered INT;
	DECLARE intoit INT;
BEGIN
	intoit := (SELECT COUNT(musicId) FROM PlaylistMusic WHERE (musicId = NEW.musicId) AND (NEW.playlistId = playlistId) GROUP BY playlistId);
	--RAISE NOTICE 'couple: (%,%)', NEW.musicId, NEW.playlistId;
	
	--RAISE NOTICE 'intoit: %', intoit;
	IF intoit IS NULL THEN
		NEW.ordered := (SELECT COUNT(musicid) FROM PlaylistMusic WHERE (NEW.playlistId = playlistId)  GROUP BY playlistId);-- GROUP BY playlistId);
		--RAISE NOTICE 'sql: %', (SELECT COUNT(PlaylistMusic.musicid) FROM PlaylistMusic WHERE (NEW.playlistId = playlistId) GROUP BY playlistId);
		--RAISE NOTICE 'ordered: %', ordered;
		
		IF NEW.ordered IS NULL THEN
			NEW.ordered = 0;
		END IF;
		--RAISE NOTICE 'ordered: %', ordered + 1;
		-- INSERT INTO PlaylistMusic (playlistId, musicId, ordered) VALUES (NEW.playlistId, NEW.musicId, ordered + 1);
		--RAISE NOTICE 'sql: %', (SELECT COUNT(PlaylistMusic.musicid) FROM PlaylistMusic WHERE (NEW.playlistId = playlistId) GROUP BY playlistId);
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
    userid integer,
    file text NOT NULL
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
    musicid integer NOT NULL,
    ordered integer NOT NULL
);


ALTER TABLE public.playlistmusic OWNER TO postgres;

--
-- Name: playlistmusic_ordered_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.playlistmusic_ordered_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.playlistmusic_ordered_seq OWNER TO postgres;

--
-- Name: playlistmusic_ordered_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.playlistmusic_ordered_seq OWNED BY public.playlistmusic.ordered;


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
    subscribetoid integer NOT NULL
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
    password character varying(64) NOT NULL
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
-- Name: playlistmusic ordered; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlistmusic ALTER COLUMN ordered SET DEFAULT nextval('public.playlistmusic_ordered_seq'::regclass);


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
1	AGog471
2	MMuf119
3	ADeB138
4	JGli15
5	LWoo267
6	AJel379
7	PDee482
8	BJel257
9	XDee230
10	JPor315
11	EEli216
12	GBiz193
13	SHak303
14	TJin144
15	MEsp387
16	KSwi379
17	BTem262
18	TRou386
19	SLow267
20	DLav32
21	MSwi479
22	ODeB428
23	LGli468
24	JJin463
25	BNot233
26	BTom429
27	TLow402
28	CBra258
29	KWau251
30	GLig85
31	AMcG6
32	SCar175
33	GItz200
34	JPet109
35	MMay350
36	BEll279
37	BPec50
38	TGip26
39	EBre243
40	AGre236
41	GSto300
42	IRea464
43	MBam165
44	MTom158
45	BLow41
46	PMay133
47	AEwi390
48	XRea227
49	CSum91
50	TCre180
51	ADou332
52	LTom186
53	TRea9
54	JMil210
55	MRen75
56	RCri259
57	LFac298
58	CWhi481
59	TDou446
60	TEll170
61	OGou316
62	GBiz190
63	LDeB274
64	JWoo293
65	DBau95
66	CBam344
67	CBun167
68	APec138
69	MAnd116
70	ECru46
71	PMuf304
72	LBam276
73	ADee310
74	WTom460
75	CGre428
76	BEli215
77	KTom19
78	SNea356
79	ECar141
80	GGri118
81	GPro7
82	IHak210
83	PSum224
84	EStr355
85	JGri242
86	ROsm320
87	KMcT359
88	BSwi208
89	ARum446
90	ELig86
91	RBun212
92	GVas150
93	ARak349
94	CNot358
95	BLow435
96	FItz361
97	ACro83
98	CGip243
99	SSma272
100	OFra386
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comments (commentid, content, userid, musicid) FROM stdin;
101	bfldxfxnwyzetbxnrdtafbusaaxvvhrsiklylgrbgkrnke	214	441
102	adwweydkvlkltuksnvkiza	124	1060
103	lpnvhfvgfmkobopdu	216	834
104	oddxwybherasncfwiqhfunzoswexsqeabmt	198	784
105	wuyezfspkvlavaiseahbrq	145	658
106	sxzfqmkvygudcpo	144	287
107	wdrsicaubywnun	147	760
108	rgzqknzecfiakysbgvqdomvpbylsorrltldqg	140	344
109	rpptbuglx	273	520
110	esypmwr	179	111
111	zwsmqovmtdigdqqohlu	156	418
112	glyyonrpkirovmtrazdawfainrkfcorschfqmah	138	614
113	nusodhvaivokyrglbuhohqoplvpuyahgtheufo	181	826
114	xchbqiryytlqzdqobcaolgwylkpt	109	622
115	phxcxppxcishqntw	256	489
116	ateaor	295	296
117	ekgpulkaioppawqz	130	1038
118	esdmuscmndlbnxotkkmx	240	567
119	tuudbzbstmurpmcgyvzfotwddtppfvmhpytcllfkllmoy	133	605
120	wdtqnnomxvqkhuvhfhtyndmgpsvmrqkboxexxofnr	143	830
121	sqqzwoyountgluguismaqiisxrayglqkp	214	1088
122	yytanxmf	167	260
123	cwdfpuolsmilit	202	1080
124	yfbzhipnfs	213	997
125	dyfmxyrkrcaiwvsactrpcdy	169	987
126	xlazbyqzx	283	404
127	qozppyfqxtmuilmztbmcbnrhprkrxxgsxigqvef	176	145
128	mssfrdabsqobaiberczqqeldnfxugneygykyqgxsgr	129	156
129	azdgnaeyflxzcxb	256	561
130	ipfaycekwcuoyurnlapxlzmcwdbwqefoloaqixxgzxoa	184	330
131	zyxwqbodslkqazlbmye	164	1009
132	wdycrmgnqcauzdevdmsssg	105	140
133	blzkvaqaqytueawhyxrouenntxxpcchgqpkuetz	180	555
134	bknqwydftftvplppmmgtwfibpayquycdhkzetykwwa	141	1035
135	nfmfqulsthrywozchxekfcwypzxecadlpppmizzl	143	431
136	afguuqfkgg	259	390
137	emqgavamyzwlbbvdzahpirvlcogngfnbnauqo	138	115
138	weafykakdydsel	294	460
139	wnaousufbnvrnofehiqpalmcwirxlayvqvktwb	134	487
140	vixesrrcictsikbmqnuycicxgp	151	383
141	kmiaxnwrzeidodcfwkdhlkxxffxtdlkyizhgurpcpu	300	291
142	pobfrfndbxyfcrmx	125	448
143	orzwnhpfhrkgnxlpbqmeddtqitqdfoffkleccltpkgds	108	732
144	gqbcikcy	170	668
145	fykcxttcrqoumonulrpqhxmnm	145	211
146	ggwfrqrsvhqleewgwg	285	226
147	vaprcvtnircbiflarorhbohypkafkzhalvvyahdrcdgcwch	172	383
148	krxwqpsbvvwcnskxxbuazbwtfeawisaccsseynfvenzzmmlgh	293	306
149	xadoqttsyhmbyfkesbdpomyxsnzie	216	865
150	qulxecmpsbbrtcxrghuucbhiexvnganycmrhhw	246	390
151	eggvthodtphnslzodbrkx	137	393
152	oegcuimyz	148	123
153	cllulyfquzhhfveeeupsmqnfb	103	760
154	lveyrrqvttwi	180	869
155	yguvraimzqvkfqsibpwzsugdokr	216	332
156	gnowivmxspwfdmugfifxsqxooabefzpfppdizunizwrmgmqs	190	320
157	muzbelqvsxva	168	831
158	wwwqkvdpoduemywscsdwuafmerpulihngkp	278	257
159	wraoqdxevnnvserhmdoececkknlpniowgbuhvfmwovd	180	444
160	ylfdvwdxqdtznuavoveudctdpskpqelhtewq	118	850
161	mypugrzle	105	740
162	dskvudqhmdpagwscrqk	172	683
163	tpiocyypu	260	363
164	pvfbhqrmtdrvvrwkffbynwmghyttkuowmqyizcfghayrwn	276	332
165	fuqnwrpkloetqhzn	152	160
166	nzwbatonaxmmwyncnvklinfzrtcadlxeuqa	298	864
167	nncbaonycrnmdhcklel	191	961
168	buqmpstdiepqtafuocds	129	125
169	rhtanpzbzzhyfybumiqvlvlqwwfra	115	843
170	wmimkpv	229	792
171	zuteaqhuxkztsphtmnpxbmgvgtrmfoydmfnnbn	234	267
172	oouquzqxbgytsthxelyon	200	753
173	hmydax	284	378
174	yctsxxnlcdypxgpxqmszwpdvpbkkxhqwouh	157	579
175	rvqhmbkgawqodyxpieevvwyv	245	310
176	mgowudcpmwfsnsqhddqmvsvemwezsmtvgzpyvs	221	377
177	peldtqghkfi	166	991
178	efeegdhpfyncnfrcytcpiwrxexg	211	648
179	kvwqwwiioorwcakamhggao	215	325
180	xvcenn	105	1056
181	yduezakvlyvtevmfdnxqwqlquqochf	235	335
182	ktgxrcahiuoaigmdvygumome	290	701
183	mvaaauxcubprrtprtdnlaulmmkdadknur	164	129
184	powkrmzqckissyzgpbdazrkpoivshfbloiqg	281	1056
185	pmhahdeafhq	205	741
186	dxeudkdfquivictdfypbirlthd	216	272
187	akvahxfyuoewudnhebriohphqtqgmescfpebxzwcda	278	648
188	ityoggeyxsumxztogwtucxe	261	419
189	zqpiqsrpzvgpadetvayywdcotxlqlmsqstuiafbxcaziqcz	281	173
190	wruxnznrvsrnioudqpezeuyfkybccyryvxrgbwpuoxntioen	121	723
191	ukqkdqipewadxoiiczqwocoqaqebpxehwcgwpmsybf	189	305
192	ouehknnyfidqwxhvnyptqtyitsdsyqglcgp	237	275
193	lykgkzhegdwuzakfudrdbvnqzzuyfitewbr	131	903
194	gczogzmyulvhnqdbayrpcofsweiezezniuzhxecxhgrqulrpgt	205	586
195	fqpvliidmccyyzlxtpmhxdywnetqcmfvff	242	402
196	dutqxcrpfdfztxlfxuzyy	259	419
197	ykpcwrzwpvpatsrbgwlyvppcdk	123	801
198	uhsrqmnytxboyomehagmqzzidc	218	211
199	mflhxyeyyorwsalueeaofafqzaxvrbgkcmc	118	1004
200	sqrbevsucppfxavgmchcrgbbmndxiteqflnfdgdpramgtwt	297	934
201	aietlmlvcxcse	158	342
202	cnyrddrw	237	519
203	fwncpneycqvtkseqweauthkry	237	945
204	iodsdgqhngrgnb	175	898
205	fysyuvgklth	149	603
206	atpposswngwsnscdwigovtuprtkfirbeygczzdmoawwufuprip	112	274
207	nytyvlosnmuklrglkhypbq	246	228
208	lcolbxoeknsoqlas	213	600
209	ocrmxuseavsqhbmqudiqmwkuiywyutcozxvrosiykspyyzktg	247	624
210	qabspdnfkqqqfbvauinnrmdsupmonus	150	760
211	myxmntuqrbxomcfkplcmopydnnlsm	253	144
212	pzbqchrwphtisughovwbpyvmfirnhqawuxcvchlzdqogkp	196	1053
213	occbquhvfrhpbsqofqqvedltc	248	415
214	xathyatkmi	129	1000
215	pnpldompqvkxmnwbrunqkzuxlkc	160	322
216	bibpxzeahcwqccwsaxsmvynfrutfeyncubl	219	274
217	owoliqifqdcfxycgwirrtb	227	368
218	eyxoftqpxizkfktabhwdmlzriimphfnxmaawrpgr	129	780
219	bewdhnuslhnxwmoi	263	173
220	eoarofszbgsvdlf	104	852
221	eqmymignltsa	187	117
222	nunhnxy	122	450
223	vmytw	104	782
224	zuyzbnsmagcxlyplrrrletpxzdq	271	141
225	vlofgcyouqayhkhirowiplqpdltat	294	817
226	hvwkaurgmwhhliamoasnymwl	260	630
227	ndqrcwiiwmqhaauupzutdalcwqzeefiabaiagtidbrov	194	425
228	qwtlhupckqc	283	341
229	mywkpmthwpuvpukwkpgcscirsftoi	104	504
230	kvscxlaqupsirdseyuhiialtalfsbqrxyek	266	940
231	hbgrbrzveopdbdutquarn	218	411
232	mpgwvhycn	264	736
233	lccfbuywolkyyirgbobygryeoxvgwlqzhnksczzunaid	111	805
234	dvdzgpvynfkiaidomkgkzkiztxv	104	823
235	dkbwoqzhxtfrehdabfnobi	247	925
236	edymuhhwaygysycvokpdzsfzo	192	636
237	gxrlbqcyecrniwcfupkggadzkhlmqqcmbphcgkcnlxmkkkg	125	854
238	ymozyfvrflwghgmcbrelinxrtcmdlcmdlhi	248	241
239	vcrabxlvlnybvkewbncltgegawqyxhqdcy	141	535
240	qnbhkcdavndyzgntpbziblndcokqnzfohgi	212	146
241	blnzkfybhiiqhkwloypznovphbscfcnrieinelqdbvfdcawyxx	103	307
242	bfwvbgdwgeokeuhqscydtqhmyiaa	276	1084
243	dalzbchyadcubnqague	112	395
244	qbbbxutxzmwbhehlexaywzoqfvdgdfilmluifczbwrhbh	114	271
245	dzpxruscrozlfomcfzlhrdlerooxfoxilrzdofbcnur	215	977
246	zoprozefmowpakrluhqfgunnrtvna	273	350
247	bwrtotitqhnlxzeyvvclcrquoncebckzkne	259	658
248	gscwqvttnivcikuzyiapewbenbl	174	460
249	mcztfmkzhsbpkiwwwmbgrvrioqprwthnchadovbde	267	924
250	vdchbfguadfrywolwvaalkvgvhvdudndrhwkcztwc	300	609
251	nsvxttcdfffkddiwvnepdxoywnn	220	574
252	htefqyvaferhdqeybdradrb	191	1051
253	gsmryuxdri	299	149
254	xagmqkffgwyceskerkzdz	104	192
255	xzfinenvufooqqspmrknelree	162	976
256	gamivuttoxyuokkzcukiphumibgwbrgsumzfsnal	283	600
257	idfpdhqyonmnfuolm	249	809
258	tptbrytkcdshywqepbxyilxowelctytlfhxxznivnlfpaav	286	175
259	tuweovmyylordttkoqresppfaxcvzfagksuz	101	828
260	yvrbpdn	246	1075
261	phsemfinwayqobgodcbhewunggnvgwrsmrclnfhuvwrnan	187	457
262	fbbbscukiqmd	142	909
263	utmqzieggzmvaqtmzlbdmpcckwfcvdcqeaxblzzn	275	178
264	ddsnbxtv	236	341
265	fynuyexaaawfxruawfofmuwqdvbghgymzbrwxqzxwbey	253	989
266	nibhaarcnzhsfv	217	599
267	lhylosvumtugrnnchayudnzuwnncpwgpnhagrtcngw	161	339
268	vhzxkkwspixshctriidtobimxgzxulmysnqzmklelnsxom	259	546
269	ypfvyogwdeldthbrgfoxdt	227	288
270	epiqzvltzbowdkgh	162	473
271	caisfowsqiwkwehnlwpbleag	104	401
272	ysvyyokqzhynviblilnunenvafv	235	131
273	vftid	167	434
274	bpwyfnccagoynxovyoelhdsahkyrxpmhahlyhsw	254	722
275	hldcbnxdanswteuxlzgmhaqvhcyomqxiltrwhql	175	378
276	ydampqlcgzehmmrlgir	226	1021
277	xxerpzsyvruvwrkaikiews	166	908
278	ilifxptpiwnucusgumyeutitwp	263	906
279	ioegmtzraizthysnbogmqbvxvkmfduutropzh	289	653
280	yyalrquwmcvacawyervyxvwhyzprxrzgoqhupqnfmp	283	980
281	zvzppvchxqxdxiquili	300	721
282	sxiymqflacfa	156	1046
283	uwvrbimmapmtm	135	154
284	scmsxgichuldethlcsmfuqtxaxbmzsobb	258	707
285	vlawxteheyuekcckshgukyfpkxuzrsafvopqhzshxlew	161	429
286	fdkzateofzvzkhmiam	258	618
287	ldngzahznvcn	253	212
288	yhelgqawsoisehdwrrkqdnmhhob	253	854
289	ssmodunybeeyvlelgnpazkdotukd	154	950
290	rakbnggsnoahmnqurhktzpyocuskmpooal	149	376
291	qywslozyxrkihnnmtxqtzxwrmfwzeldpqlhcyulzvhbwn	231	718
292	ruarhoevwfortlsyyblpny	197	807
293	pqhtwlrpcnmttiitbppynub	126	967
294	fzfunfbbdrxmncvzcfcxzwsi	239	331
295	biqpdgmrfbehmtbukadquqpgeoulxtbbzomzbdbqa	249	311
296	hnmhdbflanuuygnbqfwbpzhtfvsttheiwparubyzumdkarbqfd	162	529
297	infevpybuxyacprvllgshhtslnvqmicqr	121	405
298	sbfhzuygyolkfhhbmmqhesb	126	773
299	nobcoyhagkzxzfyscaxmpqhgisbhlwa	126	461
300	fpyqxudyohspyqmsfmeutimbwxzsdlhpz	150	371
301	grhgnnlympgzlpktlrsxvreetlmiz	238	429
302	konrvfwzbyuvfvdxpynrzokqowmqhbnddtnxnlrdnibbbhbihp	101	670
303	ebrigplpxxonimdpyzkwlefdzuystqe	204	803
304	glpkr	223	1047
305	gkpurmexmnmifhotrwgwrnwhwpwhorgirpq	297	510
306	pexowygwd	271	772
307	skyxfbggbefkafykgzbmrahwtuloxxrfpnnbxgha	173	179
308	sqsfokeqxsrk	170	439
309	ofnfhdtouzvuznxcbzwyxyxp	173	1075
310	bopqnacdyyxzrtxaoesnefcpunicmxhybnpgc	201	952
311	glymatahpnpixamazyyulhawgyuphkn	136	126
312	qemasklldxshye	277	793
313	wrthwadcuiwiqzpdiwqyv	211	828
314	yszueya	195	1012
315	agcobeculqogtpytrknzm	300	407
316	elpgssengbrsgnfxpt	245	314
317	nedzmwgketwhtkgxvdlqzxtsuucvmuaztyprbaeexrm	280	903
318	moxozeoohsmcwnlbhaswlbzt	227	685
319	oyffnsywocdpupnvtyysuktyhuzixukrttmnks	138	1029
320	atxpslhykdggkkiwzxgxhwruumdvapvu	124	137
321	pxnsepoqhlnfqqmosnfmaoggnplr	221	494
322	kdbsfzbbcqteiryhbnkugepefhhthytsgutlmkvsir	190	732
323	kxfnyyrvbddvlfzdocqwwluawtgwtfvbdpxbml	127	593
324	zktwwnnrnaimetxgenydzrlhczorh	182	1065
325	mvmllmihbf	189	817
326	zmameyqsyutigdxxhfrznr	103	839
327	qrrudybipsfrbzsywukpocrbgewzkrlmsiqlou	177	775
328	pvvpaeyqntegiidvsbfqwdckaawviw	118	543
329	wgqsoyqewhpgrpawq	269	1036
330	gssvhvvuhfpodpcdqzy	180	729
331	llcnahefzzysngcbbylgfuxlafhpfxwyrrxgqsxnqfmliptog	234	1027
332	foaqldiihxvywimulqzqvvulmikvgmfllhzkf	215	919
333	xdorngvvsdfbivaucrmpeywixfqnwgadmfs	213	223
334	ubceqvepuzdqtporbzwhfnhbzttd	190	711
335	qgogtdyeoqk	170	1023
336	dnzofvqmckuilz	299	590
337	rssaoippuhfbmlbffzmbbkyagcblwtpw	124	221
338	mvdwglyyhuyexkwifmdtxhgiqdzxiliaifes	246	1088
339	xokvt	128	240
340	cafichxflwmmrvxbcdzfrlmhzmlnwdxglxmriayabyth	201	197
341	ziyebnqpdybggkrfeolxextuyqhehmuvwpkrebe	300	856
342	myepdcuhmkdo	281	105
343	ptgssnewxboyabhdpbhwthkbefo	217	161
344	ylecdhwtzhuzsticcomhntenvrqkksd	226	1007
345	tfvmykygkoovmkptksfulxvv	229	1067
346	hhnxelwgrnq	285	353
347	zgxwglscnlyzhsogpleqcpvlluvlmvfdd	169	172
348	uprmbz	205	227
349	wybwutnbftqodthzianrkmefboywnndxlxsnahodgt	229	209
350	edxvtbgqnbrvuxgmufihkcqfbfmolefoiqumevmnauhuyqmi	275	737
351	wwewwzfnwsrhkwlckyecnhxssrnqeaelvmfatrdbhlbgvw	108	895
352	aptsxqyqkupnnrxtpqerqlvgwkvxompw	274	735
353	urnrmawkhztwbkub	280	1045
354	fguzwxasuuhbkmbazzldapegthasntwpy	275	286
355	zpznvewwui	233	702
356	dyhnzhveuyueptcucmasnxizdqi	139	997
357	vudaaoxiceks	238	324
358	vuwbkvkkcityrhelelilafuuxvrthyynyukufuozggvgtzpqr	129	757
359	uxxykoflggcymkkqrxclklmdrigt	180	766
360	rufmddeexwdfypzhgdw	278	495
361	skaqivxeftppcpllhwrltokzyutmtorzdxgyqed	288	450
362	ikudnpcvfkrytyiftbzulcktwgivnpdntcdudqih	269	728
363	lcpwdndhsyezuarzvxokxcfasbuwlgdwgeim	200	1056
364	heeolrgp	166	751
365	qphzfkdvtnuycduqmsmbdufezlvthlwdvklcmgn	226	1057
366	eoqybp	262	131
367	omgzmoavdrfxcqhkbhwiihukdoqqgh	200	945
368	dukdrugmtfzsygrexuhhnyrw	117	1008
369	yzfrwpmktpxpvvbtrcyzhygdishslhuifoltdfldodftl	233	950
370	wobycomhywtdazw	248	379
371	werfuilqksrbeageozftfwobytvmpbwbpyyny	192	1035
372	pokypnrftwfhlfnqiwqcvhafisirklu	143	228
373	pozgd	124	787
374	lcegpbbkxtzmmzvketibbwihloilpirtkv	104	757
375	uifubvfnrk	196	129
376	viftkhxudwgbhmhidoqscomuppmkdyseh	182	605
377	xzbbagadeuhyxmpwccgreg	231	669
378	rnpmszzcscthgenppoicvxwlv	114	278
379	tiehpixvpexhnublpdmdicdfbpmkssazwtdw	228	864
380	utsdffgebkrtgswzakaqpusrhceflnaxlai	148	303
381	okxtilrnnxehlmixismberycvkohxizgxkvfygdmgzyngnwieb	186	551
382	fpezbncvkktbhcqhkvmtfeqmetvcvyrdxhe	223	153
383	nhnqavfb	231	922
384	xsgwl	113	139
385	qvldbwhuycc	108	752
386	iqcgsndwz	136	756
387	rvkpadmp	257	834
388	ulbeiyxduhzufblvsogqukguxvbbqzevfrcqeit	209	868
389	enwqtfbprdlnpyofbxxkrxkibab	298	437
390	mvbtzkfyf	143	130
391	syrllatmwkqyb	163	605
392	widyuxlvoqnpyssegbruoezuibz	130	441
393	wkniuczfmzymife	120	879
394	cdlaywmlqmcekmnwzqyabz	177	280
395	dqwturokxoxazrlvrnowedlcnefhvwuqihzmptnb	240	1022
396	luxcsmxiemkvebnkmcpxpxqsueduvaemihxseuprff	187	563
397	rpyyqttwkithsvozsgebxxbiyanhionspxncmdddqigkf	148	364
398	eoeqqtgronsgluapigswxofuwizm	204	318
399	terhyhhebfcdplbaafrzhbaf	214	1013
400	krhqkzqvgkyhywhyvxbvyi	181	291
401	vcqgubriyerdsdbltvdoztxdweyfzstytebb	296	598
402	xfkfpdshbxqqeydonansklmvyuokpbp	285	717
403	xreddqtcndzfqxeyyg	154	742
404	unwtyqbqlwrsgylp	218	290
405	zprmqzvtnhviviudaivfdemmigyubukqyodgqcgfdvhgwkogd	192	941
406	gewwucxfznrzldlbtviyxuzmlckvdwuwvhmvvlmpxqopiulle	187	1049
407	tecfurlcpcxdefq	259	248
408	pxtvnhvbofvenbogybi	150	673
409	axahbgazaavaeuaokrwrrulfflwhbkbpbgwwqvbvllcxsibwy	215	1099
410	zpysvpqfnltntzdemgckwqwkbugp	116	762
411	rsxqf	199	790
412	iohdznkwrrmbpydzgtuinopkssp	126	605
413	gyyzv	206	657
414	ysgyfcrobydtbiraty	173	1013
415	fbnmlapnuwdprumoomckqsdxlxwqtcbqumuanzovbpdtrkqcwx	300	165
416	bdbqthkyxdpxgbf	200	826
417	nhurockqdf	150	723
418	mdxngxndymyppkxdeoefsyygisnzkpazzalhaeuzfzbywdmz	161	102
419	supyhmwbmxaybkfctixvezfhkgfmreku	197	455
420	tckgsvfbayszhyzmxtkffqunhsafrymsenpsn	172	728
421	oxdswwyaacbftlwdtaursiwetscavlikfbrptperzlvxwtxqp	250	503
422	rpdaklkugorccafvmcm	114	656
423	llvwbtdqobytkf	155	738
424	ygstslmvssuaxbnyapublpitt	151	326
425	tmltflzxsyvgpxqtuwqxcsqxpdhshib	221	971
426	uraazprlqkrfwktt	177	843
427	ulntuvuitrnmzlaroovhggakxcfdcrdqxs	209	542
428	wtneupfsumpxvxlhrwiexnkhbihmkoaliapzaunlroydhk	297	1011
429	gbbtcmpxwkgokycpymbirnxlsecgqndvn	208	550
430	clngyodunpidkmusyancwrsrrzpkipkxxfgbcu	195	1028
431	wtgumasldsdkfafauarn	294	520
432	dshaqkocdefdlcbnqhlzxslqdclsvirvlcrltua	130	122
433	hebmddpxsbsqm	182	1013
434	fcvkpxzuywdnwrackkgevibeypn	107	213
435	uyzhzwesqmdxesdayqcdmtluhcczyhpfkdafbrhekixoickn	153	553
436	bnnuxheyeqkrzz	147	543
437	udgpylzvcnuwwol	110	789
438	pgfwzvrotmoiyvqxnoigyflvdfsdrmn	123	717
439	tntsedlcypupetvmbosawiss	159	281
440	dfzxennpcdtgubftmumifrqvwouakkadeqx	156	498
441	pmfegekyismzbyzevkdhsosztsxvvdgd	180	1008
442	chaslciflsutdbqcmbgcvfzetedpyfdmfdpxqtmprfcp	273	452
443	gfzftcnabqrlnvaooebbvurrbwebpr	113	1022
444	xqryaaiweppnankziqbebagmiklbktk	237	234
445	rbhkegssrpuuo	165	670
446	oahblxhviumsvrphefneqqevgikdsvxscdtdpbcnwci	141	1032
447	ertgoley	290	488
448	fpccmoxppdeplghlusdzifefgutmzg	241	565
449	feeucofemhkpemumlmsfhboyxlbqqwahcszewnqhtk	145	354
450	zqstlowpgnxbbdpwuzwpmwgfyotxizdkfz	257	271
451	gknxbkotqcsdwwbxxielsun	290	327
452	tnmsybyqdfpekegaohgtwgmzzoomkleukqmhdtto	294	599
453	puqufqxggbhacfhnlflklvddzaggkdeahnxwzsghgrvnfaafu	188	769
454	lzfodldmzunduosgpltmnmdw	237	1064
455	naeczaccdzfuaohcpwnkicbpovgisrxtygzomwdaxuulpsyf	246	745
456	ppmig	131	1045
457	uucyvcdarahifnicbswodmuzovpmqqvolgpqefqeitxccym	278	893
458	idlcbwqglu	161	1025
459	kgfplpcrrxptonknahxwuxezvmvwrludiytlhnwsxzoqhzt	240	674
460	xiqsdyhxmwfquyvq	269	487
461	imgvapmhtmceclcaawwlelxzotpsgwcumwbrrmqebh	286	1020
462	oupzqbblofxrvx	292	350
463	gbslxabwdbxlvdtuyogsnz	120	533
464	qxmrrrkyekxefmpdlvh	276	963
465	slabhqacoioxgzzgtrvqiuusrdlzoaggkidgwsfzggnl	253	459
466	ngaaivyxwoc	271	824
467	tibuezabfvsobmxfohex	208	154
468	ptqzlqsdc	224	748
469	grnaqpyrqcrigodekxgziylqeqygmripxmbhkrslsa	297	154
470	bgwkaxtcnysluytbnchtxw	202	136
471	mvymqupmimlwebizwgtqm	289	558
472	axmpf	134	254
473	zsznazrngwrnsytsmmdtm	287	941
474	yhfkfagmgchrvpetdbhi	270	938
475	grgszra	206	217
476	phlvuu	290	288
477	ghsfiewezmtidhszuxoahfiscdgxwmhcznxdvkcw	220	214
478	zocabaastfolamq	184	206
479	ttyoyqlxart	266	1013
480	atvklk	188	112
481	lmpgnoytfxtffcxomzpedhmgixfteqthsxohrghcuoner	168	850
482	swshtuw	134	501
483	zdkzhvccwublpvl	112	1034
484	qxslbwbewcmshcxltnuimtvxuimnvnietnr	297	426
485	gdecglkcyketkyxzhzfyhquqarchchuw	148	1008
486	elixyemhhqvhwosnln	126	762
487	bqimnuplvkpcokhctadxgcvrmee	298	525
488	wdqmkkzdwhgikvzseq	146	906
489	yzstghywxcgwyuyivqvrmewlveayeaxomegurmcs	172	1032
490	qbdisxyzsbhccddlzldwcdrquowgfvla	130	438
491	lgmskapeoepmimuvffhftvqqblvfrlahpkdlvhyuwwxid	152	174
492	mpnhmesqoglr	129	227
493	ftbnalx	164	242
494	oyqlcxoaqnhcfrkfqwqgtmm	128	104
495	ewkzoiu	112	196
496	qcuhyvawdndwweqlq	229	267
497	telaodgxnuplxqrqtkormwlbqd	189	719
498	dwimkmagfaztztbtpnibtaamfnbp	259	195
499	pqqzttltsnibvhgdrhgywrkypriupirgmzswcptwd	272	636
500	qtabziaftgukrgvxvdimqcsympftxotfwvpil	116	535
501	nwtcmimkzdqhdmimdcaprv	253	228
502	qapznivvndvqvdfwpw	284	202
503	ivkqoshxpzosbzkdkkelqxnneduenhsbpdawubenuuonumfa	231	742
504	yogyrhcwsos	190	600
505	bpkzvbpwvxudkrbgikspls	119	490
506	rpiqcoactlo	246	339
507	cdrnsygqey	217	429
508	kaghgqvdvviwzhrospdfoefqqinreelow	103	790
509	goklsmfyxiamkgmtymdotvlwwtokpkddbezso	204	320
510	eslskkvhadlotqthbohclencidv	285	451
511	nlywqdqsmrghu	165	855
512	grafcbff	225	705
513	otvxovxglrmonr	222	941
514	xayhwqxpyrf	116	452
515	tcouneeddurtrnhbewggdgnhmwyebhldmnqz	278	423
516	gdkmqobpodiphhvtxotlygwomzurceonchrhxftvzfierdo	129	332
517	pamslrfdeqybdkabnzglrmcihagemzlyrycpydtghzfssfmhti	182	871
518	lrmwnunktrdmuaaqgxheepkyodonnuthblrfndh	250	1039
519	xkpzxzvphzgcweqvffxyqlugwsbxef	141	972
520	qguyqhcemikmgwxhobdrhtztikyxrhvpdvpgh	137	598
521	alqzrvitttc	249	957
522	fmozxpikynx	161	235
523	qpzpduwcbcfucmzgmlxk	297	122
524	cmkvorcnehlpezhadiuwoa	259	181
525	vabmsgsdaepoxdbiblgs	138	291
526	osmyepidfpkcyrdc	134	908
527	atmaxqvfzloowugmlzowwhwxflsvancxnfxurbnzom	210	586
528	wfmlxayyxumiqfgonywsukh	130	754
529	cmreuhzheqiabcrylfacltyeh	158	992
530	iypkzsykmkcidtivvdfzmdvugzxltnmwrtyxq	299	650
531	ceihapclttndzaxdagezaatwnvzwulwkmmm	263	1081
532	aasoxfhxtbbofasuinodllsyuclezwryyorzctqgkrmdgigwsf	182	300
533	xheisvopchazsvuogdkofyx	279	775
534	ihcvpptepheklhenxcorikgcatsgmvbxxtodumkm	138	615
535	zpkzmcapdllidt	273	1077
536	dtilv	117	700
537	celzxvidnnmflkzsvvalvipoxsxxndyxiyc	177	562
538	xhuxebevgdyramezqrrbxoiixwdnrutbbteebzwfngzycib	107	343
539	phfeurvfbiiulxchtbfcuopqwezmncqnyvegm	276	480
540	ieukkgdplweimnitbpioxayusmrmfbhzhycqwtdzevfenqtn	133	372
541	sdkqfs	295	104
542	ltfcoklgvdsrdeuzegbuuk	274	911
543	xqpzhooiptgltogroauyoxqvkxmexdyiqvyy	165	555
544	hxbrdipczabcaaazpwggdptrs	259	657
545	bskffbecxoclntpi	165	621
546	yrvofcyvqsixklvovsxwindirtavzuhvczklresfncqofm	217	860
547	gqwwubsahakeouva	248	239
548	hyrnwraxynqrvfsxhkoxnuncqclrwsv	144	375
549	gwsantfiqnemxnyzlzhciigiqonrazrmcavewnfob	186	523
550	youppznooqxzdkicsyeiozmqy	249	639
551	nknfr	216	1036
552	lqxqy	159	609
553	ibykwfrswttvyyikh	278	1042
554	onezuufrlhwoyntubtxesuqwwcnxoliaoy	257	1015
555	yvhvoydryop	190	771
556	vzgafqdupdkwsoixnfkkxeckagtqxkilwmisbwvrqhulp	233	165
557	rzdwyzmvahewfankhfpdxlfgroqsfhwcpqgohscbflik	199	775
558	pytfksp	268	327
559	htnbuxmdew	246	254
560	mgtqtafbupwxmptigtvfarzgkbr	223	320
561	knqmxlewnbultnmpmxbkg	253	735
562	vltlmnlacpspekkvtrlyclmp	184	234
563	hmeyrlnboqt	192	367
564	zyugfsibcykkylbtdcrgngugzqhppcuv	198	1046
565	gxxqwabbmdxannokexzedxslb	203	210
566	thguqexuexudhbvhwuokttyvqnwvwbnvkzvbuuf	120	315
567	ieaonzlsflelvhsbettnxlsyusv	223	606
568	deulwqfaxroonifoyooqbvsqzak	250	924
569	ifgpqqmwdhywbgbihmzavtophkdhpdcra	119	151
570	nowvzudpsfqmptnarkxfmwfxxzwkuxeuamausca	276	743
571	hhvaiwhlqrpcl	176	708
572	shausalmvuxbnmnwecmvkmecodilntutxthpenmhy	200	281
573	imgccoywurw	259	553
574	kohutvkobqnvkbzkqndnedcbptczydrozhnfntugyfxrkkyb	238	937
575	mqiwvvzhmdrykyww	154	578
576	gusvundefdbgiqwdszvnbakvbnnywdqmcrcy	216	270
577	yoyooadrmalimyrvuiohxsimmnqfvgycvmotevaeduvwykg	198	317
578	ogkrrlgake	269	286
579	wgqdaooyiqmxaihiqyuliicsiragkwa	258	816
580	xryetsnz	187	420
581	xhqdnqfbqcftvnwmbvoybcqevtpppdmwckclaawvbbwbvv	246	127
582	iktankkzdwlrmmnmkexyzxzyalqvfirasqg	295	446
583	kntmyaaogvadrsyo	266	541
584	klntutzozausgmhliskogwubasobp	213	576
585	rosliqmdyvzfyemnkekttzehkcnufuuninmayci	109	698
586	vrondposkkkqmx	296	265
587	kcevbrbgnmwbkgesuwvsnnxomxgmxi	291	149
588	txvbwolbungxxaoroealyukpcqwwltmgfbrar	167	105
589	qgzorffidlshccdnxryanulpspzxlacbszvw	121	232
590	evyvtlkpdqiaeppyldxtfqitibuukqemfvcplcaphxrxnxv	111	458
591	dgxwgkfacazidpxgbvmxsotoavkmxdvavel	162	418
592	ahezqotrdbsgiqrxufuilqeqfcvyqnaphwy	154	649
593	wiohayaieddymdqzyufnmgwfqvgwadmcacbkkirgd	138	638
594	whsayncntlveylmvigtteehm	266	559
595	piiclhisyxoownrnnguoqxcvszfrczuacnxwizda	106	395
596	wqkucrkkovvhslvzdpnwhybomkkpeownqooxrrwrvxnsewcq	294	480
597	dfnmc	177	593
598	cksqnxnhanpweazyzciirgvgqqwgglxvrdpazzbsboghmrbgaw	276	245
599	zdksniylhpyaxgumkdokwhzmwscehmpvdkiqi	296	911
600	pqruvkiwutrpyp	212	117
601	pbsvicfpxppdyqmbrunvzhxayxrqrgzgghekoyfqlf	277	1099
602	aufnlmmattokkpgwt	238	901
603	hdtqceouezyhlqhsvkkhubzrpwepknldbelwlnpxldghagobvf	289	810
604	fhoaswllfazoos	260	295
605	gvbbddalumpsxufiilfszdfaxsuglnepymu	214	874
606	kknswuqkacdmnqwpcqrhbaqyhngkbvccdlxvqndcaof	248	239
607	khybglkxobnhtzbaecazyotffxqbbvfzsxykqfc	225	410
608	lwmqlofilkaxqardtvltwyghnf	200	641
609	enblkohlvaarmvrrkirkawqerhhnppnbgvepcfubsxpd	216	285
610	thkznylprtbctozpqhsyafxdu	170	950
611	vnagdmsbwmhntpapiiagioxbwnqfefcfbhodewbglmon	247	978
612	pqianbgulbvyxphmtpmbtxaxqtnenmhokma	135	299
613	aewzurzuxxsrayfqeishslebuldeiagtxnswabeknwq	170	424
614	stdrklvxhcseacihbmeho	183	1000
615	cgasiaarggzdaf	248	720
616	reiibdnqdqfduxvtgkltzufomynybkeglhfaketuuhlfnal	107	837
617	qbvehbiuaucuvrvaqclzgliekprkduspigcfxzxtkie	299	620
618	rurapdlszywyfffiquqxoe	223	956
619	omqqyuvqqnxswno	128	444
620	lubygmizunintpaeqy	181	1030
621	kebzemdhanwcpopa	238	408
622	nzgiqwdfvlxsseztzyfvleytxsobzlrnlvmyfqelwga	297	1019
623	rfbowsasmocerrqwodffmryyrrsfldlyhs	173	1078
624	hlmwehiumlfndmnsvpvluvzwcdouigkrdrai	277	718
625	vapsflknsgvcrbzcdzhyrfzvwpobyvf	272	914
626	ghhfohytohokqevxx	268	213
627	cdlfxytekqs	281	557
628	myqpsgnqpwqiclvhnbpufgbkrvhuqauymxpwzygloh	208	250
629	gtvmeeuahhwzqmue	250	913
630	spbdtfzueedmczlit	101	273
631	afeyuhrebc	278	756
632	yszertbfuypteyuhafvpredszxeszgtzrhuxr	152	246
633	sgkgizhnreie	300	468
634	ovctxrxxhmcxgwslsontzctmxvxscwirgylkvxxusfrlsok	299	622
635	ffvkbhnpwldbadqxzxeu	103	1083
636	toxkovkfpstdmke	199	1014
637	lmzaonhcwfpkyzqkitypndysoqwicawiglon	214	368
638	glsgzpctpxcouzvsohsf	179	512
639	fhoeykyrz	188	658
640	sihcrygfoifiidvdhwkvsbntmarwqybwywlxkppotnho	288	346
641	npzzzxgoyocqefzatnksymexsdrayydnrlmlnn	258	879
642	qvzkskvylyclkpaluqsdbwsoxohsq	182	499
643	cdckwftqmdnzabcizdrkpgumzxdconpdbyuvguacm	114	907
644	mtmqqrtctggiqhguapn	216	472
645	nvtovkizxsmh	105	944
646	moqkyxsbiyxmtzulmpsitq	200	554
647	dgzhvcsccwpc	108	127
648	fmlggedrligvhwonidxdflpuxcviztmmuwfrhfmbkmmft	191	923
649	esumcmdqrfuaigkzupssgn	191	880
650	epircfegiiuqwdnwxsehylkbgbmyswbibpgllvnlvefdbcyg	138	292
651	vfvwbdcqrxvzptzpz	181	209
652	ecwgbuscomulfm	281	620
653	seelulsxlgoaqvhrtitgqdcwdlhssfgghikbyuaanhen	221	216
654	oxzubqgbhqcimawbkdeoanhparqqkgqmsyhuefcnlzqyw	115	666
655	ycktsaefccfsakkluketrgecvzfpktv	161	323
656	ykfsttvleblngaqrftzrxxnpfriqraxurzenbxxhwqmtlofar	151	689
657	qrydqsgfhexvdfxge	249	472
658	dxqmrxrgaztp	245	438
659	vtvozscrtxyyfdiupgtonaowwpwzwfyyn	200	1044
660	wzsyogkfegeqzy	189	849
661	cxproqrzbhsvqdbezsurhznucnhuzhxwgln	290	165
662	bfymrnmlrlepzfukceabsszakfkyp	242	613
663	obouushefs	123	233
664	xawnskgbnrllymhdyarbbxkvufoim	242	691
665	dssexrdxylwggimzvwpqudph	192	787
666	sckiekvcpdaw	253	760
667	qfkvfuhcdoetumse	249	1072
668	tynntvahanufrhqzszefolqhby	166	968
669	pkkiznmctbrbgqfpdlfegirfgo	154	671
670	vwwtp	193	834
671	qodcztboanlw	278	677
672	pohbthhxvdhphumdtnvlaivhtbpueywnsvo	205	541
673	cbgdpdytmwzneoiedfemmgiverc	212	352
674	puatssycbbpaoxizocedimeaormufgcbtdugafox	216	479
675	eoqcidfbrlaqqipnkzxpubemvkgfsbbbcueczuhkrf	277	839
676	ifdymqmnchbxfacwqsxsbnilsaprgotks	290	222
677	yigtuvglylttfmhwmukqb	214	650
678	pzurtwisxqzuyxspqnlcheqstwe	169	927
679	ryqsgpd	190	525
680	ufvlvigwihastnhgearwndnuopqcpyvhdsomwpapacouic	141	258
681	vbffxaqcbcuhbisbkvfsqfxzphgwy	290	185
682	szgcoelulewgqakudyscwaslgxsxtqffipndbpmoltuld	247	438
683	lfuvcwixlkyabncwxvuwdwuxtiflcilkakbocdlqscrcl	175	660
684	atrrvikqdcfdmfaqksioonsqlvp	154	770
685	xhhtbxvlqloznvnfhudvfgtrkrn	240	1001
686	spoykwzhpavrfmplzcdubosfaidgltuurgikizedqfs	266	312
687	xvreolaqisuquvmixdnosoaf	256	1079
688	hzbuuplvhyuiekoxiuaostvi	200	283
689	dstiecbndiximgzxkgiaoaccvpifyffdubwrwvra	272	1100
690	gqdcpdlbitwphtpimsss	222	711
691	fwsatswfpnqqwdncwpfdawdfhv	121	989
692	nhlfwxorzobllciwoplpttvgdbrewdprtdfezdg	211	479
693	ghswhaesmugpnbgdmeqvuytzvtbft	283	840
694	weoqmvxvmraguwgxqplmwwlnphixttpqqurocymgtwlbseeogc	128	718
695	zlzybshuebxsevqubexgkvzzyymssxmirzwpdrm	251	295
696	iuytpnegfefrvnws	126	507
697	cuxxrdfmodgxnhhadobkiyvqwdv	145	456
698	hqtpqpcxpmuwdnspnyhtqhivluppod	209	754
699	irclxvhwlowwizoygioeqlyr	291	1040
700	lzpdcvpznkbhshdxahcvzfndeqsvuesqmtv	181	884
701	fwfcakxtrfkckshxvrch	201	536
702	kxppinhbrvwcgxaiipvcbpqiids	231	527
703	suuohiuoybifcezipkqdkuwvzpcceo	272	131
704	wotqg	286	415
705	hzlifmmvwwztkhmzsaqmaxvleawq	169	1092
706	bdrsc	184	1015
707	inpedhgpgdhhxcaevaintcxuvpfsckmbhubbrse	247	738
708	exwqcnlvggyioesxheufhurdaexklsefulwbculfh	229	1091
709	hsbsktznarqwcbeahksrnaqunyff	193	732
710	fycyreucmzkauioqbiitkkxfrmkxrlnpgrn	137	574
711	fewquuvmxozhzymihdwiahhwpbiutdietggq	151	187
712	xluysubdyimzilkedfiwvle	272	188
713	vscwzkfzryfvk	266	1100
714	dickyocsfbuwsqhvbqnugeuqdmgqwxnnpt	190	557
715	omscekutxlupstlmqsuewgtfqlbymmri	265	632
716	muaqxdcbgcurztldpsfzmxgtccnvqlx	175	1094
717	kyqthougalfxnxcxdwpfaupgkag	231	141
718	gdqihbzvyencemxzekodgbghutyxvzxdfgwwndtkcsn	274	118
719	hwgsxnaqkmrcxzgzsodcxyynstmgkaofpvwuctuqbp	257	421
720	vzuwmkql	155	501
721	bbkoe	165	234
722	wktcbaqxqkkqmpwuqirfrh	260	565
723	ktiktsfmw	179	139
724	ouhyaezehcdhevkwzzxv	103	183
725	gzlofvtaygnvubvxtsbozcuxhhzeotwfm	220	1061
726	eipumueaoxqxhezxufz	215	864
727	pmwqgmnvbl	254	771
728	wplzhywuvd	289	157
729	bqowlxogllsoaymi	283	739
730	qvfixowwsgeypxwcoefidlaavzhqshunphnt	118	219
731	nwxzoznpdvqzposmbqdxf	300	1031
732	nwcvmktncemmplyobatvllgpwpxv	154	880
733	dsyhbyntbyzenscpgbgevtzohsvzkyviavlvfpthgs	260	213
734	cypsntcmlkhuzrudslndxwsx	246	1016
735	pzqbvbdmbvvfnikkulkwzzaiutuyrghmxwxm	251	559
736	npmbslmtxtqzoeuyyqehnowccurnduqtznmggzdiegpztz	207	726
737	plifnlqtirss	262	1042
738	nvsdywxyqitfberqafgmhelrdbwpzukpgwsawx	149	528
739	nininuzyct	189	641
740	scczmcnkoewxgnikucrtuxcgqinsgivzrbycnlbutyniqq	111	199
741	xfygncrpyyakfacrgfwazdmoiiikhliybquqmhmnw	110	639
742	yucoizwostxyzeekvzdqkyuaqfdgxc	187	144
743	upvdqdierftelivxpdnihpcfhmrfouyaphadrhvcduwh	107	365
744	fafhbaoiygwcoootqtvvdzdbunqmufnhmm	192	953
745	yvasocwsaf	127	1068
746	bkssiseppsp	219	589
747	twinkednisrgebmpyblfgguhfnfgni	280	217
748	ofyhyhfiiotwhqixdwxv	120	115
749	smxirazsyiywdfwwhxsmxb	224	827
750	dmhttvdeswtkhyclewyockrslcmnzvfkn	154	266
751	zbaukradpffvkcnhdsfnzkwgiwzqwyv	121	149
752	mtmrqvshmsridxgoeiohsgcqppefzupx	296	522
753	mqxbcgyzogtfzoishbexszyhtoodmbgbogkzehexvxwcrc	109	511
754	grsdaaooizgrntfrzwrlwqtelfmcsqtczir	115	473
755	uvtrindut	142	297
756	fsxsfowbhswdmvnwfrazazxugbdwdpnuvcd	244	886
757	kiwpbzlwggucbxpqwhvpzugxzzqwzoypnmeabqyfhnyo	298	592
758	ztbxyzwitndbmkpafvsddihyvkisgksyfiuxreutwrxi	289	844
759	lllrlkrqpztoeuyffhsugahnpmnfasqcbgqweqpfimcnldnzfq	149	491
760	nmdezbfweiqzhabrrnopunnikrkbunzzg	246	488
761	awdfsrgpqnnkdaiihvqiempwfyqynklqe	229	375
762	okcdqxysepmuprhoikrrtvgpnhdaxxlbdiabda	158	335
763	awssgmd	151	673
764	lffotiygfa	274	645
765	daeepuitchsnfcato	244	682
766	vxfyyczqogwkmqfetemudetfift	122	234
767	vlghmtwlsyltqysrikinmhghaxltupfvrxa	122	684
768	lywaeqlancczgumakkvabpdpaqbeqehndtyiqb	269	450
769	xwvkffnubcenbfdheglusl	151	871
770	yhzffbawtevdp	174	880
771	codoirod	278	343
772	lfnlywcoidcouwmdenuwdhf	248	941
773	fvvbxktt	214	1025
774	zxobmuctbvediqkhvnxocrzpksoqkinfnigeertaefxrygmaoi	291	717
775	lalonmbgzccbonncpk	109	626
776	qwxldxswazlftxvqgqkwy	249	1057
777	cqxtqmznadlbiloceeurbvpvqugmchsbzvlzxbyswlsycvmyaw	160	284
778	rlztpncbvuzmaganlihwzxybgtipqccvb	273	904
779	viexoqrxupfwlztiahggvrkubtgyigvlhpfzhftfbsapc	145	385
780	xutryltngbwuwsezodktyskrevfwo	232	953
781	wcxqmbmddkkobgusgkvuopnknxztseoprtgbpfodhqpropdpw	179	379
782	pcgkwofswheknsxtlivxv	291	486
783	iglxkavtuvkypq	126	152
784	vmcyrzdonvuuulungygzvmtegbrscnnyvpkv	222	651
785	ztfrmxldoermvc	255	182
786	mlnimvmwqxsbisefyxqfcnbalxypiulpqbnip	160	719
787	xaexgoyvhaxsqodzarbhshqtkhisbwukplpoqyosxgxvo	238	800
788	oltalueeuqcsisfkkbxtymvfeaxubsvwkhxwhhxlgwccqqp	106	655
789	zlbeufosnwfafgr	196	167
790	ivrkzlnsooskyqslworsszwqnu	194	302
791	dwocihhocxwhpllvspxxkattmqlhyphhtyo	148	841
792	nddrxzkwdayhkkccuotzizccpthmo	126	981
793	ahopsdcquww	150	330
794	cumkepbmvdnsquhizvockactigywnhkmpzzmyikmnhxcv	113	641
795	xdfevibnzsiy	177	826
796	gkkqbfpdycfoxqeifyezamecgxwfqp	256	727
797	btzgvkwdgcnwmdegpzf	148	711
798	qobfpbvravuvoslwizpvntbfawkpcpqrsqudegkumall	221	461
799	pdiucmgsuhkvgaprvbxghnwbrnmrotbk	183	418
800	zqwqohfemmxzgvmbzrakufqynmtlkyunwlgrhz	228	1095
801	zoqgsekbxhr	205	741
802	kbenhnqryifqlayokokornnkpmargdmibpkgybeutufkcy	295	844
803	dmspaxdcyfprq	281	676
804	zxybmknbbuyvtbln	181	468
805	dgmbnyrdzkgpcgwelnvtmicmfmxuawqxobpsoipxomo	215	436
806	xmptnouqdfpebklyabniighpklgaxtgneihlyrtx	138	934
807	vwixzfg	231	109
808	xsgpbiqcztephhptvbvktgmekobwznk	214	104
809	frrdgzcuyycvywkxszokvhry	292	913
810	rlnpdgvakhegxwlcldrhhecsaooteuuoyoaixapor	289	1085
811	clbpltiiigrnlq	205	381
812	fhizxsoszkzvskekmkpyekwxmwactkiqhb	138	561
813	xhuyztuxnpdwsodaizeixwnatkydvdkbeittkfclwddelhcu	278	558
814	gzdcymvwfunabyipplwgilwxfqiolwswszekgt	284	573
815	msuduzqpzqffqryefkoyytpevamrdnfmeznrhhmt	175	617
816	wllhscdcirwvaiocwzcumzdnmcfzwnzhlikben	215	886
817	utmbdfaztvavtmnsrnsopwaxbqpfyhgtohaqnaxuxffqae	231	1011
818	utdgpnagopgyhxnglgacylypqofvyxrnxharvminatayxcno	156	694
819	cvdnqqrszbmyativfochb	272	204
820	kunvdnzfsblrqiodpwzqpzri	290	715
821	ohdqnymlsccw	159	891
822	kslaskbuoxqlahcmgfhcougxzqlnqxbnsrcn	193	538
823	mxcwuksuuhikblsgdzoauzfz	184	652
824	cfrxxngryilw	122	846
825	ydtafrcofcbdwsqtwvr	299	369
826	aghirthduwheucwlqexddk	271	286
827	sematqcdemtlbgqdoloeetcmppugpu	151	550
828	nfuititvgfpapthqqrdlcbstplnqeorvoyennqpo	219	625
829	pochiwirzmkyndfpneqmogihdcnimyeei	112	427
830	qivkpucbqllxluqkemrixwycd	221	519
831	xotlpkuhfxappzpaldyyqqupkahrhgm	129	161
832	yuzmssbhgaspkvryfczltsalgooiogdyfkfmlqek	218	610
833	pmqnkxliukezdkfathaapamcxqonfrfs	203	990
834	cvhirrcgvssrak	224	327
835	atzawklhq	278	832
836	adpbryqebyuwixpzcyudtmc	117	852
837	panxbhebvzewpfymvp	117	674
838	domuwzgwhhcwyiknfohstwuzfr	167	374
839	zyokvtwyiiirtgvmdezznaptaurfoftfxpsz	186	231
840	olnfdrgshgkhtvdqll	247	1078
841	cskikugwkwkwlzbpzbttxozwmirzxxahfvzczzq	110	199
842	ovqufs	187	631
843	kdfxptwvhiqyniswxgffudc	160	156
844	cnoelhutkddtodsxxdkfrcwxhtfuowwixohhrxxgamrshqxv	246	466
845	tmfhpeawhtwlatbabhmnshhgzzsp	290	926
846	zmkpxschyhswzmslozfzrymtvpzkiun	145	953
847	qluadfyszxyaxumnxscdtrlxvaaytxunlkmhudheco	278	805
848	utynkqeyeqntxidgoykizoiwyquopbvypbq	131	936
849	fctneosrrsinubbzhbovzylepdaoqhxhceuhbdfotqewdqey	295	317
850	saszqwgpqmdgckuqtfmielzhibplqdhghcfdgbrnlasyy	233	1032
851	mlhfv	283	915
852	yconvqyvcvrkdtsxsyhhrmcenibbfrzcboazc	263	135
853	lcnaqnehpsmtsokwaqwhlgmyqisypwwspxlcnydx	277	571
854	kzpkiweilihrztybicsiylslonvugeuyt	157	991
855	hketipyyxldoobcdvchhbsetuwxusoulgntcklzvfgkqpvkaq	262	318
856	vuwexmsefggz	170	522
857	wzapcqtbcqbuyyxsxbzveuzguthy	230	208
858	qczxdgebnmvkpidqbsroaqvad	273	997
859	heflhqoidriuhoiahhnnghikwrgyzryw	223	696
860	vavkyrdywvuoebf	210	362
861	ftgpbupralkbmic	299	409
862	wcyrkndfpzepaicoznpq	163	413
863	ibtcztkg	279	511
864	teohhqp	241	887
865	tkuksumkqzutyknvnghuiu	168	745
866	nqwblaenmk	251	972
867	kuoihfnpsflxvzfsqxzruexehpawayoboaadw	206	441
868	ahpzzpxavhqqgq	152	691
869	bdrpkyoehvbu	163	302
870	zvmyvfylghblqclfmpf	300	893
871	nuotrokrakzvceteppdrbraeihdclbgetrm	268	615
872	hfxnazstrdwpsdflyuomfxqkxszrlqhv	276	599
873	gkirygyoowrcycl	245	505
874	sbwls	243	727
875	kvqhwpbtne	207	616
876	zyntiszhipzuuhstcxnccaun	147	254
877	unqcxukwkueshky	126	648
878	xcihileurzbdofdnqdxcqeonrdmxorqu	232	830
879	kbwabrbq	144	241
880	gfywzapfadxdctwwbw	144	1041
881	coxxdoukiug	169	843
882	nbiudgvxunviekkbmdilkqagrkdttiqrolozrpmlnmnm	216	636
883	cunpaqzoivipacfefsgvlyugm	119	722
884	yksnfookgewlvnzof	277	690
885	cyqrbgzmpnutxirzpwcmowlcwuatcvodctiaa	123	220
886	pyqwabtodbeasliypzawtrhlyk	206	699
887	smblqx	120	122
888	kdzglk	201	648
889	yasxhagzzgvzxokseovbdcrneqtgvbaoggdfllpc	266	644
890	fqsfitvggliqalvtriufxcroi	204	411
891	dmoquhfnbdfbbdfwzfnktqkxcdxhghyevrvfwnznsdkb	129	941
892	fdzfvnvoamhzyyvmloweeuklltdrvvmxgrgqwivfnleq	172	102
893	pcgdwfixyokicyltfyuncgxydlrnvktiqbtnos	228	480
894	imhhcvviaacbrtpfmtnvst	276	882
895	oguozukxtriobdhbiplmrgcda	282	448
896	fipedbdsfneihzwharmarrpbozgsbnsikyxey	282	430
897	fhlgkgppqoqalygaqdblwzhqmzqfumdtfrwrrdymkbccnghl	125	1009
898	dsmlylloygbsaum	295	338
899	mvenyzhdfrtxowtrvsehwulmhzghgugufegzpalef	144	767
900	wgsfiqlkibocsmqrqcuqddqpxphmvsyaztkcofxgdvli	245	721
901	vaxquyafxszizuhobqdelgolydietznek	247	125
902	oimaubhgunnznofkbunubbr	250	696
903	vrfsbwgvsmsvwnfksufvmkbucm	159	1088
904	ftvlsavpgdcwayaozxluqqsslncsizkxdy	277	831
905	mccacedncfuc	187	179
906	vqkrlsvcizzvpbqlxtanqpptzigyicmqpotzgdyzckha	267	615
907	bxrcozn	166	541
908	tzrhhuvugynlxpzzgarawbpaeofybmguouqzgzaowfwhbmtc	120	765
909	zydipsfxqgnlnwbpabdlirzatogyxeyhfvtghttzv	126	471
910	wtygoqrtiaxdpcmyxalcbvloteatoefpkekzybentqlwuooc	103	597
911	wiqbdtyyveysymptmpkwakealmqnfhpdmnlxftg	141	802
912	spmpbecmautprakeg	108	1038
913	gtlbtazchmyxouesuyahpwhtddepvdgdkdluygnthbvosb	286	631
914	aoesipmlrcaggittictdgyaxoasiqltt	124	429
915	rlexkxhplpdkmxtvgwdmkwhxwspgnbkeeds	243	888
916	rcqkhrdbmfnoknmqzhbzblvzbs	299	555
917	rkhvniqylrlhqnkrfzikfeqcvsmtkzgmk	211	472
918	cuvxlmkgaibyabtfrvilpfxedqe	119	809
919	sdxuillnhelnltbhcpiouuycwvkargkoplisdyu	262	595
920	afuotiiem	136	171
921	vndkrbedmrtgmylzgsigbtohpmfwdozogwpuol	280	561
922	fqvgdaqwzwhuikiqvzevpnzaaxfqwvnypsmknythdupfkvvxm	169	326
923	auqrfzggzwnnddmgviihiyoluywtz	231	413
924	fdbktdqodyycavbdqxkzduugdhbkwtwpviasynu	212	483
925	twilhivvuzwhduiwnhoseiccbcyvangvnuupcvl	118	488
926	qivtsgclnqdwwvooagwtihlftirzwtznz	280	615
927	kprygxwenvanqlquzttdybrrytobkutoybuurdzhw	149	963
928	gvqdqswziyrgaeeedpzigfroyutip	277	586
929	ntnswrqnrdovzsyqbuzurzx	159	424
930	huozxmkuedeoumndawkaapmyvvstxhunyhv	278	355
931	inolc	256	505
932	pxstbgmttktap	156	1018
933	vbzmoyuatqlvwcxdhlfepzgucbnegddn	275	112
934	azeunlsckzlpmesoahcwdsg	104	804
935	qbwonywnbqbfiaedthxzwtfhfxlopikwmhqwqfxxlevoi	161	358
936	sagvqwmhfknfsibraslypmsguhcuulfvwiw	117	1028
937	kfrnbkvwzsgkmxtisidkscrham	223	302
938	ohzgzxeovllkxkadflqmyzkc	247	303
939	nwqclgqblachdvfomxgsstowdnyhvfottgdgapawgquyplloh	284	737
940	fpybqxhgx	154	297
941	xovanfcsyqmkasiytuyhswqdvbcplbf	111	125
942	lsvcrlxebzfbiayxkvtqeuh	146	115
943	zmrfeqxtoldhkzbpcvmylwdql	174	639
944	clpblevpewtqfukctxezcfmxpeuaqmfvbvaggixzifzaehhl	121	739
945	nvamglubcxzuopqfkpkmmlccpbwicmbdegrvdlxyqpkunrf	153	922
946	rpkuopfukgbsqntesnldwdfrfxcm	246	404
947	glrtwuvsrmmhsgmo	292	498
948	sdwlbncv	251	1057
949	nhutequhnexwyrvspnznnvawpmseroxlvswm	232	879
950	qlqyftcski	210	527
951	rzxwhfnnvlbstlmnnqexqdkknsxutscroickyrfewfqoelrxw	195	576
952	xqkhiuorb	286	1015
953	lsawnhbmbifmbacieqeacsua	173	1093
954	trgstybrxfvceowcdlygooeuitqcclzwpcfvtccg	137	976
955	gvfkagqdyylvksxmxhao	176	187
956	igtlrvwwvzhdlcytqwmazyndgtmlpmgbtcvxvgu	143	191
957	zqvivpzlgrlmqdc	287	756
958	xkqpftrxokubvxgytwgzcvlpxgzmbff	190	1086
959	rzvacwudkaysiiglurdyla	175	160
960	arddalbazkfnboxvqqvnr	177	827
961	uvyaiqcutmfzcwgobwbkwayhrzzwsmiorz	272	581
962	mybge	180	653
963	okqlrqiyn	146	1069
964	bzvqqfghglfmfopwucmefgnzdxzrxltwirpxoo	286	689
965	esqfmumugmxqrmtheyssrbwbzhxgiox	224	1098
966	gefoayphtcxpxaixlpwbwgsmxggyovqtiziho	222	199
967	vwkbuenmyfttzlgmzpsgvfqdrkbolvzvvzaxgg	224	179
968	cdnadzropqhwpsfyny	189	774
969	nelimlxhmssfkzkmrvkwlihl	284	431
970	ruqkxmmdykqdtfkopcntshofortvdeatfkkazdnmi	298	228
971	ypvingiqseovgqtxphdcuamkotyvhgkgmc	179	649
972	lbuhotfzfvqwacqkxaqehxiqqrmiwvrluhgndxkqdbilcgnko	243	1035
973	xuqahdyfbxcivammwfpgkhdyxmkgpsydkcdderggp	206	824
974	gdzasveihacfttwfmtfcvgvfgphokcfmupmahbobnwafnglzq	181	595
975	dchhhkdtseymwemqhgduasbufgznrmzsszzsczvdsbrcfbfk	104	1077
976	cbniwbwqgimfnnnqt	115	154
977	angwweidkxkbnxgdxguaufiwth	157	976
978	bttarvrwnahyihddxggouronwtt	158	1081
979	nrpxmvtauzsvthfppwkc	137	711
980	phytxodubsinrybwsraecdupcxkpt	238	647
981	xonlinbquzzecwvcvcigskxhnasmfachciwxqwqumfkrqo	106	144
982	lzesuuqiqbzzhldtamyco	174	905
983	doxiizxneyabzybbilibqghkqtsaztaosxgkfdeheyfnciuqlq	150	184
984	hlpfeaqlidtskhdgsypoglfkrbnsfaznbiczewv	145	995
985	smsmlvwupwtndlpmxqivklqyyzedxxybcpwrd	139	1035
986	blyoonatqvinmnhoifklkig	259	513
987	qetmfksuclm	136	542
988	fqsqfnhakstrmmmnuksgrzwazvvwfgkncrig	127	480
989	cbgcuhqwcvewqf	174	287
990	oihgiporxofznwdbfqlzvhgazqqhnbneaaezqiuse	132	924
991	fnbebhwmnpnfqrrerhkyzdsobven	236	905
992	oyroiawgzlbmxkbdewcivrmze	241	342
993	glvsmkrftwwbtcypnfbimdnqtyrmgivddtuasnwxkrwiho	132	871
994	xbxxvgbsccpxplpwuofrctpqwekakpygnqtpdtf	224	538
995	ecvrmztdniqundtsoobiaugylzkqlymyrop	139	660
996	fevsqbluvmdywaszukirblauumvdfctdtkwzrcxo	221	295
997	sctxydouvfzrwrlvuwnlccvszqmxsunrgaddxwueumhuxf	230	242
998	vfnvkefaxobgc	169	225
999	lvkswxazpcyvbynwlrzdegfmbxqpffve	198	723
1000	ekwpqafmf	263	1020
1001	kdfvkutgygft	188	902
1002	hikebdvzgupmfpkyyoyvrttilvceekqzmgx	136	117
1003	qlqzeazeotlzhxoec	112	288
1004	fggapat	105	879
1005	nkbmiqyitqhksasxtqnkdormmaovpdmvgovykrqizczzloxk	238	108
1006	iviiapezpbtutartihknluaafeivuwxukridplhoqkboak	257	948
1007	nvzwduqssnrnqkmyhikofimizy	276	965
1008	uxcahassrremicocsmfqrpkipgciykfkeeevvxrqtygc	275	578
1009	fqlonrevpzxtmpqolwu	286	121
1010	ignfxxcgadyezkmukwfhkcvzkldqxfc	127	1067
1011	xkooicptrrpaagedqbuxbuuhskkwomrcptqbnw	113	930
1012	bmvunocnmwbkdudxfplcfxitne	195	863
1013	ntnckdtivnhgvarrszkytlekkalmcax	281	1025
1014	nuorrzixpfpuxpetpvvuqtkanaerfggia	171	996
1015	imocavgglhcttb	255	363
1016	lmiptinfwqgrmeepwldznmnqgesg	252	388
1017	ldhnsgm	138	116
1018	hfcbpigyzikuguzavyly	114	985
1019	aiccwqyzgsnkfwwvivzinwzlxzbiwgokwcwiv	232	464
1020	cdpourcfcuzqmmcltz	129	307
1021	tgghuuugsobxnnegakdquflywtiebthssbtqhxkyomqsxp	205	731
1022	xzxvifzkbtwpqhfhwrkxytqhdkmblkegixazrokvqo	138	314
1023	mcmgtizoxhmbuplfynezgu	253	462
1024	iilhiwbtsihubiquvkhwoursnzawaazsabfzcqnzpleenkwkv	165	187
1025	aupafymltxlzksgn	152	556
1026	dftahbtlvnqrudbmllzlptmhha	155	1060
1027	nfenwlkiwfsbxmueydlfu	139	209
1028	fyhuzdoisdcczfxcmfipdguasidalyyktmfgsavcekmk	147	219
1029	kfhmbyegmmwvpaovsmqnfws	239	803
1030	gyazddkovevubtvpfpuyi	186	202
1031	zeocgcxliiwnlofguiwhqobycuqonmodutlhnosxiopc	112	488
1032	eoscfgaevmhetufuslndlucaeacasfovinwatvvgeq	223	528
1033	kvsvravki	222	1100
1034	uvfhpeusipywnqzoxtcuonorelevuayfwyxb	297	221
1035	pzkgnxnzqzy	161	1009
1036	fylrhhvaxmzgtihpoueepshdmhvriiqk	119	520
1037	eckwiqkfxksfihdsrmlnz	137	463
1038	ytgpeyamwfgczgvvgliflplsuukhshxxccbwsfumipkwxp	182	883
1039	qeugxyvllpksramncstvhemnzgvxrelfmsbzrtyob	267	137
1040	lkvuwp	175	562
1041	wmtfublwptsyahvtnoentydapaflldhdkqbwnyuwkaqo	138	790
1042	etgfzobyyhkotmegzrnpqas	257	373
1043	hfcbnagadksckqkiqgsfhlyzhozkpvroxbaslnndsqd	285	120
1044	eklhlerwhxmglcuirrgpnmcdgkpvfgzrxqd	197	660
1045	eyhkqaxdyrcrt	279	580
1046	ympztxkencrnkpgtkxocd	258	502
1047	oatrrxqwncpulvqng	197	839
1048	qctnyyqhqbokmtmopt	260	601
1049	pnlgdzkbogusdtdvpmqpyguuvvpqivcekppierpnh	208	977
1050	utsxrhwfywrsiafxldgfsyqeyhrsap	131	488
1051	sfnueutpf	134	742
1052	fqyxwfwawbfk	116	741
1053	ulylbiltzsyeqy	196	465
1054	opwyhlmkuthfkskqizzppuhssduxm	166	731
1055	aboleuhxbxmwpvqpnibclrnbrffoakiexwzwyvhdaxofco	146	980
1056	bcnxyyivcszuvfivhsnehwrhiir	234	106
1057	oozxyus	279	579
1058	kbbosft	125	747
1059	ntocerrsxncybsyrdxgwfuwufnvxfpapcqa	286	622
1060	xfupzseqgwkltsfplpiylkih	225	209
1061	euxgsadpyb	166	1089
1062	rmldobkxmandfolycigefkplrmyduuqh	136	935
1063	ingvhxiwmticdnmhuamoetwtqtsusfqcivccub	234	578
1064	cslqbou	174	907
1065	rhxmzawwfhzlq	269	653
1066	bcfxgkakfgoioygipggggnhtlygs	214	670
1067	aqinxqol	280	179
1068	vtkffbwfvgkebgcrkafqoqzegdxtyovpdxosrxz	171	283
1069	fsxmokvcasggiemns	159	895
1070	efyqklqhikmsknsbddirssaiqlhypplnesv	215	538
1071	tywnxkirezl	194	148
1072	sbskhnapticrkqlqqiybzdxnvvbylkw	296	481
1073	xcetkqegsvxrades	207	543
1074	adhgscylregrlupyflsrwvzzhukzqfphugdx	217	940
1075	udqxnranwvvbmechpvzrzs	159	861
1076	buicrwtittgwacrrqdaoctkqczyqqxdomlvfwmisswhqwedbl	226	568
1077	nggozfgyqytrpawurpelionharzsurvqsaqlzfsbsdlivexoil	179	230
1078	byelirqgicmnwgvaewcpuotpxvuzzyfqiats	276	594
1079	lelshxihtbwffxlkabvdraxlxtyycwcymxfaicrypqeyrraroz	143	321
1080	pnxnoobxnotuurhgcfnrzwecnltzkegkxmbck	146	467
1081	tgmxstacuhgiqynesglawpzyztduscoymddpb	191	431
1082	gzawgffcgkepiorfon	168	446
1083	lovpuzkvlmqkfvignbwtgqqleebuxgxcrmhygfleenrtvdiece	221	591
1084	xrodupyzonskgfuiqoroswtygtielqekplhckhc	218	665
1085	fembdf	290	628
1086	fxxikpgcixkvuqoauyofumaeszxpgzocgdozdoiymumeprka	133	280
1087	wvnlellxrrprotatfdmdhceibsqqbuws	188	756
1088	znxlrgbywfvarbgnkndrfuvqtvoyqwqtxfdtwlvufxrczzhdrg	167	210
1089	zovboavnogxqeaxqorqgzg	177	431
1090	wgxcszidys	278	922
1091	ngtstlnoxhfswgqcnpkixwoimtgit	235	1062
1092	sokpirlkrvbbfubezmkbakczqehbtpfamr	118	210
1093	vyxucqzblgfxulldghbxdrurdxeqk	115	128
1094	eecikbwwzgxqcbgqgfbatwyefaunw	160	731
1095	xwiamkpcqxlxgancrlzdxduhrwmmurkatcctxafr	263	1032
1096	lmmsnwursiirrqnmckfafmnbtl	189	905
1097	coonxdmwzftlohexiincrluqqureguublvyttasqhm	125	667
1098	soekzcudkai	214	590
1099	nxtryxuggyhotkzbfbbxhyodhotl	263	347
1100	mfzypbkezvaryszxfwonzrawtrxu	289	635
1101	dbqtypydgul	191	1071
1102	cbiutmzmnpchdeymsxmzfsenkun	262	839
1103	nhbgflqrcguq	186	519
1104	qtofsffyumkkwbwgkltspd	131	600
1105	fqrzszi	136	390
1106	ibrufadkhnktfivspls	153	206
1107	gisahhvkdbrbqbbhwwqrmwanpu	270	344
1108	ypvuymnyfvobu	249	909
1109	ewduhoabeyztdognomx	173	247
1110	vvglcilucvw	209	268
1111	tskwvlyghekmob	281	1070
1112	canytmwagteidzquzsftuwqpwpsewtnxrkl	155	913
1113	bmmlgzwfubiwczfenmyobhmlctnfbhnpbtnhwwxl	279	351
1114	ywtpiairagpudmksrwoefcouyhwpgonw	277	842
1115	clotacwxmqiwerhwndcyvluxmfihhcodvhyqhurh	274	377
1116	hufrbanusxbypqpqzchlfspsnuubzffbte	129	1094
1117	mttfl	104	815
1118	uzefdxxturlhyltwapomivemrvfyolmdpifzk	171	985
1119	owobgodsnpcyvhbynutwvmhbufwrezsfrzky	112	931
1120	fypgdkvzhbymgqclfpxmf	157	957
1121	tzdvxixe	219	327
1122	tukdysksiphhbspkrofzabqmercyplypuomkiluowmclhkx	205	761
1123	admtnfwcemsreofamfqapyweovssb	220	576
1124	gxnxyguysipdaiyvasuyz	154	1001
1125	yympgvh	269	370
1126	rdskmnwywxrkytsaiewbhnlto	204	1001
1127	ndovvevaygppcvfrqqay	207	700
1128	uoxlvuispyzpv	122	128
1129	fkmlslunhmboryib	243	737
1130	inbrvmodvscsaoiy	214	915
1131	papxgrhpwbzlhzxokwnwyzoyt	105	813
1132	tgsnpwcrrvx	137	249
1133	oqxxqvddaafuklwaztwnwhy	199	526
1134	fawmnwfetbhamecskzzsk	298	658
1135	yquflffclic	187	873
1136	dnbgfbmytwe	299	429
1137	toeyhxanzefruqvtkmge	189	103
1138	cyhabkzqeauclyylguvisfvbcwzrghqzpbbpvmrvcbnbsefl	224	415
1139	fxrvadvbfouyccurxxcvnvkepruypgfnhtpmyyprenlthz	124	725
1140	qnlswzwcpuxgymk	267	297
1141	qzsbeecohmptqaxrnhqmiwallhpkislsmmsf	285	789
1142	yhhfztpmfzpzetoktmnykhspbnwzxbmgdpfdgwqni	214	471
1143	cznbncrbbpmumuwlmaqwukxutsmauyclcastbbtcvau	199	1015
1144	uctiablagoltdrlxtbburrplcdemkwlvabawzshrypg	222	734
1145	eecnxqcngkvvmrxklasqedyegaksyatoyhspxqd	215	587
1146	ffykdxhgpetsxafzxia	141	706
1147	ruphdiowrbpiwwtfobiqbvqheoscqkrwibrlvlmguytafvqh	281	147
1148	bhtxbhzvrthgskiyqfovwiuuhlypvhgfcc	119	561
1149	ifxczmcnioqageplxeccgpmqqwzvsorwlazh	125	266
1150	dwcvtnzqrwcwzlvypulidaxnufbkfnauhvaig	168	683
1151	kacfptmxhkofnzqsdevxlhsdqrqmklfyataxgndq	192	592
1152	wwhukaboypgsqutwcn	254	638
1153	solcudmfrql	210	769
1154	byynixzuazzyplo	271	469
1155	iweuzhbr	167	929
1156	xcashksdiruudanpcef	272	123
1157	zhmzuogwdpppxdvmzornt	127	667
1158	wokxpbhxemteylybgtestzhcuzbztfpienwhsqeuiwyvfka	138	924
1159	wntoxyyygshgkpkerbhfnoiadaybmdoimnlxdamdh	293	190
1160	kwklgayvszgomwdmcstmhpkvf	120	458
1161	trihpkxgrepxqruaggrmunrpdgpdbcc	298	505
1162	flcrnmpubkrddsaoidqsmhfwbftucgzxeeg	264	580
1163	ltnrkb	268	444
1164	qnaruboqqbzuoimdadubbphrbcwgmnl	280	169
1165	icxhbipyktwigxbpgkykxunprckctpdbtybsoimlapoxyv	107	724
1166	rhbmntydxclkrtmrnwsefrdgsicsgkakh	107	955
1167	ayftpzzeyepesmr	149	779
1168	vbgxygveqwxkvtngvshzscsakwlcnfllakwpywaer	134	728
1169	ftfwqbrpqfczqnzibwwcbx	291	883
1170	ezuikskdmyvvfhbfrusfu	106	430
1171	ifwuphayiddzlkvxadsbciofwvcpqvfvwudwoh	182	948
1172	fmnzogcamrouimw	279	346
1173	doshxgyb	221	240
1174	rbzsboxdkdduamltcvpbhgaiolqivktszulxgdswaczikxdg	195	297
1175	bfiveonduekeqdhhbcymzkuoywtnsiuwf	187	847
1176	gcocisbsxfnmpdrfyu	157	1064
1177	zwpxq	255	431
1178	rclbdwhdwhbaovarupoczlelzkgdiihfqczfqrwbur	138	489
1179	vopmmmllkftcoufpwuqymyqq	198	728
1180	aqccfbwggmxplzbwiymeinldpy	150	997
1181	ztzmlaowpdmhtxqzfllqi	109	735
1182	ipomkmkqpgyyqxtzxzqdeqhghbgottyglxpus	195	910
1183	lthfditrwosmngskmwfpcdbptqyzfpp	173	499
1184	keahtdhlwdxlpkbbwgokwnsdwrxvywry	267	349
1185	cfnufsyrhfxxaayvphvkhxohns	216	410
1186	uonatkwoaldhvgruegtweiwhbfwublvyabm	178	185
1187	gfnarlkzsifvfqqzgnolwcfswzmwixswymaxy	260	912
1188	mxrafvkkuraksfdzgcphqzbybdadaphvgibdm	207	834
1189	xcssqexpibmlvuflvlnwlnsvwhmsyeczlqpsaerbsrcmyahl	106	646
1190	bapetlux	145	683
1191	mleltkx	117	935
1192	mukguoeoyt	257	909
1193	lfestrwzdkrivzoar	109	713
1194	mtdafigdsolxqcgwiuyzrhfocehsuruauopmzvflbaf	130	883
1195	awwkdubokv	124	552
1196	yxceqsoiaekisinpirpotgxyucfdnbnhxwaogobkbc	244	173
1197	wytsofgkqdpmxxrbtydykkditngargibxpcgfndso	106	360
1198	kxsdngroaumczyhxtlcwhhh	136	246
1199	awadqisqtvowklkdspizxmyugwqwqdnxdlctfiadhwqrkhgcef	191	1009
1200	xrfdk	211	520
1201	lykqthxzypnvvbcyonusckowaslvl	155	419
1202	tsiiffeimwkhkbegppveievfzaoaayiucgdsfrhcavtsppw	265	540
1203	mgelniiyredx	232	970
1204	fagdpvbmb	261	229
1205	tncdmketgbsf	201	1043
1206	czhvwiczfiphogzdxwbsuts	167	274
1207	nnkdxdtrutklzgmgbzcgupotsdlanpvnaqtnpgthotqvwex	120	776
1208	fpzvpzrbybnkwrgdnazmosrfmowlemhqcbvkixuyfi	111	596
1209	kohipwnypoppwntkpvplpeuhm	184	573
1210	rrcaqbzzsczkpdvtexudyqmyp	211	886
1211	ekzczfgyluratrsnnk	296	466
1212	aoacgewo	190	1000
1213	pfdquydzsiwbbzrolnrxztehzedimtzeqnfz	280	118
1214	zqluk	295	217
1215	iagxwkukurekcvnuzeywfyu	181	704
1216	hufykunhcsdmdkbhbxzulwhcxsmubtgiyedbypvlzhigbdbfwy	268	488
1217	zrrglpfpoflfylioo	147	654
1218	uftgbqvsehnlevihozwcfbnczwm	273	423
1219	iqvbqcwzwrk	195	154
1220	txzhqazchfdympzssono	176	676
1221	onfgqqvsg	288	1013
1222	yigvlrskbfrmdbkaerkv	149	548
1223	slbispxscqkmoclamahfkksexrdcqrvkkxzgcradwprru	281	120
1224	dtztdebqfwbbiglsddyvdbimwbrtesvgpgpipvytcqpumzmmx	271	453
1225	xykzgztkxeinerhxpulvgeqihyazn	104	434
1226	woqslpxuwpsfnlgkrldvfqpqrevkz	264	1072
1227	wberctoeofdexqonqu	295	558
1228	zicgcvkqefutnvcrxqaxalffkyfbqnxqgunucowpepbkllmlt	259	305
1229	nhitseucbsrphceieavwmoz	165	1051
1230	pratfxkozordlzfltulccqfhwpxitkornpubsqowi	145	654
1231	ndmuosv	173	698
1232	wuoyxqkybtqkwezlrammvdcvabrphaeeqatdbxsn	121	880
1233	nfcsawawouuuspeymppeyopexec	192	847
1234	ygargpgpgayvrnsbtnauavsczoqwzhmxagy	131	296
1235	tqxfcbmiwhckaneprbpolmrllkbfcvon	165	227
1236	wdkweaceytrt	113	449
1237	ylmcknkixnfluftt	143	1028
1238	qlunongssatzzuhsgirucxbzryoapadgzyz	250	686
1239	zlnxexzbesidszvrgztcpsrtyafyihcifmgqaeiupvdvte	158	881
1240	qykmkqlmuirdxyravfelwdivkoxzcsh	172	359
1241	glhhifdumagbgpfmnbfgs	231	1068
1242	tsilxsmwmhhlypqdzmvvo	265	1063
1243	lxfacadau	214	1081
1244	zfgxtndgatbobvneaullgeqfkcpwsonca	175	674
1245	pwymqwiwduvn	236	737
1246	dkffgpiry	125	494
1247	qktxincwkztgqqnooneaqoagch	149	654
1248	trzlfphdgtmhdcbbbtomdenzuykdxkxdccyg	267	593
1249	mswcwtpeawglhct	181	1051
1250	ivwlt	238	464
1251	dsllqfuvxtiggocrriwrpbnwbortucyuapskqic	118	521
1252	czrdqanvgfrrewyiu	102	861
1253	acmmnklxgrpwfanniglklfhxbqpw	237	618
1254	gcspomwxdi	172	937
1255	mgswaiihiwnuoycbqtmkgknddcanvmpqfo	281	474
1256	uenztpaxyhpecbkaolatmqdukcrqoxnsvneouodoyiyrtwkf	298	534
1257	kvkxitsxsasdamubbhqvvcmvrq	206	888
1258	fstxssgztrphkzcsqtcncazpmquqwqhmrtiy	256	681
1259	qtoukkzkezuvmiaplpwpdfsvfbldghynfciqacmaxhqfsb	251	108
1260	mfvvitma	114	230
1261	hheirh	266	409
1262	cutbazzwrffqczhgkrbmy	178	946
1263	vlrxrfinmdootldyutxurbrblbskrrybvaob	121	567
1264	wwryklvumnvghfyxxzumpoehkrsiihadlucqghttvlbio	216	421
1265	qszavsinwtrxdnnxkxfzhnx	265	257
1266	qqrksgzkhdnoinirxtzuvfubwouephfaloyu	217	857
1267	ktndfqhuvflfww	293	405
1268	lmphm	170	846
1269	ielsmpuuddilybaueksleuxdikefqsbhbxvkqhaqqluf	201	942
1270	ztoolagipeciomuuhgrffxuluzpfsycykdbxuvalwzgtxpkc	297	784
1271	vthmgttelxoqygnbvgf	128	915
1272	xqirkuuiquopcadbnaqbqzvcpglulqeptlorrd	210	699
1273	flgvyxpzcruptzkgmwniiqgdftuhqphtyanyxlfmnlqffd	292	396
1274	xhxwaohfppqsyqbmpgktp	294	620
1275	aytkoaabqusxuobxlhdtwoqfxgoeulvizlooixpfekfhgdl	214	267
1276	iciavfgttlvrthxcppqgkpeccutiywaglcicrzvlfgcepfh	298	384
1277	lykaotxdsxcblxcnqwxdmmur	191	232
1278	lnoauzgcbwrgxnrucgexmflxxgecuwqhumdelqrgcyg	243	549
1279	zodvcefctpughnammnqnrrsnamxwqw	217	567
1280	aygnoebadbm	252	330
1281	weehpoobndvceu	266	454
1282	vkdllcmwceyqgsbfvyowznowymuhmxyfaqzqhnzfuknz	232	187
1283	kqecudnfvmpscnrovvdgkacieipnqz	105	193
1284	rrsnblumhsfchvieglnsoxfohdigowol	265	1024
1285	ocqukoxpmlnrctgasegkholfagcszk	177	854
1286	zdmxlmgreezmaxmepaodbdhsdvqkhskszecbfisqdup	119	772
1287	nldhdbhkwcxftvghomfzaoiddzopxalorovqacfmsfxlo	166	1014
1288	fpebpoixbubhtxipeiqyvgkk	265	116
1289	szvgrrkpy	137	942
1290	rvfmiainnlraqzymavz	262	781
1291	rsrrnbdoezclivflcdxmgprgaamnlkiwyhawqfwrpmap	296	209
1292	eswqotwpxpzblgotatdyctel	148	1039
1293	osnencirdbekqzfzqvwyrtzfgppcllphcveghyg	293	604
1294	ftqxzmsadytxbpftdviutapop	264	816
1295	uvcdrgrmlks	262	204
1296	vkeexxiwcrqqtkoehpa	137	142
1297	monbfbxkdlnkabtuohwelfmbi	299	476
1298	rkbxuodrhadb	179	492
1299	ixhirxubfihpsmhgukguixxk	198	365
1300	waucsytwopwvfoztaekgcrqrhkwlyxnsrhwgmwbgpbdaubnlfe	258	1006
1301	oubekowmsyxn	197	1000
1302	oskurtsehmmqrbcwdhaqrgwboi	203	700
1303	xsvwbdbhb	236	431
1304	qwcaxhcqpkwdgphmrslltxqhdlfsgwktzuvt	109	467
1305	bhnidqop	167	659
1306	wkgquuhrrxtyledehmtciaooxcozn	141	540
1307	wiynznqlxuryqvpzpc	296	616
1308	zzhbwgcihczidgecydemuvffkfgiuasloretecwmribdq	233	510
1309	ueqth	254	410
1310	donyrrev	114	411
1311	beehfyieegslvedttretmdgbsimpaelwhwkiu	141	554
1312	zmlhzgrldkrsozxxzbvlnuzeqgfuqkewbqxcygotvdfivq	293	345
1313	bzsdxsaxngtxssze	184	626
1314	buxiesxutz	242	442
1315	wqhbqcgagozzcb	159	128
1316	gneqhpp	284	454
1317	mfyqhqwptrndynagkswvylnrtec	180	336
1318	bkufecevkefwzgymtmeymmbidgwdccme	117	170
1319	hxldvhgndcmgsexitphkqyqcbhsvvewutp	129	269
1320	lvggzs	120	809
1321	edyarzzazdegfakgoaalultyxmlwtktixsy	267	1097
1322	tzsuisrvctfbwslcrrwckwxpomezurexgwlzfbqtwwsuosn	143	741
1323	fvogmkdo	180	486
1324	ybyioawmlaklrrzvfvqgsaegbtzyfxnsctorfomqdnqm	189	375
1325	tmheqdlemauyrpohhxwykilfqzhidrfxsiqchu	192	621
1326	ubvghdwxkaykdrsbaakfregnqdicbssqtvfyzcxewfxxmt	207	789
1327	lqcfuhclxaykicdzoqylpmiispuveqdghshxelpp	123	401
1328	gnizhawguzatbltkauahwtonrzydsfxa	128	135
1329	zcaisngwvccaptzicxnaocc	217	926
1330	mtpfarbsfrbupqwymiltwblspoklxyloucwxhwqvo	206	708
1331	ppeoyuzkzhki	275	885
1332	swyftitnyhrzyhhwiczhzxtgkmrwphvdpspzdxgqipp	245	170
1333	vhwpyclmefucyciriwngfwmzqz	150	283
1334	ndhmuybfnuhldgpzatdcppxktxquuknguz	230	730
1335	iltqsqnc	188	883
1336	dahxcplqywkflal	233	491
1337	ieiizngpsxleiwopzlpmpzvbqlkprpxagpgmzshzurygcxal	111	173
1338	ppdlhumyv	127	1048
1339	qnrwwpvonodttny	152	265
1340	qtibbddbebheaf	132	208
1341	uflgmexkiswvraupqxyyfaxahemhpmyzwkbflllqt	172	766
1342	rqqmlfwtdvnxclbsfwytzzqsuxkztfpeawbvieptpphffh	196	146
1343	uypkfosxhyzzdwctzsvhyivducywtdysr	267	786
1344	rlilnnpfrfgembusdiaavneqqvdewsrpahlpdwaaqmegtcci	112	283
1345	epxyieebubuyyyidovnuglgaurtxqqgvlpekkihddg	151	138
1346	xxrrmvhikwmwgnepesxgpn	290	880
1347	zloicpntwimetspudemmdhykpivxxdmutqowcluyauratt	102	577
1348	nkveauldssxqixmqthrimngyyfcbanrdnhhlmbkakliznkpd	293	450
1349	rncgiikwpmerhifmngbriu	255	359
1350	upyclfibtmhxbfveeafdsiktwghptgdfbo	219	172
1351	rbsfrmsskgeyuqpmncnimpwfknhnuigodalkosckkmygqqn	174	602
1352	mksaop	136	859
1353	ymkgoyttwzb	240	219
1354	ylkwmtzyutpu	274	507
1355	rldnhzm	296	945
1356	ygcfaedmgpedehuaolnbpwbb	106	846
1357	byegiwitwmqgqprqdsgaeytxebwxnwsdwf	139	221
1358	zhvrfqpf	146	954
1359	bunfomukhlhfxdhe	172	397
1360	zckrukfzuvcwetxaoskdmhowampxpmqridornybg	211	811
1361	rmlacdoomtmkhwshlfhmwmavfplqwyobsbnesmplgqqzd	201	106
1362	qwpeumgnflnligydvhgloqfikvtwblliexgsmgvhecapc	249	912
1363	errqstlrmnedvmwyuat	217	258
1364	ozxsqffdhkrwkllotfwfargigiimkp	230	512
1365	cscaanzzpyyusokepfyt	161	572
1366	gnnubqqcfy	132	404
1367	trssfbxefarugwn	254	217
1368	xhrrbxhsmryupingndcrr	235	944
1369	dnutt	193	797
1370	ohrvxozolnrbngkxuiorrilnzxd	257	423
1371	twxibmdcfshxkkyqsktoeon	164	559
1372	inptcnleeelcufxdniactnpyxzcbxwyxk	126	1062
1373	sbkboxbdmdefstorgbnbfaxi	124	315
1374	xyqpukoamocfbrgpawfqhsyaelcdzmtmfnvvvgxgsmqzuv	276	852
1375	moayihufgzfcfnegonsnbhlykchctpcazbquvcpcglmkkdmw	278	262
1376	zzumtednywqucwwqzozomhrqvthvfoaeybchikusl	197	609
1377	ivqvilpbprwkdrfbuiyfoawzptpl	151	514
1378	dyhhbgipml	291	1024
1379	mrwsywfkcmtgykefuxk	132	643
1380	epurqzboaxuivthueho	187	231
1381	ebqfufbtbizycbxbpbfnrgayxnx	168	307
1382	kxezvmurefbfvduweasawkpgevixavxfasokxuso	246	1088
1383	uhehhyhopkwxqnbqppmaheambbrngehtoohxsxvmvlvhbuy	203	915
1384	rpzdqcuif	199	349
1385	mpilhsganwvgiswxyshmbiatzpumdkdtqhwulc	132	352
1386	nrqlprebfozcyioxuittcthawghdbniaqxapnwydcas	154	1022
1387	kmftihqkqkonusptiyhcnvrlvn	241	462
1388	sihpfrmynhxeyauagmpsvmoitkgdmzyhlc	178	1078
1389	boemupzhdkxqmdrmkdqdfgtnfy	259	137
1390	bsotzwxbgc	299	196
1391	mpnyi	268	697
1392	etfipxrfrmyoigfyehcxeuqwxssllnrrfhlvh	230	992
1393	ayuudnrzoqg	279	1044
1394	ynrpbhne	186	187
1395	oxqpwqeddvbpzbbrnuhqzgckawcdwkuewwahiqyudsabcwcg	270	232
1396	anblxxlvqwrutkounqmcrwesyiuwrrppiwwpxdxpznvdfcq	282	1008
1397	puogsx	255	805
1398	hqcssbr	226	1011
1399	tfkwobcnxfmclgytrliqywcbkirqdazfxnyzdaqefvnqsyfpq	118	373
1400	qxcfbsoeldtireugzntdtwkcznxcnmdx	273	470
1401	tnmnrfo	108	204
1402	czwoxrzvsuxkibaarsrzvliprlznvkdgysfoocrg	119	337
1403	oyweigbwtkesuwiwdaksflrbfauebzokmisukbwzalvsspmdns	108	528
1404	hhkkotrd	213	867
1405	zdxfwaqzldfrisgdnmg	186	668
1406	hmuyvxwbfezmbbapgnhcyk	143	331
1407	kfbrrgbchhwcukoznqhxvfyqpqstggtfwhe	107	502
1408	psnlxibrsnevnnzlcbzzdohqsrlpoobz	298	125
1409	alnzbb	273	808
1410	ttuycerqqomqqxddalhznbkcfzswviasqairyhhcmrcf	149	590
1411	hvkkseukhbuiplovkcgzyiddowmbrlx	281	245
1412	cwuvnquvradlwxpeygpgoswryyieytigkoohxbzuqvubfg	146	214
1413	zdsrwwqzvosikpodwyoeiwfuh	182	279
1414	wbhddrlhplpmmdapdbflwgryupiggvtoptdnzwo	154	893
1415	bpovohddeqlwscagzrcqgw	259	420
1416	wpinwyltckbxllxfmlthkantpucbusktobnhlyttmchqnc	208	706
1417	bdaqcdcnakpsgrzszilryldsvfifscfxmdxieqfipwykawx	274	646
1418	brohoknk	192	394
1419	dqsxyrqyccucqthlxegurqkwyouoo	134	364
1420	yntxbozvhxtiksniewfrvidxxeabhuaiugrxfkederu	193	731
1421	btkmalyfhogwnxsxhaymvewspxfbvmzhahcg	223	192
1422	usacwhdad	107	401
1423	hkcpcyxmptspxbws	127	593
1424	kewztrxtbupatgvev	238	827
1425	uiactgnqwfcyrcaoapovkhnmzlkrezgnfeoqvtpfrewtncs	288	569
1426	xbuls	287	589
1427	dyybtskfthywzwrukogkxtrvcnnfebhhyvkrynxpnfsghv	229	978
1428	dpdrtfqydr	123	937
1429	afzhxixbnldqknvlkokvkqnhzhxehunpewyuoxnnhpwsuco	104	116
1430	nzgveiuznbxfxw	111	129
1431	zfsfgoeregpmcugomnhkwcayqndokzwkkvhakmlbcgggyvmnbp	150	1023
1432	vzrffiixccmodaihpkuzgimbddckpbx	148	920
1433	lqptdmorbelzhiqzhldznfqtrxtkscmzuopqhaoasqcidfuex	219	319
\.


--
-- Data for Name: genres; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.genres (genreid, name) FROM stdin;
1	BStr331
2	DFac326
3	DRat5
4	CDee67
5	LSim94
6	AWau226
7	KBre169
8	DAnd193
9	BAsp400
10	MEll284
11	DFri158
12	KLig484
13	TCri440
14	LBam154
15	PSwi386
16	TDeB9
17	RLav233
18	HWhi481
19	BRum335
20	AJul240
21	ECro24
22	TGre237
23	PCre14
24	GRou230
25	ACri52
26	SSim430
27	LSim67
28	BPro266
29	RCol254
30	DDee115
\.


--
-- Data for Name: music; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.music (musicid, title, description, publicationdate, turnoffcomments, link, duration, userid, file) FROM stdin;
101	cmhehogtqi	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1983-03-04 00:00:00	f		00:02:43	101	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
102	rnlzywnfun	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-03-03 00:00:00	f		00:01:47	277	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
103	tkxbdhrhyo	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-10-23 00:00:00	f		00:01:53	124	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
104	ykzvomewya	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-01-06 00:00:00	f		00:04:32	250	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
105	qycxylbvgp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-01-03 00:00:00	f		00:04:42	267	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
106	nwvlsvyfws	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-03-26 00:00:00	f		00:06:58	161	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
107	okourremhv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2006-12-21 00:00:00	f		00:01:13	120	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
108	mydvxnaolb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-04-27 00:00:00	f		00:04:53	105	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
109	gksedtzhad	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1982-01-18 00:00:00	f		00:06:51	178	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
110	hiopetfkzv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2019-04-17 00:00:00	f		00:06:37	200	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
111	mcdhazabhn	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-05-21 00:00:00	f		00:06:27	108	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
112	sixchedfsq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-12-19 00:00:00	f		00:05:34	222	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
113	rdcurhdzdp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-07-07 00:00:00	f		00:06:16	136	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
114	mtgdimduto	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2015-11-05 00:00:00	f		00:06:36	219	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
115	gsushdmndx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1983-04-10 00:00:00	f		00:03:11	196	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
116	oawlenlgse	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-06-01 00:00:00	f		00:05:20	202	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
117	ywbvnlgwvr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-05-21 00:00:00	f		00:02:25	236	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
118	bsgmfheffc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1994-11-15 00:00:00	f		00:02:05	180	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
119	valfgecalq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2015-02-10 00:00:00	f		00:04:21	133	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
120	evmzgpguhv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-03-09 00:00:00	f		00:02:38	231	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
121	kgknqsqnai	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2013-11-19 00:00:00	f		00:06:51	193	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
122	kvysifsxuh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-09-20 00:00:00	f		00:05:23	111	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
123	czpvipyebf	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2019-05-27 00:00:00	f		00:06:00	134	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
124	zrtkgaydhl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-02-05 00:00:00	f		00:06:07	179	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
125	nvkpqavkxu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-07-02 00:00:00	f		00:02:28	114	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
126	uqpwlsuagl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-03-08 00:00:00	f		00:02:58	271	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
127	rigywoikrg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-07-08 00:00:00	f		00:03:02	294	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
128	ezdgedvdam	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-07-08 00:00:00	f		00:05:48	256	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
129	cmkdgrciva	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2018-12-26 00:00:00	f		00:01:03	110	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
130	pfncmflpos	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1996-11-24 00:00:00	f		00:03:47	203	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
131	cefrpmieig	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-10-18 00:00:00	f		00:05:09	159	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
132	cssxeqcgzg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2019-12-26 00:00:00	f		00:03:17	201	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
133	ozwqpkkqkz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-01-18 00:00:00	f		00:05:51	121	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
134	qpwvlweylm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-09-15 00:00:00	f		00:05:43	126	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
135	uqqoqkkniy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-06-14 00:00:00	f		00:05:46	108	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
136	kyeersmzbv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2013-10-12 00:00:00	f		00:06:37	246	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
137	tmipdclrwt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-05-17 00:00:00	f		00:02:39	167	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
138	bqowdtirco	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2012-05-02 00:00:00	f		00:05:42	261	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
139	stavgrtlsc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2013-12-28 00:00:00	f		00:04:43	116	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
140	tfvisyvrht	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-08-06 00:00:00	f		00:02:57	194	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
141	gwxmtoxpfq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-11-26 00:00:00	f		00:02:17	115	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
142	dnyihgzueg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-07-24 00:00:00	f		00:02:36	208	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
143	wiicxekzxh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-01-26 00:00:00	f		00:05:51	291	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
144	nnmsroevgk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-12-13 00:00:00	f		00:04:55	266	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
145	rvdfrbuvgf	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-05-24 00:00:00	f		00:05:31	165	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
146	sfnlyhtbey	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-12-19 00:00:00	f		00:05:54	204	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
147	glokhthutc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2019-03-17 00:00:00	f		00:04:33	244	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
148	sfrorrgxhe	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2006-12-08 00:00:00	f		00:05:18	129	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
149	bhatggzelv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-08-22 00:00:00	f		00:02:26	145	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
150	oudzzmzzpb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2006-03-01 00:00:00	f		00:04:03	287	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
151	aenrzkucdr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2013-12-20 00:00:00	f		00:04:17	210	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
152	erohilgxqv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-03-04 00:00:00	f		00:01:10	122	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
153	aorrrodcqc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-08-26 00:00:00	f		00:03:40	236	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
154	fdxxqavbop	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2021-11-27 00:00:00	f		00:06:43	231	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
155	ntaavzbaid	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-02-08 00:00:00	f		00:06:05	289	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
156	riqpzhrmat	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1996-12-12 00:00:00	f		00:05:32	149	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
157	boiqpsznbd	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-01-06 00:00:00	f		00:01:18	104	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
158	exuedvyimg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-12-18 00:00:00	f		00:06:07	259	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
159	hnbgmlkzed	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2015-08-25 00:00:00	f		00:01:25	226	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
160	kybiuugrmr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-12-02 00:00:00	f		00:02:18	254	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
161	athdbxbeqf	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2013-06-12 00:00:00	f		00:02:30	123	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
162	obzhzcslri	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-10-27 00:00:00	f		00:02:01	185	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
163	gilzfywdva	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-12-28 00:00:00	f		00:03:00	144	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
164	pydccvfwry	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2021-05-15 00:00:00	f		00:04:40	211	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
165	ygzwzxzvlz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2000-01-23 00:00:00	f		00:01:53	193	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
166	tfggugzvdr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-04-06 00:00:00	f		00:06:23	253	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
167	qibvmdkmbr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-04-15 00:00:00	f		00:05:51	262	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
168	ppuleotlwl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-01-17 00:00:00	f		00:02:50	185	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
169	orimrdbwxh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2018-05-23 00:00:00	f		00:06:48	254	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
170	poblaelxny	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-12-18 00:00:00	f		00:04:48	266	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
171	emrshntlov	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2019-08-09 00:00:00	f		00:06:54	202	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
172	xyyhysgkag	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1982-11-10 00:00:00	f		00:05:15	276	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
173	tstwvxdxow	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-05-06 00:00:00	f		00:05:01	300	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
174	socnvdoyrh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1997-09-26 00:00:00	f		00:03:12	296	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
175	cevvwewqqp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-09-17 00:00:00	f		00:01:22	280	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
176	zudxncdwlh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-07-05 00:00:00	f		00:05:47	250	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
177	myehxtawuc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-07-27 00:00:00	f		00:04:38	268	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
178	ullwrcbuvv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2017-12-13 00:00:00	f		00:02:34	262	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
179	dlvoafutwq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-05-08 00:00:00	f		00:03:18	170	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
180	xmyoqhvcvu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-12-04 00:00:00	f		00:05:23	113	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
181	epnobxekom	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-09-04 00:00:00	f		00:04:39	196	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
182	ncrveynfie	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-05-14 00:00:00	f		00:02:13	213	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
183	stpkeuuhms	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-09-15 00:00:00	f		00:04:09	113	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
184	onohdgyaqb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-09-16 00:00:00	f		00:03:56	225	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
185	zooyctgaac	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-07-03 00:00:00	f		00:01:59	277	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
186	abpahavobg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-07-04 00:00:00	f		00:03:23	179	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
187	havsmaxgtb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2010-01-28 00:00:00	f		00:04:52	223	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
188	iktsxlqczb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2017-10-01 00:00:00	f		00:05:54	143	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
189	axaqyzatwv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1996-01-09 00:00:00	f		00:02:22	167	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
190	dvrrtpliva	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-10-16 00:00:00	f		00:01:12	274	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
191	aqioropgpy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2020-02-28 00:00:00	f		00:01:35	147	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
192	tlezfyepda	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2010-09-18 00:00:00	f		00:03:26	263	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
193	kihaltcaex	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-03-04 00:00:00	f		00:01:23	159	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
194	kecbptwipo	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-09-05 00:00:00	f		00:03:39	164	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
195	gdzgvkmsba	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-08-20 00:00:00	f		00:03:44	135	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
196	xzvbowpfkc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1983-10-18 00:00:00	f		00:02:52	224	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
197	ssiknthszc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-08-20 00:00:00	f		00:06:30	282	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
198	dknalnhqrb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2013-04-24 00:00:00	f		00:02:33	131	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
199	ffgrvvbnga	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-05-05 00:00:00	f		00:01:22	278	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
200	rubvagzlww	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1993-05-17 00:00:00	f		00:02:05	139	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
201	bfwqocmxav	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2012-01-07 00:00:00	f		00:02:53	259	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
202	rvdmdlfahh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-03-14 00:00:00	f		00:01:10	242	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
203	ygwrrwzmku	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-11-19 00:00:00	f		00:04:01	216	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
204	zsoueizpdl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-06-15 00:00:00	f		00:04:36	163	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
205	gwpxctinxt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2021-02-09 00:00:00	f		00:05:38	199	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
206	uuaxndihoy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-07-20 00:00:00	f		00:02:53	210	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
207	fwymshrokw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-05-03 00:00:00	f		00:03:59	292	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
208	hizzdpkqvt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2010-06-06 00:00:00	f		00:01:05	136	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
209	aedzdncaxl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-11-09 00:00:00	f		00:05:10	178	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
210	unkkpkmpwq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-12-20 00:00:00	f		00:05:24	183	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
211	adwrwmpovp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2021-05-03 00:00:00	f		00:06:46	238	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
212	rprctzgvmo	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-11-19 00:00:00	f		00:06:10	143	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
213	ysncagtpqf	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1999-01-28 00:00:00	f		00:05:06	191	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
214	rosncqxlhr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1987-09-24 00:00:00	f		00:02:55	263	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
215	omlnsbippx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-04-24 00:00:00	f		00:01:23	110	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
216	maquhmtnzt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1997-07-13 00:00:00	f		00:04:27	125	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
217	kgkaaergnu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1999-05-12 00:00:00	f		00:06:02	115	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
218	mpfvplxwnq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-03-26 00:00:00	f		00:01:26	194	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
219	rykgirwfdc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-09-24 00:00:00	f		00:04:09	159	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
220	pprfucrxfr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2005-12-28 00:00:00	f		00:04:46	207	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
221	nlqhbhwitr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1987-06-25 00:00:00	f		00:06:45	198	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
222	proqzgueer	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-05-18 00:00:00	f		00:02:38	292	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
223	hsccgfqape	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2018-04-20 00:00:00	f		00:04:20	176	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
224	qtxycvfoew	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-03-01 00:00:00	f		00:04:33	164	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
225	vooxbouzib	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-06-13 00:00:00	f		00:03:32	222	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
226	tuxqvhgghe	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-06-10 00:00:00	f		00:05:07	185	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
227	dmcregxhwh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2019-05-12 00:00:00	f		00:05:47	278	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
228	nxelkcuaix	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1999-05-11 00:00:00	f		00:03:33	188	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
229	ekacmsbpcb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2006-03-14 00:00:00	f		00:06:39	115	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
230	aaeampxyrl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-03-14 00:00:00	f		00:06:11	127	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
231	bmtvyryldi	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2013-03-25 00:00:00	f		00:02:22	280	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
232	dvvsaufvhp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2021-04-14 00:00:00	f		00:04:07	252	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
233	tosqxqyyfp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1982-12-18 00:00:00	f		00:05:20	169	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
234	bxwwhlshxh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-04-18 00:00:00	f		00:01:42	177	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
235	fabffkycue	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-04-24 00:00:00	f		00:02:16	148	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
236	ymifwcbphz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1982-06-06 00:00:00	f		00:01:35	277	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
237	zkhgwslqbe	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-06-01 00:00:00	f		00:01:00	126	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
238	vlowrumrgv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-03-24 00:00:00	f		00:05:22	124	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
239	yfkvvhednt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2012-09-10 00:00:00	f		00:06:06	278	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
240	hvamwrgctw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2021-02-06 00:00:00	f		00:02:27	155	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
241	dbhtgwvfgp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1983-11-05 00:00:00	f		00:01:32	110	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
242	vwaodeeexc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-11-21 00:00:00	f		00:03:41	114	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
243	vpnwkpvrwh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-10-23 00:00:00	f		00:02:45	188	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
244	xoyfeztiap	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2000-02-19 00:00:00	f		00:04:19	214	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
245	kntbeowpzu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-02-18 00:00:00	f		00:01:57	122	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
246	mzzatyuyfk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1987-11-11 00:00:00	f		00:05:48	182	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
247	zvpxetsgvr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-07-17 00:00:00	f		00:05:11	134	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
248	cnkkvnindv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2006-05-17 00:00:00	f		00:04:01	204	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
249	wcwpaocxci	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-01-24 00:00:00	f		00:03:54	282	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
250	rtzmzoxeds	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2021-07-09 00:00:00	f		00:03:30	291	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
251	erwslemoyz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2005-11-21 00:00:00	f		00:03:43	214	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
252	vqvgzqxyhz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2017-04-15 00:00:00	f		00:05:12	250	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
253	pgmfwsgkcg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-09-11 00:00:00	f		00:06:48	139	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
254	csbavkzmuw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-12-05 00:00:00	f		00:06:45	118	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
255	nxdhwbrhow	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2006-12-28 00:00:00	f		00:02:01	275	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
256	nimdpumuep	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1993-12-23 00:00:00	f		00:03:55	196	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
257	niqptzdnec	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2019-03-09 00:00:00	f		00:04:50	249	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
258	cndgzckozs	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2021-12-22 00:00:00	f		00:04:44	245	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
259	ynleeogsiw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2015-04-11 00:00:00	f		00:01:12	149	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
260	oqrdiaoyfx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-07-01 00:00:00	f		00:04:04	279	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
261	mibogwqvgd	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-01-20 00:00:00	f		00:02:12	180	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
262	sizlwcywqz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-07-22 00:00:00	f		00:06:09	250	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
263	hbblzopttl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-05-11 00:00:00	f		00:03:49	133	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
264	huknbocptd	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-03-06 00:00:00	f		00:04:00	267	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
265	irstrwrbzy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1997-12-04 00:00:00	f		00:05:37	130	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
266	mawsfwfidl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-06-20 00:00:00	f		00:02:34	175	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
267	qpsitpbpav	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-09-02 00:00:00	f		00:05:19	299	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
268	mpvdiqqwpv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-02-15 00:00:00	f		00:04:23	231	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
269	iozvllhidu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-07-20 00:00:00	f		00:06:23	294	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
270	mvwlklgfky	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2006-02-17 00:00:00	f		00:06:09	270	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
271	fthntipzlm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-11-06 00:00:00	f		00:04:53	183	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
272	axovfuggwb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-02-02 00:00:00	f		00:02:52	199	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
273	gvkgqcxhuc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2015-06-20 00:00:00	f		00:06:40	228	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
274	soevipouov	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-01-06 00:00:00	f		00:04:00	161	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
275	bfhadaquel	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1987-10-09 00:00:00	f		00:03:16	240	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
276	mkwarpxqnu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2005-07-03 00:00:00	f		00:01:07	231	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
277	ikienvpnot	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-08-22 00:00:00	f		00:06:07	101	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
278	ubuxyyzxky	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1999-05-07 00:00:00	f		00:03:42	268	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
279	ktodptbcbe	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-01-19 00:00:00	f		00:03:35	117	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
280	sqgtwaygqm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-09-27 00:00:00	f		00:02:48	294	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
281	xiiclkgzbp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-01-21 00:00:00	f		00:03:15	209	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
282	cytdyspiwm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2010-04-26 00:00:00	f		00:01:57	194	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
283	vnmamuglfq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2006-12-13 00:00:00	f		00:02:11	169	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
284	fshwodyggh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-04-01 00:00:00	f		00:01:56	122	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
285	hfomeeattr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-06-23 00:00:00	f		00:01:10	141	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
286	thbclgobga	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-03-17 00:00:00	f		00:05:41	266	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
287	rcmqdkakvg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1994-07-26 00:00:00	f		00:04:07	157	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
288	vqbztnaloh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-02-01 00:00:00	f		00:04:22	127	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
289	nhymxcqpto	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-07-22 00:00:00	f		00:03:32	234	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
290	bxehiuftsv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-12-11 00:00:00	f		00:04:48	127	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
291	wzhqteqywr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2019-01-18 00:00:00	f		00:02:43	221	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
292	ggakxzbomv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-02-15 00:00:00	f		00:05:46	202	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
293	zcaubsqwus	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-11-05 00:00:00	f		00:06:07	267	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
294	imdbcwvglm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-10-01 00:00:00	f		00:03:00	153	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
295	akcohwzedo	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-04-06 00:00:00	f		00:06:45	203	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
296	zgxyxrwhqt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1993-07-13 00:00:00	f		00:05:08	168	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
297	xgcpokybup	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-07-10 00:00:00	f		00:03:52	111	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
298	ctlwykdqfa	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-08-18 00:00:00	f		00:05:34	246	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
299	vzzzawrdeb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-07-02 00:00:00	f		00:02:40	144	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
300	wndsvbpumm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1994-10-25 00:00:00	f		00:02:59	255	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
301	gnlemseiya	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1996-12-15 00:00:00	f		00:04:43	116	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
302	qopdmzmqer	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-12-19 00:00:00	f		00:06:34	196	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
303	spinagvtak	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-02-10 00:00:00	f		00:03:29	118	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
304	eirhbhtzyb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2010-12-25 00:00:00	f		00:01:39	257	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
305	soaadqnskt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-11-13 00:00:00	f		00:04:16	181	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
306	hkxeposetr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-04-08 00:00:00	f		00:03:00	152	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
307	wlvgpkuknv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-02-14 00:00:00	f		00:02:39	145	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
308	zhidtiqivw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1993-08-05 00:00:00	f		00:02:44	164	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
309	pakkhtmcby	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-03-18 00:00:00	f		00:01:45	266	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
310	decafuucht	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-07-07 00:00:00	f		00:04:23	268	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
311	fgdnbnztan	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2000-06-24 00:00:00	f		00:03:01	154	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
312	nkrbpoeabl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-09-17 00:00:00	f		00:06:46	153	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
313	stlgfdclwy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-08-08 00:00:00	f		00:04:58	201	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
314	yqdnoonwfv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2005-04-22 00:00:00	f		00:04:23	254	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
315	dqqaargedu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-08-07 00:00:00	f		00:03:00	271	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
316	mngqdimlfo	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-02-03 00:00:00	f		00:02:47	230	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
317	pgpmeqcdnn	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-02-17 00:00:00	f		00:04:26	252	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
318	sfewdggfse	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-02-16 00:00:00	f		00:05:21	238	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
319	hltezacgyu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1993-01-15 00:00:00	f		00:03:01	113	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
320	dnbffzlvug	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-02-20 00:00:00	f		00:06:26	198	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
321	ekzttownts	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-11-06 00:00:00	f		00:06:30	276	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
322	feyuvzvtzo	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-09-04 00:00:00	f		00:01:43	112	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
323	otwxtdolft	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2012-03-16 00:00:00	f		00:03:24	158	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
324	muyybubvqq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2019-08-12 00:00:00	f		00:03:12	167	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
325	rqdrcyycel	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2018-10-15 00:00:00	f		00:01:58	268	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
326	nhtxomihop	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-12-25 00:00:00	f		00:01:50	155	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
327	naztkkplgw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2015-02-21 00:00:00	f		00:05:50	208	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
328	ptgrnmdobi	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-10-20 00:00:00	f		00:06:55	185	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
329	cprqzpanmq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-05-04 00:00:00	f		00:06:24	295	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
330	unmzccxbii	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-10-11 00:00:00	f		00:05:53	175	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
331	hcwwqwlers	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-01-23 00:00:00	f		00:02:25	164	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
332	nuooqoclhr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-08-01 00:00:00	f		00:02:50	276	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
333	oarqnnvfsi	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-05-01 00:00:00	f		00:05:07	256	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
334	xnoxpsyycb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-03-07 00:00:00	f		00:02:08	192	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
335	qvnsoprcue	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-10-11 00:00:00	f		00:01:44	257	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
336	evddprebbs	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-09-09 00:00:00	f		00:03:50	143	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
337	omnqqtfgli	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1993-12-07 00:00:00	f		00:01:17	178	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
338	allgxnodou	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1999-08-02 00:00:00	f		00:02:59	246	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
339	savbrdafyv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-04-05 00:00:00	f		00:04:29	174	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
340	tpoqlawktc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-04-08 00:00:00	f		00:02:20	187	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
341	lrbhzxbviy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2010-06-01 00:00:00	f		00:01:12	254	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
342	lazczydwkg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-12-21 00:00:00	f		00:02:22	117	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
343	vfoprpyslb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-04-06 00:00:00	f		00:03:04	133	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
344	psxbavbucx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-09-04 00:00:00	f		00:05:54	246	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
345	gnqkagkxvw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-08-02 00:00:00	f		00:05:19	218	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
346	aipkfholyc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-08-06 00:00:00	f		00:06:17	117	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
347	iixibhping	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-10-15 00:00:00	f		00:04:16	234	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
348	zhgrshxesm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-10-28 00:00:00	f		00:01:09	260	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
349	qvfzmogzuq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2020-01-11 00:00:00	f		00:06:31	166	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
350	dbekgwozlo	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1983-09-15 00:00:00	f		00:04:58	193	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
351	qxkctvahth	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-06-20 00:00:00	f		00:01:34	245	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
352	cyznhpqser	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-08-25 00:00:00	f		00:06:26	134	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
353	zpsvomhrtq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-08-25 00:00:00	f		00:03:59	259	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
354	hovfnuesbx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2012-06-02 00:00:00	f		00:05:51	232	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
355	ptcqpdwclh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1997-08-14 00:00:00	f		00:05:47	245	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
356	cxiyrvsoti	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2010-01-09 00:00:00	f		00:01:18	228	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
357	hgsaflmtrm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2018-01-13 00:00:00	f		00:04:02	252	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
358	fvxxmshlww	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-11-17 00:00:00	f		00:01:32	132	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
359	rcgfzctont	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-07-19 00:00:00	f		00:03:07	127	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
360	spgkdfkshy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1983-07-22 00:00:00	f		00:06:17	167	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
361	esvoaynwmb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-05-16 00:00:00	f		00:04:36	171	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
362	lmrehxkkdw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2000-05-23 00:00:00	f		00:05:55	283	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
363	bsiutettnh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-03-26 00:00:00	f		00:05:11	289	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
364	rykdgvvemz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-11-21 00:00:00	f		00:02:20	217	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
365	ytblftcfbp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-11-18 00:00:00	f		00:01:01	217	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
366	vxtkyiincu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-04-08 00:00:00	f		00:05:53	196	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
367	ponvutspil	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2000-11-27 00:00:00	f		00:01:39	234	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
368	osvcqbzvhx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1996-10-18 00:00:00	f		00:01:01	225	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
369	uxykvrgmlk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-11-21 00:00:00	f		00:06:58	183	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
370	txpxzxeqns	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-05-11 00:00:00	f		00:05:11	154	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
371	czzzegrpmz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2010-02-23 00:00:00	f		00:03:42	258	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
372	bniynsowrm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2013-12-12 00:00:00	f		00:06:02	162	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
373	qytegzzsiy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-01-20 00:00:00	f		00:02:44	212	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
374	xnaumxkswi	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2005-02-10 00:00:00	f		00:01:35	158	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
375	ctfitiimad	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1982-01-24 00:00:00	f		00:05:23	269	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
376	ffsthgxsit	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-11-01 00:00:00	f		00:03:22	112	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
377	ohlppugbdc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1993-02-28 00:00:00	f		00:01:30	286	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
378	xrwrolkzdz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2017-02-06 00:00:00	f		00:03:25	214	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
379	dbmkobyhvw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-12-06 00:00:00	f		00:03:03	225	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
380	mtynbfncgn	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-08-08 00:00:00	f		00:02:41	290	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
381	pxflalcfxd	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2019-03-04 00:00:00	f		00:05:10	133	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
382	dotagsnprp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-08-09 00:00:00	f		00:01:18	279	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
383	evnfhhzfob	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-05-24 00:00:00	f		00:05:51	281	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
384	lorslhrdup	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-11-17 00:00:00	f		00:06:04	242	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
385	skztccmarz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-06-11 00:00:00	f		00:06:23	200	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
386	vuwtqfotqy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2006-07-15 00:00:00	f		00:05:15	156	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
387	yrbytmgkuq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-04-04 00:00:00	f		00:05:11	225	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
388	rpfaqumelq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1997-11-03 00:00:00	f		00:03:26	288	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
389	edermgkugi	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-05-11 00:00:00	f		00:02:08	169	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
390	icynnazyap	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-02-02 00:00:00	f		00:06:47	106	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
391	bnkisgtork	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2005-12-17 00:00:00	f		00:06:31	201	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
392	bofsuhoibe	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-01-08 00:00:00	f		00:06:43	120	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
393	iqqiqauars	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-03-17 00:00:00	f		00:06:40	160	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
394	yxicbuubpd	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-12-03 00:00:00	f		00:06:30	201	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
395	mgmnqvkgnk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-01-21 00:00:00	f		00:06:57	224	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
396	xofsbagxup	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2017-04-03 00:00:00	f		00:05:18	275	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
397	qqckxbzkcp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2012-03-21 00:00:00	f		00:06:26	240	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
398	gdwvqmzyra	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-02-04 00:00:00	f		00:01:51	170	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
399	qmgwwdgzfa	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1997-03-19 00:00:00	f		00:01:40	275	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
400	ytlgwrerdp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-07-07 00:00:00	f		00:01:24	250	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
401	nwwfcyurxq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2021-04-12 00:00:00	f		00:05:59	114	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
402	tdikpafrhv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-01-20 00:00:00	f		00:04:01	196	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
403	ofvgvdsllz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-12-21 00:00:00	f		00:01:11	201	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
404	dgrztyhakn	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-06-23 00:00:00	f		00:02:47	151	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
405	ymffwmtuqz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-12-25 00:00:00	f		00:03:38	206	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
406	fbiansdttd	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-04-28 00:00:00	f		00:02:40	195	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
407	yldlmhylau	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2013-12-11 00:00:00	f		00:06:33	210	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
408	bblzftniio	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2012-12-13 00:00:00	f		00:03:26	261	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
409	dppanqluxg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2015-11-07 00:00:00	f		00:01:43	120	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
410	pkeoteumbl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2000-06-22 00:00:00	f		00:03:55	154	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
411	tluyymbcae	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2017-08-01 00:00:00	f		00:06:18	284	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
412	oezknuqsky	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-12-05 00:00:00	f		00:05:09	209	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
413	gqbaapzlde	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1993-12-06 00:00:00	f		00:05:46	286	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
414	mfhpryxttx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-10-11 00:00:00	f		00:06:08	141	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
415	mfxaymzpuf	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-01-17 00:00:00	f		00:01:38	274	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
416	zoumyvndfe	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1987-01-05 00:00:00	f		00:06:32	278	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
417	ldbddkuvan	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-10-02 00:00:00	f		00:06:45	296	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
418	eexituyify	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-02-02 00:00:00	f		00:06:31	187	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
419	carrofmwvb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-12-24 00:00:00	f		00:05:37	156	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
420	ipuuylnwcq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2015-02-19 00:00:00	f		00:01:01	269	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
421	ggusueukgh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-10-01 00:00:00	f		00:05:43	189	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
422	fvfkkhwsee	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1983-07-22 00:00:00	f		00:02:14	195	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
423	wcmwidnhmb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2012-10-25 00:00:00	f		00:01:23	224	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
424	wakvzubhaw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-09-17 00:00:00	f		00:05:28	252	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
425	zczovpfbey	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2012-05-24 00:00:00	f		00:05:32	271	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
426	glnlfokkwq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-10-05 00:00:00	f		00:05:09	216	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
427	puucravhsx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-11-26 00:00:00	f		00:04:45	107	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
428	sfrrfnhdkc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2010-10-26 00:00:00	f		00:06:36	186	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
429	fowanipzuu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-05-26 00:00:00	f		00:03:05	300	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
430	ylhtishqid	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2013-12-13 00:00:00	f		00:02:06	165	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
431	lbgadzzqde	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-05-21 00:00:00	f		00:05:44	130	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
432	crupuwguxf	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-12-16 00:00:00	f		00:05:29	155	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
433	lqpaornczp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-09-22 00:00:00	f		00:03:02	159	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
434	sfodbxzsbb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1982-08-17 00:00:00	f		00:04:46	107	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
435	oxnpqtqwlq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1982-06-06 00:00:00	f		00:06:35	116	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
436	hnneiefrkx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-07-03 00:00:00	f		00:05:34	259	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
437	dkedfkhdvd	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1993-11-18 00:00:00	f		00:05:41	148	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
438	ocpnzibuyp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-05-28 00:00:00	f		00:01:27	254	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
439	dpzinwtful	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-09-06 00:00:00	f		00:05:53	118	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
440	tqwmuegnru	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-12-09 00:00:00	f		00:04:06	115	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
441	ehhuommbxi	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2020-08-17 00:00:00	f		00:02:55	251	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
442	ooxgivqciy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-03-04 00:00:00	f		00:02:00	268	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
443	hveuiaefwt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2021-07-18 00:00:00	f		00:01:36	252	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
444	usevgshkzx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2000-06-16 00:00:00	f		00:06:50	245	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
445	yomrteehcu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1982-06-02 00:00:00	f		00:06:26	236	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
446	tfkqirntai	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-06-10 00:00:00	f		00:06:01	212	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
447	rhislufcfz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-04-26 00:00:00	f		00:02:11	124	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
448	qtwmpaxiar	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2021-11-12 00:00:00	f		00:06:26	300	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
449	ldfdccpubw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2020-02-01 00:00:00	f		00:02:24	188	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
450	lqoxicugwm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2000-08-01 00:00:00	f		00:01:31	244	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
451	fbskftotos	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1994-08-21 00:00:00	f		00:06:56	279	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
452	gcgnryilaz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-03-26 00:00:00	f		00:06:00	187	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
453	rxwbbifvws	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-12-06 00:00:00	f		00:01:10	212	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
454	slnsqkwsks	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-12-05 00:00:00	f		00:05:56	161	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
455	lqoqpihuny	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-08-09 00:00:00	f		00:01:00	252	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
456	umurvmxewg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-10-11 00:00:00	f		00:04:36	169	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
457	wndcorfrnb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-12-19 00:00:00	f		00:01:37	138	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
458	rvcqparldn	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-03-17 00:00:00	f		00:03:41	294	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
459	ghlaqyxems	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-11-18 00:00:00	f		00:02:58	242	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
460	lwbxawuilm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-10-09 00:00:00	f		00:01:46	173	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
461	tnzuriklzp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2000-09-14 00:00:00	f		00:01:29	191	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
462	dngrnxymtf	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-03-10 00:00:00	f		00:03:41	245	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
463	hfinbkgxyu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-12-02 00:00:00	f		00:03:18	252	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
464	rrkkziobtt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2019-04-28 00:00:00	f		00:02:35	207	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
465	cpqtkkrlmq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-09-11 00:00:00	f		00:04:31	185	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
466	kkfmyxzwif	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-07-11 00:00:00	f		00:04:17	287	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
467	erleilewkt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1999-11-12 00:00:00	f		00:04:06	278	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
468	upsdgsifig	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-10-17 00:00:00	f		00:03:40	265	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
469	kharnygvhc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2006-01-27 00:00:00	f		00:06:24	105	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
470	kaygbiyygg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1983-07-17 00:00:00	f		00:01:16	294	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
471	kcvpntqspy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1993-04-23 00:00:00	f		00:05:04	290	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
472	itgprlcdsl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-07-25 00:00:00	f		00:06:35	156	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
473	fzaymynbgm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1987-05-12 00:00:00	f		00:05:15	291	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
474	eppvwmgidk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-04-15 00:00:00	f		00:02:26	134	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
475	qtcimzsree	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-10-24 00:00:00	f		00:01:45	280	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
476	yerafcnknk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1996-12-27 00:00:00	f		00:04:39	150	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
477	oygloezztd	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-09-20 00:00:00	f		00:05:04	291	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
478	zwxqwdvlaw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1999-01-11 00:00:00	f		00:03:19	287	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
479	mlzvroxpuc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1982-09-25 00:00:00	f		00:01:43	264	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
480	iibxzhmuvh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2015-07-06 00:00:00	f		00:01:02	291	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
481	qybwxngytu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2006-05-14 00:00:00	f		00:06:30	120	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
482	rnetyzogwt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2000-02-09 00:00:00	f		00:03:07	123	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
483	bbyboviwmw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2012-10-13 00:00:00	f		00:03:54	118	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
484	btufaduqoa	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2005-02-03 00:00:00	f		00:04:36	161	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
485	lyvdrfasel	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-03-03 00:00:00	f		00:02:17	257	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
486	xaaculxhaz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-11-28 00:00:00	f		00:05:11	145	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
487	fpmofuvxut	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1997-03-25 00:00:00	f		00:04:10	160	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
488	klwuimmccm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1994-08-19 00:00:00	f		00:05:37	216	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
489	nhkyfxplpr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-04-15 00:00:00	f		00:02:14	237	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
490	cxrvqtixle	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-06-25 00:00:00	f		00:04:57	205	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
491	auepgsilrs	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-06-24 00:00:00	f		00:05:03	231	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
492	ewhmwceuar	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-08-11 00:00:00	f		00:04:55	267	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
493	qylwrvmgig	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-11-19 00:00:00	f		00:03:52	147	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
494	mpvnkqgoga	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-07-27 00:00:00	f		00:06:00	282	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
495	ywbirbdhiw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-09-08 00:00:00	f		00:04:15	289	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
496	nkhtzgomao	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1983-01-24 00:00:00	f		00:02:11	259	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
497	bsrzoheznx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-08-07 00:00:00	f		00:02:27	214	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
498	tiyfmyywro	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1999-06-14 00:00:00	f		00:04:15	149	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
499	ybvbiwmfxg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-07-11 00:00:00	f		00:03:01	271	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
500	nmzaidxleg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-08-02 00:00:00	f		00:06:07	263	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
501	ihxpwayvuv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-04-27 00:00:00	f		00:03:06	217	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
502	vsqkcseeuh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-10-12 00:00:00	f		00:06:35	260	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
503	houpzpxkna	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2018-06-08 00:00:00	f		00:06:52	182	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
504	ykddppsnme	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2019-05-22 00:00:00	f		00:02:26	146	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
505	wvdxfxkhtb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2000-02-28 00:00:00	f		00:05:07	181	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
506	prfkhqytdb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1987-12-13 00:00:00	f		00:03:50	206	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
507	yirodgrvxc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-10-15 00:00:00	f		00:03:02	286	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
508	qtedlkszal	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-03-11 00:00:00	f		00:01:25	286	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
509	tnizhkbhnx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1987-11-27 00:00:00	f		00:05:24	297	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
510	qkbfnzpzec	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-10-09 00:00:00	f		00:06:57	255	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
511	fnzqkuzxtp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-11-15 00:00:00	f		00:01:36	140	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
512	wliklvllvz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1987-02-14 00:00:00	f		00:03:42	259	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
513	yvzgxivpct	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-07-27 00:00:00	f		00:06:18	279	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
514	pstkxpgzzu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-08-15 00:00:00	f		00:03:49	157	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
515	qcwrthamnv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1993-06-14 00:00:00	f		00:05:38	156	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
516	wystekughx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-02-13 00:00:00	f		00:03:24	148	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
517	dsunozzmsa	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2012-01-06 00:00:00	f		00:04:18	102	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
518	vorqsvbuyp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-04-04 00:00:00	f		00:02:59	296	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
519	fvknvfgkzg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2020-05-02 00:00:00	f		00:02:41	207	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
520	zyziefwbvx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-01-26 00:00:00	f		00:01:17	112	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
521	swkliecprh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2018-11-23 00:00:00	f		00:06:15	132	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
522	qauaizkoui	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2018-05-11 00:00:00	f		00:02:35	256	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
523	cnbwyvoywq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-11-02 00:00:00	f		00:04:20	117	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
524	sggbtbvtfv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1987-09-06 00:00:00	f		00:06:25	189	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
525	hartluhyvz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-10-08 00:00:00	f		00:04:08	268	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
526	oayhetespp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-11-16 00:00:00	f		00:03:32	261	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
527	obunlnwkvg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2018-04-09 00:00:00	f		00:06:27	140	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
528	zlldixkrrk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-01-14 00:00:00	f		00:03:17	186	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
529	shdqrerqrl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-01-17 00:00:00	f		00:01:28	270	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
530	tooksynsrr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-10-16 00:00:00	f		00:01:59	250	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
531	hcodbogpsc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-08-03 00:00:00	f		00:02:15	221	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
532	sxqqobbgaq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-11-08 00:00:00	f		00:02:29	250	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
533	otidffepbr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-04-25 00:00:00	f		00:03:07	131	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
534	ngtqzystyd	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-09-13 00:00:00	f		00:06:09	219	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
535	nmnqynskiz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1994-05-27 00:00:00	f		00:04:40	291	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
536	xpbzzcfted	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-10-22 00:00:00	f		00:04:02	215	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
537	ivgrniirqp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2012-03-10 00:00:00	f		00:05:43	258	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
538	ypavvaypwf	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1993-07-28 00:00:00	f		00:02:48	245	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
539	repqlqwymz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2017-05-17 00:00:00	f		00:04:08	262	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
540	psyaqraleq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2000-12-09 00:00:00	f		00:04:12	298	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
541	rhzkierxtd	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2018-01-01 00:00:00	f		00:06:58	233	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
542	pudxqvplhp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-10-20 00:00:00	f		00:06:06	183	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
543	znlqoqkvfv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1982-03-03 00:00:00	f		00:04:25	136	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
544	iflbtfeynw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1983-12-09 00:00:00	f		00:01:02	206	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
545	gcvfoimbto	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-04-21 00:00:00	f		00:02:54	261	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
546	ddwewxcmge	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-06-11 00:00:00	f		00:01:51	283	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
547	ogwpsishmz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-05-06 00:00:00	f		00:03:17	237	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
548	bsxvwpzzsa	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-08-22 00:00:00	f		00:05:22	211	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
549	qwfunrqclv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1983-04-21 00:00:00	f		00:05:36	265	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
550	ughytukovp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-07-25 00:00:00	f		00:03:41	175	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
551	ebyltpfvep	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1982-02-10 00:00:00	f		00:05:43	219	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
552	ialamrfyld	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-11-24 00:00:00	f		00:04:43	150	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
553	mgefxwbioe	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-06-05 00:00:00	f		00:02:38	169	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
554	cfvbfshzbt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1996-02-13 00:00:00	f		00:06:04	181	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
555	ycosuompfq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2020-10-10 00:00:00	f		00:06:40	198	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
556	mbbgqtzxmd	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-03-16 00:00:00	f		00:01:01	248	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
557	bnfpvawqge	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1993-02-26 00:00:00	f		00:04:58	157	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
558	prttyyisid	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2012-05-22 00:00:00	f		00:01:28	215	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
559	znrycsxhhm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2019-04-15 00:00:00	f		00:02:23	129	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
560	sdzggwuggh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-06-25 00:00:00	f		00:01:45	160	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
561	poqakuuzns	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2012-09-22 00:00:00	f		00:03:01	238	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
562	odlcrlzmma	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-06-05 00:00:00	f		00:01:20	297	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
563	puelmourvg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-10-13 00:00:00	f		00:01:57	240	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
564	kfmymxcluh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1997-02-08 00:00:00	f		00:05:57	225	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
565	bzglxkruup	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-05-11 00:00:00	f		00:03:50	202	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
566	ikygpszkmn	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-09-06 00:00:00	f		00:05:07	260	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
567	xrvsaydrze	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-01-21 00:00:00	f		00:03:28	121	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
568	soxorcwbzt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-11-25 00:00:00	f		00:06:51	279	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
569	cuekuqlgqc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-05-11 00:00:00	f		00:01:57	120	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
570	nespzcyqua	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-10-05 00:00:00	f		00:03:54	141	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
571	zoqytaowym	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-09-16 00:00:00	f		00:05:01	264	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
572	qakoalpnih	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-09-22 00:00:00	f		00:05:23	239	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
573	dczstzkqrr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-05-19 00:00:00	f		00:02:26	188	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
574	nuvswlhqga	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-09-25 00:00:00	f		00:02:23	201	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
575	pkqomckmnn	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-12-05 00:00:00	f		00:01:37	133	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
576	ayisowwphk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-03-16 00:00:00	f		00:04:02	293	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
577	fceaycbtak	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-02-11 00:00:00	f		00:03:24	135	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
578	mpddkvvioo	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-04-16 00:00:00	f		00:05:35	171	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
579	nwmqbtxlba	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-06-28 00:00:00	f		00:03:38	158	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
580	supdcwswvz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1999-05-01 00:00:00	f		00:02:43	132	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
581	rugioruvyg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-06-21 00:00:00	f		00:01:44	129	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
582	ydtopthdxd	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-03-21 00:00:00	f		00:01:34	130	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
583	dtfowwafrz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2020-11-18 00:00:00	f		00:06:13	157	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
584	oipuoqimak	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2010-12-26 00:00:00	f		00:06:08	137	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
585	tmssqrodrp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2010-03-15 00:00:00	f		00:01:12	165	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
586	vrbxkfhsch	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-03-23 00:00:00	f		00:03:36	116	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
587	uuvbgfecsq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-02-22 00:00:00	f		00:03:50	105	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
588	huaxqqummo	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-12-15 00:00:00	f		00:02:47	120	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
589	vsemoduhcb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-03-18 00:00:00	f		00:01:52	233	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
590	idwzukezhm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1999-08-12 00:00:00	f		00:02:02	128	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
591	hntyrgmzdy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-02-14 00:00:00	f		00:05:20	129	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
592	esuukuiicm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2019-09-10 00:00:00	f		00:03:27	112	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
593	sicpttualx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-12-13 00:00:00	f		00:02:25	225	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
594	iwpcwuvxaw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2019-04-24 00:00:00	f		00:01:30	207	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
595	rzuabrygdf	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2015-07-21 00:00:00	f		00:04:24	298	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
596	ahtmcvqhsv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2005-02-15 00:00:00	f		00:04:13	139	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
597	mygfitsopu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-01-05 00:00:00	f		00:04:42	184	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
598	znzmssnhiu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2017-08-19 00:00:00	f		00:01:40	170	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
599	muunznrmxm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-09-12 00:00:00	f		00:05:30	170	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
600	hhkguwxqeh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-08-23 00:00:00	f		00:03:21	123	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
601	nsthcvitam	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2015-05-12 00:00:00	f		00:01:09	166	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
602	ypgtlyybvy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2020-12-14 00:00:00	f		00:05:29	254	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
603	onvkyaxzef	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-05-07 00:00:00	f		00:03:28	190	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
604	whhnplqwis	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-01-08 00:00:00	f		00:03:14	218	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
605	smscmpwmiv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-06-21 00:00:00	f		00:06:11	275	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
606	rblskeckak	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-04-23 00:00:00	f		00:06:44	137	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
607	sgrwaktifi	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-08-14 00:00:00	f		00:05:38	246	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
608	reafzsanit	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-04-19 00:00:00	f		00:03:36	152	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
609	eufxresxip	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1987-09-03 00:00:00	f		00:05:57	252	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
610	vcizlvfxtz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2021-05-12 00:00:00	f		00:02:39	108	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
611	avnxsuenwn	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1999-11-26 00:00:00	f		00:01:34	264	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
612	slbxgycaku	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2010-02-02 00:00:00	f		00:01:07	231	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
613	yogsyrgpuo	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-04-18 00:00:00	f		00:01:09	119	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
614	mdggdncpll	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-04-09 00:00:00	f		00:04:42	116	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
615	vvvxebtcaw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2010-02-08 00:00:00	f		00:05:23	143	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
616	flfwbalscr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1987-02-09 00:00:00	f		00:04:38	198	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
617	wzkqpihsnx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1993-04-14 00:00:00	f		00:05:41	207	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
618	owwdqfpxvl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-11-25 00:00:00	f		00:01:29	156	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
619	fpqyhzvnwy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1994-07-08 00:00:00	f		00:06:58	273	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
620	vfyncwdhiw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2015-03-06 00:00:00	f		00:02:52	152	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
621	shshobenxc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-11-07 00:00:00	f		00:05:51	130	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
622	cwnpmiuzad	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1993-07-10 00:00:00	f		00:04:14	293	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
623	sfgwnlmuwp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2005-01-23 00:00:00	f		00:04:24	185	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
624	acaizxyysk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2013-06-04 00:00:00	f		00:04:59	264	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
625	vhapnddncl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-12-20 00:00:00	f		00:04:08	152	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
626	npcerybnpv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-09-22 00:00:00	f		00:05:12	127	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
627	puqxntldxx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-09-14 00:00:00	f		00:05:16	160	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
628	cgfzuwukly	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-10-21 00:00:00	f		00:04:34	104	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
629	yumbtlfpcv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2013-10-12 00:00:00	f		00:06:20	128	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
630	wdpetaxfco	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1983-01-20 00:00:00	f		00:02:28	133	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
631	kypeuqtrmm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-11-13 00:00:00	f		00:05:23	175	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
632	vizygpklai	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-08-04 00:00:00	f		00:01:13	221	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
633	labhtabhib	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-01-19 00:00:00	f		00:03:50	264	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
634	grzcaycngt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-06-22 00:00:00	f		00:04:52	235	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
635	ruzcpcrqdt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-04-14 00:00:00	f		00:06:25	125	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
636	ixmhrntldh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-04-11 00:00:00	f		00:04:44	238	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
637	bagrxpitxg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-04-19 00:00:00	f		00:01:38	126	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
638	ooxywophsc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-09-02 00:00:00	f		00:03:08	110	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
639	znkwlrgmpo	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-03-13 00:00:00	f		00:01:34	118	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
640	lsodeehdgs	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-01-23 00:00:00	f		00:03:43	294	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
641	rqfvbfqwdf	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-02-08 00:00:00	f		00:03:35	160	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
642	tfovsrpooy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-02-18 00:00:00	f		00:05:50	177	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
643	xogqxgxoce	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2012-04-21 00:00:00	f		00:01:28	233	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
644	epoyrxlwcy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-02-12 00:00:00	f		00:06:43	231	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
645	rmbnzmgbua	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-04-07 00:00:00	f		00:04:33	151	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
646	zqnsrxdklv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-06-09 00:00:00	f		00:06:42	216	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
647	wlirtmwysf	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-01-01 00:00:00	f		00:03:11	165	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
648	edacofivlq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-01-04 00:00:00	f		00:03:59	140	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
649	azvklqwrss	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-05-01 00:00:00	f		00:02:12	261	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
650	btmnypvosu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-10-02 00:00:00	f		00:01:36	111	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
651	kzsukowbsm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2021-11-22 00:00:00	f		00:06:13	127	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
652	iglhsrftxv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-03-17 00:00:00	f		00:05:28	190	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
653	byiffvhtbr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-06-13 00:00:00	f		00:04:14	255	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
654	xivigizpwx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-12-09 00:00:00	f		00:06:59	209	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
655	vpxctaotmk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-07-04 00:00:00	f		00:05:30	105	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
656	edqwshlrir	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-02-10 00:00:00	f		00:03:12	296	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
657	ngopbywaft	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-02-18 00:00:00	f		00:05:04	131	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
658	ikqgemseek	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1996-12-01 00:00:00	f		00:04:09	237	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
659	kxbyhvaqrs	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2019-01-17 00:00:00	f		00:06:26	111	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
660	rdzibxmqsy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-03-15 00:00:00	f		00:01:33	218	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
661	dndkpeyuhf	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-12-14 00:00:00	f		00:05:32	109	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
662	ztrlhnkycn	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-09-01 00:00:00	f		00:05:27	230	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
663	gqhkvvdace	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1987-09-21 00:00:00	f		00:01:29	146	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
664	bifbwlcvmq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2020-01-27 00:00:00	f		00:04:50	211	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
665	fnqbobobup	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2000-02-03 00:00:00	f		00:01:26	161	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
666	iceourvsqh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-12-07 00:00:00	f		00:01:30	253	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
667	mhgxslmlqm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-11-04 00:00:00	f		00:05:57	288	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
668	mzdzswndyr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2018-07-08 00:00:00	f		00:02:20	258	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
669	aosoukvbrv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-12-18 00:00:00	f		00:01:59	213	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
670	rvitvapqhb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1987-09-23 00:00:00	f		00:02:25	210	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
671	xpiihtgret	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-07-09 00:00:00	f		00:02:24	155	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
672	cntrgexuai	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2018-05-28 00:00:00	f		00:01:54	185	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
673	kwoasvtpni	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2012-01-26 00:00:00	f		00:03:47	150	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
674	bmxvqmuzwg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-11-06 00:00:00	f		00:01:12	181	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
675	ngqesedksa	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-08-21 00:00:00	f		00:03:10	283	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
676	rlvyowlxqa	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1999-07-09 00:00:00	f		00:05:22	237	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
677	rdvhackizp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1997-07-18 00:00:00	f		00:03:10	147	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
678	hidddtiupd	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-09-13 00:00:00	f		00:01:14	232	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
679	fzikhrdmir	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-04-14 00:00:00	f		00:01:19	245	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
680	kmybubgqwb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-08-14 00:00:00	f		00:01:06	191	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
681	rtkxufanux	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2013-09-22 00:00:00	f		00:06:20	122	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
682	eholghrtyx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2018-10-17 00:00:00	f		00:05:20	200	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
683	icuyidqpxv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-03-07 00:00:00	f		00:06:50	276	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
684	kqienilkas	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2005-09-17 00:00:00	f		00:02:21	108	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
685	zfigtcnwnd	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-07-16 00:00:00	f		00:06:45	290	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
686	sxxldvsrqn	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-10-28 00:00:00	f		00:06:23	231	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
687	dbreuuwnqw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2020-11-16 00:00:00	f		00:04:44	281	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
688	tcyafgoxrc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-10-05 00:00:00	f		00:01:04	167	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
689	tqqnivtvlx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2000-01-13 00:00:00	f		00:04:25	128	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
690	yloowmmdyv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2020-06-23 00:00:00	f		00:06:26	142	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
691	fyyddrpstp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2012-10-25 00:00:00	f		00:01:14	260	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
692	hzivplespb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2005-07-02 00:00:00	f		00:06:49	154	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
693	vtbxrhbafd	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-05-09 00:00:00	f		00:02:39	168	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
694	ezcbwbtigl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-04-01 00:00:00	f		00:03:21	108	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
695	alkuabkivw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2017-09-20 00:00:00	f		00:02:26	261	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
696	kdyakastsa	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-09-12 00:00:00	f		00:06:38	171	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
697	mnymdspgui	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-03-19 00:00:00	f		00:06:02	288	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
698	dyyrpstcxp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-06-20 00:00:00	f		00:01:17	157	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
699	usxnkqlkyb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-11-06 00:00:00	f		00:06:46	140	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
700	plpicphhye	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-04-23 00:00:00	f		00:01:33	249	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
701	ietwddzhid	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-11-15 00:00:00	f		00:05:33	177	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
702	vscwfoiezi	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-12-28 00:00:00	f		00:02:19	190	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
703	fyqodqcdge	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-03-22 00:00:00	f		00:05:57	157	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
704	qrhbaweooe	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-05-16 00:00:00	f		00:03:04	142	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
705	maawfolgnn	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-09-08 00:00:00	f		00:05:43	290	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
706	tyyhmzhbac	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1994-06-17 00:00:00	f		00:05:19	148	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
707	rzsnchohdu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2018-06-03 00:00:00	f		00:02:13	265	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
708	ndipudwokn	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-02-07 00:00:00	f		00:06:18	140	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
709	filhlmygnk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-07-07 00:00:00	f		00:02:34	288	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
710	cmthaucmfi	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-01-19 00:00:00	f		00:06:55	215	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
711	tpoqlvrahb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-09-26 00:00:00	f		00:03:42	225	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
712	beykyssals	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2020-09-02 00:00:00	f		00:01:04	238	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
713	vdigepcnbg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1996-09-11 00:00:00	f		00:05:38	293	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
714	iowbuqlatq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-05-16 00:00:00	f		00:06:53	172	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
715	cufpwgblnh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-01-19 00:00:00	f		00:03:51	146	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
716	kuueovzbxe	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2015-06-16 00:00:00	f		00:04:17	139	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
717	szquabmvod	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-02-22 00:00:00	f		00:03:48	294	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
718	glrdzdwuvi	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-03-20 00:00:00	f		00:06:38	284	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
719	hosbmfwhwx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-11-10 00:00:00	f		00:06:27	268	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
720	sedromdbyb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1999-04-03 00:00:00	f		00:03:57	200	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
721	rzuouvknlt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-06-25 00:00:00	f		00:03:37	214	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
722	dtzyeupize	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-03-06 00:00:00	f		00:03:00	170	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
723	cxacwufewq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2017-05-25 00:00:00	f		00:05:12	235	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
724	wrxupcwyuw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-11-17 00:00:00	f		00:05:11	278	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
725	sbeisdppmz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-04-21 00:00:00	f		00:01:13	200	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
726	lytaouxysy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-04-06 00:00:00	f		00:04:44	121	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
727	kfcszalize	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-11-26 00:00:00	f		00:01:51	220	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
728	vtgxxhxhmx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-12-26 00:00:00	f		00:02:32	112	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
729	dthecdsvli	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2015-06-21 00:00:00	f		00:02:32	263	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
730	vbqxoqfopr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1999-12-18 00:00:00	f		00:05:56	104	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
731	oukltyxebb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1983-05-24 00:00:00	f		00:02:27	200	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
732	qntfyhpbzf	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-12-01 00:00:00	f		00:03:41	115	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
733	oadfroqyxf	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2021-11-26 00:00:00	f		00:04:12	144	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
734	ryyydqezxc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2012-11-15 00:00:00	f		00:05:14	236	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
735	otbsobxdds	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2006-10-17 00:00:00	f		00:06:32	274	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
736	somqbcaaka	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1997-06-12 00:00:00	f		00:01:55	272	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
737	hhhfxqnwie	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2012-03-27 00:00:00	f		00:05:36	157	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
738	hbrltigdrv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2006-05-26 00:00:00	f		00:06:48	297	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
739	vgnmgodzre	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-05-25 00:00:00	f		00:03:15	214	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
740	ewkopsaqpb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-03-04 00:00:00	f		00:05:54	240	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
741	nwzztgzdal	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-12-05 00:00:00	f		00:02:16	185	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
742	lilnzyyfsv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2015-08-18 00:00:00	f		00:01:38	128	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
743	eveikexrfz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-05-17 00:00:00	f		00:06:03	232	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
744	kofnzixhmu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-01-09 00:00:00	f		00:01:35	146	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
745	gqqtywopcm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-02-26 00:00:00	f		00:04:55	287	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
746	excvadtpwt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2020-08-20 00:00:00	f		00:01:29	262	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
747	fsqclrenwv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-07-02 00:00:00	f		00:01:16	118	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
748	nuhapboxza	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1982-10-15 00:00:00	f		00:05:19	159	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
749	bsdeyqrloz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2010-02-11 00:00:00	f		00:01:49	240	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
750	dfvmwdsklo	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-06-18 00:00:00	f		00:06:14	131	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
751	pxlxuosvdh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-10-15 00:00:00	f		00:03:20	187	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
752	terlxwslga	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-04-11 00:00:00	f		00:05:46	176	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
753	lxzpinopra	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-04-06 00:00:00	f		00:04:54	177	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
754	kuvvdfzlgg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-07-02 00:00:00	f		00:04:37	103	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
755	svzfwhgsxg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-09-07 00:00:00	f		00:06:12	167	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
756	hhrmovnhyk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-05-01 00:00:00	f		00:02:44	239	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
757	rigfnpnhym	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-03-06 00:00:00	f		00:01:18	216	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
758	mzaupgxfah	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-11-18 00:00:00	f		00:02:13	290	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
759	wkgvtfisok	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2013-10-18 00:00:00	f		00:04:45	266	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
760	rnnvdhilnt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-07-07 00:00:00	f		00:03:35	190	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
761	dhdugyqzze	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-05-02 00:00:00	f		00:01:08	110	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
762	qaopvetaez	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-10-17 00:00:00	f		00:02:34	238	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
763	pqkubqwuzt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-06-26 00:00:00	f		00:02:10	297	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
764	qctdexaftm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-11-08 00:00:00	f		00:03:23	198	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
765	vpbskhpnst	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-12-28 00:00:00	f		00:02:34	251	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
766	hacbzshone	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2019-02-19 00:00:00	f		00:05:31	149	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
767	ylsyzqkxfd	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-02-06 00:00:00	f		00:02:58	196	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
768	toszxuihnq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1993-07-11 00:00:00	f		00:02:12	129	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
769	izacnhoubw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-07-13 00:00:00	f		00:01:05	172	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
770	ooubfmlqdh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2006-12-11 00:00:00	f		00:03:05	109	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
771	vpmbsahiec	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-04-27 00:00:00	f		00:03:06	258	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
772	utwhedaxxl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2021-06-20 00:00:00	f		00:03:13	103	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
773	kwylmeruiv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-09-11 00:00:00	f		00:06:15	242	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
774	ecvuqqzgqx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1983-11-22 00:00:00	f		00:01:23	179	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
775	pelcomarsy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-05-02 00:00:00	f		00:04:52	140	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
776	vvwflxzsqe	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2006-12-27 00:00:00	f		00:06:46	107	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
777	pwcysqkxze	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-10-23 00:00:00	f		00:03:04	129	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
778	pprbbfivey	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-11-06 00:00:00	f		00:06:09	173	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
779	xzzonkiaaa	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2000-08-18 00:00:00	f		00:05:39	168	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
780	agvrnrqrpc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-09-16 00:00:00	f		00:05:46	210	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
781	ewnocrquko	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-05-19 00:00:00	f		00:02:04	220	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
782	kadlsrsdem	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-02-05 00:00:00	f		00:02:07	249	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
783	gbplocvshm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-11-11 00:00:00	f		00:04:21	125	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
784	gftuppfprh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-07-16 00:00:00	f		00:03:19	158	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
785	yypmxdwdud	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2020-09-27 00:00:00	f		00:05:23	289	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
786	bqvehpfqwo	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-07-08 00:00:00	f		00:06:57	154	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
787	yyxaddgvuz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-09-16 00:00:00	f		00:06:27	227	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
788	tfmbuhrxqz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-04-15 00:00:00	f		00:02:53	169	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
789	ukpgheycfk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-07-23 00:00:00	f		00:04:13	239	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
790	pukyakxumh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2006-03-20 00:00:00	f		00:01:20	222	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
791	mgzxpqztzp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-06-14 00:00:00	f		00:01:02	266	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
792	avrdgmzvzs	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-12-15 00:00:00	f		00:04:10	140	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
793	ddvkpywrsc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2021-03-05 00:00:00	f		00:04:08	265	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
794	mwkiaagdit	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-03-11 00:00:00	f		00:03:49	177	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
795	hknorehprx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-07-08 00:00:00	f		00:06:19	136	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
796	mkivbyszyy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2017-05-22 00:00:00	f		00:05:20	297	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
797	cnoednbeso	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1999-12-16 00:00:00	f		00:05:21	203	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
798	tloypniiew	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-03-20 00:00:00	f		00:03:50	187	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
799	prokezosap	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-05-28 00:00:00	f		00:06:35	147	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
800	mwdototwuq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-08-05 00:00:00	f		00:03:27	300	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
801	qkkhplxczv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-03-10 00:00:00	f		00:04:29	223	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
802	niggcnottv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2021-11-03 00:00:00	f		00:03:44	113	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
803	wfstwfkkql	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-02-04 00:00:00	f		00:03:38	192	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
804	rzahwztaic	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-09-04 00:00:00	f		00:03:18	247	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
805	lrfeegshha	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2019-04-23 00:00:00	f		00:01:16	137	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
806	imntwrwnik	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-05-13 00:00:00	f		00:05:53	222	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
807	ukgwsliqwx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2010-01-15 00:00:00	f		00:01:44	257	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
808	vbcmhioovq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-08-21 00:00:00	f		00:05:02	242	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
809	reauvfrbmz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-05-14 00:00:00	f		00:01:10	164	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
810	ciyqtbanch	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-03-03 00:00:00	f		00:06:32	255	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
811	cqpsyfleil	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1996-11-13 00:00:00	f		00:04:11	207	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
812	vufsvawnid	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-09-10 00:00:00	f		00:03:38	128	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
813	sovnifytic	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-12-04 00:00:00	f		00:03:58	198	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
814	aipbdlqxdw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-04-22 00:00:00	f		00:05:49	138	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
815	gpkimvxnmg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-02-24 00:00:00	f		00:02:51	194	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
816	uarucsxqbk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-01-24 00:00:00	f		00:04:35	189	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
817	aepdcmlrug	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-07-13 00:00:00	f		00:04:53	283	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
818	zxatomdxgr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2000-07-28 00:00:00	f		00:01:45	148	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
819	cryfmqtdbk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-04-06 00:00:00	f		00:05:57	278	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
820	xqmhozphnx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1987-10-25 00:00:00	f		00:06:51	233	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
821	dfkonfowke	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-02-20 00:00:00	f		00:03:29	148	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
822	pgrmilabmy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-06-02 00:00:00	f		00:04:11	267	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
823	btkoyxzuzp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-11-03 00:00:00	f		00:02:34	138	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
824	dxukrnvrky	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-09-10 00:00:00	f		00:06:38	278	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
825	dxmcfsixnm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2005-01-18 00:00:00	f		00:05:31	208	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
826	anqszupigt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1982-02-06 00:00:00	f		00:04:04	124	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
827	szoxuwufqk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1987-12-19 00:00:00	f		00:05:53	123	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
828	syiohcpgol	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-11-13 00:00:00	f		00:05:22	178	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
829	dvfedqrqdm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-07-09 00:00:00	f		00:01:40	276	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
830	osnmvlbgmk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-11-14 00:00:00	f		00:04:31	294	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
831	swrsbltrzk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-05-20 00:00:00	f		00:01:17	174	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
832	hnusdpxvvz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1983-09-28 00:00:00	f		00:06:33	173	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
833	ufubnubrxu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1997-04-26 00:00:00	f		00:01:42	134	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
834	ncauwxphwx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-03-05 00:00:00	f		00:05:26	279	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
835	ibpbhkthnn	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2010-07-16 00:00:00	f		00:06:29	166	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
836	cstwveherv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1983-12-25 00:00:00	f		00:02:39	247	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
837	eivzpnyfay	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2006-08-26 00:00:00	f		00:03:08	103	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
838	lymoyffkwi	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-03-14 00:00:00	f		00:01:06	207	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
839	mpccbcedwk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-05-21 00:00:00	f		00:06:22	139	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
840	mlporwamnm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-09-07 00:00:00	f		00:02:49	111	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
841	qlhqbgdpgd	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1982-02-05 00:00:00	f		00:02:34	208	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
842	bepwplznuu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-06-23 00:00:00	f		00:06:11	129	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
843	qvzizynfop	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2013-12-09 00:00:00	f		00:03:19	128	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
844	amoezgezdt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-07-23 00:00:00	f		00:03:34	192	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
845	nsafcxbmvd	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2006-09-12 00:00:00	f		00:04:29	181	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
846	wzhgglnxeh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-11-23 00:00:00	f		00:05:55	158	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
847	yzrkfqklvo	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2018-04-25 00:00:00	f		00:03:04	233	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
848	dkvbsrwndi	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-09-09 00:00:00	f		00:03:06	283	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
849	ccvvyfpkht	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-09-04 00:00:00	f		00:02:16	236	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
850	ertiynfgkl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-11-05 00:00:00	f		00:03:01	107	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
851	lkcaxyiuck	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-12-19 00:00:00	f		00:01:30	280	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
852	vxayvmsaeq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-09-13 00:00:00	f		00:03:35	220	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
853	gmncuzdnwy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-01-11 00:00:00	f		00:03:29	248	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
854	xmzeyyrkec	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2012-11-21 00:00:00	f		00:03:12	181	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
855	nwksmmoesg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2005-02-03 00:00:00	f		00:05:34	252	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
856	atvxkitsvg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-02-11 00:00:00	f		00:05:57	112	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
857	wdlqaggmoz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2006-01-21 00:00:00	f		00:03:00	147	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
858	qdbviifgqo	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-02-12 00:00:00	f		00:02:51	276	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
859	qmizagnynl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1999-04-21 00:00:00	f		00:02:45	198	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
860	afkvhzsrie	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-11-09 00:00:00	f		00:03:21	143	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
861	gwcexumwhe	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1993-03-03 00:00:00	f		00:06:52	194	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
862	wzkqruxtnh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-06-10 00:00:00	f		00:04:44	117	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
863	ruvglheqis	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-08-26 00:00:00	f		00:03:13	256	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
864	hfxgszbvyy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1996-12-25 00:00:00	f		00:02:15	164	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
865	gvdgvbpqme	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2010-03-04 00:00:00	f		00:04:04	169	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
866	ehnimnosbo	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2018-03-04 00:00:00	f		00:06:41	259	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
867	ghbsouceai	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-02-18 00:00:00	f		00:01:50	116	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
868	vrhqrmptai	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2017-03-22 00:00:00	f		00:06:28	265	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
869	lwxelsnhpc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2017-12-17 00:00:00	f		00:01:52	167	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
870	trcnwpisiq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-11-09 00:00:00	f		00:04:45	268	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
871	cuwfgmrrhg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-02-04 00:00:00	f		00:05:45	128	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
872	ircfsyqkex	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-10-09 00:00:00	f		00:05:45	128	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
873	aokdyftuom	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-12-05 00:00:00	f		00:01:05	167	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
874	mszywqccan	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2013-09-11 00:00:00	f		00:06:36	231	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
875	yrcdaiwmyh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-08-14 00:00:00	f		00:04:18	195	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
876	yxxexmrtid	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-09-04 00:00:00	f		00:06:48	125	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
877	vzqwslxydg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2017-06-12 00:00:00	f		00:06:21	234	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
878	bnrmrfvkqq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-08-18 00:00:00	f		00:01:54	218	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
879	atstoldzxk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-11-19 00:00:00	f		00:02:41	167	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
880	evxxvitohy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-10-03 00:00:00	f		00:06:00	284	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
881	hzswlhqnbo	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-07-06 00:00:00	f		00:02:46	294	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
882	rgzhfipohb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1982-07-01 00:00:00	f		00:01:44	184	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
883	nqktrcnttx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1996-02-16 00:00:00	f		00:03:30	295	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
884	pobzpytxgm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-11-19 00:00:00	f		00:01:05	275	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
885	eefvsrtgpb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1987-08-17 00:00:00	f		00:04:18	284	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
886	ipdflzpwcq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-10-19 00:00:00	f		00:03:39	188	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
887	qidenowdqm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2005-03-24 00:00:00	f		00:05:08	284	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
888	hubvhfczrk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-01-03 00:00:00	f		00:03:22	199	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
889	fzhieyptnv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-02-26 00:00:00	f		00:06:13	109	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
890	zrpgufddoe	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2005-06-01 00:00:00	f		00:06:37	146	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
891	lpfalxrayz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-09-15 00:00:00	f		00:02:21	207	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
892	hzoksbhupb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-08-12 00:00:00	f		00:03:22	156	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
893	qdeurdcwko	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1982-06-23 00:00:00	f		00:03:54	176	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
894	hruudiqzpw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-10-07 00:00:00	f		00:02:17	254	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
895	gtmvqzsddn	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-02-15 00:00:00	f		00:05:35	261	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
896	zganfylobf	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-08-11 00:00:00	f		00:03:33	225	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
897	rpodyokofs	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-12-26 00:00:00	f		00:02:38	147	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
898	pbohydebxn	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-05-15 00:00:00	f		00:04:02	246	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
899	dfciwrbgeh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2018-03-02 00:00:00	f		00:05:51	168	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
900	livpqdzuas	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-09-01 00:00:00	f		00:04:15	218	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
901	faekvtphse	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1997-12-19 00:00:00	f		00:04:22	121	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
902	lvxiactmfn	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1999-06-09 00:00:00	f		00:05:13	169	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
903	yidnkruxoq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-06-15 00:00:00	f		00:04:16	199	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
904	xapghnltvc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-04-06 00:00:00	f		00:02:27	239	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
905	nydzekyrwv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-01-07 00:00:00	f		00:05:12	159	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
906	kyuqvexeqe	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-02-02 00:00:00	f		00:05:20	228	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
907	gmturzmwgz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1994-06-05 00:00:00	f		00:05:10	118	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
908	irrtifvkda	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2006-08-10 00:00:00	f		00:01:06	150	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
909	kodcelhahu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1983-06-18 00:00:00	f		00:06:56	296	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
910	mcftxrnwxm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-10-21 00:00:00	f		00:03:57	178	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
911	nziqnnxyxg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1993-10-09 00:00:00	f		00:02:48	162	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
912	ihxkosoxxr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1996-01-23 00:00:00	f		00:02:10	116	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
913	cnzrowrrrz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2017-01-22 00:00:00	f		00:03:58	212	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
914	lfkusdesqz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-06-08 00:00:00	f		00:03:32	234	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
915	rlhdybuqux	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2005-02-19 00:00:00	f		00:03:55	206	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
916	yrhinchghm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2015-09-04 00:00:00	f		00:03:42	151	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
917	nzythroutq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1996-01-11 00:00:00	f		00:05:37	218	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
918	dragvohzmk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-06-22 00:00:00	f		00:06:52	234	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
919	eirtluopef	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-04-13 00:00:00	f		00:04:51	270	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
920	bbrdlgaqvl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-10-18 00:00:00	f		00:03:25	268	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
921	ggdzwvgmwu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2006-04-08 00:00:00	f		00:02:55	212	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
922	qvlhlyrowv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1997-08-13 00:00:00	f		00:01:44	254	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
923	hknhhlfrib	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-09-07 00:00:00	f		00:01:25	272	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
924	rccsclgccg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1983-03-17 00:00:00	f		00:03:41	146	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
925	dcywvzhihu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-09-10 00:00:00	f		00:05:25	140	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
926	wdvneyilvf	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-02-22 00:00:00	f		00:01:19	141	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
927	nocamzqvco	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-06-13 00:00:00	f		00:04:30	260	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
928	svkuhcmfll	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1987-06-03 00:00:00	f		00:04:11	104	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
929	ifxvuxacuy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-05-17 00:00:00	f		00:03:37	166	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
930	chbpvvmngy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-10-12 00:00:00	f		00:05:27	298	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
931	rllbbdqkfs	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2006-05-14 00:00:00	f		00:06:20	284	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
932	yfzknkyauf	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-10-25 00:00:00	f		00:02:30	166	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
933	hxzxscawuy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-08-24 00:00:00	f		00:06:13	280	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
934	znudnyhndk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2013-04-11 00:00:00	f		00:02:56	107	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
935	mwedkvwktr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-04-01 00:00:00	f		00:01:18	199	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
936	ltvfcfbbmp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2012-02-22 00:00:00	f		00:04:08	173	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
937	ctukribltg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-11-24 00:00:00	f		00:03:43	176	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
938	zlwdfqstfc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-01-02 00:00:00	f		00:01:57	107	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
939	xxikxhbrpp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1996-01-01 00:00:00	f		00:06:22	290	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
940	lcvbgrpgbp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-02-26 00:00:00	f		00:01:25	241	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
941	evxehvwpxm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-06-13 00:00:00	f		00:03:18	125	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
942	specetywzv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2000-01-20 00:00:00	f		00:03:54	113	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
943	kptfxlebfx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-10-21 00:00:00	f		00:04:14	106	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
944	tsalwosytx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-01-08 00:00:00	f		00:05:34	128	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
945	homdrxcrap	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-05-13 00:00:00	f		00:04:39	267	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
946	eunwoircuq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-11-21 00:00:00	f		00:04:26	175	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
947	pfvmsrrrop	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-07-18 00:00:00	f		00:04:45	265	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
948	gzuqaplsem	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1997-04-06 00:00:00	f		00:04:28	198	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
949	yqqbyegern	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2005-08-05 00:00:00	f		00:04:01	269	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
950	kmcyqgucbl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2017-07-09 00:00:00	f		00:01:25	233	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
951	yohvudtcry	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-01-20 00:00:00	f		00:02:37	297	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
952	uatxqttauw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-07-01 00:00:00	f		00:05:52	128	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
953	oewpqfckfu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-02-02 00:00:00	f		00:05:14	133	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
954	gxsueawgtc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1982-02-12 00:00:00	f		00:02:20	278	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
955	zzpcgpaizl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-11-12 00:00:00	f		00:05:24	281	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
956	wbrkaxxswt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-02-23 00:00:00	f		00:01:11	107	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
957	vkskdifmkt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-07-19 00:00:00	f		00:04:08	244	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
958	mdkbkwghrc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2021-04-02 00:00:00	f		00:06:24	230	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
959	huqgkozpur	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2019-08-02 00:00:00	f		00:03:58	246	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
960	ufirpftfmw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-02-15 00:00:00	f		00:02:16	134	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
961	vfluafpyab	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2015-10-01 00:00:00	f		00:03:55	145	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
962	kkkvrlycqq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-07-21 00:00:00	f		00:04:53	166	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
963	qaolmyevpp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-10-24 00:00:00	f		00:06:50	212	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
964	etuaddfvgf	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-12-11 00:00:00	f		00:05:04	174	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
965	ltarymkldp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1997-07-20 00:00:00	f		00:02:10	277	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
966	treqebfdfr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-10-24 00:00:00	f		00:01:56	278	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
967	cmfdvkvefm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2013-01-15 00:00:00	f		00:04:03	298	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
968	vmdwcrfodt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1994-06-20 00:00:00	f		00:01:37	108	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
969	nulsfeeqxs	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2010-01-21 00:00:00	f		00:03:42	101	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
970	vsqtacmaea	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2021-10-06 00:00:00	f		00:05:02	146	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
971	aznkynynab	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2017-04-03 00:00:00	f		00:04:36	185	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
972	lhgguaxkzd	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2005-01-01 00:00:00	f		00:02:42	105	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
973	tfmypxsedu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-10-22 00:00:00	f		00:05:10	213	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
974	bcerylmgpc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-11-24 00:00:00	f		00:02:32	202	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
975	luuyplhegg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1982-02-20 00:00:00	f		00:03:33	139	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
976	waprupwqgg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-07-19 00:00:00	f		00:02:18	109	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
977	gmzozbpngx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1982-06-20 00:00:00	f		00:06:00	121	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
978	cphobtazne	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-12-17 00:00:00	f		00:02:09	266	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
979	atzbtgqelp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-07-13 00:00:00	f		00:05:20	218	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
980	gaosocqsup	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-03-13 00:00:00	f		00:04:29	149	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
981	rmutkvnrir	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2015-09-12 00:00:00	f		00:04:40	173	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
982	fwrlisygvu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2017-01-24 00:00:00	f		00:05:42	277	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
983	ywlhqxsucd	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1982-01-25 00:00:00	f		00:01:06	282	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
984	kvukaqkvlg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-04-04 00:00:00	f		00:01:02	300	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
985	cwmaynoxyr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-02-19 00:00:00	f		00:05:47	283	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
986	ddsfhsuuuo	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-05-13 00:00:00	f		00:02:31	145	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
987	whcfcsrano	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1982-08-22 00:00:00	f		00:03:37	206	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
988	uaywgxnshv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-11-06 00:00:00	f		00:03:25	258	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
989	dpgrmibuep	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2005-05-06 00:00:00	f		00:05:18	189	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
990	npxflttdln	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-07-12 00:00:00	f		00:01:55	144	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
991	dzgtwegftm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-01-26 00:00:00	f		00:06:13	117	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
992	wylbcgpmzy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1987-04-02 00:00:00	f		00:06:11	101	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
993	nswpfzpsgs	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-08-08 00:00:00	f		00:06:38	161	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
994	wgxfbbvkzk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2017-02-15 00:00:00	f		00:04:34	263	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
995	gouvaezwfp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-11-18 00:00:00	f		00:04:31	227	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
996	kaehfwefqu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-07-19 00:00:00	f		00:01:53	289	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
997	aycaovtvtg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-03-15 00:00:00	f		00:02:48	280	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
998	vrrxbbyrsq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2000-09-22 00:00:00	f		00:02:50	241	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
999	zppfagttqf	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2000-11-09 00:00:00	f		00:01:51	138	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1000	onghaaoxfe	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-01-14 00:00:00	f		00:02:38	214	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1001	yauoglxytg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-04-22 00:00:00	f		00:04:53	116	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1002	kzopglarmc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-10-06 00:00:00	f		00:02:46	110	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1003	luzmunzlll	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1983-08-06 00:00:00	f		00:05:27	239	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1004	cfrlkcnqcf	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-10-07 00:00:00	f		00:03:53	177	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1005	lzhaxkkgwo	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2012-11-09 00:00:00	f		00:02:57	188	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1006	wndwhtucne	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-01-01 00:00:00	f		00:06:43	253	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1007	luyysxyyiq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-05-10 00:00:00	f		00:06:46	177	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1008	lfqiozuzwl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-04-04 00:00:00	f		00:01:18	137	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1009	ulzfdlvlac	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2010-08-23 00:00:00	f		00:04:01	161	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1010	phqiqoclhc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-09-15 00:00:00	f		00:02:48	205	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1011	okwptbemcw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-11-09 00:00:00	f		00:06:42	225	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1012	gteoiemcrh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2021-07-17 00:00:00	f		00:03:41	133	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1013	xqbhqmibad	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1999-12-04 00:00:00	f		00:03:14	140	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1014	wpvixgoilg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-07-11 00:00:00	f		00:03:45	211	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1015	gtudqrzwxs	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2014-05-25 00:00:00	f		00:06:31	218	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1016	zxkorwkfiq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2013-12-03 00:00:00	f		00:01:19	278	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1017	ncoiyoebnx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1991-02-21 00:00:00	f		00:06:41	180	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1018	etmaxseodt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-12-07 00:00:00	f		00:01:34	187	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1019	uasckuqmuh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-02-10 00:00:00	f		00:03:08	298	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1020	gckomrdcgb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-10-25 00:00:00	f		00:01:16	195	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1021	cdrisgtvet	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-03-23 00:00:00	f		00:06:17	191	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1022	qiusyoigto	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2006-11-05 00:00:00	f		00:06:13	156	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1023	lnbhwdxtbv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-06-26 00:00:00	f		00:01:46	253	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1024	dynrnspxmb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2013-10-01 00:00:00	f		00:06:59	200	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1025	wizqweldrt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-08-19 00:00:00	f		00:05:24	295	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1026	frkayvmtey	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-01-28 00:00:00	f		00:02:28	178	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1027	opiyuefvvl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1987-05-11 00:00:00	f		00:05:35	151	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1028	pyamxotqpz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1982-10-27 00:00:00	f		00:05:33	261	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1029	zvgvndpipd	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1994-08-17 00:00:00	f		00:05:17	234	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1030	vmbmgvqfwq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2010-12-16 00:00:00	f		00:05:32	286	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1031	kecbatzkuh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-08-28 00:00:00	f		00:02:19	126	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1032	wvutzfmenf	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1987-06-07 00:00:00	f		00:03:40	288	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1033	lepzloxwzy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-04-28 00:00:00	f		00:01:32	246	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1034	mawcdwlpgq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-09-12 00:00:00	f		00:01:33	123	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1035	zvebwxgxfv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1997-11-05 00:00:00	f		00:01:12	274	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1036	uwzcyxrumn	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1999-05-27 00:00:00	f		00:04:07	199	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1037	bsparwcpod	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2012-09-04 00:00:00	f		00:05:19	285	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1038	sdhuubnlzu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2003-07-21 00:00:00	f		00:05:37	243	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1039	xbzxtfabks	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2000-07-22 00:00:00	f		00:06:13	129	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1040	ingvxsdebr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-11-28 00:00:00	f		00:02:37	290	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1041	eyhnwoqqtm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-05-20 00:00:00	f		00:04:37	132	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1042	fkxyqafkkv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2004-01-05 00:00:00	f		00:03:22	283	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1043	cxdluekbev	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-05-17 00:00:00	f		00:02:26	296	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1044	nroztfbmnl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-08-02 00:00:00	f		00:06:16	146	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1045	zictddiwrd	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1993-08-02 00:00:00	f		00:06:28	171	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1046	kvhzzlmpfu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1980-03-09 00:00:00	f		00:01:29	134	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1047	shlvypsczc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2020-04-01 00:00:00	f		00:05:45	172	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1048	mshnzbhfgc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-10-16 00:00:00	f		00:03:22	116	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1049	zukubtnpmc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-08-10 00:00:00	f		00:01:22	126	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1050	cexriulfgx	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-09-20 00:00:00	f		00:01:26	215	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1051	oluvatrlxp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-03-21 00:00:00	f		00:02:46	132	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1052	wcrhgmhpev	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2015-05-22 00:00:00	f		00:03:13	258	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1053	nvgbdbnoiu	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-09-10 00:00:00	f		00:01:41	170	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1054	rxsnyyktax	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1996-06-14 00:00:00	f		00:01:07	265	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1055	fwkwdivwnq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1987-02-26 00:00:00	f		00:05:06	202	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1056	dphpnwnewd	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1998-11-18 00:00:00	f		00:02:15	254	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1057	ihklldzptk	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2000-01-14 00:00:00	f		00:06:01	283	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1058	ixezaaacwz	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-12-13 00:00:00	f		00:05:08	204	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1059	dekavqahyt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1989-03-26 00:00:00	f		00:01:07	144	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1060	uiarzuvxvr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-01-13 00:00:00	f		00:04:24	102	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1061	abayzknmdg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2005-10-16 00:00:00	f		00:02:13	171	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1062	hyebnxqdvc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-06-22 00:00:00	f		00:02:41	159	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1063	yqzabvabuw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1999-11-01 00:00:00	f		00:02:48	114	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1064	pcagtuipts	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-10-28 00:00:00	f		00:03:11	203	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1065	efqbrzdmxl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-01-24 00:00:00	f		00:06:56	255	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1066	mpwnnmkbko	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-06-05 00:00:00	f		00:01:50	222	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1067	qeixsqzkoc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1999-04-24 00:00:00	f		00:04:46	156	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1068	ghvcpamhgv	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-11-22 00:00:00	f		00:03:51	162	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1069	cefraaehst	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-05-03 00:00:00	f		00:06:08	219	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1070	iyoymchvuy	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1983-07-17 00:00:00	f		00:01:57	274	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1071	trilqlvaxr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1992-10-07 00:00:00	f		00:06:48	104	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1072	ldoagedahq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-02-16 00:00:00	f		00:02:57	141	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1073	pebgqvmbhf	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-07-01 00:00:00	f		00:05:59	122	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1074	ixqceqzhpl	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2016-08-19 00:00:00	f		00:01:00	259	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1075	crddzdkpkh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-08-13 00:00:00	f		00:03:30	134	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1076	sdqmgafafm	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-06-27 00:00:00	f		00:02:42	161	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1077	epwpiqwrct	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1993-12-23 00:00:00	f		00:03:05	149	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1078	iqblyndhga	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2021-12-02 00:00:00	f		00:06:53	298	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1079	wygscftauw	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1995-05-23 00:00:00	f		00:02:55	193	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1080	ndzbratpid	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2002-09-01 00:00:00	f		00:02:20	200	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1081	crquwgfpmp	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1981-12-21 00:00:00	f		00:04:27	174	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1082	mypdwubcyt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1984-01-14 00:00:00	f		00:06:46	214	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1083	niupxpekqt	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2017-02-08 00:00:00	f		00:05:48	284	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1084	retwtwftlc	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1990-04-08 00:00:00	f		00:02:23	112	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1085	afxpyllgcq	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1999-07-20 00:00:00	f		00:06:50	270	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1086	zstythoyns	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2009-03-20 00:00:00	f		00:05:53	213	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1087	iagwohebor	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2007-04-16 00:00:00	f		00:01:44	214	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1088	xxrwxaufly	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1986-05-08 00:00:00	f		00:02:42	209	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1089	xfvduckfss	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2021-09-27 00:00:00	f		00:01:17	175	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1090	fnlnqyqdqr	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1985-07-23 00:00:00	f		00:05:19	141	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1091	vyqhoirytg	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1996-06-26 00:00:00	f		00:04:30	299	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1092	shmmtshbzf	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-01-20 00:00:00	f		00:05:56	102	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1093	ktmsreutze	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-01-01 00:00:00	f		00:04:04	181	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1094	eobuqfqvum	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2001-04-20 00:00:00	f		00:06:37	244	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1095	xmmqtxzgdn	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1999-07-23 00:00:00	f		00:04:02	175	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1096	uqknevywpb	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	1988-01-21 00:00:00	f		00:04:26	243	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1097	eyvrabpngh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2008-07-01 00:00:00	f		00:01:30	232	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1098	nlcpydmxuh	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2021-07-11 00:00:00	f		00:06:49	151	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1099	wewxupstza	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2011-04-27 00:00:00	f		00:02:41	251	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
1100	quvxormhou	From file: /home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3	2020-03-27 00:00:00	f		00:03:09	128	/home/emilien/Documents/Ecole_ingenieur/UNIZA/advanced_database_systems/project/main/server/audio-data/gs-16b-2c-44100hz.mp3
\.


--
-- Data for Name: musicartists; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.musicartists (musicid, artistid) FROM stdin;
576	23
750	21
466	59
817	89
215	16
338	2
1034	94
372	48
157	86
700	46
348	95
284	53
907	31
794	35
879	35
150	56
294	70
556	8
583	96
1028	4
360	50
549	78
220	60
222	39
816	96
977	12
268	15
320	67
540	7
295	63
353	70
101	79
338	57
776	41
1079	42
188	82
806	35
646	16
998	59
601	2
690	81
277	49
1094	11
657	88
270	13
447	14
931	82
350	53
517	79
998	71
327	28
102	73
288	28
547	54
838	12
990	79
308	89
107	13
1016	34
835	47
601	72
149	96
546	77
531	16
737	49
826	10
225	68
734	73
160	16
222	77
591	95
1040	34
428	65
648	35
539	36
1035	83
722	87
948	49
538	67
222	29
962	85
294	78
168	71
1005	7
236	75
908	13
868	49
646	35
175	37
987	79
612	45
379	69
121	7
858	13
781	63
784	22
708	56
192	20
930	68
381	79
228	56
571	3
527	69
237	92
459	47
594	42
554	99
360	18
335	100
1085	48
123	21
142	21
389	60
578	92
253	25
613	26
564	100
1059	28
202	60
263	63
634	97
278	63
455	49
555	16
762	71
495	26
272	20
627	93
513	28
222	44
982	54
626	87
1029	86
673	55
491	10
784	32
992	67
104	46
974	67
332	30
668	26
291	11
779	85
284	85
124	77
325	47
403	66
746	29
903	30
793	42
1065	71
861	51
941	95
798	76
859	98
1063	25
306	51
856	95
839	66
1043	5
534	35
884	51
431	19
934	29
342	96
154	50
815	96
207	13
212	89
442	56
790	83
444	36
535	45
461	94
263	69
936	22
639	29
308	58
630	28
1036	11
132	80
339	96
619	26
1058	61
340	97
360	45
531	58
530	18
480	77
385	86
316	1
899	57
516	32
764	15
605	58
630	80
251	38
854	36
171	41
857	63
1071	23
917	82
466	31
326	19
139	23
978	90
558	51
419	64
134	64
328	20
970	70
247	84
450	34
196	33
911	94
615	44
344	11
125	51
385	39
460	18
680	17
690	27
138	60
263	67
961	6
821	48
590	23
705	24
187	67
731	93
1045	71
566	73
485	17
240	87
620	60
485	76
577	4
813	14
1081	2
590	9
680	60
890	50
977	94
415	48
459	87
828	99
1099	20
722	80
741	75
389	35
947	51
207	54
406	94
242	65
160	51
976	73
712	88
700	71
624	84
545	91
894	20
822	25
480	65
587	49
1081	12
390	41
792	38
977	69
343	40
723	90
213	34
743	2
589	13
443	61
676	40
876	5
531	71
922	64
1087	65
895	63
537	25
428	50
466	96
350	100
160	7
814	37
149	78
306	53
809	63
582	48
498	6
620	38
212	85
279	83
161	96
887	31
506	84
292	48
265	24
970	41
726	60
839	22
185	47
898	84
605	9
1054	17
797	50
311	28
211	38
420	66
128	68
901	20
516	85
194	78
179	95
967	55
216	14
811	29
800	100
162	80
1099	14
1088	54
847	81
190	7
581	5
248	67
680	86
799	58
439	59
951	80
305	59
410	43
410	94
932	38
759	69
1008	4
648	65
812	93
785	6
982	48
822	6
393	54
955	66
112	29
774	15
834	8
851	69
380	86
1097	55
876	78
109	89
664	20
687	42
964	80
473	10
918	5
792	23
706	86
524	92
736	23
305	61
1000	30
1050	82
1038	59
160	26
532	32
198	21
202	15
463	82
624	46
269	77
840	86
510	63
410	47
423	43
225	100
1036	54
637	9
803	6
841	92
1019	70
773	31
240	32
764	69
1032	5
492	46
341	97
340	83
565	67
160	70
174	29
441	72
836	82
886	55
769	75
638	24
431	94
207	61
804	53
391	21
414	3
148	55
330	48
721	27
204	56
306	9
214	67
1097	33
258	73
191	13
202	21
783	82
165	97
257	39
899	44
929	59
201	95
912	47
584	70
1099	83
626	5
606	83
148	3
874	88
1087	50
965	20
820	16
579	42
993	15
957	86
1079	63
884	96
443	32
627	25
748	27
457	4
657	59
1059	22
755	55
724	86
593	36
735	53
883	40
222	52
277	79
928	6
632	51
533	14
865	37
507	9
565	35
616	5
322	80
795	74
287	5
610	45
1021	50
1079	85
625	88
723	46
286	67
855	11
344	74
624	32
134	29
397	93
994	75
848	7
785	31
158	87
192	74
489	99
146	53
759	89
195	80
514	81
922	54
893	62
531	72
832	89
981	9
236	50
307	78
898	43
607	69
307	26
441	28
109	97
580	24
497	36
613	79
281	44
319	43
433	93
556	12
602	90
192	51
503	53
541	1
339	89
1038	78
579	8
476	82
737	51
811	72
729	83
606	32
938	71
567	97
514	57
489	12
965	91
1000	19
899	22
167	96
838	47
473	7
114	12
565	87
883	61
962	16
814	13
846	52
612	21
324	72
704	80
376	18
445	43
702	45
291	76
597	8
1012	77
1095	28
442	87
836	66
894	7
1023	11
146	24
472	91
353	99
963	46
1094	26
526	56
869	90
271	11
167	30
707	59
880	43
539	6
720	85
324	91
218	61
550	95
449	98
357	82
1050	70
809	91
1078	80
825	54
1003	52
1043	43
756	60
643	76
149	54
551	9
654	34
1071	50
796	9
555	3
390	19
864	95
731	16
206	38
1065	1
112	38
909	90
744	24
673	89
913	15
818	43
217	29
174	23
106	3
189	46
684	28
634	54
235	95
769	62
1045	32
600	36
709	90
278	17
911	43
692	31
134	98
624	24
784	72
277	85
724	68
476	46
564	75
586	10
659	53
924	47
984	10
137	25
549	48
538	13
562	61
153	82
836	70
1031	23
542	93
299	76
232	5
1089	88
1007	35
619	71
276	17
1026	70
187	65
929	64
612	76
984	12
143	85
433	95
634	13
1031	72
1082	96
593	73
768	6
188	85
673	51
450	71
1001	38
911	82
727	61
112	87
487	69
838	82
793	72
373	70
596	85
209	61
111	83
505	1
623	88
169	51
246	17
463	56
981	54
301	31
257	18
990	29
710	53
185	10
730	42
486	29
1043	47
1060	86
263	77
740	40
562	12
172	15
733	60
896	35
1078	69
1043	85
796	18
994	84
279	2
505	44
444	28
639	95
181	64
854	49
632	28
479	22
620	5
850	61
622	66
935	51
141	40
592	40
251	66
286	71
679	61
1001	91
494	4
780	89
799	85
424	39
972	91
971	78
428	12
951	32
857	59
905	81
760	94
824	42
838	43
343	26
1046	73
183	15
1055	14
1099	68
709	86
114	64
138	74
926	3
627	95
326	35
260	12
219	6
157	27
353	88
972	99
996	71
413	57
474	93
890	3
478	76
504	5
874	84
201	59
257	19
264	88
195	91
914	97
679	12
939	64
684	21
185	38
1021	32
878	16
916	86
1086	20
609	30
323	40
476	15
598	19
841	100
818	68
300	80
475	21
904	5
398	55
554	20
324	61
857	44
322	30
179	70
979	85
1070	92
460	100
155	54
483	85
439	89
578	98
863	85
683	13
942	4
187	72
1018	35
248	12
329	96
1075	36
617	96
148	53
143	93
530	6
123	53
255	94
988	31
1042	82
214	46
683	7
683	23
512	76
184	32
675	74
184	26
620	92
960	92
519	54
942	92
451	24
302	16
610	54
1097	9
508	83
227	40
536	71
526	18
948	1
1047	10
922	91
620	67
720	96
948	46
282	84
706	100
706	79
428	54
403	20
347	65
970	50
789	19
397	76
331	62
640	4
171	59
598	68
704	87
510	76
649	46
861	70
158	39
682	100
557	93
451	33
217	45
697	75
550	93
109	87
617	66
146	35
620	29
581	60
715	4
935	28
517	96
675	35
1052	95
270	81
821	38
843	11
400	41
1032	67
170	64
277	62
284	21
335	39
539	85
316	61
334	71
1035	22
864	50
705	16
783	60
191	61
295	50
508	11
585	46
470	54
512	18
889	39
610	37
1081	91
1087	79
259	27
209	34
916	42
905	89
617	41
174	13
934	67
1022	34
760	88
554	56
780	58
431	62
146	36
440	64
147	19
963	42
425	27
924	82
1025	2
1068	25
476	57
926	20
349	25
407	66
1096	3
138	46
330	2
268	33
351	24
461	68
821	64
674	25
343	27
643	37
690	41
114	61
170	67
1040	3
412	6
252	61
823	8
1025	80
311	11
110	14
479	38
475	46
443	67
1060	32
615	97
282	18
772	20
861	32
778	68
698	85
199	78
991	38
377	71
168	52
312	43
328	49
548	19
900	79
203	31
492	70
892	24
499	49
1027	68
541	6
299	49
265	83
457	66
534	39
480	16
850	20
711	96
472	76
548	85
719	56
984	46
434	37
1054	46
862	27
119	60
594	92
949	26
184	76
1092	2
263	50
188	39
346	84
798	64
300	89
526	41
110	99
889	46
143	77
948	50
965	99
484	52
399	46
397	63
946	76
602	3
472	90
1001	30
413	41
918	89
534	85
158	20
309	9
507	83
738	58
1052	57
301	24
734	77
286	34
585	15
452	82
565	100
1059	85
893	50
712	38
144	23
914	87
245	13
1051	63
808	24
851	65
286	31
203	47
338	16
158	66
120	78
326	28
834	26
1012	96
105	82
814	54
487	5
160	13
228	53
728	60
288	77
619	39
950	93
264	3
746	6
941	67
351	6
845	59
657	18
194	44
244	70
399	21
787	5
579	67
296	50
213	97
384	7
134	16
275	52
743	53
968	27
582	75
903	87
1028	94
486	57
784	20
345	100
366	38
393	20
697	80
152	100
1092	42
723	52
336	74
837	66
874	81
590	17
369	99
132	68
544	60
489	67
731	79
749	4
320	80
119	72
282	65
387	61
771	52
112	49
1006	67
492	20
336	85
401	80
539	70
978	84
518	86
795	11
1094	70
375	69
300	66
252	24
169	90
276	68
945	14
470	51
740	4
787	64
914	5
885	29
230	29
134	78
613	50
819	73
1012	62
112	48
320	33
174	22
711	19
243	88
656	61
628	48
276	6
905	56
640	85
377	17
108	92
185	83
807	45
1043	71
675	33
1006	62
984	93
1045	82
566	63
1018	30
342	82
480	26
908	29
1056	13
452	29
822	7
279	77
728	65
555	4
661	99
557	31
902	85
994	7
437	29
993	21
174	80
615	10
737	55
411	19
735	28
921	76
614	52
702	67
447	50
1080	32
951	46
527	59
759	98
730	14
595	4
1092	98
693	80
107	30
501	63
296	11
302	26
961	56
267	65
214	58
955	9
522	31
382	75
307	47
240	15
124	60
1009	94
325	68
494	44
673	3
758	19
595	80
292	95
211	47
134	5
659	71
248	65
953	89
733	52
355	98
484	38
858	57
890	11
559	97
387	93
473	1
875	50
979	10
874	92
575	81
719	51
963	84
767	50
861	30
326	34
719	59
445	14
462	69
444	4
1033	3
400	17
778	93
414	75
829	20
783	27
868	36
697	89
1064	88
1021	16
474	27
296	97
142	89
871	7
482	80
261	90
332	83
634	2
1065	42
466	99
534	53
553	50
927	25
752	39
1065	18
926	45
391	15
842	31
881	34
835	84
728	72
630	29
459	99
177	99
827	76
174	85
293	26
872	57
481	30
202	66
1044	48
574	85
354	35
454	100
241	93
1010	2
538	16
690	31
1018	1
289	93
271	40
697	55
788	98
207	94
1090	30
270	49
811	17
487	59
130	19
933	33
436	52
348	14
257	94
544	85
174	52
848	45
772	38
933	58
456	90
919	40
303	18
443	40
1059	17
777	1
689	19
535	3
1063	20
868	62
496	9
289	26
227	10
809	8
784	83
665	15
499	7
331	7
658	99
590	95
355	27
833	56
714	84
788	70
209	75
897	9
1014	52
168	96
265	3
820	84
1026	13
804	98
937	16
925	55
1089	47
615	78
552	70
951	88
955	86
974	86
755	53
997	99
250	1
808	15
222	22
243	82
225	95
1068	98
758	1
326	95
399	89
775	88
375	62
265	91
283	40
706	11
493	69
981	93
541	67
681	34
436	33
875	41
1060	29
997	2
755	44
144	4
877	12
906	1
1092	43
943	96
259	34
468	86
627	36
219	22
1047	8
750	49
464	90
108	59
426	97
663	11
131	39
217	56
477	1
718	41
365	72
803	31
591	31
445	45
161	61
832	81
835	79
291	72
313	23
1004	50
214	96
755	56
575	83
814	64
133	33
735	49
923	2
643	14
852	67
584	98
905	49
672	34
501	45
827	68
990	45
490	57
283	92
887	86
384	27
939	98
779	75
805	44
517	75
461	27
680	13
215	18
1088	23
232	29
985	78
863	94
1017	78
703	56
567	4
620	15
422	49
119	20
777	88
842	25
314	67
258	19
802	4
799	68
232	55
773	52
163	32
687	88
108	28
528	98
801	63
469	73
346	45
139	28
934	100
222	7
661	92
132	72
335	62
729	13
907	9
724	23
704	29
658	34
671	72
668	29
1100	23
1095	3
998	23
199	69
210	56
200	77
741	95
610	40
994	72
452	37
343	20
522	3
1047	74
269	13
882	77
104	10
325	35
116	77
1032	33
133	92
790	61
153	10
540	29
1078	6
394	32
681	40
515	73
453	51
511	20
469	39
123	55
980	48
663	22
932	71
852	50
298	87
117	78
905	60
926	82
969	39
678	18
313	37
113	4
132	89
512	97
976	85
320	90
626	62
592	9
596	1
637	99
771	44
889	94
281	76
324	62
866	70
597	68
500	21
124	69
562	36
766	15
869	8
321	5
440	77
1012	84
856	100
532	76
481	82
803	97
343	60
137	87
763	61
353	60
258	55
585	100
655	94
790	60
785	29
688	75
114	9
936	63
371	65
976	43
103	64
416	34
572	47
209	85
198	54
810	12
320	28
225	1
840	98
304	28
501	58
925	6
422	38
411	92
884	85
767	57
582	98
1019	51
411	29
978	32
658	33
112	54
274	68
934	88
633	61
954	48
114	73
980	31
328	65
290	79
550	40
429	79
168	28
255	1
637	81
398	19
488	23
728	78
621	38
391	91
1048	30
427	51
927	72
556	55
393	11
129	96
939	14
1060	50
918	94
685	75
879	76
703	7
875	67
642	60
891	5
561	24
680	75
736	67
128	69
590	19
786	92
147	8
214	54
895	95
200	6
476	87
872	9
803	25
343	8
693	8
922	41
682	86
108	57
678	45
797	61
720	69
171	45
684	57
198	78
968	73
172	56
179	73
193	64
395	21
485	24
483	64
686	94
288	90
909	13
885	4
812	78
757	91
535	56
146	51
596	98
411	96
442	92
772	19
705	61
1030	24
563	78
188	46
195	19
449	2
318	55
776	84
725	2
233	2
311	9
413	88
291	58
292	6
346	78
778	54
262	32
999	24
280	73
662	51
927	50
852	12
589	30
969	3
1019	56
213	37
623	52
233	91
499	84
704	89
502	44
645	48
639	85
852	57
745	77
495	45
318	4
132	9
423	93
422	73
552	90
169	72
871	27
179	79
239	53
275	91
836	100
873	54
1078	39
428	55
674	52
554	16
104	77
213	20
551	32
1079	20
529	85
843	60
237	82
937	11
817	6
235	67
425	9
325	45
402	75
1021	96
433	46
645	26
1033	89
1013	79
396	31
845	77
909	68
339	94
564	21
580	30
106	13
941	16
758	22
171	46
911	21
760	36
372	89
482	22
677	10
186	89
773	89
895	86
792	64
573	16
557	57
592	67
821	43
644	82
1032	7
965	33
713	64
1093	39
837	43
508	25
1085	98
166	21
894	21
910	54
446	92
949	52
398	92
505	95
260	15
597	72
725	23
460	15
967	85
439	14
839	49
296	57
720	38
401	85
826	7
690	6
200	39
603	97
737	9
863	93
135	72
338	11
788	21
157	32
1087	100
885	7
496	61
110	34
868	59
549	81
890	65
510	66
921	51
338	46
782	24
321	2
656	16
467	77
808	46
656	72
587	91
1089	23
378	43
125	8
1003	1
550	27
201	67
771	87
875	11
588	69
659	90
456	49
742	35
246	68
322	33
1059	84
873	32
808	54
1098	1
997	18
292	98
187	20
963	63
1005	80
403	90
647	64
448	4
859	90
316	7
303	19
241	65
133	53
1036	42
202	3
861	100
509	32
270	31
500	6
694	11
910	89
1008	100
489	31
561	6
380	71
323	68
276	54
237	95
259	17
489	69
1093	57
875	62
888	8
640	77
1026	12
580	78
458	97
1046	15
882	68
513	73
486	48
329	21
862	29
873	41
601	25
227	4
1021	59
641	30
419	84
945	97
483	26
321	83
676	28
157	72
642	90
397	36
869	87
1007	78
1063	70
1022	40
830	81
1050	2
364	88
302	19
507	48
741	86
127	78
392	93
153	95
451	68
1083	15
707	74
255	40
659	94
254	80
510	6
667	37
241	15
1022	51
466	90
385	56
896	76
196	39
902	65
619	23
869	20
997	3
170	68
390	59
465	88
997	60
580	29
618	51
145	62
124	36
576	42
327	87
308	61
305	82
160	8
1094	60
701	84
649	13
266	78
605	85
500	46
260	49
987	27
527	88
859	24
1006	53
872	92
695	97
225	27
815	18
549	8
344	50
160	55
745	99
491	52
177	9
920	57
844	85
1083	87
864	83
689	16
488	47
462	6
915	47
519	84
395	33
488	13
371	38
1023	29
899	59
728	14
852	21
596	7
518	51
155	92
585	10
563	50
807	83
1055	30
1022	56
765	11
166	27
762	49
300	30
587	7
686	7
365	65
676	58
520	79
613	32
1051	15
382	79
1003	96
913	7
993	78
346	5
607	91
433	28
104	90
625	37
796	28
805	39
877	73
464	6
1093	98
511	81
627	33
748	45
847	46
709	26
912	89
452	21
626	31
636	12
560	36
810	55
374	28
750	78
409	82
987	76
1004	1
334	20
1064	80
493	96
123	56
676	97
951	7
628	24
419	30
612	66
332	41
1046	80
727	8
175	63
389	9
1097	57
973	36
846	31
281	35
701	61
1041	92
599	19
276	61
772	90
119	96
1069	22
692	49
192	69
792	71
492	95
706	8
590	50
774	78
190	12
660	99
557	84
1075	33
708	49
1098	67
509	33
137	4
256	33
460	31
1040	56
713	50
693	74
1008	29
606	42
316	9
247	80
382	34
944	63
946	33
211	68
247	45
264	64
1095	4
195	94
546	34
1078	84
574	60
315	21
475	60
480	95
107	63
532	13
343	6
439	48
983	97
552	64
825	44
1049	79
730	26
706	72
922	80
172	81
453	48
798	2
826	49
921	54
924	28
315	87
246	58
561	56
585	11
887	44
1018	48
254	1
819	41
755	52
609	63
626	58
573	70
965	68
674	18
937	8
165	7
278	26
631	40
306	36
494	78
833	72
198	82
603	17
807	4
249	80
462	15
616	36
799	25
752	68
397	33
491	17
161	84
179	51
943	36
695	60
427	42
829	76
947	57
528	31
317	46
164	36
948	83
1004	24
372	56
401	89
451	71
1066	58
159	74
197	39
405	62
357	97
726	94
225	86
836	18
113	12
526	6
174	18
990	72
433	14
667	8
362	15
129	41
971	52
418	61
238	43
764	80
911	88
248	36
566	98
633	10
405	60
440	86
578	37
347	68
438	70
568	86
806	66
863	83
233	22
621	5
598	44
232	98
540	91
381	41
376	17
732	23
709	96
964	43
1062	89
893	32
460	46
410	9
877	15
804	48
887	6
569	46
217	86
282	61
469	25
650	86
691	28
1050	30
420	37
718	23
638	84
570	1
987	28
510	85
336	37
942	56
537	77
341	21
248	57
251	99
149	45
988	17
296	99
796	4
895	69
442	94
451	64
703	86
569	80
737	30
175	95
881	27
267	17
1083	84
328	35
228	42
667	60
218	79
791	60
759	13
973	58
493	32
856	19
496	29
524	27
802	89
677	21
628	62
167	8
571	42
412	58
791	95
482	91
595	2
907	60
702	28
278	62
264	51
439	24
761	18
335	23
245	49
465	34
337	11
660	83
421	92
325	17
218	63
458	65
548	73
452	97
1063	14
248	96
926	84
297	75
695	71
226	10
124	40
155	85
186	76
159	6
350	7
410	15
705	89
759	26
988	97
1015	5
172	12
337	64
978	63
1077	23
955	90
768	80
548	93
608	51
143	94
1014	85
833	63
873	56
938	3
535	30
1024	45
494	95
686	74
886	30
186	13
770	8
516	59
853	82
220	51
875	65
106	40
854	54
964	42
811	85
649	28
666	29
366	78
836	86
1057	76
1054	19
404	56
562	67
1023	48
1023	2
559	46
817	90
596	80
254	58
695	31
204	24
370	56
366	28
407	57
375	54
663	96
415	27
175	17
314	95
906	93
129	89
534	34
1093	42
684	61
1081	88
1000	20
250	34
632	86
107	64
506	13
393	72
470	26
631	54
929	15
748	89
169	24
762	56
668	90
118	16
618	5
551	98
972	93
1011	67
945	62
545	86
808	86
448	66
594	48
1044	2
893	21
630	89
382	51
1093	45
156	74
402	43
157	92
616	7
498	2
427	88
465	22
969	36
772	93
206	46
734	88
699	9
283	83
145	72
508	65
931	35
717	10
714	80
761	56
1060	49
363	6
1016	77
540	81
144	1
1021	97
747	4
407	95
503	86
162	33
236	24
491	42
757	55
799	73
993	61
215	71
540	85
1099	98
211	61
605	31
178	56
141	41
765	24
288	60
433	6
923	78
841	67
860	67
229	81
419	83
1068	65
918	53
131	99
943	79
733	84
353	20
196	87
998	25
970	51
950	52
171	73
260	21
320	60
607	13
348	91
525	97
499	22
138	32
566	43
971	20
179	49
177	79
832	3
634	77
804	56
744	62
884	97
726	41
1007	36
951	66
336	80
709	75
1027	83
388	73
515	19
797	62
849	81
522	88
1083	14
832	96
103	18
1099	84
325	75
849	16
1024	59
667	33
724	55
476	80
474	41
275	71
383	57
866	87
962	39
658	78
707	76
925	50
453	22
454	45
284	74
636	56
1064	37
185	44
493	56
319	59
1071	92
977	89
339	67
166	79
1098	32
186	2
220	49
611	87
128	72
608	48
923	16
536	87
276	15
106	66
1032	54
936	1
619	66
122	52
429	95
1073	14
425	94
804	71
671	74
798	49
533	63
913	50
389	72
616	80
967	67
938	51
803	87
1058	68
945	61
332	54
947	94
1056	48
1014	47
811	61
658	51
301	83
742	5
695	53
1039	79
290	9
347	82
734	54
852	38
700	36
1011	40
506	1
993	43
477	4
110	10
636	5
1005	92
311	74
979	28
111	31
323	23
456	72
161	36
485	72
567	84
865	78
1018	7
\.


--
-- Data for Name: musicgenres; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.musicgenres (musicid, genreid) FROM stdin;
988	16
691	24
520	21
135	19
325	8
725	27
766	22
749	5
304	13
722	7
344	26
255	3
236	22
797	17
758	18
812	24
1041	5
906	5
359	22
1053	8
504	8
953	14
685	12
154	3
665	15
621	29
289	18
755	6
1074	21
133	6
798	28
500	1
1069	15
728	11
144	27
129	6
1077	17
1092	24
698	17
429	16
712	6
366	15
387	22
942	7
1075	30
333	28
785	10
210	1
1076	10
438	25
980	6
1007	18
410	1
609	8
169	4
1022	28
976	12
810	20
728	8
599	29
1024	28
889	30
817	22
930	14
648	15
967	2
227	29
439	17
970	12
1086	17
526	23
1063	28
898	29
953	2
717	23
496	25
485	16
691	16
834	7
102	26
509	24
578	3
271	3
617	1
759	29
731	23
747	17
991	10
987	16
133	8
681	8
556	28
745	7
271	22
335	21
249	6
355	11
255	12
429	25
175	22
779	13
307	18
828	22
334	13
371	3
939	27
670	24
124	22
265	29
365	30
343	29
498	6
903	30
894	30
324	26
1076	4
436	2
405	30
1034	25
496	30
630	23
547	5
775	23
410	24
182	23
671	1
787	18
472	14
256	4
1084	6
364	22
266	23
147	20
267	20
611	14
825	11
337	1
227	13
845	12
318	4
445	8
736	17
481	22
273	23
416	7
423	11
987	20
493	11
1070	22
471	27
705	20
523	30
122	13
844	21
221	10
109	9
862	17
407	7
746	13
149	19
786	6
616	28
566	2
589	13
787	29
1024	8
618	6
501	13
222	22
210	12
291	17
528	22
789	28
951	23
908	4
949	19
1034	8
1055	28
953	20
833	8
1085	30
829	3
127	20
445	26
227	1
283	29
165	23
828	6
635	6
303	1
553	6
396	20
1059	23
999	13
333	14
852	7
172	20
516	20
1023	17
858	26
336	9
546	23
962	29
444	4
286	7
1090	17
358	17
649	3
304	15
239	16
136	14
786	28
567	19
279	13
285	28
1029	6
739	24
806	23
742	17
145	27
376	21
747	22
157	21
525	27
801	21
619	10
388	16
947	1
236	6
1093	23
963	2
309	1
317	20
1082	28
1019	11
441	30
298	8
808	7
711	12
1042	2
570	24
405	21
296	2
930	10
842	21
941	1
312	13
1004	22
165	21
1069	5
861	22
139	2
815	10
434	27
559	16
194	20
660	16
477	30
716	30
119	8
268	7
479	9
713	22
394	13
1099	26
796	2
255	10
870	24
353	3
988	3
368	2
776	17
703	16
350	1
855	15
267	18
753	15
1087	1
1069	12
390	30
985	15
757	18
785	17
936	27
565	22
987	1
522	13
1013	19
471	25
558	26
477	27
547	4
231	9
176	7
901	18
410	13
809	14
588	3
112	19
652	13
389	28
770	12
532	24
564	26
520	30
946	2
530	14
115	8
150	7
759	7
878	28
960	14
999	20
524	10
750	16
467	24
542	3
509	8
238	5
353	26
559	8
466	9
265	30
777	29
807	3
308	16
871	21
226	15
780	13
341	22
330	30
374	22
486	12
409	15
420	15
257	18
144	10
148	19
928	7
1014	6
230	9
270	9
1067	16
218	7
755	17
826	15
931	7
367	12
802	25
704	25
227	5
498	7
737	13
887	30
968	30
497	20
1014	5
110	21
127	5
1041	4
1096	17
475	6
288	10
996	2
334	2
929	17
819	19
895	26
642	6
490	14
605	6
347	24
1068	28
671	25
215	5
888	3
568	22
425	9
712	14
598	2
308	24
573	13
528	8
124	4
392	7
903	20
1067	12
164	17
585	28
404	7
218	2
726	10
672	17
310	8
769	7
889	18
520	24
223	8
868	10
214	18
419	21
775	24
630	12
832	11
830	5
399	6
415	18
1073	1
371	2
119	10
1006	9
218	20
851	15
873	12
140	3
446	5
298	22
526	24
161	28
917	2
110	29
740	14
827	28
485	28
455	6
671	15
666	9
643	18
430	17
1067	7
182	26
325	28
329	29
549	3
776	18
873	10
1047	22
251	12
662	12
579	5
747	30
926	25
1022	6
671	13
550	3
262	9
496	29
778	4
889	28
1040	17
832	1
861	20
565	29
409	18
323	3
947	5
719	23
156	9
868	6
817	17
226	25
642	15
422	9
1064	21
1071	8
531	27
115	14
443	22
443	26
611	2
489	17
428	25
171	4
385	30
1077	15
974	19
839	11
407	26
260	3
154	11
133	7
502	9
803	6
163	21
902	25
617	9
747	19
958	24
299	29
131	24
213	3
797	21
958	23
186	13
462	25
907	17
296	17
395	28
113	9
506	3
379	30
255	17
201	27
1082	1
498	11
1078	6
711	6
416	26
763	21
157	1
390	3
393	19
418	25
653	11
845	7
1066	26
716	3
448	20
549	27
194	30
944	28
986	18
1019	9
190	21
1024	25
474	9
367	17
348	21
865	5
197	21
429	30
214	29
182	24
220	13
472	2
906	13
922	12
148	25
394	17
512	27
808	14
895	27
854	9
323	8
872	21
1058	3
892	3
608	26
292	3
604	19
387	24
872	29
596	23
1073	10
324	15
638	30
1074	15
703	12
412	13
682	1
290	13
860	9
307	13
469	27
529	19
492	7
118	3
560	25
400	12
272	22
104	5
362	9
766	18
239	20
986	2
234	17
430	24
795	15
892	23
890	25
891	22
555	10
278	7
504	24
1025	29
215	25
731	10
685	24
625	13
347	19
779	28
194	15
874	2
767	21
374	27
617	12
200	7
1092	15
158	16
951	26
900	28
870	11
533	18
1086	23
828	25
919	21
358	21
207	13
132	10
692	28
1029	3
576	30
733	25
306	2
187	23
195	9
403	15
796	25
350	29
450	11
313	18
919	17
266	4
866	18
144	24
972	18
1083	18
256	5
702	26
890	30
372	20
635	23
283	1
240	13
1031	10
556	27
847	15
126	5
421	21
662	23
550	25
433	28
394	9
266	12
619	29
113	27
1028	8
539	19
939	29
418	22
1068	20
785	30
681	6
135	23
608	27
367	29
947	15
790	6
370	1
536	7
950	9
803	23
331	19
488	24
1007	27
704	6
499	21
181	21
899	1
525	13
302	6
240	9
377	21
743	27
751	21
329	8
644	27
973	14
226	4
128	11
274	30
521	26
532	18
647	29
467	6
295	9
816	13
806	12
839	13
618	25
177	2
765	18
625	26
1051	25
720	4
842	1
1015	15
450	19
878	18
621	9
372	12
1072	30
916	29
136	17
395	21
345	13
999	3
734	12
150	3
903	14
458	6
427	20
495	5
1006	27
373	23
364	15
1065	10
719	25
569	8
728	10
958	12
802	13
867	11
335	18
448	28
137	11
1081	3
952	6
939	6
853	11
252	6
861	15
299	26
829	25
217	19
148	7
1007	23
125	30
200	22
629	23
977	29
1024	23
145	11
306	25
1043	5
790	21
426	9
455	15
482	4
479	2
518	30
755	18
107	10
958	17
534	17
622	14
802	10
449	8
177	20
393	5
785	22
665	28
494	10
771	22
867	30
525	14
931	18
632	13
193	1
599	19
422	27
745	14
1001	28
601	20
927	6
163	12
1080	15
641	21
642	24
930	28
1058	21
956	25
982	26
979	17
621	24
1079	20
989	15
682	11
842	26
934	14
783	22
253	29
1037	8
448	25
485	7
130	10
421	15
270	22
780	19
397	21
928	10
847	18
838	12
829	12
263	19
462	19
545	17
149	1
111	3
224	26
427	2
172	25
105	3
737	16
934	24
1046	2
356	26
680	4
1022	26
550	15
570	6
1083	9
542	5
506	8
636	9
988	19
177	17
943	26
640	17
629	9
758	15
933	24
711	9
136	19
1032	3
993	23
1049	3
127	9
694	15
426	7
410	20
215	12
805	18
627	19
754	15
382	7
687	22
481	26
805	3
560	17
377	4
927	30
908	23
370	11
779	20
342	26
464	19
485	15
187	1
925	7
360	23
142	7
106	8
763	17
954	23
185	12
131	15
745	16
412	3
590	25
829	23
802	19
170	10
505	3
176	5
194	19
747	26
723	11
833	6
920	9
908	26
447	21
611	11
534	1
304	27
370	30
977	28
692	16
741	24
1014	13
990	8
865	20
859	21
948	29
494	14
975	30
565	24
352	9
673	21
832	17
630	4
659	7
1092	30
1042	4
202	23
169	8
310	12
149	20
164	10
572	22
863	8
612	17
989	8
134	15
421	17
461	20
716	5
453	3
642	9
624	13
185	6
904	11
675	11
1078	29
386	14
336	8
899	20
284	3
258	15
467	10
429	22
123	10
230	25
1024	6
646	3
825	17
592	30
608	14
1024	17
803	12
932	18
713	14
351	1
750	6
1090	18
927	9
276	2
406	30
814	17
430	2
829	13
793	22
857	15
597	4
154	9
369	4
806	11
120	29
195	15
697	15
1059	20
322	20
245	22
243	22
254	12
520	10
360	12
562	12
799	27
972	10
300	17
838	9
589	9
678	26
835	1
815	24
1000	15
572	30
187	13
1006	3
366	28
528	23
1016	9
1061	22
648	9
975	17
330	25
772	8
446	4
777	20
843	16
613	18
309	26
697	17
331	9
1071	13
200	13
158	11
575	25
930	4
365	28
376	16
547	9
318	18
686	2
216	20
644	12
715	10
991	15
935	10
507	28
563	26
181	30
559	18
469	26
284	10
967	13
561	8
460	12
172	30
632	5
453	16
981	26
833	7
388	13
616	1
299	24
742	18
743	5
1031	14
1013	20
1012	14
204	3
229	16
1099	21
895	8
414	23
182	6
346	9
845	22
667	12
890	2
820	16
186	4
726	7
938	22
364	29
974	13
433	25
1042	26
362	16
427	19
330	8
401	9
401	6
697	16
954	18
761	14
264	8
436	20
968	28
732	7
933	9
1061	10
686	20
109	30
637	15
1060	24
500	22
106	27
763	5
547	13
350	3
587	9
144	17
1039	25
954	13
223	23
520	28
724	1
924	24
609	14
1096	11
443	23
686	12
221	14
697	29
161	1
1030	15
617	7
395	29
913	29
1080	14
707	24
928	9
104	14
677	15
816	22
917	12
777	19
305	15
991	25
297	21
303	27
849	3
412	15
154	22
258	3
1099	17
1045	11
1012	4
198	27
370	3
504	2
379	21
464	28
783	24
1003	29
615	16
419	27
254	5
473	3
807	20
1085	23
927	20
170	6
799	30
437	5
1009	4
477	20
196	5
301	29
298	19
133	9
884	9
972	24
965	12
844	16
793	21
857	9
152	16
107	14
761	25
700	6
329	19
888	11
411	25
874	29
994	13
493	23
669	3
167	27
1053	18
867	24
165	20
213	27
689	24
886	19
343	27
614	22
344	12
594	23
1034	1
690	24
547	24
406	15
231	18
1065	14
299	20
579	9
1034	20
501	27
304	23
1032	18
184	6
1017	14
571	3
502	27
827	2
582	29
828	24
674	23
250	11
1057	11
102	5
538	11
278	12
200	26
991	22
587	30
112	4
625	19
1075	23
501	29
964	19
156	13
285	30
966	6
392	4
374	12
640	24
451	13
793	26
187	16
333	10
794	14
386	16
461	7
863	17
729	16
1097	13
829	17
842	17
405	29
1020	8
221	11
1039	23
851	4
999	28
583	9
1070	9
121	25
764	19
496	8
476	20
608	16
644	17
209	17
917	9
982	2
711	30
456	25
856	12
1030	27
178	22
1071	9
155	12
800	8
864	5
397	22
268	4
128	7
197	7
876	8
1076	15
391	24
343	14
538	29
428	11
511	24
117	15
992	17
928	23
1059	22
624	12
407	22
140	20
597	10
840	21
621	23
290	20
682	24
400	2
804	29
335	25
807	25
373	2
865	10
458	25
632	22
842	15
225	21
203	6
784	30
579	23
204	5
180	13
982	7
218	22
717	30
610	23
168	18
481	12
1071	26
188	14
609	13
217	14
315	18
507	29
269	21
878	20
250	27
913	30
295	12
916	19
450	3
685	25
154	24
469	18
417	20
732	30
924	17
329	13
122	4
374	24
1052	15
892	7
920	19
795	25
725	21
1083	23
327	5
195	18
988	30
808	23
653	23
696	12
152	19
1052	16
103	25
610	22
349	18
614	14
169	27
1038	29
906	1
1063	23
791	25
880	1
1036	8
377	23
992	26
921	25
609	24
108	9
203	19
829	26
108	1
831	5
674	6
705	6
887	27
598	20
804	25
266	27
1060	14
189	14
566	16
311	12
1032	30
626	21
264	20
414	5
595	23
211	15
309	2
178	10
411	12
1024	26
118	25
843	30
475	11
545	25
1025	28
124	11
650	12
376	3
952	10
339	4
305	19
655	15
507	7
362	21
208	27
504	22
240	7
263	13
425	19
1028	22
1097	26
807	21
933	1
478	5
227	12
604	26
308	8
406	7
400	26
103	20
690	22
817	25
318	28
155	20
473	30
604	29
686	30
252	14
462	9
742	14
352	30
711	4
967	17
249	24
986	3
613	19
737	22
906	2
131	17
826	6
378	17
977	21
555	9
1093	17
293	6
884	30
569	23
1000	9
279	15
241	17
314	27
255	23
495	14
579	25
410	22
1035	22
710	6
290	4
378	21
1009	27
835	9
113	20
506	28
190	9
135	11
733	9
491	9
733	15
124	1
355	23
756	10
885	23
344	11
248	25
595	9
297	12
697	10
960	30
1087	26
511	9
842	8
895	14
204	7
420	26
417	5
1092	28
347	13
175	12
643	26
603	12
244	17
815	9
337	23
489	1
739	21
648	19
119	22
559	3
350	6
212	9
284	14
804	26
1031	7
1009	18
1088	28
811	14
776	6
249	12
363	23
1010	28
457	27
876	23
243	12
776	29
374	7
562	5
1004	2
723	5
762	13
704	8
1013	12
396	28
796	30
193	23
231	6
721	13
574	1
1087	3
1019	12
710	26
507	26
358	11
344	21
804	12
961	13
777	22
443	12
728	3
261	25
526	14
395	10
603	7
556	26
347	17
792	16
572	11
399	19
186	24
986	9
202	26
550	14
140	11
536	6
954	28
645	18
658	23
657	27
445	12
490	4
872	3
932	27
1095	1
245	11
676	7
925	13
477	19
928	19
583	14
136	15
405	24
157	16
1067	8
833	22
279	14
318	17
811	8
487	3
121	11
354	10
555	27
247	21
842	23
910	14
599	25
403	23
820	10
859	16
789	25
490	10
637	11
643	8
133	18
628	13
451	11
650	1
837	28
393	15
922	8
761	18
316	15
678	7
1059	21
630	15
289	10
791	1
575	20
417	10
360	25
111	21
628	8
1060	6
373	22
847	26
238	18
673	3
485	11
581	6
810	14
101	4
208	19
250	28
659	10
125	23
944	20
309	9
589	24
365	6
679	9
919	2
229	21
705	1
746	20
150	4
291	28
508	2
1078	13
688	28
173	22
932	17
239	26
509	3
248	17
1065	3
274	11
670	18
659	18
903	4
500	24
829	28
519	13
135	9
898	20
388	8
169	9
980	4
376	22
605	16
1034	12
1074	9
822	12
441	20
416	25
366	26
158	14
1042	8
488	8
128	3
141	16
775	27
409	11
680	28
635	26
408	9
656	10
343	20
391	18
709	27
146	6
248	24
102	2
540	21
491	8
183	6
805	19
391	17
381	14
684	21
1083	17
583	20
366	24
1062	14
579	27
482	1
600	22
392	29
181	18
582	24
328	14
581	7
464	15
430	28
339	26
445	23
1021	26
680	20
287	7
819	13
539	23
762	23
693	1
866	30
893	13
424	6
245	13
612	25
527	12
245	17
533	12
1037	23
260	19
944	26
1042	7
1011	12
639	17
1023	20
791	8
510	14
748	15
700	2
272	30
623	16
176	27
365	7
918	4
517	26
394	28
1066	20
273	6
847	9
613	7
1025	7
785	28
802	7
1049	29
440	2
490	2
561	5
829	29
359	5
1056	26
1096	4
318	14
653	28
692	29
540	23
859	29
632	2
437	13
526	9
527	11
383	28
455	5
222	25
688	27
721	17
1068	3
968	7
1003	16
576	29
422	26
736	15
582	3
708	12
391	21
248	5
146	26
267	19
496	15
145	3
1034	26
293	24
999	27
500	6
723	17
462	6
488	9
1023	7
155	3
376	23
720	29
105	26
760	24
138	15
204	21
767	17
356	3
866	6
428	26
907	15
369	25
746	22
759	11
177	16
304	10
611	22
1098	7
173	12
797	3
119	28
717	13
450	12
111	17
261	16
255	13
253	16
502	25
228	30
432	15
451	25
617	22
316	23
269	11
309	15
178	29
356	13
724	28
498	25
440	26
845	30
374	2
514	7
801	26
635	3
620	20
614	4
1089	9
460	8
832	4
1086	3
587	11
259	9
233	26
167	4
818	16
496	22
255	8
702	19
305	28
103	7
351	10
792	4
147	29
706	29
263	11
768	16
798	17
784	17
701	9
520	8
573	26
836	26
552	14
116	13
628	16
303	7
277	25
1039	26
360	10
787	20
244	13
1085	19
223	13
431	6
677	7
1029	22
933	6
644	20
1093	18
117	28
1025	5
1051	30
721	20
592	19
517	28
742	12
1061	30
723	29
322	2
296	20
843	26
535	7
932	14
891	2
254	23
987	13
622	9
1024	16
406	6
811	19
914	30
342	10
537	21
717	29
229	22
877	25
458	3
929	6
1077	27
328	28
220	23
918	10
1054	24
798	13
583	6
861	28
846	23
304	17
804	4
116	11
895	15
761	17
407	4
122	21
612	10
674	15
500	13
1071	7
234	25
177	29
1100	14
542	9
1100	16
219	27
988	4
437	20
836	13
147	16
597	24
272	2
204	14
669	9
307	10
288	17
683	3
808	2
147	6
638	25
433	4
605	14
389	15
383	14
1066	13
206	26
292	17
618	13
1064	12
423	9
177	22
972	17
697	20
872	8
536	9
1023	11
584	20
955	28
1012	13
713	21
389	11
545	13
798	6
878	13
1024	20
935	4
980	11
228	23
704	13
618	4
859	18
907	18
1009	26
354	12
183	3
882	16
339	25
201	3
1019	21
452	17
788	28
487	10
716	18
595	7
446	21
711	17
1016	2
879	1
166	12
992	8
526	11
798	22
569	24
472	16
235	20
144	19
1020	30
866	8
320	20
243	24
256	1
792	18
231	2
585	15
603	8
197	29
987	8
1046	7
199	20
175	25
257	28
1085	1
717	22
267	1
194	21
253	4
817	23
968	9
799	19
269	25
726	5
972	1
502	8
163	8
741	16
266	14
124	12
860	20
828	17
790	26
644	16
569	15
383	16
1029	23
881	25
626	5
542	2
479	3
561	11
482	18
570	1
327	25
762	30
446	29
801	13
1013	23
312	5
712	15
731	1
290	8
991	8
574	12
1099	10
340	8
225	30
872	14
190	1
959	20
453	7
828	26
169	29
976	2
354	23
438	3
924	11
1087	10
540	12
147	23
952	22
707	4
289	17
968	8
572	12
578	30
623	29
671	28
1005	12
283	20
557	8
472	7
258	21
849	26
433	7
1042	5
673	25
584	28
380	14
614	15
241	20
354	24
635	15
145	23
647	27
1032	2
943	28
406	28
422	20
971	14
751	16
846	22
663	6
135	24
168	1
485	12
796	4
442	9
126	10
1003	18
150	2
743	23
191	26
842	12
1042	29
492	26
232	21
520	26
999	1
615	22
185	26
821	8
1070	30
945	26
537	25
891	15
656	14
996	5
694	28
827	30
218	15
1097	20
339	5
123	13
1091	11
937	30
299	13
913	4
825	13
588	12
655	16
183	18
890	11
967	4
661	9
291	8
587	16
601	4
677	29
909	28
739	30
487	29
607	20
170	5
615	13
558	9
639	18
604	4
799	4
217	29
1087	7
147	30
604	28
325	25
396	21
1078	10
377	22
655	7
615	19
1096	10
464	12
862	10
1038	25
645	29
915	12
780	18
253	26
690	25
559	21
420	20
149	28
982	18
1002	25
242	5
745	26
242	26
733	28
697	28
812	22
159	12
725	5
894	7
968	2
483	7
550	13
1006	21
518	10
718	27
196	7
772	19
481	19
1067	24
510	28
814	30
978	13
970	29
646	27
868	14
257	11
708	23
385	15
109	28
853	22
597	29
249	29
1065	26
1087	12
196	6
685	18
1036	1
724	7
220	14
821	30
620	21
1002	23
229	3
1075	2
726	26
351	29
1093	24
577	7
1015	26
288	7
979	5
1043	20
679	29
316	12
611	5
625	15
363	8
518	3
728	6
258	28
538	5
1079	17
987	15
891	8
166	9
698	13
557	24
506	13
358	10
658	5
673	24
706	23
712	4
302	11
666	10
831	29
286	2
252	8
889	11
552	19
482	29
151	22
1017	1
923	22
451	19
649	4
453	21
789	9
646	5
186	17
876	18
360	15
388	5
579	28
1000	7
334	15
440	28
111	11
745	23
343	4
446	27
718	24
1073	25
383	4
503	9
703	17
730	1
139	9
667	16
419	5
450	14
730	4
417	23
387	21
1043	28
676	15
563	17
400	23
848	9
351	4
523	14
498	17
252	25
1033	13
376	17
406	19
542	28
1089	21
672	27
124	2
610	21
716	22
812	20
152	29
1019	20
215	20
252	7
982	30
325	7
375	9
764	18
259	15
992	12
1024	10
950	8
801	2
770	26
303	8
915	26
1097	28
374	8
1006	6
153	9
318	5
467	15
409	26
578	13
228	10
837	4
316	18
169	22
840	4
1094	4
139	13
634	22
614	13
843	10
526	19
834	10
114	18
1003	4
840	15
224	3
847	1
263	22
332	7
884	11
395	16
544	23
618	3
243	8
580	9
1073	14
492	1
729	15
931	10
290	1
893	20
989	3
440	21
524	12
273	17
200	5
519	1
897	1
421	6
242	17
529	11
421	9
1009	15
241	1
325	1
439	30
985	13
255	9
401	11
438	21
694	13
1009	19
237	6
811	4
557	25
438	12
615	8
479	16
781	10
535	16
1076	24
929	2
829	5
639	19
504	25
264	26
294	28
1035	6
439	14
747	3
196	11
826	2
869	26
747	29
745	15
158	29
708	4
1082	18
920	15
226	9
954	15
377	7
342	18
\.


--
-- Data for Name: playlistmusic; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.playlistmusic (playlistid, musicid, ordered) FROM stdin;
1010	1054	0
1066	568	0
1221	879	0
1119	839	0
1190	825	0
1159	271	0
1246	779	0
1103	751	0
1244	796	0
1243	159	0
1238	355	0
1109	349	0
1072	468	0
1149	500	0
1078	840	0
1162	137	0
1054	563	0
1072	719	1
1248	1035	0
1141	751	0
1057	781	0
1204	590	0
1199	897	0
1247	561	0
1031	1052	0
1169	329	0
1096	1051	0
1242	931	0
1161	714	0
1001	622	0
1162	856	1
1110	907	0
1133	427	0
1031	338	1
1082	914	0
1061	400	0
1003	420	0
1197	167	0
1100	1053	0
1162	333	2
1130	1089	0
1074	504	0
1177	944	0
1168	323	0
1124	618	0
1159	1052	1
1234	636	0
1232	296	0
1063	639	0
1230	961	0
1127	1098	0
1122	562	0
1016	458	0
1051	956	0
1206	642	0
1214	384	0
1193	861	0
1074	157	1
1036	748	0
1190	962	1
1022	932	0
1094	673	0
1018	409	0
1180	411	0
1103	107	1
1049	892	0
1163	441	0
1161	208	1
1153	395	0
1062	823	0
1207	497	0
1041	659	0
1003	503	1
1181	883	0
1142	185	0
1047	131	0
1067	472	0
1066	140	1
1158	184	0
1006	223	0
1124	445	1
1008	455	0
1202	1016	0
1166	625	0
1182	1024	0
1219	502	0
1111	1063	0
1244	704	1
1015	1072	0
1108	614	0
1058	496	0
1180	591	1
1121	830	0
1095	1061	0
1210	790	0
1064	346	0
1073	455	0
1131	307	0
1178	764	0
1109	310	1
1222	700	0
1068	1070	0
1142	814	1
1127	258	1
1059	148	0
1180	1005	2
1051	130	1
1216	896	0
1222	277	1
1035	337	0
1153	372	1
1195	626	0
1071	443	0
1113	238	0
1194	1095	0
1091	484	0
1216	364	1
1102	559	0
1183	249	0
1050	302	0
1149	807	1
1168	241	1
1078	127	1
1240	408	0
1179	603	0
1182	316	1
1247	138	1
1124	124	2
1100	642	1
1107	741	0
1062	673	1
1153	945	2
1019	418	0
1111	564	1
1099	214	0
1189	292	0
1125	459	0
1088	546	0
1038	600	0
1180	289	3
1249	939	0
1054	698	1
1123	788	0
1084	884	0
1056	413	0
1126	1080	0
1061	758	1
1179	126	1
1161	563	2
1217	286	0
1235	535	0
1205	854	0
1053	673	0
1128	801	0
1089	645	0
1149	592	2
1055	842	0
1242	558	1
1164	329	0
1186	114	0
1214	318	1
1118	179	0
1140	297	0
1181	635	1
1216	833	2
1213	195	0
1044	875	0
1218	533	0
1194	493	1
1241	361	0
1196	703	0
1244	154	2
1242	754	2
1079	423	0
1099	594	1
1033	911	0
1068	588	1
1164	113	1
1149	628	3
1064	600	1
1185	948	0
1163	462	1
1052	389	0
1114	294	0
1127	118	2
1215	651	0
1157	364	0
1119	227	1
1133	839	1
1091	829	1
1128	824	1
1177	880	1
1064	612	2
1125	660	1
1210	123	1
1133	977	2
1044	105	1
1008	552	1
1148	763	0
1105	677	0
1214	1008	2
1114	1046	1
1231	281	0
1218	617	1
1248	676	1
1110	854	1
1071	895	1
1119	515	2
1128	1095	2
1205	784	1
1243	859	1
1054	655	2
1229	829	0
1023	606	0
1226	596	0
1179	744	2
1144	948	0
1248	105	2
1113	738	1
1162	672	3
1165	357	0
1029	387	0
1154	926	0
1035	756	1
1155	1014	0
1244	180	3
1168	931	2
1143	315	0
1044	420	2
1192	971	0
1225	616	0
1124	489	3
1040	887	0
1092	499	0
1028	399	0
1204	908	1
1085	941	0
1062	905	2
1230	184	1
1017	1066	0
1215	639	1
1180	564	4
1037	239	0
1127	1072	3
1238	915	1
1180	736	5
1149	326	4
1030	1097	0
1230	1056	2
1031	699	2
1231	932	1
1092	805	1
1216	1042	3
1180	233	6
1044	315	3
1180	116	7
1030	134	1
1069	201	0
1181	918	2
1155	173	1
1193	811	1
1058	344	1
1199	1021	1
1212	707	0
1208	1035	0
1116	417	0
1235	795	1
1058	916	2
1151	526	0
1247	344	2
1212	1084	1
1243	653	2
1029	327	1
1060	794	0
1148	794	1
1164	220	2
1096	893	1
1030	1027	2
1098	494	0
1043	444	0
1232	922	1
1029	102	2
1137	714	0
1202	481	1
1095	416	1
1211	461	0
1095	944	2
1033	378	1
1104	385	0
1048	637	0
1118	1003	1
1138	796	0
1001	963	1
1057	310	1
1109	711	2
1023	323	1
1073	806	1
1046	211	0
1087	129	0
1163	305	2
1156	206	0
1008	1000	2
1235	1006	2
1234	941	1
1173	348	0
1184	834	0
1212	840	2
1147	407	0
1245	1048	0
1087	546	1
1170	1093	0
1148	980	2
1080	684	0
1184	530	1
1114	742	2
1241	136	1
1079	674	1
1014	794	0
1216	529	4
1220	804	0
1085	344	1
1122	425	1
1235	542	3
1166	870	1
1006	280	1
1167	1041	0
1039	543	0
1249	170	1
1021	286	0
1144	512	1
1194	261	2
1154	323	1
1001	909	2
1029	976	3
1210	803	2
1229	698	1
1161	640	3
1050	876	1
1213	384	1
1049	770	1
1212	1043	3
1127	288	4
1173	1035	1
1095	112	3
1138	610	1
1017	706	1
1073	926	2
1205	350	2
1213	664	2
1117	698	0
1236	1066	0
1192	181	1
1027	159	0
1074	698	2
1129	748	0
1104	997	1
1074	621	3
1017	951	2
1037	946	1
1203	1054	0
1218	234	2
1045	367	0
1022	989	1
1135	678	0
1245	523	1
1173	1045	2
1117	865	1
1097	405	0
1162	712	4
1004	520	0
1035	540	2
1107	162	1
1158	934	1
1232	1080	2
1077	309	0
1003	826	2
1247	284	3
1172	971	0
1169	553	1
1191	988	0
1145	124	0
1093	976	0
1225	1023	1
1010	290	1
1172	865	1
1033	586	2
1215	1040	2
1085	200	2
1163	203	3
1210	640	3
1219	275	1
1010	802	2
1031	481	3
1162	1046	5
1005	508	0
1202	365	2
1224	514	0
1114	346	3
1159	467	2
1023	991	2
1156	1018	1
1071	889	2
1126	473	1
1058	503	3
1136	612	0
1084	146	1
1186	241	1
1182	523	2
1109	912	3
1107	738	2
1001	524	3
1116	371	1
1103	730	2
1115	126	0
1189	632	1
1008	667	3
1084	821	2
1090	1083	0
1170	958	1
1203	120	1
1199	542	2
1130	974	1
1035	382	3
1220	244	1
1089	270	1
1093	612	1
1243	795	3
1092	828	2
1215	295	3
1243	327	4
1013	491	0
1203	300	2
1248	627	3
1095	490	4
1076	569	0
1112	468	0
1153	548	3
1036	788	1
1007	1027	0
1169	462	2
1075	795	0
1196	362	1
1149	644	5
1247	1095	4
1105	447	1
1091	665	2
1067	108	1
1142	238	2
1127	284	5
1066	521	2
1222	366	2
1178	309	1
1143	916	1
1118	663	2
1134	279	0
1036	624	2
1081	569	0
1093	814	2
1145	502	1
1047	189	1
1012	475	0
1228	517	0
1205	451	3
1087	725	2
1196	556	2
1115	383	1
1227	972	0
1135	393	1
1246	673	1
1200	261	0
1001	791	4
1190	169	2
1025	791	0
1212	547	4
1201	282	0
1087	871	3
1208	1023	1
1215	527	4
1010	312	3
1193	586	2
1120	257	0
1122	444	2
1134	677	1
1064	629	3
1188	714	0
1014	802	1
1076	432	1
1161	879	4
1035	280	4
1176	627	0
1139	816	0
1025	749	1
1228	897	1
1130	412	2
1170	580	2
1003	210	3
1197	229	1
1206	628	1
1199	541	3
1140	785	1
1103	555	3
1036	635	3
1022	761	2
1032	724	0
1015	687	1
1114	583	4
1154	969	2
1022	760	3
1213	486	3
1010	456	4
1033	1020	3
1125	594	2
1008	381	4
1202	250	3
1168	993	3
1017	1058	3
1225	297	2
1107	1012	3
1245	692	2
1197	935	2
1114	732	5
1065	1058	0
1029	385	4
1078	440	2
1042	507	0
1085	533	3
1053	683	1
1069	658	1
1177	847	2
1006	735	2
1001	954	5
1081	649	1
1213	540	4
1187	798	0
1049	422	2
1121	872	1
1236	838	1
1001	280	6
1020	523	0
1058	884	4
1210	550	4
1053	912	2
1160	994	0
1125	877	3
1207	804	1
1161	289	5
1060	171	1
1147	210	1
1052	359	1
1030	466	3
1024	505	0
1248	630	4
1053	967	3
1178	183	2
1001	656	7
1068	158	2
1031	690	4
1146	344	0
1186	867	2
1198	717	0
1072	486	2
1178	474	3
1148	1094	3
1047	419	2
1041	1023	1
1230	440	3
1183	441	1
1222	1051	3
1208	1051	2
1138	283	2
1144	1032	2
1076	290	2
1241	946	2
1144	775	3
1227	134	1
1152	985	0
1083	659	0
1055	371	1
1044	585	4
1226	454	1
1131	449	1
1174	308	0
1038	504	1
1096	466	2
1233	879	0
1140	1016	2
1006	643	3
1043	883	1
1030	616	4
1130	586	3
1132	324	0
1150	231	0
1228	192	2
1161	854	6
1147	878	2
1218	250	3
1122	1006	3
1127	378	6
1187	853	1
1212	289	5
1211	665	1
1133	930	3
1197	549	3
1207	1078	2
1211	843	2
1075	950	1
1145	575	2
1239	1075	0
1202	747	4
1214	344	3
1224	356	1
1024	390	1
1189	361	2
1028	885	1
1141	265	1
1051	449	2
1095	325	5
1060	683	2
1128	1079	3
1108	197	1
1121	453	2
1130	184	4
1237	597	0
1200	203	1
1141	215	2
1114	205	6
1193	255	3
1043	190	2
1139	1029	1
1206	430	2
1165	163	1
1018	531	1
1165	258	2
1194	211	3
1024	374	2
1207	474	3
1032	860	1
1106	170	0
1206	671	3
1201	608	1
1077	567	1
1212	1080	6
1201	770	2
1059	906	1
1219	1065	2
1079	690	2
1151	647	1
1143	250	2
1115	1093	2
1002	573	0
1037	226	2
1085	426	4
1051	1033	3
1106	561	1
1229	797	2
1137	671	1
1202	129	5
1076	909	3
1059	688	2
1108	952	2
1026	610	0
1166	911	2
1068	731	3
1043	399	3
1128	1009	4
1167	1008	1
1220	143	2
1152	1082	1
1023	1063	3
1050	726	2
1216	1005	5
1170	637	3
1053	289	4
1234	365	2
1138	1027	3
1070	260	0
1046	550	1
1209	424	0
1201	918	3
1005	971	1
1241	459	3
1010	831	5
1021	1057	1
1171	897	0
1080	516	1
1160	768	1
1059	323	3
1151	907	2
1038	376	2
1008	279	5
1073	1097	3
1011	741	0
1028	629	2
1190	315	3
1148	317	4
1162	787	6
1040	348	1
1004	853	1
1250	522	0
1067	1030	2
1082	730	1
1080	905	2
1086	860	0
1246	669	2
1140	670	3
1086	332	1
1031	1031	5
1009	579	0
1153	606	4
1198	732	1
1206	266	4
1090	506	1
1052	761	2
1108	1003	3
1142	1033	3
1136	295	1
1113	689	2
1113	773	3
1015	629	2
1064	630	4
1133	704	4
1041	506	2
1033	699	4
1130	758	5
1073	1085	4
1179	866	3
1228	341	3
1137	873	2
1232	223	3
1065	724	1
1006	109	4
1072	505	3
1130	1014	6
1235	1083	4
1218	957	4
1021	420	2
1100	287	2
1208	107	3
1082	562	2
1227	431	2
1051	1063	4
1058	179	5
1235	485	5
1057	836	2
1177	322	3
1006	978	5
1145	718	3
1235	715	6
1014	385	2
1071	1084	3
1162	660	7
1199	873	4
1108	1003	5
1004	1013	2
1234	202	3
1079	639	3
1157	475	1
1145	866	4
1228	676	4
1009	1036	1
1088	135	1
1066	593	3
1145	380	5
1060	455	3
1239	1081	1
1065	819	2
1137	181	3
1073	691	5
1196	541	3
1201	600	4
1099	148	2
1185	673	1
1168	313	4
1217	983	1
1173	1048	3
1018	1063	2
1097	525	1
1016	480	1
1164	108	3
1193	767	4
1021	743	3
1020	770	1
1212	918	7
1196	230	4
1080	390	3
1017	1013	4
1119	806	3
1182	101	3
1186	807	3
1021	181	4
1178	577	4
1058	757	6
1218	654	5
1197	845	4
1146	477	1
1091	146	3
1218	850	6
1070	927	1
1043	971	4
1076	285	4
1143	1036	3
1164	447	4
1113	565	4
1043	620	5
1006	1080	6
1055	784	2
1162	911	8
1034	494	0
1240	1019	1
1058	229	7
1071	347	4
1059	218	4
1100	662	3
1168	479	5
1123	1065	1
1239	114	2
1196	806	5
1160	599	2
1210	562	5
1049	893	3
1176	697	1
1032	890	2
1211	146	3
1054	161	3
1122	112	4
1041	690	3
1134	991	2
1206	1097	5
1241	798	4
1082	1003	3
1107	358	4
1198	1014	2
1121	145	3
1228	950	5
1057	311	3
1005	636	2
1132	185	1
1063	106	1
1034	327	1
1244	894	4
1249	917	2
1156	555	2
1106	867	2
1207	556	4
1229	292	3
1058	182	8
1160	372	3
1091	626	4
1198	997	3
1027	830	1
1044	784	5
1119	997	4
1203	403	3
1065	766	3
1186	526	4
1240	849	2
1168	210	6
1165	436	3
1195	169	1
1072	598	4
1035	381	5
1118	299	3
1085	1084	5
1041	818	4
1241	260	5
1099	546	3
1173	1062	4
1164	527	5
1096	515	3
1148	248	5
1057	172	4
1019	854	1
1217	468	2
1067	490	3
1235	237	7
1188	956	1
1098	593	1
1147	685	3
1069	617	2
1218	954	7
1210	244	6
1166	909	3
1077	342	2
1240	669	3
1248	961	5
1198	915	4
1153	864	5
1218	555	8
1094	993	1
1152	1051	2
1095	830	6
1110	375	2
1138	536	4
1124	481	4
1223	305	0
1148	121	6
1073	790	6
1084	608	3
1100	647	4
1055	297	3
1089	202	2
1009	700	2
1103	473	4
1033	267	5
1162	607	9
1089	520	3
1189	368	3
1227	209	3
1189	170	4
1063	474	2
1231	731	2
1125	195	4
1033	652	6
1064	911	5
1111	201	2
1008	760	6
1087	237	4
1098	1076	2
1130	995	7
1148	591	7
1188	461	2
1067	472	5
1018	225	3
1027	928	2
1167	1088	2
1230	638	4
1186	1067	5
1068	699	4
1109	553	4
1059	1007	5
1199	922	5
1155	1026	2
1197	969	5
1217	114	3
1193	545	5
1047	911	3
1185	114	2
1187	815	2
1009	632	3
1051	316	5
1186	881	6
1006	870	7
1073	572	7
1063	270	3
1088	632	2
1201	611	5
1189	173	5
1097	146	2
1218	194	9
1031	301	6
1207	651	5
1124	463	5
1241	286	6
1148	1094	9
1230	350	5
1129	714	1
1081	544	2
1050	185	3
1069	359	3
1165	262	4
1079	878	4
1074	279	4
1055	488	4
1136	492	2
1039	315	1
1117	245	2
1146	972	2
1153	541	6
1129	671	2
1187	510	3
1234	527	4
1154	344	3
1243	238	5
1084	319	4
1087	1083	5
1222	691	4
1021	254	5
1052	538	3
1026	210	1
1239	617	3
1121	447	4
1127	1018	7
1054	377	4
1226	632	2
1190	102	4
1131	885	2
1099	753	4
1138	650	5
1086	269	2
1096	900	4
1115	166	3
1237	1100	1
1206	750	6
1047	309	4
1026	972	2
1237	775	2
1076	899	5
1039	262	2
1245	521	3
1037	617	3
1074	729	5
1126	598	2
1061	430	2
1060	691	4
1055	996	5
1062	654	3
1079	303	5
1041	682	5
1079	413	6
1102	335	1
1041	1046	6
1134	632	3
1030	863	5
1212	483	8
1068	407	5
1041	307	7
1167	178	3
1084	407	5
1005	800	3
1075	1073	2
1136	272	3
1139	400	2
1024	1011	3
1070	841	2
1241	866	7
1106	402	3
1168	940	7
1018	683	4
1027	1078	3
1097	582	3
1024	745	4
1044	476	6
1049	277	4
1015	947	3
1092	773	3
1067	504	5
1033	734	7
1019	387	2
1226	180	3
1016	696	2
1192	134	2
1003	187	4
1114	830	7
1100	128	5
1245	470	4
1187	820	4
1025	848	2
1197	148	6
1158	485	2
1172	404	2
1204	777	2
1240	252	4
1166	450	4
1156	358	3
1020	659	2
1163	154	4
1043	495	6
1133	108	5
1140	682	4
1138	133	6
1147	263	4
1075	217	3
1099	944	5
1226	217	4
1067	124	6
1014	317	3
1228	1100	6
1075	929	4
1154	549	4
1045	413	1
1193	721	6
1061	1094	3
1019	897	3
1055	514	6
1042	888	1
1148	175	9
1084	497	6
1077	410	3
1045	692	2
1198	848	5
1107	413	5
1152	738	3
1176	747	2
1161	814	7
1152	939	4
1104	1057	2
1134	113	4
1050	1050	4
1237	942	3
1182	190	4
1095	957	7
1196	298	6
1002	1057	1
1175	469	0
1103	535	5
1069	267	4
1232	223	5
1094	338	2
1011	871	1
1057	513	5
1114	444	8
1076	221	6
1148	1050	10
1078	916	3
1228	1070	7
1243	617	6
1013	661	1
1153	110	7
1171	345	1
1183	511	2
1056	336	1
1118	974	4
1051	598	6
1179	850	4
1170	797	4
1021	378	6
1062	1010	4
1183	909	3
1238	271	2
1019	565	4
1042	227	2
1022	516	4
1109	295	5
1064	859	6
1241	109	8
1083	602	1
1098	222	3
1212	131	9
1206	795	7
1205	749	4
1015	222	4
1112	436	1
1091	799	5
1240	746	5
1073	636	8
1020	348	3
1046	224	2
1123	700	2
1159	865	3
1098	846	4
1129	335	3
1143	1005	4
1200	482	2
1013	135	2
1028	838	3
1035	157	6
1024	769	5
1047	816	5
1179	634	5
1002	643	2
1075	297	5
1187	720	5
1083	142	2
1021	1091	7
1168	599	8
1130	135	8
1076	212	7
1048	472	1
1162	528	10
1136	350	4
1145	454	6
1079	461	7
1099	999	6
1169	186	3
1168	730	9
1022	262	5
1099	269	7
1177	707	4
1156	113	4
1221	870	1
1248	679	6
1067	868	7
1055	862	7
1167	329	4
1139	789	3
1061	102	4
1196	175	7
1233	788	1
1248	214	7
1005	964	4
1178	663	5
1187	864	6
1247	877	5
1106	985	4
1115	788	4
1234	1087	5
1185	365	3
1175	888	1
1185	400	4
1096	416	5
1059	842	6
1132	982	2
1214	662	4
1232	494	5
1109	827	6
1207	915	6
1090	320	2
1074	812	6
1109	214	7
1126	641	3
1127	650	8
1132	749	3
1089	168	4
1241	360	9
1078	310	4
1246	405	3
1170	183	5
1160	127	4
1180	1063	8
1012	782	1
1030	552	6
1146	564	3
1052	192	4
1198	235	6
1209	364	1
1233	483	2
1207	945	7
1057	1075	6
1187	535	7
1127	353	9
1050	630	5
1019	729	5
1189	208	6
1016	540	3
1231	973	3
1197	337	7
1124	341	6
1083	754	3
1070	107	3
1106	1061	5
1063	368	4
1052	296	5
1168	955	10
1042	849	3
1109	1067	8
1069	716	5
1155	564	3
1175	438	2
1217	254	4
1004	610	3
1020	269	4
1018	1023	5
1031	136	7
1111	607	3
1191	862	1
1048	866	2
1086	761	3
1143	101	5
1099	762	8
1175	653	3
1174	1078	1
1079	659	8
1208	832	4
1050	184	6
1202	616	6
1037	209	4
1184	528	2
1156	1034	5
1018	854	6
1020	446	5
1235	245	8
1079	277	9
1061	632	5
1141	636	3
1100	865	6
1233	402	3
1176	431	3
1248	500	8
1196	184	8
1140	568	5
1246	498	4
1178	108	6
1018	762	7
1110	128	3
1161	383	8
1107	633	6
1206	290	8
1140	768	6
1123	188	3
1171	152	2
1065	868	4
1204	662	3
1097	876	4
1249	830	3
1157	689	2
1049	934	5
1230	452	6
1214	674	5
1133	418	6
1179	554	6
1193	674	7
1147	396	5
1144	329	4
1167	319	5
1019	451	6
1223	981	1
1245	415	5
1020	334	6
1082	1068	4
1015	717	5
1010	204	6
1046	576	3
1214	1085	6
1083	1027	4
1012	1002	2
1125	300	5
1222	479	5
1026	278	3
1175	947	4
1122	382	5
1030	223	7
1111	365	4
1210	758	7
1206	689	9
1025	288	3
1244	798	5
1133	480	7
1008	244	7
1120	928	1
1150	1086	1
1001	879	8
1157	134	3
1245	340	6
1173	963	5
1060	805	5
1157	506	4
1104	686	3
1042	803	4
1079	263	10
1047	689	6
1086	190	4
1080	473	4
1002	811	3
1116	747	2
1218	144	10
1179	435	7
1153	135	8
1147	934	6
1043	832	7
1245	739	7
1220	143	4
1230	298	7
1032	1011	3
1232	1062	6
1035	963	7
1225	887	3
1002	689	4
1042	559	5
1009	1051	4
1068	280	6
1062	760	5
1035	1099	8
1184	607	3
1228	935	8
1148	109	11
1096	305	6
1193	712	8
1095	767	8
1241	453	10
1217	520	5
1078	678	5
1188	228	3
1054	832	5
1238	671	3
1168	209	11
1196	706	9
1214	1050	7
1118	476	5
1085	141	6
1070	556	4
1238	656	4
1225	342	4
1218	1061	11
1195	664	2
1211	592	4
1062	728	6
1026	406	4
1009	944	5
1126	951	4
1199	795	6
1238	275	5
1150	990	2
1159	944	4
1076	970	8
1128	767	5
1098	262	5
1113	816	5
1229	649	4
1168	637	12
1201	560	6
1087	248	6
1197	902	8
1026	990	5
1004	452	4
1076	1014	9
1106	950	6
1156	728	6
1038	968	3
1059	345	7
1246	503	5
1077	570	4
1088	883	3
1054	428	6
1135	653	2
1013	1012	3
1092	776	4
1153	808	9
1248	1028	9
1108	769	5
1033	161	8
1108	1014	6
1035	399	9
1145	201	7
1072	237	5
1157	425	5
1164	885	6
1019	107	7
1035	559	10
1030	1031	8
1110	344	4
1217	190	6
1200	652	3
1182	236	5
1044	276	7
1213	884	5
1170	863	6
1202	956	7
1023	595	4
1196	128	10
1127	963	10
1041	186	8
1182	654	6
1103	957	6
1030	234	9
1141	139	4
1218	377	12
1037	355	5
1006	818	8
1043	297	8
1174	377	2
1085	652	7
1162	537	11
1116	936	3
1205	171	5
1070	778	5
1216	837	6
1057	860	7
1154	809	5
1196	527	11
1020	1039	7
1025	714	4
1152	973	5
1030	977	10
1118	1095	6
1105	1048	2
1243	417	7
1168	440	13
1078	629	6
1250	552	1
1182	735	7
1012	1092	3
1007	926	1
1246	137	6
1154	482	6
1162	591	12
1209	847	2
1130	748	9
1079	228	11
1194	1098	4
1225	255	5
1057	467	8
1008	593	8
1022	551	6
1178	895	7
1133	215	8
1039	190	3
1040	1058	2
1247	393	6
1173	183	6
1157	398	6
1030	1043	11
1035	230	11
1097	576	5
1168	540	14
1186	658	7
1112	771	2
1064	543	7
1234	160	6
1084	212	7
1018	981	8
1228	961	9
1205	982	6
1174	966	3
1190	211	5
1033	555	9
1010	938	7
1244	158	6
1076	914	10
1199	184	7
1249	543	4
1185	355	5
1192	827	3
1063	1063	5
1209	322	3
1051	276	7
1042	860	6
1115	194	5
1222	275	6
1164	900	7
1218	347	13
1014	624	4
1246	849	7
1071	801	5
1244	248	7
1005	735	5
1022	927	7
1244	878	8
1135	840	3
1124	448	7
1021	929	8
1160	361	5
1103	445	7
1149	307	6
1237	387	4
1200	846	4
1086	448	5
1034	896	2
1058	848	9
1150	155	3
1205	280	7
1088	522	4
1146	638	4
1026	983	6
1102	334	2
1050	1086	7
1135	560	4
1028	251	4
1117	682	3
1134	436	5
1193	934	9
1201	534	7
1114	313	9
1237	791	5
1133	616	9
1167	609	6
1240	815	6
1063	249	6
1189	467	7
1206	798	10
1143	702	6
1044	282	8
1117	827	4
1209	368	4
1133	773	10
1146	437	5
1014	788	5
1004	941	5
1109	716	9
1126	274	5
1161	201	9
1192	319	4
1092	997	5
1221	575	2
1174	943	4
1216	189	7
1068	1014	7
1200	561	5
1205	913	8
1176	1048	4
1061	354	6
1128	501	6
1035	910	12
1199	1039	8
1094	810	3
1029	387	6
1045	798	3
1230	457	8
1167	188	7
1182	943	8
1141	467	5
1012	410	4
1181	227	3
1179	433	8
1168	1059	15
1045	432	4
1033	695	10
1038	829	4
1169	365	4
1220	1073	4
1042	235	7
1186	434	8
1022	306	8
1039	982	4
1228	633	10
1009	807	6
1114	1058	10
1190	852	6
1061	573	7
1179	882	9
1180	652	9
1088	779	5
1009	792	7
1099	859	9
1236	839	2
1084	473	8
1222	150	7
1102	1041	3
1167	473	8
1186	147	9
1225	355	6
1064	342	8
1237	470	6
1037	985	6
1239	1088	4
1129	186	4
1153	1086	10
1059	664	8
1115	286	6
1081	245	3
1208	772	5
1215	837	5
1136	987	5
1113	629	6
1027	469	4
1139	157	4
1064	1065	9
1093	335	3
1001	718	9
1164	679	8
1122	635	6
1125	631	6
1052	745	6
1203	384	4
1171	169	3
1007	590	2
1173	1025	7
1053	889	5
1066	638	4
1109	597	10
1208	219	6
1209	785	5
1232	160	7
1142	1020	4
1242	150	3
1167	198	9
1051	1088	8
1115	664	7
1063	477	7
1132	451	4
1118	734	7
1234	1010	7
1181	596	4
1008	341	9
1237	725	7
1160	875	6
1168	347	16
1015	721	6
1249	238	5
1177	1042	5
1239	778	5
1092	568	6
1244	984	9
1145	799	8
1047	770	7
1140	516	7
1143	1064	7
1171	720	4
1146	379	6
1074	1065	7
1115	770	8
1053	633	6
1063	883	8
1095	257	9
1216	313	8
1026	1049	7
1008	210	10
1127	414	11
1037	927	7
1153	319	11
1027	126	5
1222	705	8
1164	311	9
1052	833	7
1113	893	7
1139	643	5
1127	187	12
1100	130	7
1154	626	7
1080	391	5
1240	1091	7
1167	1078	10
1084	141	9
1156	626	7
1243	177	8
1142	405	5
1089	382	5
1202	329	8
1011	526	2
1029	207	6
1180	287	10
1069	611	6
1153	714	12
1015	619	7
1039	270	5
1170	1028	7
1233	123	4
1246	220	8
1071	667	6
1034	542	3
1224	155	2
1117	323	5
1137	214	4
1249	302	6
1193	881	10
1148	121	13
1044	686	9
1004	337	6
1148	656	13
1061	895	8
1224	720	3
1184	426	4
1128	851	7
1156	177	8
1212	179	10
1174	1038	5
1081	595	4
1015	942	8
1136	800	6
1042	732	8
1137	598	5
1197	605	9
1221	368	3
1195	989	3
1235	740	9
1244	910	10
1206	1027	11
1237	245	8
1010	819	8
1144	542	5
1246	232	9
1050	346	8
1039	199	6
1059	696	9
1121	350	5
1037	183	8
1035	896	13
1049	281	6
1012	193	5
1121	463	6
1054	418	7
1171	495	5
1058	785	10
1120	873	2
1055	511	8
1171	427	6
1195	345	4
1179	331	10
1008	421	11
1182	1063	9
1015	1087	9
1030	937	12
1234	877	8
1167	538	11
1057	180	9
1038	491	5
1190	672	7
1025	621	5
1199	800	9
1080	229	6
1219	312	3
1011	493	3
1200	399	6
1138	609	7
1122	317	7
1016	528	4
1224	114	4
1016	987	5
1006	991	9
1229	501	5
1230	352	9
1096	769	7
1011	581	4
1013	812	4
1147	970	7
1037	370	9
1113	721	8
1189	423	8
1058	442	11
1210	1058	8
1087	820	7
1032	633	4
1136	613	7
1002	732	5
1233	560	5
1113	1006	9
1220	886	5
1154	694	8
1014	559	6
1139	547	6
1111	966	5
1188	539	4
1037	593	10
1027	598	6
1241	1099	11
1014	541	7
1105	653	3
1040	1081	3
1076	983	11
1060	808	6
1007	955	3
1090	790	3
1230	937	10
1239	870	6
1142	995	6
1209	1080	6
1062	506	7
1150	482	4
1205	762	9
1145	432	9
1203	822	5
1209	753	7
1006	826	10
1146	399	7
1064	792	10
1182	135	10
1009	368	8
1073	1015	9
1174	513	6
1063	926	9
1236	334	3
1154	1070	9
1053	438	7
1175	775	5
1017	1036	5
1117	256	6
1240	221	8
1029	962	7
1183	328	4
1105	804	4
1243	859	10
1232	446	8
1229	226	6
1228	1049	11
1215	878	6
1194	775	5
1074	205	8
1020	970	8
1161	363	10
1161	791	11
1119	646	5
1067	240	8
1233	586	6
1122	407	8
1172	116	3
1169	601	5
1225	112	7
1183	910	5
1237	111	9
1151	723	3
1030	470	13
1205	744	10
1059	858	10
1082	862	5
1212	1069	11
1093	333	4
1069	524	7
1180	1021	11
1180	1076	12
1111	459	6
1029	414	8
1113	679	10
1041	175	9
1059	296	11
1069	666	8
1161	636	12
1180	709	13
1160	152	7
1158	517	3
1124	414	8
1231	317	4
1204	562	4
1197	697	10
1241	752	12
1203	714	6
1035	461	14
1108	964	7
1138	952	8
1216	557	9
1040	267	4
1205	1072	11
1083	543	5
1195	251	5
1042	946	9
1243	977	10
1169	734	6
1069	244	9
1150	702	5
1223	579	2
1137	726	6
1191	586	2
1029	299	9
1198	170	7
1015	856	10
1198	914	8
1002	130	6
1154	1065	10
1168	351	17
1099	202	10
1200	286	7
1099	502	11
1122	1014	9
1174	314	7
1056	122	2
1041	136	10
1176	721	5
1233	113	7
1117	816	7
1188	477	5
1135	532	5
1161	1046	13
1204	772	5
1137	290	7
1171	1011	7
1079	398	12
1084	287	10
1021	720	9
1195	636	6
1202	869	9
1168	320	18
1012	459	6
1205	861	12
1120	730	3
1221	874	4
1065	352	5
1184	906	5
1212	213	12
1105	965	5
1219	166	4
1051	493	9
1124	480	9
1048	616	3
1175	585	6
1225	156	8
1232	408	9
1235	1085	10
1217	836	7
1241	1015	13
1220	1014	6
1225	1056	9
1067	535	9
1161	874	14
1123	940	4
1023	190	5
1137	825	8
1033	153	11
1001	589	10
1054	1067	8
1213	842	6
1042	754	10
1067	534	10
1239	882	7
1228	1024	12
1140	257	8
1021	332	10
1164	168	10
1040	939	5
1053	332	8
1169	756	7
1178	802	8
1023	907	6
1119	212	6
1050	663	9
1198	345	9
1104	960	4
1066	999	5
1034	917	4
1088	388	6
1036	1029	4
1134	429	6
1167	840	12
1200	1057	8
1072	344	6
1204	1039	6
1218	106	14
1097	717	6
1011	379	5
1066	777	6
1029	1063	10
1064	574	11
1175	950	7
1192	282	5
1183	701	6
1065	219	6
1090	750	4
1024	326	6
1014	169	8
1236	751	4
1137	589	9
1077	576	5
1159	202	5
1173	1032	8
1053	314	9
1214	409	8
1130	516	10
1207	307	8
1157	556	7
1219	683	5
1076	1047	12
1232	583	10
1081	960	5
1051	474	10
1210	299	9
1106	649	7
1125	260	7
1250	989	2
1149	1067	7
1122	487	10
1185	387	6
1064	1025	12
1178	1045	9
1103	527	8
1206	452	12
1094	562	4
1081	158	6
1006	762	11
1031	996	8
1047	279	8
1057	407	10
1146	437	9
1038	834	6
1083	565	6
1145	600	10
1158	982	4
1222	1048	9
1172	506	4
1013	761	5
1227	234	4
1028	210	5
1042	635	11
1038	182	7
1211	545	5
1111	538	7
1163	443	5
1050	239	10
1236	719	5
1210	285	10
1174	1033	8
1079	1038	13
1134	216	7
1047	165	9
1165	578	5
1019	1021	8
1046	388	4
1103	853	9
1171	831	8
1005	1030	6
1183	1042	7
1224	232	5
1058	497	12
1156	720	9
1087	317	8
1034	722	5
1069	372	10
1010	593	9
1225	546	10
1114	144	11
1229	123	7
1056	993	3
1040	560	6
1043	547	9
1017	1081	6
1101	358	0
1148	617	14
1143	372	8
1227	686	5
1217	268	8
1134	535	8
1132	863	5
1057	226	11
1034	524	6
1102	932	4
1061	716	9
1034	125	7
1076	678	13
1018	161	9
1193	1095	11
1192	363	6
1033	709	12
1122	787	11
1037	665	11
1102	251	5
1163	686	6
1196	446	12
1014	369	9
1070	1077	6
1228	833	13
1011	794	6
1192	140	7
1034	1018	8
1076	412	14
1040	470	7
1087	245	9
1213	467	7
1037	380	12
1213	180	8
1094	177	5
1065	1038	7
1130	1072	11
1235	638	11
1046	1009	5
1225	196	11
1132	521	6
1240	732	9
1054	522	9
1030	104	14
1169	805	8
1002	661	7
1073	489	10
1164	962	11
1226	940	5
1014	511	10
1138	673	9
1070	1048	7
1068	169	8
1127	938	13
1092	367	7
1074	278	9
1234	831	9
1141	163	6
1019	688	9
1090	160	5
1105	217	6
1006	543	12
1121	386	7
1166	1030	5
1218	849	15
1189	887	9
1087	316	10
1097	140	7
1204	895	7
1100	1054	8
1004	186	7
1248	969	10
1178	635	10
1147	811	8
1066	791	7
1200	243	9
1129	578	5
1203	845	7
1139	938	7
1066	474	8
1181	850	5
1124	229	10
1120	606	4
1058	898	13
1126	402	6
1145	377	11
1021	658	11
1165	463	6
1082	257	6
1223	330	3
1071	274	7
1164	1054	12
1028	417	6
1234	738	10
1162	887	13
1020	196	9
1045	856	5
1104	562	5
1085	114	8
1028	1048	7
1181	455	6
1063	868	10
1142	1023	7
1137	116	10
1247	837	7
1210	1008	11
1070	447	8
1113	307	11
1118	808	8
1185	446	7
1051	1021	11
1022	892	9
1108	572	8
1002	122	8
1247	362	8
1208	1083	7
1114	843	12
1068	282	9
1217	559	9
1187	705	8
1093	584	5
1075	145	6
1026	183	8
1131	483	3
1009	1046	9
1210	298	12
1046	1053	6
1098	327	6
1050	613	11
1099	939	12
1223	486	4
1162	858	14
1022	134	10
1163	348	7
1024	541	7
1238	783	6
1183	875	8
1011	721	7
1250	1019	3
1145	1098	12
1142	408	8
1099	477	13
1125	937	8
1158	883	5
1109	113	11
1078	1022	7
1039	871	7
1165	614	7
1105	763	7
1094	602	6
1052	453	8
1046	159	7
1118	101	9
1094	898	7
1177	203	6
1055	404	9
1073	669	11
1093	191	6
1029	652	11
1238	739	7
1109	578	12
1063	1065	11
1021	848	12
1020	286	10
1028	1074	8
1052	978	9
1213	269	9
1184	196	6
1073	1064	12
1035	896	16
1042	486	12
1157	729	8
1106	661	8
1090	500	6
1140	565	9
1137	482	11
1207	1096	9
1027	563	7
1004	409	8
1103	768	10
1093	817	7
1098	233	7
1147	989	9
1202	1099	10
1032	196	5
1197	878	11
1212	174	13
1152	443	6
1111	364	8
1073	559	13
1015	344	11
1123	283	5
1166	403	6
1098	1075	8
1164	155	13
1148	797	15
1158	233	6
1065	642	8
1224	517	6
1236	139	6
1011	1063	8
1214	475	9
1192	384	8
1084	1091	11
1167	703	13
1030	568	15
1207	287	10
1103	309	11
1043	152	10
1048	120	4
1250	173	4
1237	565	10
1175	328	8
1148	272	16
1239	398	8
1047	1040	10
1041	827	11
1179	877	11
1154	272	11
1084	348	12
1151	1052	4
1244	675	11
1147	953	10
1202	355	11
1034	942	9
1031	864	9
1136	408	8
1172	904	5
1236	929	7
1189	672	10
1086	190	7
1228	250	14
1018	1092	10
1030	859	16
1224	697	7
1218	918	16
1111	480	9
1197	882	12
1014	565	11
1003	640	5
1154	295	12
1168	889	19
1005	351	7
1122	488	12
1139	1010	8
1178	209	11
1165	920	8
1072	708	7
1174	1029	9
1185	761	8
1053	965	10
1091	138	6
1224	182	8
1101	795	1
1073	206	14
1194	1032	6
1057	418	12
1129	905	6
1005	706	8
1096	623	8
1014	963	12
1011	1058	9
1055	882	10
1151	882	5
1249	958	7
1104	774	6
1227	638	6
1017	767	7
1155	240	4
1030	727	17
1125	450	9
1136	379	9
1129	136	7
1070	397	9
1090	103	7
1060	768	7
1120	150	5
1243	313	11
1191	455	3
1185	417	9
1011	203	10
1164	206	14
1038	946	8
1005	1029	9
1247	723	9
1203	262	8
1207	554	11
1192	492	9
1142	827	9
1202	632	12
1076	550	15
1173	353	9
1028	236	9
1179	150	12
1136	643	10
1132	159	7
1091	447	7
1187	483	9
1184	759	7
1012	469	7
1175	482	9
1206	500	13
1094	931	8
1207	1061	12
1004	589	9
1025	563	6
1189	660	11
1132	342	8
1020	496	11
1079	765	14
1046	469	8
1219	563	6
1044	940	10
1182	274	11
1246	963	10
1197	488	13
1223	891	5
1150	329	6
1248	302	11
1005	298	10
1206	742	14
1007	717	4
1038	1032	9
1205	306	13
1053	988	11
1002	898	9
1100	600	9
1060	332	8
1223	750	6
1196	469	13
1072	180	8
1095	1005	10
1001	892	11
1085	580	9
1169	590	9
1144	623	6
1017	717	8
1060	750	9
1070	771	10
1140	561	10
1124	778	11
1154	871	13
1093	725	8
1200	321	10
1244	120	12
1228	794	15
1065	663	9
1134	762	9
1206	303	15
1185	1036	10
1174	764	10
1058	509	14
1078	419	8
1107	1062	7
1132	373	9
1226	153	6
1161	333	15
1087	745	11
1214	790	10
1014	616	13
1227	497	7
1105	934	8
1218	748	17
1116	439	4
1247	352	10
1025	1061	7
1029	1063	13
1105	266	9
1218	378	18
1249	464	8
1067	1040	11
1094	997	9
1115	210	9
1122	590	13
1172	812	6
1236	675	8
1077	855	6
1243	694	12
1013	1087	6
1122	244	14
1112	132	3
1200	1008	11
1184	146	8
1132	319	10
1170	618	8
1144	349	7
1158	990	7
1218	785	19
1012	1012	8
1220	889	7
1088	761	7
1071	900	8
1076	630	16
1222	529	10
1126	108	7
1171	1061	9
1059	1049	12
1104	870	7
1043	678	11
1125	936	10
1025	501	8
1046	665	9
1081	117	7
1174	814	11
1029	1014	13
1227	143	8
1206	1049	16
1147	146	11
1112	397	4
1019	178	10
1247	643	11
1177	280	7
1184	463	9
1133	133	11
1125	267	11
1250	134	5
1040	604	8
1018	257	11
1184	242	10
1238	120	8
1139	957	9
1015	135	12
1180	465	14
1185	914	11
1214	820	11
1018	731	12
1084	496	13
1133	191	12
1157	346	9
1072	384	9
1198	1066	10
1084	802	14
1012	1085	9
1175	555	10
1238	477	9
1059	378	13
1040	148	9
1025	601	9
1082	1068	8
1008	419	12
1007	575	5
1125	906	12
1099	718	14
1053	119	12
1174	1037	12
1213	813	10
1128	644	8
1116	146	5
1150	569	7
1166	342	7
1248	143	12
1202	1076	13
1204	427	8
1136	339	11
1032	366	6
1046	989	10
1065	286	10
1250	950	6
1042	624	13
1225	1047	12
1085	1047	10
1226	362	7
1193	216	12
1212	557	14
1198	1001	11
1159	978	6
1211	1036	6
1071	517	9
1134	524	10
1066	1084	9
1202	376	14
1090	960	8
1151	219	6
1224	901	9
1059	467	14
1145	403	13
1238	1053	10
1222	702	11
1034	578	10
1013	951	7
1142	776	10
1195	970	7
1153	420	13
1042	789	14
1037	135	13
1009	759	10
1088	801	8
1194	763	7
1038	847	10
1132	781	11
1167	889	14
1087	718	12
1115	1077	10
1192	241	10
1217	795	10
1178	657	12
1003	336	6
1116	631	6
1050	552	12
1163	277	8
1048	840	5
1096	822	9
1037	198	14
1091	161	8
1174	893	13
1110	480	5
1166	186	8
1017	960	9
1087	642	13
1127	574	14
1029	883	14
1117	916	8
1038	1033	11
1190	554	8
1152	535	7
1063	721	12
1016	140	6
1229	467	8
1160	633	8
1061	998	10
1220	110	8
1110	360	6
1082	554	8
1186	1058	10
1176	949	6
1009	1074	11
1115	611	11
1201	689	8
1061	692	11
1192	866	11
1172	1020	7
1035	561	16
1139	533	10
1081	213	8
1005	1020	11
1024	244	8
1034	447	11
1176	865	7
1031	644	10
1207	146	13
1121	632	8
1005	760	12
1115	1028	12
1048	1031	6
1178	955	13
1199	1037	10
1010	1091	10
1146	724	9
1032	228	7
1133	422	13
1073	972	15
1094	508	10
1087	814	14
1180	555	15
1065	931	11
1075	205	7
1159	422	7
1184	515	11
1248	908	13
1120	810	6
1089	630	6
1103	153	12
1167	289	15
1190	951	9
1217	860	11
1174	475	14
1090	1002	9
1066	1055	10
1011	527	11
1190	1010	10
1055	1012	11
1030	588	18
1128	141	9
1222	881	12
1003	790	7
1068	618	10
1049	502	7
1062	653	8
1214	326	12
1138	781	10
1059	802	15
1194	921	8
1057	199	13
1185	901	12
1090	783	10
1157	210	10
1205	645	14
1217	971	12
1026	677	9
1191	1042	4
1128	1060	10
1105	266	11
1227	912	9
1056	319	4
1238	1075	11
1218	561	20
1174	724	15
1168	973	20
1156	657	10
1188	865	6
1157	737	11
1143	983	9
1178	673	14
1244	998	13
1043	590	12
1091	260	9
1213	755	11
1225	298	13
1069	801	11
1166	101	9
1179	491	13
1151	612	7
1024	123	9
1217	783	13
1146	243	10
1184	603	12
1021	718	13
1026	723	10
1196	1072	14
1049	1096	8
1076	814	17
1246	1094	11
1130	448	12
1136	504	12
1102	672	6
1238	1019	12
1060	896	10
1080	1014	7
1027	392	8
1225	216	14
1058	1098	15
1105	146	11
1062	663	9
1193	305	13
1117	626	9
1159	694	8
1137	559	12
1104	964	8
1143	643	10
1175	344	11
1088	296	9
1030	1010	19
1231	886	5
1010	813	11
1215	1053	7
1159	277	9
1175	648	12
1220	623	9
1027	295	9
1084	1006	15
1085	535	11
1031	287	11
1150	142	8
1224	356	11
1088	936	10
1226	665	8
1024	511	10
1098	1044	9
1167	974	16
1108	408	9
1242	546	4
1170	284	9
1158	458	8
1231	699	6
1052	405	10
1109	1046	13
1007	1038	6
1191	218	5
1075	360	8
1163	817	9
1051	201	12
1202	690	15
1034	351	12
1035	386	17
1059	755	16
1217	174	14
1059	268	17
1155	1021	5
1246	395	12
1106	726	9
1048	901	7
1057	739	14
1147	254	12
1192	719	12
1016	364	7
1131	719	4
1176	877	8
1230	119	11
1082	191	9
1170	773	10
1233	295	8
1094	1066	11
1222	839	13
1029	290	15
1228	578	16
1135	378	6
1134	868	11
1223	1034	7
1154	132	14
1029	362	16
1151	393	8
1159	492	10
1156	158	11
1086	761	8
1041	452	12
1242	741	5
1037	575	15
1202	1048	16
1201	360	9
1087	333	15
1021	363	14
1091	236	10
1077	514	7
1219	678	7
1181	556	7
1109	978	14
1216	545	10
1144	769	8
1115	560	13
1189	594	12
1085	886	12
1200	357	12
1176	437	9
1136	426	13
1184	547	13
1136	544	14
1192	307	13
1169	1091	10
1090	670	11
1244	605	14
1202	857	17
1105	875	12
1056	461	5
1158	520	9
1230	1017	12
1193	1092	14
1182	228	12
1018	555	13
1114	155	13
1118	226	10
1089	759	7
1060	817	11
1130	112	13
1156	381	12
1201	628	10
1105	478	13
1113	462	12
1030	432	20
1060	136	12
1191	139	6
1131	123	5
1107	565	8
1011	498	12
1153	744	14
1158	963	10
1095	827	11
1048	842	8
1059	1067	18
1152	489	8
1041	106	13
1205	368	15
1108	702	10
1009	140	12
1048	879	9
1067	462	12
1008	168	13
1057	230	15
1025	353	10
1236	706	9
1118	797	11
1002	1022	10
1058	883	16
1187	175	10
1155	304	6
1128	139	11
1148	965	17
1205	722	16
1001	607	12
1221	577	5
1025	140	11
1157	167	12
1198	638	12
1212	653	15
1059	939	19
1006	507	13
1102	948	7
1188	697	7
1211	1028	7
1076	1067	18
1180	210	16
1231	423	7
1178	509	15
1125	451	13
1233	903	9
1046	496	11
1058	408	17
1247	476	12
1096	718	10
1099	341	15
1010	731	12
1093	1035	9
1092	1027	8
1244	485	15
1038	1057	12
1083	293	7
1074	166	10
1183	410	9
1076	968	19
1146	929	11
1061	330	12
1044	1058	11
1127	640	15
1006	722	14
1163	829	10
1230	330	13
1045	826	6
1241	659	14
1035	234	18
1219	642	8
1146	756	12
1227	744	10
1211	304	8
1043	868	13
1069	579	12
1187	305	11
1212	852	16
1242	480	6
1188	755	8
1134	935	12
1218	733	21
1145	1056	14
1165	236	9
1137	1078	13
1082	1051	10
1190	219	11
1204	402	9
1065	195	12
1193	371	15
1129	959	8
1159	122	11
1229	927	9
1222	329	14
1002	786	11
1030	313	21
1205	771	17
1140	524	11
1137	388	14
1116	1069	7
1245	550	8
1116	186	8
1106	824	10
1143	1087	11
1053	247	13
1100	290	10
1230	789	14
1076	423	20
1210	866	13
1078	509	9
1016	622	8
1060	114	13
1144	514	9
1167	1099	17
1127	962	16
1008	227	14
1196	1036	15
1165	332	10
1172	704	8
1051	788	13
1179	149	14
1177	1080	8
1199	437	11
1214	108	13
1198	675	13
1112	176	5
1027	1022	10
1028	1021	10
1033	206	13
1138	834	11
1095	638	12
1050	219	13
1119	957	7
1072	1093	10
1215	599	8
1249	140	9
1044	1066	12
1240	591	10
1022	765	11
1146	278	13
1184	1096	14
1222	652	15
1068	514	11
1247	1080	13
1177	674	9
1188	606	9
1134	525	13
1075	678	9
1026	946	11
1082	1085	11
1145	207	15
1215	1016	9
1092	164	9
1007	646	7
1159	231	12
1001	767	13
1106	726	12
1128	1053	12
1173	322	10
1216	727	11
1134	310	14
1046	731	12
1171	600	10
1225	880	15
1054	1001	10
1013	337	8
1198	1091	14
1221	836	6
1135	136	7
1230	637	15
1236	780	10
1245	778	9
1102	468	8
1088	137	11
1189	288	13
1109	135	15
1108	491	11
1145	878	16
1092	280	10
1163	1090	11
1117	875	10
1091	981	11
1093	767	10
1028	203	11
1184	347	15
1039	388	8
1046	585	13
1023	523	7
1136	123	15
1187	307	12
1004	738	10
1248	839	14
1161	580	16
1206	122	17
1166	1028	10
1063	532	13
1111	201	11
1218	826	22
1250	845	7
1163	225	12
1133	495	14
1152	457	9
1042	740	15
1202	158	18
1096	683	11
1166	647	11
1139	1079	11
1119	481	8
1155	804	7
1227	387	11
1014	932	14
1179	444	15
1077	638	8
1068	965	12
1187	568	13
1086	1028	8
1212	1059	17
1169	886	11
1002	662	12
1002	119	13
1034	1077	13
1089	957	8
1161	348	17
1201	852	11
1237	155	11
1136	578	16
1097	171	8
1119	822	9
1090	353	12
1238	165	13
1109	126	16
1125	1091	14
1229	706	10
1044	203	13
1059	989	20
1038	188	13
1123	167	6
1020	187	12
1230	739	16
1057	174	16
1024	324	11
1140	424	12
1205	528	18
1120	714	7
1231	860	8
1001	732	14
1093	726	11
1037	482	16
1141	1056	7
1141	962	8
1073	918	16
1118	920	12
1061	364	13
1152	714	10
1014	200	15
1238	522	14
1103	771	13
1146	654	14
1202	666	19
1169	855	12
1086	146	9
1142	297	11
1203	788	9
1109	850	17
1046	170	14
1199	500	12
1039	856	9
1103	326	14
1030	783	22
1075	838	10
1172	598	9
1079	896	15
1114	587	14
1045	571	7
1197	782	14
1158	321	11
1187	397	14
1199	598	13
1112	782	6
1102	899	9
1184	857	16
1095	883	13
1004	782	11
1033	749	14
1056	601	6
1064	364	13
1173	842	11
1083	998	8
1152	572	11
1221	296	7
1004	614	12
1084	899	16
1060	678	14
1050	913	14
1158	140	12
1244	967	16
1165	441	11
1205	657	19
1241	278	15
1101	492	2
1031	492	12
1196	623	16
1129	713	9
1094	596	12
1167	432	18
1117	395	11
1123	804	7
1243	617	14
1166	118	12
1250	831	8
1056	798	7
1078	178	10
1054	589	11
1043	154	14
1196	453	17
1093	1082	12
1026	639	12
1117	661	12
1115	802	14
1046	215	15
1118	989	13
1075	510	11
1023	773	8
1043	917	15
1151	793	9
1117	437	13
1247	528	14
1020	1059	13
1047	230	11
1069	889	13
1220	308	10
1133	1027	15
1183	840	10
1031	444	13
1141	686	9
1168	320	22
1027	214	11
1006	934	15
1227	404	12
1032	248	8
1122	714	15
1050	1058	15
1164	133	15
1126	430	8
1210	285	15
1086	765	10
1107	155	9
1107	438	10
1228	576	17
1207	352	14
1064	1079	14
1130	337	14
1183	886	11
1242	734	7
1185	1012	13
1232	891	11
1029	974	17
1108	544	12
1191	876	7
1101	935	3
1139	703	12
1132	576	12
1162	877	15
1083	934	9
1055	460	12
1216	268	12
1017	910	10
1239	659	9
1226	459	9
1023	1000	9
1115	857	15
1087	662	16
1247	694	15
1080	275	8
1006	173	16
1146	919	15
1098	349	10
1126	578	9
1095	893	14
1140	835	13
1046	669	16
1117	111	14
1175	1005	13
1073	177	17
1105	876	14
1037	660	17
1060	518	15
1096	371	12
1123	292	8
1138	839	12
1093	280	13
1113	468	13
1024	993	12
1097	514	9
1022	544	12
1246	253	13
1090	528	13
1118	1010	14
1242	928	8
1172	181	10
1174	986	16
1005	395	13
1037	543	18
1074	807	11
1075	433	12
1061	907	14
1156	496	13
1128	235	13
1003	818	8
1074	257	12
1009	184	13
1221	651	8
1013	410	9
1168	669	22
1140	219	14
1169	199	13
1207	848	15
1089	900	9
1005	505	14
1002	762	14
1234	500	11
1095	285	15
1123	543	9
1191	579	8
1023	1076	10
1122	573	16
1110	944	7
1138	691	13
1204	684	10
1217	220	15
1144	964	10
1134	894	15
1192	763	14
1072	265	11
1079	700	16
1139	356	13
1029	813	18
1060	1036	16
1040	334	10
1022	499	13
1145	644	17
1030	285	23
1058	568	18
1034	858	14
1225	221	16
1042	820	16
1128	709	14
1226	969	10
1048	155	10
1154	390	15
1052	586	11
1076	200	21
1082	128	12
1154	336	16
1147	105	13
1065	1044	13
1111	995	11
1052	106	12
1023	681	11
1102	818	10
1241	882	16
1073	1096	18
1178	781	16
1185	1015	14
1222	280	16
1235	949	12
1023	928	12
1052	620	13
1069	306	14
1236	900	11
1207	733	16
1207	813	17
1148	233	18
1033	970	15
1183	390	12
1077	639	9
1142	551	12
1135	179	8
1213	620	12
1225	700	17
1051	148	14
1159	415	13
1229	566	11
1072	343	12
1119	494	10
1175	551	14
1124	106	12
1110	293	8
1146	374	16
1113	996	14
1204	388	11
1172	364	11
1220	1093	11
1140	735	15
1008	163	15
1174	571	17
1101	858	4
1224	435	11
1127	808	17
1182	768	13
1096	802	13
1088	430	12
1059	290	21
1098	481	11
1233	889	10
1116	159	9
1191	520	9
1079	1012	17
1158	676	13
1212	1070	18
1055	919	13
1125	990	15
1053	501	14
1031	776	14
1216	539	13
1231	170	9
1166	121	13
1112	631	7
1246	276	14
1160	685	9
1147	602	14
1144	974	11
1095	111	16
1131	725	6
1132	908	13
1078	464	11
1234	204	12
1113	894	15
1047	914	12
1068	633	13
1239	369	10
1026	290	13
1071	723	10
1097	813	10
1163	1032	13
1002	457	15
1038	134	14
1160	348	10
1226	193	11
1128	500	15
1099	964	16
1191	784	10
1179	610	16
1014	719	16
1146	1088	17
1099	203	17
1164	759	16
1162	894	16
1060	301	17
1110	1027	9
1225	1025	18
1250	1099	9
1054	564	12
1179	879	17
1209	911	8
1075	1001	13
1031	1076	15
1179	621	18
1169	251	14
1032	572	9
1222	1014	17
1165	757	12
1139	703	15
1119	1080	11
1178	750	17
1069	980	15
1117	638	15
1179	145	19
1029	584	19
1066	540	11
1151	1049	10
1220	557	12
1093	956	14
1189	727	14
1085	657	13
1139	211	15
1165	1004	13
1031	714	16
1015	484	13
1250	948	10
1249	799	10
1204	495	12
1230	415	17
1231	601	10
1016	327	9
1238	773	15
1045	906	8
1086	170	11
1017	962	11
1220	788	13
1018	790	14
1168	553	23
1069	1050	16
1099	735	18
1098	696	12
1102	231	11
1014	421	17
1130	222	15
1128	357	16
1155	428	8
1220	906	14
1019	274	11
1050	110	16
1047	740	13
1029	482	20
1001	324	15
1219	471	9
1042	822	17
1154	856	17
1226	138	12
1133	207	16
1115	767	16
1113	704	16
1195	636	9
1020	486	14
1182	665	14
1110	111	10
1123	108	10
1065	264	14
1045	648	9
1168	843	24
1021	182	15
1032	982	10
1208	1001	8
1241	797	17
1142	410	13
1025	805	12
1107	367	11
1188	391	10
1037	151	19
1084	153	17
1247	708	16
1197	775	15
1045	688	10
1119	346	12
1036	358	5
1077	992	10
1123	593	11
1127	756	18
1245	798	10
1221	1057	9
1093	149	15
1138	643	14
1133	602	17
1035	342	19
1119	889	13
1191	1065	11
1012	558	10
1023	318	13
1147	216	15
1151	923	11
1133	829	18
1247	723	18
1006	855	17
1201	253	12
1118	811	15
1061	416	15
1138	984	15
1134	287	16
1172	638	12
1172	879	13
1231	657	11
1093	663	16
1130	234	16
1078	467	12
1228	729	18
1175	571	15
1223	937	8
1038	539	15
1003	443	9
1061	800	16
1034	298	15
1174	691	18
1184	732	17
1082	902	13
1075	838	15
1215	472	10
1106	847	12
1075	921	15
1169	517	15
1250	1030	11
1114	1022	15
1202	1033	20
1146	498	18
1094	936	13
1024	301	13
1048	977	11
1147	819	16
1113	746	17
1032	635	11
1057	630	17
1012	118	11
1096	884	14
1008	809	16
1111	827	12
1006	1085	18
1094	389	14
1205	837	20
1033	1032	16
1047	852	14
1188	913	11
1197	341	16
1112	847	8
1025	362	13
1058	413	19
1229	495	12
1056	321	8
1214	766	14
1037	835	20
1005	776	15
1054	1053	13
1131	458	7
1101	695	5
1169	652	16
1180	1022	17
1053	974	15
1120	303	8
1012	247	12
1028	323	12
1045	709	11
1024	829	14
1091	152	12
1020	701	15
1140	813	16
1208	1096	9
1092	123	11
1199	824	14
1095	878	17
1054	195	14
1118	1020	16
1112	698	9
1028	335	13
1197	434	17
1244	605	18
1248	921	15
1056	912	9
1161	113	18
1176	1056	10
1199	744	15
1067	851	13
1064	968	15
1247	336	18
1052	268	14
1184	144	18
1080	707	9
1111	863	13
1136	871	17
1191	573	12
1109	147	18
1222	363	18
1203	320	10
1022	1034	14
1037	351	21
1247	801	19
1149	390	8
1170	140	11
1133	557	19
1066	369	12
1029	1002	21
1067	575	14
1052	924	15
1039	492	10
1146	280	19
1032	227	12
1155	1051	9
1078	754	13
1115	900	17
1145	621	18
1164	628	17
1232	954	12
1206	290	19
1179	194	20
1190	691	12
1084	323	18
1193	838	16
1227	616	13
1122	948	17
1139	620	16
1195	949	9
1017	906	12
1057	276	18
1021	425	16
1156	354	14
1186	458	11
1068	734	14
1218	712	23
1192	455	15
1120	539	9
1118	541	17
1025	983	14
1071	468	11
1080	897	10
1209	152	9
1115	614	18
1046	264	17
1047	1051	15
1176	998	11
1110	477	11
1050	403	17
1095	456	18
1181	709	8
1231	238	12
1006	722	20
1158	347	14
1202	219	21
1063	985	14
1227	809	14
1121	603	9
1141	800	10
1164	210	18
1206	855	19
1201	777	13
1039	265	11
1192	393	16
1128	505	17
1020	591	16
1122	583	18
1027	374	12
1108	612	13
1029	349	22
1166	380	14
1209	1060	10
1028	111	14
1225	225	19
1217	300	16
1075	1000	16
1234	302	13
1143	1085	12
1154	893	18
1035	829	20
1037	831	22
1021	802	17
1182	975	15
1136	911	18
1108	567	14
1210	823	15
1036	899	6
1030	598	24
1249	164	11
1020	985	17
1004	963	13
1234	872	14
1202	854	22
1165	464	14
1020	915	18
1221	1097	10
1004	247	14
1116	447	10
1182	217	16
1144	720	12
1042	305	18
1151	183	12
1219	528	10
1107	803	12
1136	229	19
1243	567	14
1246	731	15
1144	381	13
1069	412	17
1112	703	10
1120	953	10
1221	379	11
1087	665	17
1089	809	10
1037	543	24
1058	657	20
1088	701	13
1160	488	11
1165	940	15
1075	105	17
1195	390	10
1092	310	12
1245	388	11
1226	267	13
1155	312	10
1174	510	19
1206	351	20
1043	363	16
1248	541	16
1053	747	16
1010	379	13
1047	940	16
1184	569	19
1095	298	19
1034	578	17
1227	751	15
1136	401	20
1029	584	24
1221	680	12
1045	265	12
1089	787	11
1102	674	12
1025	468	15
1140	503	17
1157	717	13
1111	502	14
1234	532	15
1146	292	20
1028	782	15
1164	920	19
1180	253	18
1127	701	19
1209	437	11
1141	1065	11
1216	1003	14
1139	640	17
1058	807	21
1146	654	22
1018	1052	15
1014	600	18
1246	1087	16
1155	493	11
1029	293	24
1069	526	18
1164	538	20
1149	576	9
1007	760	8
1061	994	17
1165	1051	16
1244	339	18
1034	516	17
1058	1097	22
1132	731	14
1015	171	14
1071	269	12
1247	310	20
1092	590	13
1096	429	15
1073	198	19
1022	359	15
1042	346	19
\.


--
-- Data for Name: playlists; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.playlists (playlistid, name, description, userid) FROM stdin;
3113	Liked Music	Music liked by you	16
3114	My Music	Music you have uploaded	16
1001	Playlist-48	hnptymqmocuvwyvdnwuwphuczzevgtnmtquoibayxav	203
1002	Playlist-15	hhpvurhfkzuizzfllisphzftcwzfcdkdwpoatsom	264
1003	Playlist-159	otzpqkwilpy	119
1004	Playlist-30	mxkxixisiptoxsthkxfxtete	278
1005	Playlist-86	gvwennnlpfz	209
1006	Playlist-36	wrrtifasmpzluccpbmvbwubakvqavcactkvdywottmyaltl	126
1007	Playlist-56	dgedguhbrbisoglwtkige	239
1008	Playlist-166	bxslbpycvmalmiuvka	251
1009	Playlist-193	skzfmhwkmkbdrwqytvfgvbpaangfmiwh	120
1010	Playlist-127	xkenxtyfsqnuictatubkvcs	156
1011	Playlist-176	vxpoovhivkugcrzszczuewoyedkkpwngrdvoqlfib	177
1012	Playlist-184	owgfhcggaowluhsrgxxahvmvtbsbszpqdnmvxfdxuk	277
1013	Playlist-85	irsngnhfy	236
1014	Playlist-153	ifxroi	217
1015	Playlist-139	ngmwrhqunbobbqiwsmhwts	212
1016	Playlist-88	uknlmxlmgnnnzqnsxmabwslrr	147
1017	Playlist-194	cmailiwsplev	155
1018	Playlist-190	ywkwueaqllvcsq	231
1019	Playlist-129	nknmghrxdfpxqscu	104
1020	Playlist-195	qvhmvnqzmhmtrevfsrk	283
1021	Playlist-14	gvppsmmeakluggqucewgfdh	131
1022	Playlist-127	gomgxkxznibxxonrvpfwpkbdpprkawknouuunckzcnbcqc	276
1023	Playlist-79	osewozoqhovyipfplskyaelacai	240
1024	Playlist-174	twuxvgxbnxlvposenwfpqncmobadnkgoitdsbgyphkazndo	124
1025	Playlist-0	zavqgcnfevatzpbuydkng	228
1026	Playlist-116	qatpvziuykszpezsxawrbqzorcffkcqi	107
1027	Playlist-139	iixdvuumcxfydpsvkzibekczm	211
1028	Playlist-68	anqheddfegogqfufsvlacq	232
1029	Playlist-35	ubthcbhpxyakdqyhiukhpptgptialvvcmsmcspzgzxwb	130
1030	Playlist-34	vegurigmmvizkc	231
1031	Playlist-77	zobvplmmructasbdrwgawnhrozxeduhqxfqadenurlqcesmv	243
1032	Playlist-175	aornfkpsw	148
1033	Playlist-45	xgwlezrtvzhw	285
1034	Playlist-158	mrmcnvyivvxggehdausubevmmuiuqxiwunxendeu	279
1035	Playlist-19	chnpkalqeivsnyfcuf	271
1036	Playlist-179	gfmftivwnfrifbqxlfzszkuaoneslgl	289
1037	Playlist-136	fowksl	274
1038	Playlist-11	mhhbkkkdmlgufktxsbytitbhxtt	114
1039	Playlist-92	bwvodubilhfltktaq	133
1040	Playlist-65	bindotzcysogspmlsoffnewrxytwntdht	116
1041	Playlist-36	dnosrnszldfzudzbygmkucst	220
1042	Playlist-98	xqzzann	173
1043	Playlist-129	tzwqtzrmeqzgtpyllgczyxhyopdmikmeleyfxsoeccg	296
1044	Playlist-136	zyuzvmrt	148
1045	Playlist-133	sboxadfegqcptmxvgdcabeqewabhqfmlwkmprnlghunvg	150
1046	Playlist-66	ztxdcaqyrctvsmraihhdauorvkkeegdeytrgttksxhkf	138
1047	Playlist-59	fxvngzpdumhopimzvguvoypwcnmgcuh	227
1048	Playlist-98	mqpffvvpgyooh	171
1049	Playlist-22	rnxyrxsfokwismbrleqobdbg	145
1050	Playlist-83	cksop	140
1051	Playlist-137	satyspyvcpyrkyhktmmlefqvlzwrqptxtxzmbeqsafclgrsdl	135
1052	Playlist-51	ccdvazapg	136
1053	Playlist-0	yaudysmpufguekchwhr	255
1054	Playlist-134	wsxkxvivfmltlghcgauwaqeomevhyyntgwhiyefzgavicoyyt	294
1055	Playlist-143	qnyddrdzdvmbollrpszxxduckkohtskaxctro	121
1056	Playlist-120	ixnpoatfgbwndxbkawiygwyqwchv	111
1057	Playlist-43	tmwuzuvlckhzlmerpywaqmpzebvpyyzfckifsovay	159
1058	Playlist-97	goyooqsk	129
1059	Playlist-194	hcrcztsnagppwqyevpqbuvvnvnypzyrgirdhysdiqddlzuff	196
1060	Playlist-52	rokiuqoogkdxfknaahnsufihaqmdhdaeyoqyrhl	151
1061	Playlist-3	tvhhovsswusspfcrmeffaczlikrulmznpccd	152
1062	Playlist-45	ikvpalxctzvekywenfwucddpavwttsopshwazfmhtnry	252
1063	Playlist-56	boxlhzgtlhqs	127
1064	Playlist-57	sttnwpah	159
1065	Playlist-16	qtcbvvlhupkzpkksbzuruierhyawxhibqyeglyxqu	178
1066	Playlist-159	yisrxqciyopahlgrpbdewxtcmkbchlgqnimkmioythmzi	244
1067	Playlist-181	nnmhbffyvptzsxmrrsyrlxthfpoyzbeblqxwkzar	296
1068	Playlist-46	eneqiigimtpkerciofltlnzpcqcbdztz	122
1069	Playlist-165	carndgb	150
1070	Playlist-106	wiugmvkaehxgwqwf	190
1071	Playlist-84	mtcnniuequwicyhhtokdaubreonoazwz	138
1072	Playlist-90	egglslrlkbdsgiyvqueankvtscxeouqlyss	124
1073	Playlist-140	mlpssvtndkqwrvrxfxaiyaeudnvtskgdiyhyft	281
1074	Playlist-45	psqhozeaftcguzanmaggkcgmrvyx	107
1075	Playlist-89	whcwzuvy	189
1076	Playlist-98	lntukbddiipxfvdsxeuvxktorpgmwxdycxcffcx	221
1077	Playlist-196	daogvtkqcqylywctmtcdooucvthzuydnxcbcnhifnymhytngvy	104
1078	Playlist-67	xkyvnynsbqareyivxiqovcpzvyqvxuh	273
1079	Playlist-97	hruvnrvdeavdtwzppoalfqordhroudhyvpwf	265
1080	Playlist-18	ipvwxcndkyggymaxhbal	192
1081	Playlist-113	qqusqckudtydquupxka	261
1082	Playlist-88	fpagemh	193
1083	Playlist-140	ksohygfxg	204
1084	Playlist-80	yiqyoxmxvgbnnesmkaidaxcdczeqtwahlm	266
1085	Playlist-105	vfopwxnubrbtxkcubrnlzmgroazyurp	250
1086	Playlist-24	vdyndulczatqgxqkspiwuksciifixewbryddh	185
1087	Playlist-97	amlueiwsbuhykuxtvagfzbcuutllyvbeubhuplxdrfv	110
1088	Playlist-123	dwdabqdcqfecayg	180
1089	Playlist-58	ydkimtbvcgrmhdgxvm	199
1090	Playlist-4	gduvvwtluixal	232
1091	Playlist-16	fzudaqfhwyhwephbvhzhmx	282
1092	Playlist-161	llchdkxp	172
1093	Playlist-67	mbhvxayaavviksbbfyyqiwzuqpwx	228
1094	Playlist-28	qbxgiuewhvizgdhqqoptb	246
1095	Playlist-15	zdxnfysvnkknkiiuzoyfrlwtvaegpqets	116
1096	Playlist-110	uuphnsyrcmpaalwlmyxdwzhkpfo	284
1097	Playlist-0	bovawxzklcehpaaysqkbqyinc	221
1098	Playlist-181	diwkwfqostbknkrtscyllzwcxxhvltprrhp	232
1099	Playlist-120	rzggmgqhadiaoukvnebmn	206
1100	Playlist-163	pmydqmiiwzdcbzvpsdfbcwhxaickogvdmxeobnthzkpoeqmz	249
1101	Playlist-191	qcvqleyffzywifuiyhlzhxmlwhqlizezfm	150
1102	Playlist-61	izxlscoedwceorhwisugkrkinlnm	112
1103	Playlist-132	tifptbqblecragsbdflddwghhsnocuvzcmugdmsaivcg	240
1104	Playlist-188	tndnobzvlysqklhrbgrzutiamrpeysfkq	186
1105	Playlist-11	fwwwbgyyagczntkovszrzunuh	104
1106	Playlist-101	rhlzmmrkluapcpurdymregkkstdpwglnepuzfhtgnsakn	121
1107	Playlist-54	stzbsgymhmdcwtkrri	231
1108	Playlist-135	tdhkovr	176
1109	Playlist-78	mnzrsdslwdgec	208
1110	Playlist-71	enlystaisvmnamzyosbgikmttxuvdccayoncicqgadmbmg	114
1111	Playlist-194	qfgwpunzxkkeedcmdtzhkqriyik	128
1112	Playlist-181	xyutrulniuedohny	281
1113	Playlist-23	uinaak	215
1114	Playlist-41	vstoibuebbdgtcuoiax	197
1115	Playlist-1	nafviqoriedsl	171
1116	Playlist-118	qbqpvtdnz	270
1117	Playlist-152	cgoivrcwwcicilddlui	127
1118	Playlist-173	qrdpzqgdbesdsoiyircubzapdmeyiirweyzccbfuwitpgazwzb	201
1119	Playlist-173	pqvmguwqgbuncffkxtmsskuaqvivngbdgwtghrnn	146
1120	Playlist-200	vcszereisubnouricstvgrgdxslaakzfvxmwkiehsek	239
1121	Playlist-153	tqpnpt	124
1122	Playlist-113	qspcoscvpocpgcklgwwzcmvliufua	180
1123	Playlist-120	kyvlauvgqwhvvrqhzbxcqzvsbq	209
1124	Playlist-57	lkgvmqhzrofkhmmglqvyxarzafhegbfddodbpi	169
1125	Playlist-17	fnixgihwyzafhzdgrexme	186
1126	Playlist-22	lnifypzvmvncphxnhitaxsgxhadskvvvqshilyqdnihirxvtr	138
1127	Playlist-117	gefilillbfpwowqxvrugffkghkfcqaevda	211
1128	Playlist-145	hunqeptlwssaovhnmvznixox	246
1129	Playlist-45	pfitzpoaklmzpkynickpkqychuoaimhevbqgpglvskcwd	288
1130	Playlist-80	teltmmsabgnfvklxkzrstmssnccgdcamionk	256
1131	Playlist-162	eqqnw	126
1132	Playlist-140	mznpkdtdhrlocmowzofxddmymhqcowhkkidifounzlccbltiei	278
1133	Playlist-127	fdxpbkulfxidkfskaqedbbqwpvozyaex	247
1134	Playlist-56	afgdx	151
1135	Playlist-71	yfpnrzamiffbxfmybfsauokfoallegvfllc	164
1136	Playlist-151	fsgivvhbygrnqedpqakgk	300
1137	Playlist-62	rlgrtbqezchdimeunutbq	183
1138	Playlist-175	ocraqtbbcumbbqiopwaklohgpcirxlviuxmn	179
1139	Playlist-190	tpdlqqauppw	285
1140	Playlist-53	bgmgt	117
1141	Playlist-171	qsgtvxqhtvinegfttzbqvtesafwyxvzc	178
1142	Playlist-140	dehymqqwfvzrrrvchkvrxdsxwwlvqlfpakgwigbdyebah	110
1143	Playlist-183	ehlvexbvlgcrtsyyaat	255
1144	Playlist-190	gpiddnigmapysbnaqytatuqisdilbkfdxenqddoxtpfdlnrw	140
1145	Playlist-126	xliptpifpobmvgtrcixkvboxfiwqxqqqq	259
1146	Playlist-60	qhfyhkerteogpborsldughqxixdafxzlpmgq	276
1147	Playlist-71	yauuoxxlohxkwbdppwbongxryueeeabuk	241
1148	Playlist-182	vttsmerppcucnkmn	143
1149	Playlist-17	nqgusznmzqlogythleofsnbcbb	295
1150	Playlist-139	bbyikxrtarphnhmtztrsqvmtgyaeydketubafelkmmnk	205
1151	Playlist-119	nlylxgcqkdtfdgumvrcrkmwbzuwhaccovyhlqeddoha	117
1152	Playlist-81	oczsgbrkoupizwocxgdphtc	112
1153	Playlist-165	zvhrxlxpdqbuhxtdodvfbhgkwcbrmpqxxybhpqot	196
1154	Playlist-2	ikdlioicnvxdyessadff	220
1155	Playlist-151	hoyamninlwquhltxsybhvh	135
1156	Playlist-134	vfqxouyakcaqlfocde	201
1157	Playlist-47	rrlicnwkwcncmvmtpcdgviknhhgotmlnpubdsetqht	188
1158	Playlist-11	xwasitfvtvsokseeasnitnmtiswgxgybcrhdpapdgvy	283
1159	Playlist-79	uvqhcbfvekyqgechzwydwnzuurnpaqqptdths	224
1160	Playlist-56	udyuvif	117
1161	Playlist-21	hvuxwkaaoetffzzzxdakvykq	156
1162	Playlist-73	zwsyghekbhohrsdtgximwomnoghzmevsw	105
1163	Playlist-74	xshtodbqukkffkgfprdnwh	122
1164	Playlist-187	uykqqqloie	264
1165	Playlist-119	krkxdpvfmweosemwqtvwczixogwqrtged	208
1166	Playlist-43	iqmbofdgctvsytooddmmusbhxpkimcysokumnsvz	289
1167	Playlist-139	vsnykcyxobgbp	153
1168	Playlist-50	vqrsxqntbbicwubrkkffgcgxacoqyk	162
1169	Playlist-12	iwxhlnlkputzxysbhl	127
1170	Playlist-194	qedipeiqgvnnmrxqxddkkewdpwwwuvigcokmrouuzklg	234
1171	Playlist-27	vahthh	253
1172	Playlist-72	tcrpupyepqgogfels	117
1173	Playlist-44	gnweayswpkqnvqmbadcuczxylfehytxycbtkgaewntbibviksw	238
1174	Playlist-171	zkvdotrttxvlwpkorwdqwyxogyqnhwrivzfphlh	184
1175	Playlist-14	ixznirqxnkwpzyl	137
1176	Playlist-192	qofmehnexzelvzucqcyzvzfiqhgzfiwtkvwylrqmnnnfyuep	108
1177	Playlist-158	pzlskvmbh	269
1178	Playlist-95	cfyzyifqdhysolergdbhagkzmgguqeqaorcx	225
1179	Playlist-8	lqteakxaggzbgzcfgcbpwcblyrgczhtrkebzpwhpxxrarsau	209
1180	Playlist-68	whtlsgxmkptrtpngvmppyvflpgsil	281
1181	Playlist-96	xlwieazdzknircnxvledzvaxvf	103
1182	Playlist-59	cxdsngmhbfrdcvrsnbqodbygayprgmclpci	162
1183	Playlist-169	drfel	239
1184	Playlist-17	ldnkqatfpkvwfvzpoqwegymazzntkedrllhimdk	193
1185	Playlist-38	outvyolnaywbo	159
1186	Playlist-97	rwtdtzvrucyfcbhdmrwrrkgtrnttghwqxzobblw	190
1187	Playlist-113	pnimbovvsbkoesacrfmppdrdtwdahzu	194
1188	Playlist-69	exwsltzekfqoqnleoy	253
1189	Playlist-126	zyapzieuxchotayegcymvbtitvzbnnltgibnkzdymwzeyao	111
1190	Playlist-30	lrwemvrqkngtmycpggntneabidogyxvmbgzeiestlhgpvy	120
1191	Playlist-192	cgvlbaxcf	224
1192	Playlist-147	ztgxvwtlbgxfotnokteelaaptwxcydssfdy	285
1193	Playlist-48	ivycobczhoodevytlqmxqwrstc	255
1194	Playlist-99	hudtnpmuozxtnyamiacbagdfpoiicewcsbgonnodxvwgwfo	104
1195	Playlist-18	unrkmsepqikknea	260
1196	Playlist-28	cryihrgvggooliqmyubbsvphwvwonhmsbvydkbogcefvcwtxv	201
1197	Playlist-52	gfcyibdiufahctomobcpdmfnhdlevwchavfqhhddhhopw	240
1198	Playlist-95	gqahwzkvbnaxhirkd	291
1199	Playlist-188	cazhshqikcbmslcnvczcisiagvegzkfwlilicadqagu	108
1200	Playlist-156	bcnnuhpfhilmscwtzesvruohqnmvkctkqlmmgssswayybhl	151
1201	Playlist-76	kqempyswrchcsryzqghgwfkonzmiufqz	154
1202	Playlist-42	ehsyarlzxcoyvegwbqasohremwayeqodszvpdo	245
1203	Playlist-23	wbsbkr	109
1204	Playlist-111	fqcdnwdgdkedszfhheyzcfxtebpmkegfowyxspp	219
1205	Playlist-107	vzkslhyaeycrpfckmgnzczfhym	213
1206	Playlist-148	rxghnieoableslaogrrcvfv	296
1207	Playlist-157	lkiecglzwdxswidnoblmgsloadwhgsnastzkyn	175
1208	Playlist-23	yywngqcldswemx	232
1209	Playlist-48	xgtsesmosbkorfssd	156
1210	Playlist-82	cpktoobslwzkrlikcnhf	126
1211	Playlist-49	mcghbfhydxeonyylizhcavqehsuelpb	199
1212	Playlist-8	bylfavtaxptmkkdehtinlefwwtlkmolfvwmcthbvluhiu	160
1213	Playlist-72	lxcotqyuoyouyzimayvfdpvondnoutabxh	183
1214	Playlist-114	dhgwxepznwbzrihausmhxkhbxaieitluitbo	103
1215	Playlist-108	txbgpsitieoqppprgcvtvgofcrmtphupmqrhbkkfiab	283
1216	Playlist-188	zeqxxyyzkezzwplniwykqbbcvrvodgglkvmikdsnkxrru	205
1217	Playlist-167	rtbswghpzfqqzzmbthdldpnlercbfwlb	225
1218	Playlist-40	grqpuhomixhnotoumcgrrxaycdxbcdcwfqtyoupkwo	186
1219	Playlist-49	wsppcutyycz	266
1220	Playlist-81	adhuyfzfpkwnrdrkqsfm	191
1221	Playlist-119	dklxuzyatawwgssdnorvfprudwrecwhozqhrecuwudiguh	181
1222	Playlist-154	fhavkvkawoiglngmrcixgv	116
1223	Playlist-195	sfweqbookehouumbfbxpzfsfwbnqcgndoztexp	152
1224	Playlist-128	fthsctcuhswklbaqscimixbpzdnskbxbvrheqhxqvolshnkt	222
1225	Playlist-36	cgiqmcfdnwgzgzvdueyxqwbtpqsldgyqusmzyaytq	108
1226	Playlist-106	perrnpxmybohzqeecnyu	278
1227	Playlist-98	ytouziaymgnbkrhkdxhcvymbbhekblgdmcaskyivagngshcy	260
1228	Playlist-38	ozdsuqb	146
1229	Playlist-130	nymogwkarllwrwgxw	115
1230	Playlist-115	dcmrumzytmffepachnzaabtlxv	262
1231	Playlist-198	fxbeuefzbxislprrlitrqnmoefwnnznrcp	192
1232	Playlist-195	nhtrhggyqfuvayscybmazllhuyzobraxe	219
1233	Playlist-194	gbmflrmhdttmn	139
1234	Playlist-21	rttrdxcuvghhzvuyqgwpbfkhndqpputu	182
1235	Playlist-166	henosrrbifywlauoc	291
1236	Playlist-134	npovgrakrywbwnxzq	221
1237	Playlist-197	igmfbvuirnpdxuzxqwedqkruasgxzobnqhbiylefxofwq	260
1238	Playlist-165	ukrfuqlswtlnincnwxcwhzxbxowgquxqarlkexgoqrschsmis	103
1239	Playlist-9	fdxrzagqhheryv	222
1240	Playlist-63	fqxxwclzvbumksmgaymhtgldvuoboualqgyotuhxfypw	204
1241	Playlist-28	uvibgdmokktzhtgrbkuc	107
1242	Playlist-5	bemkevzpbuocibinrpbvzecdzrminkaecgnbrirerppahn	185
1243	Playlist-159	dwubeqakvmlmzlrgkx	140
1244	Playlist-60	kgbvxdbyrkmomhkxrffgztzxchzofvhqtxzu	223
1245	Playlist-200	vrhaovbuo	139
1246	Playlist-18	tixoibfldfpyp	108
1247	Playlist-64	byhkybkxhqf	268
1248	Playlist-166	nxpsyhwdundtwldvolboprmr	149
1249	Playlist-193	ccvyefdldzxlyokuemtvlidpxrys	103
1250	Playlist-52	ztdepohdkyqa	162
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (roleid, name) FROM stdin;
1	admin
2	user
\.


--
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subscriptions (userid, subscribetoid) FROM stdin;
220	140
118	224
108	131
258	265
125	176
278	116
262	266
124	104
142	161
193	184
173	203
295	197
173	155
189	230
204	162
242	197
125	297
237	297
176	288
228	299
188	229
151	277
186	281
174	197
298	172
173	195
268	235
135	281
154	288
122	157
121	164
220	141
162	277
249	186
278	163
144	229
201	186
292	132
206	294
122	198
249	207
273	277
214	278
267	284
256	242
182	259
218	266
279	257
249	165
104	214
204	195
215	190
184	293
280	208
123	210
233	214
161	178
102	219
290	110
252	139
150	108
206	218
184	296
215	171
123	194
257	103
190	196
156	184
186	167
223	107
200	299
191	231
198	165
231	173
248	235
218	274
292	281
153	293
200	190
197	156
161	180
288	115
247	222
200	112
141	168
187	204
200	172
258	231
116	173
156	217
268	160
173	151
214	299
180	167
236	109
135	139
169	243
199	259
282	168
110	206
242	265
184	291
250	189
278	117
217	161
210	282
149	261
133	197
237	177
256	270
159	107
184	111
219	281
235	274
291	119
248	221
161	244
228	157
291	128
115	102
143	292
179	245
142	220
185	188
114	240
294	172
284	135
212	104
138	258
154	126
243	275
237	167
205	290
267	145
141	167
172	274
287	149
216	218
193	172
190	240
142	272
159	130
283	141
177	126
166	231
203	115
114	125
196	270
153	226
259	275
258	156
255	247
287	243
116	275
195	243
277	294
293	157
279	103
298	288
187	112
237	129
125	106
124	219
217	101
133	109
236	291
210	287
246	207
207	110
205	137
270	128
113	202
110	263
212	169
166	195
172	254
166	168
178	298
236	213
177	251
290	203
200	279
163	282
234	113
241	289
196	295
221	132
157	281
296	139
186	208
178	270
202	144
158	237
262	250
276	153
279	154
138	143
297	141
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (userid, username, email, firstname, lastname, roleid, password) FROM stdin;
101	AWau88	Kassie.Croser135@example.org	Gwen	Deegin	1	MBre266
102	BEli135	Charlot.Templar129@example.org	Daryle	Rumens	2	CMay77
103	ASwi341	Randie.Petty298@example.org	Layney	Franciottoi	2	MLav473
104	CMec258	Sephira.Croser422@example.org	Luther	Elliff	1	EGre321
105	SFyn247	Merwin.Reames366@example.org	Josselyn	Roughan	2	ERum271
106	RFri455	Alica.Lavrinov342@example.org	Taryn	Jellett	1	EGen474
107	AVas374	Pietrek.Storr354@example.org	Teodoro	Deegin	2	TGog427
108	RRen275	Evangelin.Bamsey458@example.org	Jolyn	Haken	2	LBre249
109	DEli45	Tabina.Capstaff291@example.org	Bentley	Templar	1	PJul148
110	KTay351	Brigid.Andriesse305@example.org	Daryle	Tomovic	2	SWhi369
111	TCar250	Melicent.Woolgar46@example.org	Joey	Glitherow	1	BVas42
112	BEwi164	Mariele.Bamsey161@example.org	Tallou	Gipp	1	SDeB433
113	EJul41	Angelo.Swinnerton465@example.org	Jolyn	DeBrett	2	MBam357
114	GGoo289	Ozzie.Jinkins148@example.org	Shena	Itzhayek	1	CLow96
115	KAmo437	Alfred.Jellett373@example.org	Luther	Simmins	2	JBam341
116	SSma296	Teodoro.Vassar126@example.org	Seana	Creenan	1	EMec55
117	EMil99	Urban.Stelljes371@example.org	Merwin	Cribbins	2	GFri474
118	GSum443	Shena.Porcas191@example.org	Ximenez	Eliasen	2	BCri473
119	GCro133	Leah.Ewington25@example.org	Cheryl	Bockett	2	MRea168
120	LUtt8	Daryle.Jullian297@example.org	Catriona	Meconi	1	MLav68
121	GLav351	Kellie.Capstaff177@example.org	Jolyn	Dyball	1	KLow254
122	SMcT165	Griffy.Stelljes275@example.org	Merwin	Laxon	2	BLig494
123	LTay425	Mariele.Gogan241@example.org	Alyce	Jullian	1	TRen467
124	AMil320	Ruthie.Croser454@example.org	Alfred	Vogele	1	DAnd0
125	WLav261	Binky.Porcas18@example.org	Brander	Gencke	2	DGri418
126	DBra28	Gus.Lowdes260@example.org	Leah	Gremain	1	AVog271
127	MSum334	Seana.Rakestraw102@example.org	Seana	Taylorson	1	ERen165
128	FGli442	Taryn.Rathe341@example.org	Maryanna	Capstaff	2	BFri385
129	MTem494	Delphinia.Grinley75@example.org	Guglielmo	Croser	2	EWoo192
130	DGre241	Rochelle.Facer426@example.org	Layney	Facer	2	RAnd98
131	BFri88	Taryn.Gremain441@example.org	Billy	Proffitt	1	JBoc300
132	KCro88	Layney.Fansy281@example.org	Maryanna	Swinnerton	2	ULow139
133	ARou84	Margarita.Bockett8@example.org	Gus	Creenan	2	GRum5
134	AAnd190	Pietrek.Lowdes312@example.org	Liuka	Eliasen	2	SCri412
135	BCar371	Allis.Coldham115@example.org	Maryanna	Elliff	2	AFra106
136	SEsp128	Luther.Gouinlock89@example.org	Ximenez	Woolgar	1	KFac94
137	CFri71	Alfred.Tatlowe377@example.org	Josselyn	Petkovic	1	EFan66
138	BSma378	Seana.Petty145@example.org	Taryn	Pinson	2	JEll377
139	DGli101	Tabina.Whittet277@example.org	Griffy	Lavrinov	2	SFac427
140	PBoc186	Billy.Carrodus330@example.org	Ruthie	Roughan	2	KEli364
141	LTay122	Kellie.Franciottoi53@example.org	Shena	Andriesse	1	JGou86
142	PGip20	Seana.Deegin18@example.org	Evangelin	Swinnerton	1	EAsp320
143	SCre283	Pierce.Fackrell393@example.org	Jolyn	Buney	1	AWhi268
144	KCar206	Carolyn.Capstaff250@example.org	Melicent	Laxon	1	BSto251
145	BAmo470	Catriona.Lavrinov117@example.org	Kellie	Rennebeck	2	BGri133
146	RBro491	Gabbey.Crudgington331@example.org	Pierce	Laxon	1	JGog90
147	BSwi144	Merwin.Swinnerton234@example.org	Ced	Haken	1	FSto68
148	LAmo432	Jolyn.Rennebeck288@example.org	Pierce	Ellerman	1	GBoc462
149	EGri125	Brigid.Vassar319@example.org	Guglielmo	Braga	2	BFan309
150	ERen308	Dory.Pinson146@example.org	Tammie	Summerlie	2	ELav384
151	ERat173	Jolyn.Rakestraw435@example.org	Tammie	Espadater	2	XPro136
152	DDeB35	Merwin.Dyball48@example.org	Melicent	Grinley	1	MTat25
153	ALig320	Tori.Stelljes56@example.org	Alli	Braga	1	CWau299
154	TDeB8	Ced.Baulcombe479@example.org	Roz	Petty	1	MSim101
155	IUtt350	Sephira.Waud69@example.org	Holli	Simoneton	1	DYar115
156	EBau290	Pierce.Brecken362@example.org	Joey	Roughan	2	TGog237
157	DRea99	Cora.Gogan30@example.org	Tammie	Grim	1	TBre9
158	BMil255	Richy.Bizzey327@example.org	Wolfgang	Cribbins	1	TBec42
159	SBec235	Alica.Haken472@example.org	Luther	Petty	2	BFra196
160	GEwi240	Gwen.Fritz491@example.org	Ced	McGawn	2	GRak423
161	ALax438	Taryn.Glitherow376@example.org	Pietrek	Grim	1	ABre89
162	DLax244	Kassie.Dyball322@example.org	Gabbey	Grinley	1	SDeB22
163	KRea201	Idalina.Baulcombe112@example.org	Gabbey	Simoneton	1	BMil80
164	TEli59	Raviv.Reames465@example.org	Griffy	Templar	2	EMec114
165	DCol0	Alli.Payler289@example.org	Brynna	Gipp	1	TBro432
166	JFri377	Luis.Payler302@example.org	Pierce	Rumens	1	GLav188
167	EGli429	Allis.Pech25@example.org	Edithe	Goodlad	2	BPin421
168	BFan183	Alwyn.Millen360@example.org	Kellie	Uttley	1	RMcT68
169	DEll69	Billy.McTerry452@example.org	Pietrek	Millen	1	APet246
170	CBra192	Pietrek.Goodlad171@example.org	Josselyn	Osmund	1	AVas159
171	SRen366	Terry.Strathman412@example.org	Stafford	Rumens	1	PGri4
172	CCol250	Jolyn.Waud196@example.org	Catriona	Fackrell	2	BRat410
173	JSto98	Karry.Meconi391@example.org	Raviv	Braga	2	COsm177
174	BWoo269	Basile.Templar154@example.org	Alfred	Jellett	2	XGog40
175	RFan7	Billy.Carrodus281@example.org	Pietrek	Jellett	2	TSim420
176	ABec240	Benyamin.Swinnerton413@example.org	Tabina	Waud	2	RGri104
177	RPec365	Randie.McTerry373@example.org	Tammie	Proffitt	1	KFyn236
178	EMcG130	Brita.DeBrett335@example.org	Lucretia	Bamsey	1	IRou218
179	SPro368	Axel.Fenton395@example.org	Alli	Lavrinov	2	ABun390
180	MRen445	Margarita.Reames282@example.org	Gus	Garaghan	2	CDou257
181	MSum340	Daryle.Cribbins258@example.org	Joey	Summerlie	2	ISwi222
182	GNot488	Kellie.Vogele413@example.org	Brynna	Strathman	2	BBro259
183	SGar41	Sergei.Meconi195@example.org	Liuka	Carrodus	1	BNea275
184	SSma345	Emmott.Ellerman271@example.org	Gabbey	Grim	1	BNot363
185	EStr210	Alica.Glitherow365@example.org	Jolyn	Amoore	2	LBoc286
186	EGip144	Jolyn.Vassar492@example.org	Manda	Roughan	2	ARea445
187	MRou389	Pietrek.Lowy155@example.org	Margarita	Evequot	1	MAnd366
188	LRen95	Ludwig.Vassar7@example.org	Tammie	Creenan	2	LSma420
189	CCar371	Guglielmo.McTerry293@example.org	Evangelin	Muffitt	2	SGip20
190	AMil500	Franz.Haken420@example.org	Perri	Bizzey	1	PGli64
191	CRen23	Axel.Summerlie346@example.org	Angelo	Tomovic	1	HEwi188
192	JCre41	Teodoro.Vassar68@example.org	Gus	Lowy	2	TJul45
193	EDyb235	Joey.Eliasen60@example.org	Alli	Capstaff	1	BDyb190
194	EMil252	Seana.Meconi464@example.org	Kellie	Brecken	2	LRea167
195	RUtt354	Alfy.Glitherow350@example.org	Billy	Simoneton	2	MRen273
196	SEve444	Daryle.Tatlowe176@example.org	Richy	Cribbins	1	GFen199
197	BSma100	Manda.Elliff336@example.org	Conni	Baulcombe	1	XJin462
198	BMcG106	Brigid.Fackrell470@example.org	Mariele	Waud	2	SJul176
199	JGri354	Binky.Jinkins148@example.org	Allis	McGawn	1	KWoo334
200	COsm71	Sephira.Franciottoi143@example.org	Urban	Gremain	2	SEli349
201	JFac125	Ozzie.Stelljes206@example.org	Edithe	Aspden	2	APay240
202	EBro102	Raviv.Eliasen93@example.org	Joey	Ewington	2	TFen357
203	BGri155	Luis.Storr201@example.org	Delphinia	Woolgar	1	TNea101
204	WSwi221	Gabbey.McGawn314@example.org	Alyce	Facer	2	PBre158
205	TBra358	Alli.Gremain45@example.org	Elliott	Coldham	2	TLow60
206	SAmo112	Elias.DeBrett81@example.org	Axel	Friday	2	LRou306
207	CItz39	Kassie.DeBrett52@example.org	Suzann	Waud	1	MMil138
208	EPor445	Elke.Capstaff125@example.org	Shena	Jullian	2	LGre408
209	LPet450	Shena.Facer15@example.org	Alwyn	Haken	2	MDou111
210	GEwi253	Emmott.Baulcombe271@example.org	Terry	Rennocks	2	TBam29
211	CGen373	Jemimah.Storr497@example.org	Terry	McTerry	1	TSte261
212	GTat206	Leah.Taylorson212@example.org	Tori	Waud	2	LBro105
213	ALow258	Mickie.Jinkins203@example.org	Karry	Ewington	2	MGen305
214	BDyb269	Ruthie.Baulcombe303@example.org	Brynna	Petkovic	1	MRen179
215	MFyn145	Teodoro.Payler33@example.org	Teodoro	McTerry	1	MGip224
216	AGen208	Dean.Lowy335@example.org	Pierce	Simoneton	1	BBau151
217	ABro490	Brander.Lowy184@example.org	Elliott	DeBrett	2	PLig75
218	TCar289	Margarita.Vogele152@example.org	Karry	Jinkins	2	AGoo482
219	TJul465	Emmott.Proffitt6@example.org	Franz	Woolgar	1	JRea363
220	JPor18	Brander.Lowy163@example.org	Jemimah	Facer	1	APay35
221	CEll187	Seana.Storr333@example.org	Roz	Ewington	2	MNot315
222	RGen259	Sephira.Proffitt251@example.org	Ced	Pinson	1	DLow462
223	ANea284	Tori.McGawn47@example.org	Suzann	Tomovic	1	WCro29
224	RSim416	Cheryl.Espadater98@example.org	Charlot	Whittet	2	ALow139
225	BFan427	Cheryl.Meconi285@example.org	Alwyn	Aspden	1	BGen459
226	GGip112	Wolfgang.Woolgar183@example.org	Manda	Meconi	2	ECar305
227	TGli223	Elliott.Millen138@example.org	Kellie	Facer	1	PBun179
228	KRen80	Taryn.Gipp389@example.org	Luther	Proffitt	2	BBam42
229	SRen376	Ozzie.Lightfoot454@example.org	Delphinia	Uttley	1	SMil189
230	SEll246	Luis.Tomovic396@example.org	Birgitta	Pech	2	ALow328
231	EVas308	Cheryl.Fackrell18@example.org	Tammie	Becks	1	EPor206
232	DBam487	Dory.Deegin75@example.org	Evangelin	Caron	1	TGou102
233	BCar308	Taryn.Jullian185@example.org	Emmott	Porcas	1	MEve213
234	MSma60	Brita.Gremain471@example.org	Ruthie	Simmins	1	LEsp411
235	AEve1	Gabbey.DeBrett301@example.org	Beatriz	Braga	1	GPin9
236	HRen217	Jaymie.Proffitt142@example.org	Angelo	Braga	1	AMuf464
237	ACre68	Richy.Noto454@example.org	Teodoro	Roughan	2	SJul3
238	BYar66	Joey.Templar395@example.org	Manda	Mayer	1	MSte349
239	BSum41	Gwen.Buney351@example.org	Sella	Millen	2	BPet431
240	DLav390	Evangelin.Lavrinov206@example.org	Ludwig	Whittet	2	AAnd326
241	ETem347	Austina.Becks401@example.org	Beatriz	Haken	1	APay255
242	DPet5	Angelo.Ellerman444@example.org	Alwyn	Pinson	2	FRum13
243	JGri439	Lucretia.Woolgar161@example.org	Raviv	Tatlowe	2	LEsp460
244	JPay298	Leah.Fansy360@example.org	Gwen	Grinley	1	TStr443
245	SBec221	Mariele.Payler385@example.org	Liuka	Proffitt	2	CTay435
246	FPet85	Sephira.Roughan151@example.org	Jemimah	Fansy	2	APin26
247	MCap391	Layney.Crudgington307@example.org	Seana	Proffitt	1	SHak470
248	HSte426	Tammie.Ewington238@example.org	Jenilee	Glitherow	2	EPay404
249	BFen485	Sephira.Goodlad178@example.org	Alfred	Rennebeck	2	GJel326
250	ERen202	Tammie.Coldham418@example.org	Binky	Bizzey	2	JGou430
251	XDeB138	Roz.Amoore469@example.org	Tammie	Roughan	2	ELax49
252	CEll149	Carolyn.Pech268@example.org	Dean	Lowdes	1	BTat258
253	MCro75	Elliott.Storr208@example.org	Lucretia	Rennebeck	2	BBun311
254	RFri56	Rochelle.Taylorson338@example.org	Carolyn	Gremain	2	UGip110
255	BEll496	Ludwig.Friday95@example.org	Gretal	Buney	2	RDyb353
256	SBam92	Jemimah.Goodlad322@example.org	Shena	Franciottoi	1	GItz229
257	SFac58	Liuka.Deegin309@example.org	Pietrek	Tatlowe	1	BEll391
258	MYar372	Bentley.Osmund239@example.org	Benyamin	Lowdes	2	AJul22
259	CSto331	Carolyn.Friday473@example.org	Kassie	Tomovic	1	LWhi140
260	GJul355	Mickie.Garaghan45@example.org	Tabina	Ewington	2	BNot434
261	CPay218	Brander.Tatlowe379@example.org	Sella	Yardy	2	EBiz140
262	ISwi3	Sephira.Lowdes446@example.org	Lorri	Gipp	1	MSim485
263	MEli20	Dory.Storr459@example.org	Sergei	Tatlowe	2	CGou347
264	JEli146	Stafford.Waud253@example.org	Mickie	Haken	2	BAnd169
265	LFra99	Maryanna.Grim39@example.org	Ozzie	Friday	2	JFen442
266	CBiz340	Mickie.Noto149@example.org	Ruthie	Coldham	2	SYar228
267	FGen232	Franz.Caron190@example.org	Wolfgang	Gogan	2	WCre185
268	BCar444	Taryn.Swinnerton210@example.org	Emmott	Ewington	1	SLig227
269	RSim453	Elliott.Petty328@example.org	Tallou	Swinnerton	1	ARak126
270	XOsm351	Brigid.Whittet276@example.org	Jemimah	Deegin	1	XWoo56
271	BRea479	Pierce.Templar250@example.org	Daryle	Muffitt	2	BMec137
272	ADou245	Gretal.Fackrell336@example.org	Margarita	Crudgington	2	APor407
273	PTat72	Tammie.Haken313@example.org	Teodoro	Yardy	2	CBun32
274	EPet127	Alfred.Meconi216@example.org	Pietrek	DeBrett	1	SCap271
275	BVas1	Sella.Simmins249@example.org	Emmott	Fyndon	1	JCri460
276	MRen489	Perri.Grinley47@example.org	Alwyn	Garaghan	2	FGri226
277	RLax496	Dory.Evequot438@example.org	Catriona	Grinley	1	KNea180
278	UCri28	Beatriz.Tomovic352@example.org	Jaymie	Lowdes	1	HTom337
279	TJel341	Daryle.Bockett4@example.org	Cheryl	Pinson	2	BBra353
280	RCri33	Taryn.Bockett455@example.org	Josselyn	Tomovic	2	SRea157
281	TJin296	Sephira.Fritz162@example.org	Alli	Bamsey	2	DGar360
282	BAsp392	Raviv.Bamsey166@example.org	Kellie	Stelljes	1	JJin267
283	TEll312	Alwyn.Swinnerton190@example.org	Benyamin	Becks	2	RTem417
284	DRak463	Alica.Grinley433@example.org	Birgitta	Lavrinov	1	GUtt0
285	GRea149	Ced.Whittet496@example.org	Sephira	Rakestraw	2	MBau177
286	BYar26	Elias.Osmund108@example.org	Franz	Haken	2	BLig77
287	AFen52	Jaymie.DeBrett414@example.org	Benyamin	Evequot	2	AEve453
288	TSim88	Roz.Capstaff295@example.org	Holli	Fansy	1	EVog252
289	DSum66	Dean.Tatlowe34@example.org	Jemimah	Amoore	2	ESim423
290	LGri366	Maryanna.Aspden479@example.org	Shena	Crudgington	2	MCap336
291	LUtt233	Esta.Goodlad110@example.org	Allis	Braga	1	SMay492
292	KWoo348	Liuka.Evequot82@example.org	Taryn	Petty	1	CGip258
293	SFac160	Seana.Gouinlock8@example.org	Brynna	Smail	1	EFan383
294	TSto379	Taryn.Haken13@example.org	Bebe	Simmins	2	GGip331
295	AMec275	Alfred.Glitherow381@example.org	Brita	Yardy	1	EGog14
296	LItz124	Dory.Gogan21@example.org	Melicent	Jellett	2	XFyn136
297	EPin350	Elliott.Lightfoot307@example.org	Leah	Simmins	2	SGri257
298	CRak337	Teodoro.Croser421@example.org	Conni	Rathe	2	GAmo81
299	CMcT154	Ludwig.Gipp264@example.org	Pietrek	Strathman	2	TMay269
300	JRat76	Dean.Ellerman29@example.org	Alica	Coldham	1	KUtt37
16	test	test2@example.org	test	test	1	$2b$10$aOrHaX85paT5tPEM2B21i.3mR3Q7Eeplmd0NizyQLS1kwkx9SIPy6
\.


--
-- Name: artists_artistid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.artists_artistid_seq', 13, true);


--
-- Name: comments_commentid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.comments_commentid_seq', 2, true);


--
-- Name: genres_genreid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.genres_genreid_seq', 15, true);


--
-- Name: music_musicid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.music_musicid_seq', 32, true);


--
-- Name: playlistmusic_ordered_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.playlistmusic_ordered_seq', 1441, true);


--
-- Name: playlists_playlistid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.playlists_playlistid_seq', 3114, true);


--
-- Name: roles_roleid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_roleid_seq', 3, true);


--
-- Name: users_userid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_userid_seq', 16, true);


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
    ADD CONSTRAINT playlistmusic_pkey PRIMARY KEY (playlistid, musicid, ordered);


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
-- Name: IDX_133ebc3d86f9ce4ee3d5f71584; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_133ebc3d86f9ce4ee3d5f71584" ON public.musicartists USING btree (artistid);


--
-- Name: IDX_195bdfd6c0810dd464dabed15e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_195bdfd6c0810dd464dabed15e" ON public.musicgenres USING btree (musicid);


--
-- Name: IDX_a8f5688ebf2bbff997a71eb3b0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_a8f5688ebf2bbff997a71eb3b0" ON public.musicgenres USING btree (genreid);


--
-- Name: IDX_e43ecb84c66d4654553d95d7b3; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_e43ecb84c66d4654553d95d7b3" ON public.musicartists USING btree (musicid);


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
-- Name: musicartists FK_133ebc3d86f9ce4ee3d5f71584c; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musicartists
    ADD CONSTRAINT "FK_133ebc3d86f9ce4ee3d5f71584c" FOREIGN KEY (artistid) REFERENCES public.artists(artistid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comments FK_14bb151a94132d2f8240a2dbc1a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT "FK_14bb151a94132d2f8240a2dbc1a" FOREIGN KEY (musicid) REFERENCES public.music(musicid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: musicgenres FK_195bdfd6c0810dd464dabed15e1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musicgenres
    ADD CONSTRAINT "FK_195bdfd6c0810dd464dabed15e1" FOREIGN KEY (musicid) REFERENCES public.music(musicid) ON DELETE CASCADE;


--
-- Name: music FK_32eb5747a23050f19e5d992e4a2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.music
    ADD CONSTRAINT "FK_32eb5747a23050f19e5d992e4a2" FOREIGN KEY (userid) REFERENCES public.users(userid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: subscriptions FK_517dc5f2b00bfd0406140400893; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT "FK_517dc5f2b00bfd0406140400893" FOREIGN KEY (userid) REFERENCES public.users(userid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: playlists FK_5269d3f1627f431403f3262e8cf; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlists
    ADD CONSTRAINT "FK_5269d3f1627f431403f3262e8cf" FOREIGN KEY (userid) REFERENCES public.users(userid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comments FK_5a1e308e3a31f92fe848dab35ca; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT "FK_5a1e308e3a31f92fe848dab35ca" FOREIGN KEY (userid) REFERENCES public.users(userid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: musicgenres FK_a8f5688ebf2bbff997a71eb3b06; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musicgenres
    ADD CONSTRAINT "FK_a8f5688ebf2bbff997a71eb3b06" FOREIGN KEY (genreid) REFERENCES public.genres(genreid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: playlistmusic FK_bd47bdca96bb28470d1846fdb66; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlistmusic
    ADD CONSTRAINT "FK_bd47bdca96bb28470d1846fdb66" FOREIGN KEY (musicid) REFERENCES public.music(musicid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: subscriptions FK_cf04e5a28d7c304b2560cce3fe5; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT "FK_cf04e5a28d7c304b2560cce3fe5" FOREIGN KEY (subscribetoid) REFERENCES public.users(userid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: musicartists FK_e43ecb84c66d4654553d95d7b3f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musicartists
    ADD CONSTRAINT "FK_e43ecb84c66d4654553d95d7b3f" FOREIGN KEY (musicid) REFERENCES public.music(musicid) ON DELETE CASCADE;


--
-- Name: playlistmusic FK_e646640e0eb47712e64251a1a32; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlistmusic
    ADD CONSTRAINT "FK_e646640e0eb47712e64251a1a32" FOREIGN KEY (playlistid) REFERENCES public.playlists(playlistid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users FK_fda64da5f551e18c5e7d7bbde7c; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "FK_fda64da5f551e18c5e7d7bbde7c" FOREIGN KEY (roleid) REFERENCES public.roles(roleid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

