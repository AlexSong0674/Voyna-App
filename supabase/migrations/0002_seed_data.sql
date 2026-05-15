-- ════════════════════════════════════════════════════════════════════
-- Voyna MVP 시드 데이터 — 서울 30곳 명소 + 30 배지
-- 실행 방법: 0001_initial_schema.sql 적용 후 이 파일 실행
-- ════════════════════════════════════════════════════════════════════

-- ── 30곳 명소 ──
INSERT INTO public.locations (id, name, name_en, description, lat, lng, radius_m, category, region, district) VALUES
(1,  '경복궁',           'Gyeongbokgung Palace',     '조선왕조 정궁·5대궁 중 최대 규모',          37.5796, 126.9770, 150, '역사',     '서울', '종로구'),
(2,  '창덕궁',           'Changdeokgung Palace',     '유네스코 세계문화유산·후원으로 유명',        37.5794, 126.9910, 150, '역사',     '서울', '종로구'),
(3,  '창경궁',           'Changgyeonggung Palace',   '조선시대 동궐·왕대비 거처',                37.5784, 126.9947, 120, '역사',     '서울', '종로구'),
(4,  '덕수궁',           'Deoksugung Palace',        '석조전·정관헌 등 동서양 건축 혼재',         37.5658, 126.9751, 120, '역사',     '서울', '중구'),
(5,  '종묘',             'Jongmyo Shrine',           '조선 역대 왕·왕비 신위 모신 유교 사당',     37.5745, 126.9942, 120, '역사',     '서울', '종로구'),
(7,  '광화문 광장',      'Gwanghwamun Square',       '서울의 상징 광장·세종대왕 동상',            37.5760, 126.9769, 100, '랜드마크', '서울', '종로구'),
(8,  '숭례문',           'Sungnyemun',               '국보 1호·서울 도성 정남문',                37.5601, 126.9753, 80,  '역사',     '서울', '중구'),
(11, '북촌 한옥마을',    'Bukchon Hanok Village',    '서울에서 가장 잘 보존된 한옥 밀집 지구',     37.5827, 126.9831, 200, '한옥',     '서울', '종로구'),
(12, '인사동',           'Insadong',                 '전통 공예·갤러리·찻집 거리',                37.5733, 126.9856, 150, '거리',     '서울', '종로구'),
(13, '삼청동',           'Samcheong-dong',           '갤러리·카페·돌담길로 유명',                37.5825, 126.9810, 150, '거리',     '서울', '종로구'),
(14, '익선동',           'Ikseon-dong',              '개량 한옥 카페·레트로 골목',                37.5732, 126.9882, 120, '거리',     '서울', '종로구'),
(16, 'N서울타워',        'N Seoul Tower',            '서울의 상징 타워·연인의 자물쇠',            37.5512, 126.9882, 100, '랜드마크', '서울', '용산구'),
(17, '롯데월드타워',     'Lotte World Tower',        '국내 최고층 555m·서울 스카이라인',         37.5125, 127.1025, 100, '랜드마크', '서울', '송파구'),
(19, 'DDP',              'Dongdaemun Design Plaza',  '자하 하디드 설계 미래형 건축',              37.5673, 127.0096, 120, '랜드마크', '서울', '중구'),
(21, '코엑스 별마당도서관', 'Starfield Library COEX', '초대형 책장이 인상적인 도서관',             37.5125, 127.0590, 60,  '문화',     '서울', '강남구'),
(22, '청와대',           'Cheong Wa Dae',            '前 대통령 관저·일반 개방',                  37.5870, 126.9747, 150, '역사',     '서울', '종로구'),
(23, '광장시장',         'Gwangjang Market',         '한국 최초의 상설시장·먹거리 천국',          37.5703, 126.9999, 80,  '시장',     '서울', '종로구'),
(25, '명동',             'Myeongdong',               '쇼핑·먹거리·외국인 관광 중심지',            37.5636, 126.9826, 200, '거리',     '서울', '중구'),
(26, '홍대 거리',        'Hongdae Street',           '예술·인디 음악·클럽 중심지',                37.5563, 126.9233, 200, '거리',     '서울', '마포구'),
(27, '가로수길',         'Garosu-gil',               '은행나무 가로수와 패션 거리',                37.5202, 127.0233, 150, '거리',     '서울', '강남구'),
(28, '여의도 한강공원',  'Yeouido Hangang Park',     '벚꽃·불꽃축제·자전거 코스',                  37.5285, 126.9337, 200, '한강',     '서울', '영등포구'),
(29, '반포 한강공원',    'Banpo Hangang Park',       '달빛무지개분수·세빛섬',                     37.5117, 126.9970, 200, '한강',     '서울', '서초구'),
(31, '잠실 한강공원',    'Jamsil Hangang Park',      '롯데타워 야경 명소',                        37.5183, 127.0822, 200, '한강',     '서울', '송파구'),
(33, '남산공원',         'Namsan Park',              '서울 도심의 푸른 허파',                     37.5512, 126.9942, 200, '자연',     '서울', '중구'),
(34, '북한산 국립공원',  'Bukhansan National Park',  '서울의 명산·백운대 정상',                   37.6584, 126.9870, 300, '자연',     '서울', '은평구'),
(35, '인왕산',           'Inwangsan',                '호랑이 전설·서울 성곽 코스',                37.5818, 126.9573, 200, '자연',     '서울', '종로구'),
(37, '서울숲',           'Seoul Forest',             '도심 속 사슴 사육·생태 공원',                37.5444, 127.0376, 250, '자연',     '서울', '성동구'),
(39, '국립중앙박물관',   'National Museum of Korea', '한국 최대 박물관·반가사유상',                37.5240, 126.9803, 150, '문화',     '서울', '용산구'),
(44, '강남역',           'Gangnam Station',          '서울 최대 유동인구·번화가',                  37.4979, 127.0276, 180, '거리',     '서울', '강남구'),
(45, '이태원',           'Itaewon',                  '글로벌 거리·다양한 문화',                    37.5347, 126.9947, 180, '거리',     '서울', '용산구')
ON CONFLICT (id) DO NOTHING;

-- 시퀀스 재설정
SELECT setval('public.locations_id_seq', GREATEST((SELECT MAX(id) FROM public.locations), 100));

-- ── 30 배지 (location_id와 1:1) ──
INSERT INTO public.badges (id, location_id, name, grade, xp_reward, requires_confirmation, icon, color_hex) VALUES
(1,  1,  '경복궁',           'special', 300, TRUE,  '🏯', '#C8102E'),
(2,  2,  '창덕궁',           'rare',    150, TRUE,  '🏯', '#1F5E3B'),
(3,  3,  '창경궁',           'common',   50, FALSE, '🏯', '#8B4513'),
(4,  4,  '덕수궁',           'rare',    150, TRUE,  '🏛', '#D4AF37'),
(5,  5,  '종묘',             'rare',    150, TRUE,  '⛩', '#4A4A4A'),
(7,  7,  '광화문 광장',      'common',   50, FALSE, '🗿', '#003478'),
(8,  8,  '숭례문',           'common',   50, FALSE, '🏛', '#A0522D'),
(11, 11, '북촌 한옥마을',    'rare',    150, TRUE,  '🏘', '#6B4226'),
(12, 12, '인사동',           'common',   50, FALSE, '🖌', '#8B0000'),
(13, 13, '삼청동',           'common',   50, FALSE, '🍂', '#DAA520'),
(14, 14, '익선동',           'common',   50, FALSE, '☕', '#E07B00'),
(16, 16, 'N서울타워',        'special', 300, TRUE,  '🗼', '#FF6B6B'),
(17, 17, '롯데월드타워',     'rare',    150, TRUE,  '🏙', '#1E3A8A'),
(19, 19, 'DDP',              'common',   50, FALSE, '🛸', '#C0C0C0'),
(21, 21, '코엑스 별마당도서관', 'common', 50, FALSE, '📚', '#3B82F6'),
(22, 22, '청와대',           'special', 400, TRUE,  '🏛', '#1F4E79'),
(23, 23, '광장시장',         'common',   50, FALSE, '🥘', '#E63946'),
(25, 25, '명동',             'common',   50, FALSE, '🛍', '#FF69B4'),
(26, 26, '홍대 거리',        'common',   50, FALSE, '🎸', '#9333EA'),
(27, 27, '가로수길',         'common',   50, FALSE, '👗', '#FFD700'),
(28, 28, '여의도 한강공원',  'common',   50, FALSE, '🌸', '#FFB6C1'),
(29, 29, '반포 한강공원',    'rare',    150, TRUE,  '🌈', '#7DD3FC'),
(31, 31, '잠실 한강공원',    'common',   50, FALSE, '🌃', '#1E40AF'),
(33, 33, '남산공원',         'common',   50, FALSE, '🌲', '#15803D'),
(34, 34, '북한산 국립공원',  'special', 400, TRUE,  '⛰', '#374151'),
(35, 35, '인왕산',           'rare',    150, TRUE,  '🐯', '#92400E'),
(37, 37, '서울숲',           'common',   50, FALSE, '🦌', '#65A30D'),
(39, 39, '국립중앙박물관',   'rare',    150, TRUE,  '🗿', '#7C2D12'),
(44, 44, '강남역',           'common',   50, FALSE, '🌆', '#0EA5E9'),
(45, 45, '이태원',           'common',   50, FALSE, '🌍', '#A855F7')
ON CONFLICT (id) DO NOTHING;

SELECT setval('public.badges_id_seq', GREATEST((SELECT MAX(id) FROM public.badges), 100));

-- ── 검증 ──
-- 다음 결과가 보이면 성공:
--   locations: 30
--   badges:    30 (common 19, rare 8, special 3)
SELECT 'locations' AS table_name, COUNT(*) AS count FROM public.locations
UNION ALL
SELECT 'badges',                  COUNT(*) FROM public.badges
UNION ALL
SELECT 'badges_common',           COUNT(*) FROM public.badges WHERE grade = 'common'
UNION ALL
SELECT 'badges_rare',             COUNT(*) FROM public.badges WHERE grade = 'rare'
UNION ALL
SELECT 'badges_special',          COUNT(*) FROM public.badges WHERE grade = 'special';
