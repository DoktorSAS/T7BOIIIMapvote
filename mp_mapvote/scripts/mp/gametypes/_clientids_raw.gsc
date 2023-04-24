// TODO: Check whats using are not needed for the mapvote purpose
#using scripts\codescripts\struct;

#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\math_shared;
#using scripts\shared\sound_shared;
#using scripts\shared\util_shared;
#using scripts\shared\drown;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\challenges_shared;
#using scripts\shared\util_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\hud_message_shared;
#using scripts\shared\hud_shared;

#insert scripts\shared\shared.gsh;

#precache("material", "white");
#precache("material", "uie_t7_hud_waypoints_compassping_enemy");
#precache("material", "compassping_friendlyyelling_mp");

/*
	Mod: Mapvote Menu
	Developed by DoktorSAS
	Version: v0.1.0
	Config:
	set mv_enable			1 						// Enable/Disable the mapvote
	set mv_maps				""						// Lits of maps that can be voted on the mapvote, leave empty for all maps
	set mv_excludedmaps		""						// Lis of maps you don't want to show in the mapvote
	set mv_time 			1 						// Time to vote
	set mv_socialname 		"SocialName" 			// Name of the server social such as Discord, Twitter, Website, etc
	set mv_sentence 		"Thanks for playing" 	// Thankfull sentence
	set mv_votecolor		"5" 					// Color of the Vote Number
	set mv_arrowcolor		"white"					// RGB Color of the arrows
	set mv_selectcolor 		"lighgreen"				// RGB Color when map get voted
	set mv_backgroundcolor 	"grey"					// RGB Color of map background
	set mv_blur 			"3"						// Blur effect power
	set mv_gametypes 		"dm;dm.cfg"				// This dvar can be used to have multiple gametypes with different maps, with this dvar you can load gamemode cfg files

	Version: 0.1.0
	- 3 and 5 maps support
	- Credits, sentence and social on bottom left
	- Simple keyboard and controller button support
	- Allow to load gametypes
*/

#namespace mapvote;

REGISTER_SYSTEM("mapvote", &__init__, undefined)

function __init__()
{
	// this is now handled in code ( not lan )
	// see s_nextScriptClientId
	level.clientid = 0;

	callback::on_start_gametype(&init);
	callback::on_connect(&on_player_connect);
	callback::on_spawned(&on_player_spawned);
	// Note: Don't lock the game on the state but at least get called on endgame challenges::registerChallengesCallback( "gameEnd",&MapvoteStart );
}

function init()
{
	// precacheStatusIcon("uie_t7_hud_waypoints_compassping_enemy");
	// precacheStatusIcon("compassping_friendlyyelling_mp");
	MapvoteConfigurate();
	// Note: Don't lock the game on the state but at least get called on endgame
	// level.onEndGame_sub = level.onEndGame;
	// level.onEndGame = &MapvoteStart;
	// Note: Don't get called at all
	// level.endGameFunction = &MapvoteStart;
	// level.onRoundEndGame_stub = level.onRoundEndGame;
	// level.onRoundEndGame = &MapvoteStart;
	level.startMapvote = &MapvoteStart;
}

function MapvoteConfigurate()
{
	SetDvarIfNotInizialized("mv_enable", 1);
	if (getDvarInt("mv_enable") != 1) // Check if mapvote is enable
		return;						  // End if the mapvote its not enable

	level.mapvote = [];
	SetDvarIfNotInizialized("mv_time", 20);
	level.mapvote["time"] = getDvarInt("mv_time");
	// Nota: It is on end game and lock the game in the state but it display a fully white screen
	// if(!isDefined(level.end_game_video))
	//{
	//	level.end_game_video = SpawnStruct();
	//	level.end_game_video.duration = level.mapvote["time"];
	// }
	// else
	//{
	//	level.end_game_video.duration = level.end_game_video.duration + level.mapvote["time"];
	// }
	SetDvarIfNotInizialized("mv_maps", "mp_biodome mp_spire mp_sector mp_apartments mp_chinatown mp_veiled mp_havoc mp_ethiopia mp_infection mp_metro mp_redwood mp_stronghold mp_nuketown_x mp_shrine mp_ruins mp_cryogen mp_rome mp_crucible mp_kung_fu mp_miniature mp_western mp_conduit mp_rise mp_arena mp_city mp_skyjacked mp_aerospace mp_waterpark mp_banzai mp_veiled_heyday mp_redwood_ice");

	// PreCache maps images
	maps_data = [];
	maps_data = BuildMapsData();

	// Setting default values if needed
	SetDvarIfNotInizialized("mv_credits", 1);
	SetDvarIfNotInizialized("mv_socials", 1);
	SetDvarIfNotInizialized("mv_extramaps", 1);
	SetDvarIfNotInizialized("mv_socialname", "Discord");
	SetDvarIfNotInizialized("mv_sociallink", "Discord.gg/^3xlabs^7");
	SetDvarIfNotInizialized("mv_sentence", "Thanks for Playing by @DoktorSAS");
	SetDvarIfNotInizialized("mv_votecolor", "5");
	SetDvarIfNotInizialized("mv_arrowcolor", "white");
	SetDvarIfNotInizialized("mv_blur", "3");
	SetDvarIfNotInizialized("mv_scrollcolor", "cyan");
	SetDvarIfNotInizialized("mv_selectcolor", "lightgreen");
	SetDvarIfNotInizialized("mv_backgroundcolor", "grey");
	SetDvarIfNotInizialized("mv_gametypes", "dm;dm.cfg tdm;tdm.cfg dm;dm.cfg tdm;tdm.cfg sd;sd.cfg sd;sd.cfg");
	setDvarIfNotInizialized("mv_excludedmaps", "");

	// Nota: It is on end game and lock the game in the state but it display a fully white screen
	// level waittill("sfade");
	// level thread MapvoteStart();
}

function on_player_connect()
{
	self.clientid = matchRecordNewPlayer(self);
	if (!isdefined(self.clientid) || self.clientid == -1)
	{
		self.clientid = level.clientid;
		level.clientid++; // Is this safe? What if a server runs for a long time and many people join/leave
	}

	/#
		PrintLn("client: " + self.name + " clientid: " + self.clientid);
	#/
}

function on_player_spawned() // Patch for blur effect persisting (TODO: This issue is a BO2 issue, i don't know if BO3 have the same bug)
{
	self endon("disconnect");
	level endon("game_ended");
	//Note: Just for quit testing put level thread MapvoteStart(); here
	self setblur(0, 0);
	self thread handlePlayerButtons();
}

function handlePlayerButtons()
{
	self endon("disconnect");
	level endon("mv_destroy_hud");
	while (true)
	{
		if (self AdsButtonPressed())
		{
			self notify("right");
			wait 0.2;
		}

		if (self AttackButtonPressed())
		{
			self notify("left");
			wait 0.2;
		}

		if (self UseButtonPressed() || self JumpButtonPressed() || self ReloadButtonPressed())
		{
			self notify("select");
			wait 0.2;
		}
		wait 0.02;
	}
}

// utils.gsc
function SetDvarIfNotInizialized(dvar, value)
{
	if (!IsInizialized(dvar))
	{
		setDvar(dvar, value);
	}
}

function IsInizialized(dvar)
{
	result = GetDvarString(dvar);
	return result != "";
}

// mv_client.gsc
function MapvotePlayerUI()
{
	self setblur(getDvarFloat("mv_blur"), 1.5);

	scroll_color = getColor(getDvarString("mv_scrollcolor"));
	bg_color = getColor(getDvarString("mv_backgroundcolor"));
	// self FreezeControlsAllowLook(0);
	boxes = [];
	boxes[0] = self CreateRectangle("CENTER", "CENTER", -220, -452, 205, 133, scroll_color, "white", 1, 0);
	boxes[1] = self CreateRectangle("CENTER", "CENTER", 0, -452, 205, 133, bg_color, "white", 1, 0);
	boxes[2] = self CreateRectangle("CENTER", "CENTER", 220, -452, 205, 133, bg_color, "white", 1, 0);

	self thread ClientFixAngle();
	level waittill("mv_start_animation");

	if (getDvarInt("mv_extramaps") == 1)
	{
		dynamic_position = 100;
		boxes[3] = self CreateRectangle("CENTER", "CENTER", -120, -452, 205, 133, bg_color, "white", 2, 0);
		boxes[4] = self CreateRectangle("CENTER", "CENTER", 120, -452, 205, 133, bg_color, "white", 2, 0);
		boxes[3] affectElement("y", 1.2, -50 + dynamic_position);
		boxes[4] affectElement("y", 1.2, -50 + dynamic_position);
		boxes[0] affectElement("y", 1.2, -100);
		boxes[1] affectElement("y", 1.2, -100);
		boxes[2] affectElement("y", 1.2, -100);
	}
	else
	{
		boxes[0] affectElement("y", 1.2, -50);
		boxes[1] affectElement("y", 1.2, -50);
		boxes[2] affectElement("y", 1.2, -50);
	}

	self thread DestroyBoxes(boxes);
	self.statusicon = "uie_t7_hud_waypoints_compassping_enemy"; // Red dot
	level waittill("mv_start_vote");
	boxes[0] affectElement("alpha", 0.2, 1);
	boxes[1] affectElement("alpha", 0.2, 1);
	boxes[2] affectElement("alpha", 0.2, 1);
	if (boxes.size > 3)
	{
		boxes[3] affectElement("alpha", 0.2, 1);
		boxes[4] affectElement("alpha", 0.2, 1);
	}
	index = 0;
	isVoting = 1;
	while (level.mapvote["time"] > 0 && isVoting)
	{
		command = self util::waittill_any_return("left", "right", "select");
		if (command == "right")
		{
			index++;
			if (index == boxes.size)
				index = 0;
		}
		else if (command == "left")
		{
			index--;
			if (index < 0)
				index = boxes.size - 1;
		}

		if (command == "select")
		{
			isVoting = 0;
		}
		else
		{
			for (i = 0; i < boxes.size; i++)
			{
				if (i != index)
					boxes[i] affectElement("color", 0.2, bg_color);
				else
					boxes[i] affectElement("color", 0.2, scroll_color);
			}
		}
	}
	if (!isVoting)
	{
		self.statusicon = "compassping_friendlyyelling_mp"; // Green dot
		vote = "vote" + (index + 1);
		level notify(vote);
		select_color = getColor(GetDvarString("mv_selectcolor"));
		boxes[index] affectElement("color", 0.2, select_color);
		level waittill("mv_destroy_hud");
	}
}

function DestroyBoxes(boxes)
{
	level waittill("mv_destroy_hud");
	foreach (box in boxes)
	{
		box affectElement("alpha", 0.5, 0);
	}
	wait 0.5;
	foreach (box in boxes)
	{
		box hud::destroyElem();
	}
}

function ClientFixAngle() // TODO: Check if the bug happen also in BO3
{
	self endon("disconnect");
	level endon("game_ended");
	level waittill("mv_start_vote");
	angles = self getPlayerAngles();

	self util::waittill_any("left", "right");
	if (self getPlayerAngles() != angles)
		self setPlayerAngles(angles);
}

// mv_server.gsc
function MapvoteGetMapsThatCanBeVoted(mapslist)
{
	if (GetDvarString("mv_excludedmaps") != "")
	{
		maps = [];
		maps = strTok(GetDvarString("mv_excludedmaps"), " ");
		foreach (map in maps)
		{
			arrayremovevalue(mapslist, map);
		}
	}
	return mapslist;
}

function MapvoteGetRandomMaps(mapsIDs, times) // Select random map from the list
{
	mapschoosed = [];
	for (i = 0; i < times; i++)
	{
		index = RandomIntRange(0, mapsIDs.size);
		map = mapsIDs[index];
		mapschoosed[i] = map;
		logPrint("map;" + map + ";index;" + index + "\n");
		mapsIDs = ArrayRemoveElement(mapsIDs, map);
		// arrayremovevalue(mapsIDs, map);
	}

	return mapschoosed;
}
// Note: is required for  [[level.onEndGame_stub]](winner);  or [[level.onRoundEndGame_stub]](winner); -> function MapvoteStart(winner)
function MapvoteStart()
{
	if (getDvarInt("mv_enable") != 1 || !util::wasLastRound()) // Check if mapvote is enable
		return;						  // End if the mapvote its not enable

	if (!isDefined(level.mapvote_started))
	{
		level.mapvote_started = 1;
		// mapslist = [];
		maps_keys = [];
		maps_keys = strTok(GetDvarString("mv_maps"), " ");
		mapslist = MapvoteGetRandomMaps(maps_keys); // Remove blacklisted maps
		times = 3;
		if (getDvarInt("mv_extramaps") == 1)
		{
			times = 5;
		}

		mapschoosed = MapvoteGetRandomMaps(maps_keys, times);
		gametypes = [];
		gametypes = strTok(getDvarString("mv_gametypes"), " ");
		level.mapvote["map1"] = level.maps_data[mapschoosed[0]];
		level.mapvote["map2"] = level.maps_data[mapschoosed[1]];
		level.mapvote["map3"] = level.maps_data[mapschoosed[2]];

		level.mapvote["map1"].gametype = gametypes[RandomIntRange(0, gametypes.size)];
		level.mapvote["map2"].gametype = gametypes[RandomIntRange(0, gametypes.size)];
		level.mapvote["map3"].gametype = gametypes[RandomIntRange(0, gametypes.size)];

		level.mapvote["map1"].gametypeUI = GametypeToName(strTok(level.mapvote["map1"].gametype, ";")[0]);
		level.mapvote["map2"].gametypeUI = GametypeToName(strTok(level.mapvote["map2"].gametype, ";")[0]);
		level.mapvote["map3"].gametypeUI = GametypeToName(strTok(level.mapvote["map3"].gametype, ";")[0]);

		if (getDvarInt("mv_extramaps") == 1)
		{
			level.mapvote["map4"] = level.maps_data[mapschoosed[3]];
			level.mapvote["map5"] = level.maps_data[mapschoosed[4]];
			level.mapvote["map4"].gametype = gametypes[RandomIntRange(0, gametypes.size)];
			level.mapvote["map5"].gametype = gametypes[RandomIntRange(0, gametypes.size)];
			level.mapvote["map4"].gametypeUI = GametypeToName(strTok(level.mapvote["map4"].gametype, ";")[0]);
			level.mapvote["map5"].gametypeUI = GametypeToName(strTok(level.mapvote["map5"].gametype, ";")[0]);
		}

		foreach (player in level.players)
		{
			if (!player util::is_bot())
				player thread MapvotePlayerUI();
		}
		wait 0.2;
		level thread MapvoteServerUI();

		VoteManager();
	}
	// Note: Don't get called at all [[level.onRoundEndGame]](winner);
	// Note: Don't lock the game on the state but at least get called on endgame [[level.onEndGame_stub]](winner);
}

function MapvoteServerUI()
{
	mv_arrowcolor = GetColor(getDvarString("mv_arrowcolor"));
	mv_votecolor = getDvarString("mv_votecolor");

	buttons = level hud::createServerFontString("objective", 2);
	buttons setText("^3[{+speed_throw}]              ^7Press ^3[{+gostand}] ^7or ^3[{+activate}] ^7to select              ^3[{+attack}]");
	buttons.hideWhenInMenu = 0;

	mapsUI = [];
	mapsUI[0] = spawnStruct();
	mapsUI[1] = spawnStruct();
	mapsUI[2] = spawnStruct();

	mapsUI[0].mapname = level CreateString(level.mapvote["map1"].mapname + "\n" + level.mapvote["map1"].gametypeUI, "objective", 1.2, "CENTER", "CENTER", -220, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
	mapsUI[1].mapname = level CreateString(level.mapvote["map2"].mapname + "\n" + level.mapvote["map2"].gametypeUI, "objective", 1.2, "CENTER", "CENTER", 0, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
	mapsUI[2].mapname = level CreateString(level.mapvote["map3"].mapname + "\n" + level.mapvote["map3"].gametypeUI, "objective", 1.2, "CENTER", "CENTER", 220, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);

	if (getDvarInt("mv_extramaps") == 1)
	{
		buttons hud::setPoint("CENTER", "CENTER", 0, 150);
		mapsUI[3] = spawnStruct();
		mapsUI[4] = spawnStruct();

		mapsUI[3].mapname = level CreateString(level.mapvote["map4"].mapname + "\n" + level.mapvote["map4"].gametypeUI, "objective", 1.2, "CENTER", "CENTER", -120, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
		mapsUI[4].mapname = level CreateString(level.mapvote["map5"].mapname + "\n" + level.mapvote["map5"].gametypeUI, "objective", 1.2, "CENTER", "CENTER", 120, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
	}
	else
	{
		buttons hud::setPoint("CENTER", "CENTER", 0, 100);
	}

	level notify("mv_start_animation");

	for (i = 0; i < mapsUI.size; i++)
	{
		map = mapsUI[i];
		dynamic_position = 0;
		if (mapsUI.size > 3 && i < 3)
		{
			dynamic_position = -50;
		}
		else if (mapsUI.size > 3 && i > 2)
		{
			dynamic_position = 100;
		}
		map.mapname.alpha = 0;
		map.mapname affectElement("alpha", 1.6, 1);
		map.mapname.y = -9 + dynamic_position;
		if (isDefined(map.textbg))
		{
			map.textbg.y = 186 + dynamic_position;
		}
		//map.image affectElement("y", 1.2, 89 + dynamic_position);
	}

	wait 1;
	level notify("mv_start_vote");

	mv_sentence = GetDvarString("mv_sentence");
	mv_socialname = GetDvarString("mv_socialname");
	mv_sociallink = GetDvarString("mv_sociallink");
	credits = level hud::createServerFontString("objective", 1.2);
	credits hud::setPoint("BOTTOM_LEFT", "BOTTOM_LEFT", 15, -70);
	credits setText(mv_sentence + "\nDeveloped by @^5DoktorSAS ^7\n" + mv_socialname + ": " + mv_sociallink);
	credits affectElement("alpha", 0.5, 1);

	timer = level hud::createServerFontString("objective", 2);
	timer hud::setPoint("TOP", "TOP", "CENTER", 30);
	timer setTimer(level.mapvote["time"]);
	wait level.mapvote["time"];
	level notify("mv_destroy_hud");
	// logPrint("mapvote//mv_ServerUI " + getTime()/1000 + "\n");

	foreach (map in mapsUI)
	{
		map.mapname affectElement("alpha", 0.4, 0);
		if (isDefined(map.textbg))
		{
			map.textbg affectElement("alpha", 0.4, 0);
		}
		//map.image affectElement("alpha", 0.4, 0);
	}

	credits affectElement("alpha", 0.5, 0);
	timer affectElement("alpha", 0.5, 0);

	buttons affectElement("alpha", 0.4, 0);

	foreach (player in level.players)
	{
		player notify("done");
		player setblur(0, 0);
	}
}

function VoteManager()
{
	votes = [];
	votes[0] = spawnStruct();
	votes[1] = spawnStruct();
	votes[2] = spawnStruct();
	votes[0].votes = level CreateString(0, "objective", 1.5, "LEFT", "CENTER", -150, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
	votes[0].votes.label = "^" + getDvarInt("mv_votecolor");
	votes[0].map = level.mapvote["map1"];

	votes[1].votes = level CreateString(0, "objective", 1.5, "CENTER", "CENTER", 75, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
	votes[1].votes.label = "^" + getDvarInt("mv_votecolor");
	votes[1].map = level.mapvote["map2"];

	votes[2].votes = level CreateString(0, "objective", 1.5, "RIGHT", "CENTER", 290, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
	votes[2].votes.label = "^" + getDvarInt("mv_votecolor");
	votes[2].map = level.mapvote["map3"];
	if (getDvarInt("mv_extramaps") == 1)
	{
		votes[3] = spawnStruct();
		votes[4] = spawnStruct();
		votes[5] = spawnStruct();
		votes[3].votes = level CreateString(0, "objective", 1.5, "LEFT", "CENTER", -50, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
		votes[3].votes.label = "^" + getDvarInt("mv_votecolor");
		votes[3].map = level.mapvote["map4"];

		votes[4].votes = level CreateString(0, "objective", 1.5, "RIGHT", "CENTER", 190, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
		votes[4].votes.label = "^" + getDvarInt("mv_votecolor");
		votes[4].map = level.mapvote["map5"];
	}

	for (i = 0; i < votes.size; i++)
	{
		vote = votes[i];
		dynamic_position = 0;
		if (votes.size > 3 && i < 3)
		{
			dynamic_position = -50;
		}
		else if (votes.size > 3 && i > 2)
		{
			dynamic_position = 100;
		}
		vote.value = 0;
		vote.votes.alpha = 0;
		vote.votes.y = 1 + dynamic_position;
		vote.votes affectElement("alpha", 1.6, 1);
	}

	isInVote = 1;
	index = 0;
	while (isInVote)
	{
		notify_value = level util::waittill_any_return("vote1", "vote2", "vote3", "vote4", "vote5", "mv_destroy_hud");

		if (notify_value == "mv_destroy_hud")
		{
			isInVote = 0; // Note: Required, seems that the break don't make the while quit.
			break;
		}
		else
		{
			switch (notify_value)
			{
			case "vote1":
				index = 0;
				break;
			case "vote2":
				index = 1;
				break;
			case "vote3":
				index = 2;
				break;
			case "vote4":
				index = 3;
				break;
			case "vote5":
				index = 4;
				break;
			}
			votes[index].value++;
			votes[index].votes setValue(votes[index].value);
		}
	}

	foreach (vote in votes)
	{
		vote.votes affectElement("alpha", 0.5, 0);
	}

	winner = MapvoteGetMostVotedMap(votes);
	map = winner.map;
	MapvoteSetRotation(map.exec_rotation, map.gametype);

	wait 1.2;
}

function MapvoteGetMostVotedMap(votes)
{
	winner = spawnStruct();
	winner = votes[0];
	for (i = 1; i < votes.size; i++)
	{
		if (isDefined(votes[i]) && votes[i].value > winner.value)
		{
			winner = votes[i];
		}
	}

	return winner;
}

function MapvoteSetRotation(mapid, gametype)
{
	array = strTok(gametype, ";");
	str = "";
	if (array.size > 0)
	{
		str = "gametype " + array[0];
	}
	if (array.size > 1)
	{
		str = str + " exec " + array[1];
	}
	setdvar("sv_maprotationcurrent", str + " map " + mapid);
	setdvar("sv_maprotation", str + " map " + mapid);
	level notify("mv_ended");
}

function insertMap(key, displayname, image, exec_rotation)
{
	/*
		key          : it rappresent that map id/key to use on the dvar mp_maps
		displayname : displayname3 its the mapname used for the 3 maps mapvote version
		image        : is the image shader to use for the map
		exec_rotation: it rappresent the value of sv_maprotationcurrent before map rotation get invoked
	*/
	level.maps_data[key] = SpawnStruct();
	level.maps_data[key].mapname = displayname;
	level.maps_data[key].exec_rotation = exec_rotation;
	level.maps_data[key].image = image;
}

function BuildMapsData()
{
	level.maps_data = [];
	insertMap("mp_biodome", "Aquarium", "img_t7_menu_mp_preview_biodome", "mp_biodome");
	insertMap("mp_spire", "Breach", "img_t7_menu_mp_preview_spire", "mp_spire");
	insertMap("mp_sector", "Combine", "img_t7_menu_mp_preview_sector", "mp_sector");
	insertMap("mp_apartments", "Evac", "img_t7_menu_mp_preview_apartments", "mp_apartments");
	insertMap("mp_chinatown", "Exodus", "img_t7_menu_mp_preview_chinatown", "mp_chinatown");
	insertMap("mp_veiled", "Fringe", "img_t7_menu_mp_preview_veiled", "mp_veiled");
	insertMap("mp_havoc", "Havoc", "img_t7_menu_mp_preview_havoc", "mp_havoc");
	insertMap("mp_ethiopia", "Hunted", "img_t7_menu_mp_preview_ethiopia", "mp_ethiopia");
	insertMap("mp_infection", "Infection", "img_t7_menu_mp_preview_infection", "mp_infection");
	insertMap("mp_metro", "Metro", "img_t7_menu_mp_preview_metro", "mp_metro");
	insertMap("mp_redwood", "Redwood","img_t7_menu_mp_preview_redwood", "mp_redwood");
	insertMap("mp_stronghold", "Stronghold", "img_t7_menu_mp_preview_stronghold", "mp_stronghold");
	insertMap("mp_nuketown_x", "Nuk3town", "img_t7_menu_mp_preview_nuketown_x", "mp_nuketown_x");

	// Awakening DLC
	insertMap("mp_crucible", "Gauntlet", "img_t7_menu_mp_preview_crucible", "mp_crucible");
	insertMap("mp_rise", "Rise", "img_t7_menu_mp_preview_rise", "mp_rise");
	insertMap("mp_skyjacked", "Skyjacked", "img_t7_menu_mp_preview_skyjacked", "mp_skyjacked");
	insertMap("mp_waterpark", "Splash", "img_t7_menu_mp_preview_waterpark", "mp_waterpark");

	// Eclipse DLC
	insertMap("mp_kung_fu", "Knockout", "img_t7_menu_mp_preview_kung_fu", "mp_kung_fu");
	insertMap("mp_conduit", "Rift", "img_t7_menu_mp_preview_conduit", "mp_conduit");
	insertMap("mp_aerospace", "Spire", "img_t7_menu_mp_preview_aerospace", "mp_aerospace");
	insertMap("mp_banzai", "Verge", "img_t7_menu_mp_preview_banzai", "mp_banzai");

	// Descent DLC
	insertMap("mp_shrine", "Berserk", "img_t7_menu_mp_preview_shrine", "mp_shrine");
	insertMap("mp_cryogen", "Cryogen", "img_t7_menu_mp_preview_cryogen", "mp_cryogen");
	insertMap("mp_rome", "Empire", "img_t7_menu_mp_preview_rome", "mp_rome");
	insertMap("mp_arena", "Rumble", "img_t7_menu_mp_preview_arena", "mp_arena");

	// Salvation DLC
	insertMap("mp_ruins", "Citadel", "img_t7_menu_mp_preview_ruins", "mp_ruins");
	insertMap("mp_miniature", "Micro", "img_t7_menu_mp_preview_miniature", "mp_miniature");
	insertMap("mp_western", "Outlaw", "img_t7_menu_mp_preview_western", "mp_western");
	insertMap("mp_city", "Rupture", "img_t7_menu_mp_preview_city", "mp_city");

	// Bonus Maps
	insertMap("mp_veiled_heyday", "Fringe Night", "img_t7_menu_mp_preview_veiled_heyday", "mp_veiled_heyday");
	insertMap("mp_redwood_ice", "Redwood Snow", "img_t7_menu_mp_preview_redwood_ice", "mp_redwood_ice");

	/*
		To add a new map to the mapvote you need to edit this function called buildmaps_dataata.
		How to do it?
		1. Copy insertMap("", "",  "", ""); and paste it under level.maps_dataata = [];
		2. Compile the empty spaces, the arguments in ordare are:
			1) Map custom id: Is an id that you can use in your mv_maps dvar to identify this specific map
			2) Map UI name: Is the display name
			4) Map preview: Is the image to display on the mapvote
			5) Map config: This is the code that get executed once the map rotate to the winning map on the mapvote
		Let's make an exemple, i want to add a map called "Minecraft" so i'll add this code:
			insertMap("mp_minecraft", "Minecraft", "preview_mp_minecraft", "mp_minecraft");
	*/
}

function CreateString(input, font, fontScale, align, relative, x, y, color, alpha, glowColor, glowAlpha, sort, isValue)
{
	if (self != level)
	{
		hud = hud::createFontString(font, fontScale);
	}
	else
	{
		hud = hud::createServerFontString(font, fontScale);
	}

	if (!isDefined(isValue))
	{
		hud setText(input);
	}
	else
	{
		hud setValue(int(input));
	}

	hud hud::setPoint(align, relative, x, y);
	hud.color = color;
	hud.alpha = alpha;
	hud.glowColor = glowColor;
	hud.glowAlpha = glowAlpha;
	hud.sort = sort;
	hud.alpha = alpha;
	hud.archived = 0;
	hud.hideWhenInMenu = 0;
	return hud;
}
function DrawShader(shader, x, y, width, height, color, alpha, sort, align, relative, isLevel)
{
	if (isDefined(isLevel))
		hud = newhudelem();
	else
		hud = newclienthudelem(self);
	hud.elemtype = "icon";
	hud.color = color;
	hud.alpha = 1;
	hud.sort = sort;
	hud.children = [];
	if (isDefined(align))
		hud.align = align;
	if (isDefined(relative))
		hud.relative = relative;
	hud hud::setparent(level.uiparent);
	hud.x = x;
	hud.y = y;
	hud setshader(shader, width, height);
	hud.hideWhenInMenu = 0;
	hud.archived = 0;
	return hud;
}

function CreateRectangle(align, relative, x, y, width, height, color, shader, sort, alpha)
{
	uiElement = newClientHudElem(self);
	uiElement.elemType = "bar";
	uiElement.width = width;
	uiElement.height = height;
	uiElement.align = align;
	uiElement.relative = relative;
	uiElement.xOffset = 0;
	uiElement.yOffset = 0;
	uiElement.hidewheninmenu = true;
	uiElement.children = [];
	uiElement.sort = sort;
	uiElement.color = color;
	uiElement.alpha = alpha;
	uiElement hud::setParent(level.uiParent);
	uiElement setShader(shader, width, height);
	uiElement.hidden = false;
	uiElement.archived = false;
	uiElement hud::setPoint(align, relative, x, y);
	return uiElement;
}

function ValidateColor(value)
{
	return value == "0" || value == "1" || value == "2" || value == "3" || value == "4" || value == "5" || value == "6" || value == "7";
}

function GetColor(color)
{
	switch (tolower(color))
	{
	case "red":
		return (0.960, 0.180, 0.180);

	case "black":
		return (0, 0, 0);

	case "grey":
		return (0.035, 0.059, 0.063);

	case "purple":
		return (1, 0.282, 1);

	case "pink":
		return (1, 0.623, 0.811);

	case "green":
		return (0, 0.69, 0.15);

	case "blue":
		return (0, 0, 1);

	case "lightblue":
	case "light blue":
		return (0.152, 0329, 0.929);

	case "lightgreen":
	case "light green":
		return (0.09, 1, 0.09);

	case "orange":
		return (1, 0662, 0.035);

	case "yellow":
		return (0.968, 0.992, 0.043);

	case "brown":
		return (0.501, 0.250, 0);

	case "cyan":
		return (0, 1, 1);

	case "white":
		return (1, 1, 1);
	}
}

function affectElement(type, time, value)
{
	if (type == "x" || type == "y")
		self moveOverTime(time);
	else
		self fadeOverTime(time);
	if (type == "x")
		self.x = value;
	if (type == "y")
		self.y = value;
	if (type == "alpha")
		self.alpha = value;
	if (type == "color")
		self.color = value;
}

function GametypeToName(gametype)
{
	switch (tolower(gametype))
	{
	case "dm":
		return "Free for all";
	break;
	case "tdm":
		return "Team Deathmatch";
	break;
	case "ball":
		return "Uplink";
	break;
	case "sd":
		return "Search & Destroy";
	break;
	case "sr":
		return "Search & Rescue";
	break;
	case "dom":
		return "Domination";
	break;
	case "dem":
		return "Demolition";
	break;
	case "conf":
		return "Kill Confirmed";
	break;
	case "ctf":
		return "Capture the Flag";
	break;
	case "shrp":
		return "Sharpshooter";
	break;
	case "gun":
		return "Gun Game";
	break;
	case "sas":
		return "Sticks & Stones";
	break;
	case "hq":
		return "Headquaters";
	break;
	case "koth":
		return "Hardpoint";
	break;
	case "escort":
		return "Safeguard";
	break;
	case "clean":
		return "Fracture";
	break;
	case "prop":
		return "Prop Hunt";
	break;
	case "infect":
		return "Infected";
	break;
	case "sniperonly":
		return "Snipers Only";
	break;
	}
	return "invalid";
}

function ArrayRemoveElement(array, todelete)
{
	newarray = [];
	foreach (element in array)
	{
		if (element != todelete)
		{
			newarray[newarray.size] = element;
		}
	}
	return newarray;
}