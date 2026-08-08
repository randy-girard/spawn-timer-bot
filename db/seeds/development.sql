-- Seed data extracted from db/development.sqlite
-- Load after migrations: rake db:seed

BEGIN;

TRUNCATE aliases, tods, characters, settings, timers RESTART IDENTITY CASCADE;

-- timers
INSERT INTO timers (id, name, window_start, window_end, variance, alerted, last_tod, alerting_soon, skip_count, auto_tod, linked_timer_id, clear_parent_timer_id, warn_time) VALUES (1, 'Autotod', '1 day', NULL, NULL, NULL, NULL, FALSE, 0, TRUE, NULL, NULL, NULL);
INSERT INTO timers (id, name, window_start, window_end, variance, alerted, last_tod, alerting_soon, skip_count, auto_tod, linked_timer_id, clear_parent_timer_id, warn_time) VALUES (2, 'fast', '5 minutes', NULL, NULL, NULL, NULL, FALSE, 0, FALSE, NULL, NULL, NULL);
INSERT INTO timers (id, name, window_start, window_end, variance, alerted, last_tod, alerting_soon, skip_count, auto_tod, linked_timer_id, clear_parent_timer_id, warn_time) VALUES (3, 'faster', '15 seconds', NULL, NULL, NULL, NULL, FALSE, 0, TRUE, NULL, NULL, NULL);
INSERT INTO timers (id, name, window_start, window_end, variance, alerted, last_tod, alerting_soon, skip_count, auto_tod, linked_timer_id, clear_parent_timer_id, warn_time) VALUES (4, 'long', '2 days', '7 days', NULL, NULL, NULL, FALSE, 0, FALSE, NULL, NULL, NULL);
INSERT INTO timers (id, name, window_start, window_end, variance, alerted, last_tod, alerting_soon, skip_count, auto_tod, linked_timer_id, clear_parent_timer_id, warn_time) VALUES (5, 'Another', '2 days', '4 days', NULL, NULL, NULL, FALSE, 0, FALSE, NULL, NULL, NULL);
INSERT INTO timers (id, name, window_start, window_end, variance, alerted, last_tod, alerting_soon, skip_count, auto_tod, linked_timer_id, clear_parent_timer_id, warn_time) VALUES (6, 'Derakor The Vindicator', '6 hours', '7 hours', NULL, NULL, NULL, FALSE, 0, FALSE, NULL, NULL, NULL);
INSERT INTO timers (id, name, window_start, window_end, variance, alerted, last_tod, alerting_soon, skip_count, auto_tod, linked_timer_id, clear_parent_timer_id, warn_time) VALUES (7, 'Lord Nagafen', '7 days', NULL, '8 hours', NULL, NULL, FALSE, 0, FALSE, NULL, NULL, NULL);
INSERT INTO timers (id, name, window_start, window_end, variance, alerted, last_tod, alerting_soon, skip_count, auto_tod, linked_timer_id, clear_parent_timer_id, warn_time) VALUES (8, 'Naggy RF', '0 hours', '72 hours', NULL, NULL, NULL, FALSE, 0, FALSE, 7, 9, NULL);
INSERT INTO timers (id, name, window_start, window_end, variance, alerted, last_tod, alerting_soon, skip_count, auto_tod, linked_timer_id, clear_parent_timer_id, warn_time) VALUES (9, 'Zordak Ragefire', '1 day', NULL, '8 hours', NULL, NULL, FALSE, 0, FALSE, NULL, NULL, NULL);
INSERT INTO timers (id, name, window_start, window_end, variance, alerted, last_tod, alerting_soon, skip_count, auto_tod, linked_timer_id, clear_parent_timer_id, warn_time) VALUES (10, 'SRO Night Time', '72 minutes', NULL, NULL, NULL, NULL, FALSE, 0, TRUE, NULL, NULL, '5 minutes');
INSERT INTO timers (id, name, window_start, window_end, variance, alerted, last_tod, alerting_soon, skip_count, auto_tod, linked_timer_id, clear_parent_timer_id, warn_time) VALUES (11, 'Lodizal', '18 hours', NULL, '1 hour', NULL, NULL, FALSE, 1, FALSE, NULL, NULL, NULL);
INSERT INTO timers (id, name, window_start, window_end, variance, alerted, last_tod, alerting_soon, skip_count, auto_tod, linked_timer_id, clear_parent_timer_id, warn_time) VALUES (12, 'shortwindow', '1 minute', NULL, '10 seconds', NULL, NULL, FALSE, 0, FALSE, NULL, NULL, NULL);

-- settings
INSERT INTO settings (id, key, value) VALUES (1, 'webhook_message_id', '1432801264919646459');

-- aliases
INSERT INTO aliases (id, timer_id, name, created_at) VALUES (2, 2, 'super fast', '2022-07-06 13:37:07.130853');
INSERT INTO aliases (id, timer_id, name, created_at) VALUES (3, 6, 'Vindi', '2022-07-06 13:41:56.808934');
INSERT INTO aliases (id, timer_id, name, created_at) VALUES (4, 6, 'vindy', '2022-07-06 13:49:41.773354');
INSERT INTO aliases (id, timer_id, name, created_at) VALUES (6, 2, 'bob', '2022-07-06 13:52:37.663931');
INSERT INTO aliases (id, timer_id, name, created_at) VALUES (7, 6, 'fast', '2022-07-06 13:53:11.292856');
INSERT INTO aliases (id, timer_id, name, created_at) VALUES (8, 6, 'noway', '2022-07-06 13:53:36.933167');
INSERT INTO aliases (id, timer_id, name, created_at) VALUES (9, 2, 'noway hosay', '2022-07-06 13:53:42.610804');

-- tods
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (1, 1, '222705027536519168', 'freezzo', 'freezzo', 1650397525.654592, '2022-04-19 15:45:25.677211');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (2, 1, NULL, NULL, NULL, 1650397586.6156821, '2022-04-19 15:46:26.813118');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (3, 1, '222705027536519168', 'freezzo', 'freezzo', 1650397972.400436, '2022-04-19 15:52:52.411544');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (4, 1, NULL, NULL, NULL, 1650398033.372937, '2022-04-19 15:53:53.610186');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (5, 1, NULL, NULL, NULL, 1650398094.506628, '2022-04-19 15:54:54.722021');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (6, 3, '266714829010632705', 'Pumped <Castle>', 'Pumped', 1650559464.796087, '2022-04-21 12:44:24.802653');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (7, 3, NULL, NULL, NULL, 1650559480.291309, '2022-04-21 12:44:40.664414');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (8, 3, NULL, NULL, NULL, 1650559495.5764182, '2022-04-21 12:44:55.845767');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (9, 2, '222705027536519168', 'freezzo', 'freezzo', 1650805378.389149, '2022-04-24 09:02:58.396501');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (10, 4, '222705027536519168', 'freezzo', 'freezzo', 1650805486.843315, '2022-04-24 09:04:46.852209');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (11, 5, '222705027536519168', 'freezzo', 'freezzo', 1650546321.3272278, '2022-04-24 09:05:21.337032');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (12, 4, '222705027536519168', 'freezzo', 'freezzo', 1651083877.737956, '2022-04-27 14:24:37.746599');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (13, 5, '222705027536519168', 'freezzo', 'freezzo', 1654349859.121849, '2022-06-04 09:37:39.130546');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (14, 5, '222705027536519168', 'freezzo', 'freezzo', 1654259877.354527, '2022-06-04 09:37:57.366219');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (15, 4, '222705027536519168', 'freezzo', 'freezzo', 1654350204.699189, '2022-06-04 09:43:24.706648');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (16, 5, '222705027536519168', 'freezzo', 'freezzo', 1654350301.480514, '2022-06-04 09:45:01.488622');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (17, 5, '222705027536519168', 'freezzo', 'freezzo', 1654091113.376388, '2022-06-04 09:45:13.388175');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (18, 5, '222705027536519168', 'freezzo', 'freezzo', 1654188427.912399, '2022-06-04 09:47:07.925376');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (19, 5, '222705027536519168', 'freezzo', 'freezzo', 1654026440.6372108, '2022-06-04 09:47:20.647225');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (20, 2, '222705027536519168', 'freezzo', 'freezzo', 1654350109.6830359, '2022-06-04 09:47:49.692276');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (21, 2, '222705027536519168', 'freezzo', 'freezzo', 1654350239.46222, '2022-06-04 09:47:59.471836');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (22, 2, '222705027536519168', 'freezzo', 'Nanae', 1657126520.8296251, '2022-07-06 12:55:20.836137');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (23, 4, '222705027536519168', 'freezzo', 'Nanae', 1657126590.302112, '2022-07-06 12:56:30.309149');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (24, 5, '222705027536519168', 'freezzo', 'Nanae', 1657126747.663465, '2022-07-06 12:59:07.670636');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (25, 4, '222705027536519168', 'freezzo', 'Nanae', 1656997191.1009102, '2022-07-06 12:59:51.110859');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (26, 5, '222705027536519168', 'freezzo', 'Nanae', 1656867794.984471, '2022-07-06 13:03:14.993745');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (27, 6, '222705027536519168', 'freezzo', 'Nanae', 1657129787.616482, '2022-07-06 13:49:47.628206');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (28, 6, '222705027536519168', 'freezzo', 'Nanae', 1657129910.35818, '2022-07-06 13:51:50.365906');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (29, 6, '222705027536519168', 'freezzo', 'Nanae', 1657129921.450064, '2022-07-06 13:52:01.459127');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (30, 2, '222705027536519168', 'freezzo', 'Nanae', 1657129993.605922, '2022-07-06 13:53:13.612706');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (31, 4, '222705027536519168', 'freezzo', 'Nanae', 1658091281.516047, '2022-07-17 16:54:41.524109');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (32, 1, '222705027536519168', 'freezzo', 'Nanae', 1658091525.891495, '2022-07-17 16:58:45.898808');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (33, 5, '222705027536519168', 'freezzo', 'Nanae', 1658105329.921592, '2022-07-17 20:48:49.930782');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (34, 2, '222705027536519168', 'freezzo', 'Nanae', 1658105354.87377, '2022-07-17 20:49:14.881031');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (35, 3, '222705027536519168', 'freezzo', 'Nanae', 1658105356.9470022, '2022-07-17 20:49:16.957316');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (36, 6, '222705027536519168', 'freezzo', 'Nanae', 1658105360.016106, '2022-07-17 20:49:20.023818');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (37, 3, NULL, NULL, NULL, 1658105371.999276, '2022-07-17 20:49:32.274645');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (38, 3, NULL, NULL, NULL, 1658105387.1934102, '2022-07-17 20:49:47.413667');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (39, 7, '222705027536519168', 'freezzo', 'Nanae', 1658263557.0426261, '2022-07-19 16:45:57.053392');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (40, 8, '222705027536519168', 'freezzo', 'Nanae', 1658263557.0426261, '2022-07-19 16:45:57.055016');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (41, 7, '222705027536519168', 'freezzo', 'Nanae', 1658263716.8817651, '2022-07-19 16:48:36.896533');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (42, 8, '222705027536519168', 'freezzo', 'Nanae', 1658263716.8817651, '2022-07-19 16:48:36.899605');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (43, 9, '222705027536519168', 'freezzo', 'Nanae', 1658264403.785484, '2022-07-19 17:00:03.797397');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (44, 9, '222705027536519168', 'freezzo', 'Nanae', 1658264490.855705, '2022-07-19 17:01:30.865933');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (45, 10, '222705027536519168', 'freezzo', 'Nanae', 1658334300, '2022-07-20 13:24:05.447464');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (46, 10, '222705027536519168', 'freezzo', 'Nanae', 1658338440, '2022-07-20 13:35:42.080417');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (47, 11, '222705027536519168', 'freezzo', 'Nanae', 1658415353, '2022-07-22 21:03:39.873134');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (48, 4, '222705027536519168', 'freezzo', 'Nanae', 1659209869.867546, '2022-07-30 15:37:49.874062');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (49, 2, '266714829010632705', 'Pumped <Castle>', 'Pumped', 1659210086.806699, '2022-07-30 15:41:26.815147');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (50, 3, '222705027536519168', 'freezzo', 'Randy', 1761676905.5289001, '2025-10-28 14:41:45.535332');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (51, 3, NULL, NULL, NULL, 1761676921.101347, '2025-10-28 14:42:01.454865');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (52, 3, NULL, NULL, NULL, 1761676949.056533, '2025-10-28 14:42:29.299935');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (53, 3, NULL, NULL, NULL, 1761676964.4200902, '2025-10-28 14:42:44.740146');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (54, 3, NULL, NULL, NULL, 1761676979.628084, '2025-10-28 14:42:59.840127');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (55, 3, NULL, NULL, NULL, 1761676994.8960168, '2025-10-28 14:43:15.282241');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (56, 3, NULL, NULL, NULL, 1761677009.920171, '2025-10-28 14:43:30.132285');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (57, 3, NULL, NULL, NULL, 1761677025.154783, '2025-10-28 14:43:45.337391');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (58, 3, NULL, NULL, NULL, 1761677040.4057028, '2025-10-28 14:44:00.615004');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (59, 3, NULL, NULL, NULL, 1761677056.19677, '2025-10-28 14:44:16.428114');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (60, 3, NULL, NULL, NULL, 1761677178.721828, '2025-10-28 14:46:18.928549');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (61, 3, NULL, NULL, NULL, 1761677194.134936, '2025-10-28 14:46:34.345266');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (62, 12, '222705027536519168', 'freezzo', 'Randy', 1761677258.585305, '2025-10-28 14:47:38.595929');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (63, 12, '222705027536519168', 'freezzo', 'Randy', 1761677521.98225, '2025-10-28 14:52:01.991917');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (64, 12, '222705027536519168', 'freezzo', 'Randy', 1761677873.2537432, '2025-10-28 14:57:53.262687');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (65, 12, '222705027536519168', 'freezzo', 'Randy', 1761677982.204855, '2025-10-28 14:59:42.214878');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (66, 12, '222705027536519168', 'freezzo', 'Randy', 1761678145.120301, '2025-10-28 15:02:25.129512');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (67, 12, '222705027536519168', 'freezzo', 'Randy', 1761678274.3872771, '2025-10-28 15:04:34.398014');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (68, 12, '222705027536519168', 'freezzo', 'Randy', 1761678585.675609, '2025-10-28 15:09:45.684870');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (69, 12, '222705027536519168', 'freezzo', 'Randy', 1761678724.231106, '2025-10-28 15:12:04.241419');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (70, 12, '222705027536519168', 'freezzo', 'Randy', 1761678959.526701, '2025-10-28 15:15:59.538392');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (71, 12, '222705027536519168', 'freezzo', 'Randy', 1761679021.347341, '2025-10-28 15:17:01.359054');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (72, 12, '222705027536519168', 'freezzo', 'Randy', 1761679686.97074, '2025-10-28 15:28:06.993974');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (73, 12, '222705027536519168', 'freezzo', 'Randy', 1761681073.390849, '2025-10-28 15:51:13.401608');
INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (74, 12, '222705027536519168', 'freezzo', 'Randy', 1761683233.249485, '2025-10-28 16:27:13.261972');

-- characters
INSERT INTO characters (id, name, inventory_data, spellbook_data, inventory_updated_at, spellbook_updated_at, created_at, updated_at) VALUES (1, 'Aftershock', 'Location	Name	ID	Count	Slots
Charm	Empty	0	0	0
Ear	Empty	0	0	0
Head	Empty	0	0	0
Face	Empty	0	0	0
Ear	Empty	0	0	0
Neck	Empty	0	0	0
Shoulders	Empty	0	0	0
Arms	Empty	0	0	0
Back	Empty	0	0	0
Wrist	Empty	0	0	0
Wrist	Empty	0	0	0
Range	Empty	0	0	0
Hands	Empty	0	0	0
Primary	Empty	0	0	0
Secondary	A Worn Candle	9979	1	5
Fingers	Empty	0	0	0
Fingers	Empty	0	0	0
Chest	Empty	0	0	0
Legs	Empty	0	0	0
Feet	Empty	0	0	0
Waist	Empty	0	0	0
Ammo	Empty	0	0	0
General1	Skin of Milk	9990	3	5
General2	Hand Made Backpack	17969	1	10
General2-Slot1	Words of Recluse	11832	1	5
General2-Slot2	Words of the Sentient (Beza)	11831	1	5
General2-Slot3	Words of Allure	11829	1	5
General2-Slot4	Words of Dimension	11871	1	5
General2-Slot5	Words of Detachment	11835	1	5
General2-Slot6	Velishoul''s Tome Pg. 9	16083	1	5
General2-Slot7	Words of Convocation	11872	1	5
General2-Slot8	Words of Descrying	11852	1	5
General2-Slot9	Words of Haunting	11836	1	5
General2-Slot10	A Faded Velishoul''s Tome Page	16084	1	5
General3	Backpack	17005	1	8
General3-Slot1	Rune of Karana	11753	9	5
General3-Slot2	Rune of Contortion	11769	5	5
General3-Slot3	Rune of Dismemberment	11755	1	5
General3-Slot4	Rune of Fulguration	11741	14	5
General3-Slot5	Rune of Al''Kabor	11746	20	5
General3-Slot6	Rune of Rathe	11776	2	5
General3-Slot7	Rune of Tyranny	11771	1	5
General3-Slot8	Rune of the Cyclone	11767	1	5
General4	Rune of Al''Kabor	11746	1	5
General5	Rune of Velious	11745	1	5
General6	Backpack	17005	1	8
General6-Slot1	Rune of Rallos Zek	11757	1	5
General6-Slot2	Rune of Paralysis	11772	1	5
General6-Slot3	Rune of the Catalyst	11765	1	5
General6-Slot4	Rune of Nagafen	16054	2	5
General6-Slot5	Rune of Arrest	11762	1	5
General6-Slot6	Rune of Conception	11774	2	5
General6-Slot7	Words of Refuge	11819	1	5
General6-Slot8	Rune of Solusek Ro	11766	1	5
General7	Backpack	17005	1	8
General7-Slot1	Words of Incarceration	11804	1	5
General7-Slot2	Words of Burnishing	11862	1	5
General7-Slot3	Words of Obligation	11863	1	5
General7-Slot4	Words of Allure	11829	1	5
General7-Slot5	Words of Collection (Caza)	11864	1	5
General7-Slot6	Words of Transcendence	11792	1	5
General7-Slot7	Words of Derivation	16024	1	5
General7-Slot8	Words of Possession	11815	1	5
General8	Shralok Pack	17401	1	8
General8-Slot1	Words of Discernment	11823	2	5
General8-Slot2	Blue Diamond	22503	1	5
General8-Slot3	Tears of Prexus	11806	1	5
General8-Slot4	Ruby	10035	1	5
General8-Slot5	Words of Radiance	11824	1	5
General8-Slot6	The Scent of Marr	11802	3	5
General8-Slot7	Breath of Ro	11808	2	5
General8-Slot8	Black Marble	25805	1	5
Held	Empty	0	0	0
Bank1	Empty	0	0	0
Bank2	Empty	0	0	0
Bank3	Empty	0	0	0
Bank4	Empty	0	0	0
Bank5	Empty	0	0	0
Bank6	Empty	0	0	0
Bank7	Empty	0	0	0
Bank8	Empty	0	0	0
Bank9	Empty	0	0	0
Bank10	Empty	0	0	0
Bank11	Empty	0	0	0
Bank12	Empty	0	0	0
Bank13	Empty	0	0	0
Bank14	Empty	0	0	0
Bank15	Empty	0	0	0
Bank16	Empty	0	0	0
SharedBank1	Empty	0	0	0
SharedBank2	Empty	0	0	0
', NULL, '2026-07-01 13:31:44.645940', NULL, '2026-07-01 13:30:30.073686', '2026-07-01 13:31:44.646323');

SELECT setval(pg_get_serial_sequence('timers', 'id'), COALESCE((SELECT MAX(id) FROM timers), 1));
SELECT setval(pg_get_serial_sequence('settings', 'id'), COALESCE((SELECT MAX(id) FROM settings), 1));
SELECT setval(pg_get_serial_sequence('aliases', 'id'), COALESCE((SELECT MAX(id) FROM aliases), 1));
SELECT setval(pg_get_serial_sequence('tods', 'id'), COALESCE((SELECT MAX(id) FROM tods), 1));
SELECT setval(pg_get_serial_sequence('characters', 'id'), COALESCE((SELECT MAX(id) FROM characters), 1));

COMMIT;
