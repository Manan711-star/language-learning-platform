-- Language Learning Platform - Seed Data
-- Run AFTER schema.sql in pgAdmin 4

-- Courses
INSERT INTO courses (title, language, description, level, image_url, total_lessons, duration_hours) VALUES
('Spanish for Beginners', 'Spanish', 'Learn essential Spanish vocabulary, grammar, and conversation skills from scratch. Perfect for travelers and beginners.', 'Beginner', 'assets/images/course-spanish.svg', 5, 8.5),
('French Essentials', 'French', 'Master French basics including greetings, numbers, and everyday phrases. Build a strong foundation for fluency.', 'Beginner', 'assets/images/course-french.svg', 4, 6.0),
('German Fundamentals', 'German', 'Discover German language structure, pronunciation, and common expressions used in daily life.', 'Beginner', 'assets/images/course-german.svg', 4, 7.0),
('Japanese Starter', 'Japanese', 'Start your Japanese journey with Hiragana, basic kanji, and essential polite expressions.', 'Beginner', 'assets/images/course-japanese.svg', 5, 10.0),
('Italian Basics', 'Italian', 'Learn Italian through practical lessons covering food, travel, and cultural expressions.', 'Beginner', 'assets/images/course-italian.svg', 4, 5.5),
('Mandarin Chinese Intro', 'Chinese', 'Introduction to Mandarin Chinese with Pinyin, tones, and fundamental characters.', 'Beginner', 'assets/images/course-chinese.svg', 4, 9.0);

-- Spanish Lessons
INSERT INTO lessons (course_id, title, content, lesson_order, xp_reward, vocabulary) VALUES
(1, 'Greetings & Introductions', 'Learn how to say hello, goodbye, and introduce yourself in Spanish.

**Key Phrases:**
- Hola = Hello
- Buenos días = Good morning
- Buenas tardes = Good afternoon
- Adiós = Goodbye
- Me llamo... = My name is...
- Mucho gusto = Nice to meet you

**Practice:** Try introducing yourself using these phrases!', 1, 10, '[{"word":"Hola","translation":"Hello"},{"word":"Adiós","translation":"Goodbye"},{"word":"Gracias","translation":"Thank you"}]'),
(1, 'Numbers 1-20', 'Master counting from one to twenty in Spanish.

**Numbers:**
1 = Uno, 2 = Dos, 3 = Tres, 4 = Cuatro, 5 = Cinco
6 = Seis, 7 = Siete, 8 = Ocho, 9 = Nueve, 10 = Diez
11 = Once, 12 = Doce, 13 = Trece, 14 = Catorce, 15 = Quince
16 = Dieciséis, 17 = Diecisiete, 18 = Dieciocho, 19 = Diecinueve, 20 = Veinte

Numbers are essential for shopping, telling time, and daily conversations.', 2, 10, '[{"word":"Uno","translation":"One"},{"word":"Diez","translation":"Ten"},{"word":"Veinte","translation":"Twenty"}]'),
(1, 'Common Verbs', 'Learn the most used Spanish verbs and their conjugations.

**Essential Verbs:**
- Ser (to be): soy, eres, es
- Estar (to be): estoy, estás, está
- Tener (to have): tengo, tienes, tiene
- Ir (to go): voy, vas, va
- Querer (to want): quiero, quieres, quiere

These five verbs appear in almost every Spanish conversation!', 3, 15, '[{"word":"Ser","translation":"To be (permanent)"},{"word":"Estar","translation":"To be (temporary)"},{"word":"Tener","translation":"To have"}]'),
(1, 'Food & Dining', 'Order food and drinks confidently in Spanish restaurants.

**Vocabulary:**
- El agua = Water
- La comida = Food
- El restaurante = Restaurant
- La cuenta = The bill
- Quisiera... = I would like...
- Delicioso = Delicious

**Useful phrase:** "La cuenta, por favor" (The bill, please)', 4, 15, '[{"word":"Agua","translation":"Water"},{"word":"Comida","translation":"Food"},{"word":"Delicioso","translation":"Delicious"}]'),
(1, 'Travel Phrases', 'Essential phrases for traveling in Spanish-speaking countries.

**At the Airport:**
- ¿Dónde está...? = Where is...?
- Un boleto = A ticket
- La salida = The exit

**Asking for Help:**
- ¿Habla inglés? = Do you speak English?
- Necesito ayuda = I need help
- ¿Cuánto cuesta? = How much does it cost?', 5, 20, '[{"word":"Boleto","translation":"Ticket"},{"word":"Ayuda","translation":"Help"},{"word":"Cuesta","translation":"Costs"}]');

-- French Lessons
INSERT INTO lessons (course_id, title, content, lesson_order, xp_reward, vocabulary) VALUES
(2, 'Bonjour! Basic Greetings', 'Start with French greetings and polite expressions.

**Greetings:**
- Bonjour = Hello/Good day
- Bonsoir = Good evening
- Au revoir = Goodbye
- Salut = Hi (informal)
- Comment allez-vous? = How are you? (formal)
- Ça va? = How are you? (informal)', 1, 10, '[{"word":"Bonjour","translation":"Hello"},{"word":"Au revoir","translation":"Goodbye"}]'),
(2, 'French Numbers', 'Learn to count in French from 1 to 20.

1 = Un, 2 = Deux, 3 = Trois, 4 = Quatre, 5 = Cinq
6 = Six, 7 = Sept, 8 = Huit, 9 = Neuf, 10 = Dix
11 = Onze, 12 = Douze, 13 = Treize, 14 = Quatorze, 15 = Quinze
16 = Seize, 17 = Dix-sept, 18 = Dix-huit, 19 = Dix-neuf, 20 = Vingt', 2, 10, '[{"word":"Un","translation":"One"},{"word":"Dix","translation":"Ten"}]'),
(2, 'At the Café', 'Order like a local at a French café.

- Un café, s''il vous plaît = A coffee, please
- L''addition = The bill
- Un croissant = A croissant
- Je voudrais = I would like', 3, 15, '[{"word":"Café","translation":"Coffee"},{"word":"Croissant","translation":"Croissant"}]'),
(2, 'French Culture Tips', 'Understanding French culture enhances your language learning.

- Always greet shopkeepers with "Bonjour"
- Use "vous" for formal situations
- The French appreciate effort in speaking their language
- Meals are social occasions - never rush!', 4, 15, '[{"word":"Merci","translation":"Thank you"},{"word":"S''il vous plaît","translation":"Please"}]');

-- German Lessons
INSERT INTO lessons (course_id, title, content, lesson_order, xp_reward, vocabulary) VALUES
(3, 'German Greetings', 'Learn formal and informal German greetings.

- Guten Tag = Good day
- Guten Morgen = Good morning
- Guten Abend = Good evening
- Tschüss = Bye (informal)
- Auf Wiedersehen = Goodbye (formal)
- Wie geht es Ihnen? = How are you? (formal)', 1, 10, '[{"word":"Guten Tag","translation":"Good day"},{"word":"Tschüss","translation":"Bye"}]'),
(3, 'German Articles', 'Master der, die, das - the German articles.

- der (masculine): der Mann, der Tisch
- die (feminine): die Frau, die Tür
- das (neuter): das Kind, das Buch

Every German noun has a gender - learn them together!', 2, 15, '[{"word":"Der","translation":"The (masc.)"},{"word":"Die","translation":"The (fem.)"},{"word":"Das","translation":"The (neut.)"}]'),
(3, 'Useful German Phrases', 'Essential phrases for daily life in Germany.

- Entschuldigung = Excuse me
- Sprechen Sie Englisch? = Do you speak English?
- Ich verstehe nicht = I don''t understand
- Wo ist...? = Where is...?', 3, 15, '[{"word":"Entschuldigung","translation":"Excuse me"},{"word":"Verstehe","translation":"Understand"}]'),
(3, 'German Food Vocabulary', 'Navigate German restaurants and markets.

- Das Brot = Bread
- Das Wasser = Water
- Das Bier = Beer
- Die Wurst = Sausage
- Lecker! = Delicious!', 4, 15, '[{"word":"Brot","translation":"Bread"},{"word":"Wasser","translation":"Water"}]');

-- Japanese Lessons
INSERT INTO lessons (course_id, title, content, lesson_order, xp_reward, vocabulary) VALUES
(4, 'Hiragana Basics', 'Learn the first Japanese writing system - Hiragana.

あ (a) い (i) う (u) え (e) お (o)
か (ka) き (ki) く (ku) け (ke) こ (ko)
さ (sa) し (shi) す (su) せ (se) そ (so)

Hiragana is used for native Japanese words and grammar particles.', 1, 15, '[{"word":"あ","translation":"a"},{"word":"い","translation":"i"},{"word":"う","translation":"u"}]'),
(4, 'Japanese Greetings', 'Polite greetings are essential in Japanese culture.

- こんにちは (Konnichiwa) = Hello
- おはよう (Ohayou) = Good morning
- こんばんは (Konbanwa) = Good evening
- さようなら (Sayounara) = Goodbye
- ありがとう (Arigatou) = Thank you', 2, 10, '[{"word":"Konnichiwa","translation":"Hello"},{"word":"Arigatou","translation":"Thank you"}]'),
(4, 'Basic Kanji', 'Introduction to fundamental kanji characters.

- 一 (ichi) = One
- 二 (ni) = Two
- 三 (san) = Three
- 人 (hito) = Person
- 日 (hi) = Day/Sun
- 水 (mizu) = Water', 3, 20, '[{"word":"一","translation":"One"},{"word":"人","translation":"Person"}]'),
(4, 'Polite Expressions', 'Master keigo basics for respectful communication.

- すみません (Sumimasen) = Excuse me/Sorry
- お願いします (Onegaishimasu) = Please
- はい (Hai) = Yes
- いいえ (Iie) = No
- わかりました (Wakarimashita) = I understand', 4, 15, '[{"word":"Sumimasen","translation":"Excuse me"},{"word":"Hai","translation":"Yes"}]'),
(4, 'Numbers in Japanese', 'Count in Japanese using native and Sino-Japanese numbers.

一 (1), 二 (2), 三 (3), 四 (4), 五 (5)
六 (6), 七 (7), 八 (8), 九 (9), 十 (10)', 5, 15, '[{"word":"一","translation":"1"},{"word":"十","translation":"10"}]');

-- Italian Lessons
INSERT INTO lessons (course_id, title, content, lesson_order, xp_reward, vocabulary) VALUES
(5, 'Ciao! Italian Greetings', 'Warm Italian greetings for every occasion.

- Ciao = Hi/Bye (informal)
- Buongiorno = Good morning
- Buonasera = Good evening
- Arrivederci = Goodbye
- Come sta? = How are you?', 1, 10, '[{"word":"Ciao","translation":"Hi/Bye"},{"word":"Buongiorno","translation":"Good morning"}]'),
(5, 'Italian Food Words', 'Essential vocabulary for Italian cuisine lovers.

- La pasta = Pasta
- La pizza = Pizza
- Il vino = Wine
- Il gelato = Ice cream
- Buon appetito! = Enjoy your meal!', 2, 15, '[{"word":"Pasta","translation":"Pasta"},{"word":"Gelato","translation":"Ice cream"}]'),
(5, 'Italian Travel', 'Navigate Italy with confidence.

- Dov''è...? = Where is...?
- Quanto costa? = How much?
- Un biglietto = A ticket
- Aiuto! = Help!', 3, 15, '[{"word":"Dov''è","translation":"Where is"},{"word":"Quanto costa","translation":"How much"}]'),
(5, 'Expressing Feelings', 'Share emotions in Italian.

- Sono felice = I am happy
- Sono stanco/a = I am tired
- Mi piace = I like
- Non capisco = I don''t understand', 4, 15, '[{"word":"Felice","translation":"Happy"},{"word":"Mi piace","translation":"I like"}]');

-- Chinese Lessons
INSERT INTO lessons (course_id, title, content, lesson_order, xp_reward, vocabulary) VALUES
(6, 'Pinyin & Tones', 'Master Mandarin pronunciation with Pinyin and four tones.

**Tones:**
1st: mā (flat) - 2nd: má (rising)
3rd: mǎ (dip) - 4th: mà (falling)

**Basic Pinyin:**
nǐ hǎo = Hello
xiè xie = Thank you
zài jiàn = Goodbye', 1, 15, '[{"word":"Nǐ hǎo","translation":"Hello"},{"word":"Xiè xie","translation":"Thank you"}]'),
(6, 'Basic Characters', 'Learn your first Chinese characters.

- 一 (yī) = One
- 二 (èr) = Two
- 三 (sān) = Three
- 人 (rén) = Person
- 大 (dà) = Big
- 小 (xiǎo) = Small', 2, 15, '[{"word":"人","translation":"Person"},{"word":"大","translation":"Big"}]'),
(6, 'Daily Conversations', 'Practical phrases for everyday situations.

- 你好吗？(Nǐ hǎo ma?) = How are you?
- 我很好 (Wǒ hěn hǎo) = I am fine
- 对不起 (Duì bu qǐ) = Sorry
- 没关系 (Méi guān xi) = No problem', 3, 15, '[{"word":"Duì bu qǐ","translation":"Sorry"},{"word":"Méi guān xi","translation":"No problem"}]'),
(6, 'Numbers & Counting', 'Count in Mandarin Chinese.

一(1) 二(2) 三(3) 四(4) 五(5)
六(6) 七(7) 八(8) 九(9) 十(10)', 4, 15, '[{"word":"一","translation":"1"},{"word":"十","translation":"10"}]');

-- Quizzes
INSERT INTO quizzes (course_id, title, description, time_limit_seconds, passing_score, xp_reward) VALUES
(1, 'Spanish Basics Quiz', 'Test your knowledge of Spanish greetings, numbers, and verbs.', 300, 70, 25),
(2, 'French Fundamentals Quiz', 'Quiz on French greetings, numbers, and café vocabulary.', 240, 70, 25),
(3, 'German Essentials Quiz', 'Test German articles, greetings, and common phrases.', 240, 70, 25),
(4, 'Japanese Starter Quiz', 'Hiragana, greetings, and basic kanji assessment.', 360, 70, 30),
(5, 'Italian Basics Quiz', 'Italian greetings, food, and travel vocabulary quiz.', 240, 70, 25),
(6, 'Chinese Intro Quiz', 'Pinyin, tones, and basic character recognition.', 300, 70, 30);

-- Spanish Quiz Questions
INSERT INTO quiz_questions (quiz_id, question_text, question_order) VALUES
(1, 'How do you say "Hello" in Spanish?', 1),
(1, 'What is "Gracias" in English?', 2),
(1, 'How do you say "10" in Spanish?', 3),
(1, 'What does "Me llamo" mean?', 4),
(1, 'Which verb means "to have" in Spanish?', 5);

INSERT INTO quiz_options (question_id, option_text, is_correct) VALUES
(1, 'Hola', TRUE), (1, 'Adiós', FALSE), (1, 'Gracias', FALSE), (1, 'Por favor', FALSE),
(2, 'Please', FALSE), (2, 'Thank you', TRUE), (2, 'Sorry', FALSE), (2, 'Goodbye', FALSE),
(3, 'Cinco', FALSE), (3, 'Diez', TRUE), (3, 'Veinte', FALSE), (3, 'Dos', FALSE),
(4, 'I am called/My name is', TRUE), (4, 'I am hungry', FALSE), (4, 'I am tired', FALSE), (4, 'I am happy', FALSE),
(5, 'Ser', FALSE), (5, 'Estar', FALSE), (5, 'Tener', TRUE), (5, 'Ir', FALSE);

-- French Quiz Questions
INSERT INTO quiz_questions (quiz_id, question_text, question_order) VALUES
(2, 'What does "Bonjour" mean?', 1),
(2, 'How do you say "Thank you" in French?', 2),
(2, 'What is "Cinq" in English?', 3),
(2, 'What does "Au revoir" mean?', 4);

INSERT INTO quiz_options (question_id, option_text, is_correct) VALUES
(6, 'Good morning', FALSE), (6, 'Hello/Good day', TRUE), (6, 'Good night', FALSE), (6, 'Goodbye', FALSE),
(7, 'Merci', TRUE), (7, 'Bonjour', FALSE), (7, 'Salut', FALSE), (7, 'Oui', FALSE),
(8, 'Three', FALSE), (8, 'Five', TRUE), (8, 'Ten', FALSE), (8, 'One', FALSE),
(9, 'Hello', FALSE), (9, 'See you later', FALSE), (9, 'Goodbye', TRUE), (9, 'Good night', FALSE);

-- German Quiz Questions
INSERT INTO quiz_questions (quiz_id, question_text, question_order) VALUES
(3, 'What does "Guten Tag" mean?', 1),
(3, 'Which article is used for "die Frau"?', 2),
(3, 'How do you say "Excuse me" in German?', 3),
(3, 'What does "Wasser" mean?', 4);

INSERT INTO quiz_options (question_id, option_text, is_correct) VALUES
(10, 'Good night', FALSE), (10, 'Good day', TRUE), (10, 'Goodbye', FALSE), (10, 'Good morning', FALSE),
(11, 'Der', FALSE), (11, 'Die', TRUE), (11, 'Das', FALSE), (11, 'Den', FALSE),
(12, 'Entschuldigung', TRUE), (12, 'Danke', FALSE), (12, 'Bitte', FALSE), (12, 'Tschüss', FALSE),
(13, 'Bread', FALSE), (13, 'Beer', FALSE), (13, 'Water', TRUE), (13, 'Food', FALSE);

-- Japanese Quiz Questions
INSERT INTO quiz_questions (quiz_id, question_text, question_order) VALUES
(4, 'What does "Konnichiwa" mean?', 1),
(4, 'What does ありがとう (Arigatou) mean?', 2),
(4, 'What character represents "person"?', 3),
(4, 'What does "Sumimasen" mean?', 4),
(4, 'What does はい (Hai) mean?', 5);

INSERT INTO quiz_options (question_id, option_text, is_correct) VALUES
(14, 'Goodbye', FALSE), (14, 'Hello', TRUE), (14, 'Thank you', FALSE), (14, 'Sorry', FALSE),
(15, 'Hello', FALSE), (15, 'Goodbye', FALSE), (15, 'Thank you', TRUE), (15, 'Please', FALSE),
(16, '一', FALSE), (16, '人', TRUE), (16, '水', FALSE), (16, '日', FALSE),
(17, 'Thank you', FALSE), (17, 'Excuse me/Sorry', TRUE), (17, 'Yes', FALSE), (17, 'No', FALSE),
(18, 'No', FALSE), (18, 'Yes', TRUE), (18, 'Maybe', FALSE), (18, 'Please', FALSE);

-- Italian Quiz Questions
INSERT INTO quiz_questions (quiz_id, question_text, question_order) VALUES
(5, 'What does "Ciao" mean?', 1),
(5, 'How do you say "Ice cream" in Italian?', 2),
(5, 'What does "Buongiorno" mean?', 3),
(5, 'What does "Mi piace" mean?', 4);

INSERT INTO quiz_options (question_id, option_text, is_correct) VALUES
(19, 'Good morning', FALSE), (19, 'Hi/Bye', TRUE), (19, 'Thank you', FALSE), (19, 'Please', FALSE),
(20, 'La pizza', FALSE), (20, 'Il gelato', TRUE), (20, 'La pasta', FALSE), (20, 'Il vino', FALSE),
(21, 'Good evening', FALSE), (21, 'Good morning', TRUE), (21, 'Good night', FALSE), (21, 'Goodbye', FALSE),
(22, 'I don''t understand', FALSE), (22, 'I like', TRUE), (22, 'I am happy', FALSE), (22, 'I am tired', FALSE);

-- Chinese Quiz Questions
INSERT INTO quiz_questions (quiz_id, question_text, question_order) VALUES
(6, 'What does "Nǐ hǎo" mean?', 1),
(6, 'What does 人 (rén) mean?', 2),
(6, 'How do you say "Thank you" in Mandarin?', 3),
(6, 'What does "Duì bu qǐ" mean?', 4),
(6, 'What is the character for "big"?', 5);

INSERT INTO quiz_options (question_id, option_text, is_correct) VALUES
(23, 'Goodbye', FALSE), (23, 'Hello', TRUE), (23, 'Thank you', FALSE), (23, 'Sorry', FALSE),
(24, 'One', FALSE), (24, 'Person', TRUE), (24, 'Water', FALSE), (24, 'Big', FALSE),
(25, 'Zài jiàn', FALSE), (25, 'Xiè xie', TRUE), (25, 'Nǐ hǎo', FALSE), (25, 'Duì bu qǐ', FALSE),
(26, 'Thank you', FALSE), (26, 'Sorry', TRUE), (26, 'Hello', FALSE), (26, 'Goodbye', FALSE),
(27, '小', FALSE), (27, '大', TRUE), (27, '人', FALSE), (27, '三', FALSE);

-- Daily Challenges Pool
-- Each challenge has a day_offset (0-6). The backend selects challenges where
-- day_offset = (unix_epoch_days % 7), giving a fresh set every day of the week.
-- 7 offsets × 6 challenges each = 42 total challenges in rotation.

INSERT INTO challenges (title, description, challenge_type, language, xp_reward, difficulty, content, day_offset) VALUES

-- ── Day 0 ──────────────────────────────────────────────────────────────────
('Word of the Day: Spanish', 'Learn and use today''s Spanish vocabulary word.', 'vocabulary', 'Spanish', 15, 'Easy',
 '{"word":"Biblioteca","translation":"Library","example":"La biblioteca está cerca.","task":"Use this word in a sentence"}', 0),
('Speed Translation: French', 'Translate 5 French phrases as fast as you can.', 'translation', 'French', 20, 'Medium',
 '{"phrases":[{"french":"Je m''appelle Marie","english":"My name is Marie"},{"french":"Où est la gare?","english":"Where is the train station?"},{"french":"J''ai faim","english":"I am hungry"},{"french":"Il fait beau","english":"The weather is nice"},{"french":"À bientôt","english":"See you soon"}]}', 0),
('Kanji Challenge', 'Identify 5 basic kanji characters.', 'recognition', 'Japanese', 25, 'Hard',
 '{"characters":[{"char":"水","meaning":"Water"},{"char":"火","meaning":"Fire"},{"char":"木","meaning":"Tree"},{"char":"金","meaning":"Gold/Money"},{"char":"土","meaning":"Earth/Soil"}]}', 0),
('German Article Master', 'Choose the correct article for 5 German nouns.', 'grammar', 'German', 20, 'Medium',
 '{"nouns":[{"word":"Tisch","article":"der","english":"Table"},{"word":"Blume","article":"die","english":"Flower"},{"word":"Buch","article":"das","english":"Book"},{"word":"Auto","article":"das","english":"Car"},{"word":"Frau","article":"die","english":"Woman"}]}', 0),
('Italian Pronunciation', 'Practice pronouncing 5 Italian words correctly.', 'pronunciation', 'Italian', 15, 'Easy',
 '{"words":[{"word":"Grazie","ipa":"/ˈɡrattsje/","meaning":"Thank you"},{"word":"Prego","ipa":"/ˈpreːɡo/","meaning":"You''re welcome"},{"word":"Scusi","ipa":"/ˈskuːzi/","meaning":"Excuse me"},{"word":"Bene","ipa":"/ˈbeːne/","meaning":"Well/Good"},{"word":"Amore","ipa":"/aˈmoːre/","meaning":"Love"}]}', 0),
('Tone Practice: Chinese', 'Identify the correct tone for each Mandarin syllable.', 'pronunciation', 'Chinese', 20, 'Medium',
 '{"words":[{"word":"mā","tone":1,"meaning":"Mother"},{"word":"má","tone":2,"meaning":"Hemp"},{"word":"mǎ","tone":3,"meaning":"Horse"},{"word":"mà","tone":4,"meaning":"Scold"},{"word":"ma","tone":0,"meaning":"Question particle"}]}', 0),

-- ── Day 1 ──────────────────────────────────────────────────────────────────
('Spanish Verb Blitz', 'Conjugate 5 common Spanish verbs in present tense.', 'translation', 'Spanish', 20, 'Medium',
 '{"phrases":[{"french":"I eat (comer, yo)","english":"como"},{"french":"She speaks (hablar, ella)","english":"habla"},{"french":"We go (ir, nosotros)","english":"vamos"},{"french":"They have (tener, ellos)","english":"tienen"},{"french":"You are (ser, tú)","english":"eres"}]}', 1),
('French Vocabulary: Food', 'Learn 5 French food words used in everyday life.', 'vocabulary', 'French', 15, 'Easy',
 '{"word":"Fromage","translation":"Cheese","example":"J''aime le fromage.","task":"Name three cheeses in French"}', 1),
('Hiragana Sprint', 'Match 5 hiragana characters to their romaji.', 'recognition', 'Japanese', 25, 'Hard',
 '{"characters":[{"char":"あ","meaning":"a"},{"char":"い","meaning":"i"},{"char":"う","meaning":"u"},{"char":"え","meaning":"e"},{"char":"お","meaning":"o"}]}', 1),
('German Greetings', 'Translate 5 German greeting phrases into English.', 'translation', 'German', 20, 'Medium',
 '{"phrases":[{"french":"Guten Morgen","english":"Good morning"},{"french":"Guten Abend","english":"Good evening"},{"french":"Wie geht es Ihnen?","english":"How are you?"},{"french":"Auf Wiedersehen","english":"Goodbye"},{"french":"Bitte","english":"Please"}]}', 1),
('Italian Food Words', 'Identify 5 classic Italian food terms.', 'vocabulary', 'Italian', 15, 'Easy',
 '{"word":"Pane","translation":"Bread","example":"Vorrei del pane, per favore.","task":"Use this word when ordering at a restaurant"}', 1),
('Chinese Numbers', 'Match 5 Chinese characters to their numeric values.', 'recognition', 'Chinese', 20, 'Medium',
 '{"characters":[{"char":"一","meaning":"1"},{"char":"二","meaning":"2"},{"char":"三","meaning":"3"},{"char":"四","meaning":"4"},{"char":"五","meaning":"5"}]}', 1),

-- ── Day 2 ──────────────────────────────────────────────────────────────────
('Spanish Colours', 'Match 5 Spanish colour words to their English equivalents.', 'translation', 'Spanish', 15, 'Easy',
 '{"phrases":[{"french":"Rojo","english":"Red"},{"french":"Azul","english":"Blue"},{"french":"Verde","english":"Green"},{"french":"Amarillo","english":"Yellow"},{"french":"Negro","english":"Black"}]}', 2),
('French Article Challenge', 'Choose le, la, or les for 5 French nouns.', 'grammar', 'French', 20, 'Medium',
 '{"nouns":[{"word":"Livre","article":"le","english":"Book"},{"word":"Maison","article":"la","english":"House"},{"word":"Chat","article":"le","english":"Cat"},{"word":"Fleur","article":"la","english":"Flower"},{"word":"Enfants","article":"les","english":"Children"}]}', 2),
('Katakana Sprint', 'Match 5 katakana characters to their romaji.', 'recognition', 'Japanese', 25, 'Hard',
 '{"characters":[{"char":"ア","meaning":"a"},{"char":"イ","meaning":"i"},{"char":"ウ","meaning":"u"},{"char":"エ","meaning":"e"},{"char":"オ","meaning":"o"}]}', 2),
('German Numbers', 'Translate 5 German number words into digits.', 'translation', 'German', 15, 'Easy',
 '{"phrases":[{"french":"Eins","english":"1"},{"french":"Zwei","english":"2"},{"french":"Drei","english":"3"},{"french":"Vier","english":"4"},{"french":"Fünf","english":"5"}]}', 2),
('Italian Greetings', 'Practise 5 essential Italian greeting phrases.', 'pronunciation', 'Italian', 15, 'Easy',
 '{"words":[{"word":"Ciao","ipa":"/tʃaʊ/","meaning":"Hello/Goodbye"},{"word":"Buongiorno","ipa":"/ˌbwɔnˈdʒorno/","meaning":"Good morning"},{"word":"Arrivederci","ipa":"/arˌriveˈdertʃi/","meaning":"Goodbye"},{"word":"Salve","ipa":"/ˈsalve/","meaning":"Hello (formal)"},{"word":"Buonasera","ipa":"/ˌbwɔnaˈseːra/","meaning":"Good evening"}]}', 2),
('Chinese Greetings', 'Translate 5 common Mandarin greeting phrases.', 'translation', 'Chinese', 20, 'Medium',
 '{"phrases":[{"french":"你好","english":"Hello"},{"french":"谢谢","english":"Thank you"},{"french":"对不起","english":"Sorry"},{"french":"再见","english":"Goodbye"},{"french":"没关系","english":"No problem"}]}', 2),

-- ── Day 3 ──────────────────────────────────────────────────────────────────
('Spanish Travel Phrases', 'Translate 5 handy Spanish travel phrases.', 'translation', 'Spanish', 20, 'Medium',
 '{"phrases":[{"french":"¿Dónde está el baño?","english":"Where is the bathroom?"},{"french":"¿Cuánto cuesta?","english":"How much does it cost?"},{"french":"Una habitación, por favor","english":"A room, please"},{"french":"Llame a la policía","english":"Call the police"},{"french":"Me perdí","english":"I am lost"}]}', 3),
('French Pronunciation', 'Practise 5 tricky French words out loud.', 'pronunciation', 'French', 15, 'Easy',
 '{"words":[{"word":"Grenouille","ipa":"/ɡʁə.nuj/","meaning":"Frog"},{"word":"Feuille","ipa":"/fœj/","meaning":"Leaf"},{"word":"Accueil","ipa":"/a.kœj/","meaning":"Welcome"},{"word":"Écureuil","ipa":"/e.ky.ʁœj/","meaning":"Squirrel"},{"word":"Seuil","ipa":"/sœj/","meaning":"Threshold"}]}', 3),
('Japanese Kanji: Nature', 'Identify 5 nature-related kanji.', 'recognition', 'Japanese', 25, 'Hard',
 '{"characters":[{"char":"山","meaning":"Mountain"},{"char":"川","meaning":"River"},{"char":"海","meaning":"Sea"},{"char":"空","meaning":"Sky"},{"char":"花","meaning":"Flower"}]}', 3),
('German Modal Verbs', 'Choose the correct German modal verb for each sentence.', 'grammar', 'German', 25, 'Hard',
 '{"nouns":[{"word":"können (can)","article":"kann","english":"ich ___ schwimmen"},{"word":"müssen (must)","article":"muss","english":"ich ___ arbeiten"},{"word":"wollen (want)","article":"will","english":"ich ___ schlafen"},{"word":"sollen (should)","article":"soll","english":"ich ___ lernen"},{"word":"dürfen (may)","article":"darf","english":"ich ___ gehen"}]}', 3),
('Italian Numbers', 'Translate 5 Italian number words.', 'translation', 'Italian', 15, 'Easy',
 '{"phrases":[{"french":"Uno","english":"1"},{"french":"Due","english":"2"},{"french":"Tre","english":"3"},{"french":"Quattro","english":"4"},{"french":"Cinque","english":"5"}]}', 3),
('Chinese Body Parts', 'Identify 5 Chinese words for body parts.', 'recognition', 'Chinese', 20, 'Medium',
 '{"characters":[{"char":"头","meaning":"Head"},{"char":"手","meaning":"Hand"},{"char":"眼","meaning":"Eye"},{"char":"耳","meaning":"Ear"},{"char":"口","meaning":"Mouth"}]}', 3),

-- ── Day 4 ──────────────────────────────────────────────────────────────────
('Spanish Word of the Day: Home', 'Learn a useful Spanish word related to the home.', 'vocabulary', 'Spanish', 15, 'Easy',
 '{"word":"Ventana","translation":"Window","example":"Abre la ventana, por favor.","task":"Describe your room using ventana in a sentence"}', 4),
('French Numbers', 'Translate 5 French number words into digits.', 'translation', 'French', 15, 'Easy',
 '{"phrases":[{"french":"Un","english":"1"},{"french":"Deux","english":"2"},{"french":"Trois","english":"3"},{"french":"Quatre","english":"4"},{"french":"Cinq","english":"5"}]}', 4),
('Japanese Greetings', 'Match 5 Japanese greeting phrases to their meanings.', 'translation', 'Japanese', 20, 'Medium',
 '{"phrases":[{"french":"こんにちは","english":"Hello"},{"french":"おはようございます","english":"Good morning"},{"french":"こんばんは","english":"Good evening"},{"french":"ありがとう","english":"Thank you"},{"french":"さようなら","english":"Goodbye"}]}', 4),
('German Vocabulary: Food', 'Learn a common German food word.', 'vocabulary', 'German', 15, 'Easy',
 '{"word":"Brot","translation":"Bread","example":"Ich esse Brot zum Frühstück.","task":"Use Brot in a sentence about breakfast"}', 4),
('Italian Colours', 'Match 5 Italian colour words to English.', 'translation', 'Italian', 15, 'Easy',
 '{"phrases":[{"french":"Rosso","english":"Red"},{"french":"Blu","english":"Blue"},{"french":"Verde","english":"Green"},{"french":"Giallo","english":"Yellow"},{"french":"Bianco","english":"White"}]}', 4),
('Chinese Animals', 'Identify 5 Chinese characters for animals.', 'recognition', 'Chinese', 20, 'Medium',
 '{"characters":[{"char":"猫","meaning":"Cat"},{"char":"狗","meaning":"Dog"},{"char":"鸟","meaning":"Bird"},{"char":"鱼","meaning":"Fish"},{"char":"马","meaning":"Horse"}]}', 4),

-- ── Day 5 ──────────────────────────────────────────────────────────────────
('Spanish Family Vocab', 'Learn key Spanish words for family members.', 'vocabulary', 'Spanish', 15, 'Easy',
 '{"word":"Hermano","translation":"Brother","example":"Mi hermano se llama Carlos.","task":"Introduce one of your family members in Spanish"}', 5),
('French Café Phrases', 'Translate 5 French phrases you''d use in a café.', 'translation', 'French', 20, 'Medium',
 '{"phrases":[{"french":"Un café, s''il vous plaît","english":"A coffee, please"},{"french":"L''addition, s''il vous plaît","english":"The bill, please"},{"french":"Je voudrais un croissant","english":"I would like a croissant"},{"french":"C''est combien?","english":"How much is it?"},{"french":"Merci beaucoup","english":"Thank you very much"}]}', 5),
('Japanese Numbers', 'Match 5 Japanese number words to their values.', 'recognition', 'Japanese', 20, 'Medium',
 '{"characters":[{"char":"一","meaning":"1"},{"char":"二","meaning":"2"},{"char":"三","meaning":"3"},{"char":"四","meaning":"4"},{"char":"五","meaning":"5"}]}', 5),
('German Pronunciation', 'Practise 5 German words with tricky pronunciation.', 'pronunciation', 'German', 20, 'Medium',
 '{"words":[{"word":"Schwarzwald","ipa":"/ˈʃvaʁtsˌvalt/","meaning":"Black Forest"},{"word":"Strauß","ipa":"/ʃtʁaʊs/","meaning":"Bouquet/Ostrich"},{"word":"Schlüssel","ipa":"/ˈʃlʏsl/","meaning":"Key"},{"word":"Zwölf","ipa":"/tsvœlf/","meaning":"Twelve"},{"word":"Pferd","ipa":"/pfeːʁt/","meaning":"Horse"}]}', 5),
('Italian Travel Phrases', 'Translate 5 Italian phrases useful for travel.', 'translation', 'Italian', 20, 'Medium',
 '{"phrases":[{"french":"Dov''è la stazione?","english":"Where is the station?"},{"french":"Quanto costa?","english":"How much does it cost?"},{"french":"Un biglietto, per favore","english":"A ticket, please"},{"french":"Aiuto!","english":"Help!"},{"french":"Non capisco","english":"I don''t understand"}]}', 5),
('Chinese Family Words', 'Identify 5 Chinese characters for family members.', 'recognition', 'Chinese', 20, 'Medium',
 '{"characters":[{"char":"妈","meaning":"Mum"},{"char":"爸","meaning":"Dad"},{"char":"哥","meaning":"Older brother"},{"char":"姐","meaning":"Older sister"},{"char":"弟","meaning":"Younger brother"}]}', 5),

-- ── Day 6 ──────────────────────────────────────────────────────────────────
('Spanish Word of the Day: Weather', 'Learn a Spanish word about the weather.', 'vocabulary', 'Spanish', 15, 'Easy',
 '{"word":"Lluvia","translation":"Rain","example":"Hay mucha lluvia hoy.","task":"Describe today''s weather in Spanish"}', 6),
('French Verb Blitz', 'Conjugate 5 French verbs in present tense (je form).', 'translation', 'French', 20, 'Medium',
 '{"phrases":[{"french":"manger (to eat, je)","english":"mange"},{"french":"parler (to speak, je)","english":"parle"},{"french":"avoir (to have, je)","english":"ai"},{"french":"être (to be, je)","english":"suis"},{"french":"aller (to go, je)","english":"vais"}]}', 6),
('Japanese Food Kanji', 'Identify 5 Japanese kanji related to food.', 'recognition', 'Japanese', 25, 'Hard',
 '{"characters":[{"char":"食","meaning":"Food/Eat"},{"char":"飲","meaning":"Drink"},{"char":"魚","meaning":"Fish"},{"char":"肉","meaning":"Meat"},{"char":"米","meaning":"Rice"}]}', 6),
('German Word of the Day', 'Learn a useful everyday German word.', 'vocabulary', 'German', 15, 'Easy',
 '{"word":"Entschuldigung","translation":"Excuse me / Sorry","example":"Entschuldigung, wo ist der Bahnhof?","task":"Use Entschuldigung in a polite question"}', 6),
('Italian Article Challenge', 'Choose il, la, lo, or le for 5 Italian nouns.', 'grammar', 'Italian', 20, 'Medium',
 '{"nouns":[{"word":"Libro","article":"il","english":"Book"},{"word":"Casa","article":"la","english":"House"},{"word":"Studente","article":"lo","english":"Student"},{"word":"Porta","article":"la","english":"Door"},{"word":"Fiori","article":"i","english":"Flowers"}]}', 6),
('Chinese Word of the Day', 'Learn a practical Mandarin word for daily life.', 'vocabulary', 'Chinese', 15, 'Easy',
 '{"word":"朋友","translation":"Friend","example":"他是我的好朋友。","task":"Use 朋友 in a sentence introducing a friend"}', 6);

-- Achievements
INSERT INTO achievements (name, description, icon_url, xp_required, badge_color) VALUES
('First Steps', 'Complete your first lesson', 'assets/images/badge-first.svg', 10, 'bronze'),
('Quiz Master', 'Pass your first quiz', 'assets/images/badge-quiz.svg', 25, 'silver'),
('Streak Starter', 'Maintain a 3-day learning streak', 'assets/images/badge-streak.svg', 50, 'gold'),
('Polyglot', 'Enroll in 3 different language courses', 'assets/images/badge-polyglot.svg', 100, 'platinum'),
('Challenge Champion', 'Complete 5 daily challenges', 'assets/images/badge-challenge.svg', 75, 'gold'),
('XP Hunter', 'Earn 500 XP points', 'assets/images/badge-xp.svg', 500, 'diamond');
